unit Searching;

interface

uses
  UnitGroupsWork, BDE, ThreadManeger, DBCMenu, CmpUnit, FileCtrl, Dolphin_DB,
  ShellApi,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Registry, Dialogs, DB, DBTables, Grids, DBGrids, Menus, ExtCtrls, StdCtrls,
  ImgList, ComCtrls, ActiveX, ShlObj, DBCtrls, JPEG, DmProgress, ClipBrd,
  SaveWindowPos, ExtDlgs , ToolWin, UnitDBKernel, Rating, Math, CommonDBSupport,
  AppEvnts, TwButton, ShellCtrls, UnitBitmapImageList, GraphicCrypt,
  ShellContextMenu, DropSource, DropTarget, DateUtils, acDlgSelect,
  ProgressActionUnit, UnitSQLOptimizing, UnitScripts, DBScriptFunctions,
  Exif, EasyListview, WebLink, MPCommonUtilities, GraphicsCool,
  UnitRangeDBSelectForm, UnitSearchBigImagesLoaderThread, DragDropFile,
  DragDrop, UnitPropeccedFilesSupport, uVistaFuncs, ComboBoxExDB,
  UnitDBDeclare, UnitDBFileDialogs, UnitDBCommon, UnitDBCommonGraphics,
  UnitCDMappingSupport;

type
 TString255 = string[255];
 PString255 = ^TString255;

type
  TXListView = TEasyListView;

type
  TSearchForm = class(TForm)
    Panel1: TPanel;
    PopupMenu2: TPopupMenu;
    SlideShow1: TMenuItem;
    Image1: TImage;
    Splitter1: TSplitter;
    N1: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    N2: TMenuItem;
    SelectAll1: TMenuItem;
    ManageDB1: TMenuItem;
    Options1: TMenuItem;
    CopySearchResults1: TMenuItem;
    LoadResults1: TMenuItem;
    HintTimer: TTimer;
    NewPanel1: TMenuItem;
    SaveResults1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Help1: TMenuItem;
    SearchPanelA: TPanel;
    Label1: TLabel;
    Rating2: TRating;
    TwButton1: TTwButton;
    PropertyPanel: TPanel;
    Label2: TLabel;
    Label8: TLabel;
    Rating1: TRating;
    Label4: TLabel;
    Label6: TLabel;
    Memo2: TMemo;
    Label5: TLabel;
    Memo1: TMemo;
    Save: TButton;
    ExplorerPanel: TPanel;
    ShellTreeView1: TShellTreeView;
    Explorer1: TMenuItem;
    N3: TMenuItem;
    ShowUpdater1: TMenuItem;
    PopupMenu1: TPopupMenu;
    DoSearchNow1: TMenuItem;
    Panels1: TMenuItem;
    Properties1: TMenuItem;
    Explorer2: TMenuItem;
    DateTimePicker1: TDateTimePicker;
    SaveasTable1: TMenuItem;
    BackGroundSearchPanel: TPanel;
    IsDatePanel: TPanel;
    PopupMenu3: TPopupMenu;
    Datenotexists1: TMenuItem;
    PanelValueIsDateSets: TPanel;
    Image2: TImage;
    LabelBackGroundSearching: TLabel;
    PopupMenu4: TPopupMenu;
    EditGroups1: TMenuItem;
    GroupsManager1: TMenuItem;
    DateExists1: TMenuItem;
    PopupMenu5: TPopupMenu;
    Ratingnotsets1: TMenuItem;
    PopupMenu6: TPopupMenu;
    SetComent1: TMenuItem;
    Comentnotsets1: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    N4: TMenuItem;
    Cut1: TMenuItem;
    Copy2: TMenuItem;
    Paste1: TMenuItem;
    MenuItem3: TMenuItem;
    Undo1: TMenuItem;
    Datenotsets1: TMenuItem;
    PopupMenu7: TPopupMenu;
    Setvalue1: TMenuItem;
    ImageList1: TImageList;
    HelpTimer: TTimer;
    SearchPanelB: TPanel;
    DmProgress1: TDmProgress;
    Label7: TLabel;
    Button1: TButton;
    Button2: TButton;
    PanelWideSearch: TPanel;
    DateTimePicker2: TDateTimePicker;
    DateTimePicker3: TDateTimePicker;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    CheckBox5: TCheckBox;
    Edit2: TEdit;
    Edit3: TEdit;
    PopupMenu8: TPopupMenu;
    OpeninExplorer1: TMenuItem;
    AddFolder1: TMenuItem;
    Hide1: TMenuItem;
    GroupsManager2: TMenuItem;
    About1: TMenuItem;
    Activation1: TMenuItem;
    Help2: TMenuItem;
    HomePage1: TMenuItem;
    ContactWithAuthor1: TMenuItem;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    NewSearch1: TMenuItem;
    DropFileTarget1: TDropFileTarget;
    GetUpdates1: TMenuItem;
    ImageEditor1: TMenuItem;
    Image3: TImage;
    QuickGroupsSearch: TPopupMenu;
    SortingPopupMenu: TPopupMenu;
    SortbyID1: TMenuItem;
    SortbyName1: TMenuItem;
    SortbyDate1: TMenuItem;
    SortbyRating1: TMenuItem;
    SortbyFileSize1: TMenuItem;
    SortbySize1: TMenuItem;
    N5: TMenuItem;
    Increment1: TMenuItem;
    Decremect1: TMenuItem;
    Image5: TImage;
    Image6: TImage;
    GetPhotosFromDrive1: TMenuItem;
    GroupsImageList: TImageList;
    CheckBox6: TCheckBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    InsertSpesialQueryPopupMenu: TPopupMenu;
    CheckBox7: TCheckBox;
    HidePanelTimer: TTimer;
    DateTimePicker4: TDateTimePicker;
    IsTimePanel: TPanel;
    PanelValueIsTimeSets: TPanel;
    PopupMenu10: TPopupMenu;
    Setvalue2: TMenuItem;
    PopupMenu11: TPopupMenu;
    Timenotexists1: TMenuItem;
    TimeExists1: TMenuItem;
    Timenotsets1: TMenuItem;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Help3: TMenuItem;
    Tools1: TMenuItem;
    View1: TMenuItem;
    Exit1: TMenuItem;
    Help4: TMenuItem;
    Activation2: TMenuItem;
    About2: TMenuItem;
    HomePage2: TMenuItem;
    ContactWithAuthor2: TMenuItem;
    GetUpdates2: TMenuItem;
    NewPanel2: TMenuItem;
    NewSearch2: TMenuItem;
    Explorer3: TMenuItem;
    N6: TMenuItem;
    Options2: TMenuItem;
    GroupsManager3: TMenuItem;
    N7: TMenuItem;
    LoadResults2: TMenuItem;
    SaveResults2: TMenuItem;
    ShowExplorerPage1: TMenuItem;
    SelectTimer: TTimer;
    GetListofKeyWords1: TMenuItem;
    GetPhotosFromDrive2: TMenuItem;
    RemovableDrives1: TMenuItem;
    CDROMDrives1: TMenuItem;
    SpecialLocation1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    RemovableDrives2: TMenuItem;
    N10: TMenuItem;
    CDROMDrives2: TMenuItem;
    N11: TMenuItem;
    SpecialLocation2: TMenuItem;
    DBTreeView1: TMenuItem;
    DestroyTimer: TTimer;
    ImageEditor2: TMenuItem;
    View2: TMenuItem;
    ManageDB2: TMenuItem;
    DropFileTarget2: TDropFileTarget;
    ScriptListPopupMenu: TPopupMenu;
    ScriptMainMenu: TMainMenu;
    RatingPopupMenu1: TPopupMenu;
    N00: TMenuItem;
    N01: TMenuItem;
    N02: TMenuItem;
    N03: TMenuItem;
    N04: TMenuItem;
    N05: TMenuItem;
    ImageBackGround: TImage;
    ShowDateOptionsLink: TWebLink;
    SortLink: TWebLink;
    BigImagesTimer: TTimer;
    DropFileTarget3: TDropFileTarget;
    SearchGroupsImageList: TImageList;
    ImageAllGroups: TImage;
    SearchImageList: TImageList;
    ComboBoxSearchGroups: TComboBoxExDB;
    SearchEdit: TComboBoxExDB;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolBarImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    DisabledToolBarImageList: TImageList;
    ComboBoxSelGroups: TComboBoxExDB;
    PopupMenuZoomDropDown: TPopupMenu;
    SortbyCompare1: TMenuItem;
    procedure DoSearchNow(Sender: TObject);
    procedure Edit1_KeyPress(Sender: TObject; var Key: Char);
    procedure Additem_(sender: TObject; Name_ : String; tag : integer );
    procedure FormCreate(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1DblClick(Sender: TObject);

    procedure SlideShow1Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure DeleteItemFromDBByID(Id : integer);
    procedure load_thum_(Sender: TObject);

    function GetSelectedTstrings :  Tstrings;
    function GetSelectedID : TArInteger;
    procedure FormDestroy(Sender: TObject);
    procedure reloadtheme(Sender: TObject);
    procedure search(Sender: TObject);
    procedure breakoperation(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);

    function GetAllFiles:  Tstrings;
    procedure Splitter1Moved(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ManageDB1Click(Sender: TObject);
    procedure RefreshInfoByID(ID : integer);
    procedure Memo1Change(Sender: TObject);
    procedure ErrorQSL(sql : string);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure CopySearchResults1Click(Sender: TObject);
    procedure HintTimerTimer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    function HintRealA(item:TObject) : boolean;
    procedure initialization_;
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure NewPanel1Click(Sender: TObject);
    procedure SaveResults1Click(Sender: TObject);
    procedure LoadResults1Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure Help1Click(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure RenameCurrentItem(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);

    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Explorer1Click(Sender: TObject);
    procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1Exit(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Explorer2Click(Sender: TObject);
    procedure SetPath(Value : String);
    procedure SearchPanelAContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Rating1MouseDown(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    Procedure DoLockInfo;
    Procedure DoUnLockInfo;
    Function LockInfo : Boolean;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveAsTable1Click(Sender: TObject);
    procedure DateNotExists1Click(Sender: TObject);
    procedure IsDatePanelDblClick(Sender: TObject);
    procedure PanelValueIsDateSetsDblClick(Sender: TObject);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure BackGroundSearchPanelResize(Sender: TObject);
    procedure BackGroundSearchPanelContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure LabelBackGroundSearchingContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure ComboBox1_KeyPress(Sender: TObject; var Key: Char);
    Procedure ReloadGroups;
    procedure ComboBox1_Select(Sender: TObject);
    procedure ComboBox1_DblClick(Sender: TObject);
    procedure GroupsManager1Click(Sender: TObject);
    procedure DateExists1Click(Sender: TObject);
    procedure PopupMenu3Popup(Sender: TObject);
    procedure Ratingnotsets1Click(Sender: TObject);
    procedure PopupMenu5Popup(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure SetComent1Click(Sender: TObject);
    procedure Comentnotsets1Click(Sender: TObject);
    procedure Datenotsets1Click(Sender: TObject);
    procedure PopupMenu6Popup(Sender: TObject);
    procedure LoadLanguage;
    procedure HelpTimerTimer(Sender: TObject);
    procedure PopupMenu7Popup(Sender: TObject);
    procedure PopupMenu4Popup(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure PopupMenu8Popup(Sender: TObject);
    procedure OpeninExplorer1Click(Sender: TObject);
    procedure AddFolder1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure DeleteItemByID(ID : integer);
    procedure GroupsManager2Click(Sender: TObject);
    procedure Activation1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure ContactWithAuthor1Click(Sender: TObject);
    procedure RefreshThumItemByID(ID : integer);
    procedure NewSearch1Click(Sender: TObject);
    procedure GetUpdates1Click(Sender: TObject);
    procedure HelpNextClick(Sender: TObject);
    procedure HelpCloseClick(Sender : TObject; var CanClose : Boolean);

    procedure HelpActivationNextClick(Sender: TObject);
    procedure HelpActivationCloseClick(Sender : TObject; var CanClose : Boolean);

    procedure FormShow(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);

    procedure QuickGroupsearch(Sender: TObject);
    procedure SortbyID1Click(Sender: TObject);
    procedure SortbyName1Click(Sender: TObject);
    procedure SortbyDate1Click(Sender: TObject);
    procedure SortbyRating1Click(Sender: TObject);
    procedure SortbyFileSize1Click(Sender: TObject);
    procedure SortbySize1Click(Sender: TObject);
    procedure Image4_Click(Sender: TObject);
    procedure Decremect1Click(Sender: TObject);
    procedure Increment1Click(Sender: TObject);
    procedure GetPhotosClick(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure InsertSpesialQueryPopupMenuItemClick(Sender: TObject);
    procedure DeleteSelected;
    procedure HidePanelTimerTimer(Sender: TObject);
    procedure PanelValueIsTimeSetsDblClick(Sender: TObject);
    procedure PopupMenu11Popup(Sender: TObject);
    procedure Timenotexists1Click(Sender: TObject);
    procedure TimeExists1Click(Sender: TObject);
    procedure Timenotsets1Click(Sender: TObject);
    procedure Help4Click(Sender: TObject);
    procedure Activation2Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure HomePage2Click(Sender: TObject);
    procedure ContactWithAuthor2Click(Sender: TObject);
    procedure GetUpdates2Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShowExplorerPage1Click(Sender: TObject);
    procedure DoShowSelectInfo;
    procedure SelectTimerTimer(Sender: TObject);
    procedure GetListofKeyWords1Click(Sender: TObject);
    procedure RemovableDrives1Click(Sender: TObject);
    procedure CDROMDrives1Click(Sender: TObject);
    procedure SpecialLocation1Click(Sender: TObject);
    procedure GetPhotosFromDrive2Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure IsTimePanelDblClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure DBTreeView1Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure View2Click(Sender: TObject);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure ReloadListMenu;
    procedure ScriptExecuted(Sender : TObject);
    Procedure LoadExplorerValue(Sender : TObject);
    Procedure ListView1Resize(Sender : TObject);
    procedure UpdateTheme(Sender: TObject);
    Function SelCount : integer;
    procedure EasyListview1ItemThumbnailDraw(
      Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
      ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure ListView1SelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
    function GetListItemByID(ID : integer) : TEasyItem;
    function GetItemNO(item : TEasyItem):integer;
    function GetSelecteditemNO(item : TEasyItem):integer;
    function ItemIndex(item : TEasyItem) : integer;
    procedure ListView1Edited(Sender: TObject; Item: TEasyItem;
      var S: String);
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    Function ListView1Selected : TEasyItem;
    Function ItemAtPos(X,Y : integer): TEasyItem;
    Function ItemAtPosStar(X,Y : integer): TEasyItem;
    procedure EasyListview1DblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
    procedure EasyListview1ItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    procedure EasyListview2KeyAction(Sender: TCustomEasyListview;
      var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListview1ItemEdited(Sender: TCustomEasyListview;
      Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure N05Click(Sender: TObject);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem;
        const SearchBuffer: WideString; var CompareResult: Integer);
    procedure ShowDateOptionsLinkClick(Sender: TObject);
    procedure SetDateSettings(Sender : TObject; DateFrom, DateTo, LastDate : TDateTime; ByLastDate: boolean);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure ApplicationEvents1Activate(Sender: TObject);
    procedure LoadSizes();
    function FileNameExistsInList(FileName : string) : boolean;
    procedure ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap);
    procedure ReplaceImageIndexWithPath(FileName : string; Index : integer);
    function GetImageIndexWithPath(FileName : string) : integer;

    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure BigImagesTimerTimer(Sender: TObject);
    function GetVisibleItems : TArStrings;
    function IsSelectedVisible: boolean;
    procedure ComboBoxSearchGroupsSelect(Sender: TObject);
    procedure ComboBoxSearchGroupsDropDown(Sender: TObject);
    procedure SearchEditDropDown(Sender: TObject);
    procedure SearchEditSelect(Sender: TObject);
    procedure SearchEditEnterDown(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure SearchEditGetAdditionalImage(Sender: TObject; index: Integer;
      HDC: Cardinal; var Top, Left: Integer);
    procedure ToolButton14Click(Sender: TObject);
    procedure SortingClick(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure SortingPopupMenuPopup(Sender: TObject);
    procedure SortbyCompare1Click(Sender: TObject);
  private
  fListUpdating : boolean;
  FPropertyGroups: String;
  TempFolderName : String;
  CurrentItemInfo : TOneRecordInfo;
  FFirstTip_WND : HWND;
  WindowsMenuTickCount : Cardinal;
  LastSelCount : integer;
  FUpdatingDB : Boolean;
  DestroyCounter : Integer;
  GroupsLoaded : boolean;
    procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
    { Protected declarations }
  protected
  procedure CreateWND; override;
  procedure CreateParams(VAR Params: TCreateParams); override;
    { Private declarations }
  public
    ListView1: TXListView;
    WindowID : TGUID;
    ThreadQuery : TDataSet;
    SelectQuery : TDataSet;
    WorkQuery : TDataSet;
    FBitmapImageList : TBitmapImageList;
    SID : TGUID;
    Data : TSearchRecordArray;

    FormDateRangeSelectDBHideed : boolean;

    MouseDowned : Boolean;
    RenameResult : Boolean;
    PopupHandled : boolean;

    LoadingThItem, ShLoadingThItem : TEasyItem;

    ShowingDateRangeWindow: boolean;
    ItemSelectedByMouseDown : boolean;
    ItemByMouseDown : boolean;
    LastQuery : String;
    FilesToDrag : TArStrings;
    DBCanDrag : Boolean;
    DBDragPoint : TPoint;
    current_id_show : integer;
    FSearchPath, fcomment, fkeywords : string;
    thum_images_:integer;
    WorkedFiles_ : Tstrings;
    mouse_mov:boolean;
    frating :integer;
    SelectedInfo : TSelectedInfo;
    FLockInfo : Boolean;
    Creating : Boolean;
    LockChangePath : Boolean;
    result_replaceimg : integer;
    FShowen : boolean;
    aScript : TScript;
    ListMenuScript : String;
    aFS : TFileStream;
    FormDateRangeSelectDB: TFormDateRangeSelectDB;

    FPictureSize : integer;
    SearchTextList : TStrings;
    SearchGroupsList : TStrings;
    SearchRatingList : TList;
    SearchByCompating : boolean;
    CanSaveQueryList  : boolean;
    procedure LoadGroupsList(LoadAllLIst : boolean = false);
    procedure LoadSearchList(LoadAllLIst : boolean = false);
    procedure AddNewSearchListEntry;
    procedure LoadSearchTexts;
    procedure LoadToolBarIcons;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ReRecreateGroupsList;
    function IfBreak(Sender : TObject; aSID : TGUID) : boolean;
    procedure DoSetSearchByComparing;
    procedure LoadSearchDBParametrs;
    procedure SaveQueryList;          
    procedure LoadQueryList;
  published
    { Public declarations }
  end;

  TArSearch = array of TSearchForm;
  TArForms = array of TForm;

  TManagerSearchs = class(TObject)
   Private
    FSearchs : TArSearch;
    FForms : TArForms;
   Public
    Constructor Create;
    Destructor Destroy; override;
    Function NewSearch : TSearchForm;
    Procedure FreeSearch(Search : TSearchForm);
    Procedure AddSearch(Search : TSearchForm);
    Procedure RemoveSearch(Search : TSearchForm);
    Function IsSearch(Search : TSearchForm) : Boolean;
    Function SearchCount : Integer;
    Property Searchs : TArSearch Read FSearchs;
    Function IsSearchForm(Search: TForm): Boolean;
    Function GetAnySearch : TSearchForm;
   published
  end;

var
  Foperations : integer;
  Sclipbrd : string;
  SearchManager : TManagerSearchs;

  procedure SelectedColor(var image : TBitmap; Color : TColor);
  procedure GrayScale(var image : TBitmap);
  Function RectInRect(Const R1, R2 : TRect) : Boolean;
 procedure DrawAttributes(bit : TBitmap; PistureSize : integer; Rating,Rotate, Access : Integer; FileName : String; Crypt : Boolean; var Exists : integer; ID : integer = 0);
 function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;

  const
  Images_sm = 1;
  limit_up = false;

  {$R WindowsXPMan.res}

implementation

uses Language, UnitManageGroups, FormManegerUnit, SlideShow, Loadingresults,
     PropertyForm, ReplaceForm, CleaningForm, Options, UnitLoadFilesToPanel,
     UnitHintCeator, UnitImHint, DBSelectUnit, UnitFormCont,
     About, activation, ExplorerUnit, InstallFormUnit, UnitUpdateDB,
     UnitUpdateDBThread, ManagerDBUnit, UnitEditGroupsForm , UnitQuickGroupInfo,
     UnitGroupReplace, UnitSavingTableForm, UnitInternetUpdate, UnitHelp,
     ImEditor, UnitGetPhotosForm, UnitListOfKeyWords, UnitDBTreeView,
     ReplaseLanguageInScript, ReplaseIconsInScript,
     UnitUpdateDBObject, UnitFormSizeListViewTh, UnitBigImagesSize;

{$R *.dfm}
//{$R icons.res}

procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject);
var
  PositionIndex, AbsIndex: Integer;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;
      AbsIndex := 0;
      PositionIndex := 0;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);
      try
        RectArray.BoundsRect := Item.DisplayRect;
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
        InflateRect(RectArray.TextRect, -2, -2);

      finally
      end;
    end
  end
end;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;
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
    if EasyListview.Items[i].OwnerGroup.Expanded then
    begin
     ItemRectArray(EasyListview.Items[i],Metrics.tmHeight,RectArray);

      if PtInRect(RectArray.IconRect, ViewportPoint) then
       Result := EasyListview.Items[i] else
      if PtInRect(RectArray.TextRect, ViewportPoint) then
       Result := EasyListview.Items[i];
    end;
    Inc(i)
  end
end;

procedure TSearchForm.DoSearchNow(Sender: TObject);
var
  WideSearch : TWideSearchOptions;
  fScript : TScript;
  ScriptString : string;
  c : integer;
begin
 If FUpdatingDB then Exit;
 If Creating then Exit;
 WideSearch.Enabled:=PanelWideSearch.Visible;
 WideSearch.IfBreak:=IfBreak;
 if FormDateRangeSelectDB<>nil then
 if FormDateRangeSelectDB.IsVisible then
 begin
  ShowWindow(FormDateRangeSelectDB.Handle,SW_HIDE);
  FormDateRangeSelectDB.IsVisible:=false;
 end;
 SearchByCompating:=false;
 ScriptString:=Include('Scripts\DoSearch.dbini');
 InitializeScript(fScript);
 fScript.Description:='New search script';

 FinalizeScript(fScript);

 LoadBaseFunctions(fScript);
 LoadDBFunctions(fScript);
 AddAccessVariables(fScript);
 if Pos('"',SearchEdit.Text)>0 then
 SearchEdit.Text:=SysUtils.StringReplace(SearchEdit.Text,'"',' ',[rfReplaceAll]);

 SetNamedValue(fScript,'$SearchString','"'+SearchEdit.Text+'"');
 SetNamedValue(fScript,'$Rating',IntToStr(Rating2.Rating));

 ExecuteScript(nil,fScript,ScriptString,c,nil);
 SearchEdit.Text:=GetNamedValueString(fScript,'$SearchString');
 Rating2.Rating:=GetNamedValueInt(fScript,'$Rating');

 WideSearch.ShowLastTime:=CheckBox6.Checked;
 WideSearch.LastTimeValue:=StrToIntDef(ComboBox4.Text,3);
 WideSearch.LastTimeCode:=ComboBox5.ItemIndex;
 WideSearch.UseWideSearch:=CheckBox7.Checked;

 WideSearch.GroupName:=ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption;
 if WideSearch.GroupName=TEXT_MES_ALL_GROUPS then
 WideSearch.GroupName:='';

 PanelWideSearch.Visible:=false;
 Rating2.IsLayered:=PanelWideSearch.Visible;
 TwButton1.IsLayered:=PanelWideSearch.Visible;
 Rating2.Enabled:= not PanelWideSearch.Visible;
 TwButton1.Enabled:= not PanelWideSearch.Visible;
 Button2.Caption:='-->';
 Button1.OnClick:= BreakOperation;
 Button1.Caption:=TEXT_MES_STOP;
 DmProgress1.Text:=TEXT_MES_STOPING+'...';
 Label7.Caption:=TEXT_MES_CALCULATING+'...';
 If Creating then Exit;
 try
  ThreadQuery.Active:=false;
  ListView1.Items.Clear;
  FBitmapImageList.Clear;
 except
 end;
 DmProgress1.Text:=TEXT_MES_INITIALIZE+'...';
 DmProgress1.position:=0;
 DmProgress1.Text:=TEXT_MES_QUERY_EX;
 WideSearch.EnableDate:=CheckBox1.Checked;
 WideSearch.MinDate:=Min(DateTimePicker2.DateTime,DateTimePicker3.DateTime);
 WideSearch.MaxDate:=Max(DateTimePicker2.DateTime,DateTimePicker3.DateTime);
 WideSearch.EnableRating:=CheckBox4.Checked;
 WideSearch.MinRating:=Min(StrToIntDef(ComboBox2.Text,0),StrToIntDef(ComboBox3.Text,0));
 WideSearch.MaxRating:=Max(StrToIntDef(ComboBox2.Text,0),StrToIntDef(ComboBox3.Text,0));
 WideSearch.EnableID:=CheckBox5.Checked;
 WideSearch.MinID:=Min(StrToIntDef(Edit2.Text,0),StrToIntDef(Edit3.Text,0));
 WideSearch.MaxID:=Max(StrToIntDef(Edit2.Text,0),StrToIntDef(Edit3.Text,0));
 WideSearch.Private_:=CheckBox2.Checked;
 WideSearch.Common_:=CheckBox3.Checked;
 SID:=GetGUID;
 ToolButton14.Enabled:=true;
 SearchThread.Create(false,Self,SID,Rating2.Rating,TwButton1.Pushed,SortLink.Tag,Decremect1.Checked,SearchEdit.text,WideSearch,BreakOperation,FPictureSize);
 AddNewSearchListEntry;
end;

procedure TSearchForm.Edit1_KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then
 begin
  key:=#0;
  DoSearchNow(nil);
 end;
end;

procedure TSearchForm.Additem_(Sender: TObject; Name_ : String; Tag : integer );
var
  New : TEasyItem;
begin
 New := ListView1.Items.Add;
 New.Tag:=Tag;
 New.ImageIndex:=0;
 New.Caption:=Name_;
end;

procedure TSearchForm.FormCreate(Sender: TObject);
const
 n = 3;
 Captions : array[0..n-1] of string = (TEXT_MES_SPEC_QUERY, TEXT_MES_DELETED, TEXT_MES_DUBLICATES);

var
  Menus : array[0..n-1] of TMenuItem;
  i : integer;
  MainMenuScript : string;

begin
 CanSaveQueryList:=true;
 fListUpdating:=false;
 GroupsLoaded:=false;
 ShowingDateRangeWindow:=false;
 FormDateRangeSelectDB:=nil;
 SearchEdit.ShowDropDownMenu:=false;

 SearchEdit.NullText := TEXT_MES_NULL_TEXT;
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
     ListView1.BackGround.Image:=TBitmap.create;
     ListView1.BackGround.Image.PixelFormat:=pf24bit;
     ListView1.BackGround.Image.Width:=150;
     ListView1.BackGround.Image.Height:=150;
     ListView1.BackGround.Image.Canvas.Brush.Color:=Theme_ListColor;
     ListView1.BackGround.Image.Canvas.Pen.Color:=Theme_ListColor;
     ListView1.BackGround.Image.Canvas.Rectangle(0,0,150,150);

     for i:=1 to 20 do
     begin
      try
       ListView1.BackGround.Image.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
       break;
      except
       Sleep(50);
      end;
     end;
     ListView1.Font.Color:=0;
     ListView1.View:=elsThumbnail;
     ListView1.DragKind:=dkDock;
     ListView1.Selection.MouseButton:= [cmbRight];

     ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
     ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);
     ListView1.Selection.AlphaBlend:=true;
     ListView1.Selection.AlphaBlendSelRect:=true;
     ListView1.Selection.MultiSelect:=true;
     ListView1.Selection.RectSelect:=true;
     ListView1.Selection.EnableDragSelect:=true;
     ListView1.Selection.TextColor:=Theme_ListFontColor;
     ListView1.GroupFont.Color:=Theme_ListFontColor;
     FPictureSize:=ThImageSize;
     LoadSizes();

     ListView1.HotTrack.Color:=Theme_ListFontColor;
     ListView1.HotTrack.Cursor:=CrArrow;
     ListView1.IncrementalSearch.Enabled:=true;
     ListView1.OnItemThumbnailDraw:=EasyListview1ItemThumbnailDraw;

     ListView1.OnDblClick:=EasyListview1DblClick;

     ListView1.OnIncrementalSearch:=Listview1IncrementalSearch;
     ListView1.OnExit:=ListView1Exit;
     ListView1.OnMouseDown:=ListView1MouseDown;
     ListView1.OnMouseUp:=ListView1MouseUp;
     ListView1.OnMouseMove:=ListView1MouseMove;
     ListView1.OnItemSelectionChanged:=EasyListview1ItemSelectionChanged;
     ListView1.OnMouseWheel:=ListView1MouseWheel;
     ListView1.OnKeyAction:=EasyListview2KeyAction;
     ListView1.OnItemEdited:=self.EasyListview1ItemEdited;
     ListView1.OnResize:=ListView1Resize;
     ListView1.Groups.Add;
     ListView1.Header.Columns.Add;

 ConvertTo32BitImageList(DragImageList);

 DBKernel.RegisterProcUpdateTheme(UpdateTheme,self);
 Activation1.Visible:=not FolderView;
 Activation2.Visible:=not FolderView;
 Help1.Visible:=not FolderView;
 Help4.Visible:=not FolderView;

 GetPhotosFromDrive1.Visible:=not FolderView;
 GetPhotosFromDrive2.Visible:=not FolderView;
 ToolButton14.Enabled:=false;

 ExplorerManager.LoadEXIF;
 WindowID:=GetGUID;
 InitializeScript(aScript);
 LoadBaseFunctions(aScript);
 LoadDBFunctions(aScript);
 LoadFileFunctions(aScript);

 AddScriptObjFunction(aScript,'ShowExplorerPanel',F_TYPE_OBJ_PROCEDURE_TOBJECT,Explorer2Click);
 AddScriptObjFunction(aScript,'HideExplorerPanel',F_TYPE_OBJ_PROCEDURE_TOBJECT,Properties1Click);
 AddScriptObjFunction(aScript,'SlideShow',F_TYPE_OBJ_PROCEDURE_TOBJECT,SlideShow1Click);
 AddScriptObjFunction(aScript,'SelectAll',F_TYPE_OBJ_PROCEDURE_TOBJECT,SelectAll1Click);
 AddScriptObjFunction(aScript,'SaveResultsAsTable',F_TYPE_OBJ_PROCEDURE_TOBJECT,SaveasTable1Click);
 AddScriptObjFunction(aScript,'CopySearchResults',F_TYPE_OBJ_PROCEDURE_TOBJECT,CopySearchResults1Click);
 AddScriptObjFunction(aScript,'LoadResults',F_TYPE_OBJ_PROCEDURE_TOBJECT,LoadResults1Click);
 AddScriptObjFunction(aScript,'SaveResults',F_TYPE_OBJ_PROCEDURE_TOBJECT,SaveResults1Click);
 AddScriptObjFunction(aScript,'CloseWindow',F_TYPE_OBJ_PROCEDURE_TOBJECT,Exit1Click);
 AddScriptObjFunction(aScript,'LoadExplorerValue',F_TYPE_OBJ_PROCEDURE_TOBJECT,LoadExplorerValue);

 Menu:=nil;
 SetNamedValue(aScript,'$dbname','"'+dbname+'"');
 ReloadListMenu;

 if DBKernel.Readbool('Options','UseMainMenuInSearchForm',true) then
 begin
  if not SafeMode and UseScripts then
  begin
   MainMenuScript:=ReadScriptFile('scripts\SearchMainMenu.dbini');
   Menu:=nil;
   LoadMenuFromScript(ScriptMainMenu.Items,DBkernel.ImageList,MainMenuScript,aScript,ScriptExecuted,FExtImagesInImageList,true);
   Menu:=ScriptMainMenu;
  end else Menu:=MainMenu1;
 end;

 ScriptListPopupMenu.Images:=DBKernel.ImageList;
 ScriptMainMenu.Images:=DBKernel.ImageList;
 SelectQuery:=GetQuery(dbname);
 ThreadQuery:=GetQuery(dbname);
 WorkQuery:=GetQuery(dbname);
 DropFileTarget2.Register(SearchEdit);
 GetPhotosFromDrive2.Visible:=not FolderView;
 DestroyCounter:=0;
 FShowen:=false;
 FUpdatingDB:=false;

 DropFileTarget1.Register(Self);

 try
 DateTimePicker2.DateTime:=Now;
 DateTimePicker3.DateTime:=Now;


 for i:=0 to n-1 do
 begin
  Menus[i]:=TmenuItem.Create(InsertSpesialQueryPopupMenu);
  Menus[i].Caption:=Captions[i];
  Menus[i].OnClick:=InsertSpesialQueryPopupMenuItemClick;
  Menus[i].Tag:=i;
  InsertSpesialQueryPopupMenu.Items.Add(Menus[i]);
 end;
 Menus[0].Enabled:=false;
 ListView1.HotTrack.Enabled:=DBKernel.Readbool('Options','UseHotSelect',true);
 Panel1.Width:=DBKernel.ReadInteger('Search','LeftPanelWidth',150);
 GetPhotosFromDrive1.Visible:= not FolderView;
 FBitmapImageList := TBitmapImageList.Create;
 FormManager.RegisterMainForm(Self);
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate() throw exception: '+e.Message);
 end;
 try
  initialization_;
 except    
   on e : Exception do EventLog(':TSearchForm::FormCreate() throw exception: '+e.Message);
 end;
 DBKernel.RegisterForm(self);
 LoadLanguage;
 SearchManager.AddSearch(Self);

 if DBKernel.ReadboolW('','DoUpdateHelp',false) then
 begin
  DoUpdateHelp;
 end;
 DBKernel.WriteBoolW('','DoUpdateHelp',false);
 try
  LoadSearchTexts;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadSearchTexts throw exception: '+e.Message);
 end;
 try
  LoadGroupsList;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadGroupsList throw exception: '+e.Message);
 end;
 try
  LoadSearchList;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadSearchList throw exception: '+e.Message);
 end;
 LoadToolBarIcons;
 LoadQueryList;
 LoadSearchDBParametrs;
end;

procedure TSearchForm.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Info : TDBPopupMenuInfo;
  item: TEasyItem;
  FileNames : TArStrings;
  i : integer;
  S : String;
begin
 if CopyFilesSynchCount>0 then WindowsMenuTickCount:=GetTickCount;
 HintTimer.Enabled:=false;
 Item:=ItemByPointImage(ListView1, Point(MousePos.x,MousePos.y));
 if (Item=nil) or ((MousePos.x=-1) and (MousePos.y=-1)) then Item:=ListView1.Selection.First;

 if (item<>nil) and (item.Selected) then
 begin
  LoadingThItem:= nil;
  if Active then
  Application.HideHint;
  if ImHint<>nil then
  ImHint.Close;
  HintTimer.Enabled:=false;
  Info:=GetCurrentPopUpMenuInfo(Item);
  if not (getTickCount-WindowsMenuTickCount>WindowsMenuTime)  then
  begin
   DBPopupMenu.Execute(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y,Info);
  end else
  begin
   SetLength(FileNames,0);
   For i:=0 to length(Info.ItemFileNames_)-1 do
   if Info.ItemSelected_[i] then
   begin
    SetLength(FileNames,Length(FileNames)+1);
    FileNames[Length(FileNames)-1]:=Info.ItemFileNames_[i];
   end;
   GetProperties(FileNames,MousePos,ListView1);
  end;
 end else
 begin
  if not (ShiftKeyDown and CtrlKeyDown) and UseScripts then
  begin
  WorkedFiles_.Clear;
  if ListView1.Selection.First=nil then

   if Length(Data)=ListView1.Items.Count then
   begin
    for i:=1 to ListView1.Items.Count do
    WorkedFiles_.Add(Data[ItemIndex(ListView1.Items[i-1])].FileName);
   end else
   begin
    if SelCount=1 then
    begin
     WorkedFiles_:=GetAllFiles;
    end else
    begin
     WorkedFiles_:=GetSelectedTstrings;
    end;
   end;
   SetBoolAttr(aScript,'$OneFileExists',WorkedFiles_.count<>0);
   S:=ListMenuScript;
   LoadMenuFromScript(ScriptListPopupMenu.Items,DBkernel.ImageList,S,aScript,ScriptExecuted,FExtImagesInImageList,true);
   ScriptListPopupMenu.Popup(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y);
  end else
   PopupMenu2.Popup(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y);
 end;
end;

procedure TSearchForm.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i : integer;
  MenuInfo : TDBPopupMenuInfo;
  item, itemsel: TEasyItem;
begin

  Item:=ItemAtPos(x,y);
  MouseDowned:=Button=mbRight;
  itemsel:=Item;
  ItemByMouseDown:=false;
  if (Button = mbLeft) then
  if itemsel<>nil then
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

  if (Button = mbLeft) and (Item<>nil) then
  begin
    DBCanDrag:=True;
    SetLength(FilesToDrag,0);
    GetCursorPos(DBDragPoint);
    MenuInfo:=GetCurrentPopUpMenuInfo(Item);
    SetLength(FilesToDrag,0);
    For i:=0 to length(MenuInfo.ItemFileNames_)-1 do
    if MenuInfo.ItemSelected_[i] then
    If FileExists(MenuInfo.ItemFileNames_[i]) then
    begin
     SetLength(FilesToDrag,Length(FilesToDrag)+1);
     FilesToDrag[Length(FilesToDrag)-1]:=MenuInfo.ItemFileNames_[i];
    end;
    If Length(FilesToDrag)=0 then DBCanDrag:=false;
  end;
end;

function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;
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
   if EasyListview.Items[i].Visible then
   begin
      EasyListview.Items[i].ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);
      a:=EasyListview.CellSizes.Thumbnail.Width - 35;
      b:=0;
      t:=RectArray.IconRect.Top;
      l:=RectArray.IconRect.Left;
      r:=Rect(a+l,b+t,a+22+l,b+t+18);
      if PtInRect(r, ViewportPoint) then
       Result := EasyListview.Items[i];
   end;
   Inc(i)
  end
end;

procedure TSearchForm.ListView1DblClick(Sender: TObject);
var
  MenuInfo : TDBPopupMenuInfo;
  info : TRecordsInfo;
  p,p1 : TPoint;
begin

  GetCursorPos(p1);
  p:=ListView1.ScreenToClient(p1);
  if ItemByPointStar(Listview1,p)<>nil then
  begin
   RatingPopupMenu1.Tag:=ItemAtPos(p.x,p.y).Tag;
   Application.HideHint;
   if ImHint<>nil then
   if not UnitImHint.Closed then
   ImHint.Close;
   LoadingThitem:=nil;
   RatingPopupMenu1.Popup(p1.x,p1.y);
   exit;
  end;

 if Active then
 Application.HideHint;
 if ImHint<>nil then
 if not UnitImHint.Closed then
 ImHint.Close;
 HintTimer.Enabled:=false;

 if ListView1.Selection.First<>nil then
 begin
  MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
  If Viewer=nil then
  Application.CreateForm(TViewer,Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.Execute(Sender,info);
 end;
end;

procedure TSearchForm.ListView1SelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
begin
 if not SelectTimer.Enabled then
 SelectTimer.Enabled:=true;
end;

procedure TSearchForm.SlideShow1Click(Sender: TObject);
var
  Info : TRecordsInfo;
  DBInfo : TDBPopupMenuInfo;
begin
 Info:=RecordsInfoNil;
 DBInfo:=GetCurrentPopUpMenuInfo(nil);
 DBPopupMenuInfoToRecordsInfo(DBInfo,Info);
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 Viewer.Execute(Sender,Info);
end;

procedure TSearchForm.SaveClick(Sender: TObject);
var
  s, s1, s2, s3, _sqlexectext, CommonKeyWords, KeyWords, CommonGroups, Groups : string;
  EventInfo : TEventValues;
  i, j, id  :Integer;
  List : TSQLList;
  IDs : String;
  xCount : integer;
  ProgressForm : TProgressActionForm;
  WorkQuery : TDataSet;
begin
 WorkQuery:=GetQuery;
 If not DBkernel.ProgramInDemoMode then
 begin
  if CharToInt(DBkernel.GetCodeChar(12))<>CharToInt(DBkernel.GetCodeChar(10))*CharToInt(DBkernel.GetCodeChar(10))*CharToInt(DBkernel.GetCodeChar(10)) mod 15 then exit;
 end;


 if SelCount=1 then
 begin
  S:=label2.Caption;
  delete(s,1,5);
  id:=strtointdef(s,-1);
  if id<0 then exit;
  _sqlexectext:='Update '+GetDefDBName;
  s1:=normalizeDBString(memo2.lines.Text);
  s2:=normalizeDBString(memo1.lines.Text);
  s3:=normalizeDBString(FPropertyGroups);
  _sqlexectext:=_sqlexectext+' Set Comment="'+s1+'" , KeyWords="'+s2+'", Rating='+inttostr(rating1.Rating)+', DateToAdd = :Date, IsDate = :IsDate, aTime = :aTime, IsTime = :IsTime, Groups = "'+s3+'"';

  _sqlexectext:=_sqlexectext+ ' Where ID=:ID';
  WorkQuery.active:=false;
  SetSQL(WorkQuery,_sqlexectext);

  SetDateParam(WorkQuery,0,DateTimePicker1.DateTime);
  SetBoolParam(WorkQuery,1,not IsDatePanel.Visible);
  SetDateParam(WorkQuery,2,TimeOf(DateTimePicker4.DateTime));
  SetBoolParam(WorkQuery,3,not IsTimePanel.Visible);
  SetIntParam(WorkQuery,4,id);  //Must be LAST PARAM!
  ExecSQL(WorkQuery);
  EventInfo.Comment:=memo2.lines.Text;
  EventInfo.KeyWords:=memo1.lines.Text;
  EventInfo.Rating:=rating1.Rating;
  EventInfo.Groups:=FPropertyGroups;
  EventInfo.Date:=DateTimePicker1.DateTime;
  EventInfo.IsDate:=not IsDatePanel.Visible;
  DBKernel.DoIDEvent(Sender,id,[EventID_Param_Rating,EventID_Param_Comment,EventID_Param_KeyWords,EventID_Param_Date,EventID_Param_IsDate,EventID_Param_Groups],EventInfo);
 end else
 begin
  FUpdatingDB:=true;
  Save.Enabled:=false;
  Button1.Enabled:=false;
  ListView1.Enabled:=false;

  Memo1.Enabled:=false;
  Memo2.Enabled:=false;
  ComboBoxSelGroups.Enabled:=false;
  DateTimePicker1.Enabled:=false;
  DateTimePicker4.Enabled:=false;
  Rating1.Enabled:=false;

  xCount:=0;
  ProgressForm:=nil;
  CommonKeyWords:=SelectedInfo.CommonKeyWords;
  if VariousKeyWords(Memo1.lines.Text,CommonKeyWords) then inc(xCount);
  If not CompareGroups(CurrentItemInfo.ItemGroups,FPropertyGroups) then inc(xCount);

  if xCount>0 then
  begin
   ProgressForm:=GetProgressWindow;
   ProgressForm.OperationCount:=xCount;
   ProgressForm.OperationPosition:=0;
   ProgressForm.OneOperation:=false;
   ProgressForm.MaxPosCurrentOperation:=Length(SelectedInfo.Ids);
   ProgressForm.xPosition:=0;
   ProgressForm.DoShow;
  end;

  //[BEGIN] Date Support
  If not PanelValueIsDateSets.Visible then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set DateToAdd = :Date Where ';
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' (ID='+inttostr(SelectedInfo.Ids[i])+')' else
   _sqlexectext:=_sqlexectext+' OR (ID='+inttostr(SelectedInfo.Ids[i])+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetDateParam(WorkQuery,0,DateTimePicker1.DateTime);
   ExecSQL(WorkQuery);
   EventInfo.Date:=DateTimePicker1.DateTime;
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_Date],EventInfo);
  end;
  if not PanelValueIsDateSets.Visible then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set IsDate = :IsDate Where ';
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' (ID='+inttostr(SelectedInfo.Ids[i])+')' else
   _sqlexectext:=_sqlexectext+' OR (ID='+inttostr(SelectedInfo.Ids[i])+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetBoolParam(WorkQuery,0,not IsDatePanel.Visible);
   ExecSQL(WorkQuery);
   EventInfo.IsDate:=not IsDatePanel.Visible;
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_IsDate],EventInfo);
  end;
  //[END] Date Support


  //[BEGIN] Time Support
  If not PanelValueIsTimeSets.Visible then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set aTime = :aTime Where ';
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' (ID='+inttostr(SelectedInfo.Ids[i])+')' else
   _sqlexectext:=_sqlexectext+' OR (ID='+inttostr(SelectedInfo.Ids[i])+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetDateParam(WorkQuery,0,TimeOf(DateTimePicker4.DateTime));
   ExecSQL(WorkQuery);
   EventInfo.Time:=TimeOf(DateTimePicker4.DateTime);
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_Time],EventInfo);
  end;
  if not PanelValueIsTimeSets.Visible then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set IsTime = :IsTime Where ID in (';
   for i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(SelectedInfo.Ids[i])+' ' else
   _sqlexectext:=_sqlexectext+' , '+inttostr(SelectedInfo.Ids[i])+'';
   _sqlexectext:=_sqlexectext+')';

   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetBoolParam(WorkQuery,0,not IsTimePanel.Visible);
   ExecSQL(WorkQuery);
   EventInfo.IsTime:=not IsTimePanel.Visible;
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_IsTime],EventInfo);
  end;
  //[END] Time Support

  //[BEGIN] Rating Support
  if not Rating1.Islayered then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set Rating = :Rating Where ID in (';
   for i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(SelectedInfo.Ids[i])+' ' else
   _sqlexectext:=_sqlexectext+' , '+inttostr(SelectedInfo.Ids[i])+'';
   _sqlexectext:=_sqlexectext+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetIntParam(WorkQuery,0,Rating1.Rating);
   ExecSQL(WorkQuery);
   EventInfo.Rating:=Rating1.Rating;
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_Rating],EventInfo);
  end;
  //[END] Rating Support

  //[BEGIN] Comment Support
  if not Memo2.ReadOnly then
  begin
   _sqlexectext:='Update '+GetDefDBName+' Set Comment = "'+normalizeDBString(Memo2.Text)+'" Where ID in (';
   for i:=0 to Length(SelectedInfo.Ids)-1 do
   if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(SelectedInfo.Ids[i])+' ' else
   _sqlexectext:=_sqlexectext+' , '+inttostr(SelectedInfo.Ids[i])+'';
   _sqlexectext:=_sqlexectext+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   ExecSQL(WorkQuery);
   EventInfo.Comment:=Memo2.Text;
   For i:=0 to Length(SelectedInfo.Ids)-1 do
   DBKernel.DoIDEvent(Sender,SelectedInfo.Ids[i],[EventID_Param_Comment],EventInfo);
  end;
  //[END] Comment Support

  //[BEGIN] KeyWords Support

  If VariousKeyWords(Memo1.lines.Text,CommonKeyWords) then
  begin
   FreeSQLList(List);
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   for i:=0 to ListView1.Items.Count-1 do
   if ListView1.Items[i].Selected then
   begin
    KeyWords:=Data[i].KeyWords;
    ReplaceWords(SelectedInfo.CommonKeyWords,Memo1.Lines.Text,KeyWords);
    if VariousKeyWords(KeyWords,Data[i].KeyWords) then
    begin
     AddQuery(List,KeyWords,Data[i].ID);
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
    _sqlexectext:='Update '+GetDefDBName+' Set KeyWords ="'+NormalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
    WorkQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
    ExecSQL(WorkQuery);
    EventInfo.KeyWords:=List[i].Value;
    for j:=0 to Length(List[i].IDs)-1 do
    DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_KeyWords],EventInfo);
   end;
  end;
  //[END] KeyWords Support

  //[BEGIN] Groups Support
  CommonGroups:=SelectedInfo.Groups;
  If not CompareGroups(CurrentItemInfo.ItemGroups,FPropertyGroups) then
  begin
   FreeSQLList(List);
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   for i:=0 to ListView1.Items.Count-1 do
   if ListView1.Items[i].Selected then
   begin
    Groups:=Data[i].Groups;
    ReplaceGroups(SelectedInfo.Groups,FPropertyGroups,Groups);
    if not CompareGroups(Groups,Data[i].Groups) then
    begin
     AddQuery(List,Groups,Data[i].ID);
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
    _sqlexectext:='Update '+GetDefDBName+' Set Groups ="'+normalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
    WorkQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
   ExecSQL(WorkQuery);
     EventInfo.Groups:=List[i].Value;
    for j:=0 to Length(List[i].IDs)-1 do
    DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_Groups],EventInfo);
   end;

  end;
  //[END] Groups Support
  FUpdatingDB:=false;
  ListView1.Enabled:=true;
  Button1.Enabled:=true;

  Memo1.Enabled:=true;
  Memo2.Enabled:=true;
  ComboBoxSelGroups.Enabled:=true;
  DateTimePicker1.Enabled:=true;
  DateTimePicker4.Enabled:=true;
  Rating1.Enabled:=true;
  if ProgressForm<>nil then
  begin
   ProgressForm.Release;
   if UseFreeAfterRelease then ProgressForm.Free;
  end;
  DoShowSelectInfo;
 end;
 FreeDS(WorkQuery);
 Save.Enabled:=false;
end;

procedure TSearchForm.load_thum_(Sender: TObject);
begin
 DmProgress1.Text:=TEXT_MES_PROGRESS_PR;
 DmProgress1.Position:=0;
end;

procedure DrawAttributes(bit : TBitmap; PistureSize : integer; Rating,Rotate, Access : Integer; FileName : String; Crypt : Boolean; var Exists : integer; ID : integer = 0);
var
  FExif : TExif;
  failture : boolean;
  DeltaX : integer;
  FE : boolean;
begin
 DeltaX:=PistureSize-100;
 If ID=0 then
 DrawIconEx(bit.Canvas.Handle,0+DeltaX,0,UnitDBKernel.icons[DB_IC_NEW+1].Handle,16,16,0,0,DI_NORMAL);

 FE:=true;
 if Exists=0 then
 begin
  FE:=FileExists(FileName);
  if FE then Exists:=1 else Exists:=-1;
 end;
 if Exists=-1 then FE:=false;

 if FolderView then
 if not FE then
 begin
  FileName:=ProgramDir+FileName;
  FE:=FileExists(FileName);
 end;

 if ExplorerManager.ShowEXIF then
 begin
  FExif := TExif.Create;
  failture:=false;
  try
  FExif.ReadFromFile(FileName);
  except
   failture:=true;
  end;
  if FExif.Valid and not failture then
  begin
   If Id=0 then
   DrawIconEx(bit.Canvas.Handle,20+DeltaX,0,UnitDBKernel.icons[DB_IC_EXIF+1].Handle,16,16,0,0,DI_NORMAL) else
   DrawIconEx(bit.Canvas.Handle,0+DeltaX,0,UnitDBKernel.icons[DB_IC_EXIF+1].Handle,16,16,0,0,DI_NORMAL)
  end;
  FExif.free;
 end;


 if Crypt then DrawIconEx(bit.Canvas.Handle,20+DeltaX,0,UnitDBKernel.icons[DB_IC_KEY+1].Handle,16,16,0,0,DI_NORMAL);
 Case Rating of
  1: DrawIconEx(bit.Canvas.Handle,80+DeltaX,0,UnitDBKernel.icons[DB_IC_RATING_1+1].Handle,16,16,0,0,DI_NORMAL);
  2: DrawIconEx(bit.Canvas.Handle,80+DeltaX,0,UnitDBKernel.icons[DB_IC_RATING_2+1].Handle,16,16,0,0,DI_NORMAL);
  3: DrawIconEx(bit.Canvas.Handle,80+DeltaX,0,UnitDBKernel.icons[DB_IC_RATING_3+1].Handle,16,16,0,0,DI_NORMAL);
  4: DrawIconEx(bit.Canvas.Handle,80+DeltaX,0,UnitDBKernel.icons[DB_IC_RATING_4+1].Handle,16,16,0,0,DI_NORMAL);
  5: DrawIconEx(bit.Canvas.Handle,80+DeltaX,0,UnitDBKernel.icons[DB_IC_RATING_5+1].Handle,16,16,0,0,DI_NORMAL);
 end;
 Case Rotate of
  DB_IMAGE_ROTATED_90: DrawIconEx(bit.Canvas.Handle,60+DeltaX,0,UnitDBKernel.icons[DB_IC_ROTETED_90+1].Handle,16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_180: DrawIconEx(bit.Canvas.Handle,60+DeltaX,0,UnitDBKernel.icons[DB_IC_ROTETED_180+1].Handle,16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_270: DrawIconEx(bit.Canvas.Handle,60+DeltaX,0,UnitDBKernel.icons[DB_IC_ROTETED_270+1].Handle,16,16,0,0,DI_NORMAL);
 end;
 If Access=db_access_private then
 DrawIconEx(bit.Canvas.Handle,40+DeltaX,0,UnitDBKernel.icons[DB_IC_PRIVATE+1].Handle,16,16,0,0,DI_NORMAL);
 if not FE then
 begin             
  if Copy(FileName,1,2)='::' then
  begin
   DrawIconEx(bit.Canvas.Handle,0+DeltaX,0,UnitDBKernel.icons[DB_IC_CD_IMAGE+1].Handle,18,18,0,0,DI_NORMAL);
  end else
  begin
   DrawIconEx(bit.Canvas.Handle,0+DeltaX,0,UnitDBKernel.icons[DB_IC_DELETE_INFO+1].Handle,18,18,0,0,DI_NORMAL);
  end;
 end;
end;

procedure TSearchForm.RefreshThumItemByID(ID : integer);
var
  BS : TStream;
  item : TEasyItem;
  Password, fname : string;
  J : TJpegImage;
  bit : TBitmap;
  i, iItemIndex : integer;

  RecordInfo : TOneRecordInfo;
  Exists : integer;
begin
 Password:='';
 item:=GetListItemByID(ID);
 if item=nil then exit;
 if not (item.imageindex<=Images_sm-1) then
 begin
  SelectQuery.Active:=false;
  SetSQL(SelectQuery,'SELECT * FROM '+GetDefDBName+' WHERE ID='+inttostr(ID));
  SelectQuery.active:=true;
  if TBlobField(SelectQuery.FieldByName('thum'))=nil then
  begin
   exit;
  end;
  if ValidCryptBlobStreamJPG(SelectQuery.FieldByName('thum')) then
  begin
   Password:=DBKernel.FindPasswordForCryptBlobStream(SelectQuery.FieldByName('thum'));
   if Password<>'' then
   begin
    J:=TJpegImage(DeCryptBlobStreamJPG(SelectQuery.FieldByName('thum'),Password));
    Data[ItemIndex(item)].Crypted:=true;
   end else
   begin
    bit := TBitmap.create;
    bit.PixelFormat:=pf24bit;
    bit.Width:=ThSize;
    bit.Height:=ThSize;
    FillColorEx(bit, Theme_ListColor);
    try
     bit.canvas.Draw(ThSize div 2 - image1.picture.Graphic.Width div 2,ThSize div 2 - image1.picture.Graphic.height div 2,image1.picture.Graphic);
    except
    end;
    Exists:=0;
    DrawAttributes(bit,fPictureSize,0,0,0,SelectQuery.FieldByName('FFileName').AsString,true,Exists);
    FBitmapImageList.FImages[item.ImageIndex].Bitmap.Free;
    FBitmapImageList.FImages[item.ImageIndex].Bitmap:=bit;
    ListView1.Refresh;
    exit;
   end;
  end else
  begin
   J:=TJpegImage.Create;
   BS:=GetBlobStream(SelectQuery.FieldByName('thum'),bmRead);
   Data[ItemIndex(item)].Crypted:=false;
   try
    if BS.Size<>0 then
    J.loadfromStream(BS) else
   except
   end;
   BS.Free;
  end;
  bit := TBitmap.create;
  bit.PixelFormat:=pf24bit;
  bit.Canvas.Brush.Color:=Theme_ListColor;
  bit.Canvas.Pen.Color:=Theme_ListColor;
  bit.width:=ThSize;
  bit.height:=ThSize;
  FillColorEx(bit, Theme_ListColor);

  bit.canvas.Draw(ThSize div 2 - J.Width div 2,ThSize div 2 - J.height div 2,J);
  J.free;
  Data[ItemIndex(item)].Rotation:=SelectQuery.FieldByName('Rotated').AsInteger;
  case Data[ItemIndex(item)].Rotation of
   DB_IMAGE_ROTATED_90  :  Rotate90A(bit);
   DB_IMAGE_ROTATED_180 :  Rotate180A(bit);
   DB_IMAGE_ROTATED_270 :  Rotate270A(bit);
  end;
  fname:=Trim(SelectQuery.FieldByName('Name').asstring);
  for i:= Length(fname) downto 1 do
  begin
   if fname[i]=' ' then Delete(fname,i,1) else break;
  end;
  item.Caption:=fname;
  Data[ItemIndex(item)].FileName:=SelectQuery.FieldByName('FFileName').AsString;
  iItemIndex:=ItemIndex(item);

  Exists:=0;
  DrawAttributes(bit,fPictureSize,Data[iItemIndex].Rating,Data[iItemIndex].Rotation,Data[iItemIndex].Access,SelectQuery.FieldByName('FFileName').AsString,Data[iItemIndex].Crypted,Exists);

  FBitmapImageList.FImages[item.ImageIndex].Bitmap.free;
  FBitmapImageList.FImages[item.ImageIndex].Bitmap:=bit;
  RecordInfo.ItemFileName:=SelectQuery.FieldByName('FFileName').AsString;
  RecordInfo.ItemRating:=Data[iItemIndex].Rating;
  RecordInfo.ItemRotate:=Data[iItemIndex].Rotation;
  RecordInfo.ItemAccess:=Data[iItemIndex].Access;
  RecordInfo.ItemCrypted:=Data[iItemIndex].Crypted;

 //?????????????? TSearchThreadLoadBigImage.Create(false,self,self.SID,RecordInfo,fPictureSize);
  ListView1.Refresh;
 end;
 if GetlistitembyID(ID).imageindex=0 then
 begin
  SelectQuery.Active:=false;
  SetSQL(SelectQuery,'SELECT * FROM '+GetDefDBName+' WHERE ID='+inttostr(ID));
  SelectQuery.active:=true;
  if TBlobField(SelectQuery.FieldByName('thum'))=nil then
  begin
   exit;
  end;
  if ValidCryptBlobStreamJPG(SelectQuery.FieldByName('thum')) then
  begin
   Password:=DBKernel.FindPasswordForCryptBlobStream(SelectQuery.FieldByName('thum'));
   if Password<>'' then
   begin
    J:=TJPEGImage(DeCryptBlobStreamJPG(SelectQuery.FieldByName('thum'),Password));
    Data[ItemIndex(item)].Crypted:=true;
   end else
   begin
    bit.width:=ThSize;
    bit.height:=ThSize;
    FillColorEx(bit, Theme_ListColor);
    try
     bit.canvas.Draw(ThSize div 2 - Image1.Picture.Graphic.Width div 2,ThSize div 2 - Image1.Picture.Graphic.height div 2,Image1.Picture.Graphic);
    except
    end;
    Exists:=0;
    DrawAttributes(bit,fPictureSize,0,0,0,SelectQuery.FieldByName('FFileName').AsString,true,Exists);
    FBitmapImageList.FImages[item.ImageIndex].Bitmap.Assign(bit);
    ListView1.Refresh;
    exit;
   end;
  end else
  begin
   J:=TJpegImage.Create;
   Data[ItemIndex(item)].Crypted:=false;
   BS:=GetBlobStream(SelectQuery.FieldByName('thum'),bmRead);
   try
    if BS.Size<>0 then
    J.loadfromStream(BS) else
   except
   end;
   BS.Free;
  end;
  bit := TBitmap.create;
  bit.PixelFormat:=pf24bit;
  bit.width:=ThSize;
  bit.height:=ThSize;
  FillColorEx(bit, Theme_ListColor);
  bit.canvas.Draw(ThSize div 2 - J.Width div 2,ThSize div 2 - J.height div 2,J);
  J.free;
  case Data[ItemIndex(item)].Rotation of
   DB_IMAGE_ROTATED_90  :  Rotate90A(bit);
   DB_IMAGE_ROTATED_180 :  Rotate180A(bit);
   DB_IMAGE_ROTATED_270 :  Rotate270A(bit);
  end;
  Exists:=0;
  DrawAttributes(bit,fPictureSize,Data[ItemIndex(item)].Rating,Data[ItemIndex(item)].Rotation,Data[ItemIndex(item)].Access,SelectQuery.FieldByName('FFileName').AsString,Data[ItemIndex(item)].Crypted,Exists);
  FBitmapImageList.AddBitmap(bit);
  ListView1.Refresh;
  item.ImageIndex:=FBitmapImageList.Count-1;
 end;
end;

procedure TSearchForm.DeleteItemFromDBByID(Id: integer);
var
  EventInfo : TEventValues;
begin
 if GetlistitembyID(Id)<>nil then
 begin
  getlistitembyid(Id).ImageIndex:=1;
  SelectQuery.active:=false;
  SetSQL(SelectQuery,'UPDATE '+GetDefDBName+' SET Attr='+inttostr(db_attr_not_exists)+' WHERE ID='+inttostr(id));
  ExecSQL(SelectQuery);
  DBKernel.DoIDEvent(nil,id,[EventID_Param_Delete],EventInfo);
 end;
end;

function TSearchForm.GetListItemByID(ID : integer) : TEasyItem;
var
  i : integer;
begin
 result:=nil;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if listview1.Items[i].Tag=ID then
  begin
   result:=ListView1.Items[i];
   break;
  end;
 end;
end;

function TSearchForm.GetSelectedID: tarinteger;
var
  i, c : integer;
begin
 c:=0;
 for i:=0 to listview1.Items.Count-1 do
 begin
  if listview1.Items[i].Selected then
  begin
   inc(c);
   SetLength(result,c);
   result[c-1]:=ListView1.Items[i].Tag;
  end;
 end;
end;

function TSearchForm.GetSelectedTStrings: TStrings;
var
  i : integer;
begin
 Result:=TStringList.Create;
 if listview1.Items.Count=0 then exit;
 for i:=0 to listview1.Items.Count-1 do
 begin
  if listview1.Items[i].Selected then
  if FileExists(Data[ItemIndex(ListView1.Items[i])].FileName) then
  Result.Add(Data[ItemIndex(ListView1.Items[i])].FileName);
 end;
end;

procedure TSearchForm.FormDestroy(Sender: TObject);
begin
 DBKernel.WriteInteger('Search','LeftPanelWidth',Panel1.Width);
 DBKernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
 FinalizeScript(aScript);
 FreeDS(ThreadQuery);
 FreeDS(SelectQuery);
 FreeDS(WorkQuery);
 DropFileTarget2.Unregister;
 DropFileTarget1.Unregister;
 if Creating then exit;
 DBkernel.UnRegisterForm(self);
 DBKernel.UnRegisterChangesID(self,ChangedDBDataByID);
 DBkernel.SaveCurrentColorTheme;
 SaveWindowPos1.SavePosition;
 FBitmapImageList.Free;
 FBitmapImageList:=nil;
 FormManager.UnRegisterMainForm(Self);
 Creating:=true;
 if FormDateRangeSelectDB<>nil then
 begin
  FormDateRangeSelectDB.Selecting:=true;//NO APPLY BUTTON EBABLED
  FormDateRangeSelectDB.Release;
  if UseFreeAfterRelease then
  FormDateRangeSelectDB.Free;
 end;
end;

procedure TSearchForm.Reloadtheme(Sender: TObject);
begin   
  DBKernel.RecreateThemeToForm(self);
  Application.HintColor:=Theme_MainColor;
end;

procedure TSearchForm.BreakOperation(Sender: TObject);
begin
 if ToolButton14.Enabled then
 ToolButton14.Click;
 DmProgress1.Text:=TEXT_MES_STOPING+'...';
 Button1.Onclick:= Search;
 Button1.Caption:=TEXT_MES_SEARCH;
 DmProgress1.Text:=TEXT_MES_DONE;
 DmProgress1.Position:=0;
 ListView1.Show;
 BackGroundSearchPanel.Hide;
 ListView1.Groups.EndUpdate;
end;

procedure TSearchForm.Search(Sender: TObject);
begin
 DoSearchNow(Sender);
end;

procedure TSearchForm.SelectAll1Click(Sender: TObject);
begin
 ListView1.Selection.SelectAll;
 ListView1.SetFocus;
end;

{function TSearchForm.GetSelectedNO: integer;
var
  i : integer;
begin
 result:=0;
 if Listview1.Items.Count=0 then exit;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if listview1.Items[i].Selected then
  begin
   result:=i;
   break;
  end;
 end;
end;  }

function TSearchForm.GetAllFiles: Tstrings;
var
  i : integer;
begin
 Result:=TStringList.Create;
 for i:=1 to ListView1.Items.Count do
 Result.Add(Data[ItemIndex(ListView1.Items[i-1])].FileName);
end;

procedure TSearchForm.Splitter1Moved(Sender: TObject);
const
  otstup =15;
begin
 if Panel1.width<150 then Panel1.width:=150;
 if Panel1.width>240 then Panel1.width:=240;
 SearchEdit.Width:=Panel1.width-otstup;
 DmProgress1.Width:=Panel1.width-otstup;
 Memo1.Width:=Panel1.width-otstup;
 Memo2.Width:=Panel1.width-otstup;
 ComboBoxSearchGroups.Width:=Panel1.width-otstup;
 DateTimePicker1.Width:=Panel1.width-otstup;
 IsDatePanel.Width:=Panel1.width-otstup;
 PanelValueIsDateSets.Width:=Panel1.width-otstup;

 DateTimePicker4.Width:=Panel1.width-otstup;
 IsTimePanel.Width:=Panel1.width-otstup;
 PanelValueIsTimeSets.Width:=Panel1.width-otstup;

 Button2.Left:=Panel1.width-Button2.Width-otstup div 2;
 Button1.Width:=Panel1.width-78;
 ComboBoxSelGroups.Width:=Panel1.width-otstup;
 Save.Left:=memo1.Width+memo1.Left-Save.Width;
 DateTimePicker2.Width:=Panel1.width-otstup;
 DateTimePicker3.Width:=Panel1.width-otstup;
 CheckBox1.Width:=Panel1.width-otstup;
 CheckBox2.Width:=Panel1.width-otstup;
 CheckBox3.Width:=Panel1.width-otstup;
 CheckBox4.Width:=Panel1.width-otstup;
 CheckBox5.Width:=Panel1.width-otstup;
 ComboBox2.Width:=(Panel1.width-otstup*3) div 2+otstup div 2;
 Edit2.Width:=(Panel1.width-otstup*3) div 2+otstup div 2;
 ComboBox3.Width:=(Panel1.width-otstup*3) div 2+otstup div 2;
 ComboBox3.Left:=ComboBox2.Left+ComboBox2.Width+otstup;
 Edit3.Width:=(Panel1.width-otstup*3) div 2+otstup div 2;
 Edit3.Left:=ComboBox2.Left+ComboBox2.Width+otstup;

 ComboBox4.Width:=ComboBox2.width;
 ComboBox5.Left:=ComboBox3.Left;
 ComboBox5.Width:=ComboBox3.width;
end;

function TSearchForm.GetItemNO(item : TEasyItem) : integer;
var
  i : integer;
begin
 result:=0;
 if ListView1.Items.Count=0 then exit;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if listview1.Items[i]=item then
  begin
   Result:=i;
   break;
  end;
 end;
end;

function TSearchForm.GetSelectedItemNO(item : TEasyItem) : integer;
var
  i, c : integer;
begin
 result:=0;
 c:=-1;
 if listview1.Items.Count=0 then exit;
 for i:=0 to listview1.Items.Count-1 do
 begin
  if listview1.Items[i].Selected then inc(c);
  if listview1.Items[i]=item then
  begin
   result:=c;
   break;
  end;
 end;
end;

procedure TSearchForm.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=ord('"') then key:=ord('''');
end;

procedure TSearchForm.ManageDB1Click(Sender: TObject);
begin
 DoManager;
end;

procedure TSearchForm.RefreshInfoByID(ID : integer);
begin
 if Current_id_show<>ID then exit;
 ListView1SelectItem(nil,GetlistitembyID(ID),true);
end;

procedure TSearchForm.Memo1Change(Sender: TObject);

 function ReadCHDate : boolean;
 begin
  if SelCount>1 then
  Result:=not PanelValueIsDateSets.Visible and ((CurrentItemInfo.ItemIsDate<>not IsDatePanel.Visible) or (CurrentItemInfo.ItemDate<>DateTimePicker1.DateTime) or (SelectedInfo.IsVariousDates and not PanelValueIsDateSets.Visible)) else
  Result:=(((CurrentItemInfo.ItemDate<>DateTimePicker1.DateTime) or (IsDatePanel.Visible<>not SelectedInfo.IsDate)) and not PanelValueIsDateSets.Visible);
 end;

 function ReadCHTime : boolean;
 var
   VarTime : Boolean;
 begin
  VarTime:=Abs(CurrentItemInfo.ItemTime-TimeOf(DateTimePicker4.DateTime))>1/(24*60*60*3);
  if SelCount>1 then
  Result:=not PanelValueIsTimeSets.Visible and ((CurrentItemInfo.ItemIsTime<>not IsTimePanel.Visible) or (VarTime or (SelectedInfo.IsVariousTimes and not PanelValueIsTimeSets.Visible))) else
  Result:=((VarTime or (IsTimePanel.Visible<>not SelectedInfo.IsTime)) and not PanelValueIsTimeSets.Visible);
 end;

begin
 If LockInfo Then Exit;
 if SelCount>1 then
 begin
  if ReadCHTime or ReadCHDate or not rating1.Islayered or (not Memo2.ReadOnly and SelectedInfo.IsVariousComments) or (not SelectedInfo.IsVariousComments and (SelectedInfo.CommonComment<>Memo2.Text)) or VariousKeyWords(SelectedInfo.CommonKeyWords,Memo1.Text) or not CompareGroups(CurrentItemInfo.ItemGroups,FPropertyGroups) then
  Save.Enabled:=true else Save.Enabled:=false;
  if not rating1.Islayered then Label8.Font.Style:=Label8.Font.Style+[fsBold] else Label8.Font.Style:=Label8.Font.Style-[fsBold];
  if (not Memo2.ReadOnly and SelectedInfo.IsVariousComments) or (not SelectedInfo.IsVariousComments and (SelectedInfo.CommonComment<>Memo2.Text)) then Label6.Font.Style:=Label6.Font.Style+[fsBold] else Label6.Font.Style:=Label6.Font.Style-[fsBold];
  if VariousKeyWords(SelectedInfo.CommonKeyWords,Memo1.Text) then Label5.Font.Style:=Label5.Font.Style+[fsBold] else Label5.Font.Style:=Label5.Font.Style-[fsBold];
 end else
 begin
  if ReadCHTime or ReadCHDate or (CurrentItemInfo.ItemRating<>Rating1.Rating) or (CurrentItemInfo.ItemComment<>Memo2.text) or VariousKeyWords(CurrentItemInfo.ItemKeyWords,Memo1.Text) or not CompareGroups(CurrentItemInfo.ItemGroups,FPropertyGroups) then
  Save.Enabled:=true else Save.Enabled:=false;
  if (CurrentItemInfo.ItemRating<>Rating1.Rating) then Label8.Font.Style:=Label8.Font.Style+[fsBold] else Label8.Font.Style:=Label8.Font.Style-[fsBold];
  if (CurrentItemInfo.ItemComment<>Memo2.text) then Label6.Font.Style:=Label6.Font.Style+[fsBold] else Label6.Font.Style:=Label6.Font.Style-[fsBold];
  if VariousKeyWords(CurrentItemInfo.ItemKeyWords,Memo1.text) then Label5.Font.Style:=Label5.Font.Style+[fsBold] else Label5.Font.Style:=Label5.Font.Style-[fsBold];
 end;
end;

procedure TSearchForm.ErrorQSL(sql : string);
begin
 MessageBoxDB(Handle,TEXT_MES_3+sql,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
end;

procedure TSearchForm.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i : integer;
  RefreshParams : TEventFields;
  FilesToUpdate : TSearchRecordArray;
  FileName : String;
  Rotate,ReRotation : integer;
begin

 if EventID_Repaint_ImageList in params then
 begin
  ListView1.Refresh;
  exit;
 end;

 if EventID_Param_GroupsChanged in params then
 begin
  ReRecreateGroupsList;
  Exit;
 end;

 if EventID_Param_DB_Changed in params then
 begin
  if FormDateRangeSelectDB<>nil then
  begin
   FormDateRangeSelectDB.Selecting:=true;//NO APPLY BUTTON EBABLED
   FormDateRangeSelectDB.Release;
   if UseFreeAfterRelease then
   FormDateRangeSelectDB.Free;
   FormDateRangeSelectDB:=nil;
  end;
  Caption:=ProductName+' - '+DBKernel.DBUserName+'  ['+DBkernel.GetDataBaseName+']';
  ReRecreateGroupsList;
  FPictureSize:=Dolphin_DB.ThImageSize;
  LoadSizes;
 end;

 if ID=-2 then exit;

 if [EventID_Param_DB_Changed,EventID_Param_Refresh_Window] * params<>[] then
 begin
  FreeDS(SelectQuery);
  FreeDS(ThreadQuery);
  FreeDS(WorkQuery);
  SelectQuery:=GetQuery(dbname);
  ThreadQuery:=GetQuery(dbname);
  WorkQuery:=GetQuery(dbname);
  ReRecreateGroupsList; 
  LoadQueryList;
  LoadSearchDBParametrs;
  DoSearchNow(nil);
  Exit;
 end;

 if EventID_Param_Delete in params then
 begin
  DeleteItemByID(ID);
  Exit;
 end;

 Rotate:=0;
 For i:=0 to Length(Data)-1 do
 if Data[i].ID=ID then
 begin
  if EventID_Param_Private in params then Data[i].Access:=Value.Access;
  if EventID_Param_Crypt in params then Data[i].Crypted:=Value.Crypt;
  if EventID_Param_Include in params then
  begin
   Data[i].Include:=Value.Include;
   Boolean(TDataObject(GetListItemByID(ID).Data).Data^):=Value.Include;
  end;
  if EventID_Param_Attr in params then Data[i].Attr:=Value.Attr;
  if EventID_Param_IsDate in params then Data[i].IsDate:=Value.IsDate;
  if EventID_Param_IsTime in params then Data[i].IsTime:=Value.IsTime;
  if EventID_Param_Groups in params then Data[i].Groups:=Value.Groups;
  if EventID_Param_Links in params then Data[i].Links:=Value.Links;

  if EventID_Param_Date in params then Data[i].Date:=Value.Date;
  if EventID_Param_Time in params then Data[i].Time:=Value.Time;
  if EventID_Param_Rating in params then Data[i].Rating:=Value.Rating;

  if EventID_Param_Rotate in params then
  begin
   ReRotation:=GetNeededRotation(Data[i].Rotation,Value.Rotate);
   Data[i].Rotation:=Value.Rotate;
  end;

  if EventID_Param_Name in params then Data[i].FileName:=Value.Name;
  if EventID_Param_KeyWords in params then Data[i].KeyWords:=Value.KeyWords;
  if EventID_Param_Comment in params then Data[i].Comments:=Value.Comment;


  FileName:=Data[i].FileName;
  Rotate:=Data[i].Rotation;
 end;
                                   
 if [EventID_Param_Rotate]*params<>[] then
 begin
  for i:=0 to Length(Data)-1 do
  if Data[i].ID=ID then
  begin
   if ListView1.Items[i].ImageIndex>-1 then
   begin
    Case ReRotation of
     DB_IMAGE_ROTATED_270: Rotate270A(FBitmapImageList.FImages[ListView1.Items[i].ImageIndex].Bitmap);
     DB_IMAGE_ROTATED_90: Rotate90A(FBitmapImageList.FImages[ListView1.Items[i].ImageIndex].Bitmap);
     DB_IMAGE_ROTATED_180: Rotate180A(FBitmapImageList.FImages[ListView1.Items[i].ImageIndex].Bitmap);
    end;
   end else
   begin         
    SetLength(FilesToUpdate,1);
    FilesToUpdate[0].FileName:=FileName;
    FilesToUpdate[0].Rotation:=Rotate;
    TSearchBigImagesLoaderThread.Create(false,self,SID,nil,fPictureSize,FilesToUpdate,true);
   end;
  end;
 end;

 RefreshParams:=[EventID_Param_Private,EventID_Param_Rotate,EventID_Param_Name,EventID_Param_Rating,EventID_Param_Crypt];
 if RefreshParams*params<>[] then
 begin
  ListView1.Repaint;
 end;

 RefreshParams:=[EventID_Param_Image,EventID_Param_Delete,EventID_Param_Critical];
 if RefreshParams*params<>[] then
 begin
  SetLength(FilesToUpdate,1);

  FilesToUpdate[0].FileName:=FileName;
  FilesToUpdate[0].Rotation:=Rotate;
  TSearchBigImagesLoaderThread.Create(false,self,SID,nil,fPictureSize,FilesToUpdate,true);
 end;
 if ((EventID_Param_Comment in params) or (EventID_Param_KeyWords in params) or (EventID_Param_Rating in params) or (EventID_Param_Date in params) or (EventID_Param_Time in params) or (EventID_Param_IsDate in params) or (EventID_Param_IsTime in params)  or (EventID_Param_Groups in params)) and (ID=current_id_show) then
 ListView1SelectItem(Sender,GetListItemByID(ID),true);

 if (EventID_Param_include in params) then ListView1.Refresh;
end;

procedure TSearchForm.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key='"' then key:='''';
end;

procedure TSearchForm.ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p : Tpoint;
  i, n, MaxH, MaxW, ImH,ImW : integer;
  TempImage, DragImage : TBitmap;
  SelectedItem, item: TEasyItem;
  FileName : string;
  R : TRect;
  EasyRect : TEasyRectArrayObject;
Const
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK+DT_CENTER;

  function GetPictureSize : integer;
  var
    i : integer;
    Item : TEasyItem;
    pass : String;
  begin
   Result:=100;
   Item:= Listview1.Selection.First;
   for i:=0 to Listview1.Selection.Count-1 do
   begin
    if not Data[ItemIndex(Item)].Crypted then
    begin
     Result:=fPictureSize;
     exit;
    end else
    begin
     pass:=DBkernel.FindPasswordForCryptImageFile(Data[ItemIndex(Item)].FileName);
     if Pass<>'' then
     begin
      Result:=fPictureSize;
      exit;
     end;
    end;
    Item:=Listview1.Selection.Next(Item);
    if Item=nil then exit;
   end;
  end;

  function GetImageByIndex(index, ItemIndex : integer) : TBitmap;
  begin
   if Index=-1 then
   begin
    if Data[ItemIndex].Crypted then
    begin
     if DBkernel.FindPasswordForCryptImageFile(Data[ItemIndex].FileName)='' then
     begin
      Result:=TBitmap.Create;
      Result.PixelFormat:=pf24bit;
      Result.Width:=fPictureSize;
      Result.Height:=fPictureSize; 
      FillRectNoCanvas(Result,Dolphin_DB.Theme_ListColor);
      Result.Canvas.Draw(fPictureSize div 2 - image1.picture.Graphic.Width div 2,fPictureSize div 2 - image1.picture.Graphic.Height div 2,image1.picture.Graphic);
      exit;
     end
    end;
    Result:=TBitmap.Create;
    Result.PixelFormat:=pf24bit;
    Result.Width:=image1.picture.Graphic.Width;
    Result.Height:=image1.picture.Graphic.Height;
    FillRectNoCanvas(Result,Dolphin_DB.Theme_ListColor);
    Result.Canvas.Draw(Result.Width div 2 - image1.picture.Graphic.Width div 2,Result.Height div 2 - image1.picture.Graphic.Height div 2,image1.picture.Graphic);
   end else
   begin
    Result:=FBitmapImageList.FImages[index].Bitmap;
    Result:=RemoveBlackColor(Result);
   end;
  end;

begin
 PopupHandled:=false;
 If DBCanDrag then
 begin
  GetCursorPos(p);
  If (Abs(DBDragPoint.x-p.x)>3) or (Abs(DBDragPoint.y-p.y)>3) then
  begin
   p:=DBDragPoint;

   item:=ItemAtPos(ListView1.ScreenToClient(p).x,ListView1.ScreenToClient(p).y);
   if item=nil then exit;
   if Listview1.Selection.FocusedItem=nil then
   Listview1.Selection.FocusedItem:=item;
   //Creating Draw image
   TempImage:=TBitmap.create;
   TempImage.PixelFormat:=pf32bit;
   TempImage.Width:=fPictureSize+Min(ListView1.Selection.Count,10)*7+5;
   TempImage.Height:=fPictureSize+Min(ListView1.Selection.Count,10)*7+45+1;
   MaxH:=0;
   MaxW:=0;
   TempImage.Canvas.Brush.Color := 0;
   TempImage.Canvas.FillRect(Rect(0, 0, TempImage.Width, TempImage.Height));

   if ListView1.Selection.Count<2 then
   begin
    DragImage:=nil;
    if item<>nil then
    DragImage:=GetImageByIndex(item.ImageIndex,item.Index) else
    if ListView1.Selection.First<>nil then
    DragImage:=GetImageByIndex(Listview1.Selection.First.ImageIndex,ItemIndex(Listview1.Selection.First));

    TempImage.Canvas.Draw(0,0, DragImage);
    n:=0;
    MaxH:=DragImage.Height;
    MaxW:=DragImage.Width;
    ImH:=DragImage.Height;
    ImW:=DragImage.Width;
    DragImage.Free;
   end else
   begin
    SelectedItem:=ListView1.Selection.First;
    n:=1;
    for i:=1 to 9 do
    begin
     if SelectedItem<>item then
     begin
      DragImage:=GetImageByIndex(SelectedItem.ImageIndex,ItemIndex(Listview1.Selection.First));
      TempImage.Canvas.Draw(n,n, DragImage);
      Inc(n,7);
      if DragImage.Height+n>MaxH then MaxH:=DragImage.Height+n;
      if DragImage.Width+n>MaxW then MaxW:=DragImage.Width+n;
      DragImage.Free;
     end;
     SelectedItem:=Listview1.Selection.Next(SelectedItem);
     if SelectedItem=nil then break;
    end;
    DragImage:=GetImageByIndex(Listview1.Selection.FocusedItem.ImageIndex,ItemIndex(Listview1.Selection.FocusedItem));
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
   TempImage.Canvas.Brush.Style:=bsClear;
   FileName:=Listview1.Selection.FocusedItem.Caption;
   DrawTextA(TempImage.Canvas.Handle, PChar(FileName), Length(FileName), R, DrawTextOpt);

   DragImageList.Clear;
   DragImageList.Height:=TempImage.Height;
   DragImageList.Width:=TempImage.Width;
   if not IsWindowsVista then
   DragImageList.BkColor:=0;
   DragImageList.Add(TempImage,nil);
   TempImage.Free;

   DropFileSource1.Files.Clear;
   for i:=0 to Length(FilesToDrag)-1 do
   DropFileSource1.Files.Add(FilesToDrag[i]);
   ListView1.Refresh;

   Application.HideHint;
   if ImHint<>nil then
   if not UnitImHint.closed then
   ImHint.close;
   HintTimer.Enabled:=false;

   item.ItemRectArray(nil,ListView1.Canvas,EasyRect);

   DBDragPoint:=ListView1.ScreenToClient(DBDragPoint);

   ImW:=(EasyRect.IconRect.Right-EasyRect.IconRect.Left) div 2 - ImW div 2;
   ImH:=(EasyRect.IconRect.Bottom-EasyRect.IconRect.Top) div 2 - ImH div 2;
   DropFileSource1.ImageHotSpotX:=Min(MaxW,Max(1,DBDragPoint.X-EasyRect.IconRect.Left+n-ImW));
   DropFileSource1.ImageHotSpotY:=Min(MaXH,Max(1,DBDragPoint.Y-EasyRect.IconRect.Top+n-ImH+ListView1.Scrollbars.ViewableViewportRect.Top));

   DropFileSource1.Execute;
   DBCanDrag:=false;
  end;
 end;

 if ImHint<>nil then
 begin
  GetCursorPos(p);
  if WindowFromPoint(p)=ImHint.Handle then exit;
 end;

 if LoadingThItem=ItemByPointImage(ListView1,Point(X,Y)) then exit;
 LoadingThItem:=ItemByPointImage(ListView1,Point(X,Y));
 if LoadingThItem=nil then
 begin
  Application.HideHint;
  if ImHint<>nil then
  if not UnitImHint.closed then
  ImHint.close;
  HintTimer.Enabled:=false;
 end else begin

  HintTimer.Enabled:=false;
  if Active then
  begin
   if DBKernel.Readbool('Options','AllowPreview',True) then
   HintTimer.Enabled:=true;
   ShLoadingThItem:=LoadingThItem;
  end;
  if LoadingThItem<>nil then
  if DBKernel.Readbool('Options','AllowPreview',True) then
  if ItemIndex(LoadingThItem)<Length(Data) then
  ListView1.ShowHint:= not FileExists(Data[ItemIndex(loadingthitem)].FileName) else
  ListView1.ShowHint:=true;
  if LoadingThItem<>nil then
  begin
   if ItemIndex(LoadingThItem)<Length(Data)-1 then
   if ItemIndex(LoadingThItem)>-1 then
   ListView1.Hint:=Data[ItemIndex(LoadingThItem)].Comments;
  end;
 end;
end;

procedure TSearchForm.PopupMenu2Popup(Sender: TObject);
var
  i : integer;
begin        

 HintTimer.Enabled:=false;
 WorkedFiles_.Clear;
 if ListView1Selected=nil then

 if Length(Data)=ListView1.Items.Count then
 begin
  for i:=1 to ListView1.Items.Count do
  WorkedFiles_.Add(Data[ItemIndex(ListView1.Items[i-1])].FileName);
  end else
  begin
  if SelCount=1 then
  begin
   WorkedFiles_:=GetAllFiles;
   end else begin
   WorkedFiles_:=GetSelectedTstrings;
  end;
 end;

 if WorkedFiles_.count=0 then
 begin
 SlideShow1.Visible:=false;
 SelectAll1.Visible:=false;
  end else
 begin
  SlideShow1.Visible:=true;
  SelectAll1.Visible:=true;
 end;

 SelectAll1.Visible:=SelectAll1.Visible and not FUpdatingDB;
 SaveasTable1.Visible:=False;
 SaveResults1.Visible:=false;
 if ListView1.Items.Count>0 then
 begin        
  SaveAsTable1.Visible:=True;
  SaveResults1.Visible:=True;
 end;

 SaveResults1.Visible:=not FolderView;
 GetPhotosFromDrive1.Visible:=not FolderView;
end;

procedure TSearchForm.Options1Click(Sender: TObject);
begin
 DoOptions;
end;

procedure TSearchForm.CopySearchResults1Click(Sender: TObject);
var
  i : integer;
begin
 Sclipbrd:='';
 for i:=1 to ListView1.Items.Count do
 Sclipbrd:=Sclipbrd+IntTostr(ListView1.Items[i-1].Tag)+'$';
 Sclipbrd:=Sclipbrd+'';
end;

procedure TSearchForm.HintTimerTimer(Sender: TObject);
var
  p, p1 : tpoint;
  Index, i : Integer;
  item: TEasyItem;
begin
 GetCursorPos(p);
 p1:=ListView1.ScreenToClient(p);

 if (not Active) or (not ListView1.Focused) or (ItemAtPos(p1.X,p1.y)<>LoadingThItem) or (shloadingthitem<>LoadingThItem) then

 begin
  HintTimer.Enabled:=false;
  exit;
 end;

 if FPictureSize>=Dolphin_DB.ThHintSize then exit;

 if LoadingThItem=nil then exit;
 if ItemIndex(LoadingThItem)<0 then exit;
 HintTimer.Enabled:=false;
 UnitHintCeator.fItem:= LoadingThItem;
 Index:=ItemIndex(LoadingThItem);
 if (Index<0) or (Index>Length(Data)-1) then Exit;
 UnitHintCeator.fInfo:=RecordInfoOne(ProcessPath(Data[Index].FileName),Data[Index].ID,Data[Index].Rotation,Data[Index].Rating,Data[Index].Access,Data[Index].FileSize,Data[index].Comments,Data[index].KeyWords,'','',Data[index].Groups,Data[index].Date,Data[index].IsDate ,Data[index].IsTime,Data[index].Time, Data[index].Crypted, Data[index].Include, true, Data[index].Links);
 UnitHintCeator.ThRect:=rect(p.X,p.Y,p.x+ThSize,p.Y+ThSize);
 UnitHintCeator.Work_.Add(ProcessPath(Data[Index].FileName));
 UnitHintCeator.Owner:=Self;
 UnitHintCeator.hr:=HintRealA;

  Item:=ItemAtPos(p1.x,p1.y);
  if item=nil then exit;

  if DBKernel.Readbool('Options','UseHotSelect',true) then

  if not (CtrlKeyDown or ShiftKeyDown) then
  if not LoadingThItem.Selected then
  begin
   if not (CtrlKeyDown or ShiftKeyDown) then
   for i:=0 to Listview1.Items.Count-1 do
   if Listview1.Items[i].Selected then
   if LoadingThItem<>Listview1.Items[i] then
   Listview1.Items[i].Selected:=false;
   if ShiftKeyDown then
    Listview1.Selection.SelectRange(LoadingThItem,Listview1.Selection.FocusedItem,false,false) else
   if not ShiftKeyDown then
   begin
    LoadingThItem.Selected:=true;
   end;
  end;
  LoadingThItem.Focused:=true;

  HintCeator.Create(false);
end;

procedure TSearchForm.FormDeactivate(Sender: TObject);
begin
 hinttimer.Enabled:=false;
end;

function TSearchForm.HintRealA(item: TObject): boolean;
var
  p, p1 : tpoint;
begin
 getcursorpos(p);
 p1:=listview1.ScreenToClient(p);
 result:=not ((not self.Active) or (not listview1.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (ItemAtPos(p1.X,p1.y)=nil) or (item<>loadingthitem));
end;

procedure TSearchForm.initialization_;
var
  s : string;
begin
 If DBTerminating then exit;
 DBCanDrag:=false;
 DBKernel.RegisterChangesID(self,ChangedDBDataByID);
 Caption:=ProductName+' - '+DBKernel.DBUserName+'  ['+DBkernel.GetDataBaseName+']';
 if (DBKernel.DBUserType=UtAdmin) and (DBKernel.DBUserName<>TEXT_MES_ADMIN) then
 Caption:=Caption+' ('+TEXT_MES_ADMIN+')';
 if DBKernel.DBUserType=UtUser then
 Caption:=Caption+' ('+TEXT_MES_USER+')';
 if DBKernel.DBUserType=UtGuest then
 Caption:=Caption+' ('+TEXT_MES_GUEST+')';
 DoShowSelectInfo;
 ListView1.Canvas.Pen.Color:=$0;
 ListView1.Canvas.brush.Color:=$0;
 button1.onclick:= Search;
 button1.caption:=TEXT_MES_SEARCH;
 Label7.Caption:=TEXT_MES_NO_RES;
 DmProgress1.Text:=TEXT_MES_NO_RES;
 SaveWindowPos1.Key:=RegRoot+'Searching';
 if not SafeMode then
 SaveWindowPos1.SetPosition;
 if not SafeMode then
 Reloadtheme(nil);

 SortLink.UseSpecIconSize:=true;
 SortLink.SetDefault;

 Foperations:=0;
 WorkedFiles_:=TstringList.Create;
 ListView1.DoubleBuffered:=true;
                          
 CheckBox6.Caption:=TEXT_MES_SHOW_LAST;
 ComboBox5.Clear;
 ComboBox5.Items.Add(TEXT_MES_SHOW_LAST_DAYS);
 ComboBox5.Items.Add(TEXT_MES_SHOW_LAST_WEEKS);
 ComboBox5.Items.Add(TEXT_MES_SHOW_LAST_MONTH);
 ComboBox5.Items.Add(TEXT_MES_SHOW_LAST_YEARS);



 PopupMenu2.Images:=DBKernel.ImageList;
 PopupMenu8.Images:=DBKernel.ImageList;
 MainMenu1.Images:=DBKernel.ImageList;
 SlideShow1.ImageIndex:=DB_IC_SLIDE_SHOW;
 SelectAll1.ImageIndex:=DB_IC_SELECTALL;
 ManageDB1.ImageIndex:=DB_IC_ADMINTOOLS;
 ManageDB2.ImageIndex:=DB_IC_ADMINTOOLS;
 Options1.ImageIndex:=DB_IC_OPTIONS;
 CopySearchResults1.ImageIndex:=DB_IC_COPY;
 LoadResults1.ImageIndex:=DB_IC_LOADFROMFILE;
 SaveResults1.ImageIndex:=DB_IC_SAVETOFILE;
 NewPanel1.ImageIndex:=DB_IC_PANEL;
 Help1.ImageIndex:=DB_IC_HELP;
 Explorer1.ImageIndex:=DB_IC_EXPLORER;
 ShowUpdater1.ImageIndex:=DB_IC_BOX;
 SaveasTable1.ImageIndex:=DB_IC_SAVE_AS_TABLE;
 OpeninExplorer1.ImageIndex:=DB_IC_EXPLORER;
 AddFolder1.ImageIndex:=DB_IC_ADD_FOLDER;
 GroupsManager2.ImageIndex:=DB_IC_GROUPS;
 Help2.ImageIndex:=DB_IC_HELP;
 Activation1.ImageIndex:=DB_IC_NOTES;
 About1.ImageIndex:=DB_IC_HELP;
 HomePage1.ImageIndex:=DB_IC_NETWORK;
 NewSearch1.ImageIndex:=DB_IC_ADDTODB;
 ContactWithAuthor1.ImageIndex:=DB_IC_E_MAIL;
 GetUpdates1.ImageIndex:=DB_IC_UPDATING;
 ImageEditor1.ImageIndex:=DB_IC_IMEDITOR;
 GetPhotosFromDrive1.ImageIndex:=DB_IC_GET_USB;

 Help4.ImageIndex:=DB_IC_HELP;
 Activation2.ImageIndex:=DB_IC_NOTES;
 About2.ImageIndex:=DB_IC_HELP;
 HomePage2.ImageIndex:=DB_IC_NETWORK;
 ContactWithAuthor2.ImageIndex:=DB_IC_E_MAIL;
 GetUpdates2.ImageIndex:=DB_IC_UPDATING;
 Exit1.ImageIndex:=DB_IC_EXIT;
 LoadResults2.ImageIndex:=DB_IC_LOADFROMFILE;
 SaveResults2.ImageIndex:=DB_IC_SAVETOFILE;
 ShowExplorerPage1.ImageIndex:=DB_IC_EXPLORER_PANEL;

 NewPanel2.ImageIndex:=DB_IC_PANEL;
 NewSearch2.ImageIndex:=DB_IC_ADDTODB;
 GroupsManager3.ImageIndex:=DB_IC_GROUPS;
 Explorer3.ImageIndex:=DB_IC_EXPLORER;
 Options2.ImageIndex:=DB_IC_OPTIONS;

 RemovableDrives1.ImageIndex:=DB_IC_USB;
 CDROMDrives1.ImageIndex:=DB_IC_CD_ROM;
 SpecialLocation1.ImageIndex:=DB_IC_DIRECTORY;
 SortbyCompare1.ImageIndex:=DB_IC_DUBLICAT;
 RemovableDrives2.ImageIndex:=DB_IC_USB;
 CDROMDrives2.ImageIndex:=DB_IC_CD_ROM;
 SpecialLocation2.ImageIndex:=DB_IC_DIRECTORY;

 GetListofKeyWords1.ImageIndex:=DB_IC_SEARCH;
 DBTreeView1.ImageIndex:=DB_IC_TREE;
 ImageEditor2.ImageIndex:=DB_IC_IMEDITOR;

 View2.ImageIndex:=DB_IC_SLIDE_SHOW;

 RatingPopupMenu1.Images:=DBkernel.ImageList;

 N00.ImageIndex:=DB_IC_DELETE_INFO;
 N01.ImageIndex:=DB_IC_RATING_1;
 N02.ImageIndex:=DB_IC_RATING_2;
 N03.ImageIndex:=DB_IC_RATING_3;
 N04.ImageIndex:=DB_IC_RATING_4;
 N05.ImageIndex:=DB_IC_RATING_5;

 SlideShow1.ImageIndex:=DB_IC_SLIDE_SHOW;
 SelectAll1.ImageIndex:=DB_IC_SELECTALL;
 ManageDB1.ImageIndex:=DB_IC_ADMINTOOLS;
 ManageDB2.ImageIndex:=DB_IC_ADMINTOOLS;
 Options1.ImageIndex:=DB_IC_OPTIONS;

 ShowDateOptionsLink.Icon:=(UnitDBKernel.icons[DB_IC_EDIT_DATE+1]);

 BackGroundSearchPanelResize(Nil);
 Splitter1Moved(nil);
 DoUnLockInfo;
 Image3.Picture.Graphic:=TIcon.Create;
 DBkernel.ImageList.GetIcon(DB_IC_GROUPS,Image3.Picture.Icon);

 Creating:=false;
end;

procedure TSearchForm.CMMOUSELEAVE(var Message: TWMNoParams);
var
  p : tpoint;
  r : trect;
begin
 if ImHint=nil then exit;
 r:=rect(ImHint.left,ImHint.top,ImHint.left+ImHint.width, ImHint.top+ImHint.height);
 getcursorpos(p);
 if PtInRect(r,p) then
 begin
  exit;
 end;
 loadingthitem:= nil;
 if Active then
 application.HideHint;
 ImHint.close;
 hinttimer.Enabled:=false;
end;

procedure TSearchForm.NewPanel1Click(Sender: TObject);
begin
 ManagerPanels.NewPanel.Show;
end;

procedure TSearchForm.SaveResults1Click(Sender: TObject);
var
  n,i : integer;
  l : TArStrings;
  ItemsImThArray : TArStrings;
  ItemsIDArray : TArInteger;
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith';
 SaveDialog.FilterIndex:=1;

 if SaveDialog.Execute then
 begin
  n:=SaveDialog.GetFilterIndex;
  if n=1 then
  begin
   FileName:=SaveDialog.FileName;
   if GetExt(FileName)<>'IDS' then
   FileName:=FileName+'.ids';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;

   SetLength(ItemsIDArray,Length(Data));
   for i:=0 to Length(Data)-1 do
   ItemsIDArray[i]:=Data[i].ID;

   SaveIDsTofile(FileName,ItemsIDArray);
  end;
  if n=2 then
  begin
   SetLength(l,0);
   FileName:=SaveDialog.FileName;
   if GetExt(FileName)<>'DBL' then
   FileName:=FileName+'.dbl';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;

   SetLength(ItemsIDArray,Length(Data));
   for i:=0 to Length(Data)-1 do
   ItemsIDArray[i]:=Data[i].ID;

   SaveListTofile(FileName,ItemsIDArray,l);
  end;
  if n=3 then
  begin
   FileName:=SaveDialog.FileName;
   if GetExt(FileName)<>'ITH' then
   FileName:=FileName+'.ith';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;

   SetLength(ItemsImThArray,Length(Data));
   for i:=0 to Length(Data)-1 do
   ItemsImThArray[i]:=Data[i].ImTh;

   SaveImThsTofile(FileName,ItemsImThArray);
  end;
 end;
 SaveDialog.Free;
end;

procedure TSearchForm.LoadResults1Click(Sender: TObject);
var
  IDs : TArInteger;
  Files : TArStrings;
  S : string;
  i : integer;
  OpenDialog : DBOpenDialog;
begin
 if FUpdatingDB then exit;

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='All Supported (*.ids;*.ith;*.dbl)|*.ids;*.ith;*.dbl|DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith';
 OpenDialog.FilterIndex:=1;

 if OpenDialog.Execute then
 begin
  If GetExt(OpenDialog.FileName)='IDS' then
  begin
   SearchEdit.Text:=LoadIDsFromfile(OpenDialog.FileName);
   DoSearchNow(nil);
  end;
  If GetExt(OpenDialog.FileName)='DBL' then
  begin
   LoadDblFromfile(OpenDialog.FileName,IDs,Files);
   s:='';
   for i:=0 to length(IDs)-1 do
   s:=s+IntToStr(IDs[i])+'$';
   SearchEdit.Text:=s;
   DoSearchNow(nil);
  end;
  If GetExt(OpenDialog.FileName)='ITH' then
  begin
   SearchEdit.Text:=':ThFile('+OpenDialog.FileName+'):';
   DoSearchNow(nil);
  end;
 end;
 OpenDialog.Free;
end;

procedure TSearchForm.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
 if DBkernel.ReadString('Options','SaveLogErrors')<>'' then
 begin
  Dolphin_DB.EventLog('Error ['+DateTimeToStr(Now)+'] = '+e.Message);
 end;
end;

procedure TSearchForm.Help1Click(Sender: TObject);
begin
 DoAbout;
end;

procedure TSearchForm.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  If LockChangePath then Exit;
  If Creating then Exit;
  if FUpdatingDB then Exit;
  SearchEdit.Text:=':folder('+ShellTreeView1.Path+'):';
  DoSearchNow(Sender);
end;

procedure TSearchForm.RenameCurrentItem(Sender: TObject);
begin
 if ListView1.Selection.First=nil then exit;
 ListView1.EditManager.Enabled:=true;
end;

procedure TSearchForm.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
 If key=#13 then ListView1DblClick(Sender);
 if Key in Unusedchar then key:=#0;
 //TODO: contex menu popup
end;

procedure TSearchForm.ListView1Edited(Sender: TObject; Item: TEasyItem;
  var S: String);
begin
 s:=copy(s,1,min(length(s),255));
 if AnsiLowerCase(s)=AnsiLowerCase(GetFileName(Data[ItemIndex(Item)].FileName)) then exit;
 begin
  If GetExt(s)<>GetExt(Data[ItemIndex(Item)].FileName) then
  If FileExists(Data[ItemIndex(Item)].FileName) then
  begin
   If ID_OK<>MessageBoxDB(Handle,TEXT_MES_REPLACE_EXT,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
   begin
    s:=GetFileName(Data[ItemIndex(Item)].FileName);
    Exit;
   end;
  end;
  RenameResult:=RenameFileWithDB(Data[ItemIndex(Item)].FileName,GetDirectory(Data[ItemIndex(Item)].FileName)+s, Item.Tag,false);
 end;
end;

procedure TSearchForm.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

 if ListView1Selected=nil then exit;

 if Ord(Key) = VK_F2 then
 if SelCount=1 then


  ListView1.EditManager.Enabled:=true;
  ListView1.Selection.First.Edit;

 if Active then
 Application.HideHint;
 if ImHint<>nil then
 if not UnitImHint.closed then
 ImHint.close;
end;

procedure TSearchForm.Explorer1Click(Sender: TObject);
begin
 NewExplorer;
end;

function TSearchForm.GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
var
  i , MenuLength : integer;
begin
 Result.Position:=0;
 Result.IsListItem:=false;
 Result.IsPlusMenu:=false;
 MenuLength:=Length(Data);
 if MenuLength<ListView1.Items.Count then exit;
 SetLength(Result.ItemFileNames_,MenuLength);
 SetLength(Result.ItemComments_,MenuLength);
 SetLength(Result.ItemFileSizes_,MenuLength);
 SetLength(Result.ItemRotations_,MenuLength);
 SetLength(Result.ItemIDs_,MenuLength);
 SetLength(Result.ItemSelected_,MenuLength);
 SetLength(Result.ItemAccess_,MenuLength);
 SetLength(Result.ItemRatings_,MenuLength);
 SetLength(Result.ItemDates_,MenuLength);
 SetLength(Result.ItemIsDates_,MenuLength);
 SetLength(Result.ItemTimes_,MenuLength);
 SetLength(Result.ItemIsTimes_,MenuLength);
 SetLength(Result.ItemGroups_,MenuLength);
 SetLength(Result.ItemLinks_,MenuLength);
 SetLength(Result.ItemCrypted_,MenuLength);
 SetLength(Result.ItemInclude_,MenuLength);
 SetLength(Result.ItemKeyWords_,MenuLength);
 SetLength(Result.ItemAttr_,MenuLength);
 SetLength(Result.ItemLoaded_,MenuLength);
 Result.PlusMenu:=nil;
 Result.IsDateGroup:=True;
 For i:=0 to MenuLength-1 do
 begin
  Result.ItemFileNames_[i]:=ProcessPath(Data[i].FileName);
  Result.ItemComments_[i]:=Data[i].Comments;
  Result.ItemFileSizes_[i]:=Data[i].FileSize;
  Result.ItemRotations_[i]:=Data[i].Rotation;
  Result.ItemIDs_[i]:=Data[i].ID;
  Result.ItemAccess_[i]:=Data[i].Access;
  Result.ItemRatings_[i]:=Data[i].Rating;
  Result.ItemDates_[i]:=Data[i].Date;
  Result.ItemTimes_[i]:=Data[i].Time;
  Result.ItemIsDates_[i]:=Data[i].IsDate;
  Result.ItemIsTimes_[i]:=Data[i].IsTime;
  Result.ItemGroups_[i]:=Data[i].Groups;
  Result.ItemCrypted_[i]:=Data[i].Crypted;
  Result.ItemKeyWords_[i]:=Data[i].KeyWords;
  Result.ItemAttr_[i]:=Data[i].Attr;
  Result.ItemLoaded_[i]:=true;
  Result.ItemInclude_[i]:=Data[i].Include;
  Result.ItemLinks_[i]:=Data[i].Links;
 end;
 Result.IsAttrExists:=true;
 For i:=0 to ListView1.Items.Count-1 do
 if ListView1.Items[i].Selected then
 Result.ItemSelected_[i]:=true else
 Result.ItemSelected_[i]:=false;
 If Item=nil then
 begin
 end else
 begin
  if SelCount=1 then
  begin
   Result.IsListItem:=true;
   if ListView1.Selection.First<>nil then
   begin
    Result.ListItem:=ListView1.Selection.First;
    Result.Position:=ItemIndex(ListView1.Selection.First);
   end;
  end;
  if SelCount>1 then
  begin
   Result.Position:=ItemIndex(Item);
  end;
 end;
end;

procedure TSearchForm.ListView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Handled : boolean;
  i : integer;
  item: TEasyItem;
begin

   item:=self.ItemAtPos(X,Y);
   if item<>nil then
   if item.Selected then
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
    if ([ssCtrl]*Shift<>[]) and not ItemSelectedByMouseDown and (Button=mbLeft) then
    item.Selected:=false;
   end;

 if MouseDowned then
 if Button=mbRight then
 begin
  ListView1ContextPopup(ListView1,Point(X,Y),Handled);
  PopupHandled:=true;
 end;
 MouseDowned:=false;
 DBCanDrag:=false;
 SetLength(FilesToDrag,0);
end;

procedure TSearchForm.ListView1Exit(Sender: TObject);
begin
 DBCanDrag:=false;
 SetLength(FilesToDrag,0);
end;

procedure TSearchForm.Properties1Click(Sender: TObject);
begin
 if SelCount>1 then
 PropertyPanel.Visible:=true;
 ExplorerPanel.Visible:=false;
 Properties1.Checked:=true;
 Explorer2.Checked:=false;
 ShowExplorerPage1.Checked:=false;
 ShowExplorerPage1.ImageIndex:=DB_IC_EXPLORER_PANEL;
end;

procedure TSearchForm.Explorer2Click(Sender: TObject);
begin
 ShowExplorerPage1.Checked:=true;
 ShowExplorerPage1.ImageIndex:=-1;
 PropertyPanel.Visible:=false;
 ExplorerPanel.Visible:=true;
 if not ShellTreeView1.UseShellImages then
 begin
  ShellTreeView1.ObjectTypes:=[otFolders];
  ShellTreeView1.UseShellImages:=true;
  ShellTreeView1.Refresh(ShellTreeView1.TopItem);
 end;
 ExplorerPanel.Align:=AlClient;
 Properties1.Checked:=false;
 Explorer2.Checked:=true;
 ShellTreeView1.FullCollapse;
 if FSearchPath<>'' then
 if DirectoryExists(FSearchPath) then
 ShellTreeView1.Path:=FSearchPath;
end;

procedure TSearchForm.SearchPanelAContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
Var
  WHandle : THandle;
begin
 WHandle:=WindowFromPoint(SearchPanelA.ClientToScreen(MousePos));
 if WHandle<>SearchEdit.Handle then
 PopupMenu1.Popup(SearchPanelA.ClientToScreen(MousePos).X,SearchPanelA.ClientToScreen(MousePos).Y);
end;

procedure TSearchForm.Rating1MouseDown(Sender: TObject);
begin
  if Rating1.islayered then Rating1.islayered:=false;
  Memo1Change(Sender);
end;

procedure TSearchForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  i : integer;
  b : Boolean;
begin

 begin
  if Msg.message=WM_KEYDOWN then
  if SearchEdit.Focused then
  begin
   if Msg.wParam=13 then
   begin
    DoSearchNow(nil);
    Handled:=true;
    Msg.Message:=0;
   end;
  end;
  if Msg.message=WM_KEYUP then
  if SearchEdit.Focused then
  Msg.Message:=0;
 end;
 if Msg.hwnd=ListView1.Handle then
 begin
  if Msg.message=516 then
  begin
   WindowsMenuTickCount:=GetTickCount;
  end;

  //middle mouse button
  if Msg.message=519 then
  begin
   Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
   BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
   Msg.message:=0;
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
 end;


 if Msg.hwnd=FFirstTip_WND then
 if msg.message=275 then
 if msg.WParam=4 then
 SendMessage(FFirstTip_WND, WM_CLOSE,1,1);

 if Msg.hwnd=ListView1.Handle then
 if Msg.message=256 then
 begin             
  WindowsMenuTickCount:=GetTickCount;
  //93-context menu button
  if (Msg.wParam=93) then
  begin
   ListView1ContextPopup(ListView1,Point(-1,-1),b);
  end;
  if (Msg.wParam=Ord('r')) or (Msg.wParam=Ord('R')) then
  if ShiftkeyDown then
  begin
   ReloadIDMenu;
   ReloadListMenu;
   MessageBoxDB(Handle,TEXT_MES_MENU_RELOADED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
  end;         
  //109-
  if (Msg.wParam=109) then ZoomIn; 
  //107+
  if (Msg.wParam=107) then ZoomOut;
  
  //Del  --->  delete selected
  if (Msg.wParam=46) and not FUpdatingDB then DeleteSelected;

  //Ctrl+a  --->  select all
  if (Msg.wParam=65) and CtrlKeyDown and not FUpdatingDB then SelectAll1Click(Nil);

  //Ctrl+s  --->  stop loading
  if (Msg.wParam=83) and CtrlKeyDown then
  if ToolButton14.Enabled then ToolButton14Click(nil);

 end;
end;

procedure TSearchForm.DoLockInfo;
begin
 FLockInfo:=True;
end;

procedure TSearchForm.DoUnLockInfo;
begin
 FLockInfo:=False;
end;

function TSearchForm.LockInfo: Boolean;
begin
 Result:=FLockInfo;
end;

procedure TSearchForm.SetPath(Value: String);
begin
 formatDir(Value);
 FSearchPath := Value;
 LockChangePath:=true;
 If ExplorerPanel.Visible then
 ShellTreeView1.Path:=Value;
 LockChangePath:=false;
end;

procedure TSearchForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 SearchManager.RemoveSearch(Self);
 Hide;
 if FUpdatingDB then
 begin
  DestroyTimer.Interval:=100;
  DestroyCounter:=1;
 end;
 DestroyTimer.Enabled:=true;
end;

procedure MakePermTable(Qry: TQuery; PermTableName: string);
var
  h: HDBICur;
begin
 if Qry.Active then Qry.Close;
 Qry.Prepare;
 dbiQExec(Qry.StmtHandle, @h);
 DbiMakePermanent(h, PChar(PermTableName), True);
end;

procedure TSearchForm.SaveAsTable1Click(Sender: TObject);
var
  FileList : TArStrings;
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';
 if ListView1.Items.Count>0 then
 begin
  if SaveDialog.Execute then
  begin
   FileName:=SaveDialog.FileName;
   if GetExt(FileName)<>'PHOTODB' then
   FileName:=FileName+'.photodb';

   SetLength(FileList,0);
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_1,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
   SaveQuery(ThreadQuery, FileName,false,FileList);
  end;
 end else
 begin
  MessageBoxDB(Handle,TEXT_MES_NO_RECORDS_FOUNDED_TO_SAVE,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
 end;
 SaveDialog.Free;
end;

procedure TSearchForm.Datenotexists1Click(Sender: TObject);
begin
 IsDatePanel.Visible:=True;
 Memo1Change(Sender);
end;

procedure TSearchForm.IsDatePanelDblClick(Sender: TObject);
begin
 If FUpdatingDB then Exit;
 IsDatePanel.Visible:=False;
 Memo1Change(Sender);
end;

procedure TSearchForm.PanelValueIsDateSetsDblClick(Sender: TObject);
begin
 If FUpdatingDB then Exit;
 PanelValueIsDateSets.Visible:=false;
 Memo1Change(Sender);
end;

procedure TSearchForm.BeginUpdate;
begin
 fListUpdating:=true;
 ListView1.Groups.BeginUpdate(false);
 BackGroundSearchPanel.Visible:=True;
 ListView1.Visible:=false;
end;

procedure TSearchForm.EndUpdate;
begin
 fListUpdating:=false;
 ListView1.Visible:=true;
 BackGroundSearchPanel.Visible:=False;
 ListView1.Groups.EndUpdate;
end;

procedure TSearchForm.BackGroundSearchPanelResize(Sender: TObject);
begin
 LabelBackGroundSearching.Top:=BackGroundSearchPanel.Height div 2+128 div 2;
 LabelBackGroundSearching.Left:=BackGroundSearchPanel.Width div 2-LabelBackGroundSearching.Width div 2;
 Image2.Top:=BackGroundSearchPanel.Height div 2-128 div 2;
 Image2.Left:=BackGroundSearchPanel.Width div 2-128 div 2;
end;

procedure TSearchForm.BackGroundSearchPanelContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
 LoadingThItem:= nil;
 if Active then
 Application.HideHint;
 if ImHint<>nil then
 ImHint.close;
 HintTimer.Enabled:=false;
 PopupMenu2.Popup(BackGroundSearchPanel.ClientToScreen(MousePos).x,BackGroundSearchPanel.ClientToScreen(MousePos).y);
end;

procedure TSearchForm.LabelBackGroundSearchingContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
 LoadingThItem:= nil;
 if Active then
 Application.HideHint;
 if ImHint<>nil then
 ImHint.close;
 HintTimer.Enabled:=false;
 PopupMenu2.Popup(LabelBackGroundSearching.ClientToScreen(MousePos).x,LabelBackGroundSearching.ClientToScreen(MousePos).y);
end;

procedure TSearchForm.ComboBox1_KeyPress(Sender: TObject; var Key: Char);
begin
 Key:=#0;
end;

procedure TSearchForm.ReloadGroups;
var
  i : integer;
  FCurrentGroups : TGroups;
begin
 FCurrentGroups:=EncodeGroups(FPropertyGroups);
 ComboBoxSelGroups.Items.Clear;
 For i:=0 to Length(FCurrentGroups)-1 do
 begin
  ComboBoxSelGroups.ItemsEx.Add().Caption:=FCurrentGroups[i].GroupName;
 end;

 ComboBoxSelGroups.ItemsEx.Add().Caption:=TEXT_MES_MANAGEA;

 ComboBoxSelGroups.Text:=TEXT_MES_GROUPSA;
end;

procedure TSearchForm.ComboBox1_Select(Sender: TObject);
var
  KeyWords : string;
begin
 Application.ProcessMessages;
 if ComboBoxSelGroups.ItemsEx.Count=0 then exit;
 if ComboBoxSelGroups.ItemIndex<>-1 then
 if (ComboBoxSelGroups.Text=ComboBoxSelGroups.ItemsEx[ComboBoxSelGroups.Items.Count-1].Caption) and (ComboBoxSelGroups.ItemsEx[ComboBoxSelGroups.ItemIndex].ImageIndex=0) then
 begin
  KeyWords:=Memo1.Text;
  DBChangeGroups(FPropertyGroups,KeyWords);
  Application.ProcessMessages;
  Memo1.Text:=KeyWords;
  ReloadGroups;
  Memo1Change(Sender);
 end else
 begin
  ShowGroupInfo(ComboBoxSelGroups.Text,false,nil);
 end;
 ComboBoxSelGroups.ItemIndex:=0;
 ComboBoxSelGroups.LastItemIndex:=0;
 ComboBoxSelGroups.Text:=TEXT_MES_GROUPSA;
end;

procedure TSearchForm.ComboBox1_DblClick(Sender: TObject);
var
  KeyWords : string;
begin
 KeyWords:=Memo1.Text;
 DBChangeGroups(FPropertyGroups,KeyWords);
 Memo1.Text:=KeyWords;
 ReloadGroups;
 Memo1Change(Sender);
end;

procedure TSearchForm.GroupsManager1Click(Sender: TObject);
begin
 ExecuteGroupManager;
end;

procedure TSearchForm.DateExists1Click(Sender: TObject);
begin
 IsDatePanel.Visible:=False;
 Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu3Popup(Sender: TObject);
begin
 DateNotExists1.Visible:=not IsDatePanel.Visible;
 DateExists1.Visible:=IsDatePanel.Visible;
 DateExists1.Visible:=DateExists1.Visible and not FUpdatingDB;
 Datenotsets1.Visible:=Datenotsets1.Visible and not FUpdatingDB;
 Datenotsets1.Visible:=Datenotsets1.Visible and (SelCount>1) and not FUpdatingDB;
end;

procedure TSearchForm.Ratingnotsets1Click(Sender: TObject);
begin
 Rating1.Islayered:=True;
 Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu5Popup(Sender: TObject);
begin
 Ratingnotsets1.Visible:=not Rating1.Islayered and not FUpdatingDB;
 if SelCount<2 then Ratingnotsets1.Visible:=False;
end;

procedure TSearchForm.MenuItem2Click(Sender: TObject);
begin
 Memo2.SelectAll;
end;

procedure TSearchForm.Cut1Click(Sender: TObject);
begin
 Memo2.CutToClipboard;
end;

procedure TSearchForm.Copy2Click(Sender: TObject);
begin
 Memo2.CopyToClipboard;
end;

procedure TSearchForm.Paste1Click(Sender: TObject);
begin
 Memo2.PasteFromClipboard;
end;

procedure TSearchForm.Undo1Click(Sender: TObject);
begin
 Memo2.Undo;
end;

procedure TSearchForm.SetComent1Click(Sender: TObject);
begin
 if not Memo2.ReadOnly then exit;
 Memo2.ReadOnly:=False;
 Memo2.Cursor:=CrDefault;
 Memo2.Text:='';
 SelectedInfo.CommonComment:='';
 CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
 Memo1Change(Sender);
end;

procedure TSearchForm.Comentnotsets1Click(Sender: TObject);
begin
 Memo2.ReadOnly:=True;
 Memo2.Cursor:=CrHandPoint;
 Memo2.Text:=TEXT_MES_VAR_COM;
 SelectedInfo.CommonComment:=TEXT_MES_VAR_COM;
 CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
 Memo1Change(Sender);
end;

procedure TSearchForm.Datenotsets1Click(Sender: TObject);
begin
 PanelValueIsDateSets.Visible:=True;
 Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu6Popup(Sender: TObject);
begin
 SetComent1.Visible:=Memo2.ReadOnly;
 Comentnotsets1.Visible:=not Memo2.ReadOnly;
 MenuItem2.Visible:=not Memo2.ReadOnly;
 Cut1.Visible:=not Memo2.ReadOnly;
 Copy2.Visible:=not Memo2.ReadOnly;
 Paste1.Visible:=not Memo2.ReadOnly;
 Undo1.Visible:=not Memo2.ReadOnly;
end;

procedure TSearchForm.LoadLanguage;
begin
 LabelBackGroundSearching.Caption:=TEXT_MES_SERCH_PR;
 Label1.Caption:=TEXT_MES_SEARCH_TEXT;
 Label2.Caption:=TEXT_MES_IDENT;
 Label7.Caption:=TEXT_MES_RESULT;
 Label8.Caption:=TEXT_MES_RATING;

 Label4.Caption:=TEXT_MES_SIZE;
 Label6.Caption:=TEXT_MES_COMMENTS;
 Label5.Caption:=TEXT_MES_KEYWORDS;
 Save.Caption:=TEXT_MES_SAVE;
 SlideShow1.Caption:=TEXT_MES_SLIDE_SHOW;
 SelectAll1.Caption:=TEXT_MES_SELECT_ALL;
 ShowUpdater1.Caption:=TEXT_MES_SHOW_UPDATER;
 Help1.Caption:=TEXT_MES_HELP;
 ManageDB1.Caption:=TEXT_MES_MANAGE_DB;
 ManageDB2.Caption:=TEXT_MES_MANAGE_DB;
 Options1.Caption:=TEXT_MES_OPTIONS;
 SaveasTable1.Caption:=TEXT_MES_SAVE_AS_TABLE;
 CopySearchResults1.Caption:=TEXT_MES_LOAD_RES;
 LoadResults1.Caption:=TEXT_MES_LOAD_RES;
 SaveResults1.Caption:=TEXT_MES_SAVE_RES;
 NewPanel1.Caption:=TEXT_MES_NEW_PANEL;
 Explorer1.Caption:=TEXT_MES_EXPLORER;
 DoSearchNow1.Caption:=TEXT_MES_DO_SEARCH_NOW;
 Panels1.Caption:=TEXT_MES_PANELS;
 Properties1.Caption:=TEXT_MES_PROPERTIES;
 Explorer2.Caption:=TEXT_MES_EXPLORER;
 EditGroups1.Caption:=TEXT_MES_EDIT_GROUPS;
 GroupsManager1.Caption:=TEXT_MES_GROUPS_MANAGER;
 GroupsManager2.Caption:=TEXT_MES_GROUPS_MANAGER;
 Ratingnotsets1.Caption:=TEXT_MES_RATING_NOT_SETS;
 SetComent1.Caption:=TEXT_MES_SET_COM;
 Comentnotsets1.Caption:=TEXT_MES_SET_COM_NOT;
 MenuItem2.Caption:=TEXT_MES_SELECT_ALL;
 Cut1.Caption:=TEXT_MES_CUT;
 Copy2.Caption:=TEXT_MES_COPY;
 Paste1.Caption:=TEXT_MES_PASTE;
 Undo1.Caption:=TEXT_MES_UNDO;
 CheckBox1.Caption:=TEXT_MES_WS_DATE_BETWEEN;
 CheckBox2.Caption:=TEXT_MES_WS_SHOW_PRIVATE;
 CheckBox3.Caption:=TEXT_MES_WS_SHOW_COMMON;
 CheckBox4.Caption:=TEXT_MES_WS_RATING_BETWEEN;
 CheckBox5.Caption:=TEXT_MES_WS_ID_BETWEEN;
 OpeninExplorer1.Caption:=TEXT_MES_OPEN_IN_EXPLORER;
 AddFolder1.Caption:=TEXT_MES_ADD_FOLDER;
 Help2.Caption:=TEXT_MES_HELP;
 Activation1.Caption:=TEXT_MES_ACTIVATION;
 About1.Caption:=TEXT_MES_ABOUT;
 HomePage1.Caption:=TEXT_MES_HOME_PAGE;
 ContactWithAuthor1.Caption:=TEXT_MES_CONTACT_WITH_AUTHOR;
 NewSearch1.Caption:=TEXT_MES_NEW_SEARCH;
 GetUpdates1.Caption:=TEXT_MES_GET_UPDATING;
 ImageEditor1.Caption:=TEXT_MES_IMAGE_EDITOR_W;
 SortbyID1.Caption:=TEXT_MES_SORT_BY_ID;
 SortbyName1.Caption:=TEXT_MES_SORT_BY_NAME;
 SortbyDate1.Caption:=TEXT_MES_SORT_BY_DATE;
 SortbyRating1.Caption:=TEXT_MES_SORT_BY_RATING;
 SortbyFileSize1.Caption:=TEXT_MES_SORT_BY_FILESIZE;
 SortbySize1.Caption:=TEXT_MES_SORT_BY_SIZE;

 SortbyCompare1.Caption:=TEXT_MES_IMAGES_SORT_BY_COMPARE_RESULT;
 
 Increment1.Caption:=TEXT_MES_SORT_INCREMENT;
 Decremect1.Caption:=TEXT_MES_SORT_DECREMENT;
 GetPhotosFromDrive1.Caption:=TEXT_MES_GET_PHOTOS;
 CheckBox7.Caption:=TEXT_MES_USE_WIDE_SEARCH;

 Datenotexists1.Caption:=TEXT_MES_NO_DATE_1;
 DateExists1.Caption:=TEXT_MES_DATE_EX;
 Datenotsets1.Caption:=TEXT_MES_DATE_NOT_SETS;
 PanelValueIsDateSets.Caption:=TEXT_MES_VAR_VALUES;
 IsDatePanel.Caption:=TEXT_MES_NO_DATE_1;
 Setvalue1.Caption:=TEXT_MES_SET_VALUE;
 Setvalue2.Caption:=TEXT_MES_SET_VALUE;
 IsTimePanel.Caption:=TEXT_MES_TIME_NOT_EXISTS;
 PanelValueIsTimeSets.Caption:=TEXT_MES_VAR_VALUES;

 Help3.Caption:=TEXT_MES_HELP;
 Help4.Caption:=TEXT_MES_HELP;
 Activation2.Caption:=TEXT_MES_ACTIVATION;
 About2.Caption:=TEXT_MES_ABOUT;
 HomePage2.Caption:=TEXT_MES_HOME_PAGE;
 ContactWithAuthor2.Caption:=TEXT_MES_CONTACT_WITH_AUTHOR;
 GetUpdates2.Caption:=TEXT_MES_GET_UPDATING;

 Exit1.Caption:=TEXT_MES_EXIT;
 LoadResults2.Caption:=TEXT_MES_LOAD_RES;
 SaveResults2.Caption:=TEXT_MES_SAVE_RES;
 ShowExplorerPage1.Caption:=TEXT_MES_SHOW_EXPLORER_PANEL;

 NewPanel2.Caption:=TEXT_MES_NEW_PANEL;
 NewSearch2.Caption:=TEXT_MES_NEW_SEARCH;
 GroupsManager3.Caption:=TEXT_MES_GROUPS_MANAGER;
 Explorer3.Caption:=TEXT_MES_EXPLORER;
 Options2.Caption:=TEXT_MES_OPTIONS;

 File1.Caption:=TEXT_MES_FILE;
 View1.Caption:=TEXT_MES_VIEW;
 Tools1.Caption:=TEXT_MES_TOOLS;

 RemovableDrives1.Caption:=TEXT_MES_REMOVABLE_DRIVES;
 CDROMDrives1.Caption:=TEXT_MES_CD_ROM_DRIVES;
 SpecialLocation1.Caption:=TEXT_MES_SPECIAL_LOCATION;

 RemovableDrives2.Caption:=TEXT_MES_REMOVABLE_DRIVES;
 CDROMDrives2.Caption:=TEXT_MES_CD_ROM_DRIVES;
 SpecialLocation2.Caption:=TEXT_MES_SPECIAL_LOCATION;


 GetListofKeyWords1.Caption:=TEXT_MES_GET_LIST_OF_KEYWORDS;
 GetPhotosFromDrive2.Caption:=TEXT_MES_GET_PHOTOS;

 Timenotsets1.Caption:=TEXT_MES_TIME_NOT_SETS;
 TimeExists1.Caption:=TEXT_MES_TIME_EXISTS;
 TimenotExists1.Caption:=TEXT_MES_TIME_NOT_EXISTS;

 DBTreeView1.Caption:=TEXT_MES_MAKE_DB_TREE;
 ImageEditor2.Caption:=TEXT_MES_IMAGE_EDITOR_W;
 View2.Caption:=TEXT_MES_SLIDE_SHOW;
 ShowDateOptionsLink.Text:=TEXT_MES_SHOW_DATE_OPTIONS;

 ToolButton3.Caption:=TEXT_MES_SEARCH;
 ToolButton9.Caption:=TEXT_MES_SORTING;
 ToolButton1.Caption:=TEXT_MES_ZOOM_IN;
 ToolButton2.Caption:=TEXT_MES_ZOOM_OUT;
 ToolButton10.Caption:=TEXT_MES_GROUPS;

 ToolButton4.Caption:=TEXT_MES_SAVE;
 ToolButton5.Caption:=TEXT_MES_OPEN;
 ToolButton12.Caption:=TEXT_MES_EXPLORER;

end;

procedure GrayScale(var image : TBitmap);
var
  i, j, c : integer;
  p : PARGB;
begin
 if image.PixelFormat<>pf24bit then image.PixelFormat:=pf24bit;
 for i:=0 to image.Height-1 do
 begin
  p:=image.ScanLine[i];
  for j:=0 to image.Width-1 do
  begin
   c:=round(0.3*p[j].r+0.59*p[j].g+0.11*p[j].b);
   p[j].r:=c;
   p[j].g:=c;
   p[j].b:=c;
  end;
 end;
end;

procedure SelectedColor(var image : TBitmap; Color : TColor);
var
  i, j, r, g, b : integer;
  p : PARGB;



begin
 r:=GetRValue(Color);
 g:=GetGValue(Color);
 b:=GetBValue(Color);
 if image.PixelFormat<>pf24bit then image.PixelFormat:=pf24bit;
 for i:=0 to image.Height-1 do
 begin
  p:=image.ScanLine[i];
  for j:=0 to image.Width-1 do
  if Odd(i+j) then
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
end;

Function RectInRect(Const R1, R2 : TRect) : Boolean;
begin
 Result:=PtInRect(R2,R1.TopLeft) or PtInRect(R2,R1.BottomRight) or PtInRect(R1,R2.TopLeft) or PtInRect(R1,R2.BottomRight);
end;

procedure TSearchForm.HelpTimerTimer(Sender: TObject);
var
  FTable : TTable;
  DS : TDataSet;

  procedure xHint(xDS : TDataSet);

    function count :  integer;
    begin
     if xDS is TTable then result:=xDS.RecordCount else
     result:=xDS.FieldByName('Coun').AsInteger;
    end;

  begin
   if count<50 then
   DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_FIRST,Point(0,0),ListView1,HelpNextClick,TEXT_MES_NEXT_HELP,HelpCloseClick) else
   begin
    HelpNo:=0;
    DBKernel.WriteBool('HelpSystem','CheckRecCount',False);
   end;
  end;

begin
 if not Active then Exit;
 if FolderView then Exit;
 HelpTimer.Enabled:=false;
 if not DBKernel.ReadBool('HelpSystem','CheckRecCount',True) then
 begin
  HelpActivationNO:=0;
  if DBkernel.GetDemoMode then
  if DBKernel.ReadBool('HelpSystem','ActivationHelp',True) then
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_FIRST,Point(0,0),ListView1,HelpActivationNextClick,TEXT_MES_NEXT_HELP,HelpActivationCloseClick) else
  if not DBkernel.GetDemoMode then
  DBKernel.WriteBool('HelpSystem','ActivationHelp',false);
  exit;
 end;

 if GetDBType=DB_TYPE_MDB then
 begin
  DS:=GetQuery;
  SetSQL(DS, 'Select count(*) as Coun from '+GetDefDBname);
  DS.Open;
  xHint(DS);
  FreeDS(DS);
 end;

 if GetDBType=DB_TYPE_BDE then
 begin
  FTable := TTable.Create(nil);
  FTable.TableName:=dbname;
  FTable.Active:=true;
  xHint(FTable);
  FTable.Close;
  FTable.Free;
 end;
end;

procedure TSearchForm.PopupMenu7Popup(Sender: TObject);
begin
 Setvalue1.Visible:= not FUpdatingDB;
end;

procedure TSearchForm.PopupMenu4Popup(Sender: TObject);
begin
 EditGroups1.Visible:= not FUpdatingDB;
end;

procedure TSearchForm.Button2Click(Sender: TObject);
begin
 PanelWideSearch.Visible:=not PanelWideSearch.Visible;
 if PanelWideSearch.Visible then Button2.Caption:='<--' else Button2.Caption:='-->';
 Rating2.IsLayered:=PanelWideSearch.Visible;
 TwButton1.IsLayered:=PanelWideSearch.Visible;
 Rating2.Enabled:= not PanelWideSearch.Visible;
 TwButton1.Enabled:= not PanelWideSearch.Visible;
end;

procedure TSearchForm.CheckBox1Click(Sender: TObject);
begin
 DateTimePicker2.Enabled:=CheckBox1.Checked;
 DateTimePicker3.Enabled:=CheckBox1.Checked;
 if CheckBox1.Checked then
 CheckBox6.Checked:=false;
end;

procedure TSearchForm.CheckBox4Click(Sender: TObject);
begin
 ComboBox2.Enabled:=CheckBox4.Checked;
 ComboBox3.Enabled:=CheckBox4.Checked;
end;

procedure TSearchForm.CheckBox5Click(Sender: TObject);
begin
 Edit2.Enabled:=CheckBox5.Checked;
 Edit3.Enabled:=CheckBox5.Checked;
end;

procedure TSearchForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
 if not (key in abs_cifr) then
 if key<>#8 then Key:=#0;
end;

procedure TSearchForm.PopupMenu8Popup(Sender: TObject);
begin
 if ShellTreeView1.SelectedFolder<>nil then
 begin
  TempFolderName:=ShellTreeView1.SelectedFolder.PathName;
  OpeninExplorer1.Visible:=DirectoryExists(ShellTreeView1.SelectedFolder.PathName);
  AddFolder1.Visible:=OpeninExplorer1.Visible;
  View2.Visible:=OpeninExplorer1.Visible;
 end else
 begin
  TempFolderName:='';
  OpeninExplorer1.Visible:=false;
  AddFolder1.Visible:=false;
  View2.Visible:=false;
 end;
end;

procedure TSearchForm.OpeninExplorer1Click(Sender: TObject);
begin
 With ExplorerManager.NewExplorer do
 begin
  SetPath(Self.TempFolderName);
  Show;
  SetFocus;
 end;
end;

procedure TSearchForm.AddFolder1Click(Sender: TObject);
begin
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddDirectory(TempFolderName,nil);
end;

procedure TSearchForm.Hide1Click(Sender: TObject);
begin
 Properties1Click(Sender);
end;

procedure TSearchForm.Splitter1CanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
 if NewSize<150 then Accept:=false;
 if NewSize>340 then Accept:=false;
end;

procedure TSearchForm.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 Creating:=true;
 LockChangePath:=false;
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TSearchForm.DeleteItemByID(ID: integer);
var
  i, j: integer;
begin
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if ListView1.Items[i].Tag=ID then
  begin
   for j:=i to ListView1.Items.Count-2 do
   begin
    Data[j]:=Data[j+1];
   end;
   ListView1.Items.Delete(i);
   Setlength(Data,Length(Data)-1);
   break;
  end;
 end;
end;

procedure TSearchForm.GroupsManager2Click(Sender: TObject);
begin
 ExecuteGroupManager;
end;

procedure TSearchForm.Activation1Click(Sender: TObject);
begin
 DoActivation;
end;

procedure TSearchForm.Help2Click(Sender: TObject);
begin
 DoHelp;
end;

procedure TSearchForm.HomePage1Click(Sender: TObject);
begin
 DoHomePage;
end;

procedure TSearchForm.ContactWithAuthor1Click(Sender: TObject);
begin
 DoHomeContactWithAuthor;
end;

{ TManagerSearchs }

procedure TManagerSearchs.AddSearch(Search: TSearchForm);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FSearchs)-1 do
 if FSearchs[i]=Search then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FSearchs,Length(FSearchs)+1);
  FSearchs[Length(FSearchs)-1]:=Search;

  SetLength(FForms,Length(FForms)+1);
  FForms[Length(FForms)-1]:=Search;
 end;
end;

constructor TManagerSearchs.Create;
begin
 SetLength(FSearchs,0);
 SetLength(FForms,0);
end;

destructor TManagerSearchs.Destroy;
begin
 SetLength(FSearchs,0);
 SetLength(FForms,0);
 inherited;
end;

procedure TManagerSearchs.FreeSearch(Search: TSearchForm);
begin
//
end;

function TManagerSearchs.IsSearch(Search: TSearchForm): Boolean;
Var
  i : Integer;
begin
 Result:=False;
 For i:=0 to Length(FSearchs)-1 do
 if FSearchs[i]=Search then
 Begin
  Result:=True;
  Break;
 End;
end;

function TManagerSearchs.IsSearchForm(Search: TForm): Boolean;
var
  i : Integer;
begin
 Result:=False;
 For i:=0 to Length(FForms)-1 do
 if FForms[i]=Search then
 Begin
  Result:=True;
  Break;
 End;
end;

function TManagerSearchs.NewSearch: TSearchForm;
begin
 Application.CreateForm(TSearchForm,Result);
end;

function TManagerSearchs.GetAnySearch : TSearchForm;
begin
 if SearchCount=0 then Result:=NewSearch else Result:=FSearchs[0];
end;

procedure TManagerSearchs.RemoveSearch(Search: TSearchForm);
var
  i, j : integer;
begin
 For i:=0 to Length(FSearchs)-1 do
 if FSearchs[i]=Search then
 begin
  For j:=i to Length(FSearchs)-2 do
  FSearchs[j]:=FSearchs[j+1];
  SetLength(FSearchs,Length(FSearchs)-1);
  For j:=i to Length(FForms)-2 do
  FForms[j]:=FForms[j+1];
  SetLength(FForms,Length(FForms)-1);
  break;
 end;
end;

function TManagerSearchs.SearchCount: Integer;
begin
 Result:=Length(FSearchs);
end;

procedure TSearchForm.NewSearch1Click(Sender: TObject);
begin
 With SearchManager.NewSearch do
 begin
  Show;
  SetFocus;
 end;
end;

procedure TSearchForm.GetUpdates1Click(Sender: TObject);
begin
 GetUpdates(true);
end;

procedure TSearchForm.HelpCloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=ID_OK=MessageBoxDB(Handle,TEXT_MES_CLOSE_HELP,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION);
 if CanClose then
 begin
  HelpNo:=0;
  DBKernel.WriteBool('HelpSystem','CheckRecCount',False);
 end;
end;

procedure TSearchForm.HelpNextClick(Sender: TObject);
var
  Handled : boolean;
begin
 ListView1ContextPopup(ListView1,Point(0,0),Handled);
 HelpNO:=1;
end;

procedure TSearchForm.FormShow(Sender: TObject);
begin
 if not FShowen then
 HelpTimer.Enabled:=true;
 FShowen:=true;
 SearchEdit.SetFocus;
end;

procedure TSearchForm.HelpActivationCloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=ID_OK=MessageBoxDB(Handle,TEXT_MES_CLOSE_HELP,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION);
 if CanClose then
 begin
  HelpActivationNO:=0;
  DBKernel.WriteBool('HelpSystem','ActivationHelp',False);
 end;
end;

procedure TSearchForm.HelpActivationNextClick(Sender: TObject);
var
  Handled : boolean;
begin
 HelpActivationNO:=HelpActivationNO+1;
 if HelpActivationNO=1 then
 begin
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_1,Point(0,0),ListView1,HelpActivationNextClick,TEXT_MES_NEXT_HELP,HelpActivationCloseClick);
 end;
 if HelpActivationNO=2 then
 begin
  ListView1ContextPopup(ListView1,Point(0,0),Handled);
  HelpActivationNO:=3;
 end;
end;

procedure TSearchForm.ImageEditor1Click(Sender: TObject);
begin
 NewImageEditor;
end;

procedure TSearchForm.Image3Click(Sender: TObject);
var
  Groups : TGroups;
  size, i : integer;
  MenuItem : TmenuItem;
  P : TPoint;
  SmallB, B : TBitmap;
  JPEG : TJPEGImage;
begin
 if not GroupsLoaded then LoadGroupsList(true);
 GetCursorPos(P);
 Groups:=GetRegisterGroupList(true,not (ShiftKeyDown));
 QuickGroupsSearch.Items.Clear;
 GroupsImageList.Clear;
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 for i:=0 to Length(Groups)-1 do
 begin
  B := TBitmap.Create;
  B.PixelFormat:=pf24bit;
  JPEG := TJPEGImage.Create;
  JPEG.Assign(Groups[i].GroupImage);
  B.Canvas.Brush.Color:=Graphics.clMenu;
  B.Canvas.Pen.Color:=Graphics.clMenu;
  size:=Max(JPEG.Width,JPEG.Height);
  B.Width:=size;
  B.Height:=size;
  B.Canvas.Rectangle(0,0,size,size);
  B.Canvas.Draw(B.Width div 2 - JPEG.Width div 2, B.Height div 2 - JPEG.Height div 2,JPEG);
  DoResize(16,16,B,SmallB);
  B.Free;
  GroupsImageList.Add(SmallB,nil);
  JPEG.Free;
 end;
 SmallB.Free;
 for i:=0 to Length(Groups)-1 do
 begin
  MenuItem := TmenuItem.Create(QuickGroupsSearch.Items);
  MenuItem.Caption:=Groups[i].GroupName;
  MenuItem.OnClick:=QuickGroupsearch;
  MenuItem.ImageIndex:=i;
  QuickGroupsSearch.Items.Add(MenuItem);
 end;
 QuickGroupsSearch.Popup(P.X,P.Y);
end;

procedure TSearchForm.QuickGroupsearch(Sender: TObject);
var
 S : String;
 i : integer;
begin
 S:=(Sender as TMenuItem).Caption;
 for i:=1 to Length(s)-1 do
 begin
  if (s[i]='&') and (s[i+1]<>'&') then Delete(S,i,1);
 end;
 for i:=1 to ComboBoxSearchGroups.Items.Count-1 do
 if ComboBoxSearchGroups.ItemsEx[i].Caption=S then
 begin
  ComboBoxSearchGroups.ItemIndex := i;
  break;
 end;
 if Button1.Caption<>TEXT_MES_STOP then DoSearchNow(nil);
end;

procedure TSearchForm.SortbyID1Click(Sender: TObject);
begin
 SortbyID1.Checked:=true;
 SortLink.Tag:=0;
 SortLink.Text:=TEXT_MES_SORT_BY_ID;
 SortingClick(Sender);
end;

procedure TSearchForm.SortbyName1Click(Sender: TObject);
begin
 SortbyName1.Checked:=true;
 SortLink.Tag:=1;
 SortLink.Text:=TEXT_MES_SORT_BY_NAME;
 SortingClick(Sender);
end;

procedure TSearchForm.SortbyDate1Click(Sender: TObject);
begin
 SortbyDate1.Checked:=true;
 SortLink.Tag:=2;
 SortLink.Text:=TEXT_MES_SORT_BY_DATE;
 SortingClick(Sender);
end;

procedure TSearchForm.SortbyRating1Click(Sender: TObject);
begin
 SortbyRating1.Checked:=true;
 SortLink.Tag:=3;
 SortLink.Text:=TEXT_MES_SORT_BY_RATING;
 SortingClick(Sender);
end;

procedure TSearchForm.SortbyFileSize1Click(Sender: TObject);
begin
 SortbyFileSize1.Checked:=true;
 SortLink.Tag:=4;
 SortLink.Text:=TEXT_MES_SORT_BY_FILESIZE;
 SortingClick(Sender);
end;

procedure TSearchForm.SortbySize1Click(Sender: TObject);
begin
 SortbySize1.Checked:=true;
 SortLink.Tag:=5;
 SortLink.Text:=TEXT_MES_SORT_BY_SIZE;
 SortingClick(Sender);
end;

procedure TSearchForm.Image4_Click(Sender: TObject);
var
  p : TPoint;
begin
 GetCursorPos(p);
 SortingPopupMenu.Popup(p.x,p.y);
end;

procedure TSearchForm.Decremect1Click(Sender: TObject);
begin
 Decremect1.Checked:=true;
 SortLink.Icon:=Image6.Picture.Icon;
 SortLink.RecreateShImage;
 SortingClick(Sender);
end;

procedure TSearchForm.Increment1Click(Sender: TObject);
begin
 Increment1.Checked:=true;
 SortLink.Icon:=Image5.Picture.Icon;
 SortLink.RecreateShImage;
 SortingClick(Sender);
end;

procedure TSearchForm.GetPhotosClick(Sender: TObject);
var
  Item : TMenuItem;
begin
 Item:=(Sender as TMenuItem);
 GetPhotosFromDrive(Char(Item.Tag));
end;

procedure TSearchForm.ComboBox1DropDown(Sender: TObject);
var
  i : integer;
  size : integer;
  Group : TGroup;
  SmallB, B : TBitmap;
  GroupImageValid : Boolean;
  FCurrentGroups : TGroups;

  procedure CreteDefaultGroupImage;
  begin
   SmallB.Width:=16;
   SmallB.Height:=16;
   SmallB.Canvas.Pen.Color:=Theme_MainColor;
   SmallB.Canvas.Brush.Color:=Theme_MainColor;
   SmallB.Canvas.Rectangle(0,0,16,16);
   DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1].Handle,16,16,0,0,DI_NORMAL);
   GroupImageValid:=true;
  end;

begin

 GroupsImageList.Clear;
 FCurrentGroups:=EncodeGroups(FPropertyGroups);
 for i:=0 to Length(FCurrentGroups)-1 do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Canvas.Brush.Color:=Theme_MainColor;
  Group:=GetGroupByGroupName(FCurrentGroups[i].GroupName,true);
  GroupImageValid:=false;
  if Group.GroupImage<>nil then
  if not Group.GroupImage.Empty then
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   GroupImageValid:=true;

   size:=Max(Group.GroupImage.Width,Group.GroupImage.Height);
   B.Canvas.Brush.Color:=Theme_MainColor;
   B.Canvas.Pen.Color:=Theme_MainColor;
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - Group.GroupImage.Width div 2, B.Height div 2 - Group.GroupImage.Height div 2,Group.GroupImage);

   FreeGroup(Group);
   DoResize(15,15,B,SmallB);
   SmallB.Height:=16;
   SmallB.Width:=16;
   B.Free;
  end else CreteDefaultGroupImage;
  GroupsImageList.Add(SmallB,nil);
  SmallB.Free;

  With ComboBoxSelGroups.ItemsEx[i] do
  begin
   if GroupImageValid then
   ImageIndex:=i+1 else ImageIndex:=0;
  end;
 end;

 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 CreteDefaultGroupImage;
 GroupsImageList.Add(SmallB,nil);
 SmallB.Free;

 if ComboBoxSelGroups.ItemsEx.Count<>0 then
 With ComboBoxSelGroups.ItemsEx[ComboBoxSelGroups.ItemsEx.Count-1] do ImageIndex:=0;

 ComboBoxSelGroups.ShowEditIndex:=GroupsImageList.Count-1;
end;

procedure TSearchForm.CheckBox6Click(Sender: TObject);
begin
 ComboBox4.Enabled:=CheckBox6.Checked;
 ComboBox5.Enabled:=CheckBox6.Checked;
 if CheckBox6.Checked then
 CheckBox1.Checked:=false;
end;

procedure TSearchForm.InsertSpesialQueryPopupMenuItemClick(
  Sender: TObject);
begin
 case (Sender as TMenuItem).Tag of
 1 : SearchEdit.Text:=':DeletedFiles:';
 2 : SearchEdit.Text:=':Dublicates:';
 end;
end;

procedure TSearchForm.DeleteSelected;
var
  i : integer;
begin
 if DmProgress1.Position<>0 then exit;
 ListView1.Groups.BeginUpdate(false);
 for i:=ListView1.Items.Count-1 downto 0 do
 if ListView1.Items[i].Selected then
 begin
  DeleteItemByID(ListView1.Items[i].Tag);
 end;
 ListView1.Groups.EndUpdate(false);
end;

procedure TSearchForm.HidePanelTimerTimer(Sender: TObject);
begin
 if (ListView1Selected=nil) or (SelCount=0) then
 begin
  HidePanelTimer.Enabled:=false;
  PropertyPanel.Hide;
 end;
end;

procedure TSearchForm.PanelValueIsTimeSetsDblClick(Sender: TObject);
begin
 If FUpdatingDB then Exit;
 PanelValueIsTimeSets.Visible:=false;
 Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu11Popup(Sender: TObject);
begin
 TimeNotExists1.Visible:=not IsTimePanel.Visible;
 TimeExists1.Visible:=IsTimePanel.Visible;
 TimeExists1.Visible:=TimeExists1.Visible and not FUpdatingDB;
 Timenotsets1.Visible:=Timenotsets1.Visible and not FUpdatingDB;
 Timenotsets1.Visible:=Timenotsets1.Visible and (SelCount>1) and not FUpdatingDB;
end;

procedure TSearchForm.Timenotexists1Click(Sender: TObject);
begin
 IsTimePanel.Visible:=True;
 Memo1Change(Sender);
end;

procedure TSearchForm.TimeExists1Click(Sender: TObject);
begin
 IsTimePanel.Visible:=False;
 Memo1Change(Sender);
end;

procedure TSearchForm.Timenotsets1Click(Sender: TObject);
begin
 PanelValueIsTimeSets.Visible:=True;
 Memo1Change(Sender);
end;

procedure TSearchForm.Help4Click(Sender: TObject);
begin
 DoHelp;
end;

procedure TSearchForm.Activation2Click(Sender: TObject);
begin
 if ActivateForm=nil then
 Application.CreateForm(TActivateForm,ActivateForm);
 ActivateForm.Execute;
end;

procedure TSearchForm.About2Click(Sender: TObject);
begin
 if AboutForm = nil then
 Application.CreateForm(TAboutForm,AboutForm);
 AboutForm.Execute;
end;

procedure TSearchForm.HomePage2Click(Sender: TObject);
begin
 DoHomePage;
end;

procedure TSearchForm.ContactWithAuthor2Click(Sender: TObject);
begin
 DoHomeContactWithAuthor;
end;

procedure TSearchForm.GetUpdates2Click(Sender: TObject);
begin
 TInternetUpdate.Create(false,true);
end;

procedure TSearchForm.Exit1Click(Sender: TObject);
begin
 Close;
end;

procedure TSearchForm.ShowExplorerPage1Click(Sender: TObject);
begin
 if ShowExplorerPage1.Checked then Properties1Click(Sender) else Explorer2Click(Sender);
end;

procedure TSearchForm.DoShowSelectInfo;
var
  i, indent : integer;
  size : int64;
  A : TArStrings;
  CommonKeyWords : String;
  ArStr : TArStrings;
  ArDates : TArDateTime;
  ArIsDates : TArBoolean;
  ArIsTimes : TArBoolean;
  ArInt : TArInteger;
  ArGroups : TArStrings;
  ArTimes : TArTime;
  WorkQuery : TDataSet;
begin
 if Active then

 Memo2.PopupMenu:=nil;
 if ListView1Selected=nil then
 if SelCount=0 then
 begin
  HidePanelTimer.Enabled:=true;
  Exit;
 end;
 HidePanelTimer.Enabled:=false;
 LockWindowUpdate(Handle);
 PropertyPanel.Show;
 SearchPanelB.Top:=PropertyPanel.Top-1;
 LockWindowUpdate(0);
 WorkQuery:=GetQuery;
 if (SelCount>1) then
 begin
  SelectedInfo.One:=false;
  SelectedInfo.Nil_:=false;
  size:=0;
  SetLength(SelectedInfo.Ids,0);
  SetLength(ArDates,0);
  SetLength(ArTimes,0);
  SetLength(ArIsDates,0);
  SetLength(ArIsTimes,0);
  SetLength(ArInt,0);
  SetLength(A,0);
  SetLength(ArStr,0);
  SetLength(ArGroups,0);

  For i:=0 to ListView1.Items.Count-1 do
  if ListView1.Items[i].Selected then
  begin
   Size:=Size+Data[i].FileSize;
   SetLength(A,Length(A)+1);
   A[Length(A)-1]:=Data[i].KeyWords;
   SetLength(SelectedInfo.Ids,Length(SelectedInfo.Ids)+1);
   SelectedInfo.Ids[Length(SelectedInfo.Ids)-1]:=Data[i].ID;
   SetLength(ArDates,Length(ArDates)+1);
   ArDates[Length(ArDates)-1]:=Data[i].Date;
   SetLength(ArTimes,Length(ArTimes)+1);
   ArTimes[Length(ArTimes)-1]:=Data[i].Time;

   SetLength(ArInt,Length(ArInt)+1);
   ArInt[Length(ArInt)-1]:=Data[i].Rating;
   SetLength(ArStr,Length(ArStr)+1);
   ArStr[Length(ArStr)-1]:=Data[i].Comments;
   SetLength(ArIsDates,Length(ArIsDates)+1);
   ArIsDates[Length(ArIsDates)-1]:=Data[i].IsDate;
   SetLength(ArIsTimes,Length(ArIsTimes)+1);
   ArIsTimes[Length(ArIsTimes)-1]:=Data[i].IsTime;

   SetLength(ArGroups,Length(ArGroups)+1);
   ArGroups[Length(ArGroups)-1]:=Data[i].Groups;
  end;
  DoLockInfo;
  lockwindowupdate(Handle);
  SelectedInfo.CommonRating:=MaxStatInt(ArInt);
  rating1.Rating:=SelectedInfo.CommonRating;
  rating1.Islayered:=true;
  rating1.layered:=100;

  CurrentItemInfo.ItemDate:=MaxStatDate(ArDates);
  CurrentItemInfo.ItemIsDate:=MaxStatBool(ArIsDates);
  SelectedInfo.Date:=MaxStatDate(ArDates);
  SelectedInfo.IsDate:=MaxStatBool(ArIsDates);
  PanelValueIsDateSets.Visible:=IsVariousBool(ArIsDates) or IsVariousDate(ArDates);
  DateTimePicker1.DateTime:=SelectedInfo.Date;
  IsDatePanel.Visible:=not SelectedInfo.IsDate;
  SelectedInfo.IsVariousDates:=PanelValueIsDateSets.Visible;


  CurrentItemInfo.ItemTime:=MaxStatDate(TArDateTime(ArTimes));
  CurrentItemInfo.ItemIsTime:=MaxStatBool(ArIsTimes);
  SelectedInfo.Time:=MaxStatTime(ArTimes);
  SelectedInfo.IsTime:=MaxStatBool(ArIsTimes);
  PanelValueIsTimeSets.Visible:=IsVariousBool(ArIsTimes) or IsVariousDate(TArDateTime(ArTimes));
  DateTimePicker4.DateTime:=SelectedInfo.Time;
  IsTimePanel.Visible:=not SelectedInfo.IsTime;
  SelectedInfo.IsVariousTimes:=PanelValueIsTimeSets.Visible;

  CommonKeyWords:=GetCommonWordsA(A);
  SelectedInfo.CommonKeyWords:=CommonKeyWords;
  Label4.Caption:=Format(TEXT_MES_SIZE_FORMATA,[sizeintextA(size)]);
  Label2.Caption:=TEXT_MES_ITEMS+' = '+inttostr(SelCount);
  Memo1.Lines.text:=CommonKeyWords;
  SelectedInfo.IsVariousComments:=IsVariousArStrings(ArStr);
  if SelectedInfo.IsVariousComments then
  begin
   SelectedInfo.CommonComment:=TEXT_MES_VAR_COM;
   CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
   Memo2.PopupMenu:=PopupMenu6;
  end else
  begin
   SelectedInfo.CommonComment:=ArStr[0];
   CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
  end;
  if SelectedInfo.IsVariousComments then
  begin
   Memo2.ReadOnly:=true;
   Memo2.Cursor:=CrHandPoint;
  end;
  Memo2.Text:=SelectedInfo.CommonComment;
  CurrentItemInfo.ItemGroups:=GetCommonGroups(ArGroups);
  SelectedInfo.Groups:=CurrentItemInfo.ItemGroups;
  FPropertyGroups:=CurrentItemInfo.ItemGroups;
  ReloadGroups;
  DoUnLockInfo;
  Memo1Change(nil);
  lockwindowupdate(0);
  current_id_show:=-1;
  FreeDS(WorkQuery);
 end else begin
  rating1.Islayered:=false;
  SelectQuery.Active:=false;

  indent:=0;
  if ListView1.Selection.First<>nil then
  indent:=ListView1.Selection.First.Tag;

  SetSQL(SelectQuery,'SELECT * FROM '+GetDefDBName+' WHERE ID='+inttostr(indent));
  SelectQuery.active:=true;
  lockwindowupdate(Handle);
  Label2.Caption:=Format(TEXT_MES_ID_FORMATA,[inttostr(indent)]);
  Label4.Caption:=Format(TEXT_MES_SIZE_FORMATA,[sizeintextA(SelectQuery.FieldByName('FileSize').asinteger)]);
  memo1.Lines.text:=SelectQuery.FieldByName('KeyWords').asstring;
  memo2.Lines.text:=SelectQuery.FieldByName('Comment').asstring;
  Rating1.Rating:=SelectQuery.FieldByName('Rating').asinteger;
  CurrentItemInfo.ItemRating:=Rating1.Rating;

  listView1.Hint := SelectQuery.FieldByName('Comment').asstring;
  current_id_show:=SelectQuery.FieldByName('ID').AsInteger;
  frating:=SelectQuery.FieldByName('Rating').asinteger;
  CurrentItemInfo.ItemKeyWords:=SelectQuery.FieldByName('KeyWords').AsString;
  CurrentItemInfo.ItemComment:=SelectQuery.FieldByName('Comment').AsString;

  DateTimePicker1.DateTime:=SelectQuery.FieldByName('DateToAdd').AsDateTime;
  CurrentItemInfo.ItemDate:=SelectQuery.FieldByName('DateToAdd').AsDateTime;
  CurrentItemInfo.ItemIsDate:=SelectQuery.FieldByName('IsDate').AsBoolean;
  SelectedInfo.IsDate:=CurrentItemInfo.ItemIsDate;
  IsDatePanel.Visible:=not CurrentItemInfo.ItemIsDate;
  PanelValueIsDateSets.Visible:=False;

  DateTimePicker4.DateTime:=SelectQuery.FieldByName('aTime').AsDateTime;
  CurrentItemInfo.ItemTime:=SelectQuery.FieldByName('aTime').AsDateTime;
  CurrentItemInfo.ItemIsTime:=SelectQuery.FieldByName('IsTime').AsBoolean;
  SelectedInfo.IsTime:=CurrentItemInfo.ItemIsTime;
  IsTimePanel.Visible:=not CurrentItemInfo.ItemIsTime;
  PanelValueIsTimeSets.Visible:=False;

  CurrentItemInfo.ItemGroups:=SelectQuery.FieldByName('Groups').AsString;
  FPropertyGroups:=CurrentItemInfo.ItemGroups;
  ReloadGroups;
  Save.Enabled:=false;
  Memo2.Cursor:=CrDefault;
  Application.HintHidePause:=50*length(SelectQuery.FieldByName('Comment').AsString);
  SelectQuery.Close;
  Memo1Change(nil);
  lockwindowupdate(0);
  FreeDS(WorkQuery);
 end;
end;

procedure TSearchForm.SelectTimerTimer(Sender: TObject);
begin
 if LastSelCount<2 then
 begin
  SelectTimer.Enabled:=false;
  DoShowSelectInfo;
  WindowsMenuTickCount:=GetTickCount;
  LastSelCount:=0;
  Exit;
 end;
 if LastSelCount=SelCount then
 begin
  SelectTimer.Enabled:=false;
  DoShowSelectInfo;
  LastSelCount:=0;
  Exit;
 end;
 LastSelCount:=SelCount;
end;

procedure TSearchForm.GetListofKeyWords1Click(Sender: TObject);
begin
 GetListOfKeyWords;
end;

procedure TSearchForm.RemovableDrives1Click(Sender: TObject);
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
  DS:=DriveState(Chr(i));
  If (DS=dolphin_db.DS_DISK_WITH_FILES) or (DS=dolphin_db.DS_EMPTY_DISK) then
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

procedure TSearchForm.CDROMDrives1Click(Sender: TObject);
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
  If (DS=dolphin_db.DS_DISK_WITH_FILES) or (DS=dolphin_db.DS_EMPTY_DISK) then
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

procedure TSearchForm.SpecialLocation1Click(Sender: TObject);
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

procedure TSearchForm.GetPhotosFromDrive2Click(Sender: TObject);
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

procedure TSearchForm.File1Click(Sender: TObject);
begin
 LoadResults2.Visible:=not FUpdatingDB;
end;

procedure TSearchForm.IsTimePanelDblClick(Sender: TObject);
begin
 If FUpdatingDB then Exit;
 IsTimePanel.Visible:=False;
 Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu1Popup(Sender: TObject);
begin
 DoSearchNow1.Visible:=not FUpdatingDB;
end;

procedure TSearchForm.DBTreeView1Click(Sender: TObject);
begin
 MakeDBFileTree(dbname);
end;

procedure TSearchForm.DestroyTimerTimer(Sender: TObject);
begin
 if FUpdatingDB then Exit;
 if DestroyCounter>0 then
 begin
  inc(DestroyCounter);
 end;
 if (DestroyCounter<3) and (DestroyCounter<>0) then exit;
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
end;

procedure TSearchForm.View2Click(Sender: TObject);
var
  info : TRecordsInfo;
  n : integer;
begin
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 GetFileListByMask(TempFolderName,SupportedExt,info,n,True);
 if Length(info.ItemFileNames)>0 then
 Viewer.Execute(Self,info);
end;

procedure TSearchForm.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if DropFileTarget2.Files.Count<>0 then
 begin
  SearchEdit.Text:=':ScanImageW('+DropFileTarget2.Files[0]+':1):';
  SearchEdit.SetFocus;
 end;
end;

procedure TSearchForm.ReloadListMenu;
begin
 ListMenuScript:=ReadScriptFile('scripts\SearchListMenu.dbini');
end;

procedure TSearchForm.ScriptExecuted(Sender: TObject);
begin
 LoadItemVariables(aScript,Sender as TMenuItemW);
 if Trim((Sender as TMenuItemW).Script)<>'' then
 ExecuteScript(Sender as TMenuItemW,aScript,'',FExtImagesInImageList,DBkernel.ImageList,ScriptExecuted);
end;

procedure TSearchForm.LoadExplorerValue(Sender: TObject);
begin
 SetBoolAttr(aScript,'$explorer',ExplorerPanel.Visible);
end;

function TSearchForm.SelCount : integer;
begin
 Result:= ListView1.Selection.Count;
end;

function TSearchForm.ListView1Selected : TEasyItem;
begin
 Result:= ListView1.Selection.First;
end;

procedure TSearchForm.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  r,r1 : TRect;
  b : TBitmap;
  w,h,index : integer;
  temp_str : string;
begin
 if fListUpdating then exit;
 if Item.Data=nil then exit;
 r1:=ARect;

 if not Boolean(TDataObject(Item.Data).Data^) then
 begin
  ListView1.PaintInfoItem.fBorderColor:=$00FFFF;
 end else
 begin
  ListView1.PaintInfoItem.fBorderColor:=Theme_ListSelectColor;
 end;

 if Item.ImageIndex>-1 then
 begin
  w:=FBitmapImageList.FImages[Item.ImageIndex].Bitmap.Width;
  h:=FBitmapImageList.FImages[Item.ImageIndex].Bitmap.Height;
  ProportionalSizeA(fPictureSize,fPictureSize,w,h);
 end;

 b:=TBitmap.Create;
 b.PixelFormat:=pf24bit;
 b.Width:=fPictureSize;
 b.Height:=fPictureSize;
 FillRectNoCanvas(b,ListView1.Canvas.Brush.Color);

 if Item.ImageIndex>-1 then
 begin
  b.Canvas.StretchDraw(Rect(fPictureSize div 2 - w div 2,fPictureSize div 2 - h div 2,w+(fPictureSize div 2 - w div 2),h+(fPictureSize div 2 - h div 2)),FBitmapImageList.FImages[Item.ImageIndex].Bitmap);
 end else
 begin
  b.Canvas.Draw(fPictureSize div 2 - image1.picture.Graphic.Width div 2,fPictureSize div 2 - image1.picture.Graphic.height div 2,image1.picture.Graphic);
 end;

 r.Left:=r1.Left-2;
 r.Top:=r1.Top-2;

 index:=ItemIndex(Item);
 if index>Length(Data)-1 then
 begin
  EventLog(':TSearchForm.Listview1ItemThumbnailDraw() Error: index = '+IntToStr(index)+', Length(Data) = '+IntToStr(Length(Data)));
  exit;
 end;
 DrawAttributes(b,fPictureSize,Data[index].Rating,Data[index].Rotation,Data[index].Access,Data[index].FileName,Data[index].Crypted,Data[index].Exists,1);

 if ProcessedFilesCollection.ExistsFile(Data[index].FileName)<>nil then
 DrawIconEx(b.Canvas.Handle,2,b.Height-18,UnitDBKernel.icons[DB_IC_RELOADING+1].Handle,16,16,0,0,DI_NORMAL);

 if (Data[index].CompareResult.ByGistogramm>0) or (Data[index].CompareResult.ByPixels>0) then
 begin
  DrawIconEx(b.Canvas.Handle,fPictureSize-16,b.Height-18,UnitDBKernel.icons[DB_IC_DUBLICAT+1].Handle,16,16,0,0,DI_NORMAL);
  temp_str:=Format('%d%%\%d%%',[Round(Data[index].CompareResult.ByPixels),Round(Data[index].CompareResult.ByGistogramm)]);
  r1:=Rect(fPictureSize-16-b.Canvas.TextWidth(temp_str)-3,b.Height-16,fPictureSize-16,B.Height);
  DrawTextA(b.Canvas.Handle, PChar(temp_str), Length(temp_str), r1, DT_VCENTER+DT_CENTER);
 end;

 ACanvas.Draw(r.Left,r.Top,b);
 b.free;
end;

procedure TSearchForm.EasyListview1DblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
begin
 ListView1DblClick(Sender);
end;

procedure TSearchForm.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 ListView1SelectItem(Sender,Item,false);
end;

function TSearchForm.ItemAtPosStar(X,Y : integer): TEasyItem;
begin
 result:=nil;
end;

Function TSearchForm.ItemAtPos(X,Y : integer): TEasyItem;
begin
 Result:=ItemByPointImage(Listview1,Point(x,y));
end;

procedure TSearchForm.EasyListview2KeyAction(Sender: TCustomEasyListview;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
var
  aChar : Char;
begin
 aChar:=Char(CharCode);
 ListView1KeyPress(Sender,aChar);
 if CharCode=VK_F2 then ListView1KeyDown(Sender,CharCode,[]);
end;

procedure TSearchForm.EasyListview1ItemEdited(Sender: TCustomEasyListview;
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

procedure TSearchForm.N05Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  Dolphin_DB.SetRating(RatingPopupMenu1.Tag,(Sender as TMenuItem).Tag);
  EventInfo.Rating:=(Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Sender,RatingPopupMenu1.Tag,[EventID_Param_Rating],EventInfo);
end;

procedure TSearchForm.ListView1Resize(Sender : TObject);
begin
 Listview1.BackGround.OffsetX:=ListView1.Width-Listview1.BackGround.Image.Width;
 Listview1.BackGround.OffsetY:=ListView1.Height-Listview1.BackGround.Image.Height;
end;

procedure TSearchForm.UpdateTheme(Sender: TObject);
var
  b : TBitmap;
begin
 SortLink.SetDefault;
 ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
 ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);

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

end;

procedure TSearchForm.Listview1IncrementalSearch(Item: TEasyCollectionItem;
  const SearchBuffer: WideString; var CompareResult: Integer);
var
  CompareStr: WideString;
begin

  CompareStr := Item.Caption;
  SetLength(CompareStr, Length(SearchBuffer));

  if IsUnicode then
    CompareResult := lstrcmpiW(PWideChar(SearchBuffer), PWideChar(CompareStr))
  else
    CompareResult := lstrcmpi(PChar(string(SearchBuffer)), PChar(string(CompareStr)));
end;

function TSearchForm.ItemIndex(item : TEasyItem) : integer;
var
  i : integer;
begin
  Result:=item.Index;
  for i:=0 to item.OwnerGroup.Index-1 do
  begin
   Result:=Result+ListView1.Groups[i].Items.Count;
  end;
end;

procedure TSearchForm.ShowDateOptionsLinkClick(Sender: TObject);
var
  x : TDateTime;
begin
 if FormDateRangeSelectDB=nil then
 Application.CreateForm(TFormDateRangeSelectDB, FormDateRangeSelectDB);

 x:=StrToIntDef(ComboBox4.Text,3);
 Case ComboBox5.ItemIndex of
  0 : x:=x;
  1 : x:=x*7;
  2 : x:=x*30;
  3 : x:=x*365;
  end;
 x:=Round(Now)-x;

 ShowingDateRangeWindow:=true;
 FormDateRangeSelectDB.Execute(Min(DateTimePicker2.Date,DateTimePicker3.Date),Max(DateTimePicker2.Date,DateTimePicker3.Date),x,CheckBox6.Checked,SetDateSettings);
 ShowingDateRangeWindow:=false;

end;

procedure TSearchForm.SetDateSettings(Sender : TObject; DateFrom, DateTo,
  LastDate : TDateTime; ByLastDate: boolean);
begin
 CheckBox6.Checked:=ByLastDate;
 CheckBox1.Checked:=not ByLastDate;
 if ByLastDate then
 begin
  ComboBox5.ItemIndex:=0;
  ComboBox4.Text:=IntToStr(Max(1,Round(now-LastDate)));
 end else
 begin
  DateTimePicker2.Date:=DateFrom;
  DateTimePicker3.Date:=DateTo;
 end;
end;


procedure TSearchForm.ApplicationEvents1Deactivate(Sender: TObject);
begin
 if ShowingDateRangeWindow then exit;
 if FormDateRangeSelectDB<>nil then
 if FormDateRangeSelectDB.IsVisible then
 begin
  ShowWindow(FormDateRangeSelectDB.Handle,SW_HIDE);
  FormDateRangeSelectDB.IsVisible:=false;
  FormDateRangeSelectDBHideed:=true;
 end;
end;

procedure TSearchForm.ApplicationEvents1Activate(Sender: TObject);
begin
 if FormDateRangeSelectDB<>nil then
 if FormDateRangeSelectDBHideed then
 begin
  ShowWindow(FormDateRangeSelectDB.Handle,SW_SHOWNOACTIVATE);
  FormDateRangeSelectDB.IsVisible:=true;
 end;
 FormDateRangeSelectDBHideed:=false;
end;

procedure TSearchForm.LoadSizes();
begin
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;
end;

function TSearchForm.FileNameExistsInList(FileName : string) : boolean;
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 Result:=false;
 for i:=0 to Length(Data)-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   Result:=true;
   break;
  end;
 end;
end;

function TSearchForm.GetImageIndexWithPath(FileName : string) : integer;
var
  i : integer;
begin
 Result:=-1;
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(Data)-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   Result:=ListView1.Items[i].ImageIndex;
   break;
  end;
 end;
end;

procedure TSearchForm.ReplaceImageIndexWithPath(FileName : string; Index : integer);
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(Data)-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   ListView1.Items[i].ImageIndex:=Index;
  end;
 end;
end;

procedure TSearchForm.ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap);
var
  i : integer;
  Bmp : TBitmap;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(Data)-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   if ListView1.Items[i].ImageIndex=-1 then
   begin
    Bmp:=TBitmap.Create;
    Bmp.Assign(Bitmap);
    FBitmapImageList.AddBitmap(Bmp);
    ListView1.Items[i].ImageIndex:=FBitmapImageList.Count-1;
   end else
   begin
    FBitmapImageList.FImages[ListView1.Items[i].ImageIndex].Bitmap.Assign(Bitmap);
   end;
   ListView1.Refresh;
  end;
 end;
end;

procedure TSearchForm.BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
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

procedure TSearchForm.ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
 if not (ssCtrl in Shift) then exit;
 if WheelDelta<0 then
 begin
  ZoomIn;
 end else
 begin
  ZoomOut;
 end;
end;

procedure TSearchForm.BigImagesTimerTimer(Sender: TObject);
begin
 if Self.fListUpdating then exit;
 BigImagesTimer.Enabled:=false;
 SID:=GetGUID;
 //тут начинается загрузка больших картинок
 UnitSearchBigImagesLoaderThread.TSearchBigImagesLoaderThread.Create(false,self,SID,nil,fPictureSize,Copy(Data));
end;

function TSearchForm.GetVisibleItems: TArStrings;
var
  i : integer;
  r : TRect;
  t : array of boolean;
  rv : TRect;
begin
 SetLength(Result,0);
 SetLength(t,0);              
 if Length(Data)<>ListView1.Items.Count then exit;
 rv :=  Listview1.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  r:=Rect(ListView1.ClientRect.Left+rv.Left,ListView1.ClientRect.Top+rv.Top,ListView1.ClientRect.Right+rv.Left,ListView1.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView1.Items[i].DisplayRect) then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:=Data[i].FileName;
  end;
 end;
end;

function TSearchForm.IsSelectedVisible: boolean;
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

procedure TSearchForm.LoadGroupsList(LoadAllLIst : boolean = false);
var
  Groups : TGroups;
  size, i : integer;
  SmallB, B : TBitmap;
  JPEG : TJPEGImage;
begin
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 if not LoadAllLIst then
 begin
  SearchGroupsImageList.Clear;
  ComboBoxSearchGroups.Items.Clear;
  With ComboBoxSearchGroups.ItemsEx.Add do
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   B.Canvas.Brush.Color:=Graphics.clMenu;
   B.Canvas.Pen.Color:=Graphics.clMenu;
   size:=Max(ImageAllGroups.Picture.Graphic.Width,ImageAllGroups.Picture.Graphic.Height);
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - ImageAllGroups.Picture.Graphic.Width div 2, B.Height div 2 - ImageAllGroups.Picture.Graphic.Height div 2,ImageAllGroups.Picture.Graphic);
   DoResize(32,32,B,SmallB);
   B.Free;
   SearchGroupsImageList.Add(SmallB,nil);
   Caption:=TEXT_MES_ALL_GROUPS;
   ImageIndex:=0;
  end;
  ComboBoxSearchGroups.ItemIndex:=0;
  SmallB.Free;
  exit;
 end;
 Groups:=GetRegisterGroupList(true,false);
 if GroupsLoaded then exit;
 for i:=0 to Length(Groups)-1 do
 begin
  B := TBitmap.Create;
  B.PixelFormat:=pf24bit;
  JPEG := TJPEGImage.Create;
  JPEG.Assign(Groups[i].GroupImage);
  B.Canvas.Brush.Color:=Graphics.clMenu;
  B.Canvas.Pen.Color:=Graphics.clMenu;
  size:=Max(JPEG.Width,JPEG.Height);
  B.Width:=size;
  B.Height:=size;
  B.Canvas.Rectangle(0,0,size,size);
  B.Canvas.Draw(B.Width div 2 - JPEG.Width div 2, B.Height div 2 - JPEG.Height div 2,JPEG);
  DoResize(32,32,B,SmallB);
  B.Free;
  SearchGroupsImageList.Add(SmallB,nil);
  JPEG.Free;
  With ComboBoxSearchGroups.ItemsEx.Add do
  begin
   Caption:=Groups[i].GroupName;
   ImageIndex:=i+1;
  end;
 end;
 SmallB.Free;
 GroupsLoaded:=true;
end;

procedure TSearchForm.LoadSearchList(LoadAllLIst : boolean = false);
var
  size : integer;
  SmallB, B : TBitmap;
  text : String;
  PGroup : PString255;
begin
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 text:=SearchEdit.Text;
 if not LoadAllLIst then
 begin
  SearchImageList.Clear;
  SearchEdit.Items.Clear;
  With SearchEdit.ItemsEx.Add do
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   B.Canvas.Brush.Color:=Graphics.clMenu;
   B.Canvas.Pen.Color:=Graphics.clMenu;
   size:=Max(ImageAllGroups.Picture.Graphic.Width,ImageAllGroups.Picture.Graphic.Height);
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - ImageAllGroups.Picture.Graphic.Width div 2, B.Height div 2 - ImageAllGroups.Picture.Graphic.Height div 2,ImageAllGroups.Picture.Graphic);
   DoResize(16,16,B,SmallB);
   B.Free;
   SearchImageList.Add(SmallB,nil);
   Caption:=TEXT_MES_CLEAR_SEARCH_TEXT;
   ImageIndex:=0;    
   GetMem(PGroup,SizeOF(TString255));
   PGroup^:=TEXT_MES_ALL_GROUPS;
   Data:=PGroup;
   OverlayImageIndex:=0;
   SelectedImageIndex:=0;
  end;
  SearchEdit.Text:=text;
  SearchEdit.ItemIndex:=0;
  SmallB.Free;
  exit;
 end;
end;

procedure TSearchForm.ComboBoxSearchGroupsSelect(Sender: TObject);
begin
 if Button1.Caption<>TEXT_MES_STOP then
 DoSearchNow(nil);
end;

procedure TSearchForm.ComboBoxSearchGroupsDropDown(Sender: TObject);
begin
 if not GroupsLoaded then LoadGroupsList(true);
end;

procedure TSearchForm.SearchEditDropDown(Sender: TObject);
begin
//
end;

function IntPointer(int : integer) : PInteger;
begin
 Getmem(Result,SizeOf(Integer));
 Result^:=int;
end;

procedure TSearchForm.AddNewSearchListEntry;
var
  b, Bitmap : TBitmap;
  i : integer;
  text : String;
  PGroup : PString255;
  Deleted : boolean;     
  ComboBoxSearchGroupsItemIndex : integer;
const
  SearchTextCount = 10;
begin
 ComboBoxSearchGroupsItemIndex:=ComboBoxSearchGroups.GetItemIndex;
 if not SearchEdit.ShowDropDownMenu then
 begin
  SearchEdit.ItemsEx.Delete(0);
  SearchImageList.Delete(0);
  SearchEdit.ShowDropDownMenu:=true;
 end;
 if SearchTextList.Count>0 then
 begin
  i:=ComboBoxSearchGroups.GetItemIndex;
  if SearchTextList[0]=SearchEdit.Text then
  if SearchGroupsList[0] = ComboBoxSearchGroups.ItemsEx[i].Caption then
  if Integer(SearchRatingList[0]^)=Rating2.Rating then
    exit;
 end;
 text:=SearchEdit.Text;
 Deleted:=false;

 for i:=SearchTextList.Count-1 downto 1 do
 begin
  if SearchTextList[i]=SearchEdit.Text then
  if SearchGroupsList[i] = ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption then
  if Integer(SearchRatingList[i]^)=Rating2.Rating then
  begin
   SearchTextList.Delete(i);
   SearchGroupsList.Delete(i);
   SearchRatingList.Delete(i);
   SearchEdit.ItemsEx.Delete(i);
   SearchImageList.Delete(i);
  end;
 end;

 if not Deleted then
 if SearchTextList.Count=SearchTextCount then
 begin
  SearchTextList.Delete(SearchTextCount-1);
  SearchGroupsList.Delete(SearchTextCount-1);
  SearchRatingList.Delete(SearchTextCount-1);
  SearchEdit.ItemsEx.Delete(SearchTextCount-1);
  SearchImageList.Delete(SearchTextCount-1);
 end;
 b:=TBitmap.Create;

 if SearchGroupsImageList.GetBitmap(ComboBoxSearchGroupsItemIndex,b) then
 begin
  Bitmap:=TBitmap.Create;
  DoResize(16,16,b,Bitmap);
  b.free;
  SearchImageList.Insert(0,Bitmap,nil);
  Bitmap.Free;   

  With SearchEdit.ItemsEx.Insert(0) do
  begin
   Caption:=text;
   ImageIndex:=0;
   OverlayImageIndex:=0;
   SelectedImageIndex:=0;
   GetMem(PGroup,SizeOF(TString255));
   PGroup^:=ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroupsItemIndex].Caption;
   Data:=PGroup;
  end;
  SearchEdit.Text:=text;
  SearchEdit.ItemIndex:=0;
  for i:=1 to SearchEdit.ItemsEx.Count-1 do
  begin
   SearchEdit.ItemsEx[i].ImageIndex:=SearchEdit.ItemsEx[i].ImageIndex+1;
  end;
 end;
 SearchGroupsList.Insert(0,ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption);
 SearchTextList.Insert(0,SearchEdit.Text);
 SearchRatingList.Insert(0,IntPointer(Rating2.Rating));

 SaveQueryList;
end;

procedure TSearchForm.LoadSearchTexts;
begin
 SearchTextList := TStringList.Create;
 SearchGroupsList := TStringList.Create;
 SearchRatingList := TList.Create;
end;

procedure TSearchForm.SearchEditSelect(Sender: TObject);
var
  i : integer;
  GroupName : String;
begin
 SearchEdit.ItemIndex:=SearchEdit.GetItemIndex;
 SearchEdit.Realign;
 SearchEdit.SelStart:=0;
 SearchEdit.SelLength:=0;
 if SearchEdit.ItemIndex>-1 then
 begin
  GroupName:=TString255(SearchEdit.ItemsEx[SearchEdit.ItemIndex].Data^);
  for i:=0 to ComboBoxSearchGroups.Items.Count-1 do
  if ComboBoxSearchGroups.ItemsEx[i].Caption=GroupName then
  begin
   ComboBoxSearchGroups.ItemIndex := i;
   break;
  end;
 end;
 if SearchEdit.ShowDropDownMenu then
 Rating2.Rating:=Integer(SearchRatingList[SearchEdit.GetItemIndex]^);
end;


procedure TSearchForm.CreateWND;
begin
  inherited;
end;

procedure TSearchForm.SearchEditEnterDown(Sender: TObject);
begin
 DoSearchNow(nil);
end;

procedure TSearchForm.FormResize(Sender: TObject);
var
  aTop,n, LastIndex : integer;

begin
 LastIndex:=ComboBoxSearchGroups.ItemIndex;
 aTop := ClientHeight - ComboBoxSearchGroups.Top-ComboBoxSearchGroups.Height - Panel1.Top;
 n:=Max(5,aTop div 32);
 if n<>ComboBoxSearchGroups.DropDownCount then
 begin
  ComboBoxSearchGroups.DropDownCount:=n;
  ComboBoxSearchGroups.ItemIndex:=LastIndex;
 end;
end;

procedure TSearchForm.LoadToolBarIcons();
var
  Ico : TIcon;

  procedure AddIcon(Name : String);
  begin
   if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then Name:=Name+'_SMALL';
   try
    Ico:=TIcon.Create;
    Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
    ToolBarImageList.AddIcon(Ico);
   except
   end;
  end;

  procedure AddDisabledIcon(Name : String);
  var
    i : integer;
  begin
   if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then Name:=Name+'_SMALL';
   Ico:=TIcon.Create;
   try
    Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
    for i:=1 to 9 do
    DisabledToolBarImageList.AddIcon(Ico);
   except
   end;
  end;
begin
 ToolButton5.Visible:=true;

 if DBKernel.Readbool('Options','UseSmallToolBarButtons',false) then
 begin
  ToolBarImageList.Width:=16;
  ToolBarImageList.Height:=16;  
  DisabledToolBarImageList.Width:=16;
  DisabledToolBarImageList.Height:=16;
 end;

 ConvertTo32BitImageList(ToolBarImageList);
 ConvertTo32BitImageList(DisabledToolBarImageList);

 AddIcon('SEARCH_FIND');
 AddIcon('SEARCH_SORT');
 AddIcon('SEARCH_ZOOM_IN');
 AddIcon('SEARCH_ZOOM_OUT');
 AddIcon('SEARCH_GROUPS');
 AddIcon('SEARCH_SAVE');
 AddIcon('SEARCH_IMPORT');
 AddIcon('SEARCH_EXPLORER');
 AddIcon('SEARCH_BREAK');

 AddDisabledIcon('SEARCH_BREAK_GRAY');

 ToolButton3.ImageIndex:=0;
 ToolButton9.ImageIndex:=1;
 ToolButton1.ImageIndex:=3;
 ToolButton2.ImageIndex:=2;
 ToolButton10.ImageIndex:=4;
 ToolButton4.ImageIndex:=5;
 ToolButton5.ImageIndex:=6;    
 ToolButton12.ImageIndex:=7;
 ToolButton14.ImageIndex:=8;

 ToolBar1.Images := ToolBarImageList;
 ToolBar1.DisabledImages:= DisabledToolBarImageList;
end;

procedure TSearchForm.ToolButton3Click(Sender: TObject);
begin
 DoSearchNow(nil);
end;

procedure TSearchForm.ZoomIn;
var
  SelectedVisible : boolean;
begin
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize>40 then FPictureSize:=FPictureSize-10;
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);

 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TSearchForm.ZoomOut;
var
  SelectedVisible : boolean;
begin                 
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize<550 then FPictureSize:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;  
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;   
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);
 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TSearchForm.ToolButton1Click(Sender: TObject);
begin
 ZoomIn;
end;

procedure TSearchForm.ToolButton2Click(Sender: TObject);
begin
 ZoomOut;
end;

procedure TSearchForm.ReRecreateGroupsList();
begin            
 SearchEdit.ShowDropDownMenu:=false;
 GroupsLoaded:=false;
 SearchTextList.Clear;
 SearchGroupsList.Clear;
 SearchRatingList.Clear;
 LoadGroupsList;
 LoadSearchList;
end;

procedure TSearchForm.ToolButton12Click(Sender: TObject);
var
  FileName : string;
begin
 if ListView1.Selection.Count=0 then
 begin
  NewExplorer;
 end else
 begin
  With ExplorerManager.NewExplorer do
  begin
   FileName:=Data[GetItemNO(ListView1.Selection.First)].FileName;
   DoProcessPath(FileName);
   SetOldPath(FileName);
   SetPath(ExtractFilePath(FileName));
   Show;
   SetFocus;
  end;
 end;
end;

procedure TSearchForm.SearchEditGetAdditionalImage(Sender: TObject;
  index: Integer; HDC: Cardinal; var Top, Left: Integer);
begin
 if index>SearchRatingList.Count-1 then exit;
 if Integer(SearchRatingList[index]^)>0 then
 begin
  FillRect(HDC,Rect(SearchEdit.Width-20,Top,SearchEdit.Width,Top+16),SearchEdit.Canvas.Brush.Handle);
  Rating2.DoDrawImageByrating(HDC,SearchEdit.Width-18,Top,Integer(SearchRatingList[index]^));
 end;
end;

procedure TSearchForm.ToolButton14Click(Sender: TObject);
begin
 if ToolButton14.Enabled then
 begin                      
  ToolButton14.Enabled:=false;
  BreakOperation(Sender);
  SID:=Dolphin_DB.GetGUID;
 end;
end;

function TSearchForm.IfBreak(Sender : TObject; aSID : TGUID): boolean;
begin
 Result:=not IsEqualGUID(SID, aSID);
end;

procedure TSearchForm.SortingClick(Sender: TObject);
var
  i, l, index, n : integer;
  aType, SortType : byte;
  ShowGroups : Boolean;   
  FLastRating : Integer;
  FLastSize : int64;
  FLastChar : Char;
  FLastYear, FLastMonth : integer;
type
  SortList = array of TEasyItem;     

  TSortItem = record                 {This defines the objects being sorted.}
    ID : integer;
    ValueInt : int64;
    ValueStr : string;
    ValueDouble : double;
   end;
                      
  TSortItems = array of TSortItem;  {This is an array of objects to be sorted.}
  
   aListItem = record
    Caption : string;
    Indent : integer;
    Data : Pointer;
    ImageIndex : integer;
    DBData : TSearchRecord;
   end;

  aListItems = array of aListItem;


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

  procedure QuickSort(var X:TSortItems; N:integer;aType : byte; Increment : boolean);
  var
    i : integer;
  begin
    Qsort(X,0,N-1,aType);
    if not Increment then
    begin
     for i:=0 to Length(X) div 2 do
     begin
      Swap(X,i,Length(X)-1-i);
     end;
    end;
  end;

begin
 if Sender = nil then exit;
 if not (Sender is TMenuItem) then exit;
 //NOT RIGHT! SORTING BY FOLDERS-IMAGES-OTHERS
 if ((Sender as TMenuItem).Tag=-1) then exit;

 if ListView1.Items.Count<2 then exit;
 ListView1.Groups.BeginUpdate(false);

 //saving settings
 DBKernel.WriteInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMethod',SortLink.Tag);
 DBKernel.WriteBool('Search_DB_'+DBKernel.GetDataBaseName,'OldMethodDecrement',Decremect1.Checked);

 SortType:=0;
 if (SortbyID1.Checked) then SortType:=0;
 if (SortbyName1.Checked) then SortType:=1;
 if (SortbyDate1.Checked) then SortType:=2;
 if (SortbyRating1.Checked) then SortType:=3;
 if (SortbyFileSize1.Checked) then SortType:=4;
 if (SortbySize1.Checked) then SortType:=5;
 if (SortbyCompare1.Checked) then SortType:=6;

 try
 l:=ListView1.Items.Count;

 SetLength(SIs,L);
 SetLength(LI,L);

 for i:=0 to l-1 do
 begin
  LI[i].Caption:=ListView1.Items[i].Caption;
  LI[i].Indent:=ListView1.Items[i].Tag;
  LI[i].Data:=ListView1.Items[i].Data;
  LI[i].ImageIndex:=ListView1.Items[i].ImageIndex;
  LI[i].DBData:=Data[i];

  index:=i;
  Case SortType of
  0: begin
      SIs[i].ValueInt:=Data[index].ID;   
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
     end;
  1: begin
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
     end;
  2: begin
      SIs[i].ValueDouble:=DateOf(Data[index].Date)+Data[index].Time;
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
     end;
  3: begin      
      SIs[i].ValueInt:=Data[index].Rating;   
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
     end;
  4: begin
      SIs[i].ValueInt:=Data[index].FileSize;
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
     end;
  5: begin
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
      SIs[i].ValueInt:=Data[index].Width*Data[index].Height;
     end;
  6: begin  //COMPARING!
      SIs[i].ValueStr:=ExtractFileName(Data[index].FileName);
      SIs[i].ValueInt:=Data[index].CompareResult.ByPixels*10+Data[index].CompareResult.ByGistogramm;
     end;
  end;
  SIs[i].ID:=i;
 end;

 aType:=0;
 if SortType=0 then aType:=1;
 if SortType=1 then aType:=4;
 if SortType=2 then aType:=2;
 if SortType=3 then aType:=1;
 if SortType=4 then aType:=1;
 if SortType=5 then aType:=1;   
 if SortType=6 then aType:=1;

 QuickSort(SIs,l,aType,Increment1.Checked);
                       
 ListView1.BeginUpdate;
 ListView1.Items.Clear;

 ShowGroups:=DBKernel.Readbool('Options','UseGroupsInSearch',true);

 FLastSize:=0;
 FLastChar:=#0;
 FLastRating:=-1;
 FLastMonth:=0;
 FLastYear:=0;

 for i:=0 to L-1 do
 begin
  AddItemInListViewByGroups(ListView1,LI[SIs[i].ID].DBData.ID,LI[SIs[i].ID].Caption,SortLink.Tag,Decremect1.Checked,
  ShowGroups,LI[SIs[i].ID].DBData.FileSize,LI[SIs[i].ID].DBData.FileName,LI[SIs[i].ID].DBData.Rating,
  LI[SIs[i].ID].DBData.Date,LI[SIs[i].ID].DBData.Include,FLastSize,FLastChar,FLastRating,FLastMonth,FLastYear);
  ListView1.Items[i].ImageIndex:=LI[SIs[i].ID].ImageIndex;
  ListView1.Items[i].Data:=LI[SIs[i].ID].Data;
  Data[i]:=LI[SIs[i].ID].DBData;
 end;
 ListView1.EndUpdate();
 except    
   on e : Exception do EventLog(':TSearchForm::SortingClick() throw exception: '+e.Message);
 end;
 ListView1.Groups.EndUpdate;  
 ListView1.Realign;
end;

procedure TSearchForm.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
 Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
 BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
end;

procedure TSearchForm.DoSetSearchByComparing;
begin
 SearchByCompating:=true;
end;

procedure TSearchForm.SortingPopupMenuPopup(Sender: TObject);
var
  i : integer;
begin
 SortbyCompare1.Visible:=SearchByCompating;

 for i:=0 to SortingPopupMenu.Items.Count-1 do
 SortingPopupMenu.Items[i].Enabled:=not fListUpdating;
end;

procedure TSearchForm.SortbyCompare1Click(Sender: TObject);
begin
 SortbyCompare1.Checked:=true;
 SortLink.Tag:=6;
 SortLink.Text:=TEXT_MES_IMAGES_SORT_BY_COMPARE_RESULT;
 SortingClick(Sender); 
end;

procedure TSearchForm.LoadSearchDBParametrs;
var
  s : string;
begin
 if not SafeMode then
 s:=DBKernel.ReadString('Search_DB_'+DBKernel.GetDataBaseName,'OldValue') else s:='';
 Rating2.Rating:=DBKernel.ReadInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMinRating',0);
 if DBKernel.ReadBool('Search_DB_'+DBKernel.GetDataBaseName,'OldMethodDecrement',false) then
 Decremect1Click(self) else Increment1Click(self);
 Case DBKernel.ReadInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMethod',0) of
  0 : SortbyID1Click(nil);
  1 : SortbyName1Click(nil);
  2 : SortbyDate1Click(nil);
  3 : SortbyRating1Click(nil);
  4 : SortbyFileSize1Click(nil);
  5 : SortbySize1Click(nil);
  else
   SortbyDate1Click(nil);
 end;
 if s<>'' then SearchEdit.text:=Copy(s,1,1000);
 SearchEdit.text:=s;

 CheckBox6.Checked:=DBKernel.ReadBool('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTime',false);
 ComboBox4.Text:=IntToStr(DBKernel.ReadInteger('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTimeValue',3));
 ComboBox5.ItemIndex:=DBKernel.ReadInteger('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTimeCode',2);
 CheckBox7.Checked:=DBKernel.ReadBool('Search_DB_'+DBKernel.GetDataBaseName,'UseWideSearch',true);
end;

procedure TSearchForm.LoadQueryList;
var
  i, Rating, LastRating : integer;
  Group, Query : string;
begin
 CanSaveQueryList:=false;
 lastRating:=Rating2.Rating;
 for i:=9 downto 0 do
 begin                               
  if DBKernel.ReadBool('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Valid',false) then
  begin
   Group := DBKernel.ReadString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Group');
   Query:= DBKernel.ReadString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Query');
   Rating:=DBKernel.ReadInteger('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Rating',0);
   SearchEdit.Text:=Query;
   Rating2.Rating:=Rating;
   try
    AddNewSearchListEntry();
   except
    on e : Exception do EventLog(':TSearchForm::LoadQueryList()/AddNewSearchListEntry throw exception: '+e.Message);
   end;
  end;
 end;
 Rating2.Rating:=LastRating;
 SearchEdit.Text:='';
 CanSaveQueryList:=true;
end;

procedure TSearchForm.SaveQueryList;
var
  i, Rating : integer;
  Group : string;
begin
 if not CanSaveQueryList then exit;        
 for i:=0 to 9 do
 begin
  DBKernel.WriteBool('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Valid',false);
 end;
 for i:=0 to SearchEdit.ItemsEx.Count-1 do
 begin
  Group := ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption;
  Rating:=Integer(SearchRatingList[i]^);
  DBKernel.WriteBool('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Valid',true);
  DBKernel.WriteString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Query',SearchTextList[i]);
  DBKernel.WriteString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Group',Group);
  DBKernel.WriteInteger('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Rating',Rating);
 end;
end;

initialization

SearchManager := TManagerSearchs.create;

finalization

SearchManager.free;

end.
