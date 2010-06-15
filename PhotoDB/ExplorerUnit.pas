unit ExplorerUnit;

interface

uses
  acDlgSelect, ActiveX, ExplorerTypes, DBCMenu, UnitDBKernel, UnitINI,
  ShellApi, dolphin_db, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, ComObj, Registry, PrintMainForm, UnitScripts, BitmapDB,
  Dialogs, ComCtrls, ShellCtrls, ImgList, Menus, ExtCtrls, ToolWin, Buttons,
  ImButton, StdCtrls, SaveWindowPos, AppEvnts, WebLink, UnitBitmapImageList,
  Network, GraphicCrypt, AddSessionPasswordUnit, UnitCrypting,
  ShellContextMenu, ShlObj, DropSource, DropTarget, Clipbrd, GraphicsCool,
  ProgressActionUnit, GraphicsBaseTypes, Math, DB, CommonDBSupport,
  EasyListview, ScPanel, MPCommonUtilities, MPCommonObjects, DragDropFile, 
  DragDrop, UnitRefreshDBRecordsThread, UnitPropeccedFilesSupport,
  UnitCryptingImagesThread, uVistaFuncs, wfsU, UnitDBDeclare, GraphicEx,
  UnitDBFileDialogs, UnitDBCommonGraphics, UnitFileExistsThread,
  UnitDBCommon, UnitCDMappingSupport, VRSIShortCuts, SyncObjs,
  uThreadForm;

type
  TExplorerForm = class(TThreadForm)
    SizeImageList: TImageList;
    PopupMenu1: TPopupMenu;
    SlideShow1: TMenuItem;
    Properties1: TMenuItem;
    Shell1: TMenuItem;
    Copy1: TMenuItem;
    Rename1: TMenuItem;
    Delete1: TMenuItem;
    DBitem1: TMenuItem;
    Splitter1: TSplitter;
    PopupMenu2: TPopupMenu;
    Addfolder1: TMenuItem;
    SelectAll1: TMenuItem;
    AddFile1: TMenuItem;
    HintTimer: TTimer;
    MainMenu1: TMainMenu;
    Open1: TMenuItem;
    N1: TMenuItem;
    Refresh1: TMenuItem;
    New1: TMenuItem;
    Directory1: TMenuItem;
    File1: TMenuItem;
    Exit1: TMenuItem;
    MainPanel: TPanel;
    ShellTreeView1: TShellTreeView;
    CloseButtonPanel: TPanel;
    Button1: TButton;
    PropertyPanel: TPanel;
    Refresh2: TMenuItem;
    OpenInNewWindow1: TMenuItem;
    Exit2: TMenuItem;
    N2: TMenuItem;
    View1: TMenuItem;
    MakeNew1: TMenuItem;
    Copy2: TMenuItem;
    Edit2: TMenuItem;
    N3: TMenuItem;
    SelectAll2: TMenuItem;
    Copy3: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    Tools1: TMenuItem;
    ShowUpdater2: TMenuItem;
    ShowUpdater1: TMenuItem;
    InfoPanel1: TMenuItem;
    ExplorerPanel1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    N4: TMenuItem;
    Back1: TMenuItem;
    Forward1: TMenuItem;
    Up1: TMenuItem;
    NewWindow1: TMenuItem;
    ShowFolders1: TMenuItem;
    ShowFiles1: TMenuItem;
    ShowHidden1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Cut2: TMenuItem;
    Paste2: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    Cut3: TMenuItem;
    Paste3: TMenuItem;
    SlideShow2: TMenuItem;
    Shell2: TMenuItem;
    NewWindow2: TMenuItem;
    StatusBar1: TStatusBar;
    GoToSearchWindow1: TMenuItem;
    DBManager1: TMenuItem;
    Searching1: TMenuItem;
    N9: TMenuItem;
    Options1: TMenuItem;
    ShowOnlyCommon1: TMenuItem;
    ShowPrivate1: TMenuItem;
    OpeninSearchWindow1: TMenuItem;
    Help1: TMenuItem;
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
    Help2: TMenuItem;
    Activation1: TMenuItem;
    About1: TMenuItem;
    HomePage1: TMenuItem;
    ContactWithAuthor1: TMenuItem;
    SelectedImages: TImage;
    ToolBarDisabledImageList: TImageList;
    N10: TMenuItem;
    CryptFile1: TMenuItem;
    ResetPassword1: TMenuItem;
    N11: TMenuItem;
    Addsessionpassword1: TMenuItem;
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
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget2: TDropFileTarget;
    GroupManager1: TMenuItem;
    GetUpdates1: TMenuItem;
    HelpTimer: TTimer;
    ImageEditor1: TMenuItem;
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
    GetPhotosFromDrive1: TMenuItem;
    Copywithfolder1: TMenuItem;
    PopupMenu4: TPopupMenu;
    Copy4: TMenuItem;
    Move1: TMenuItem;
    N15: TMenuItem;
    Cancel1: TMenuItem;
    NewPanel1: TMenuItem;
    SelectTimer: TTimer;
    RemovableDrives1: TMenuItem;
    N14: TMenuItem;
    CDROMDrives1: TMenuItem;
    N16: TMenuItem;
    SpecialLocation1: TMenuItem;
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
    Edit1: TComboBoxEx;
    AutoCompliteTimer: TTimer;
    RatingPopupMenu1: TPopupMenu;
    N00: TMenuItem;
    N01: TMenuItem;
    N02: TMenuItem;
    N03: TMenuItem;
    N04: TMenuItem;
    N05: TMenuItem;
    ImageBackGround: TImage;
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
    Image1: TImage;
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
    N20: TMenuItem;
    View3: TMenuItem;
    Thumbnails2: TMenuItem;
    Tile3: TMenuItem;
    Icons2: TMenuItem;
    List2: TMenuItem;
    SmallIcons2: TMenuItem;
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
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
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
    procedure PopupMenu1Popup(Sender: TObject);
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
    function hintrealA(item: TObject): boolean;
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    Procedure SetItemLength(Length : integer; GUID : TGUID);
    Procedure IncItemLength(GUID : TGUID);
    Procedure SetInfoToItem(info : TOneRecordInfo; FileGUID: TGUID);
    Procedure SetInfoTolastItem(info : TOneRecordInfo; GUID : TGUID);
    procedure ListView1DblClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    Procedure BeginUpdate(GUID: TGUID);
    Procedure EndUpdate(GUID: TGUID);
    procedure Open1Click(Sender: TObject);
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    Function ListView1Selected : TEasyItem;
    Function ItemAtPos(X,Y : integer): TEasyItem;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
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
    procedure Edit2Click(Sender: TObject);
    procedure DeleteIndex1Click(Sender: TObject);
    procedure DeleteItemWithIndex(Index : Integer);
    Procedure DeleteFiles(ToRecycle : Boolean);
    Procedure DirectoryChanged(Sender : TObject; SID : TGUID; pInfo: TInfoCallBackDirectoryChangedArray);
    Procedure LoadInfoAboutFiles(Info : TExplorerFilesInfo; SID : TGUID);
    Procedure AddInfoAboutFile(Info : TExplorerFilesInfo; SID : TGUID);
    function FileNeeded(FileSID : TGUID) : Boolean;
    function FileNeededW(FileSID : TGUID) : Boolean;  //��� ������� ����
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
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure ShowProgress(SID : TGUID);
    procedure HideProgress(SID : TGUID);
    procedure SetProgressMax(Value : Integer; SID : TGUID);
    procedure SetProgressPosition(Value : Integer; SID : TGUID);
    procedure SetProgressText(Text : String; SID : TGUID);
    procedure SetStatusText(Text : String; SID : TGUID);
    procedure SetNewFileNameGUID(FileGUID : TGUID; SID : TGUID);
    procedure Button1Click(Sender: TObject);
    Procedure SetPanelInfo(Info : TOneRecordInfo; FileGUID : TGUID);
    Procedure SetPanelImage(Image : TBitmap; FileGUID : TGUID);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint;
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
    procedure Image1DblClick(Sender: TObject);
    procedure Copy3Click(Sender: TObject);
    procedure Cut3Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure DBManager1Click(Sender: TObject);
    procedure DeleteLinkClick(Sender: TObject);
    function AddItemW(Caption : string; FileGUID: TGUID) : TEasyItem;
    procedure SetSelected(NewSelected: TEasyItem);
    procedure PropertiesLinkClick(Sender: TObject);
    procedure SlideShowLinkClick(Sender: TObject);
    procedure Tools1Click(Sender: TObject);
    procedure InfoPanel1Click(Sender: TObject);
    function GetThreadsCount : Integer;
    procedure Paste3Click(Sender: TObject);
    procedure View1Click(Sender: TObject);
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
    function GetVisibleItems : TArStrings;
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
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EasyListview2KeyAction(Sender: TCustomEasyListview;
        var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListview1ItemEdited(Sender: TCustomEasyListview;
        Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure ListView1Resize(Sender : TObject);
    procedure N05Click(Sender: TObject);
    procedure EasyListview1DblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
    procedure EasyListview1ItemThumbnailDraw(
        Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
        ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure EasyListview1ItemSelectionChanged(
        Sender: TCustomEasyListview; Item: TEasyItem);
    procedure ScrollBox1Reallign(Sender: TObject);
    procedure BackGround(Sender: TObject; x, y, w, h: integer;
        var Bitmap: TBitmap);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem;
        const SearchBuffer: WideString; var CompareResult: Integer);

    procedure EasyListview1ItemImageDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
      const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure EasyListview1ItemImageDrawIsCustom(
     Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
     var IsCustom: Boolean);
    procedure EasyListview1ItemImageGetSize(Sender: TCustomEasyListview;
     Item: TEasyItem; Column: TEasyColumn; var ImageWidth,
      ImageHeight: Integer);
    procedure SmallIcons1Click(Sender: TObject);
    procedure Icons1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure Tile2Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure ToolButtonViewClick(Sender: TObject);
    procedure Thumbnails1Click(Sender: TObject);
    procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject);
    function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;
    function GetView : integer;
    procedure MakeFolderViewer2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    function GetAllItems : TExplorerFilesInfo;
    procedure DoDefaultSort(GUID : TGUID);
    procedure DoStopLoading(GUID : TGUID);
    procedure AddHiddenInfo1Click(Sender: TObject);
    procedure ExtractHiddenInfo1Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure MapCD1Click(Sender: TObject);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
   private
     FPictureSize : integer;
     ListView : integer;
     ListView1 : TEasyListView;
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
     fFilesInfo : TExplorerFilesInfo;
     fCurrentPath : String;
     fCurrentTypePath : Integer;
     LockDrawIcon : boolean;

     MouseDowned : Boolean;
     PopupHandled : boolean;
     loadingthitem, shloadingthitem : TEasyItem;
     LastListViewSelected : TEasyItem;
     FListDragItems : array of TEasyItem;

     ItemByMouseDown : Boolean;
     ItemSelectedByMouseDown : Boolean;

     NotSetOldPath : boolean;
     fHistory : TStringsHistoryW;
     FOldPatch : String;
     FOldPatchType : Integer;
     fFilesToDrag : TArStrings;
     fDBCanDrag : Boolean;
     fDBCanDragW : Boolean;
     fDBDragPoint : TPoint;
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
     WasError : boolean;
     DefaultSort : integer;
     DirectoryWatcher : TWachDirectoryClass;
     procedure ReadPlaces;
     procedure UserDefinedPlaceClick(Sender : TObject);
     procedure UserDefinedPlaceContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
     procedure DoSelectItem;
     procedure SendToItemPopUpMenu_(Sender : TObject);
     procedure CorrectPath(Src : array of string; Dest : string);
    { Private declarations }
   protected
     procedure ComboWNDProc(var Message: TMessage);
     procedure CreateParams(VAR Params: TCreateParams); override;
     procedure ZoomIn;
     procedure ZoomOut;
     procedure LoadToolBarGrayedIcons();
     procedure LoadToolBarNormaIcons();
    function IsSelectedVisible: boolean;
   public
     ExtIcons : TBitmapImageList;
     FBitmapImageList : TBitmapImageList;
     WindowID : TGUID;
     CurrentGUID : TGUID;
     NewFileName : String;
     NewFileNameGUID : TGUID;
     TempFolderName : String;
     ComboPath : string;
     NoLockListView : boolean;
     FormLoadEnd : boolean;
     Procedure LoadLanguage;
     function ExitstExtInIcons(Ext : String) : boolean;
     function GetIconByExt(Ext : String) : TIcon;
     procedure AddIconByExt(Ext : String; Icon : TIcon);
     procedure LoadSizes();   
     procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
   end;

  TManagerExplorer = class(TObject)
  private
    FExplorers : TList;
    FForms : TList;
    fShowPrivate: Boolean;
    fShowEXIF: Boolean;
    FShowQuickLinks: Boolean;
    FSync : TCriticalSection;
    procedure SetShowQuickLinks(const Value: Boolean);
    function GetExplorerByIndex(Index: Integer): TExplorerForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewExplorer : TExplorerForm;
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
    property Sync : TCriticalSection read FSync;
  end;

var
  ExplorerManager : TManagerExplorer;

implementation

uses language, ThreadManeger,UnitUpdateDB, ExplorerThreadUnit, Searching,
     SlideShow, PropertyForm, UnitHintCeator, UnitImHint,
     FormManegerUnit, Options, ManagerDBUnit, UnitExplorerThumbnailCreatorThread,
     about, activation, UnitPasswordForm, UnitCryptImageForm,
     UnitFileRenamerForm, UnitImageConverter, UnitSizeResizerForm, ImEditor,
     UnitRotateImages, UnitManageGroups, UnitInternetUpdate, UnitHelp,
     UnitExportImagesForm, UnitGetPhotosForm, UnitFormCont,
     UnitLoadFilesToPanel, DBScriptFunctions, UnitStringPromtForm,
     UnitSavingTableForm, UnitUpdateDBObject, Loadingresults,
     UnitStenoGraphia, UnitBigImagesSize;

{$R *.dfm}

{$R directory_large.res}

function _AutoRename : boolean;
begin
 Result:=not DBKernel.UserRights.FileOperationsCritical;
end;

Function MakeRegPath(Path : String) : String;
var
  i : Integer;
begin
 Result:=Path;
 If Path='' then exit;
 UnFormatDir(Result);
 For i:=1 to Length(Result) do
 begin
  if Result[i]=':' then Result[i]:='_';
  if Result[i]='\' then Result[i]:='_';
 end;
end;

procedure TExplorerForm.CreateParams(VAR Params: TCreateParams);
begin
  FormLoadEnd:=false;
  NoLockListView:=false;
  FPictureSize:=ThImageSize;
  ListView1:=nil;
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
  ExStyle := ExStyle or WS_EX_APPWINDOW;
  FBitmapImageList := TBitmapImageList.Create;
  ExtIcons:= TBitmapImageList.Create;
  fHistory:=TStringsHistoryW.create;
  UpdatingList:=false;
  GlobalLock := false;
  NotSetOldPath := True;
  FIsExplorer:=false;
  FReadingFolderNumber:=0;
  FChangeHistoryOnChPath:=true;
  CopyInstances:=0;
end;

procedure TExplorerForm.ShellTreeView1Change(Sender: TObject;
  Node: TTreeNode);
begin
 if ListView1<>nil then
 SetStringPath(ShellTreeView1.Path,True);
end;

procedure VerifyPaste(Form : TExplorerForm);
var
  Files : TStrings;
  Effects : Integer;
begin
 with Form do
 begin
  Files:=TStringList.Create;
  LoadFIlesFromClipBoard(Effects,Files);
  if Files.Count<>0 then ToolButton7.Enabled:=true else ToolButton7.Enabled:=false;
  Files.free;
  if (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) then
  ToolButton7.Enabled:=false;
  ToolButton7.Visible:=DBKernel.UserRights.FileOperationsNormal;
 end;
end;

procedure TExplorerForm.FormCreate(Sender: TObject);
Var
  NewPath : String;
  NewPathType, i : Integer;
  b : tbitmap;

begin
 DirectoryWatcher := TWachDirectoryClass.Create;
 DefaultSort:=-1;
 FPictureSize:=ThImageSize;
 WasError:=false;
 FWasDragAndDrop:=false;
 LockDrawIcon:=false;
 ListView:=LV_THUMBS;
 ToolButton19.Visible:=DBkernel.UserRights.ShowOptions;
 IsReallignInfo:=false;

 ListView1:=TXListView.Create(self);
 ListView1.Parent:=self;
 ListView1.Align:=AlClient;

     MouseDowned:=false;
     PopupHandled:=false;
     ListView1.BackGround.Enabled:=true;
     ListView1.BackGround.Tile:=false;
     ListView1.BackGround.AlphaBlend:=true;
     ListView1.BackGround.OffsetTrack:=true;
     ListView1.BackGround.BlendAlpha:=220;
     ListView1.BackGround.Image:=TBitmap24.create('TExplorerForm.FormCreate.ListView1.BackGround.Image');
     ListView1.BackGround.Image.PixelFormat:=pf24bit;
     ListView1.BackGround.Image.Width:=150;
     ListView1.BackGround.Image.Height:=150;
     FillColorEx(ListView1.BackGround.Image, Theme_ListColor);

     for i:=1 to 20 do
     begin
      try
       ListView1.BackGround.Image.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
       break;
      except
       Sleep(50);
      end;
     end;              
     ListView1.HotTrack.Color:=Theme_ListFontColor;

     ListView1.Font.Color:=0;
     ListView1.View:=elsThumbnail;
     ListView1.DragKind:=dkDock;
     ListView1.Selection.MouseButton:= [];
     ListView1.Selection.AlphaBlend:=true;
     ListView1.Selection.AlphaBlendSelRect:=true;
     ListView1.Selection.MultiSelect:=true;
     ListView1.Selection.RectSelect:=true;
     ListView1.Selection.EnableDragSelect:=true;
     ListView1.Selection.TextColor:=Theme_ListFontColor;

     LoadSizes;

     ListView1.HotTrack.Cursor:=CrArrow;
     ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
     ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);

     ListView1.IncrementalSearch.Enabled:=true;
     ListView1.IncrementalSearch.ItemType:=eisiInitializedOnly;
     ListView1.OnItemThumbnailDraw:=EasyListview1ItemThumbnailDraw;

     ListView1.OnDblClick:=EasyListview1DblClick;


     ListView1.OnExit:=ListView1Exit;
     ListView1.OnMouseDown:=ListView1MouseDown;
     ListView1.OnMouseUp:=ListView1MouseUp;
     ListView1.OnMouseMove:=ListView1MouseMove;
     ListView1.OnItemSelectionChanged:=EasyListview1ItemSelectionChanged;

     ListView1.OnIncrementalSearch:=Listview1IncrementalSearch;

     ListView1.OnMouseWheel:=ListView1MouseWheel;

     ListView1.OnKeyAction:=EasyListview2KeyAction;
     ListView1.OnItemEdited:=self.EasyListview1ItemEdited;
     ListView1.OnResize:=ListView1Resize;
     ListView1.OnItemImageDraw:=EasyListview1ItemImageDraw;
     ListView1.OnItemImageDrawIsCustom:=EasyListview1ItemImageDrawIsCustom;
     ListView1.OnItemImageGetSize:=EasyListview1ItemImageGetSize;
     ListView1.Header.Columns.Add;

     ListView1.Groups.Add;

             
 ConvertTo32BitImageList(DragImageList);
 
 Activation1.Visible:=not FolderView;
 Help2.Visible:=not FolderView;
  
 WindowID:=GetGUID;
 SetLength(RefreshIDList,0);
 if not DBkernel.UserRights.ShowPath then
 begin
//?  CoolBar1.Bands[1].Visible:=false;
  CoolBar1.Bands[0].Visible:=false;
  CoolBar1.Realign;
  CoolBar1.Height:=CoolBar1.Bands[0].Height+2;
  ToolButton3.Enabled:=false;
 end;
 if not DBkernel.UserRights.ShowPath then
 if not DBkernel.UserRights.ShowPrivate then
 View1.Visible:=false;
 Edit1.Enabled:=DBkernel.UserRights.ShowPath;
 ToolBar2.Visible:=DBkernel.UserRights.ShowPath;
 SetLength(UserLinks,0);
 SetLength(FPlaces,0);
 DragFilesPopup:=TStringList.Create;
 if not DBkernel.UserRights.FileOperationsCritical then
 DropFileSource1.Dragtypes:=[dtCopy,dtLink];
 if not DBkernel.UserRights.FileOperationsNormal then
 DropFileSource1.Dragtypes:=[];
 GetPhotosFromDrive1.Visible:=DBKernel.UserRights.FileOperationsNormal and not FolderView;
 SelfDraging:=false;
// ToolBar2.ButtonHeight:=19;
 FDblClicked:=false;
 FIsExplorer:=false;
 SetLength(FListDragItems,0);
 fDBCanDragW:=false;
 image1.Picture.Bitmap:=nil;
 DropFileTarget2.Register(Self);
 DropFileTarget1.Register(ListView1);

 ListView1.HotTrack.Enabled:=DBKernel.Readbool('Options','UseHotSelect',true);
 FormManager.RegisterMainForm(Self);
 fStatusProgress:=CreateProgressBar(StatusBar1,1);
 fStatusProgress.Visible:=false;
 EndUpdate(CurrentGUID);
 fHistory.OnHistoryChange:=HistoryChanged;
 ToolButton1.Enabled:=false;
 ToolButton2.Enabled:=false;
 DBKernel.RegisterProcUpdateTheme(UpdateTheme,self);
 DBKernel.RegisterChangesID(Sender,ChangedDBDataByID);

 CurrentGUID:=GetGUID;
 MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidth',135);
 NewPath:=DBkernel.ReadString('Explorer','Patch');
 NewPathType:=DBkernel.ReadInteger('Explorer','PatchType',EXPLORER_ITEM_MYCOMPUTER);
 DBkernel.WriteString('Explorer','Patch','');
 DBkernel.WriteInteger('Explorer','PatchType',EXPLORER_ITEM_MYCOMPUTER);
 SetNewPathW(ExplorerPath(NewPath,NewPathType),True);
 DBkernel.WriteString('Explorer','Patch',NewPath);
 DBkernel.WriteInteger('Explorer','PatchType',NewPathType);
 fHistory.Clear;

 Lock:=false;
 FWndOrigin := Edit1.WindowProc;
 Edit1.WindowProc := ComboWNDProc;
 SlashHandled:=false;

 InitializeScript(aScript);
 LoadBaseFunctions(aScript);
 LoadDBFunctions(aScript);
 AddAccessVariables(aScript);
 if DBKernel.UserRights.FileOperationsCritical then
 LoadFileFunctions(aScript);
 AddScriptObjFunction(aScript,'CloseWindow',F_TYPE_OBJ_PROCEDURE_TOBJECT,CloseWindow);

 AddScriptObjFunction(aScript,'SelectAll',F_TYPE_OBJ_PROCEDURE_TOBJECT,SelectAll1Click);
 AddScriptObjFunction(aScript,'GoUp',F_TYPE_OBJ_PROCEDURE_TOBJECT,Up1Click);
 AddScriptObjFunction(aScript,'GoBack',F_TYPE_OBJ_PROCEDURE_TOBJECT,Back1Click);
 AddScriptObjFunction(aScript,'GoForward',F_TYPE_OBJ_PROCEDURE_TOBJECT,Forward1Click);

 AddScriptObjFunction(aScript,'Copy',F_TYPE_OBJ_PROCEDURE_TOBJECT,Copy3Click);
 AddScriptObjFunction(aScript,'Paste',F_TYPE_OBJ_PROCEDURE_TOBJECT,Paste3Click);
 AddScriptObjFunction(aScript,'Cut',F_TYPE_OBJ_PROCEDURE_TOBJECT,Cut3Click);
 AddScriptObjFunction(aScript,'GoToExplorerMode',F_TYPE_OBJ_PROCEDURE_TOBJECT,ExplorerPanel1Click);
 AddScriptObjFunction(aScript,'CancelExplorerMode',F_TYPE_OBJ_PROCEDURE_TOBJECT,InfoPanel1Click);
 AddScriptObjFunction(aScript,'ShowPrivate',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowPrivate1Click);
 AddScriptObjFunction(aScript,'HidePrivate',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowOnlyCommon1Click);

 AddScriptObjFunction(aScript,'SetThumbnailsView',F_TYPE_OBJ_PROCEDURE_TOBJECT,Thumbnails1Click);
 AddScriptObjFunction(aScript,'SetTilesView',F_TYPE_OBJ_PROCEDURE_TOBJECT,Tile2Click);
 AddScriptObjFunction(aScript,'SetIconsView',F_TYPE_OBJ_PROCEDURE_TOBJECT,Icons1Click);
 AddScriptObjFunction(aScript,'SetListView',F_TYPE_OBJ_PROCEDURE_TOBJECT,List1Click);
 AddScriptObjFunction(aScript,'SetList2View',F_TYPE_OBJ_PROCEDURE_TOBJECT,SmallIcons1Click);


 AddScriptObjFunctionIsString(aScript,'GetPath',GetPath);
 AddScriptObjFunctionIsBool(aScript,'CanBack',fHistory.CanBack);
 AddScriptObjFunctionIsBool(aScript,'CanForward',fHistory.CanForward);
 AddScriptObjFunctionIsBool(aScript,'CanUp',CanUp);
 AddScriptObjFunctionIsInteger(aScript,'SelCount',SelCount);
 AddScriptObjFunctionIsInteger(aScript,'SelectedIndex',SelectedIndex);
 AddScriptObjFunctionIsInteger(aScript,'GetSelectedType',GetSelectedType);
 AddScriptObjFunctionIsInteger(aScript,'CanCopySelection',GetSelectedType);
 AddScriptObjFunctionIsBool(aScript,'CanCopySelection',CanCopySelection);
 AddScriptObjFunctionIsArrayStrings(aScript,'GetSelectedFiles',GetSelectedFiles);
 AddScriptObjFunctionIsBool(aScript,'CanPasteInSelection',CanPasteInSelection);
 AddScriptObjFunctionIsBool(aScript,'ExplorerType',ExplorerType);
 AddScriptObjFunctionIsBool(aScript,'ShowPrivateNow',ShowPrivate);
 AddScriptObjFunctionIntegerIsString(aScript,'GetPathByIndex',GetPathByIndex);

 AddScriptObjFunctionIsInteger(aScript,'GetView',GetView);

// if false then
 if UseScripts and not SafeMode then
 begin
  SetNamedValueStr(aScript,'$dbname',dbname);
  MainMenuScript:=ReadScriptFile('scripts\ExplorerMainMenu.dbini');
  Menu:=nil;
  LoadMenuFromScript(ScriptMainMenu.Items,DBkernel.ImageList,MainMenuScript,aScript,ScriptExecuted,FExtImagesInImageList,true);
  Menu:=ScriptMainMenu;
  ScriptMainMenu.Images:=DBkernel.ImageList;
 end;

 ReadPlaces;

 PopUpMenu1.Images:=DBKernel.ImageList;
 PopUpMenu2.Images:=DBKernel.ImageList;
 MainMenu1.Images:=DBKernel.ImageList;
 PopupMenu3.Images:=DBKernel.ImageList;
 Shell1.ImageIndex:=DB_IC_SHELL;
 SlideShow1.ImageIndex:=DB_IC_SLIDE_SHOW;
 DBitem1.ImageIndex:=DB_IC_NOTES;
 Copy1.ImageIndex:=DB_IC_COPY;
 Delete1.ImageIndex:=DB_IC_DELETE_FILE;
 Rename1.ImageIndex:=DB_IC_RENAME;
 Properties1.ImageIndex:=DB_IC_PROPERTIES;
 AddFile1.ImageIndex:=DB_IC_NEW;
 Open1.ImageIndex:=DB_IC_EXPLORER;
 Open2.ImageIndex:=DB_IC_EXPLORER;
 SelectAll1.ImageIndex:=DB_IC_SELECTALL;
 SelectAll2.ImageIndex:=DB_IC_SELECTALL;
 Copy2.ImageIndex:=DB_IC_COPY;
 Copy3.ImageIndex:=DB_IC_COPY;
 Cut1.ImageIndex:=DB_IC_CUT;
 Cut2.ImageIndex:=DB_IC_CUT;
 Cut3.ImageIndex:=DB_IC_CUT;
 Paste1.ImageIndex:=DB_IC_PASTE;
 Paste2.ImageIndex:=DB_IC_PASTE;
 Paste3.ImageIndex:=DB_IC_PASTE;
 DBManager1.ImageIndex:=DB_IC_ADMINTOOLS;
 Searching1.ImageIndex:=DB_IC_ADDTODB;
 Options1.ImageIndex:=DB_IC_OPTIONS;
 New1.ImageIndex:=DB_IC_NEW_SHELL;
 Directory1.ImageIndex:=DB_IC_NEW_DIRECTORY;
 Refresh1.ImageIndex:=DB_IC_REFRESH_THUM;
 Back1.ImageIndex:=DB_IC_SHELL_PREVIOUS;
 Forward1.ImageIndex:=DB_IC_SHELL_NEXT;
 Up1.ImageIndex:=DB_IC_SHELL_UP;
 Addfolder1.ImageIndex:=DB_IC_ADD_FOLDER;
 MakeNew1.ImageIndex:=DB_IC_NEW_SHELL;
 Refresh2.ImageIndex:=DB_IC_REFRESH_THUM;
 Exit1.ImageIndex:=DB_IC_EXIT;
 Exit2.ImageIndex:=DB_IC_EXIT;
 TextFile1.ImageIndex:=DB_IC_TEXT_FILE;
 ShowUpdater1.ImageIndex:=DB_IC_BOX;
 NewPanel1.ImageIndex:=DB_IC_PANEL;
 ShowUpdater2.ImageIndex:=DB_IC_BOX;
 OpenInNewWindow1.ImageIndex:=DB_IC_FOLDER;
 OpeninNewWindow2.ImageIndex:=DB_IC_FOLDER;
 NewWindow1.ImageIndex:=DB_IC_FOLDER;
 GoToSearchWindow1.ImageIndex:=DB_IC_ADDTODB;
 OpeninSearchWindow1.ImageIndex:=DB_IC_ADDTODB;
 ShowOnlyCommon1.ImageIndex:=DB_IC_COMMON;
 ShowPrivate1.ImageIndex:=DB_IC_PRIVATE;
 ExplorerPanel1.ImageIndex:=DB_IC_EXPLORER_PANEL;
 InfoPanel1.ImageIndex:=DB_IC_INFO_PANEL;
 PopupMenu8.Images:=DBKernel.ImageList;
 OpeninExplorer1.ImageIndex:=DB_IC_EXPLORER;
 AddFolder2.ImageIndex:=DB_IC_ADD_FOLDER;
 Help2.ImageIndex:=DB_IC_HELP;
 Activation1.ImageIndex:=DB_IC_NOTES;
 About1.ImageIndex:=DB_IC_HELP;
 HomePage1.ImageIndex:=DB_IC_NETWORK;
 ContactWithAuthor1.ImageIndex:=DB_IC_E_MAIL;
 CryptFile1.ImageIndex:=DB_IC_CRYPTIMAGE;
 ResetPassword1.ImageIndex:=DB_IC_DECRYPTIMAGE;
 EnterPassword1.ImageIndex:=DB_IC_PASSWORD;
 Convert1.ImageIndex:=DB_IC_CONVERT;
 Resize1.ImageIndex:=DB_IC_RESIZE;
 Directory2.ImageIndex:= DB_IC_NEW_DIRECTORY;
 TextFile2.ImageIndex:= DB_IC_TEXT_FILE;
 GroupManager1.ImageIndex:=DB_IC_GROUPS;
 RotateCCW1.ImageIndex:=DB_IC_ROTETED_270;
 RotateCW1.ImageIndex:=DB_IC_ROTETED_90;
 Rotateon1801.ImageIndex:=DB_IC_ROTETED_180;
 Rotate1.ImageIndex:=DB_IC_ROTETED_0;
 GetUpdates1.ImageIndex:=DB_IC_UPDATING;
 SetasDesktopWallpaper1.ImageIndex:=DB_IC_WALLPAPER;
 Stretch1.ImageIndex:=DB_IC_WALLPAPER;
 Center1.ImageIndex:=DB_IC_WALLPAPER;
 Tile1.ImageIndex:=DB_IC_WALLPAPER;
 RefreshID1.ImageIndex:=DB_IC_REFRESH_ID;
 Othertasks1.ImageIndex:=DB_IC_OTHER_TOOLS;
 ExportImages1.ImageIndex:=DB_IC_EXPORT_IMAGES;
 ImageEditor1.ImageIndex:=DB_IC_IMEDITOR;
 ImageEditor2.ImageIndex:=DB_IC_IMEDITOR;
 Print1.ImageIndex:=DB_IC_PRINTER;
 Copywithfolder1.ImageIndex:=DB_IC_COPY;

 RemovableDrives1.ImageIndex:=DB_IC_USB;
 CDROMDrives1.ImageIndex:=DB_IC_CD_ROM;
 SpecialLocation1.ImageIndex:=DB_IC_DIRECTORY;
 SendTo1.ImageIndex:=DB_IC_SEND;
 View2.ImageIndex:=DB_IC_SLIDE_SHOW;

 Sortby1.ImageIndex:=DB_IC_SORT;
 SetFilter1.ImageIndex:=DB_IC_FILTER;

 Nosorting1.ImageIndex:=DB_IC_DELETE_INFO;
 FileName1.ImageIndex:=DB_IC_PROPERTIES;
 Rating1.ImageIndex:=DB_IC_RATING_STAR;
 Size1.ImageIndex:=DB_IC_RESIZE;
 Type1.ImageIndex:=DB_IC_ATYPE;
 Modified1.ImageIndex:=DB_IC_CLOCK;
 MakeFolderViewer1.ImageIndex:=DB_IC_SAVE_AS_TABLE; 
 MakeFolderViewer2.ImageIndex:=DB_IC_SAVE_AS_TABLE;
 Number1.ImageIndex:=DB_IC_RENAME;
                                   
 RatingPopupMenu1.Images:=DBkernel.ImageList;

 N00.ImageIndex:=DB_IC_DELETE_INFO;
 N01.ImageIndex:=DB_IC_RATING_1;
 N02.ImageIndex:=DB_IC_RATING_2;
 N03.ImageIndex:=DB_IC_RATING_3;
 N04.ImageIndex:=DB_IC_RATING_4;
 N05.ImageIndex:=DB_IC_RATING_5;

 StenoGraphia1.ImageIndex:=DB_IC_STENO;
 AddHiddenInfo1.ImageIndex:=DB_IC_STENO;
 ExtractHiddenInfo1.ImageIndex:=DB_IC_DESTENO;
 
 View3.ImageIndex:=DB_IC_SORT;
 MapCD1.ImageIndex:=DB_IC_CD_MAPPING;

 SlideShowLink.Icon:=(UnitDBKernel.icons[DB_IC_SLIDE_SHOW+1]);
 ShellLink.Icon:=(UnitDBKernel.icons[DB_IC_SHELL+1]);
 CopyToLink.Icon:=(UnitDBKernel.icons[DB_IC_COPY+1]);
 MoveToLink.Icon:=(UnitDBKernel.icons[DB_IC_CUT+1]);
 RenameLink.Icon:=(UnitDBKernel.icons[DB_IC_RENAME+1]);
 PropertiesLink.Icon:=(UnitDBKernel.icons[DB_IC_PROPERTIES+1]);
 DeleteLink.Icon:=(UnitDBKernel.icons[DB_IC_DELETE_INFO+1]);
 AddLink.Icon:=(UnitDBKernel.icons[DB_IC_NEW+1]);
 RefreshLink.Icon:=(UnitDBKernel.icons[DB_IC_REFRESH_THUM+1]);
 ImageEditorLink.Icon:=(UnitDBKernel.icons[DB_IC_IMEDITOR+1]);
 PrintLink.Icon:=(UnitDBKernel.icons[DB_IC_PRINTER+1]);
 MyPicturesLink.Icon:=(UnitDBKernel.icons[DB_IC_MY_PICTURES+1]);
 MyDocumentsLink.Icon:=(UnitDBKernel.icons[DB_IC_MY_DOCUMENTS+1]);
 MyComputerLink.Icon:=(UnitDBKernel.icons[DB_IC_MY_COMPUTER+1]);
 DesktopLink.Icon:=(UnitDBKernel.icons[DB_IC_DESKTOPLINK+1]);

 for i:=0 to ComponentCount-1 do
 if Components[i] is TWebLink then
 (Components[i] as TWebLink).GetBackGround:=BackGround;


 for i:=0 to Length(UserLinks)-1 do
 UserLinks[i].GetBackGround:=BackGround;

 DBKernel.RecreateThemeToForm(Self);

 b:=TBitmap24.Create('TExplorerForm.FormCreate.b');
 b.PixelFormat:=pf24bit;
 b.Width:=120;
 b.Height:=150;
 b.Canvas.Brush.Color:=ScrollBox1.Color;
 b.Canvas.Pen.Color:=ScrollBox1.Color;
 b.Canvas.Rectangle(0,0,120,150);
 b.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
 ScrollBox1.BackGround.Canvas.Brush.Color:=ScrollBox1.Color;
 ScrollBox1.BackGround.Canvas.Pen.Color:=ScrollBox1.Color;
 ScrollBox1.BackGround.Width:=120;
 ScrollBox1.BackGround.Height:=150;
 DrawTransparent(b,ScrollBox1.BackGround,40);
 b.free;

 Button1Click(Sender);
 try
  DoSelectItem;
 except
  on e : Exception do EventLog(':TExplorerForm::FormCreate() throw exception: '+e.Message);
 end;
 ExplorerManager.AddExplorer(Self);
 LoadLanguage;
 DBKernel.RegisterForm(Self);
 MainPanel.DoubleBuffered:=true;
 PropertyPanel.DoubleBuffered:=true;
 ListView1.DoubleBuffered:=true;
 ScrollBox1.DoubleBuffered:=true;

 LoadToolBarNormaIcons;
 LoadToolBarGrayedIcons;
 ToolBar1.Images := ToolBarNormalImageList;
 ToolBar1.DisabledImages := ToolBarDisabledImageList;
 ToolBar2.ButtonHeight:=22;
 ToolButton18.Enabled:=false;
 SaveWindowPos1.Key:=RegRoot+'Explorer\'+MakeRegPath(GetCurrentPath);
 SaveWindowPos1.SetPosition;
 FormLoadEnd:=true;
end;

procedure TExplorerForm.ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject);
var
  PositionIndex: Integer;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;
      PositionIndex := 0;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);
      try
        RectArray.BoundsRect := Item.DisplayRect;
        if ListView=0 then
        InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.IconRect := RectArray.BoundsRect;
        RectArray.IconRect.Bottom := RectArray.IconRect.Bottom - tmHeight * 2;

        // Calculate area that the Checkbox may be drawn
          RectArray.CheckRect.Top := RectArray.IconRect.Bottom;
          RectArray.CheckRect.Left := RectArray.BoundsRect.Left;
          RectArray.CheckRect.Bottom := RectArray.BoundsRect.Bottom;
          RectArray.CheckRect.Right := RectArray.CheckRect.Left;

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.LabelRect.Left := RectArray.CheckRect.Right + Item.CaptionIndent;
        RectArray.LabelRect.Top := RectArray.IconRect.Bottom + 1;
        RectArray.LabelRect.Right := RectArray.BoundsRect.Right;
        RectArray.LabelRect.Bottom := RectArray.BoundsRect.Bottom;

        // Calcuate the Text rectangle based on the current text
        // **********
        RectArray.TextRect := RectArray.LabelRect;
        // Leave room for a small border between edge of the selection rect and text
        if ListView=0 then
        InflateRect(RectArray.TextRect, -2, -2);

      finally
      end;
    end
  end
end;

function TExplorerForm.ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;
var
  i: Integer;
  r : TRect;
  RectArray: TEasyRectArrayObject;
  aCanvas : TCanvas;
  Metrics: TTextMetric;
begin
  Result := nil;
  i := 0;
  r :=  EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X:=ViewportPoint.X+r.Left;
  ViewportPoint.Y:=ViewportPoint.Y+r.Top;
  aCanvas:=EasyListview.Canvas;    
  GetTextMetrics(aCanvas.Handle, Metrics);

  while not Assigned(Result) and (i < EasyListview.Items.Count) do
  begin
    begin
     ItemRectArray(EasyListview.Items[i],Metrics.tmHeight,RectArray);

     if ListView=0 then
     begin
      if PtInRect(RectArray.IconRect, ViewportPoint) then
       Result := EasyListview.Items[i] else
      if PtInRect(RectArray.TextRect, ViewportPoint) then
       Result := EasyListview.Items[i];
    end else
      if PtInRect(RectArray.BoundsRect, ViewportPoint) then
       Result := EasyListview.Items[i];
    end;
    Inc(i)
  end
end;


procedure TExplorerForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item: TEasyItem;
  FileNames : TArStrings;
  i, index : Integer;
  r : TRect;
  VitrualKey : boolean;
begin
 if CopyFilesSynchCount>0 then WindowsMenuTickCount:=GetTickCount;
 rdown:=false;
 FDblClicked:=false;
 HintTimer.Enabled:=false;
 fDBCanDrag:=false;

 Item:=ItemByPointImage(ListView1, Point(MousePos.x,MousePos.y));
 VitrualKey:=((MousePos.x=-1) and (MousePos.y=-1));
 if (Item=nil) or VitrualKey then Item:=ListView1.Selection.First;

 r :=  Listview1.Scrollbars.ViewableViewportRect;
 if (Item<>nil) and (Item.SelectionHitPt(Point(MousePos.x+r.Left,MousePos.y+r.Top), eshtClickSelect) or VitrualKey) then
 begin
  Loadingthitem:= nil;
  Application.HideHint;
  if ImHint<>nil then
  ImHint.Close;
  if Item.Index>Length(fFilesInfo)-1 then exit;
  If (fFilesInfo[Item.Index].Access=db_access_private) and not DBKernel.UserRights.ShowPrivate then exit;
  SetForegroundWindow(Self.Handle);
  SetLength(fFilesToDrag,0);
  fpopupdown:=true;
  if not ((GetTickCount-WindowsMenuTickCount>WindowsMenuTime) and (DBkernel.UserRights.FileOperationsCritical)) then
  begin
   popupmenu1.Tag:=ItemIndexToMenuIndex(Item.Index);
   popupmenu1.Popup(ListView1.clienttoscreen(MousePos).X ,ListView1.clienttoscreen(MousePos).y);
  end else
  begin
   Screen.Cursor:=CrDefault;
   if ListView1Selected<>nil then
   begin
    SetLength(FileNames,0);
    for i:=0 to ListView1.Items.Count-1 do
    If ListView1.Items[i].Selected then
    begin
     index:=ItemIndexToMenuIndex(i);
     SetLength(FileNames,Length(FileNames)+1);
     FileNames[Length(FileNames)-1]:=fFilesInfo[index].FileName;
    end;
    GetProperties(FileNames,MousePos,ListView1);
   end;
  end;
 end else begin
  popupmenu2.Popup(ListView1.clienttoscreen(MousePos).X ,ListView1.clienttoscreen(MousePos).y);
 end;
end;

procedure TExplorerForm.SlideShow1Click(Sender: TObject);
var
  filename : string;
  info: TRecordsInfo;
  MenuInfo: TDBPopupMenuInfo;
begin
 filename:=fFilesInfo[popupmenu1.tag].FileName;
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin
  MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
  If Viewer=nil then
  Application.CreateForm(TViewer, Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.Execute(Sender,info);
 end;
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_FOLDER then
 Viewer.ShowFolderA(fFilesInfo[popupmenu1.tag].FileName,ExplorerManager.ShowPrivate);
end;

procedure TExplorerForm.Shell1Click(Sender: TObject);
begin
 ShellExecute(0, Nil,PChar(ProcessPath(fFilesInfo[popupmenu1.tag].FileName)), Nil, Nil, SW_NORMAL);
end;

procedure TExplorerForm.Properties1Click(Sender: TObject);
var
  info : TDBPopupMenuInfo;
  i, index : integer;
  ArInt : TArInteger;
  Files : TArStrings;
  WindowsProperty : Boolean;
begin
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin
  if SelCount>1 then
  begin
   info:=GetCurrentPopUpMenuInfo(nil);
   SetLength(ArInt,0);
   WindowsProperty:=true;
   For i:=0 to length(info.ItemIDs_)-1 do
   if info.ItemSelected_[i] then
   begin
    SetLength(ArInt,Length(ArInt)+1);
    ArInt[Length(ArInt)-1]:=info.ItemIDs_[i];
    if info.ItemIDs_[i]<>0 then WindowsProperty:=false;
   end;
   if not WindowsProperty then
   PropertyManager.NewSimpleProperty.ExecuteEx(ArInt) else
   begin
    SetLength(Files,0);
    for i:=0 to ListView1.Items.Count-1 do
    If ListView1.Items[i].Selected then
    begin
     index:=ItemIndexToMenuIndex(i);
     SetLength(Files,Length(Files)+1);
     Files[Length(Files)-1]:=fFilesInfo[index].FileName;
    end;
    GetPropertiesWindows(Files,ListView1);
   end;
  end else
  begin
  if not fFilesInfo[popupmenu1.tag].Loaded then
  fFilesInfo[popupmenu1.tag].ID:=Dolphin_DB.GetIdByFileName(fFilesInfo[popupmenu1.tag].FileName);
  If fFilesInfo[popupmenu1.tag].ID=0 then
  PropertyManager.NewFileProperty(fFilesInfo[popupmenu1.tag].FileName).ExecuteFileNoEx(fFilesInfo[popupmenu1.tag].FileName) else
  PropertyManager.NewIDProperty(fFilesInfo[popupmenu1.tag].ID).Execute(fFilesInfo[popupmenu1.tag].ID);
  end;
 end else
 begin
  SetLength(Files,0);
  for i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   SetLength(Files,Length(Files)+1);
   Files[Length(Files)-1]:=fFilesInfo[index].FileName;
  end;
  GetPropertiesWindows(Files,ListView1);
 end;
end;

procedure TExplorerForm.PopupMenu1Popup(Sender: TObject);
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
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_DRIVE then
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
  If not DBkernel.UserRights.Add then AddFile1.Visible:=false;
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
  Paste2.Visible:=DBkernel.UserRights.FileOperationsNormal;
  Shell1.Visible:=DBkernel.UserRights.Execute;
 end;
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_FOLDER then
 begin         
  DBitem1.Visible:=false;
  MakeFolderViewer2.Visible:=not FolderView and DBkernel.UserRights.FileOperationsCritical;
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
  Properties1.Visible:=DBKernel.UserRights.ShowPrivate;
  Paste2.Visible:=DBkernel.UserRights.FileOperationsNormal;
  Open1.Visible:=true;
  Delete1.Visible:=DBkernel.UserRights.FileOperationsCritical;
  Rename1.Visible:=DBkernel.UserRights.FileOperationsCritical;
  SlideShow1.Visible:=True;
  Files:=TStringList.Create;
  LoadFIlesFromClipBoard(Effects,Files);
  if Files.Count<>0 then Paste2.Enabled:=true else Paste2.Enabled:=false;
  Files.free;

  b:=CanCopySelection;
  Cut2.Visible:=DBkernel.UserRights.FileOperationsCritical and b;
  Copy1.Visible:=DBkernel.UserRights.FileOperationsNormal and b;
  Paste2.Visible:=DBkernel.UserRights.FileOperationsNormal;
  Shell1.Visible:=DBkernel.UserRights.Execute;
 end;
 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin   
  DBitem1.Visible:=true;            
  StenoGraphia1.Visible:=true;
  AddHiddenInfo1.Visible:= DBKernel.UserRights.FileOperationsCritical and (SelCount=1);
  ExtractHiddenInfo1.Visible:=DBKernel.UserRights.FileOperationsCritical;
  ExtractHiddenInfo1.Visible:=ExtractHiddenInfo1.Visible and ExtInMask('|PNG|BMP|',GetExt(fFilesInfo[popupmenu1.tag].FileName));

  MakeFolderViewer2.Visible:=not FolderView and DBkernel.UserRights.FileOperationsCritical;
  Print1.Visible:=DBkernel.UserRights.Print;
  Othertasks1.Visible:=DBKernel.UserRights.FileOperationsNormal;
  ImageEditor2.Visible:=DBKernel.UserRights.EditImage;
  CryptFile1.Visible:=not ValidCryptGraphicFile(fFilesInfo[popupmenu1.tag].FileName);
  ResetPassword1.Visible:=not CryptFile1.Visible;
  EnterPassword1.Visible:=not CryptFile1.Visible and (DBkernel.FindPasswordForCryptImageFile(fFilesInfo[popupmenu1.tag].FileName)='') ;
  if not DBkernel.UserRights.Crypt then
  begin
   ResetPassword1.Visible:=false;
   EnterPassword1.Visible:=false;
   CryptFile1.Visible:=false;
  end;
  Convert1.Visible:=not EnterPassword1.Visible and DBkernel.UserRights.FileOperationsNormal;
  Resize1.Visible:=not EnterPassword1.Visible and DBkernel.UserRights.FileOperationsNormal;
  Rotate1.Visible:=not EnterPassword1.Visible and DBkernel.UserRights.FileOperationsNormal;
  RefreshID1.Visible:=(not EnterPassword1.Visible) and (fFilesInfo[popupmenu1.tag].ID<>0);
  SetasDesktopWallpaper1.Visible:=CryptFile1.Visible and DBkernel.UserRights.FileOperationsCritical and IsWallpaper(fFilesInfo[popupmenu1.tag].FileName);
  Refresh1.Visible:=True;
  Open1.Visible:=false;
  Shell1.Visible:=DBkernel.UserRights.Execute;
  Rename1.Visible:=DBkernel.UserRights.FileOperationsCritical;
  NewWindow1.Visible:=false;
  Properties1.Visible:=true;
  SlideShow1.Visible:=True;
  Delete1.Visible:=DBkernel.UserRights.FileOperationsCritical;;
  AddFile1.Caption:=TEXT_MES_ADDFILE;
  if fFilesInfo[popupmenu1.tag].ID=0 then
  AddFile1.Visible:=true else AddFile1.Visible:=false;
  If not DBkernel.UserRights.Add then AddFile1.Visible:=false;
  Cut2.Visible:=DBkernel.UserRights.FileOperationsCritical;
  Copy1.Visible:=DBkernel.UserRights.FileOperationsNormal;
  Paste2.Visible:=false;
 end;
 If (fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_EXEFILE) then
 begin
  if AnsiLowerCase(ExtractFileName(fFilesInfo[popupmenu1.tag].FileName))=AnsiLowerCase(TEXT_MES_CD_MAP_FILE) then
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
  Delete1.Visible:=DBkernel.UserRights.FileOperationsCritical;
  Rename1.Visible:=DBkernel.UserRights.FileOperationsCritical;
  AddFile1.Visible:=false;
  Cut2.Visible:=DBkernel.UserRights.FileOperationsCritical;
  Copy1.Visible:=DBkernel.UserRights.FileOperationsNormal;
  Paste2.Visible:=false;
  Shell1.Visible:=DBkernel.UserRights.Execute;
 end;

 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_NETWORK then
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

 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_WORKGROUP then
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

 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_COMPUTER then
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

 If fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_SHARE then
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

 Item:=ItemAtPos(ListView1.ScreenToClient(Point).X,ListView1.ScreenToClient(Point).y);
 if PopupMenu1.tag<0 then exit;
 For i:=DBitem1.MenuIndex+1 to N8.MenuIndex-1 do
 PopupMenu1.Items.Delete(DBitem1.MenuIndex+1);

 if DBitem1.Visible then
  begin
  info:=GetCurrentPopUpMenuInfo(Item);
  If item<>nil then
  begin
   info.IsListItem:=True;
   info.ListItem:=Item;
  end;
  info.IsDateGroup:=True;
  info.IsAttrExists:=false;
  DBPopupMenu.AddDBContMenu(DBItem1,info);
 end;

 If fFilesInfo[popupmenu1.tag].ID=0 then
 begin
//  DBitem1.Visible:=false;
  if fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_IMAGE then
  SendTo1.Visible:=true;
  if DBKernel.ReadBool('Options','UseUserMenuForExplorer',true) then
  if DBKernel.UserRights.FileOperationsCritical then
  if fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_IMAGE then
  begin
   info:=GetCurrentPopUpMenuInfo(Item);
   DBPopupMenu.SetInfo(info);
   DBPopupMenu.AddUserMenu(PopupMenu1.Items,true,DBitem1.MenuIndex+1);
  end;
 end;// else begin
// end;
end;

procedure TExplorerForm.Copy1Click(Sender: TObject);
Var
  i, index : integer;
  File_List : TStrings;
begin
 File_List:=TStringList.Create;
 For i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  if not (DBkernel.UserRights.FileOperationsCritical and (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER)) or DBkernel.UserRights.FileOperationsCritical then
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
  ListView1.SetFocus;

  ListView1.EditManager.Enabled:=true;
  ListView1.Selection.First.Edit;

 end;
 if SelCount>1 then
 begin
  Files := TStringList.Create;
  For i:=0 to ListView1.Items.Count-1 do
  begin
   if ListView1.Items[i].Selected then
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
 For i:=0 to ListView1.Items.Count-1 do
 if ListView1.Items[i].Selected then
 begin
  Index := ItemIndexToMenuIndex(i);
  SetLength(S,Length(S)+1);
  S[Length(S)-1]:=fFilesInfo[Index].FileName
 end;
 Dolphin_db.DeleteFiles( Self.Handle, S , ToRecycle );
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
  For i:=0 to ListView1.Items.Count-1 do
  begin
  
  if i>ListView1.Items.Count-1 then exit;
  if ListView1.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if index>Length(fFilesInfo)-1 then exit;
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
  b : TBitmap;
begin
 try
  ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
  ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);
  ListView1SelectItem(Sender,ListView1Selected,ListView1Selected=nil);
  for i:=0 to Length(UserLinks)-1 do
  begin
   UserLinks[i].BkColor:=Theme_MainColor;
   UserLinks[i].Font.Color:=Theme_MainFontColor;
   UserLinks[i].Refresh;
  end;

  b:=TBitmap.Create;
  try
    b.PixelFormat:=pf24bit;
    b.Width:=120;
    b.Height:=150;
    b.Canvas.Brush.Color:=ScrollBox1.Color;
    b.Canvas.Pen.Color:=ScrollBox1.Color;
    b.Canvas.Rectangle(0,0,120,150);
    b.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
    ScrollBox1.BackGround.Width:=120;
    ScrollBox1.BackGround.Height:=150;
    FillColorEx(ScrollBox1.BackGround, ScrollBox1.Color);
    DrawTransparent(b,ScrollBox1.BackGround,40);
  finally
    b.free;
  end;

  if ListView1<>nil then
  begin
   if ListView1.BackGround.Image<>nil then
   ListView1.BackGround.Image:=nil;
   b:=TBitmap.create;
   b.PixelFormat:=pf24bit;
   b.Width:=150;
   b.Height:=150;
   b.Canvas.Brush.Color:=ListView1.Color;
   b.Canvas.Pen.Color:=ListView1.Color;
   b.Canvas.Rectangle(0,0,150,150);
   b.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
   ListView1.BackGround.Image:=b;
   b.Free;
  end;
 except
 end;
end;

procedure TExplorerForm.FormDestroy(Sender: TObject);
begin
 DirectoryWatcher.StopWatch;
 DirectoryWatcher.Free;
 FinalizeScript(aScript);
 DragFilesPopup.Free;
 FBitmapImageList.Free;
 ExtIcons.Free;
 CurrentGUID:=GetGUID;
 SaveWindowPos1.SavePosition;
 DropFileTarget2.Unregister;
 DropFileTarget1.Unregister;
 DBKernel.UnRegisterChangesID(Sender,ChangedDBDataByID);
 DBKernel.UnRegisterProcUpdateTheme(UpdateTheme,self);

 DBkernel.WriteInteger('Explorer','LeftPanelWidth',MainPanel.Width);

 DBkernel.WriteString('Explorer','Patch',GetCurrentPathW.Path);
 DBkernel.WriteInteger('Explorer','PatchType',GetCurrentPathW.PType);
 fStatusProgress.free;
 FormManager.UnRegisterMainForm(Self);
 DBKernel.UnRegisterForm(self);

end;

procedure TExplorerForm.ListView1Edited(Sender: TObject; Item: TEasyItem;
      var S: String);
var
  DS : TDataSet;
  Folder : String;
begin
 FDblClicked:=false;
 s:=copy(s,1,min(length(s),255));
 if AnsiLowerCase(s)=AnsiLowerCase(GetFileName(fFilesInfo[popupmenu1.tag].FileName)) then exit;
 begin
  If GetExt(s)<>GetExt(fFilesInfo[popupmenu1.tag].FileName) then
  If FileExists(fFilesInfo[popupmenu1.tag].FileName) then
  begin
   If ID_OK<>MessageBoxDB(Handle,TEXT_MES_REPLACE_EXT,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
   begin
    s:=GetFileName(fFilesInfo[popupmenu1.tag].FileName);
    Exit;
   end;
  end;
  if fFilesInfo[popupmenu1.tag].FileType=EXPLORER_ITEM_FOLDER then
  begin
   DS:=GetQuery;
   Folder:=fFilesInfo[popupmenu1.tag].FileName;
   FormatDir(Folder);
   SetSQL(DS,'Select count(*) as CountField from '+GetDefDBName+' where (FFileName Like :FolderA)');
   SetStrParam(DS,0,normalizeDBStringLike('%'+Folder+'%'));
   DS.Open;
   if DS.FieldByName('CountField').AsInteger=0 then
   begin
    try
     RenameResult:=RenameFile(fFilesInfo[popupmenu1.tag].FileName,GetDirectory(fFilesInfo[popupmenu1.tag].FileName)+s);
    except
     RenameResult:=false;
    end;
   end else
   RenameResult:=RenamefileWithDB(fFilesInfo[popupmenu1.tag].FileName,GetDirectory(fFilesInfo[popupmenu1.tag].FileName)+s, fFilesInfo[popupmenu1.tag].ID,false);
   FreeDS(DS);
  end else
  RenameResult:=RenamefileWithDB(fFilesInfo[popupmenu1.tag].FileName,GetDirectory(fFilesInfo[popupmenu1.tag].FileName)+s, fFilesInfo[popupmenu1.tag].ID,false);
 end;
end;

procedure TExplorerForm.HintTimerTimer(Sender: TObject);
var
  p, p1:tpoint;
  Index, i : integer;
begin
 GetCursorPos(p);
 p1:=Listview1.ScreenToClient(p);
 if (not Active) or (not Listview1.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (shloadingthitem<>loadingthitem) then
 begin
  HintTimer.Enabled:=false;
  Exit;
 end;
 if Loadingthitem=nil then exit;
 Index:=Loadingthitem.index;
 if Index<0 then exit;
 Index:=ItemIndexToMenuIndex(index);
 if Index>Length(fFilesInfo)-1 then exit;

  if not (CtrlKeyDown or ShiftKeyDown) then
  if DBKernel.Readbool('Options','UseHotSelect',true) then
  if not loadingthitem.Selected then
  begin
   if not (CtrlKeyDown or ShiftKeyDown) then
   for i:=0 to Listview1.Items.Count-1 do
   if Listview1.Items[i].Selected then
   if loadingthitem<>Listview1.Items[i] then
   Listview1.Items[i].Selected:=false;
   if ShiftKeyDown then
    Listview1.Selection.SelectRange(loadingthitem,Listview1.Selection.FocusedItem,false,false) else
   if not ShiftKeyDown then
   begin
    loadingthitem.Selected:=true;
   end;
  end;
  loadingthitem.Focused:=true;

 if not ExtInMask(SupportedExt,GetExt(fFilesInfo[Index].FileName)) then begin exit; end;

 If not FileExists(fFilesInfo[Index].FileName) then exit;
 HintTimer.Enabled:=false;
 UnitHintCeator.fitem:= loadingthitem;
 UnitHintCeator.threct:=rect(p.X,p.Y,p.x+100,p.Y+100);
 UnitHintCeator.fInfo:=RecordInfoOne(fFilesInfo[Index].FileName,fFilesInfo[Index].ID,fFilesInfo[Index].Rotate,fFilesInfo[Index].Rating, fFilesInfo[Index].Access, fFilesInfo[Index].FileSize, fFilesInfo[index].Comment, fFilesInfo[index].KeyWords,fFilesInfo[index].Owner,fFilesInfo[index].Collections,fFilesInfo[index].Groups,fFilesInfo[index].Date,fFilesInfo[index].IsDate,fFilesInfo[index].IsTime,fFilesInfo[index].Time,fFilesInfo[index].Crypted,fFilesInfo[index].Include,fFilesInfo[index].Loaded,fFilesInfo[index].Links);
 UnitHintCeator.work_.Add(fFilesInfo[Index].FileName);
 UnitHintCeator.hr:=self.hintrealA;
 UnitHintCeator.Owner:=self;

 HintCeator.Create(false);
end;

function TExplorerForm.hintrealA(item: TObject): boolean;
var
  p, p1 : tpoint;
begin
 GetCursorPos(p);
 p1:=listview1.ScreenToClient(p);
 result:=not ((not self.Active) or (not listview1.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (ItemAtPos(p1.X,p1.y)=nil) or (item<>loadingthitem));
end;

procedure TExplorerForm.ListView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  P : Tpoint;
  Index : Integer;
  Icon48 :TIcon48;
  i, n, MaxH, MaxW, ImH,ImW : integer;
  Image : TBitmapImageListImage;
  smintL,smintR : SmallInt;
  TempImage, DragImage : TBitmap;
  SelectedItem, item: TEasyItem;
  FileName : string;
  R : TRect;
  EasyRect : TEasyRectArrayObject;
Const
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK+DT_CENTER;
begin
 PopupHandled:=false;

 smintL:=GetAsyncKeystate(VK_LBUTTON);
 smintR:=GetAsyncKeystate(VK_RBUTTON);

 If fDBCanDrag then
 if not outdrag then
 begin
  GetCursorPos(p);
  If (Abs(fDBDragPoint.x-p.x)>3) or (Abs(fDBDragPoint.y-p.y)>3) then
  if (smintR<>0) or (smintL<>0) then

  begin
   p:=fDBDragPoint;
   DragImageList.Clear;
   Image.Bitmap:=nil;
   Image.Icon:=nil;

   if ItemAtPos(ListView1.ScreenToClient(p).x,ListView1.ScreenToClient(p).y)<>nil then
   Image:=FBitmapImageList.FImages[ItemAtPos(ListView1.ScreenToClient(p).x,ListView1.ScreenToClient(p).y).ImageIndex] else
   if Listview1Selected<>nil then
   Image:=FBitmapImageList.FImages[Listview1Selected.ImageIndex];
   
   item:=ItemAtPos(ListView1.ScreenToClient(p).x,ListView1.ScreenToClient(p).y);
   if item=nil then exit;
   if Listview1.Selection.FocusedItem=nil then
   Listview1.Selection.FocusedItem:=item;
   Case ListView of
    LV_THUMBS     : begin DragImageList.Height:=ThSize; DragImageList.Width:=ThSize;  end;
    LV_ICONS      : begin DragImageList.Height:=32; DragImageList.Width:=32;  end;
    LV_SMALLICONS : begin DragImageList.Height:=16; DragImageList.Width:=16;  end;
    LV_TITLES     : begin DragImageList.Height:=16; DragImageList.Width:=16;  end;
    LV_TILE       : begin DragImageList.Height:=48; DragImageList.Width:=48;  end;
    LV_GRID       : begin DragImageList.Height:=32; DragImageList.Width:=32;  end;
   end;

   if Image.IsBitmap then
   begin

    //Creating Draw image
    TempImage:=TBitmap.create;
    TempImage.PixelFormat:=pf32bit;
    TempImage.Width:=fPictureSize+Min(ListView1.Selection.Count,10)*7+5;//r.Right;
    TempImage.Height:=fPictureSize+Min(ListView1.Selection.Count,10)*7+45+1;//r.Bottom;/
    MaxH:=0;
    MaxW:=0;
    TempImage.Canvas.Brush.Color := 0;
    TempImage.Canvas.FillRect(Rect(0, 0, TempImage.Width, TempImage.Height));

    if ListView1.Selection.Count<2 then
    begin
     DragImage:=nil;
     if item<>nil then
     DragImage:=FBitmapImageList.FImages[item.ImageIndex].Bitmap else
     if ListView1.Selection.First<>nil then
     DragImage:=FBitmapImageList.FImages[Listview1.Selection.First.ImageIndex].Bitmap;

     DragImage:=RemoveBlackColor(DragImage);
     TempImage.Canvas.Draw(0,0, DragImage);
     n:=0;
     MaxH:=DragImage.Height;
     MaxW:=DragImage.Width;
     ImH:=DragImage.Height;
     ImW:=DragImage.Width;
     DragImage.Free;
    end else
    begin
     SelectedItem:=Listview1.Selection.First;
     n:=1;
     for i:=1 to 9 do
     begin
      if SelectedItem<>item then
      begin
       DragImage:=FBitmapImageList.FImages[SelectedItem.ImageIndex].Bitmap;
       DragImage:=RemoveBlackColor(DragImage);
       TempImage.Canvas.Draw(n,n, DragImage);
       Inc(n,7);
       if DragImage.Height+n>MaxH then MaxH:=DragImage.Height+n;
       if DragImage.Width+n>MaxW then MaxW:=DragImage.Width+n;
       DragImage.Free;
      end;
      SelectedItem:=Listview1.Selection.Next(SelectedItem);
      if SelectedItem=nil then break;
     end;
     DragImage:=FBitmapImageList.FImages[Item.ImageIndex].Bitmap;
     DragImage:=RemoveBlackColor(DragImage);
     TempImage.Canvas.Draw(n,n, DragImage);
     if DragImage.Height+n>MaxH then MaxH:=DragImage.Height+n;
     if DragImage.Width+n>MaxW then MaxW:=DragImage.Width+n;
     ImH:=DragImage.Height;
     ImW:=DragImage.Width;
     DragImage.Free;
    end;                   
    if not IsWindowsVista then
    TempImage.Canvas.Font.Color:=$000010 else
    TempImage.Canvas.Font.Color:=$000001;

    R:=Rect(0,MaxH+3,MaxW,TempImage.Height);

    Index:=ItemIndexToMenuIndex(Item.index);
    if Index<Length(fFilesInfo) then
    FileName:=Item.Caption;
    TempImage.Canvas.Brush.Style:=bsClear;
    DrawTextA(TempImage.Canvas.Handle, PChar(FileName), Length(FileName), R, DrawTextOpt);

    DragImageList.Clear;
    DragImageList.Height:=TempImage.Height;
    DragImageList.Width:=TempImage.Width;
    if not IsWindowsVista then
    DragImageList.BkColor:=$0;
    DragImageList.Add(TempImage,nil);
    TempImage.Free;

    item.ItemRectArray(nil,ListView1.Canvas,EasyRect);
    fDBDragPoint:=ListView1.ScreenToClient(fDBDragPoint);
    ImW:=(EasyRect.IconRect.Right-EasyRect.IconRect.Left) div 2 - ImW div 2;
    ImH:=(EasyRect.IconRect.Bottom-EasyRect.IconRect.Top) div 2 - ImH div 2;
    DropFileSource1.ImageHotSpotX:=Min(MaxW,Max(1,fDBDragPoint.X-EasyRect.IconRect.Left+n-ImW));
    DropFileSource1.ImageHotSpotY:=Min(MaXH,Max(1,fDBDragPoint.Y-EasyRect.IconRect.Top+n-ImH+ListView1.Scrollbars.ViewableViewportRect.Top));

   end else
   begin          
    if ListView=LV_TILE then
    begin
     Icon48:=TIcon48.Create;
     Icon48.Assign(Image.Icon);
     DragImageList.AddIcon(Icon48);
     Icon48.Free;
    end else
    DragImageList.AddIcon(Image.Icon);
    DropFileSource1.ImageHotSpotX:=DragImageList.Width div 2;
    DropFileSource1.ImageHotSpotY:=DragImageList.Height div 2;
   end;
   SetSelected(nil);
   DropFileSource1.Files.Clear;
   for i:=0 to Length(fFilesToDrag)-1 do
   DropFileSource1.Files.Add(fFilesToDrag[i]);
   ListView1.Refresh;
   SelfDraging:=true;

   Application.HideHint;
   if ImHint<>nil then
   if not UnitImHint.closed then
   ImHint.close;
   hinttimer.Enabled:=false;
   FWasDragAndDrop:=true;
   DropFileSource1.Execute;
   SelfDraging:=false;
   DropFileTarget1.Files.clear;
   fDBCanDrag:=true;
   ListView1MouseUp(Sender,mbLeft,Shift,X,Y);
   SetLength(FListDragItems,0);
   fDBCanDrag:=false;
  end;
 end;

// loadingthitem:=ItemAtPos(X,Y);

 if ImHint<>nil then
 begin
  GetCursorPos(p);
  if WindowFromPoint(p)=ImHint.Handle then exit;
 end;

 if loadingthitem=ItemByPointImage(ListView1,Point(X,Y)) then exit;
 loadingthitem:=ItemByPointImage(ListView1,Point(X,Y));

 if loadingthitem=nil then
 begin
  Application.HideHint;
  if ImHint<>nil then
  if not UnitImHint.closed then
  ImHint.close;
  hinttimer.Enabled:=false;
 end else begin
  hinttimer.Enabled:=false;
  if self.Active then
  begin
   if DBKernel.Readbool('Options','AllowPreview',True) then
   HintTimer.Enabled:=true;
   shloadingthitem:=loadingthitem;
  end;
  Index:=ItemIndexToMenuIndex(loadingthitem.index);
  If Length(fFilesInfo)=0 then Exit;
  if DBKernel.Readbool('Options','AllowPreview',True) then
  listview1.showhint:=false{ not fileexists(fFilesInfo[Index].FileName)} else
  listview1.showhint:=false;
  ListView1.Hint:=fFilesInfo[Index].Comment;
 end;
end;

procedure TExplorerForm.SetItemLength(Length: integer; GUID : TGUID);
begin
  if IsEqualGUID(GUID, CurrentGUID) then
    SetLength(fFilesInfo, Length);
end;

procedure TExplorerForm.IncItemLength(GUID: TGUID);
begin
  if IsEqualGUID(GUID, CurrentGUID) then
    Setlength(fFilesInfo, Length(fFilesInfo) + 1);
end;

procedure TExplorerForm.SetInfoToItemW(info : TOneRecordInfo; Number : Integer);
begin
 fFilesInfo[Number].FileName:=info.ItemFileName;
 fFilesInfo[Number].ID:=info.ItemId;
 fFilesInfo[Number].Rotate:=info.ItemRotate;
 fFilesInfo[Number].Access:=info.ItemAccess;
 fFilesInfo[Number].Rating:=info.ItemRating;
 fFilesInfo[Number].FileSize:=info.ItemSize;
 fFilesInfo[Number].Comment:=info.ItemComment;
 fFilesInfo[Number].KeyWords:=info.ItemKeyWords;
 fFilesInfo[Number].FileType:=Info.Tag;
 fFilesInfo[Number].Date:=Info.ItemDate;
 fFilesInfo[Number].Time:=Info.ItemTime;
 fFilesInfo[Number].IsDate:=Info.ItemIsDate;
 fFilesInfo[Number].IsTime:=Info.ItemIsTime;
 fFilesInfo[Number].Groups:=Info.ItemGroups;
 fFilesInfo[Number].Crypted:=Info.ItemCrypted;
 fFilesInfo[Number].Include:=Info.ItemInclude;
 fFilesInfo[Number].Links:=Info.ItemLinks;
 if AnsiLowerCase(info.ItemFileName)=AnsiLowerCase(FSelectedInfo.FileName) then
 ListView1SelectItem(nil,nil,false);
end;

procedure TExplorerForm.SetInfoToItem(info : TOneRecordInfo; FileGUID: TGUID);
var
  i : Integer;
begin
 for i:=0 to Length(fFilesInfo)-1 do
 if IsEqualGUID(fFilesInfo[i].SID, FileGUID) then
 begin
  fFilesInfo[i].FileName:=info.ItemFileName;
  fFilesInfo[i].ID:=info.ItemId;
  fFilesInfo[i].Rotate:=info.ItemRotate;
  fFilesInfo[i].Access:=info.ItemAccess;
  fFilesInfo[i].Rating:=info.ItemRating;
  fFilesInfo[i].FileSize:=info.ItemSize;
  fFilesInfo[i].Comment:=info.ItemComment;
  fFilesInfo[i].KeyWords:=info.ItemKeyWords;
  fFilesInfo[i].Date:=info.ItemDate;
  fFilesInfo[i].Time:=info.ItemTime;
  fFilesInfo[i].IsDate:=info.ItemIsDate;
  fFilesInfo[i].IsTime:=info.ItemIsTime;
  fFilesInfo[i].Groups:=info.ItemGroups;
  fFilesInfo[i].KeyWords:=info.ItemKeyWords;
  fFilesInfo[i].FileType:=Info.Tag;
  fFilesInfo[i].Crypted:=Info.ItemCrypted;
  fFilesInfo[i].Loaded:=Info.Loaded;
  fFilesInfo[i].Include:=Info.ItemInclude;
  fFilesInfo[i].Links:=Info.ItemLinks;
  if Viewer<>nil then Viewer.UpdateInfoAboutFileName(info.ItemFileName,info);
  Break;
 end;
 if AnsiLowerCase(info.ItemFileName)=AnsiLowerCase(FSelectedInfo.FileName) then
 ListView1SelectItem(nil,nil,false);
end;

procedure TExplorerForm.SetInfoToLastItem(info: TOneRecordInfo; GUID: TGUID);
Var
  Index : Integer;
begin
  if IsEqualGUID(GUID, CurrentGUID) then
  begin
   Index:=Length(fFilesInfo);
   fFilesInfo[Index].FileName:=info.ItemFileName;
   fFilesInfo[Index].ID:=info.ItemId;
   fFilesInfo[Index].Rotate:=info.ItemRotate;
   fFilesInfo[Index].Access:=info.ItemAccess;
   fFilesInfo[Index].Rating:=info.ItemRating;
   fFilesInfo[Index].FileSize:=info.ItemSize;
   fFilesInfo[Index].Comment:=info.ItemComment;
   fFilesInfo[Index].KeyWords:=info.ItemKeyWords;
   fFilesInfo[Index].Date:=info.ItemDate;
   fFilesInfo[Index].Time:=info.ItemTime;
   fFilesInfo[Index].IsDate:=info.ItemIsDate;
   fFilesInfo[Index].IsTime:=info.ItemIsTime;
   fFilesInfo[Index].Groups:=info.ItemGroups;
   fFilesInfo[Index].FileType:=Info.Tag;
   fFilesInfo[Index].Crypted:=Info.ItemCrypted;
   fFilesInfo[Index].Loaded:=Info.Loaded;
   fFilesInfo[Index].Include:=Info.ItemInclude;
   fFilesInfo[Index].Links:=Info.ItemLinks;
  end;
 if AnsiLowerCase(info.ItemFileName)=AnsiLowerCase(FSelectedInfo.FileName) then
 ListView1SelectItem(nil,nil,false);
end;

function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; FPictureSize : integer): TEasyItem;
var
  i: Integer;
  r : TRect;
  RectArray: TEasyRectArrayObject;
  t,l, a,b : integer;
begin
  Result := nil;
  i := 0;
  r :=  EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X:=ViewportPoint.X+r.Left;
  ViewportPoint.Y:=ViewportPoint.Y+r.Top;
  while not Assigned(Result) and (i < EasyListview.Items.Count) do
  begin
      EasyListview.Items[i].ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);
      a:=EasyListview.CellSizes.Thumbnail.Width - 35;
      b:=0;
      t:=RectArray.IconRect.Top;
      l:=RectArray.IconRect.Left;
      r:=Rect(a+l,b+t,a+22+l,b+t+18);
      if PtInRect(r, ViewportPoint) then
       Result := EasyListview.Items[i];
    Inc(i)
  end
end;

procedure TExplorerForm.ListView1DblClick(Sender: TObject);
var
  MousePos : TPoint;
  Capt, dir, ShellDir, LinkPath : string;
  MenuInfo : TDBPopupMenuInfo;
  info : TRecordsInfo;
  Index : Integer;
  p,p1 : TPoint;
  Item : TObject;

  procedure RestoreSelected;
  begin
   fDBCanDrag:=false;
   fDBCanDragW:=false;
  end;

function ResolveShortcut(Wnd: HWND; ShortcutPath: string): string;
var
  ShortCut : TVRSIShortCut;
begin
  ShortCut:= TVRSIShortCut.Create(ShortcutPath);
  Result:= ShortCut.Path;
  ShortCut.Free;
end;

begin

 if DBkernel.UserRights.SetRating then
 begin
  GetCursorPos(p1);
  p:=ListView1.ScreenToClient(p1);
  if ItemByPointStar(Listview1,p,fPictureSize)<>nil then
  begin
   Index:=ItemAtPos(p.x,p.y).Index;
   Index:=ItemIndexToMenuIndex(index);
   RatingPopupMenu1.Tag:=fFilesInfo[Index].ID;
   if RatingPopupMenu1.Tag>0 then
   begin
    Application.HideHint;
    if ImHint<>nil then
    if not UnitImHint.Closed then
    ImHint.Close;
    self.loadingthitem:=nil;
    RatingPopupMenu1.Popup(p1.x,p1.y);
    exit;
   end;
  end;
 end;

 FDblClicked:=true;
 fDBCanDrag:=false;
 fDBCanDragW:=false;
 SetLength(fFilesToDrag,0);
 Application.HideHint;
 if ImHint<>nil then
 if not UnitImHint.Closed then
 ImHint.Close;
 HintTimer.Enabled:=false;
              
 GetCursorPos(p1);
 p:=ListView1.ScreenToClient(p1);
 Item:=ItemByPointImage(ListView1, Point(p.x,p.y));
 if (Item=nil) and (Sender=nil) then Item:= ListView1Selected;

 if Item<>nil then
 if ListView1Selected<>nil then
 begin
  Capt:=ListView1Selected.Caption;
  getcursorpos(MousePos);
  Index:=ListView1Selected.index;
  Index:=ItemIndexToMenuIndex(index);
  if Index>Length(fFilesInfo)-1 then exit;
  if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) then
  begin
   dir:=fFilesInfo[Index].FileName;
   FormatDir(dir);
   SetNewPath(dir,false);
   exit;
  end;
  if fFilesInfo[Index].FileType=EXPLORER_ITEM_DRIVE then
  begin
   SetNewPath(fFilesInfo[Index].FileName,false);
   exit;
  end;
  if fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE then
  begin
   MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
   If Viewer=nil then
   Application.CreateForm(TViewer, Viewer);
   DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
   Viewer.Execute(Sender,info);
   RestoreSelected;
   exit;
  end;
  if fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE then
  begin
   if GetExt(fFilesInfo[Index].FileName)<>'LNK' then
   begin
    ShellDir:=GetDirectory(fFilesInfo[Index].FileName);
    UnFormatDir(ShellDir);
    ShellExecute(Handle, Nil,Pchar(fFilesInfo[Index].FileName), Nil, PChar(ShellDir), SW_NORMAL);
    RestoreSelected;
    exit;
   end else 
   begin
    LinkPath:=ResolveShortcut(Handle,fFilesInfo[Index].FileName);
    if LinkPath='' then exit;
    if DirectoryExists(LinkPath) then
    begin
     SetStringPath(LinkPath,false);
     exit;
    end else
    begin
     if ExtInMask(SupportedExt,GetExt(LinkPath)) then
     begin
      MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
      If Viewer=nil then
      Application.CreateForm(TViewer, Viewer);
      DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
      Viewer.Execute(Sender,info);
      RestoreSelected;
      exit;
     end;
     ShellDir:=GetDirectory(LinkPath);
     UnFormatDir(ShellDir);
     ShellExecute(Handle, Nil,Pchar(LinkPath), Nil, PChar(ShellDir), SW_NORMAL);
     RestoreSelected;
     exit;
    end;

   end;
  end;

  case fFilesInfo[Index].FileType of
    EXPLORER_ITEM_NETWORK,
    EXPLORER_ITEM_WORKGROUP,
    EXPLORER_ITEM_COMPUTER,
    EXPLORER_ITEM_SHARE:
      SetNewPathW(ExplorerPath(fFilesInfo[Index].FileName, fFilesInfo[Index].FileType), False);
  end;

 end;
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
  if ShellTreeView1.Selected<>nil then
  ShellTreeView1.Select(ShellTreeView1.Selected.Parent);
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

procedure TExplorerForm.BeginUpdate(GUID: TGUID);
begin
  if IsEqualGUID(GUID, CurrentGUID) then
  begin
  If not UpdatingList then
  if ListView1<>nil then
  begin
   ListView1.Groups[0].Visible:=false;
   ListView1.Cursor:=CrHourGlass;
   UpdatingList:=True;
  end;
 end;
end;

procedure TExplorerForm.EndUpdate(GUID: TGUID);
begin
  if IsEqualGUID(GUID, CurrentGUID) then
 begin       
  If UpdatingList then
  begin
   ListView1.Groups[0].Visible:=true;
   ListView1.Groups.EndUpdate(true);
   ListView1.Realign;
   ListView1.Repaint;
   ListView1.Cursor:=CrDefault;
   ListView1.HotTrack.Enabled:=DBKernel.Readbool('Options','UseHotSelect',true);
   UpdatingList:=false;
  end;
 end;
end;

procedure TExplorerForm.Open1Click(Sender: TObject);
begin
 ListView1DblClick(nil);
end;

function TExplorerForm.GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
var
  i, Count:integer;
  ItemIndex : Integer;
begin
 Result.Position:=0;
 Result.IsListItem:=false;
 Result.IsPlusMenu:=false;
 Result:=DBPopupMenuInfoNil;
 Result.IsDateGroup:=True;
 Count:=0;
 For i:=0 to ListView1.Items.Count-1 do
 begin
  ItemIndex:=ItemIndexToMenuIndex(i);
  if ItemIndex>length(fFilesInfo)-1 then exit;
  if fFilesInfo[ItemIndex].FileType=EXPLORER_ITEM_IMAGE then
  begin
   inc(Count);
   AddDBPopupMenuInfoOne(Result,fFilesInfo[ItemIndex].FileName, fFilesInfo[ItemIndex].Comment, fFilesInfo[ItemIndex].Groups, fFilesInfo[ItemIndex].ID, fFilesInfo[ItemIndex].FileSize, fFilesInfo[ItemIndex].Rotate, fFilesInfo[ItemIndex].Rating, fFilesInfo[ItemIndex].Access, fFilesInfo[ItemIndex].Date, fFilesInfo[ItemIndex].IsDate, fFilesInfo[ItemIndex].IsTime, fFilesInfo[ItemIndex].Time , fFilesInfo[ItemIndex].Crypted,  fFilesInfo[ItemIndex].KeyWords,fFilesInfo[ItemIndex].Loaded,fFilesInfo[ItemIndex].Include,fFilesInfo[ItemIndex].Links);
   if ListView1.Items[i].Selected then
   Result.ItemSelected_[Count-1]:=true else
   Result.ItemSelected_[Count-1]:=false;
   If item=nil then
   Result.Position:=0 else
   begin
    if ListView1.Items[i].Selected then
    if Result.Position=0 then
    Result.Position:=count-1;
   end;
  end;
 end;
end;

procedure TExplorerForm.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  s : string;
begin
 If key=#13 then
 begin
  Key:=#0;
  SetStringPath(Edit1.text,false);
 end;
 if (key=':') or (key='\') then
 begin
  if SlashHandled then
  begin
   SlashHandled:=false;
   exit;
  end;
  s:=Edit1.Text;
  FormatDir(s);
  if ComboPath<>GetDirectory(s) then
  begin
   ComboPath:=GetDirectory(Edit1.Text);
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
 Edit1.Width:=CoolBar1.Width-ImButton1.Width-Label2.Width-ToolButton9.Width-ImButton1.Width;
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
  ListView1.Refresh;
  exit;
 end;
 if ID=-2 then exit;
 if SetNewIDFileData in params then
 begin
  for i:=0 to length(fFilesInfo)-1 do
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
   if FBitmapImageList.FImages[fFilesInfo[i].ImageIndex].Bitmap=nil then
   begin
    bit := TBitmap.Create;
    bit.PixelFormat:=pf24bit;
    bit.Assign(Value.JPEGImage);
    
    if FBitmapImageList.FImages[fFilesInfo[i].ImageIndex].IsBitmap then
    FBitmapImageList.FImages[fFilesInfo[i].ImageIndex].Bitmap.Free;
    
    FBitmapImageList.FImages[fFilesInfo[i].ImageIndex].IsBitmap:=true;
    FBitmapImageList.FImages[fFilesInfo[i].ImageIndex].Bitmap:=bit;
   end;
   ListView1.Refresh;
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
  for i:=0 to length(fFilesInfo)-1 do
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
     if index<ListView1.Items.Count-1 then
     if ListView1.Items[i].Data<>nil then
     Boolean(TDataObject(ListView1.Items[i].Data).Data^):=Value.Include;

     fFilesInfo[i].Include:=Value.Include;
     ListView1.Refresh;
    end;
    break;
   end;
  end;
 end;

 if [EventID_Param_Rotate]*params<>[] then
 begin
  for i:=0 to length(fFilesInfo)-1 do
  begin
   if fFilesInfo[i].ID=ID then
   begin
    index:=MenuIndexToItemIndex(i);
    if ListView1.Items[index].ImageIndex>-1 then
      ApplyRotate(FBitmapImageList.FImages[ListView1.Items[index].ImageIndex].Bitmap, ReRotation);

   end;
  end;
 end;
 
 ImParams:=[EventID_Param_Refresh,EventID_Param_Rotate,EventID_Param_Rating,EventID_Param_Private,EventID_Param_Access];
 If ImParams*params<>[] then
 begin
  ListView1.Refresh;
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
  ListView1.Selection.ClearAll;
  RefreshLinkClick(RefreshLink);
 end;
end;

procedure TExplorerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 ExplorerManager.RemoveExplorer(Self);
 if ImHint<>nil then
 ImHint.close;
 hinttimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
end;

procedure TExplorerForm.SelectAll1Click(Sender: TObject);
begin
 ListView1.Selection.SelectAll;
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
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;  
 info.PictureSize:=fPictureSize;
 if fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE then
 RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,CurrentGUID));
 if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_EXEFILE) then
 RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FILE,info,self,UpdaterInfo,CurrentGUID));
end;

procedure TExplorerForm.RefreshItemA(Number: Integer);
var
  UpdaterInfo : TUpdaterInfo;
  info : TExplorerViewInfo;
  Index : integer;
begin
 Index := ItemIndexToMenuIndex(Number);
 if Index=-1 then exit;
 if Index>Length(fFilesInfo)-1 then exit;
 UpdaterInfo.IsUpdater:=false;
 UpdaterInfo.ID:=fFilesInfo[Index].ID;
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;    
 info.PictureSize:=fPictureSize;
 if fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE then
 RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,CurrentGUID));
 if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_EXEFILE) then
 RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FILE,info,self,UpdaterInfo,CurrentGUID));
end;

procedure TExplorerForm.HistoryChanged(Sender: TObject);
var
  MenuBack, MenuForward : TArMenuItem;
  MenuBackInfo, MenuForwardInfo : TArExplorerPath;
  i : integer;
begin
 ToolButton1.Enabled:=fHistory.CanBack;
 ToolButton2.Enabled:=fHistory.CanForward;
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
   MenuBack[Length(MenuBack)-1-i].Caption:=GetFileName(MenuBackInfo[i].Path);
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
   MenuForward[i].Caption:=GetFileName(MenuForwardInfo[i].Path);
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
  i, index : integer;
  r : TRect;
  item, itemsel: TEasyItem;
begin
  ItemsDeselected:=false;
  Item:=ItemAtPos(x,y);
  FWasDragAndDrop:=false;

  MouseDowned:=Button=mbRight;

//  if ListView=LV_THUMBS then
  begin
   itemsel:=Item;
   r :=  Listview1.Scrollbars.ViewableViewportRect;
   ItemByMouseDown:=false;
   if itemsel<>nil then
   if itemsel.SelectionHitPt(Point(x+r.Left,y+r.Top), eshtClickSelect) then
   begin

    ItemSelectedByMouseDown:=false;
    if not itemsel.Selected then
    begin
     if [ssCtrl,ssShift]*Shift=[] then
     for i:=0 to Listview1.Items.Count-1 do
     if Listview1.Items[i].Selected then
     if itemsel<>Listview1.Items[i] then
     Listview1.Items[i].Selected:=false;
     if [ssShift]*Shift<>[] then
      Listview1.Selection.SelectRange(itemsel,Listview1.Selection.FocusedItem,false,false) else
     begin
      ItemSelectedByMouseDown:=true;
      itemsel.Selected:=true;
      itemsel.Focused:=true;
     end;
    end else ItemByMouseDown:=true;
    itemsel.Focused:=true;
   end;
  end;

  if ((Button = mbLeft) or (Button = mbRight)) and (Item<>nil) and not FDblClicked then
  begin
    if Button = mbRight then
    begin
     rdown:=true
    end else
    begin
     rdown:=false;
    end;
    fDBCanDrag:=DBKernel.UserRights.FileOperationsNormal;
    SetLength(fFilesToDrag,0);
    SetLength(FListDragItems,0);
    GetCursorPos(fDBDragPoint);
    For i:=0 to ListView1.Items.Count-1 do
    if ListView1.Items[i].Selected then
    begin
     index:=ItemIndexToMenuIndex(i);
     if index>Length(fFilesInfo)-1 then exit;
     if (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (fFilesInfo[index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_SHARE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE) then
     begin
      SetLength(FListDragItems,Length(FListDragItems)+1);
      FListDragItems[Length(FListDragItems)-1]:=ListView1.Items[i];
      SetLength(fFilesToDrag,Length(fFilesToDrag)+1);
      fFilesToDrag[Length(fFilesToDrag)-1]:=fFilesInfo[index].FileName;
     end;
    end;
    If Length(fFilesToDrag)=0 then fDBCanDrag:=false;
  end;
  FDblClicked:=false;
end;

procedure TExplorerForm.ListView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j, k : integer;
  Handled : boolean;
  item: TEasyItem;
begin

   item:=self.ItemAtPos(X,Y);
   if item<>nil then
   if item.Selected and (Button=mbLeft) then
   begin
    if (Shift=[]) and item.Selected then
    if ItemByMouseDown then
    begin
     for i:=0 to Listview1.Items.Count-1 do
     if Listview1.Items[i].Selected then
     if item<>Listview1.Items[i] then
     Listview1.Items[i].Selected:=false;
    end;         
    if not (ebcsDragSelecting in Listview1.States) then 
    if ([ssCtrl]*Shift<>[]) and not ItemSelectedByMouseDown  then
    item.Selected:=false;
   end;        

 if MouseDowned then
 if Button=mbRight then
 begin
  ListView1ContextPopup(ListView1,Point(X,Y),Handled);
  PopupHandled:=true;
 end;

 MouseDowned:=false;

 if fDBCanDrag and ItemsDeselected then
 begin
  If (abs(fDBDragPoint.x-x)>3) or (abs(fDBDragPoint.y-y)>3) then
  if not FWasDragAndDrop then exit;

  SetSelected(nil);

  for j:=0 to ListView1.Items.Count-1 do
  begin
   for i:=0 to Length(FListDragItems)-1 do
   if FListDragItems[i]=ListView1.Items[j] then
   begin
    FListDragItems[i].Selected:=True;
    if i<>0 then
    begin
     for k:=i to Length(FListDragItems)-2 do
     FListDragItems[k]:=FListDragItems[k+1];
     SetLength(FListDragItems,Length(FListDragItems)-1);
    end;
    Break;
   end;
  end;
 end;
 SetLength(fFilesToDrag,0);
 SetLength(FListDragItems,0);
 fDBCanDrag:=false;
 fDBCanDragW:=false;
end;

procedure TExplorerForm.ListView1Exit(Sender: TObject);
begin
 rdown:=false;
 FDblClicked:=false;
 fDBCanDrag:=false;
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
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 info.PictureSize:=fPictureSize;
 For i:=0 to ListView1.Items.Count-1 do
 if ListView1.Items[i].Selected then
 begin
  Index := ItemIndexToMenuIndex(i);
  if (fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE) then
  begin
   RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,CurrentGUID));
  end;

  if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) then
  begin
   RegisterThreadAndStart(TExplorerThread.Create(true,fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FOLDER_UPDATE,info,self,UpdaterInfo,CurrentGUID));
  end;
 end;
end;

procedure TExplorerForm.RefreshItemByID(ID: Integer);
Var
  i : integer;
  index : Integer;
begin
 For i:=0 to Length(fFilesInfo)-1 do
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
 For i:=0 to Length(fFilesInfo)-1 do
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
 For i:=0 to Length(fFilesInfo)-1 do
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
  File_List : TStrings;
begin
 File_List:=TStringList.Create;
 File_List.Add(GetCurrentPath);
 Copy_Move(true,File_List);
 File_List.Free;
end;

procedure TExplorerForm.OpenInNewWindow1Click(Sender: TObject);
var
  Path : TExplorerPath;
begin
 Path:=GetCurrentPathW;
 With ExplorerManager.NewExplorer do
 begin
  SetNewPathW(Path,False);
  Show;
 end;
end;

function TExplorerForm.GetCurrentPath: String;
begin
 Result:=GetCurrentPathW.Path;
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
  fDBCanDrag:=false;
  fDBCanDragW:=false;
  HintTimer.Enabled:=False;
end;

Procedure TExplorerForm.Select(Item : TEasyItem; GUID : TGUID);
begin
 if IsEqualGUID(GUID, CurrentGUID) and (Item<>nil) then
 begin
  Item.Selected:=true;
  Item.Focused:=true;
  Item.MakeVisible(emvTop);
 end;
end;

procedure TExplorerForm.ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include : boolean; Big : boolean = false);
var
  i, index, c : Integer;
  R : TRect;
  p : PBoolean;
  RectArray: TEasyRectArrayObject;
begin
 For i:=0 to length(FFilesInfo)-1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  index:=MenuIndexToItemIndex(i);
  if (FFilesInfo[i].isBigImage) and (Big=true) //���� ����������� ������� �������� �������
   then exit;

  if Big then FFilesInfo[i].isBigImage:=true;

  if index>ListView1.Items.Count-1 then exit;
  c:=ListView1.Items[index].ImageIndex;
  if ListView1.Items[index].Data<>nil then
  begin
   Boolean(TDataObject(ListView1.Items[index].Data).Data^):=Include;
  end else
  begin

   Getmem(p,SizeOf(Boolean));
   p^:=Include;

   ListView1.Items[index].Data:=TDataObject.Create;
   TDataObject(ListView1.Items[index].Data).Data:=p;

  end;
  if c=-1 then
  begin
   FBitmapImageList.AddBitmap(nil);
   FFilesInfo[i].ImageIndex:=FBitmapImageList.Count-1;
   c:=FBitmapImageList.Count-1;
  end;
  if FBitmapImageList.FImages[c].IsBitmap then
  begin
   if FBitmapImageList.FImages[c].Bitmap<>nil then
   FBitmapImageList.FImages[c].Bitmap.Free
  end else
  if FBitmapImageList.FImages[c].SelfReleased then
  begin
   if FBitmapImageList.FImages[c].Icon<>nil then
   FBitmapImageList.FImages[c].Icon.Free;
  end;
  FBitmapImageList.FImages[c].Bitmap:=Bitmap;
  FBitmapImageList.FImages[c].SelfReleased:=true;

  r :=  Listview1.Scrollbars.ViewableViewportRect;
  Listview1.Items[index].ItemRectArray(Listview1.Header.FirstColumn, Listview1.Canvas, RectArray);
  r:=Rect(ListView1.ClientRect.Left+r.Left,ListView1.ClientRect.Top+r.Top,ListView1.ClientRect.Right+r.Left,ListView1.ClientRect.Bottom+r.Top);
  if RectInRect(r,RectArray.BoundsRect) then
  ListView1.Refresh;

  If FFilesInfo[i].FileType=EXPLORER_ITEM_FOLDER then
  If FFilesInfo[i].FileName=FSelectedInfo.FileName then
  If SelCount=1 then
  ListView1SelectItem(nil,ListView1Selected,True);
  Break;
 end;
end;

procedure TExplorerForm.ReplaceIcon(Icon: TIcon; FileGUID: TGUID; Include : boolean);
var
  i, index, c : Integer;
  R : TRect;
  p : PBoolean;
  RectArray: TEasyRectArrayObject;
begin
 For i:=0 to length(FFilesInfo)-1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  index:=MenuIndexToItemIndex(i);
  if index>ListView1.Items.Count-1 then exit;
  c:=ListView1.Items[index].ImageIndex;
  if ListView1.Items[index].Data<>nil then
  begin
   Boolean(TDataObject(ListView1.Items[index].Data).Data^):=Include;
  end else
  begin
   Getmem(p,SizeOf(Boolean));
   p^:=Include;

   ListView1.Items[index].Data:=TDataObject.Create;
   TDataObject(ListView1.Items[index].Data).Data:=p;
  end;
  if FBitmapImageList.FImages[c].IsBitmap then
  FBitmapImageList.FImages[c].Bitmap.Free else
  if FBitmapImageList.FImages[c].SelfReleased then
  FBitmapImageList.FImages[c].Icon.Free;
  FBitmapImageList.FImages[c].Icon:=Icon;
  FBitmapImageList.FImages[c].SelfReleased:=true;

  r :=  Listview1.Scrollbars.ViewableViewportRect;
  Listview1.Items[index].ItemRectArray(Listview1.Header.FirstColumn, Listview1.Canvas, RectArray);
  r:=Rect(ListView1.ClientRect.Left+r.Left,ListView1.ClientRect.Top+r.Top,ListView1.ClientRect.Right+r.Left,ListView1.ClientRect.Bottom+r.Top);
  if RectInRect(r,RectArray.BoundsRect) then
  ListView1.Refresh;

  If FFilesInfo[i].FileType=EXPLORER_ITEM_FOLDER then
  If FFilesInfo[i].FileName=FSelectedInfo.FileName then
  If SelCount=1 then
  ListView1SelectItem(nil,ListView1Selected,True);
  Break;
 end;
end;

procedure TExplorerForm.AddBitmap(Bitmap: TBitmap; FileGUID: TGUID);
var
  i : Integer;
begin
  for i := Length(FFilesInfo)-1 downto 0 do
    if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
    begin
      FBitmapImageList.AddBitmap(Bitmap);
      FFilesInfo[i].ImageIndex:=FBitmapImageList.Count-1;
      Break;
    end;
end;

procedure TExplorerForm.AddIcon(Icon: TIcon; SelfReleased : Boolean; FileGUID: TGUID);
var
  i : Integer;
begin
  for i := Length(FFilesInfo)-1 downto 0 do
    if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
     begin
      FBitmapImageList.AddIcon(Icon, SelfReleased);
      FFilesInfo[i].ImageIndex:=FBitmapImageList.Count-1;
      Break;
     end;
end;

function TExplorerForm.AddItem(FileGUID: TGUID; LockItems : boolean = true) : TEasyItem;
Var
  i : integer;
  P : PBoolean;
  Data : TObject;
begin
 Result:=Nil;
 For i:=Length(FFilesInfo)-1 downto 0 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  if LockItems then
  if ListView1.Groups[0].Visible then
  if ListView1.Items.Count=0 then ListView1.Groups[0].Visible:=false;

  LockDrawIcon:=true;

  GetMem(P,sizeof(Boolean));
  p^:=FFilesInfo[i].Include;

  Data:=TDataObject.Create;
  TDataObject(Data).Data:=p;

  Result:=ListView1.Items.Add(Data);
  Result.Tag:=FFilesInfo[i].FileType;
  Result.ImageIndex:=FFilesInfo[i].ImageIndex;

  If FFilesInfo[i].FileType<>EXPLORER_ITEM_DRIVE then
  Result.Caption:=GetFileName(FFilesInfo[i].FileName) else
  Result.Caption:=FFilesInfo[i].FileName;
  if IsEqualGUID(FileGUID, NewFileNameGUID) then
  begin
   Result.Selected:=true;
   Result.Focused:=true;  
   ListView1.EditManager.Enabled:=true;
   Result.Edit;
   NewFileNameGUID:=GetGUID;
  end;
  LockDrawIcon:=false;
  if ListView1.Groups[0].Visible then
  ListView1.Refresh;
  Break;
 end;
end;

function TExplorerForm.AddItemW(Caption: string; FileGUID: TGUID) : TEasyItem;
Var
  i : integer;
  P : PBoolean;
begin
 Result:=Nil;
 For i:=0 to length(FFilesInfo)-1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  if ListView1.Groups[0].Visible then
  if ListView1.Items.Count=0 then ListView1.Groups[0].Visible:=false;
  
  LockDrawIcon:=true;
  Result:=ListView1.Items.Add;
  GetMem(P,sizeof(Boolean));
  p^:=True;
  Result.Tag:=FFilesInfo[i].FileType;
  Result.Data:=TDataObject.Create;
  TDataObject(Result.Data).Data:=p;

  Result.ImageIndex:=FFilesInfo[i].ImageIndex;
  Result.Caption:=Caption;

  LockDrawIcon:=false;
  if ListView1.Groups[0].Visible then
  ListView1.Refresh;
  Break;
 end;
end;

procedure TExplorerForm.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
 If key=#13 then ListView1DblClick(nil);
end;

procedure TExplorerForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
 FEditHandle : THandle;
 b : boolean;
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
 if Length(Edit1.Text)>3 then
 begin
  SlashHandled:=true;
  ComboBox1DropDown;
 end;


 if msg.message=512 then
 begin
  FEditHandle:=GetWindow(GetWindow(Edit1.Handle, GW_CHILD), GW_CHILD);
  if FEditHandle=GetWindow(msg.hwnd, GW_CHILD) then
  begin
   if ComboPath<>GetDirectory(Edit1.Text) then
   begin
   AutoCompliteTimer.Enabled:=true;
   ComboPath:=GetDirectory(Edit1.Text);
   end;
  end;
 end;

 if Msg.hwnd=ListView1.Handle then
 begin
  if UpdatingList then
  begin
   if Msg.message=516 then
   Msg.message:=0;
   If Msg.message=513 then
   begin
    SetLength(fFilesToDrag,0);
    SetLength(FListDragItems,0);
    fDBCanDrag:=false;
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

  if Msg.message=WM_MOUSEWHEEL then
  begin
   if Msg.wParam>0 then i:=1 else i:=-1;
   if CtrlKeyDown then
   begin
    ListView1MouseWheel(ListView1,[ssCtrl],i,Point(0,0),b);
    Msg.message:=0;
   end;
  end;

  //middle mouse button
  if Msg.message=519 then
  begin
   Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
   BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
   Msg.message:=0;
  end;

 end;
       
 if Msg.message=256 then
 begin         
  WindowsMenuTickCount:=GetTickCount;
  if (Msg.wParam=37) and CtrlKeyDown then SpeedButton1Click(nil);
  if (Msg.wParam=39) and CtrlKeyDown then SpeedButton2Click(nil);
  if DBkernel.UserRights.ShowPath then
  if (Msg.wParam=38) and CtrlKeyDown then SpeedButton3Click(nil);                                          
  if (Msg.wParam=83) and CtrlKeyDown then
  if ToolButton18.Enabled then ToolButton18Click(nil);
  if (Msg.wParam=116) then SetPath(GetCurrentPath);
 end;

 if Msg.hwnd=ListView1.Handle then
 if Msg.message=256 then
 begin
  WindowsMenuTickCount:=GetTickCount;

  if (Msg.wParam=93) and CtrlKeyDown then
  begin
   if SelCOunt>0 then
   begin

   end else
   begin
    ListView1ContextPopup(nil,ListView1.ClientToScreen(Point(ListView1.Left,ListView1.Top)),b);
   end;

  end;

  //93-context menu button
  if (Msg.wParam=93) then
  begin
   ListView1ContextPopup(ListView1,Point(-1,-1),b);
  end;

  //109-
  if (Msg.wParam=109) then ZoomIn; 
  //107+
  if (Msg.wParam=107) then ZoomOut;

  if (Msg.wParam=113) then if DBkernel.UserRights.FileOperationsCritical then If ((FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then begin popupmenu1.Tag:=ItemIndexToMenuIndex(ListView1Selected.Index); Rename1Click(nil); end;

  if (Msg.wParam=46) and ShiftKeyDown then if DBkernel.UserRights.FileOperationsCritical then begin DeleteFiles(False); Exit; end;
  if (Msg.wParam=46) then if DBkernel.UserRights.FileOperationsCritical then DeleteFiles(True);
  if (Msg.wParam=67) and CtrlKeyDown then if DBkernel.UserRights.FileOperationsNormal then Copy3Click(Nil);
  if (Msg.wParam=88) and CtrlKeyDown then if DBkernel.UserRights.FileOperationsCritical then Cut3Click(Nil);
  if (Msg.wParam=86) and CtrlKeyDown then if DBkernel.UserRights.FileOperationsNormal then Paste3Click(Nil);
  if (Msg.wParam=65) and CtrlKeyDown then SelectAll1Click(nil);

 //  if (Msg.wParam=13) and AltKeyDown then Properties1Click(Nil);
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

procedure TExplorerForm.Edit2Click(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
  Index : Integer;
begin
 Back1.Enabled:=fHistory.CanBack;
 If AnsiLowerCase(GetCurrentPath)=AnsiLowerCase(MyComputer) then
 Back1.Enabled:=false;
 Forward1.Enabled:=fHistory.CanForward;
 Files:=TStringList.Create;
 LoadFIlesFromClipBoard(Effects,Files);
 if Files.Count<>0 then Paste3.Enabled:=true else Paste3.Enabled:=false;
 Files.free;
 If SelCount=0 then Paste3.Visible:=True else
 begin
  If SelCount=1 then
  begin
   Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
   If (FFilesInfo[Index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) then
   Paste3.Visible:=True else Paste3.Visible:=false;
  end else
  Paste3.Visible:=False;
 end;
 Cut3.Visible:=DBKernel.UserRights.FileOperationsCritical;
 Copy3.Visible:=DBKernel.UserRights.FileOperationsNormal;
 Paste3.Visible:=DBKernel.UserRights.FileOperationsNormal;
 Up1.Enabled:=ToolButton3.Enabled;
end;

procedure TExplorerForm.DeleteItemWithIndex(Index: Integer);
var j:integer;
    MenuIndex : integer;
begin
  LockItems;
  try
    MenuIndex:=ItemIndexToMenuIndex(Index);
    ListView1.Items.Delete(Index);
    for j:=MenuIndex to Length(fFilesInfo)-2 do
    fFilesInfo[j]:=fFilesInfo[j+1];
    setlength(fFilesInfo,Length(fFilesInfo)-1);
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
 for i:=0 to listview1.Items.Count-1 do
 begin
  if i>listview1.Items.Count-1 then break;
  if listview1.Items[i].Selected then
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
 if not IsEqualGUID(SID, CurrentGUID) then Exit;
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
    ExplorerViewInfo.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
    ExplorerViewInfo.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
    ExplorerViewInfo.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
    ExplorerViewInfo.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
    ExplorerViewInfo.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
    ExplorerViewInfo.View:=ListView;
    ExplorerViewInfo.PictureSize:=fPictureSize;
    RegisterThreadAndStart(TExplorerThread.Create(true,'',SupportedExt,0,ExplorerViewInfo,Self,UpdaterInfo,CurrentGUID));
   end;
  end;
 FILE_ACTION_REMOVED:
  begin
   if ListView1=nil then exit;
   if ListView1.Items=nil then exit;
   for i:=0 to ListView1.Items.Count-1 do
   begin
    index:=ItemIndexToMenuIndex(i);
    if index>Length(fFilesInfo)-1 then exit;
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
   if ListView1=nil then exit;
   if ListView1.Items=nil then exit;
   for i:=0 to ListView1.Items.Count-1 do
   begin
    index:=ItemIndexToMenuIndex(i);
    if index>Length(fFilesInfo)-1 then exit;
    If AnsiLowerCase(fFilesInfo[index].FileName)=AnsiLowerCase(pInfo[k].FOldFileName) then
    begin
     If (not DirectoryExists(pInfo[k].FOldFileName) and DirectoryExists(pInfo[k].FNewFileName)) or (not FileExists(pInfo[k].FOldFileName) and FileExists(pInfo[k].FNewFileName)) then
     begin
      ListView1.Items[i].Caption:=GetFileName(pInfo[k].FNewFileName);
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
      ListView1SelectItem(ListView1,ListView1Selected,ListView1Selected=nil);
     end else RenamefileWithDB(pInfo[k].FOldFileName,pInfo[k].FNewFileName, fFilesInfo[index].ID,true);
     Continue;
    end;
   end;
  end;
 end;  
end;

Procedure TExplorerForm.LoadInfoAboutFiles(Info : TExplorerFilesInfo; SID : TGUID);
var
  i, n :Integer;
begin
 If IsEqualGUID(SID, CurrentGUID) then
 begin
  n:=Length(fFilesInfo);
  SetLength(fFilesInfo,Length(Info)+n);
  For i:=0 to Length(Info)-1 do
  begin
   fFilesInfo[i+n]:=Info[i];
  end;
 end;
end;

Procedure TExplorerForm.AddInfoAboutFile(Info : TExplorerFilesInfo; SID : TGUID);
var
  i:Integer;
  b : Boolean;
begin
 If IsEqualGUID(SID, CurrentGUID) then
 begin
  b:=false;
  For i:=0 to Length(fFilesInfo)-1 do
  if fFilesInfo[i].FileName=Info[0].FileName then
  begin
   B:=true;
   break;
  end;
  If not b then
  begin
   SetLength(fFilesInfo,Length(fFilesInfo)+1);
   fFilesInfo[Length(fFilesInfo)-1]:=Info[0];
  end;
 end;
end;

function TExplorerForm.FileNeeded(FileSID : TGUID) : Boolean;
var
  i:Integer;
begin
  Result := False;
  for i := 0 to Length(fFilesInfo) - 1 do
    if IsEqualGUID(fFilesInfo[i].SID, FileSID) then
    begin
      Result := True;
      Break;
    end;
end;

function TExplorerForm.FileNeededW(FileSID : TGUID) : Boolean;
var
  i : Integer;
begin
  Result := false;
  for i := 0 to Length(fFilesInfo) - 1 do
  If IsEqualGUID(fFilesInfo[i].SID, FileSID) then
  begin
    if not fFilesInfo[i].IsBigImage then
      Result := True;
    Break;
  end;
end;

function TExplorerForm.ItemIndexToMenuIndex(Index: Integer): Integer;
Var
  i, n : Integer;
begin
 Result:=0;
 n:=ListView1.Items[Index].ImageIndex;
 For i:=0 to Length(fFilesInfo)-1 do
 begin
  If fFilesInfo[i].ImageIndex=n then
  begin
   Result:=i;
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
 For i:=0 to ListView1.Items.Count-1 do
 begin
  If ListView1.Items[i].ImageIndex=n then
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
 ListView1.SetFocus;
end;

procedure TExplorerForm.NewWindow1Click(Sender: TObject);
var
  Path : TExplorerPath;
begin
 Path:=ExplorerPath(fFilesInfo[popupmenu1.tag].FileName,fFilesInfo[popupmenu1.tag].FileType);
 With Explorermanager.NewExplorer do
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
  CopyFiles(Handle,S,GetCurrentPath,True,_AutoRename,CorrectPath,self);
  inc(CopyInstances);
  ClipBoard.Clear;
  ToolButton7.Enabled:=false;
 end;
 if (Effects= DROPEFFECT_COPY) or (Effects= DROPEFFECT_COPY+DROPEFFECT_LINK) or (Effects= DROPEFFECT_NONE) then CopyFiles(Handle,S,GetCurrentPath,false,_AutoRename);

end;

procedure TExplorerForm.PopupMenu2Popup(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
begin
 ShowUpdater1.Visible:=DBKernel.UserRights.Add;
 Addfolder1.Visible:=DBKernel.UserRights.Add;
 OpeninSearchWindow1.Visible:=True;
 Files:=TStringList.Create;
 LoadFIlesFromClipBoard(Effects,Files);
 if Files.Count<>0 then Paste1.Enabled:=true else Paste1.Enabled:=false;
 Files.free;
 Paste1.Visible:=DBKernel.UserRights.FileOperationsNormal;
 Cut1.Visible:=DBKernel.UserRights.FileOperationsCritical;
 Copy2.Visible:=DBKernel.UserRights.FileOperationsNormal;
 MakeNew1.Visible:=DBKernel.UserRights.FileOperationsNormal;

 MakeFolderViewer1.Visible:=((GetCurrentPathW.PType=EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType=EXPLORER_ITEM_DRIVE)) and not FolderView and DBkernel.UserRights.FileOperationsCritical;

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
 MakeNew1.Visible:=MakeNew1.Visible and DBkernel.UserRights.FileOperationsNormal;
 OpeninSearchWindow1.Visible:=OpeninSearchWindow1.Visible and DBkernel.UserRights.ShowPath;
end;

procedure TExplorerForm.Cut2Click(Sender: TObject);
Var
  i, index : integer;
  File_List : TStrings;
begin
  File_List:=TStringList.Create;
 For i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  Index:=ItemIndexToMenuIndex(i);
  File_List.Add(ProcessPath(fFilesInfo[index].FileName));
 end;
 Copy_Move(false,File_List);
 File_List.Free;
end;

procedure TExplorerForm.HideProgress(SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
 fStatusProgress.Hide;
end;

procedure TExplorerForm.SetProgressMax(Value: Integer; SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
 fStatusProgress.Max:=Value;
end;

procedure TExplorerForm.SetProgressPosition(Value: Integer; SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
 fStatusProgress.Position:=Value;
end;

procedure TExplorerForm.SetProgressText(Text: string; SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
end;

procedure TExplorerForm.SetStatusText(Text: string; SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
 StatusBar1.Panels[0].Text:=Text;
end;

procedure TExplorerForm.ShowProgress(SID: TGUID);
begin
 If IsEqualGUID(SID, CurrentGUID) then
   fStatusProgress.Show;
end;

procedure TExplorerForm.Button1Click(Sender: TObject);
begin
 FIsExplorer:=false;
 ListView1SelectItem(Sender,ListView1Selected,true);
 PropertyPanel.Show;
 CloseButtonPanel.Hide;                 
 DBkernel.WriteInteger('Explorer','LeftPanelWidthExplorer',MainPanel.Width);
 MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidth',135);
 ExplorerPanel1.Visible:=True;
 InfoPanel1.Visible:=False;
 ListView1SelectItem(Sender,ListView1Selected,false);
end;

procedure TExplorerForm.SetPanelImage(Image: TBitmap; FileGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    Image1.Picture.Bitmap.Assign(Image);
    Image1.Refresh;
  end;
end;

procedure TExplorerForm.SetPanelInfo(Info: TOneRecordInfo;
  FIleGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    FSelectedInfo.Width:=Info.ItemWidth;
    FSelectedInfo.Height:=Info.ItemHeight;
    FSelectedInfo.Id:=Info.ItemId;
    FSelectedInfo.Rating:=Info.ItemRating;
    FSelectedInfo.Access:=Info.ItemAccess;
    ReallignInfo;
  end;
end;

procedure TExplorerForm.Image1ContextPopup(Sender: TObject;
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
  loadingthitem:= nil;
  Application.HideHint;
  if ImHint<>nil then
  ImHint.close;
  If (fFilesInfo[Item.Index].Access=db_access_private) and not DBKernel.UserRights.ShowPrivate then exit;
  popupmenu1.Tag:=ItemIndexToMenuIndex(Item.Index);
  popupmenu1.Popup(Image1.clienttoscreen(MousePos).X ,Image1.clienttoscreen(MousePos).y);
 end else begin
  popupmenu2.Popup(Image1.clienttoscreen(MousePos).X ,Image1.clienttoscreen(MousePos).y);
 end;
end;

procedure TExplorerForm.PropertyPanelResize(Sender: TObject);
begin
  ReallignInfo;
end;

procedure TExplorerForm.ReallignToolInfo;
begin
 VerifyPaste(self);

 ToolButton5.Visible:=DBKernel.UserRights.FileOperationsCritical;
 ToolButton6.Visible:=DBKernel.UserRights.FileOperationsNormal;
 ToolButton8.Visible:=DBKernel.UserRights.FileOperationsCritical;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) and DBkernel.UserRights.FileOperationsNormal then
 begin
  if SelCount<>0 then
  ToolButton6.Enabled:=true else
  ToolButton6.Enabled:=false;
 end else
 begin
  ToolButton6.Enabled:=false;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) and DBkernel.UserRights.FileOperationsCritical then
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

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) and DBkernel.UserRights.FileOperationsCritical then
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

 ToolButton5.Visible:=DBKernel.UserRights.FileOperationsCritical;
 ToolButton6.Visible:=DBKernel.UserRights.FileOperationsNormal;
 ToolButton8.Visible:=DBKernel.UserRights.FileOperationsCritical;
// SelCount:=SelCount;
 LockWindowUpdate(self.Handle);
 s:=GetFileName(FSelectedInfo.FileName)+' ';
 For i:=Length(s) downto 1 do
 if s[i]='&' then Insert('&',S,i);

 NameLabel.Caption:=S;
 NameLabel.Constraints.MaxWidth:=ScrollBox1.Width-ScrollBox1.Left-otstup-ScrollBox1.VertScrollBar.ButtonSize;
 NameLabel.Constraints.MinWidth:=ScrollBox1.Width-ScrollBox1.Left-otstup-ScrollBox1.VertScrollBar.ButtonSize;
 S:=GetFileName(FSelectedInfo.FileName);
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

 If (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and (SelCount=1) and DBKernel.UserRights.EditImage then
 begin
  ImageEditorLink.Visible:=true;
  ImageEditorLink.Top:=SlideShowLink.Top+SlideShowLink.Height+h;
 end else
 begin
  ImageEditorLink.Visible:=false;
  ImageEditorLink.Top:=SlideShowLink.Top;
 end;

 If (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and DBkernel.UserRights.Print then
 begin
  PrintLink.Visible:=true;
  PrintLink.Top:=ImageEditorLink.Top+ImageEditorLink.Height+h;
 end else
 begin
  PrintLink.Visible:=false;
  PrintLink.Top:=ImageEditorLink.Top;
 end;


 If (((((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) and DBkernel.UserRights.Execute) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) And (SelCount=1)) then
 begin
  ShellLink.Visible:=true;
  ShellLink.Top:=PrintLink.Top+PrintLink.Height+h;
 end else
 begin
  ShellLink.Visible:=false;
  ShellLink.Top:=PrintLink.Top;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) and DBkernel.UserRights.FileOperationsNormal then
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

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) and DBkernel.UserRights.FileOperationsCritical then
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

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) And (SelCount<>0) and DBkernel.UserRights.FileOperationsCritical  then
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

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) and DBkernel.UserRights.FileOperationsCritical then
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

 if ListView1.Items.Count<400 then
 begin
  if ((FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE)) and (SelCount=0) then
  begin
   b:=true;
  end else
  begin
   b:=false;
   if Length(fFilesInfo)<>0 then
   For i:=0 to ListView1.Items.Count-1 do
   if ListView1.Items[i].Selected then
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

 If b and DBkernel.UserRights.Add then
 begin
  If SelCount=1 then AddLink.Text:=TEXT_MES_ADD_OBJECT;
  If SelCount>1 then AddLink.Text:=TEXT_MES_ADD_OBJECTS;
  if (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (SelCount=0) then
  begin
   AddLink.Icon:=(UnitDBKernel.icons[DB_IC_ADD_FOLDER+1]);
  end;
  if (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and (SelCount<>0) then
  begin
   AddLink.Icon:=(UnitDBKernel.icons[DB_IC_ADD_SINGLE_FILE+1]);
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
  For i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if ((fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) and DBkernel.UserRights.FileOperationsCritical) or (fFilesInfo[index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_EXEFILE) then
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
 If Length(s)=1 then DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_COPY_ONE,[GetFileName(S[0])]) else
 DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_COPY_MANY,[inttostr(Length(s))]);

 EndDir:=UnitDBFileDialogs.DBSelectDir(Handle,DlgCaption,Dolphin_DB.UseSimpleSelectFolderDialog);

{ _Break:=false;
 _AutoRename:=AutoRename(S,EndDir,_Break);
 if _Break then Exit;}

 If EndDir<>'' then
 CopyFiles(Self.Handle,S,EndDir,false,_AutoRename);
end;

procedure TExplorerForm.MoveToLinkClick(Sender: TObject);
var
  EndDir : String;
  i, index : integer;
  S : Array of String;
  DlgCaption : String;  
//  _AutoRename, _Break : boolean;
begin
 if not DBkernel.UserRights.FileOperationsCritical then exit;
 SetLength(S,0);
 If SelCount<>0 then
 begin
  For i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
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
 If Length(s)=1 then DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_MOVE_ONE,[GetFileName(S[0])]) else
 DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_MOVE_MANY,[inttostr(Length(s))]);

 EndDir:=UnitDBFileDialogs.DBSelectDir(Handle,DlgCaption,Dolphin_DB.UseSimpleSelectFolderDialog);
 If EndDir<>'' then
 begin
{  _AutoRename:=AutoRename(S,EndDir,_Break);
  if _Break then Exit;
           
  _Break:=false; }
  CopyFiles(Self.Handle,S,EndDir,True,_AutoRename,CorrectPath,self);
  inc(CopyInstances);
 end;
end;

procedure TExplorerForm.Paste2Click(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
  i : Integer;
  S : array of String; 
//  _AutoRename, _Break : boolean;
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

{ _Break:=false;
 _AutoRename:=AutoRename(S,fFilesInfo[popupmenu1.tag].FileName,_Break);
 if _Break then Exit;   }

 if Effects= DROPEFFECT_MOVE then
 begin
  CopyFiles(Handle,S,fFilesInfo[popupmenu1.tag].FileName,True,_AutoRename,CorrectPath,self);
  inc(CopyInstances);
  ClipBoard.Clear;
  ToolButton7.Enabled:=false;
 end;
 if (Effects= DROPEFFECT_COPY) or (Effects= DROPEFFECT_COPY+DROPEFFECT_LINK) or (Effects= DROPEFFECT_NONE) then CopyFiles(Handle,S,fFilesInfo[popupmenu1.tag].FileName,False,_AutoRename);
end;

procedure TExplorerForm.ExplorerPanel1Click(Sender: TObject);
var
  s : String;
begin
 if not ShellTreeView1.UseShellImages then
 begin                                        
  ShellTreeView1.UseShellImages:=true;
  ShellTreeView1.ObjectTypes:=[otFolders,otHidden];
  ShellTreeView1.Refresh(ShellTreeView1.TopItem);
 end;
 PropertyPanel.Hide;
 try
  if GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER then
  ShellTreeView1.Path:='C:\';
  if (GetCurrentPathW.PType=EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType=EXPLORER_ITEM_DRIVE) or (GetCurrentPathW.PType=EXPLORER_ITEM_COMPUTER) or (GetCurrentPathW.PType=EXPLORER_ITEM_SHARE) then
  begin
   s:=GetCurrentPath;
   if Length(s)=2 then
   FormatDir(s);
   ShellTreeView1.Path:=s;
  end;
  If GetCurrentPathW.PType=EXPLORER_ITEM_NETWORK then
  ShellTreeView1.Path:='C:\';
  If GetCurrentPathW.PType=EXPLORER_ITEM_WORKGROUP then
  ShellTreeView1.Path:='C:\';
 except
 end;
 FIsExplorer:=True;
 CloseButtonPanel.Show;
 MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidthExplorer',135);
 ExplorerPanel1.Visible:=False;
 InfoPanel1.Visible:=True;
end;

{ TManagerExplorer }

procedure TManagerExplorer.LoadEXIF;
begin
 fShowEXIF:=DBKernel.ReadBool('Options','ShowEXIFMarker',false);
end;

procedure TManagerExplorer.AddExplorer(Explorer: TExplorerForm);
var
  i : integer;
  b : boolean;
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
    If IsEqualGUID(TExplorerForm(FExplorers[i]).CurrentGUID, StringToGUID(SID)) then
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

function TManagerExplorer.NewExplorer: TExplorerForm;
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
  Application.CreateForm(TExplorerForm, Result);
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

procedure TExplorerForm.Image1DblClick(Sender: TObject);
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
  R : TRect;
begin
 if ImHint=nil then Exit;
 R:=rect(ImHint.left,ImHint.top,ImHint.left+ImHint.width, ImHint.top+ImHint.height);
 GetCursorPos(p);
 if PtInRect(r,p) then
 begin
  Exit;
 end;
 LoadingthItem:= nil;
 Application.HideHint;
 ImHint.Close;
 hinttimer.Enabled:=false;
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
 if DBkernel.UserRights.ShowOptions then
 begin
  if OptionsForm=nil then
  Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.show;
 end;
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
  Dolphin_db.DeleteFiles( Self.Handle, S , True );
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
  PopupMenu1.Tag:=index;
  if index>Length(fFilesInfo)-1 then exit;
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
  Popupmenu1.Tag:=ItemIndexToMenuIndex(ListView1Selected.Index);
  SlideShow1Click(Sender)
 end else
 begin
  if Viewer=nil then Application.CreateForm(TViewer, Viewer);
  Viewer.ShowFolderA(GetCurrentPath,ExplorerManager.ShowPrivate);
 end;
end;

procedure TExplorerForm.Tools1Click(Sender: TObject);
begin
 ShowUpdater2.Visible:=DBKernel.UserRights.Add;
 DBManager1.Visible:=DBKernel.UserRights.ShowAdminTools;
 ImageEditor1.Visible:=DBKernel.UserRights.EditImage;
 GroupManager1.Visible:=DBKernel.UserRights.ShowOptions;

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

procedure TExplorerForm.View1Click(Sender: TObject);
begin
 ExplorerPanel1.Visible:=ExplorerPanel1.Visible and DBkernel.UserRights.ShowPath;
 ShowOnlyCommon1.Visible:=ExplorerManager.ShowPrivate and DBkernel.UserRights.ShowPrivate;
 ShowPrivate1.Visible:=not ExplorerManager.ShowPrivate and DBkernel.UserRights.ShowPrivate;
end;

procedure TExplorerForm.ShowOnlyCommon1Click(Sender: TObject);
begin
 ExplorerManager.ShowPrivate:=false;
end;

procedure TExplorerForm.ShowPrivate1Click(Sender: TObject);
begin
 if DBkernel.UserRights.ShowPrivate then
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
 Label1.Caption:=TEXT_MES_IMAGE_PRIVIEW;
 SlideShowLink.Text:= TEXT_MES_SLIDE_SHOW;
 ShellLink.Text:= TEXT_MES_OPEN;
 CopyToLink.Text:= TEXT_MES_COPY_TO;
 MoveToLink.Text:= TEXT_MES_MOVE_TO;
 RenameLink.Text:= TEXT_MES_RENAME;
 PropertiesLink.Text:= TEXT_MES_PROPERTY;
 DeleteLink.Text:= TEXT_MES_DELETE;
 TasksLabel.Caption:= TEXT_MES_TASKS;
 Open1.Caption:= TEXT_MES_OPEN;
 Open2.Caption:= TEXT_MES_OPEN;
 SlideShow1.Caption:= TEXT_MES_SHOW;;
 NewWindow1.Caption:= TEXT_MES_NEW_WINDOW;
 Shell1.Caption:= TEXT_MES_SHELL;
 DBitem1.Caption:= TEXT_MES_DBITEM;
 Copy1.Caption:= TEXT_MES_COPY;
 Cut2.Caption:= TEXT_MES_CUT;
 Paste2.Caption:= TEXT_MES_PASTE;
 Delete1.Caption:= TEXT_MES_DELETE;
 Rename1.Caption:= TEXT_MES_RENAME;
 New1.Caption:= TEXT_MES_NEW;
 Directory1.Caption:= TEXT_MES_DIRECTORY;
 Refresh1.Caption:= TEXT_MES_REFRESH;
 Properties1.Caption:= TEXT_MES_PROPERTY;
 AddFile1.Caption:= TEXT_MES_ADD_FILE;
 OpenInNewWindow1.Caption:= TEXT_MES_OPEN_IN_NEW_WINDOW;
 OpenInNewWindow2.Caption:= TEXT_MES_OPEN_IN_NEW_WINDOW;
 Copy2.Caption:= TEXT_MES_COPY;
 Cut1.Caption:= TEXT_MES_CUT;
 Paste1.Caption:= TEXT_MES_PASTE;
 Addfolder1.Caption:= TEXT_MES_ADD_FOLDER;
 MakeNew1.Caption:= TEXT_MES_MAKE_NEW;


 Directory2.Caption:= TEXT_MES_MAKE_NEW_FOLDER;
 TextFile2.Caption:= TEXT_MES_MAKE_NEW_TEXT_FILE;

 ShowUpdater1.Caption:= TEXT_MES_SHOW_UPDATER;
 OpeninSearchWindow1.Caption:= TEXT_MES_OPEN_IN_SEARCH_WINDOW;
 Refresh2.Caption:= TEXT_MES_REFRESH;
 SelectAll1.Caption:= TEXT_MES_SELECT_ALL;
 GoToSearchWindow1.Caption:= TEXT_MES_GO_TO_SEARCH_WINDOW;
 Exit2.Caption:= TEXT_MES_EXIT;
 File1.Caption:= TEXT_MES_FILE;
 Shell2.Caption:= TEXT_MES_SHELL;
 SlideShow2.Caption:= TEXT_MES_SLIDE_SHOW;
 NewWindow2.Caption:= TEXT_MES_NEW_WINDOW;
 Exit1.Caption:= TEXT_MES_EXIT;
 Edit2.Caption:= TEXT_MES_EDIT;
 Back1.Caption:= TEXT_MES_BACK;
 Forward1.Caption:= TEXT_MES_FORWARD;
 Up1.Caption:= TEXT_MES_UP;
 Copy3.Caption:= TEXT_MES_COPY;
 Cut3.Caption:= TEXT_MES_CUT;
 Paste3.Caption:= TEXT_MES_PASTE;
 SelectAll2.Caption:= TEXT_MES_SELECT_ALL;
 View1.Caption:= TEXT_MES_VIEW;
 ExplorerPanel1.Caption:= TEXT_MES_SHOW_EXPLORER_PANEL;
 InfoPanel1.Caption:= TEXT_MES_SHOW_INFO_PANEL;
 ShowFolders1.Caption:= TEXT_MES_SHOW_FOLDERS;
 ShowFiles1.Caption:= TEXT_MES_SHOW_FILES;
 ShowHidden1.Caption:= TEXT_MES_SHOW_HIDDEN;
 ShowOnlyCommon1.Caption:= TEXT_MES_SHOW_ONLY_COMMON;
 ShowPrivate1.Caption:= TEXT_MES_SHOW_PRIVATE;
 Tools1.Caption:= TEXT_MES_TOOLS;
 ShowUpdater2.Caption:= TEXT_MES_SHOW_UPDATER;
 DBManager1.Caption:= TEXT_MES_SHOW_DB_MANAGER;
 Searching1.Caption:= TEXT_MES_SEARCHING;
 Options1.Caption:= TEXT_MES_OPTIONS;
// NO LABEL  ToolButton1.Caption:=TEXT_MES_BACK;
// NO LABEL ToolButton3.Caption:=TEXT_MES_UP;
 Help1.Caption:=TEXT_MES_HELP;
 OpeninExplorer1.Caption:=TEXT_MES_OPEN_IN_EXPLORER;
 OpeninExplorer1.Caption:=TEXT_MES_OPEN_IN_EXPLORER;
 AddFolder2.Caption:=TEXT_MES_ADD_FOLDER;
// NO LABEL ToolButton2.Caption:=TEXT_MES_FORWARD;
 ToolButton5.Caption:=TEXT_MES_CUT;
 ToolButton6.Caption:=TEXT_MES_COPY;
 ToolButton7.Caption:=TEXT_MES_PASTE;
// NO LABEL  ToolButton8.Caption:=TEXT_MES_DELETE;
 ToolButton19.Caption:=TEXT_MES_OPTIONS;
 RefreshLink.Text:=TEXT_MES_REFRESH;
 Label2.Caption:=TEXT_MES_ADDRESS;
 Help2.Caption:=TEXT_MES_HELP;
 Activation1.Caption:=TEXT_MES_ACTIVATION;
 About1.Caption:=TEXT_MES_ABOUT;
 HomePage1.Caption:=TEXT_MES_HOME_PAGE;
 ContactWithAuthor1.Caption:=TEXT_MES_CONTACT_WITH_AUTHOR;
 CryptFile1.Caption:=TEXT_MES_CRYPT_FILE;
 ResetPassword1.Caption:=TEXT_MES_DECRYPT_FILE;
 EnterPassword1.Caption:=TEXT_MES_ENTER_PASSWORD;
 Convert1.Caption:=TEXT_MES_CONVERT;
 Resize1.Caption:=TEXT_MES_RESIZE;
 Rotate1.Caption:=TEXT_MES_ROTATE_IMAGE;
 RotateCCW1.Caption:=TEXT_MES_ROTATE_270;
 RotateCW1.Caption:=TEXT_MES_ROTATE_90;
 Rotateon1801.Caption:=TEXT_MES_ROTATE_180;
 GroupManager1.Caption:=TEXT_MES_GROUPS_MANAGER;
 SetasDesktopWallpaper1.Caption:=TEXT_MES_SET_AS_DESKTOP_WALLPAPER;
 Stretch1.Caption:=TEXT_MES_BY_STRETCH;
 Center1.Caption:=TEXT_MES_BY_CENTER;
 Tile1.Caption:=TEXT_MES_BY_TILE;
 RefreshID1.Caption:=TEXT_MES_REFRESH_ID;
 GetUpdates1.Caption:=TEXT_MES_GET_UPDATING;
 DBInfoLabel.Caption:=TEXT_MES_DB_INFO;
 ImageEditor1.Caption:=TEXT_MES_IMAGE_EDITOR_W;
 ImageEditor2.Caption:=TEXT_MES_IMAGE_EDITOR;
 ImageEditorLink.Text:=TEXT_MES_IMAGE_EDITOR;

 Othertasks1.Caption:=TEXT_MES_OTHER_TASKS;
 ExportImages1.Caption:=TEXT_MES_EXPORT_IMAGES;
 PrintLink.Text:=TEXT_MES_PRINT;
 Print1.Caption:=TEXT_MES_PRINT;

 OtherPlacesLabel.Caption:=TEXT_MES_OTHER_PLACES;
 MyPicturesLink.Text:=TEXT_MES_MY_PICTURES;
 MyDocumentsLink.Text:=TEXT_MES_MY_DOCUMENTS;
 DesktopLink.Text:=TEXT_MES_DESKTOP;
 MyComputerLink.Text:=TEXT_MES_MY_COMPUTER;

 TextFile1.Caption:=TEXT_MES_NEW_TEXT_FILE;
 GetPhotosFromDrive1.Caption:=TEXT_MES_GET_PHOTOS;
 Copywithfolder1.Caption:=TEXT_MES_COPY_WITH_FOLDER;

 Copy4.Caption:=TEXT_MES_COPY;
 Move1.Caption:=TEXT_MES_MOVE;
 Cancel1.Caption:=TEXT_MES_CANCEL;
 NewPanel1.Caption:=TEXT_MES_NEW_PANEL;

 RemovableDrives1.Caption:=TEXT_MES_REMOVABLE_DRIVES;
 CDROMDrives1.Caption:=TEXT_MES_CD_ROM_DRIVES;
 SpecialLocation1.Caption:=TEXT_MES_SPECIAL_LOCATION;

 SendTo1.Caption:=TEXT_MES_SEND_TO;
 View2.Caption:=TEXT_MES_SLIDE_SHOW;

 Sortby1.Caption:=SORT_BY;

 Nosorting1.Caption:=SORT_BY_NO_SORTING;
 FileName1.Caption:=SORT_BY_FILENAME;
 Size1.Caption:=SORT_BY_SIZE;
 Type1.Caption:=SORT_BY_TYPE;
 Modified1.Caption:=SORT_BY_MODIFIED;
 Rating1.Caption:=SORT_BY_RATING;
 Number1.Caption:=SORT_BY_NUMBER;
 SetFilter1.Caption:=SORT_BY_SET_FILTER;

 MakeFolderViewer1.Caption:=TEXT_MES_MAKE_FOLDERVIEWER;
 MakeFolderViewer2.Caption:=TEXT_MES_MAKE_FOLDERVIEWER;

 Thumbnails1.Caption:=TEXT_MES_VIEW_THUMBNAILS;
 Tile2.Caption:=TEXT_MES_VIEW_TILE;
 Icons1.Caption:=TEXT_MES_VIEW_ICONS;
 SmallIcons1.Caption:=TEXT_MES_VIEW_LIST2;
 List1.Caption:=TEXT_MES_VIEW_LIST;

 Thumbnails2.Caption:=TEXT_MES_VIEW_THUMBNAILS;
 Tile3.Caption:=TEXT_MES_VIEW_TILE;
 Icons2.Caption:=TEXT_MES_VIEW_ICONS;
 SmallIcons2.Caption:=TEXT_MES_VIEW_LIST2;
 List2.Caption:=TEXT_MES_VIEW_LIST;

// NO CAPTION ToolButtonView.Caption:=TEXT_MES_VIEW;
 View3.Caption:=TEXT_MES_VIEW;      
 AddLink.Text:=TEXT_MES_ADD_OBJECT;

 StenoGraphia1.Caption:=TEXT_MES_STENOGRAPHIA;
 AddHiddenInfo1.Caption:=TEXT_MES_DO_STENO;
 ExtractHiddenInfo1.Caption:=TEXT_MES_DO_DESTENO;

 MapCD1.Caption:=TEXT_MES_ADD_CD_LOCATION;

 ToolButton1.Hint:=TEXT_MES_GO_BACK;
 ToolButton2.Hint:=TEXT_MES_GO_FORWARD;
 ToolButton3.Hint:=TEXT_MES_GO_UP;
 ToolButton5.Hint:=TEXT_MES_CUT;
 ToolButton6.Hint:=TEXT_MES_COPY;
 ToolButton7.Hint:=TEXT_MES_PASTE;
 ToolButton8.Hint:=TEXT_MES_DELETE;
 ToolButtonView.Hint:=TEXT_MES_VIEW;
 ToolButton13.Hint:=TEXT_MES_ZOOM_IN;
 ToolButton14.Hint:=TEXT_MES_ZOOM_OUT;
 ToolButton15.Hint:=TEXT_MES_GO_TO_SEARCH_WINDOW;
 ToolButton18.Hint:=TEXT_MES_STOP;
 ToolButton19.Hint:=TEXT_MES_OPTIONS;

end;

procedure TExplorerForm.Help1Click(Sender: TObject);
begin
 if AboutForm = nil then
 Application.CreateForm(TAboutForm,AboutForm);
 AboutForm.Execute;
end;

procedure TExplorerForm.PopupMenu8Popup(Sender: TObject);
begin
 if ShellTreeView1.SelectedFolder<>nil then
 begin
  TempFolderName:=ShellTreeView1.SelectedFolder.PathName;
  OpeninExplorer1.Visible:=DirectoryExists(TempFolderName);
  AddFolder2.Visible:=OpeninExplorer1.Visible and DBkernel.UserRights.Add;
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
 With ExplorerManager.NewExplorer do
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
 fDBCanDrag:=false;
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
  if DBKernel.UserRights.ShowPath then
  begin
   Caption:=MyComputer
  end else
  begin
   Caption:=ProductName;
  end;
  Edit1.text:=MyComputer;
  ThreadType:=THREAD_TYPE_MY_COMPUTER;
 end;
 If (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 begin
  S:=Path;
  UnFormatDir(s);
  if DBKernel.UserRights.ShowPath then
  Caption:=S else Caption:=ProductName;
  Edit1.text:=Path;
 end;
 If WPath.PType=EXPLORER_ITEM_NETWORK then
 begin
  if DBKernel.UserRights.ShowPath then
  Caption:=Path else Caption:=ProductName;
  Edit1.text:=Path;
  ThreadType:=THREAD_TYPE_NETWORK;
 end;
 If WPath.PType=EXPLORER_ITEM_WORKGROUP then
 begin
  if DBKernel.UserRights.ShowPath then
  Caption:=Path else Caption:=ProductName;
  Edit1.text:=Path;
  ThreadType:=THREAD_TYPE_WORKGROUP;
 end;
 If WPath.PType=EXPLORER_ITEM_COMPUTER then
 begin
  if DBKernel.UserRights.ShowPath then
  Caption:=Path else Caption:=ProductName;
  Edit1.text:=Path;
  ThreadType:=THREAD_TYPE_COMPUTER;
 end;
 S := Path;
 CurrentGUID:=GetGUID;
 if ListView1<>nil then
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
   DirectoryWatcher.Start(s,self,CurrentGUID);
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
 ToolButton3.Enabled:=ToolButton3.Enabled and DBKernel.UserRights.ShowPath;
 Setlength(fFilesInfo,0);
 try
  SelectTimer.Enabled:=false;

  if ListView1<>nil then
  begin
   ListView1.Items.Clear;
   ListView1.Groups.Add;
  end;   

  DoSelectItem;
  FBitmapImageList.Clear;
 except
 end;
 Info.OldFolderName:=FOldPatch;
 info.ShowPrivate:=DBkernel.UserRights.SetPrivate and ExplorerManager.ShowPrivate;  
 Info.PictureSize:=fPictureSize;
 BeginUpdate(CurrentGUID);

  if ListView1<>nil then
  Case ListView of
   LV_THUMBS     : begin ListView1.View:=elsThumbnail; end;
   LV_ICONS      : begin ListView1.View:=elsIcon; end;
   LV_SMALLICONS : begin ListView1.View:=elsSmallIcon; end;
   LV_TITLES     : begin ListView1.View:=elsList; end;
   LV_TILE       : begin ListView1.View:=elsTile; end;
   LV_GRID       : begin ListView1.View:=elsGrid; end;
  end;

 UpdaterInfo.IsUpdater:=false;
 Inc(FReadingFolderNumber);
 If FReadingFolderNumber>MaxInt-1 then FReadingFolderNumber:=0;
 DBThreadManeger.TerminateThreads(Handle,Thread_Type_Explorer_Watching);

 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 EventLog('ExplorerThread');
 if ListView1<>nil then
 begin
  ToolButton18.Enabled:=true;
  RegisterThreadAndStart(TExplorerThread.Create(true,Path,FileMask,ThreadType,info,self,UpdaterInfo,CurrentGUID));
 end;
 if FIsExplorer then
 if not Explorer then
 if (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_COMPUTER) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 try
  s:=GetCurrentPath;
  if Length(s)=2 then FormatDir(S);
  ShellTreeView1.Path:=s;
  ShellTreeView1.Select(ShellTreeView1.Selected);// Scroll(ShellTreeView1.Selected.Left,ShellTreeView1.Selected.Top);
 except
 end;
 DropFileTarget1.Unregister;
 if (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 DropFileTarget1.Register(ListView1);
 
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
 fHistory.fposition:=n;
 HistoryChanged(Sender);
 SetNewPathW(fHistory.fArray[n],false);
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
  fDBCanDrag:=false;
  fDBCanDragW:=false;
  exit;
 end;
 if (fDBCanDrag or fDBCanDragW) and not rdown then
 if (smintL<>0) or (smintR<>0) then
 if (SelfDraging or outdrag) then
 begin

  GetCursorPos(p);
  p:=ListView1.ScreenToClient(p);
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
 if ActivateForm=nil then
 Application.CreateForm(TActivateForm,ActivateForm);
 ActivateForm.Execute;
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
 Password:=DBKernel.FindPasswordForCryptImageFile(ProcessPath(fFilesInfo[popupmenu1.tag].FileName));
 if Password='' then
 Password:=GetImagePasswordFromUser(ProcessPath(fFilesInfo[PopupMenu1.tag].FileName));

 Setlength(ItemFileNames,Length(fFilesInfo));
 Setlength(ItemIDs,Length(fFilesInfo));
 Setlength(ItemSelected,Length(fFilesInfo));

 //be default unchecked
 for i:=0 to Length(fFilesInfo)-1 do
 ItemSelected[i]:=false;

 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 TCryptingImagesThread.Create(false, Options);

end;

procedure TExplorerForm.CryptFile1Click(Sender: TObject);
var
 i, index : integer;
 Options : TCryptImageThreadOptions;
 Opt : TCryptImageOptions;
 CryptOptions : integer;
 ItemFileNames : TArStrings;
 ItemIDs : TArInteger;
 ItemSelected : TArBoolean;

begin
 Opt:=GetPassForCryptImageFile(ProcessPath(fFilesInfo[popupmenu1.tag].FileName));
 if Opt.SaveFileCRC then CryptOptions:=CRYPT_OPTIONS_SAVE_CRC else CryptOptions:=CRYPT_OPTIONS_NORMAL;
 if Opt.Password='' then exit;

 Setlength(ItemFileNames,Length(fFilesInfo));
 Setlength(ItemIDs,Length(fFilesInfo));
 Setlength(ItemSelected,Length(fFilesInfo));

 //be default unchecked
 for i:=0 to Length(fFilesInfo)-1 do
 ItemSelected[i]:=false;

 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 TCryptingImagesThread.Create(false, Options);
end;

procedure TExplorerForm.Addsessionpassword1Click(Sender: TObject);
begin
 AddSessionPassword;
end;

procedure TExplorerForm.EnterPassword1Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 if fFilesInfo[popupmenu1.tag].ID<>0 then
 begin
  EventInfo.Image:=nil;
  if GetImagePasswordFromUser(ProcessPath(fFilesInfo[popupmenu1.tag].FileName))<>'' then
  DBKernel.DoIDEvent(Sender,fFilesInfo[popupmenu1.tag].ID,[EventID_Param_Image],EventInfo);
 end else
 begin
  if GetImagePasswordFromUser(ProcessPath(fFilesInfo[popupmenu1.tag].FileName))<>'' then
  RefreshItemByName(ProcessPath(fFilesInfo[popupmenu1.tag].FileName));
 end;
end;

procedure TExplorerForm.Resize1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
 end;
 ResizeImages(ImageList,IDList);
end;

procedure TExplorerForm.Convert1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 FileName:=fFilesInfo[PopupMenu1.tag].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_STRETCH) else
 MessageBoxDB(Handle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TExplorerForm.Center1Click(Sender: TObject);
var
  FileName : string;
begin
 FileName:=fFilesInfo[PopupMenu1.tag].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_CENTER) else
 MessageBoxDB(Handle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);

end;

procedure TExplorerForm.Tile1Click(Sender: TObject);
var
  FileName : string;
begin
 FileName:=fFilesInfo[PopupMenu1.tag].FileName;
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
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_270);
end;


procedure TExplorerForm.RotateCW1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_90);
end;

procedure TExplorerForm.Rotateon1801Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_180);
end;

procedure TExplorerForm.RefreshID1Click(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
  ItemFileNames : TArStrings;
  ItemIDs : TArInteger;
  ItemSelected : TArBoolean;
  i, index : integer;
begin
 Setlength(ItemFileNames,Length(fFilesInfo));
 Setlength(ItemIDs,Length(fFilesInfo));
 Setlength(ItemSelected,Length(fFilesInfo));

 //be default unchecked
 for i:=0 to Length(fFilesInfo)-1 do
 ItemSelected[i]:=false;

 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 if not DBkernel.UserRights.FileOperationsNormal then exit;
 outdrag:=false;
 DropInfo:=DropFileTarget1.Files;

 if ssRight in LastShift then
 begin
  Move1.Visible:=not SelfDraging;
  fDBCanDragW:=false;
  fDBCanDrag:=false;
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


{   _Break:=false;
   _AutoRename:=AutoRename(S,GetCurrentPath,_Break);
   if _Break then Exit;       }

   if not ShiftKeyDown then
   CopyFiles(Handle,S,GetCurrentPath,false,_AutoRename) else
   begin
    CopyFiles(Handle,S,GetCurrentPath,true,_AutoRename,CorrectPath,self);
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

{    _Break:=false;
    _AutoRename:=AutoRename(S,Str,_Break);
    if _Break then Exit;    }

    if not ShiftKeyDown then
    CopyFiles(Handle,S,Str,ShiftKeyDown,_AutoRename) else
    begin
     CopyFiles(Handle,S,Str,ShiftKeyDown,_AutoRename,CorrectPath,self);
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
    CreateProcess(nil,PChar('"'+FFilesInfo[index].FileName+'"'+Params),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(Str),si,p);
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
 fDBCanDrag:=true;
end;

procedure TExplorerForm.DropFileTarget1Leave(Sender: TObject);
begin
  fDBCanDrag:=false;
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
 InitializeScript(fScript);
 fScript.Description:='Set path script';
 LoadBaseFunctions(fScript);
 LoadDBFunctions(fScript);
 AddAccessVariables(fScript);
 if DBkernel.UserRights.FileOperationsCritical then
 LoadFileFunctions(fScript);
 SetNamedValueStr(fScript,'$Path',Path);
 ExecuteScript(nil,fScript,ScriptString,c,nil);
 FinalizeScript(fScript);
 Path:=GetNamedValueString(fScript,'$Path');
 if Path=#8 then
 begin
  exit;
 end;
 s:=Path;
  If (s='') or (AnsiLowerCase(s)=AnsiLowerCase(MyComputer)) then
  begin
   Edit1.text:=MyComputer;
   SetNewPath(s,ChangeTreeView);
   Exit;
  end;
  If (AnsiLowerCase(s)=AnsiLowerCase(TEXT_MES_NETWORK)) then
  begin
   Edit1.text:=TEXT_MES_NETWORK;
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
    ShellExecute(0, Nil,Pchar(s), Nil, Nil, SW_NORMAL);
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
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_1,Point(0,0),ListView1,Help1NextClick,TEXT_MES_NEXT_HELP,Help1CloseClick);
 end;
 if HelpNO=2 then
 begin
  HelpTimer.Enabled:=false;
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_2,Point(0,0),AddLink,Help1NextClick,TEXT_MES_NEXT_HELP,Help1CloseClick);
 end;
 if HelpNO=4 then
 begin
  HelpTimer.Enabled:=false;
  DoHelpHint(TEXT_MES_HELP_HINT,TEXT_MES_HELP_3,Point(0,0),ListView1);
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
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 ExportImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_90);
end;

procedure TExplorerForm.PrintLinkClick(Sender: TObject);
var
  i, index : integer;
  Files : TStrings;
begin
 Files := TStringList.Create;
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 With ExplorerManager.NewExplorer do
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
  for i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
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
   CopyFiles(Handle,Files,NewDir,false,_AutoRename);
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
    UserLinks[Length(UserLinks)-1].BkColor:=Theme_MainColor;
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
    Ico:=GetSmallIconByPath(fIcon,true);
    UserLinks[Length(UserLinks)-1].Icon:=Ico;
    Ico.free;
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
//  _AutoRename, _Break : boolean;
begin
 if (LastListViewSelCount=0) then
 begin
  fDBCanDragW:=false;
  SetLength(S,DragFilesPopup.Count);
  for i:=1 to DragFilesPopup.Count do
  S[i-1]:=DragFilesPopup[i-1];


{  _Break:=false;
  _AutoRename:=AutoRename(S,GetCurrentPath,_Break);
  if _Break then Exit;    }

  if not (Sender=Move1) then
  CopyFiles(Handle,S,GetCurrentPath,Sender=Move1,_AutoRename) else
  begin
   CopyFiles(Handle,S,GetCurrentPath,Sender=Move1,_AutoRename,CorrectPath,self);
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


{   _Break:=false;
   _AutoRename:=AutoRename(S,Str,_Break);
   if _Break then Exit;   }

   if not (Sender=Move1) then
   CopyFiles(Handle,S,Str,Sender=Move1,_AutoRename) else
   begin
    CopyFiles(Handle,S,Str,Sender=Move1,_AutoRename,CorrectPath,self);
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
 fDBCanDrag:=false;
 if ListView1<>nil then
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
    if length(fFilesInfo)=0 then exit;
    if Index>length(fFilesInfo)-1 then exit;
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
   NameLabel.Caption:=GetFileName(FileName);
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
   PopupMenu1.Tag:=Index;
   FSelectedInfo._GUID:=FileSID;
   if FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE then
   begin
    TExplorerThumbnailCreator.Create(False,FileName,FileSID,Self);
    if HelpNo=2 then
    HelpTimer.Enabled:=True;
   end;
   if image1.Picture.Bitmap=nil then
   image1.Picture.Bitmap:=TBitmap.create;
   If not PropertyPanel.Visible then
   begin
    ReallignToolInfo;
    exit;
   end;
   ReallignInfo;
   try
    With image1.Picture.Bitmap do
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

       Ico:=AIcons.GetIconByExt(FileName,
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
     end;
     If (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) then
     begin
      With image1.Picture.Bitmap do
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
   With image1.Picture.Bitmap do
   begin
    FSelectedInfo._GUID:=GetGUID;
    Width:=ThSizeExplorerPreview;
    height:=ThSizeExplorerPreview;
    Canvas.Pen.Color:=PropertyPanel.Color;
    Canvas.Brush.Color:=PropertyPanel.Color;
    Canvas.Rectangle(0,0,ThImageSize,ThImageSize);
    Ico:=UnitDBKernel.icons[DB_IC_MANY_FILES+1];
    Canvas.Draw(ThSizeExplorerPreview div 2-Ico.Width div 2,ThSizeExplorerPreview div 2-Ico.Height div 2,Ico);
    FSelectedInfo.Size:=0;
    if SelCount<1000 then
    begin
     For i:=0 to ListView1.Items.Count-1 do
     if ListView1.Items[i].Selected then
     begin
      Index := ItemIndexToMenuIndex(i);
      if FSelectedInfo.FileType<>EXPLORER_ITEM_MYCOMPUTER then
      FSelectedInfo.FileType:=fFilesInfo[Index].FileType;
      if Length(fFilesInfo)-1<Index then exit;
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
  DS:=Dolphin_DB.DriveState(Chr(i));
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
  DS:=Dolphin_DB.DriveState(Chr(i));
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
var
  item : TMenuItem;
  PanelsTexts : TStrings;
  _SendToMenus : array of TMenuItem;
  i : integer;
  _menuitem_nil1 : TMenuItem;
  _menuitem_send_to_new : TMenuItem;
begin
 item:=Sender as TMenuItem;
 for i:=1 to Item.Count-1 do
 Item.Delete(1);

 PanelsTexts := TStringList.Create;
 PanelsTexts.Assign(UnitFormCont.ManagerPanels.GetPanelsTexts);
 SetLength(_SendToMenus,PanelsTexts.Count);
 for i:=0 to Length(_SendToMenus)-1 do
 begin
  _SendToMenus[i]:=TMenuItem.Create(item);
  _SendToMenus[i].Caption:=PanelsTexts[i];
  _SendToMenus[i].OnClick:=SendToItemPopUpMenu_;
  _SendToMenus[i].ImageIndex:=DB_IC_SENDTO;
  _SendToMenus[i].Tag:=i;
 end;
 _menuitem_nil1:=TMenuItem.Create(item);
 _menuitem_nil1.Caption:='-';
 _menuitem_send_to_new:=Tmenuitem.Create(item);
 _menuitem_send_to_new.Caption:=TEXT_MES_NEW_PANEL;
 _menuitem_send_to_new.OnClick:=SendToItemPopUpMenu_;
 _menuitem_send_to_new.ImageIndex:=DB_IC_SENDTO;
 _menuitem_send_to_new.Tag:=-1;
 item.Add(_SendToMenus);
 item.Add(_menuitem_nil1);
 item.Add(_menuitem_send_to_new);
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
 for i:=0 to Length(fFilesInfo)-1 do
 begin
  index:=MenuIndexToItemIndex(i);
  if ListView1.Items[index].Selected then
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

procedure TExplorerForm.SetNewFileNameGUID(FileGUID, SID: TGUID);
begin
  if IsEqualGUID(SID,CurrentGUID) then
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
 if IsEqualGUID(CID, CurrentGUID) then
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
  i : integer;
begin
 Result:=-1;
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(fFilesInfo)-1 do
 begin
  if AnsiLowerCase(fFilesInfo[i].FileName)=FileName then
  begin
   Result:=fFilesInfo[i].ID;
   exit;
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

function TExplorerForm.GetVisibleItems: TArStrings;
var
  i, index : integer;
  r : TRect;
  t : array of boolean;
  b : boolean;
  TempResult : TArStrings;
  RectArray: TEasyRectArrayObject;
  rv : TRect;

begin
 SetLength(Result,0);
 SetLength(t,0);
 b:=false;
 rv :=  Listview1.Scrollbars.ViewableViewportRect;

 for i:=0 to ListView1.Items.Count-1 do
 begin
 
  Listview1.Items[i].ItemRectArray(Listview1.Header.FirstColumn, Listview1.Canvas, RectArray);
  r:=Rect(ListView1.ClientRect.Left+rv.Left,ListView1.ClientRect.Top+rv.Top,ListView1.ClientRect.Right+rv.Left,ListView1.ClientRect.Bottom+rv.Top);
  if RectInRect(r,RectArray.BoundsRect) then

  begin
   index:=Self.ItemIndexToMenuIndex(i);
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:= GUIDToString(fFilesInfo[index].SID);
   SetLength(t,Length(t)+1);
   t[Length(t)-1]:=fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER;
   if not b then
   begin
    if fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER then
    b:=true;
   end;
  end;
 end;

 if b then
 begin
  SetLength(TempResult,0);
  for i:=0 to Length(Result)-1 do
  begin
   if not t[i] then
   begin
    SetLength(TempResult,Length(TempResult)+1);
    TempResult[Length(TempResult)-1]:=Result[i];
   end;
  end;
  for i:=0 to Length(Result)-1 do
  begin
   if t[i] then
   begin
    SetLength(TempResult,Length(TempResult)+1);
    TempResult[Length(TempResult)-1]:=Result[i];
   end;
  end;

  Result:=Copy(TempResult);
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
 SetNamedValue(aScript,'$ItemsCount',IntToStr(ListView1.Items.Count));
 SetNamedValueStr(aScript,'$Path',GetCurrentPath);
end;

function TExplorerForm.CanUp: boolean;
begin
 Result:=AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(MyComputer);
 if GetCurrentPath='' then Result:=false;
end;

function TExplorerForm.SelCount: integer;
begin
 Result:= ListView1.Selection.Count;
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
 For i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  if not CanCopyFileByType(fFilesInfo[index].FileType) then
  begin
   Result:=false;
   break;
  end;
 end;
 if ListView1.Items.Count=0 then
 if not CanCopyFileByType(GetCurrentPathW.PType) then Result:=false;
end;

function TExplorerForm.GetPath: string;
begin
 if DBkernel.UserRights.ShowPath then
 Result:=GetCurrentPath else Result:='';
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
 if DBkernel.UserRights.ShowPath then
 begin
  for i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if CanCopyFileByType(fFilesInfo[index].FileType) then
   begin
    SetLength(Result,Length(Result)+1);
    Result[Length(Result)-1]:=fFilesInfo[index].FileName;
   end;
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
  if DBkernel.UserRights.ShowPath then
  Result:=FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.Index)].FileName
  else Result:='';
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

 if not NoLockListView then ListView1.Groups.BeginUpdate(false);

 try
 l:=ListView1.Items.Count;//Length(fFilesInfo);

 SetLength(SIs,L);
 SetLength(LI,L);

 for i:=0 to l-1 do
 begin
  LI[i].Caption:=ListView1.Items[i].Caption;
  LI[i].Indent:=ListView1.Items[i].Tag;
  LI[i].Data:=ListView1.Items[i].Data;
  LI[i].ImageIndex:=ListView1.Items[i].ImageIndex;

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
  ListView1.Items[i].Caption:=LI[SIs[i].ID].Caption;
  ListView1.Items[i].Tag:=LI[SIs[i].ID].Indent;
  ListView1.Items[i].ImageIndex:=LI[SIs[i].ID].ImageIndex;
  ListView1.Items[i].Data:=LI[SIs[i].ID].Data;
 end;
 except
  on e : Exception do EventLog(':TExplorerForm.FileName1Click() throw exception: '+e.Message);
 end;

 if not NoLockListView then ListView1.Groups.EndUpdate;
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
 SetStringPath(Edit1.text,false);
end;

procedure TExplorerForm.CorrectPath(Src: array of string; Dest: string);
var
  i : integer;
  fn, adest : string;
begin
 UnforMatDir(Dest);
 for i:=0 to Length(Src)-1 do
 begin
  fn:=Dest+'\'+GetFileName(Src[i]);
  if DirectoryExists(fn) then
  begin
   adest:=Dest+'\'+GetFileName(Src[i]);
   RenameFolderWithDB(Src[i],adest,false);
  end;
  if FileExists(fn) then
  begin
   adest:=Dest+'\'+GetFileName(Src[i]);
   RenameFileWithDB(Src[i],adest,GetIDByFileName(Src[i]),true);
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
 SetSQL(Query,'Select count(*) as CountField From '+GetDefDBname+' where (FFileName Like :FolderA)');
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
 FEditHandle:=GetWindow(GetWindow(Edit1.Handle, GW_CHILD), GW_CHILD);
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
 s:=Trim(Edit1.Text);
 if Length(s)<4 then s:=GetDirectory(s);
 if not CheckFileExistsWithSleep(s,true) then exit;
 x:=GetDirListing(s);
 s:=Edit1.Text;
 Lock:=true;
 Edit1.Items.Clear;
 for i:=0 to Length(x)-1 do
 Edit1.Items.Add(x[i]);
 Lock:=false;
 Edit1.Text:=s;
end;

procedure TExplorerForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  dir : string;
  i, c : integer;
begin
 if Key=16 then exit;
 dir:=Edit1.Text;
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
 Result:= ListView1.Selection.First;
end;

Function TExplorerForm.ItemAtPos(X,Y : integer): TEasyItem;
begin
 Result:=ItemByPointImage(Listview1,Point(x,y));
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
 ListView1.EditManager.Enabled:=false;
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
 if DBkernel.UserRights.SetRating then
 begin
  Dolphin_DB.SetRating(RatingPopupMenu1.Tag,(Sender as TMenuItem).Tag);
  EventInfo.Rating:=(Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Sender,RatingPopupMenu1.Tag,[EventID_Param_Rating],EventInfo);
 end;
end;

procedure TExplorerForm.ListView1Resize(Sender : TObject);
begin
 Listview1.BackGround.OffsetX:=ListView1.Width-Listview1.BackGround.Image.Width;
 Listview1.BackGround.OffsetY:=ListView1.Height-Listview1.BackGround.Image.Height;
end;

procedure TExplorerForm.EasyListview1DblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
begin
 ListView1DblClick(Sender);
end;

procedure TExplorerForm.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  r, r1 : TRect;
  b : TBitmap;
  w,h, index, ind : integer;
  Exists : integer;
begin
 index:=0;
 ind:=0;
 if Item.Data=nil then exit;
 try
  r1:=ARect;
  if Item.ImageIndex<0 then exit;

  if not Boolean(TDataObject(Item.Data).Data^) then
  ListView1.PaintInfoItem.fBorderColor:=$00FFFF
  else ListView1.PaintInfoItem.fBorderColor:=Theme_ListSelectColor;

  b:=TBitmap.Create;
  b.PixelFormat:=pf24bit;
  b.Width:=fPictureSize;
  b.Height:=fPictureSize;
  FillRectNoCanvas(b,ListView1.Canvas.Brush.Color);

  w:=FBitmapImageList.FImages[Item.ImageIndex].Bitmap.Width;
  h:=FBitmapImageList.FImages[Item.ImageIndex].Bitmap.Height;
  ProportionalSize(fPictureSize,fPictureSize,w,h);

  b.Canvas.StretchDraw(Rect(fPictureSize div 2 - w div 2,fPictureSize div 2 - h div 2,w+(fPictureSize div 2 - w div 2),h+(fPictureSize div 2 - h div 2)),FBitmapImageList.FImages[Item.ImageIndex].Bitmap);

  r.Left:=r1.Left-2;
  r.Top:=r1.Top-2;

  index:=ItemIndexToMenuIndex(Item.Index);

  Exists:=1;
  if fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE then
  DrawAttributes(b,fPictureSize,fFilesInfo[index].Rating,fFilesInfo[index].Rotate,fFilesInfo[index].Access,fFilesInfo[index].FileName,fFilesInfo[index].Crypted,Exists,fFilesInfo[index].id);
  if ProcessedFilesCollection.ExistsFile(fFilesInfo[index].FileName)<>nil then
  DrawIconEx(b.Canvas.Handle,2,b.Height-18,UnitDBKernel.icons[DB_IC_RELOADING+1].Handle,16,16,0,0,DI_NORMAL);

  ACanvas.Draw(r.Left,r.Top,b);
  b.free;

 except
  on e : Exception do
  begin
   LockItems;
   MessageBoxDB(Handle,Format('Error in Explorer (Drawing image item!)'#13'%s',[e.Message]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   if Item<>nil then
   MessageBoxDB(Handle,Format('Index = %d, ImageIndex = %d, ind = %s, menuind = %d',[Item.Index,Item.ImageIndex,ind,index]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   Close;
  end;
 end;
end;

procedure TExplorerForm.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 ListView1SelectItem(Sender,Item,false);
end;

procedure TExplorerForm.SetSelected(NewSelected: TEasyItem);
begin
 ListView1.Selection.GroupSelectBeginUpdate;
 ListView1.Selection.ClearAll;
 if NewSelected<>nil then NewSelected.Selected:=true;    
 ListView1.Selection.GroupSelectEndUpdate;
end;

procedure TExplorerForm.ScrollBox1Reallign(Sender: TObject);
var
  i : integer;
begin
 if IsReallignInfo then exit;
 for i:=0 to ComponentCount-1 do
 if Components[i] is TWebLink then
 if (Components[i] as TWebLink).Visible then
 (Components[i] as TWebLink).RecreateShImage;

 for i:=0 to Length(UserLinks)-1 do
 UserLinks[i].RecreateShImage;
end;

procedure TExplorerForm.BackGround(Sender: TObject; x, y, w, h: integer;
  var Bitmap: TBitmap);
begin
 ScrollBox1.GetBackGround(x,y,w,h,Bitmap);
end;

procedure TExplorerForm.Listview1IncrementalSearch(Item: TEasyCollectionItem;
  const SearchBuffer: WideString; var CompareResult: Integer);
var
  CompareStr: WideString;
begin
  if UpdatingList then exit;
  if Item=nil then exit;
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
begin
 if Item.Data=nil then exit;
 if FBitmapImageList.FImages[Item.ImageIndex].Icon<>nil then
 ACanvas.Draw(RectArray.IconRect.Left,RectArray.IconRect.Top,
  FBitmapImageList.FImages[Item.ImageIndex].Icon);
end;

procedure TExplorerForm.EasyListview1ItemImageDrawIsCustom(
  Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := ListView <> LV_THUMBS;
end;

procedure TExplorerForm.EasyListview1ItemImageGetSize(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; var ImageWidth,
  ImageHeight: Integer);
begin
 Case ListView of
  LV_THUMBS     : begin end;
  LV_ICONS      : begin ImageHeight:=32; ImageWidth:=32;  end;
  LV_SMALLICONS : begin ImageHeight:=16; ImageWidth:=16;  end;
  LV_TITLES     : begin ImageHeight:=16; ImageWidth:=16;  end;
  LV_TILE       : begin ImageHeight:=48; ImageWidth:=48;  end;
  LV_GRID       : begin ImageHeight:=32; ImageWidth:=32;  end;
  end;
end;

procedure TExplorerForm.SmallIcons1Click(Sender: TObject);
begin
 ListView:=LV_SMALLICONS;
 SmallIcons1.Checked:=true;  
 SmallIcons2.Checked:=true;
 Reload;
end;

procedure TExplorerForm.Reload;
begin
 SetNewPathW(GetCurrentPathW,false);
end;

procedure TExplorerForm.Icons1Click(Sender: TObject);
begin
 Icons1.Checked:=true; 
 Icons2.Checked:=true;
 ListView:=LV_ICONS;
 Reload;
end;

procedure TExplorerForm.List1Click(Sender: TObject);
begin
 List1.Checked:=true; 
 List2.Checked:=true;
 ListView:=LV_TITLES;
 Reload;
end;

procedure TExplorerForm.Tile2Click(Sender: TObject);
begin
 Tile2.Checked:=true; 
 Tile3.Checked:=true;
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
 Thumbnails1.Checked:=true;  
 Thumbnails2.Checked:=true;
 ListView:=LV_THUMBS;
 Reload;
end;

function TExplorerForm.GetView : integer;
begin
 Result:=ListView;
end;

procedure TExplorerForm.MakeFolderViewer2Click(Sender: TObject);
var
  FileList : TArStrings;
  i, index : integer;
begin
 if ListView1Selected<>nil then
 begin
  SetLength(FileList,0);
  for i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
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
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize>40 then FPictureSize:=FPictureSize-10;
 LoadSizes;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);

 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TExplorerForm.ZoomOut;
var
  SelectedVisible : boolean;
begin                 
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize<550 then FPictureSize:=FPictureSize+10;
 LoadSizes;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;   
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);
 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
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
 //��� ���������� �������� ������� ��������
 UpdaterInfo.IsUpdater:=false;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False) and DBKernel.UserRights.FileOperationsCritical;
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 Info.PictureSize:=fPictureSize;
 CurrentGUID:=GetGUID;
 
 ToolButton18.Enabled:=true;
 RegisterThreadAndStart(TExplorerThread.Create(true,'::BIGIMAGES','',THREAD_TYPE_BIG_IMAGES,info,self,UpdaterInfo,CurrentGUID));
 for i:=0 to Length(fFilesInfo)-1 do
 begin
  fFilesInfo[i].isBigImage:=false;
 end;
end;

function TExplorerForm.GetAllItems : TExplorerFilesInfo;
begin
 Result:=Copy(fFilesInfo);
end;

procedure TExplorerForm.DoDefaultSort(GUID : TGUID);
begin                           
  if not IsEqualGUID(GUID, CurrentGUID) then
    Exit;

 case DefaultSort of
  0: FileName1Click(FileName1);
 //1: - rating!!! no default sorting, information about sorting goes later
  2: FileName1Click(Size1);
  3: FileName1Click(Type1);
  4: FileName1Click(Modified1);
  5: FileName1Click(Number1);
 end;
end;

function TExplorerForm.ExitstExtInIcons(Ext : String) : boolean;
var
  i : integer;
begin
 Result:=false;
 Ext:=AnsiLowerCase(Ext);
 for i:=0 to ExtIcons.Count-1 do
 if ExtIcons.FImages[i].Ext=Ext then
 begin
  Result:=true;
  break;
 end;
end;

function TExplorerForm.GetIconByExt(Ext : String) : TIcon;
var
  i : integer;
begin
 Result:=nil;
 Ext:=AnsiLowerCase(Ext);
 for i:=0 to ExtIcons.Count-1 do
 if ExtIcons.FImages[i].Ext=Ext then
 begin
  Result:=ExtIcons.FImages[i].Icon;
  break;
 end;
end;

procedure TExplorerForm.AddIconByExt(Ext : String; Icon : TIcon);
begin
 ExtIcons.AddIcon(Icon,true,AnsiLowerCase(Ext));
end;

procedure TExplorerForm.AddHiddenInfo1Click(Sender: TObject);
var
  Index : integer;
begin
 if SelCount=1 then
 begin
  Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
  DoSteno(fFilesInfo[Index].FileName);
 end;
end;

procedure TExplorerForm.ExtractHiddenInfo1Click(Sender: TObject);
var
  Index : integer;
begin
 if SelCount=1 then
 begin
  Index:=ItemIndexToMenuIndex(ListView1Selected.Index);  
  DoDeSteno(fFilesInfo[Index].FileName);
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

procedure TExplorerForm.LoadToolBarNormaIcons();
var
  Ico : TIcon;

  procedure AddIcon(Name : String);
  begin
   if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then Name:=Name+'_SMALL';
   Ico:=TIcon.Create;
   Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   ToolBarNormalImageList.AddIcon(Ico);
  end;
begin
 ToolBarNormalImageList.Clear;
 ConvertTo32BitImageList(ToolBarNormalImageList);

 if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then
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
  Ico : TIcon;

  procedure AddIcon(Name : String);
  begin
   if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then Name:=Name+'_SMALL';
   Ico:=TIcon.Create;
   Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   ToolBarDisabledImageList.AddIcon(Ico);
  end;
  
begin                  
 ToolBarDisabledImageList.Clear;
 ConvertTo32BitImageList(ToolBarDisabledImageList);
// ToolBarDisabledImageList.BkColor:=ToolBar1.Color;

 if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then
 begin
  ToolBarDisabledImageList.Width:=16;
  ToolBarDisabledImageList.Height:=16;
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
 CurrentGUID:=Dolphin_DB.GetGUID;
 if UpdatingList then
 EndUpdate(CurrentGUID);
 ToolButton18.Enabled:=false;
 fStatusProgress.Visible:=false;
 StatusBar1.Panels[0].Text:=TEXT_MES_LOADING_BREAK;
end;

procedure TExplorerForm.DoStopLoading(GUID: TGUID);
begin
 if IsEqualGUID(GUID, CurrentGUID) then
 begin
  ToolButton18.Enabled:=false;
  fStatusProgress.Visible:=false;
  StatusBar1.Panels[0].Text:='';
 end;
end;

function TExplorerForm.IsSelectedVisible: boolean;
var
  i : integer;
  r : TRect;
  t : array of boolean;
  rv : TRect;
begin
 Result:=false;
 SetLength(t,0);
 rv :=  Listview1.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  r:=Rect(ListView1.ClientRect.Left+rv.Left,ListView1.ClientRect.Top+rv.Top,ListView1.ClientRect.Right+rv.Left,ListView1.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView1.Items[i].DisplayRect) then
  begin
   if ListView1.Items[i].Selected then
   begin
    Result:=true;
    exit;
   end;
  end;
 end;
end;

procedure TExplorerForm.LoadSizes;
begin
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;
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
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 FPictureSize:=SizeX;
 LoadSizes();
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;

 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);

 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TExplorerForm.MapCD1Click(Sender: TObject);
var
  info : TCDIndexInfo;
  Dir : string;
begin
 info:=TCDIndexMapping.ReadMapFile(fFilesInfo[Popupmenu1.tag].FileName);
 if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
 if info.Loaded then
 begin
  Dir:=ExtractFilePath(fFilesInfo[Popupmenu1.tag].FileName);
  FormatDir(Dir);
  CDMapper.AddCDMapping(info.CDLabel,Dir,false);
 end else
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_F,[fFilesInfo[Popupmenu1.tag].FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
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

initialization

 ExplorerManager := TManagerExplorer.Create;

Finalization

 ExplorerManager.Free;

end.
