unit Searching;

interface

uses
  UnitGroupsWork, DBCMenu, CmpUnit, FileCtrl,
  ShellApi, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ExtCtrls, StdCtrls, uGraphicUtils, uMemoryEx,
  ImgList, ComCtrls, ActiveX, ShlObj, JPEG, DmProgress, ClipBrd,
  SaveWindowPos, ExtDlgs , ToolWin, UnitDBKernel, Rating, Math, CommonDBSupport,
  AppEvnts, TwButton, ShellCtrls, UnitBitmapImageList, GraphicCrypt,
  ShellContextMenu, DropSource, DropTarget, DateUtils, acDlgSelect,
  ProgressActionUnit, UnitSQLOptimizing, uScript, UnitScripts, DBScriptFunctions,
  EasyListview, WebLink, MPCommonUtilities, GraphicsCool,
  UnitSearchBigImagesLoaderThread, DragDropFile, uFileUtils,
  DragDrop, UnitPropeccedFilesSupport, uVistaFuncs, ComboBoxExDB,
  UnitDBDeclare, UnitDBFileDialogs, UnitDBCommon, UnitDBCommonGraphics,
  uCDMappingTypes, uThreadForm, uLogger, uConstants, uTime, CommCtrl,
  uFastload, uListViewUtils, uDBDrawing, pngimage, uResources, uMemory,
  MPCommonObjects, ADODB, DBLoading, LoadingSign, uW7TaskBar,
  uFormListView, uDBPopupMenuInfo, uPNGUtils, uTranslate, uAssociations,
  uShellIntegration, uDBBaseTypes, uDBTypes, uRuntime, uSysUtils,
  uDBUtils, uDBFileTypes, Dolphin_DB, uActivationUtils, uSettings,
  uSearchTypes, WebLinkList, uDBAdapter;

type
  TSearchForm = class(TSearchCustomForm)
    PnLeft: TPanel;
    Splitter1: TSplitter;
    SaveWindowPos1: TSaveWindowPos;
    HintTimer: TTimer;
    ApplicationEvents1: TApplicationEvents;
    SearchPanelA: TPanel;
    Label1: TLabel;
    RtgQueryRating: TRating;
    TwbPrivate: TTwButton;
    PropertyPanel: TPanel;
    Label2: TLabel;
    Label8: TLabel;
    RatingEdit: TRating;
    Label4: TLabel;
    Label6: TLabel;
    Memo2: TMemo;
    Label5: TLabel;
    Memo1: TMemo;
    Save: TButton;
    ExplorerPanel: TPanel;
    PmSearchOptions: TPopupMenu;
    DoSearchNow1: TMenuItem;
    Panels1: TMenuItem;
    Properties1: TMenuItem;
    Explorer2: TMenuItem;
    DateTimePicker1: TDateTimePicker;
    IsDatePanel: TPanel;
    PopupMenu3: TPopupMenu;
    Datenotexists1: TMenuItem;
    PanelValueIsDateSets: TPanel;
    PmEditGroups: TPopupMenu;
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
    pnDateRange: TPanel;
    PopupMenu8: TPopupMenu;
    OpeninExplorer1: TMenuItem;
    AddFolder1: TMenuItem;
    Hide1: TMenuItem;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget1: TDropFileTarget;
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
    GroupsImageList: TImageList;
    InsertSpesialQueryPopupMenu: TPopupMenu;
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
    SelectTimer: TTimer;
    View2: TMenuItem;
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
    ShowDateOptionsLink: TWebLink;
    SortLink: TWebLink;
    BigImagesTimer: TTimer;
    SearchGroupsImageList: TImageList;
    ImageAllGroups: TImage;
    ComboBoxSearchGroups: TComboBoxExDB;
    SearchEdit: TComboBoxExDB;
    CoolBar1: TCoolBar;
    TbMain: TToolBar;
    TbZoomOut: TToolButton;
    ToolBarImageList: TImageList;
    TbZoomIn: TToolButton;
    TbSearch: TToolButton;
    TbSave: TToolButton;
    TbLoad: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    TbSort: TToolButton;
    TbGroups: TToolButton;
    ToolButton11: TToolButton;
    TbExplorer: TToolButton;
    ToolButton13: TToolButton;
    TbStopOperation: TToolButton;
    ToolButton15: TToolButton;
    DisabledToolBarImageList: TImageList;
    PopupMenuZoomDropDown: TPopupMenu;
    SortbyCompare1: TMenuItem;
    elvDateRange: TEasyListview;
    dblDate: TDBLoading;
    lsDate: TLoadingSign;
    LsData: TLoadingSign;
    TmrSearchResultsCount: TTimer;
    TmrQueryHintClose: TTimer;
    WlStartStop: TWebLink;
    LsSearchResults: TLoadingSign;
    TwlIncludeAllImages: TTwButton;
    WllGroups: TWebLinkList;
    SearchImageList: TImageList;
    procedure DoSearchNow(Sender: TObject);
    procedure Edit1_KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure ListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ListViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListViewDblClick(Sender: TObject);
    procedure SlideShow1Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    function GetSelectedTstrings :  Tstrings;
    procedure FormDestroy(Sender: TObject);
    procedure breakoperation(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    function GetAllFiles:  TStrings;
    procedure RefreshInfoByID(ID : integer);
    procedure Memo1Change(Sender: TObject);
    procedure ErrorQSL(sql : string);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure ListViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CopySearchResults1Click(Sender: TObject);
    procedure HintTimerTimer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure SaveResults1Click(Sender: TObject);
    procedure LoadResults1Click(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListViewExit(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Explorer2Click(Sender: TObject);
    procedure SetPath(Value : String);
    procedure SearchPanelAContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure RatingEditMouseDown(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DateNotExists1Click(Sender: TObject);
    procedure IsDatePanelDblClick(Sender: TObject);
    procedure PanelValueIsDateSetsDblClick(Sender: TObject);
    procedure ComboBox1_KeyPress(Sender: TObject; var Key: Char);
    Procedure ReloadGroups;
    procedure GroupClick(Sender: TObject);
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
    procedure PmEditGroupsPopup(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure PopupMenu8Popup(Sender: TObject);
    procedure OpeninExplorer1Click(Sender: TObject);
    procedure AddFolder1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure DeleteItemByID(ID : integer);
    procedure HelpNextClick(Sender: TObject);
    procedure HelpCloseClick(Sender : TObject; var CanClose : Boolean);
    procedure HelpActivationNextClick(Sender: TObject);
    procedure HelpActivationCloseClick(Sender : TObject; var CanClose : Boolean);
    procedure FormShow(Sender: TObject);
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
    procedure FillImageList;
    procedure InsertSpesialQueryPopupMenuItemClick(Sender: TObject);
    procedure DeleteSelected;
    procedure HidePanelTimerTimer(Sender: TObject);
    procedure PanelValueIsTimeSetsDblClick(Sender: TObject);
    procedure PopupMenu11Popup(Sender: TObject);
    procedure Timenotexists1Click(Sender: TObject);
    procedure TimeExists1Click(Sender: TObject);
    procedure Timenotsets1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ShowExplorerPage1Click(Sender: TObject);
    procedure DoShowSelectInfo;
    procedure SelectTimerTimer(Sender: TObject);
    procedure IsTimePanelDblClick(Sender: TObject);
    procedure PmSearchOptionsPopup(Sender: TObject);
    procedure View2Click(Sender: TObject);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure ReloadListMenu;
    procedure ScriptExecuted(Sender : TObject);
    procedure LoadExplorerValue(Sender : TObject);
    Procedure ListViewResize(Sender : TObject);
    function GetSelectionCount : integer;
    procedure EasyListviewItemThumbnailDraw(
      Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
      ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure ListViewSelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
    function GetListItemByID(ID : integer) : TEasyItem;
    function ItemIndex(item : TEasyItem) : integer;
    procedure ListViewEdited(Sender: TObject; Item: TEasyItem;
      var S: String);
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    function ListViewSelected : TEasyItem;
    function ItemAtPos(X,Y : integer): TEasyItem;
    procedure EasyListviewDblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
      ShiftState: TShiftState; var Handled: Boolean);
    procedure EasyListviewItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    procedure EasyListviewKeyAction(Sender: TCustomEasyListview;
      var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListviewItemEdited(Sender: TCustomEasyListview;
      Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure N05Click(Sender: TObject);
    procedure ListviewIncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);
    procedure ShowDateOptionsLinkClick(Sender: TObject);
    procedure LoadSizes;
    function FileNameExistsInList(FileName : string) : boolean;
    function ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap) : Boolean;

    procedure ListViewMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure BigImagesTimerTimer(Sender: TObject);
    function GetVisibleItems : TArStrings;
    procedure ComboBoxSearchGroupsSelect(Sender: TObject);
    procedure ComboBoxSearchGroupsDropDown(Sender: TObject);
    procedure SearchEditDropDown(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TbZoomOutClick(Sender: TObject);
    procedure TbZoomInClick(Sender: TObject);
    procedure TbExplorerClick(Sender: TObject);
    procedure TbStopOperationClick(Sender: TObject);
    procedure SortingClick(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure SortingPopupMenuPopup(Sender: TObject);
    procedure SortbyCompare1Click(Sender: TObject);
    procedure elvDateRangeItemClick(Sender: TCustomEasyListview;
      Item: TEasyItem; KeyStates: TCommonKeyStates;
      HitInfo: TEasyItemHitTestInfoSet);
    procedure elvDateRangeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure elvDateRangeResize(Sender: TObject);
    procedure dblDateDrawBackground(Sender: TObject; Buffer: TBitmap);
    procedure SearchEditChange(Sender: TObject);
    procedure TmrSearchResultsCountTimer(Sender: TObject);
    procedure elvDateRangeItemSelectionChanged(Sender: TCustomEasyListview;
      Item: TEasyItem);
    procedure SearchEditIconClick(Sender: TObject);
  private
    { Private declarations }
    FSearchInfo : TSearchInfo;
    FListUpdating : boolean;
    FPropertyGroups: String;
    TempFolderName : String;
    WindowsMenuTickCount : Cardinal;
    FLastSelectionCount : Integer;
    FUpdatingDB : Boolean;
    DestroyCounter : Integer;
    GroupsLoaded : Boolean;
    FShellTreeView : TShellTreeView;
    ElvMain: TEasyListView;
    LastMouseItem, ItemWithHint : TEasyItem;
    FBitmapImageList : TBitmapImageList;
    MouseDowned : Boolean;
    RenameResult : Boolean;
    PopupHandled : Boolean;
    ItemSelectedByMouseDown : Boolean;
    ItemByMouseDown : Boolean;
    FSearchPath : string;
    FilesToDrag : TStringList;
    DBCanDrag : Boolean;
    DBDragPoint : TPoint;
    FCurrentSelectedID : Integer;
    CurrentItemInfo : TDBPopupMenuInfoRecord;
    SelectedInfo : TSelectedInfo;
    Creating : Boolean;
    LockChangePath : Boolean;
    FHelpTimerStarted : boolean;
    aScript : TScript;
    ListMenuScript : String;
    FPictureSize : Integer;
    FSearchByCompating : Boolean;
    FFillListInfo : TListFillInfo;
    FW7TaskBar : ITaskbarList3;
    FCanBackgroundSearch: Boolean;
    FMoreThan, FLessThan: string;
    FEstimateCount: Integer;
    FProgressValue: Extended;
    FIsEstimatingActive: Boolean;
    FIsSearchingActive: Boolean;
    FLastProgressState: TBPF;
    FProgressMessage: Cardinal;
    FReloadGroupsMessage: Cardinal;
    function HintRealA(Info : TDBPopupMenuInfoRecord) : Boolean;
    procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
    function DateRangeItemAtPos(X, Y : Integer): TEasyItem;
    function GetDateFilter : TDateRange;
    procedure AddItemInListViewByGroups(DataRecord : TDBPopupMenuInfoRecord; ReplaceBitmap : Boolean);
    procedure RebuildQueryList;
    function GetSortMethod: Integer;
    function GetShowGroups: Boolean;
    function GetSortDecrement: Boolean;
    procedure KernelEventCallBack(ID: Integer; Params: TEventFields; Value: TEventValues);
    function GetRegQueryRootPath: string;
    property RegQueryRootPath: string read GetRegQueryRootPath;
  protected
   { Protected declarations }
    function TreeView : TShellTreeView;
    procedure CreateBackground;
    procedure LoadDateRange;
    procedure FetchProgress(DataSet: TCustomADODataSet;
                            Progress, MaxProgress: Integer; var EventStatus: TEventStatus);
    procedure DBRangeOpened(Sender : TObject; DS : TDataSet);
    procedure ClearItems;

    function GetListView : TEasyListview; override;
    function GetFormID : string; override;
    function InternalGetImage(FileName : string; Bitmap : TBitmap; var Width: Integer; var Height: Integer) : Boolean; override;
    function GetSearchText: string; override;
    procedure SetSearchText(Value: string); override;
    procedure SetupListView;
  public
    procedure LoadGroupsList(LoadAllLIst : boolean = false);
    procedure AddNewSearchListEntry;
    procedure LoadToolBarIcons;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ReRecreateGroupsList;
    procedure DoSetSearchByComparing;
    procedure SaveQueryList;
    procedure LoadQueryList;
    procedure LoadDataPacket(Packet : TDBPopupMenuInfo);
    procedure EmptyFillListInfo;
    procedure StartSearchThread(IsEstimate : Boolean);
    procedure StopLoadingList;
    procedure ReloadBigImages;

    //Search indicator
    procedure NotifySearchingStart;
    procedure NotifySearchingEnd;
    procedure NitifyEstimateStart;
    procedure NitifyEstimateEnd;
    procedure UpdateEstimateState(EstimateCount: Integer);
    procedure UpdateProgressState(ProgressValue: Extended);
    procedure UpdateSearchState;
    procedure UpdateVistaProgressState(State: TBPF);
    //END of Search indicator

    procedure StartSearch; overload; override;
    procedure StartSearch(Text: string); overload; override;
    procedure StartSearchDirectory(Directory: string); overload; override;
    procedure StartSearchDirectory(Directory: string; FileID: Integer); overload; override;
    procedure StartSearchSimilar(FileName: string); override;
  published
    property SortMethod : Integer read GetSortMethod;
    property ShowGroups : Boolean read GetShowGroups;
    property SortDecrement : Boolean read GetSortDecrement;
  end;

implementation

uses
  UnitManageGroups, FormManegerUnit, SlideShow, Loadingresults,
  PropertyForm, Options, UnitLoadFilesToPanel,
  UnitHintCeator, ExplorerUnit, UnitUpdateDB,
  UnitUpdateDBThread, ManagerDBUnit, UnitEditGroupsForm, UnitQuickGroupInfo,
  UnitGroupReplace, UnitSavingTableForm, UnitHelp,
  UnitUpdateDBObject, UnitFormSizeListViewTh, UnitBigImagesSize,
  UnitOpenQueryThread;

{$R *.dfm}

procedure TSearchForm.FormCreate(Sender: TObject);
const
  N = 3;
var
  MenuItem: TMenuItem;
  Captions: array[0 .. N - 1] of string;
  I: Integer;
  MainMenuScript: string;
  Ico: TIcon;
  SearchIcon: HIcon;
begin
  FLastProgressState := TBPF_PAUSED;
  FListUpdating := False;
  GroupsLoaded := False;
  MouseDowned := False;
  PopupHandled := False;
  DestroyCounter := 0;
  FHelpTimerStarted := False;
  FUpdatingDB := False;
  FCanBackgroundSearch := False;
  DBCanDrag := False;

  TW.I.Start('S -> FormCreate');

  CurrentItemInfo := TDBPopupMenuInfoRecord.Create;
  FilesToDrag := TStringList.Create;
  FSearchInfo := TSearchInfo.Create;
  SearchEdit.ShowDropDownMenu := False;
  TbStopOperation.Enabled := False;

  ExplorerManager.LoadEXIF;
  WindowID := GetGUID;
  TW.I.Start('S -> TScript');

  aScript := TScript.Create(Self, '');
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowExplorerPanel',  F_TYPE_OBJ_PROCEDURE_TOBJECT, Explorer2Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'HideExplorerPanel',  F_TYPE_OBJ_PROCEDURE_TOBJECT, Properties1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SlideShow',          F_TYPE_OBJ_PROCEDURE_TOBJECT, SlideShow1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SelectAll',          F_TYPE_OBJ_PROCEDURE_TOBJECT, SelectAll1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CopySearchResults',  F_TYPE_OBJ_PROCEDURE_TOBJECT, CopySearchResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'LoadResults',        F_TYPE_OBJ_PROCEDURE_TOBJECT, LoadResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SaveResults',        F_TYPE_OBJ_PROCEDURE_TOBJECT, SaveResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CloseWindow',        F_TYPE_OBJ_PROCEDURE_TOBJECT, Exit1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'LoadExplorerValue',  F_TYPE_OBJ_PROCEDURE_TOBJECT, LoadExplorerValue);

  SetNamedValue(AScript, '$dbname', '"' + Dbname + '"');
  ReloadListMenu;

  TW.I.Start('S -> ReadScriptFile');
  MainMenuScript := ReadScriptFile('scripts\SearchMainMenu.dbini');
  TW.I.Start('S -> LoadMenuFromScript');
  TTranslateManager.Instance.BeginTranslate;
  try
    LoadMenuFromScript(ScriptMainMenu.Items,DBkernel.ImageList,MainMenuScript,aScript,ScriptExecuted,FExtImagesInImageList,true);
  finally
    TTranslateManager.Instance.EndTranslate;
  end;
  Menu := ScriptMainMenu;

  ScriptListPopupMenu.Images := DBKernel.ImageList;
  ScriptMainMenu.Images := DBKernel.ImageList;

  TW.I.Start('S -> Register');
  DropFileTarget2.Register(SearchEdit);
  DropFileTarget1.Register(Self);

  TW.I.Start('S -> InsertSpesialQueryPopupMenu');

  Captions[0] := L('System query');
  Captions[1] := L('Show deleted items');
  Captions[2] := L('Show duplicates');
  for I := 0 to N - 1 do
  begin
    MenuItem := TMenuItem.Create(InsertSpesialQueryPopupMenu);
    MenuItem.Caption := Captions[I];
    MenuItem.OnClick := InsertSpesialQueryPopupMenuItemClick;
    MenuItem.Tag := I;
    InsertSpesialQueryPopupMenu.Items.Add(MenuItem);
    if I = 0 then
      MenuItem.Enabled := False;
  end;

  PnLeft.Width := Settings.ReadInteger('Search', 'LeftPanelWidth', 180);
  FBitmapImageList := TBitmapImageList.Create;
  TW.I.Start('S -> RegisterMainForm');
  FormManager.RegisterMainForm(Self);

  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  Caption := ProductName + ' - [' + DBkernel.GetDataBaseName + ']';

  TW.I.Start('S -> DoShowSelectInfo');
  WlStartStop.OnClick := DoSearchNow;
  SearchIcon := LoadImage(HInstance, 'EXPLORER_SEARCH_SMALL', IMAGE_ICON, 16, 16, 0);
  try
    WlStartStop.LoadFromHIcon(SearchIcon);
  finally
    DestroyIcon(SearchIcon);
  end;
  WlStartStop.Text := L('Search');
  SaveWindowPos1.Key := RegRoot + 'Searching';
  SaveWindowPos1.SetPosition;

  TW.I.Start('S -> Images');
  SortLink.UseSpecIconSize := True;
  PopupMenu8.Images := DBKernel.ImageList;
  OpeninExplorer1.ImageIndex := DB_IC_EXPLORER;
  AddFolder1.ImageIndex := DB_IC_ADD_FOLDER;
  SortbyCompare1.ImageIndex := DB_IC_DUBLICAT;
  View2.ImageIndex := DB_IC_SLIDE_SHOW;
  RatingPopupMenu1.Images := DBkernel.ImageList;
  N00.ImageIndex := DB_IC_DELETE_INFO;
  N01.ImageIndex := DB_IC_RATING_1;
  N02.ImageIndex := DB_IC_RATING_2;
  N03.ImageIndex := DB_IC_RATING_3;
  N04.ImageIndex := DB_IC_RATING_4;
  N05.ImageIndex := DB_IC_RATING_5;
  ShowDateOptionsLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EDIT_DATE + 1]);

  TW.I.Start('S -> Splitter1Moved');
  Creating := False;

  TW.I.Start('S -> LoadLanguage');
  LoadLanguage;
  SearchManager.AddSearch(Self);

  TW.I.Start('S -> LoadGroupsList');
  LoadGroupsList;

  TW.I.Start('S -> LoadQueryList');
  LoadQueryList;
  FCanBackgroundSearch := True;
  SearchEditChange(Self);

  TW.I.Start('S -> LoadToolBarIcons');
  LoadToolBarIcons;
  TbMain.ShowCaptions := True;
  TbMain.AutoSize := True;

  TW.I.Start('S -> W7 TaskBar');
  FW7TaskBar := nil;
  FProgressMessage := RegisterWindowMessage('SEARCHING_PROGRESS');
  FReloadGroupsMessage := RegisterWindowMessage('SEARCHING_RELOAD_GROUPS');
  PostMessage(Handle, FProgressMessage, 0, 0);

  TW.I.Start('S -> SetupListView');
  SetupListView;
  CreateBackground;
  TLoad.Instance.RequaredDBSettings;
  FPictureSize := ThImageSize;
  LoadSizes;

  TW.I.Start('S -> RequaredDBKernelIcons');
  TLoad.Instance.RequaredDBKernelIcons;
  Ico := TIcon.Create;
  try
    DBkernel.ImageList.GetIcon(DB_IC_GROUPS, Ico);
    Image3.Picture.Graphic := Ico;
  finally
    F(Ico);
  end;
  TW.I.Start('S -> Create - END');

end;

procedure TSearchForm.SetupListView;
begin
  ElvMain := TEasyListView.Create(Self);
  ElvMain.Parent := Self;
  ElvMain.Align := AlClient;
  ElvMain.BackGround.Enabled := True;
  ElvMain.BackGround.Tile := False;
  ElvMain.BackGround.AlphaBlend := True;
  ElvMain.BackGround.OffsetTrack := True;
  ElvMain.BackGround.BlendAlpha := 220;
  ElvMain.Font.Color := 0;
  ElvMain.View := ElsThumbnail;
  ElvMain.DragKind := DkDock;
  SetLVSelection(ElvMain, True);
  ElvMain.GroupFont.Color := clWindowText;
  ElvMain.Font.Name := 'Tahoma';
  ElvMain.HotTrack.Color := clWindowText;
  ElvMain.HotTrack.Cursor := CrArrow;
  ElvMain.HotTrack.Enabled := Settings.Readbool('Options', 'UseHotSelect', True);
  ElvMain.IncrementalSearch.Enabled := True;
  ElvMain.OnItemThumbnailDraw := EasyListViewItemThumbnailDraw;
  ElvMain.OnDblClick := EasyListViewDblClick;
  ElvMain.OnIncrementalSearch := ListViewIncrementalSearch;
  ElvMain.OnExit := ListViewExit;
  ElvMain.OnMouseDown := ListViewMouseDown;
  ElvMain.OnMouseUp := ListViewMouseUp;
  ElvMain.OnMouseMove := ListViewMouseMove;
  ElvMain.OnItemSelectionChanged := EasyListViewItemSelectionChanged;
  ElvMain.OnMouseWheel := ListViewMouseWheel;
  ElvMain.OnKeyAction := EasyListviewKeyAction;
  ElvMain.OnItemEdited := EasyListViewItemEdited;
  ElvMain.OnResize := ListViewResize;
  ElvMain.Groups.Add;
  ElvMain.Header.Columns.Add;
  ElvMain.DoubleBuffered := True;
end;

procedure TSearchForm.FormDestroy(Sender: TObject);
begin
  Settings.WriteInteger('Search','LeftPanelWidth',PnLeft.Width);

  ClearItems;
  SaveQueryList;
  SearchManager.RemoveSearch(Self);

  DropFileTarget2.Unregister;
  DropFileTarget1.Unregister;
  if Creating then
    Exit;
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  SaveWindowPos1.SavePosition;
  FormManager.UnRegisterMainForm(Self);
  Creating := True;

  F(aScript);
  F(FilesToDrag);
  F(FBitmapImageList);
  F(FSearchInfo);
  F(CurrentItemInfo);
end;

procedure TSearchForm.Edit1_KeyPress(Sender: TObject; var Key: Char);
begin
  if Byte(Key) = VK_RETURN then
  begin
    Key := #0;
    DoSearchNow(Sender);
  end;
end;

procedure TSearchForm.DoSearchNow(Sender: TObject);
var
  FScript : TScript;
  ScriptString : string;
  ImagesCount : Integer;
  DateRange : TDateRange;
begin
  if FUpdatingDB or Creating then
    Exit;

  FSearchByCompating := False;
  ScriptString := Include('Scripts\DoSearch.dbini');

  FScript := TScript.Create(Self, '');
  try
    FScript.Description := 'New search script';
    SearchEdit.Text := SysUtils.StringReplace(SearchEdit.Text,'"',' ',[rfReplaceAll]);

    SetNamedValue(fScript, '$SearchString', AnsiQuotedStr(SearchEdit.Text, '"'));
    SetNamedValue(fScript, '$Rating', IntToStr(RtgQueryRating.Rating));

    ExecuteScript(nil, FScript, ScriptString, ImagesCount, nil);
    SearchEdit.Text := GetNamedValueString(FScript, '$SearchString');
    RtgQueryRating.Rating := GetNamedValueInt(FScript, '$Rating');
  finally
    F(FScript);
  end;

  LsSearchResults.Color := ElvMain.Color;

  DateRange := GetDateFilter;
  WlStartStop.OnClick:= BreakOperation;
  WlStartStop.Text:= L('Stop');
  ClearItems;
  FBitmapImageList.Clear;
  ElvMain.ShowGroupMargins := Settings.Readbool('Options', 'UseGroupsInSearch', True);
  LsSearchResults.Hide;
  NewFormState;
  TbStopOperation.Enabled := True;
  EmptyFillListInfo;
  StartSearchThread(False);

  AddNewSearchListEntry;
end;

procedure TSearchForm.StartSearchThread(IsEstimate : Boolean);
var
  WideSearch : TSearchQuery;
  ItemEx : TComboExItem;
begin
  //TODO: free object
  WideSearch := TSearchQuery.Create;
  WideSearch.Query := SearchEdit.Text;
  ItemEx := ComboBoxSearchGroups.ItemsEx.ComboItems[ComboBoxSearchGroups.ItemIndex];
  if ItemEx.Data = nil then
    WideSearch.GroupName := ItemEx.Caption
  else
    WideSearch.GroupName := '';

  WideSearch.RatingFrom := Min(RtgQueryRating.Rating, RtgQueryRating.RatingRange);
  WideSearch.RatingTo := Max(RtgQueryRating.Rating, RtgQueryRating.RatingRange);
  WideSearch.DateFrom := Min(GetDateFilter.DateFrom, GetDateFilter.DateTo);
  WideSearch.DateTo := Max(GetDateFilter.DateFrom, GetDateFilter.DateTo);
  WideSearch.ShowPrivate := TwbPrivate.Pushed;
  WideSearch.SortDecrement := SortDecrement;
  WideSearch.SortMethod := SortMethod;
  WideSearch.ShowAllImages := TwlIncludeAllImages.Pushed;
  WideSearch.IsEstimate := IsEstimate;
  TmrSearchResultsCount.Enabled := False;
  SearchThread.Create(Self, StateID, WideSearch, BreakOperation, FPictureSize);
end;

procedure TSearchForm.TbStopOperationClick(Sender: TObject);
begin
  if TbStopOperation.Enabled then
  begin
    BreakOperation(Sender);
    NewFormState;
    NotifySearchingEnd;
    FIsEstimatingActive := False;
  end;
end;

{$REGION 'ListView events'}

procedure TSearchForm.ListViewContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Info : TDBPopupMenuInfo;
  item: TEasyItem;
  FileNames : TStrings;
  i : integer;
  S : String;
  FileList : TStrings;
  FilesCount : Integer;
begin
  if CopyFilesSynchCount > 0 then
    WindowsMenuTickCount := GetTickCount;

  HintTimer.Enabled := False;
  Item:=ItemByPointImage(ElvMain, Point(MousePos.x, MousePos.y));
  if (Item=nil) or ((MousePos.x=-1) and (MousePos.y=-1)) then Item:=ElvMain.Selection.First;

  if (item <> nil) and (item.Selected) then
  begin
    LastMouseItem:= nil;
    if Active then
      Application.HideHint;
    THintManager.Instance.CloseHint;
    HintTimer.Enabled := False;
    Info := GetCurrentPopUpMenuInfo(Item);
    try
      if not (GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
      begin
        TTranslateManager.Instance.BeginTranslate;
        try
          TDBPopupMenu.Instance.Execute(Self, ElvMain.ClientToScreen(MousePos).x, ElvMain.ClientToScreen(MousePos).y,Info);
        finally
          TTranslateManager.Instance.EndTranslate;
        end;
      end else
      begin
        FileNames := TStringList.Create;
        try
          for I := 0 to Info.Count - 1 do
          if Info[i].Selected then
            FileNames.Add(Info[i].FileName);

          GetProperties(FileNames, MousePos, ElvMain);
        finally
          F(FileNames);
        end;
      end;
    finally
      F(Info);
    end;
  end else
  begin
    if ElvMain.Selection.First = nil then
      FilesCount := ElvMain.Items.Count
    else
    begin
      if GetSelectionCount = 1 then
        FileList := GetAllFiles
      else
        FileList := GetSelectedTstrings;

      FilesCount := FileList.Count;
      F(FileList);
    end;
    SetBoolAttr(aScript,'$OneFileExists', FilesCount > 0);
    S := ListMenuScript;
    TTranslateManager.Instance.BeginTranslate;
    try
      LoadMenuFromScript(ScriptListPopupMenu.Items, DBkernel.ImageList, S, aScript, ScriptExecuted, FExtImagesInImageList, True);
    finally
      TTranslateManager.Instance.EndTranslate;
    end;
    ScriptListPopupMenu.Popup(ElvMain.ClientToScreen(MousePos).x, ElvMain.ClientToScreen(MousePos).y);
  end;
end;

procedure TSearchForm.ListViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  MenuInfo: TDBPopupMenuInfo;
  Item: TEasyItem;
begin
  Item := ItemAtPos(X, Y);
  MouseDowned := Button = mbRight;
  ItemByMouseDown := False;
  if Item = nil then
    ElvMain.Selection.ClearAll;

  EnsureSelectionInListView(ElvMain, Item, Shift, X, Y, ItemSelectedByMouseDown, ItemByMouseDown);

  if (Button = mbLeft) and (Item <> nil) then
  begin
    DBCanDrag := True;
    FilesToDrag.Clear;
    GetCursorPos(DBDragPoint);
    MenuInfo := GetCurrentPopUpMenuInfo(Item);
    try

      for I:=0 to MenuInfo.Count - 1 do
        if MenuInfo[I].Selected then
          if FileExistsSafe(MenuInfo[I].FileName) then
            FilesToDrag.Add(MenuInfo[I].FileName);

    finally
      F(MenuInfo);
    end;
    if FilesToDrag.Count = 0 then
      DBCanDrag := False;
  end;
end;

procedure TSearchForm.ListViewDblClick(Sender: TObject);
var
  MenuInfo: TDBPopupMenuInfo;
  P, P1: TPoint;
  Item: TEasyItem;
begin
  GetCursorPos(P1);
  P := ElvMain.ScreenToClient(P1);
  Item := ItemByPointImage(ElvMain, P);
  if (Item <> nil) and (Item.ImageIndex > -1) then
  begin
    if ItemByPointStar(ElvMain, P, FPictureSize, FBitmapImageList[Item.ImageIndex].Graphic) <> nil then
    begin
      RatingPopupMenu1.Tag := ItemAtPos(P.X, P.Y).Tag;
      Application.HideHint;
      THintManager.Instance.CloseHint;
      LastMouseItem := nil;
      RatingPopupMenu1.Popup(P1.X, P1.Y);
      Exit;
    end;
  end;

  if Active then
    Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;

  if ElvMain.Selection.First <> nil then
  begin
    MenuInfo := GetCurrentPopUpMenuInfo(ListViewSelected);
    try
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      Viewer.Execute(Sender, MenuInfo);
      Viewer.Show;
    finally
      F(MenuInfo);
    end;
  end;
end;

procedure TSearchForm.ListViewSelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
begin
  if not SelectTimer.Enabled then
    SelectTimer.Enabled := True;
end;

procedure TSearchForm.ListViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Pos, MousePos : Tpoint;
  I : Integer;
  Item: TEasyItem;
  Data : TDBPopupMenuInfoRecord;
  SpotX, SpotY : Integer;

begin
  PopupHandled := False;

  GetCursorPos(MousePos);
  if DBCanDrag then
  begin
    if (Abs(DBDragPoint.X - MousePos.X) > 3) or (Abs(DBDragPoint.Y - MousePos.Y) > 3) then
    begin
      Pos := ElvMain.ScreenToClient(DBDragPoint);
      item := ItemAtPos(Pos.X, Pos.Y);
      if item = nil then
        Exit;

      if ElvMain.Selection.FocusedItem = nil then
        ElvMain.Selection.FocusedItem := item;

      DBDragPoint := ElvMain.ScreenToClient(DBDragPoint);
      CreateDragImage(ElvMain, DragImageList, FBitmapImageList, Item.Caption, DBDragPoint, SpotX, SpotY);

      DropFileSource1.Files.Clear;
      for I := 0 to FilesToDrag.Count - 1 do
        DropFileSource1.Files.Add(FilesToDrag[I]);
      ElvMain.Refresh;

      Application.HideHint;
      THintManager.Instance.CloseHint;

      HintTimer.Enabled := False;

      DropFileSource1.ImageHotSpotX := SpotX;
      DropFileSource1.ImageHotSpotY := SpotY;
      DropFileSource1.ImageIndex := 0;
      DropFileSource1.Execute;
      DBCanDrag := False;
    end;
  end;

  if THintManager.Instance.HintAtPoint(MousePos) <> nil then
    Exit;

  Item := ItemByPointImage(ElvMain, Point(X,Y));

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

    Data := GetSearchRecordFromItemData(LastMouseItem);

    if Settings.Readbool('Options', 'AllowPreview', True) then
      ElvMain.ShowHint := not FileExistsSafe(Data.FileName);

    ElvMain.Hint := Data.Comment;
  end;
end;

procedure TSearchForm.ListViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Handled: Boolean;
  Item: TEasyItem;
begin

  Item := Self.ItemAtPos(X, Y);
  RightClickFix(ElvMain, Button, Shift, Item, ItemByMouseDown, ItemSelectedByMouseDown);

  if MouseDowned then
    if Button = MbRight then
    begin
      ListViewContextPopup(ElvMain, Point(X, Y), Handled);
      PopupHandled := True;
    end;
  MouseDowned := False;
  DBCanDrag := False;
  FilesToDrag.Clear;
end;

procedure TSearchForm.ListViewExit(Sender: TObject);
begin
  DBCanDrag := False;
  FilesToDrag.Clear;
end;

procedure TSearchForm.EasyListViewDblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
      ShiftState: TShiftState; var Handled: Boolean);
begin
  ListViewDblClick(Sender);
end;

procedure TSearchForm.EasyListViewItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
  ListViewSelectItem(Sender, Item, False);
end;

procedure TSearchForm.EasyListviewKeyAction(Sender: TCustomEasyListview;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
var
  AChar: Char;
begin
  AChar := Char(CharCode);
  ListViewKeyPress(Sender, AChar);
  if CharCode = VK_F2 then
    ListViewKeyDown(Sender, CharCode, []);
end;

procedure TSearchForm.ListViewResize(Sender : TObject);
begin
  ElvMain.BackGround.OffsetX := ElvMain.Width - ElvMain.BackGround.Image.Width;
  ElvMain.BackGround.OffsetY := ElvMain.Height - ElvMain.BackGround.Image.Height;
  LoadSizes;
end;

procedure TSearchForm.ListViewMouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if not (ssCtrl in Shift) then
    Exit;

  if WheelDelta < 0 then
    ZoomOut
  else
    ZoomIn;
end;

procedure TSearchForm.ListViewIncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);
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

procedure TSearchForm.EasyListViewItemEdited(Sender: TCustomEasyListview;
  Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
var
  S : string;
begin
  S := NewValue;
  RenameResult := True;
  ListViewEdited(Sender, Item, S);
  ElvMain.EditManager.Enabled := False;
  Accept := RenameResult;

  if not Accept then
    MessageBoxDB(Handle, Format(L('Cannot rename file! Error code = %d'), [GetLastError]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TSearchForm.EasyListViewItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Data : TDBPopupMenuInfoRecord;
  Y : Integer;
  CustomInfo: string;
  Extension: TSearchDataExtension;
  SimilarAmount: Integer;
begin
  if FListUpdating or (Item.Data = nil) then
    Exit;

  if Item.ImageIndex < 0 then
    Exit;

  Data := GetSearchRecordFromItemData(Item);
  CustomInfo := '';

  Extension := TSearchDataExtension(Data.Data);
  if (Extension.CompareResult.ByGistogramm > 0) or (Extension.CompareResult.ByPixels > 0) then
  begin
    SimilarAmount := Round((Extension.CompareResult.ByPixels * 8 + Extension.CompareResult.ByGistogramm * 2) / 10);
    if SimilarAmount > 0 then
      CustomInfo := Format('%d%%', [SimilarAmount])
    else
      CustomInfo := '<1%';
  end;
  DrawDBListViewItem(TEasyListview(Sender), ACanvas, Item, ARect,
                     FBitmapImageList, Y,
                     True, Data.ID, Data.ExistedFileName, Data.Rating, Data.Rotation,
                     Data.Access, Data.Crypted, Data.Exists, False, CustomInfo);

end;

{$ENDREGION}

{$REGION 'Button events'}

procedure TSearchForm.SlideShow1Click(Sender: TObject);
var
  DBInfo: TDBPopupMenuInfo;
begin
  DBInfo := GetCurrentPopUpMenuInfo(nil);
  try
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    Viewer.Execute(Sender, DBInfo);
    Viewer.Show;
  finally
    F(DBInfo);
  end;
end;

procedure TSearchForm.SelectAll1Click(Sender: TObject);
begin
  ElvMain.Selection.SelectAll;
  ElvMain.SetFocus;
end;

procedure TSearchForm.BreakOperation(Sender: TObject);
begin
  StopLoadingList;
  if TbStopOperation.Enabled then
    TbStopOperation.Click;
  WlStartStop.Onclick := DoSearchNow;
  WlStartStop.Text := L('Search');
  ElvMain.Show;
  ElvMain.Groups.EndUpdate;
end;

procedure TSearchForm.CopySearchResults1Click(Sender: TObject);
var
  I : integer;
  Sclipbrd : string;
begin
  Sclipbrd := '';
  for I := 1 to ElvMain.Items.Count do
    Sclipbrd := Sclipbrd + IntToStr(ElvMain.Items[I - 1].Tag) + '$';

  Clipboard.AsText := Sclipbrd;
end;

procedure TSearchForm.FormDeactivate(Sender: TObject);
begin
  Hinttimer.Enabled := False;
end;

procedure TSearchForm.HintTimerTimer(Sender: TObject);
var
  P, P1: Tpoint;
  I: Integer;
  Item: TEasyItem;
  DataRecord: TDBPopupMenuInfoRecord;
begin
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);

  if (not Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
    (ItemWithHint <> LastMouseItem) then
  begin
    HintTimer.Enabled := False;
    Exit;
  end;
  if FPictureSize >= ThHintSize then
    Exit;

  if LastMouseItem = nil then
    Exit;

  HintTimer.Enabled := False;
  DataRecord := GetSearchRecordFromItemData(LastMouseItem);
  THintManager.Instance.CreateHintWindow(Self, DataRecord.Copy, P, HintRealA);

  Item := ItemAtPos(P1.X, P1.Y);
  if Item = nil then
    Exit;

  if Settings.Readbool('Options', 'UseHotSelect', True) then

    if not(CtrlKeyDown or ShiftKeyDown) then
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
end;

procedure TSearchForm.SaveResults1Click(Sender: TObject);
var
  N, I : integer;
  LA : TArStrings;
  ItemsImThArray : TArAnsiStrings;
  ItemsIDArray : TArInteger;
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter :=
      L('Collection Results (*.ids)|*.ids|Collection file list (*.dbl)|*.dbl|Collection hashes (*.ith)|*.ith');
    SaveDialog.FilterIndex := 1;

    if SaveDialog.Execute then
    begin
      N := SaveDialog.GetFilterIndex;
      if N = 1 then
      begin
        FileName := SaveDialog.FileName;
        if GetExt(FileName) <> 'IDS' then
          FileName := FileName + '.ids';
        if FileExistsSafe(FileName) then
          if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
            TD_ICON_WARNING) then
            Exit;

        SetLength(ItemsIDArray, ElvMain.Items.Count);
        for I := 0 to ElvMain.Items.Count - 1 do
          ItemsIDArray[I] := GetSearchRecordFromItemData(ElvMain.Items[I]).ID;

        SaveIDsTofile(FileName, ItemsIDArray);
      end;
      if N = 2 then
      begin
        SetLength(LA, 0);
        FileName := SaveDialog.FileName;
        if GetExt(FileName) <> 'DBL' then
          FileName := FileName + '.dbl';
        if FileExistsSafe(FileName) then
          if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
            TD_ICON_WARNING) then
            Exit;

        SetLength(ItemsIDArray, ElvMain.Items.Count);
        for I := 0 to ElvMain.Items.Count - 1 do
          ItemsIDArray[I] := GetSearchRecordFromItemData(ElvMain.Items[I]).ID;

        SaveListTofile(FileName, ItemsIDArray, LA);
      end;
      if N = 3 then
      begin
        FileName := SaveDialog.FileName;
        if GetExt(FileName) <> 'ITH' then
          FileName := FileName + '.ith';
        if FileExistsSafe(FileName) then
          if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
            TD_ICON_WARNING) then
            Exit;

        SetLength(ItemsImThArray, ElvMain.Items.Count);
        for I := 0 to ElvMain.Items.Count - 1 do
          ItemsImThArray[I] := GetSearchRecordFromItemData(ElvMain.Items[I]).LongImageID;

        SaveImThsTofile(FileName, ItemsImThArray);
      end;
    end;
  finally
    F(SaveDialog);
  end;
end;

procedure TSearchForm.LoadResults1Click(Sender: TObject);
var
  IDs: TArInteger;
  Files: TArStrings;
  S: string;
  I: Integer;
  OpenDialog: DBOpenDialog;
begin
  if FUpdatingDB then
    Exit;

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter :=
      L('All Supported (*.ids;*.ith;*.dbl)|*.ids;*.ith;*.dbl|Collection Results (*.ids)|*.ids|Collection file list (*.dbl)|*.dbl|Collection hashes (*.ith)|*.ith');
    OpenDialog.FilterIndex := 1;

    if OpenDialog.Execute then
    begin
      if GetExt(OpenDialog.FileName) = 'IDS' then
      begin
        SearchEdit.Text := LoadIDsFromfile(OpenDialog.FileName);
        DoSearchNow(nil);
      end;
      if GetExt(OpenDialog.FileName) = 'DBL' then
      begin
        LoadDblFromfile(OpenDialog.FileName, IDs, Files);
        S := '';
        for I := 0 to Length(IDs) - 1 do
          S := S + IntToStr(IDs[I]) + '$';
        SearchEdit.Text := S;
        DoSearchNow(nil);
      end;
      if GetExt(OpenDialog.FileName) = 'ITH' then
      begin
        SearchEdit.Text := ':HashFile(' + OpenDialog.FileName + '):';
        DoSearchNow(nil);
      end;
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TSearchForm.ListViewKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    ListViewDblClick(Sender);

  if CharInSet(Key, Unusedchar) then
    Key := #0;
end;

procedure TSearchForm.ListViewEdited(Sender: TObject; Item: TEasyItem;
  var S: String);
var
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  S := Copy(S, 1, Min(Length(S), 255));
  SearchRecord := GetSearchRecordFromItemData(Item);

  if S = ExtractFileName(SearchRecord.FileName) then
    Exit;

  begin
    if GetExt(S) <> GetExt(SearchRecord.FileName) then
    if FileExistsSafe(SearchRecord.FileName) then
    begin
      If ID_OK <> MessageBoxDB(Handle, L('Do you really want to change file extension?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      begin
        S := ExtractFileName(SearchRecord.FileName);
        Exit;
      end;
    end;
    RenameResult := RenameFileWithDB(KernelEventCallBack, SearchRecord.FileName, ExtractFilePath(SearchRecord.FileName) + S, SearchRecord.ID, False);
  end;
end;

procedure TSearchForm.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ListViewSelected = nil then
    Exit;

  if (Ord(Key) = VK_F2) and (GetSelectionCount = 1) then
  begin
    ElvMain.EditManager.Enabled := True;
    ElvMain.Selection.First.Edit;
  end;

  if Active then
    Application.HideHint;
  THintManager.Instance.CloseHint;
end;

{$ENDREGION}

procedure TSearchForm.SaveClick(Sender: TObject);
var
  S, S1, S2, S3, _sqlexectext, CommonKeyWords, KeyWords, CommonGroups, Groups: string;
  EventInfo: TEventValues;
  I, J, Id: Integer;
  List: TSQLList;
  IDs: string;
  XCount: Integer;
  ProgressForm: TProgressActionForm;
  WorkQuery: TDataSet;
  SearchRecord: TDBPopupMenuInfoRecord;
begin
  WorkQuery := GetQuery;
  try
    if GetSelectionCount = 1 then
    begin
      S := Label2.Caption;
      Delete(S, 1, 5);
      Id := Strtointdef(S, -1);
      if Id < 0 then
        Exit;
      _sqlexectext := 'Update $DB$';
      S1 := NormalizeDBString(Memo2.Lines.Text);
      S2 := NormalizeDBString(Memo1.Lines.Text);
      S3 := NormalizeDBString(FPropertyGroups);
      _sqlexectext := _sqlexectext + ' Set Comment=' + S1 + ' , KeyWords=' + S2 + ', Rating=' + Inttostr
        (RatingEdit.Rating) +
        ', DateToAdd = :Date, IsDate = :IsDate, aTime = :aTime, IsTime = :IsTime, Groups = ' + S3;

      _sqlexectext := _sqlexectext + ' Where ID=:ID';
      WorkQuery.Active := False;
      SetSQL(WorkQuery, _sqlexectext);

      SetDateParam(WorkQuery, 'Date', DateTimePicker1.DateTime);
      SetBoolParam(WorkQuery, 1, not IsDatePanel.Visible);
      SetDateParam(WorkQuery, 'aTime', TimeOf(DateTimePicker4.DateTime));
      SetBoolParam(WorkQuery, 3, not IsTimePanel.Visible);
      SetIntParam(WorkQuery, 4, Id); // Must be LAST PARAM!
      ExecSQL(WorkQuery);
      EventInfo.Comment := Memo2.Lines.Text;
      EventInfo.KeyWords := Memo1.Lines.Text;
      EventInfo.Rating := RatingEdit.Rating;
      EventInfo.Groups := FPropertyGroups;
      EventInfo.Date := DateTimePicker1.DateTime;
      EventInfo.IsDate := not IsDatePanel.Visible;
      DBKernel.DoIDEvent(Self, Id, [EventID_Param_Rating, EventID_Param_Comment, EventID_Param_KeyWords,
        EventID_Param_Date, EventID_Param_IsDate, EventID_Param_Groups], EventInfo);
    end else
    begin
      FUpdatingDB := True;
      Save.Enabled := False;
      WlStartStop.Enabled := False;
      ElvMain.Enabled := False;

      Memo1.Enabled := False;
      Memo2.Enabled := False;
      WllGroups.Enabled := False;
      DateTimePicker1.Enabled := False;
      DateTimePicker4.Enabled := False;
      RatingEdit.Enabled := False;

      XCount := 0;
      CommonKeyWords := SelectedInfo.CommonKeyWords;
      if VariousKeyWords(Memo1.Lines.Text, CommonKeyWords) then
        Inc(XCount);
      if not CompareGroups(CurrentItemInfo.Groups, FPropertyGroups) then
        Inc(XCount);

      ProgressForm := nil;
      try
        if XCount > 0 then
        begin
          ProgressForm := GetProgressWindow;
          ProgressForm.OperationCount := XCount;
          ProgressForm.OperationPosition := 0;
          ProgressForm.OneOperation := False;
          ProgressForm.MaxPosCurrentOperation := Length(SelectedInfo.Ids);
          ProgressForm.XPosition := 0;
          ProgressForm.DoFormShow;
        end;

        // [BEGIN] Date Support
        if not PanelValueIsDateSets.Visible then
        begin
          _sqlexectext := 'Update $DB$ Set DateToAdd = :Date Where ';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')'
            else
              _sqlexectext := _sqlexectext + ' OR (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetDateParam(WorkQuery, 'Date', DateTimePicker1.DateTime);
          ExecSQL(WorkQuery);
          EventInfo.Date := DateTimePicker1.DateTime;
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_Date], EventInfo);
        end;
        if not PanelValueIsDateSets.Visible then
        begin
          _sqlexectext := 'Update $DB$ Set IsDate = :IsDate Where ';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')'
            else
              _sqlexectext := _sqlexectext + ' OR (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetBoolParam(WorkQuery, 0, not IsDatePanel.Visible);
          ExecSQL(WorkQuery);
          EventInfo.IsDate := not IsDatePanel.Visible;
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_IsDate], EventInfo);
        end;
        // [END] Date Support

        // [BEGIN] Time Support
        if not PanelValueIsTimeSets.Visible then
        begin
          _sqlexectext := 'Update $DB$ Set aTime = :aTime Where ';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')'
            else
              _sqlexectext := _sqlexectext + ' OR (ID=' + Inttostr(SelectedInfo.Ids[I]) + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetDateParam(WorkQuery, 'aTime', TimeOf(DateTimePicker4.DateTime));
          ExecSQL(WorkQuery);
          EventInfo.Time := TimeOf(DateTimePicker4.DateTime);
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_Time], EventInfo);
        end;
        if not PanelValueIsTimeSets.Visible then
        begin
          _sqlexectext := 'Update $DB$ Set IsTime = :IsTime Where ID in (';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(SelectedInfo.Ids[I]) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(SelectedInfo.Ids[I]) + '';
          _sqlexectext := _sqlexectext + ')';

          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetBoolParam(WorkQuery, 0, not IsTimePanel.Visible);
          ExecSQL(WorkQuery);
          EventInfo.IsTime := not IsTimePanel.Visible;
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_IsTime], EventInfo);
        end;
        // [END] Time Support

        // [BEGIN] Rating Support
        if not RatingEdit.Islayered then
        begin
          _sqlexectext := 'Update $DB$ Set Rating = :Rating Where ID in (';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(SelectedInfo.Ids[I]) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(SelectedInfo.Ids[I]) + '';
          _sqlexectext := _sqlexectext + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetIntParam(WorkQuery, 0, RatingEdit.Rating);
          ExecSQL(WorkQuery);
          EventInfo.Rating := RatingEdit.Rating;
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_Rating], EventInfo);
        end;
        // [END] Rating Support

        // [BEGIN] Comment Support
        if not Memo2.readonly then
        begin
          _sqlexectext := 'Update $DB$ Set Comment = ' + NormalizeDBString(Memo2.Text) + ' Where ID in (';
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            if I = 0 then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(SelectedInfo.Ids[I]) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(SelectedInfo.Ids[I]) + '';
          _sqlexectext := _sqlexectext + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          ExecSQL(WorkQuery);
          EventInfo.Comment := Memo2.Text;
          for I := 0 to Length(SelectedInfo.Ids) - 1 do
            DBKernel.DoIDEvent(Self, SelectedInfo.Ids[I], [EventID_Param_Comment], EventInfo);
        end;
        // [END] Comment Support

        // [BEGIN] KeyWords Support
        if VariousKeyWords(Memo1.Lines.Text, CommonKeyWords) then
        begin
          FreeSQLList(List);
          ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
          ProgressForm.XPosition := 0;
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
              KeyWords := SearchRecord.KeyWords;
              ReplaceWords(SelectedInfo.CommonKeyWords, Memo1.Lines.Text, KeyWords);
              if VariousKeyWords(KeyWords, SearchRecord.KeyWords) then
                AddQuery(List, KeyWords, SearchRecord.ID);
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
            { !!! } Application.ProcessMessages;
            _sqlexectext := 'Update $DB$ Set KeyWords = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
            WorkQuery.Active := False;
            SetSQL(WorkQuery, _sqlexectext);
            ExecSQL(WorkQuery);
            EventInfo.KeyWords := List[I].Value;
            for J := 0 to Length(List[I].IDs) - 1 do
              DBKernel.DoIDEvent(Self, List[I].IDs[J], [EventID_Param_KeyWords], EventInfo);
          end;
        end;
        // [END] KeyWords Support

        // [BEGIN] Groups Support
        CommonGroups := SelectedInfo.Groups;
        if not CompareGroups(CurrentItemInfo.Groups, FPropertyGroups) then
        begin
          FreeSQLList(List);
          ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
          ProgressForm.XPosition := 0;
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
              Groups := SearchRecord.Groups;
              ReplaceGroups(SelectedInfo.Groups, FPropertyGroups, Groups);
              if not CompareGroups(Groups, SearchRecord.Groups) then
                AddQuery(List, Groups, SearchRecord.ID);

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
            { !!! } Application.ProcessMessages;
            _sqlexectext := 'Update $DB$ Set Groups = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
            WorkQuery.Active := False;
            SetSQL(WorkQuery, _sqlexectext);
            ExecSQL(WorkQuery);
            EventInfo.Groups := List[I].Value;
            for J := 0 to Length(List[I].IDs) - 1 do
              DBKernel.DoIDEvent(Self, List[I].IDs[J], [EventID_Param_Groups], EventInfo);
          end;

        end;
        // [END] Groups Support
        FUpdatingDB := False;
        ElvMain.Enabled := True;
        WlStartStop.Enabled := True;

        Memo1.Enabled := True;
        Memo2.Enabled := True;
        WllGroups.Enabled := True;
        DateTimePicker1.Enabled := True;
        DateTimePicker4.Enabled := True;
        RatingEdit.Enabled := True;
      finally
        R(ProgressForm);
      end;
      DoShowSelectInfo;
    end;
  finally
    FreeDS(WorkQuery);
  end;
  Save.Enabled := False;
end;

function TSearchForm.GetListItemByID(ID : integer) : TEasyItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if ElvMain.Items[I].Tag = ID then
    begin
      Result := ElvMain.Items[I];
      Break;
    end;
  end;
end;

function TSearchForm.GetSelectedTStrings: TStrings;
var
  I : Integer;
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  Result := TStringList.Create;

  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    if ElvMain.Items[I].Selected then
      if FileExistsSafe(SearchRecord.FileName) then
        Result.Add(SearchRecord.FileName);
  end;
end;

function TSearchForm.GetAllFiles: TStrings;
var
  I : Integer;
begin
  Result := TStringList.Create;
  for I := 0 to ElvMain.Items.Count - 1 do
    Result.Add(GetSearchRecordFromItemData(ElvMain.Items[I]).FileName);
end;

procedure TSearchForm.RefreshInfoByID(ID : integer);
begin
  if FCurrentSelectedID <> ID then
    Exit;

  ListViewSelectItem(nil, GetListItemByID(ID), true);
end;

procedure TSearchForm.ClearItems;
var
  I : Integer;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
    TDataObject(ElvMain.Items[I].Data).Free;

  ElvMain.Items.Clear;
end;

procedure TSearchForm.Memo1Change(Sender: TObject);

  function ReadCHDate: Boolean;
  begin
    if GetSelectionCount > 1 then
      Result := not PanelValueIsDateSets.Visible and ((CurrentItemInfo.IsDate <> not IsDatePanel.Visible) or
          (CurrentItemInfo.Date <> DateTimePicker1.DateTime) or
          (SelectedInfo.IsVariousDates and not PanelValueIsDateSets.Visible))
    else
      Result := (((CurrentItemInfo.Date <> DateTimePicker1.DateTime) or (IsDatePanel.Visible <> not SelectedInfo.IsDate)
          ) and not PanelValueIsDateSets.Visible);
  end;

  function ReadCHTime: Boolean;
  var
    VarTime: Boolean;
  begin
    VarTime := Abs(CurrentItemInfo.Time - TimeOf(DateTimePicker4.DateTime)) > 1 / (24 * 60 * 60 * 3);
    if GetSelectionCount > 1 then
      Result := not PanelValueIsTimeSets.Visible and ((CurrentItemInfo.IsTime <> not IsTimePanel.Visible) or
          (VarTime or (SelectedInfo.IsVariousTimes and not PanelValueIsTimeSets.Visible)))
    else
      Result := ((VarTime or (IsTimePanel.Visible <> not SelectedInfo.IsTime)) and not PanelValueIsTimeSets.Visible);
  end;

begin
 if GetSelectionCount > 1 then
  begin
    if ReadCHTime or ReadCHDate or not RatingEdit.Islayered or (not Memo2.readonly and SelectedInfo.IsVariousComments)
      or (not SelectedInfo.IsVariousComments and (SelectedInfo.CommonComment <> Memo2.Text)) or VariousKeyWords
      (SelectedInfo.CommonKeyWords, Memo1.Text) or not CompareGroups(CurrentItemInfo.Groups, FPropertyGroups) then
      Save.Enabled := True
    else
      Save.Enabled := False;
    if not RatingEdit.Islayered then
      Label8.Font.Style := Label8.Font.Style + [FsBold]
    else
      Label8.Font.Style := Label8.Font.Style - [FsBold];
    if (not Memo2.readonly and SelectedInfo.IsVariousComments) or
      (not SelectedInfo.IsVariousComments and (SelectedInfo.CommonComment <> Memo2.Text)) then
      Label6.Font.Style := Label6.Font.Style + [FsBold]
    else
      Label6.Font.Style := Label6.Font.Style - [FsBold];
    if VariousKeyWords(SelectedInfo.CommonKeyWords, Memo1.Text) then
      Label5.Font.Style := Label5.Font.Style + [FsBold]
    else
      Label5.Font.Style := Label5.Font.Style - [FsBold];
  end else
  begin
    if ReadCHTime or ReadCHDate or (CurrentItemInfo.Rating <> RatingEdit.Rating) or
      (CurrentItemInfo.Comment <> Memo2.Text) or VariousKeyWords(CurrentItemInfo.KeyWords, Memo1.Text)
      or not CompareGroups(CurrentItemInfo.Groups, FPropertyGroups) then
      Save.Enabled := True
    else
      Save.Enabled := False;
    if (CurrentItemInfo.Rating <> RatingEdit.Rating) then
      Label8.Font.Style := Label8.Font.Style + [FsBold]
    else
      Label8.Font.Style := Label8.Font.Style - [FsBold];
    if (CurrentItemInfo.Comment <> Memo2.Text) then
      Label6.Font.Style := Label6.Font.Style + [FsBold]
    else
      Label6.Font.Style := Label6.Font.Style - [FsBold];
    if VariousKeyWords(CurrentItemInfo.KeyWords, Memo1.Text) then
      Label5.Font.Style := Label5.Font.Style + [FsBold]
    else
      Label5.Font.Style := Label5.Font.Style - [FsBold];
  end;
end;

procedure TSearchForm.ErrorQSL(sql : string);
begin
  MessageBoxDB(Handle, Format(L('Error in SQL. Query: %s'), [Sql]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TSearchForm.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  RefreshParams : TEventFields;
  FilesToUpdate : TDBPopupMenuInfo;
  I, ReRotation : Integer;
  SearchRecord  : TDBPopupMenuInfoRecord;
  DataObject    : TDataObject;
begin

  if EventID_Repaint_ImageList in params then
    ElvMain.Refresh

  else if EventID_Param_GroupsChanged in params then
    ReRecreateGroupsList

  else
  if EventID_Param_DB_Changed in params then
  begin
    Caption:=ProductName + ' -  ['+DBkernel.GetDataBaseName+']';
    ReRecreateGroupsList;
    FPictureSize := ThImageSize;
    LoadSizes;
    ClearItems;
    SearchEditChange(Self);
  end else
  if ID=-2 then
    Exit
    //TODO: move -2 to some constant
  else if [EventID_Param_DB_Changed,EventID_Param_Refresh_Window] * params<>[] then
  begin
    ReRecreateGroupsList;
    LoadQueryList;
    DoSearchNow(nil);
  end else if EventID_Param_Delete in params then
    DeleteItemByID(ID);

  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    if SearchRecord.ID = ID then
    begin
      if EventID_Param_Private in params then SearchRecord.Access := Value.Access;
      if EventID_Param_Crypt in params then SearchRecord.Crypted := Value.Crypt;
      if EventID_Param_Include in params then
      begin
        SearchRecord.Include := Value.Include;
        DataObject := TDataObject(ElvMain.Items[I].Data);
        DataObject.Include := Value.Include;
        ElvMain.Items[I].BorderColor := GetListItemBorderColor(DataObject);
      end;
      if EventID_Param_Attr in params then SearchRecord.Attr := Value.Attr;
      if EventID_Param_IsDate in params then SearchRecord.IsDate := Value.IsDate;
      if EventID_Param_IsTime in params then SearchRecord.IsTime := Value.IsTime;
      if EventID_Param_Groups in params then SearchRecord.Groups := Value.Groups;
      if EventID_Param_Links in params then SearchRecord.Links := Value.Links;
      if EventID_Param_Date in params then SearchRecord.Date := Value.Date;
      if EventID_Param_Time in params then SearchRecord.Time := Value.Time;
      if EventID_Param_Rating in params then SearchRecord.Rating := Value.Rating;
      if EventID_Param_Name in params then SearchRecord.FileName := Value.Name;
      if EventID_Param_KeyWords in params then SearchRecord.KeyWords := Value.KeyWords;
      if EventID_Param_Comment in params then SearchRecord.Comment := Value.Comment;
      if EventID_Param_Rotate in params then
      begin
        ReRotation := GetNeededRotation(SearchRecord.Rotation, Value.Rotate);
        SearchRecord.Rotation := Value.Rotate;

        if ElvMain.Items[i].ImageIndex > -1 then
          ApplyRotate(FBitmapImageList[ElvMain.Items[i].ImageIndex].Bitmap, ReRotation);
      end;
      RefreshParams := [EventID_Param_Crypt, EventID_Param_Image, EventID_Param_Delete, EventID_Param_Critical];
      if (ElvMain.Items[i].ImageIndex < 0) or (RefreshParams * params <> []) then
      begin
        FilesToUpdate := TDBPopupMenuInfo.Create;
        FilesToUpdate.Add(SearchRecord.Copy);

        NewFormSubState;
        RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(Self, SubStateID, nil, FPictureSize, FilesToUpdate, True));
      end;
      ElvMain.Items[I].Invalidate(False);
    end;
  end
end;

function TSearchForm.HintRealA(Info: TDBPopupMenuInfoRecord): Boolean;
var
  P, P1: Tpoint;
begin
  Getcursorpos(P);
  P1 := ElvMain.ScreenToClient(P);
  Result := not((not Self.Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
    (ItemAtPos(P1.X, P1.Y) = nil));
end;

procedure TSearchForm.CMMOUSELEAVE(var Message: TWMNoParams);
var
  P: Tpoint;
begin
  GetCursorPos(P);
  if THintManager.Instance.HintAtPoint(P) <> nil then
    Exit;

  LastMouseItem := nil;
  if Active then
    Application.HideHint;
  THintManager.Instance.CloseHint;
  Hinttimer.Enabled := False;
end;

procedure TSearchForm.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  if LockChangePath or Creating or FUpdatingDB then
    Exit;
  SearchEdit.Text := ':folder(' + TreeView.Path + '):';
  DoSearchNow(Sender);
end;

function TSearchForm.GetCurrentPopUpMenuInfo(Item : TEasyItem) : TDBPopupMenuInfo;
var
  I: Integer;
  MenuRecord: TDBPopupMenuInfoRecord;
  SearchRecord: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfo.Create;
  Result.IsListItem := False;
  Result.IsPlusMenu := False;
  Result.IsPlusMenu := False;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    MenuRecord := SearchRecord.Copy;
    Result.Add(MenuRecord);
  end;
  Result.Position := 0;
  Result.AttrExists := True;
  for I := 0 to ElvMain.Items.Count - 1 do
    Result[I].Selected := ElvMain.Items[I].Selected;
  if Item <> nil then
  begin
    if GetSelectionCount = 1 then
    begin
      Result.IsListItem := True;
      if ElvMain.Selection.First <> nil then
      begin
        Result.ListItem := ElvMain.Selection.First;
        Result.Position := ItemIndex(ElvMain.Selection.First);
      end;
    end
    else if GetSelectionCount > 1 then
    begin
      Result.Position := ItemIndex(Item);
    end;
  end;
end;

procedure TSearchForm.Properties1Click(Sender: TObject);
begin
  if GetSelectionCount > 1 then
    PropertyPanel.Visible := True;
  ExplorerPanel.Visible := False;
  Properties1.Checked := True;
  Explorer2.Checked := False;
end;

procedure TSearchForm.Explorer2Click(Sender: TObject);
begin
  PropertyPanel.Visible := False;
  ExplorerPanel.Visible := True;
  if not TreeView.UseShellImages then
  begin
    TreeView.ObjectTypes := [OtFolders];
    TreeView.UseShellImages := True;
    TreeView.Refresh(TreeView.TopItem);
  end;
  ExplorerPanel.Align := AlClient;
  Properties1.Checked := False;
  Explorer2.Checked := True;
  TreeView.FullCollapse;
  if FSearchPath <> '' then
    if DirectoryExists(FSearchPath) then
      TreeView.Path := FSearchPath;
end;

procedure TSearchForm.SearchPanelAContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  WHandle: THandle;
begin
  WHandle := WindowFromPoint(SearchPanelA.ClientToScreen(MousePos));
  if WHandle <> SearchEdit.Handle then
    PmSearchOptions.Popup(SearchPanelA.ClientToScreen(MousePos).X, SearchPanelA.ClientToScreen(MousePos).Y);
end;

procedure TSearchForm.RatingEditMouseDown(Sender: TObject);
begin
  if RatingEdit.Islayered then
    RatingEdit.Islayered := False;
  Memo1Change(Sender);
end;

procedure TSearchForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  i : integer;
  TmpBool : Boolean;
begin
  if msg.message = FProgressMessage then
    FW7TaskBar := CreateTaskBarInstance;

  if msg.message = FReloadGroupsMessage then
    ReloadGroups;

  if (Msg.message = WM_KEYDOWN) and (SearchEdit.Focused) and (Msg.wParam = VK_RETURN) then
  begin
    Handled := True;
    Msg.Message := 0;
    DoSearchNow(nil);
  end;

  if (Msg.message = WM_KEYUP) and SearchEdit.Focused then
    Msg.Message := 0;

  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);

  if Msg.hwnd = ElvMain.Handle then
  begin
    if Msg.message = WM_RBUTTONDOWN then
      WindowsMenuTickCount:=GetTickCount;

    //middle mouse button
    if Msg.message = WM_MBUTTONDOWN then
    begin
      Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
      BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
      Msg.message := 0;
    end;

    if (Msg.message = WM_MOUSEWHEEL) then
    begin
      if not Handled then
      begin
        if CtrlKeyDown then
        begin
          if Msg.wParam > 0 then i := 1 else i := -1;
          ListViewMouseWheel(ElvMain, [ssCtrl], i, Point(0,0), TmpBool);
          Msg.message := 0;
        end;

        Application.HideHint;
        THintManager.Instance.CloseHint;
      end;
    end;

    if Msg.message = WM_KEYDOWN then
    begin
      WindowsMenuTickCount:=GetTickCount;
      //context menu button
      if (Msg.wParam = VK_APPS) then
        ListViewContextPopup(ElvMain,Point(-1,-1), TmpBool);

      if (Msg.wParam = Ord('r')) or (Msg.wParam = Ord('R')) and ShiftkeyDown then
      begin
        ReloadIDMenu;
        ReloadListMenu;
        MessageBoxDB(Handle, L('Menu reloaded!'), L('Information'), TD_BUTTON_OK,TD_ICON_INFORMATION);
      end;

      if (Msg.wParam = VK_SUBTRACT) then
        ZoomOut;
      if (Msg.wParam = VK_ADD) then
        ZoomIn;
      if (Msg.wParam = VK_DELETE) and not FUpdatingDB then
        DeleteSelected;
      if (Msg.wParam = Ord('a')) and CtrlKeyDown and not FUpdatingDB then
        SelectAll1Click(Nil);
      if (Msg.wParam = Ord('s')) and CtrlKeyDown and tbStopOperation.Enabled then
        TbStopOperationClick(nil);

    end;
  end;
end;

procedure TSearchForm.SetPath(Value: string);
begin
  Value := IncludeTrailingBackslash(Value);
  FSearchPath := Value;
  LockChangePath := True;
  if ExplorerPanel.Visible then
    TreeView.Path := Value;
  LockChangePath := False;
end;

procedure TSearchForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TSearchForm.Datenotexists1Click(Sender: TObject);
begin
  IsDatePanel.Visible := True;
  Memo1Change(Sender);
end;

procedure TSearchForm.IsDatePanelDblClick(Sender: TObject);
begin
  if FUpdatingDB then
    Exit;
  IsDatePanel.Visible := False;
  Memo1Change(Sender);
end;

procedure TSearchForm.PanelValueIsDateSetsDblClick(Sender: TObject);
begin
  if FUpdatingDB then
    Exit;
  PanelValueIsDateSets.Visible := False;
  Memo1Change(Sender);
end;

procedure TSearchForm.ComboBox1_KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TSearchForm.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
begin
  FCurrentGroups := EncodeGroups(FPropertyGroups);

  FillImageList;
  WllGroups.Clear;

  if Length(FCurrentGroups) = 0 then
  begin
    LblInfo := TStaticText.Create(WllGroups);
    LblInfo.Parent := WllGroups;
    WllGroups.AddControl(LblInfo, True);
    LblInfo.Caption := L('There are no groups');
  end;

  WL := WllGroups.AddLink(True);
  WL.Text := L('Edit groups');
  WL.ImageList := GroupsImageList;
  WL.ImageIndex := 0;
  WL.ImageCanRegenerate := True;
  WL.Tag := -1;
  WL.OnClick := GroupClick;

  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    WL := WllGroups.AddLink;
    WL.Text := FCurrentGroups[I].GroupName;
    WL.ImageList := GroupsImageList;
    WL.ImageIndex := I + 1;
    WL.ImageCanRegenerate := True;
    WL.Tag := I;
    WL.OnClick := GroupClick;
  end;
  WllGroups.ReallignList;
end;

procedure TSearchForm.GroupClick(Sender: TObject);
var
  KeyWords : string;
  WL: TWebLink;
begin
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    ShowGroupInfo(WL.Text, False, nil);
  end else
  begin
    KeyWords := Memo1.Text;
    DBChangeGroups(FPropertyGroups, KeyWords);
    PostMessage(Handle, FReloadGroupsMessage, 0, 0);
    Memo1.Text := KeyWords;
    Memo1Change(Sender);
  end;
end;

procedure TSearchForm.ComboBox1_DblClick(Sender: TObject);
var
  KeyWords: string;
begin
  KeyWords := Memo1.Text;
  DBChangeGroups(FPropertyGroups, KeyWords);
  Memo1.Text := KeyWords;
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
  DateNotExists1.Visible := not IsDatePanel.Visible;
  DateExists1.Visible := IsDatePanel.Visible;
  DateExists1.Visible := DateExists1.Visible and not FUpdatingDB;
  Datenotsets1.Visible := Datenotsets1.Visible and not FUpdatingDB;
  Datenotsets1.Visible := Datenotsets1.Visible and (GetSelectionCount > 1) and not FUpdatingDB;
end;

procedure TSearchForm.Ratingnotsets1Click(Sender: TObject);
begin
  RatingEdit.Islayered := True;
  Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu5Popup(Sender: TObject);
begin
  Ratingnotsets1.Visible := not RatingEdit.Islayered and not FUpdatingDB;
  if GetSelectionCount < 2 then
    Ratingnotsets1.Visible := False;
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
  if not Memo2.readonly then
    Exit;
  Memo2.readonly := False;
  Memo2.Cursor := CrDefault;
  Memo2.Text := '';
  SelectedInfo.CommonComment := '';
  CurrentItemInfo.Comment := SelectedInfo.CommonComment;
  Memo1Change(Sender);
end;

procedure TSearchForm.Comentnotsets1Click(Sender: TObject);
begin
  Memo2.readonly := True;
  Memo2.Cursor := CrHandPoint;
  Memo2.Text := L('<Different comments>');
  SelectedInfo.CommonComment := '';
  CurrentItemInfo.Comment := SelectedInfo.CommonComment;
  Memo1Change(Sender);
end;

procedure TSearchForm.Datenotsets1Click(Sender: TObject);
begin
  PanelValueIsDateSets.Visible := True;
  Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu6Popup(Sender: TObject);
begin
  SetComent1.Visible := Memo2.ReadOnly;
  Comentnotsets1.Visible := not Memo2.ReadOnly;
  MenuItem2.Visible := not Memo2.ReadOnly;
  Cut1.Visible := not Memo2.ReadOnly;
  Copy2.Visible := not Memo2.ReadOnly;
  Paste1.Visible := not Memo2.ReadOnly;
  Undo1.Visible := not Memo2.ReadOnly;
end;

procedure TSearchForm.LoadLanguage;
begin
  BeginTranslate;
  try
    FMoreThan := L('More than');
    FLessThan := L('Less than');
    SearchEdit.NullText := L('Empty query');
    Label1.Caption := L('Search text');
    Label2.Caption := L('ID');
    Label8.Caption := L('Rating');
    Label4.Caption := L('Size');
    Label6.Caption := L('Comment');
    Label5.Caption := L('Keywords');
    Save.Caption := L('Save');
    DoSearchNow1.Caption := L('Search');
    Panels1.Caption := L('Panels');
    Properties1.Caption := L('Properties');
    Explorer2.Caption := L('Explorer');
    EditGroups1.Caption := L('Edit groups');
    GroupsManager1.Caption := L('Groups manager');
    Ratingnotsets1.Caption := L('No rating');
    SetComent1.Caption := L('Set comment');
    Comentnotsets1.Caption := L('No comment');
    MenuItem2.Caption := L('Select all');
    Cut1.Caption := L('Cut');
    Copy2.Caption := L('Copy');
    Paste1.Caption := L('Paste');
    Undo1.Caption := L('Undo');
    OpeninExplorer1.Caption := L('Open in explorer');
    AddFolder1.Caption := L('Add folder');
    SortbyID1.Caption := L('Sort by ID');
    SortbyName1.Caption := L('Sort by Name');
    SortbyDate1.Caption := L('Sort by Date');
    SortbyRating1.Caption := L('Sort by Rating');
    SortbyFileSize1.Caption := L('Sort by file size');
    SortbySize1.Caption := L('Sort by image size');

    SortbyCompare1.Caption := L('Sort by compare result');

    Increment1.Caption := L('Sort Increment');
    Decremect1.Caption := L('Sort Decrement');

    Datenotexists1.Caption := L('No date');
    DateExists1.Caption := L('Date exists');
    Datenotsets1.Caption := L('No date');
    PanelValueIsDateSets.Caption := L('Different values');
    IsDatePanel.Caption := L('No date');
    Setvalue1.Caption := L('Set value');
    Setvalue2.Caption := L('Set value');
    IsTimePanel.Caption := L('No time');
    PanelValueIsTimeSets.Caption := L('Different values');

    Timenotsets1.Caption := L('No time');
    TimeExists1.Caption := L('Set time');;
    TimenotExists1.Caption := L('No time');;

    View2.Caption := L('Slide show');
    ShowDateOptionsLink.Text := L('Date options');

    TbSearch.Caption := L('Search');
    TbSort.Caption := L('Sort');
    TbZoomOut.Caption := L('Zoom Out');
    TbZoomIn.Caption := L('Zoom In');
    TbGroups.Caption := L('Groups');

    TbSave.Caption := L('Save');
    TbLoad.Caption := L('Open');
    TbExplorer.Caption := L('Explorer');
    SearchEdit.StartText := L('Enter your query here');

    RtgQueryRating.Hint := L('Rating');
    TwbPrivate.Hint := L('Display private photos');
    TwlIncludeAllImages.Hint := L('Display hidden photos');
  finally
    EndTranslate;
  end;
end;

procedure TSearchForm.HelpTimerTimer(Sender: TObject);
var
  DS : TDataSet;
  MessageText: string;

  procedure XHint(XDS: TDataSet);
  var
    HelpHint: string;

    function Count: Integer;
    begin
      Result := XDS.FieldByName('RecordsCount').AsInteger;
    end;

  begin
    HelpHint := '     ' + L('To add photos to the collection, select "Explore" from the context menu, then find your pictures and select "Add items".' + '$nl$$nl$    Click "Help" for further assistance.$nl$     Or click on the cross at the top to help is no longer displayed.$nl$$nl$$nl$', 'Help');

    if Count < 50 then
      DoHelpHintCallBackOnCanClose(L('Help'), HelpHint, Point(0, 0), ElvMain, HelpNextClick,
        L('Next...'), HelpCloseClick)
    else
    begin
      HelpNo := 0;
      Settings.WriteBool('HelpSystem', 'CheckRecCount', False);
    end;
  end;

begin
  if not Active then
    Exit;
  if  GetForegroundWindow <> Handle then
    Exit;
  if FolderView then
    Exit;
  HelpTimer.Enabled := False;
  if not Settings.ReadBool('HelpSystem', 'CheckRecCount', True) then
  begin
    HelpActivationNO := 0;
    MessageText := '     ' + L('Do you want to get help, how to activate the program? If YES, then click on "More..." for further assistance.$nl$     Or click on the cross at the top to help is no longer displayed. $nl$$nl$', 'Help');
    if TActivationManager.Instance.IsDemoMode then
      if Settings.ReadBool('HelpSystem', 'ActivationHelp', True) then
        DoHelpHintCallBackOnCanClose(L('Help'), MessageText, Point(0, 0), ElvMain,
          HelpActivationNextClick, L('Next...'), HelpActivationCloseClick)
      else if not TActivationManager.Instance.IsDemoMode then
        Settings.WriteBool('HelpSystem', 'ActivationHelp', False);
    Exit;
  end;

  DS := GetQuery(True);
  try
    SetSQL(DS, 'Select count(*) as RecordsCount from $DB$');
    DS.Open;
    XHint(DS);
  finally
    FreeDS(DS);
  end;
end;

procedure TSearchForm.PopupMenu7Popup(Sender: TObject);
begin
  Setvalue1.Visible := not FUpdatingDB;
end;

procedure TSearchForm.PmEditGroupsPopup(Sender: TObject);
begin
  EditGroups1.Visible := not FUpdatingDB;
end;

procedure TSearchForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, Abs_cifr) then
    if Key <> #8 then
      Key := #0;
end;

procedure TSearchForm.PopupMenu8Popup(Sender: TObject);
begin
  if TreeView.SelectedFolder <> nil then
  begin
    TempFolderName := TreeView.SelectedFolder.PathName;
    OpeninExplorer1.Visible := DirectoryExists(TreeView.SelectedFolder.PathName);
    AddFolder1.Visible := OpeninExplorer1.Visible;
    View2.Visible := OpeninExplorer1.Visible;
  end else
  begin
    TempFolderName := '';
    OpeninExplorer1.Visible := False;
    AddFolder1.Visible := False;
    View2.Visible := False;
  end;
end;

procedure TSearchForm.OpeninExplorer1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(Self.TempFolderName);
    Show;
    SetFocus;
  end;
end;

procedure TSearchForm.AddFolder1Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
  UpdaterDB.AddDirectory(TempFolderName, nil);
end;

procedure TSearchForm.Hide1Click(Sender: TObject);
begin
  Properties1Click(Sender);
end;

procedure TSearchForm.Splitter1CanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  Accept := (NewSize >= 150) and (NewSize <= 340)
end;

procedure TSearchForm.DeleteItemByID(ID: integer);
var
  I : Integer;
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    if SearchRecord.ID = ID then
    begin
      ElvMain.Items[I].Data.Free;
      ElvMain.Items.Delete(I);
      Break;
    end;
  end;
end;

procedure TSearchForm.HelpCloseClick(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(Handle, L('Do you really want to refuse help?', 'Help'), L('Confirm'),
    TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);
  if CanClose then
  begin
    HelpNo := 0;
    Settings.WriteBool('HelpSystem', 'CheckRecCount', False);
  end;
end;

procedure TSearchForm.HelpNextClick(Sender: TObject);
var
  Handled: Boolean;
begin
  ListViewContextPopup(ElvMain, Point(0, 0), Handled);
  HelpNO := 1;
end;

procedure TSearchForm.FormShow(Sender: TObject);
begin
  if not FHelpTimerStarted then
    HelpTimer.Enabled := True;
  FHelpTimerStarted := True;

  SearchEdit.SetFocus;
end;

procedure TSearchForm.HelpActivationCloseClick(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(Handle, L('Do you really want to refuse help?', 'Help'), L('Confirm'),
    TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);
  if CanClose then
  begin
    HelpActivationNO := 0;
    Settings.WriteBool('HelpSystem', 'ActivationHelp', False);
  end;
end;

procedure TSearchForm.HelpActivationNextClick(Sender: TObject);
var
  Handled: Boolean;
  MessageText: string;
begin
  HelpActivationNO := HelpActivationNO + 1;
  if HelpActivationNO = 1 then
  begin
    MessageText := '     ' + L('To activate the program call the context menu, select "Help" -> "Activation"$nl$$nl$     Click "More ..." for further assistance.$nl$     Or click on the cross at the top to help no longer displayed.$nl$$nl$', 'Help');
    DoHelpHintCallBackOnCanClose(L('Help'), MessageText, Point(0, 0), ElvMain,
      HelpActivationNextClick, L('Next...'), HelpActivationCloseClick);
  end;
  if HelpActivationNO = 2 then
  begin
    ListViewContextPopup(ElvMain, Point(0, 0), Handled);
    HelpActivationNO := 3;
  end;
end;

procedure TSearchForm.Image3Click(Sender: TObject);
var
  Groups: TGroups;
  Size, I: Integer;
  MenuItem: TmenuItem;
  P: TPoint;
  SmallB, B: TBitmap;
  JPEG: TJPEGImage;
begin
  if not GroupsLoaded then
    LoadGroupsList(True);

  GetCursorPos(P);
  Groups := GetRegisterGroupList(True, not(ShiftKeyDown));
  QuickGroupsSearch.Items.Clear;
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := Pf24bit;
    for I := 0 to Length(Groups) - 1 do
    begin
      B := TBitmap.Create;
      try
        B.PixelFormat := pf24bit;
        JPEG := TJPEGImage.Create;
        try
          JPEG.Assign(Groups[I].GroupImage);
          B.Canvas.Brush.Color := Graphics.ClMenu;
          B.Canvas.Pen.Color := Graphics.ClMenu;
          Size := Max(JPEG.Width, JPEG.Height);
          B.Width := Size;
          B.Height := Size;
          B.Canvas.Rectangle(0, 0, Size, Size);
          B.Canvas.Draw(B.Width div 2 - JPEG.Width div 2, B.Height div 2 - JPEG.Height div 2, JPEG);
          DoResize(16, 16, B, SmallB);
        finally
          F(JPEG);
        end;
      finally
        F(B);
      end;
      GroupsImageList.Add(SmallB, nil);
    end;
  finally
    F(SmallB);
  end;

  for I := 0 to Length(Groups) - 1 do
  begin
    MenuItem := TmenuItem.Create(QuickGroupsSearch.Items);
    MenuItem.Caption := Groups[I].GroupName;
    MenuItem.OnClick := QuickGroupsearch;
    MenuItem.ImageIndex := I;
    QuickGroupsSearch.Items.Add(MenuItem);
  end;
  QuickGroupsSearch.Popup(P.X, P.Y);
end;

procedure TSearchForm.QuickGroupsearch(Sender: TObject);
var
  S: string;
  I: Integer;
begin
  S := (Sender as TMenuItem).Caption;
  for I := 1 to Length(S) - 1 do
  begin
    if (S[I] = '&') and (S[I + 1] <> '&') then
      Delete(S, I, 1);
  end;
  for I := 1 to ComboBoxSearchGroups.Items.Count - 1 do
    if ComboBoxSearchGroups.ItemsEx[I].Caption = S then
    begin
      ComboBoxSearchGroups.ItemIndex := I;
      Break;
    end;
  if WlStartStop.Text <> L('Stop') then
    DoSearchNow(Sender);
end;

procedure TSearchForm.SortbyID1Click(Sender: TObject);
begin
  SortbyID1.Checked := True;
  SortLink.Tag := 0;
  SortLink.Text := L('Sort by ID');
  SortingClick(Sender);
end;

procedure TSearchForm.SortbyName1Click(Sender: TObject);
begin
  SortbyName1.Checked := True;
  SortLink.Tag := 1;
  SortLink.Text := L('Sort by Name');
  SortingClick(Sender);
end;

procedure TSearchForm.SortbyDate1Click(Sender: TObject);
begin
  SortbyDate1.Checked := True;
  SortLink.Tag := 2;
  SortLink.Text := L('Sort by Date');
  SortingClick(Sender);
end;

procedure TSearchForm.SortbyRating1Click(Sender: TObject);
begin
  SortbyRating1.Checked := True;
  SortLink.Tag := 3;
  SortLink.Text := L('Sort by Rating');
  SortingClick(Sender);
end;

procedure TSearchForm.SortbyFileSize1Click(Sender: TObject);
begin
  SortbyFileSize1.Checked := True;
  SortLink.Tag := 4;
  SortLink.Text := L('Sort by file size');
  SortingClick(Sender);
end;

procedure TSearchForm.SortbySize1Click(Sender: TObject);
begin
  SortbySize1.Checked := True;
  SortLink.Tag := 5;
  SortLink.Text := L('Sort by image size');
  SortingClick(Sender);
end;

procedure TSearchForm.Image4_Click(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  SortingPopupMenu.Popup(P.X, P.Y);
end;

procedure TSearchForm.Decremect1Click(Sender: TObject);
begin
  Decremect1.Checked := True;
  SortLink.Icon := Image6.Picture.Icon;
  SortLink.RefreshBuffer;
  SortingClick(Sender);
end;

procedure TSearchForm.Increment1Click(Sender: TObject);
begin
  Increment1.Checked := True;
  SortLink.Icon := Image5.Picture.Icon;
  SortLink.RefreshBuffer;
  SortingClick(Sender);
end;

procedure TSearchForm.FillImageList;
var
  I: Integer;
  Size: Integer;
  Group: TGroup;
  SmallB, B: TBitmap;
  GroupImageValid: Boolean;
  FCurrentGroups: TGroups;

  procedure CreteDefaultGroupImage;
  begin
    SmallB.Width := 16;
    SmallB.Height := 16;
    SmallB.Canvas.Pen.Color := clBtnFace;
    SmallB.Canvas.Brush.Color := clBtnFace;
    SmallB.Canvas.Rectangle(0, 0, 16, 16);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
    GroupImageValid := True;
  end;

begin
  GroupsImageList.Clear;
  FCurrentGroups := EncodeGroups(FPropertyGroups);

  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    CreteDefaultGroupImage;
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;

  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf24bit;
      SmallB.Canvas.Brush.Color := ClBtnFace;
      Group := GetGroupByGroupName(FCurrentGroups[I].GroupName, True);
      GroupImageValid := False;
      if Group.GroupImage <> nil then
        if not Group.GroupImage.Empty then
        begin
          B := TBitmap.Create;
          try
            B.PixelFormat := pf24bit;
            GroupImageValid := True;

            Size := Max(Group.GroupImage.Width, Group.GroupImage.Height);
            B.Canvas.Brush.Color := clBtnFace;
            B.Canvas.Pen.Color := clBtnFace;
            B.Width := Size;
            B.Height := Size;
            B.Canvas.Rectangle(0, 0, Size, Size);
            B.Canvas.Draw(B.Width div 2 - Group.GroupImage.Width div 2, B.Height div 2 - Group.GroupImage.Height div 2,
              Group.GroupImage);

            FreeGroup(Group);
            DoResize(15, 15, B, SmallB);
            SmallB.Height := 16;
            SmallB.Width := 16;
          finally
            F(B);
          end;
        end else
          CreteDefaultGroupImage;
      GroupsImageList.Add(SmallB, nil);
    finally
      F(SmallB);
    end;
  end;


end;

procedure TSearchForm.InsertSpesialQueryPopupMenuItemClick(
  Sender: TObject);
begin
  case (Sender as TMenuItem).Tag of
    1:
      SearchEdit.Text := ':DeletedFiles:';
    2:
      SearchEdit.Text := ':Dublicates:';
  end;
end;

procedure TSearchForm.DeleteSelected;
var
  I: Integer;
begin
  ElvMain.Groups.BeginUpdate(False);
  try
    for I := ElvMain.Items.Count - 1 downto 0 do
      if ElvMain.Items[I].Selected then
        DeleteItemByID(ElvMain.Items[I].Tag);

  finally
    ElvMain.Groups.EndUpdate(False);
  end;
end;

procedure TSearchForm.HidePanelTimerTimer(Sender: TObject);
begin
  if (ListViewSelected = nil) or (GetSelectionCount = 0) then
  begin
    HidePanelTimer.Enabled := False;
    PropertyPanel.Hide;
  end;
end;

procedure TSearchForm.PanelValueIsTimeSetsDblClick(Sender: TObject);
begin
  if FUpdatingDB then
    Exit;
  PanelValueIsTimeSets.Visible := False;
  Memo1Change(Sender);
end;

procedure TSearchForm.PopupMenu11Popup(Sender: TObject);
begin
  TimeNotExists1.Visible := not IsTimePanel.Visible;
  TimeExists1.Visible := IsTimePanel.Visible;
  TimeExists1.Visible := TimeExists1.Visible and not FUpdatingDB;
  Timenotsets1.Visible := Timenotsets1.Visible and not FUpdatingDB;
  Timenotsets1.Visible := Timenotsets1.Visible and (GetSelectionCount > 1) and not FUpdatingDB;
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

procedure TSearchForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TSearchForm.ShowExplorerPage1Click(Sender: TObject);
begin
  if ExplorerPanel.Visible then
    Properties1Click(Sender)
  else
    Explorer2Click(Sender);
end;

procedure TSearchForm.DoShowSelectInfo;
var
  I, Indent : integer;
  Size : Int64;
  KeyWordList : TStringList;
  CommonKeyWords : String;
  ArComments : TStringList;
  ArDates : TArDateTime;
  ArIsDates : TArBoolean;
  ArIsTimes : TArBoolean;
  ArInt : TArInteger;
  ArGroups : TStringList;
  ArTimes : TArTime;
  WorkQuery : TDataSet;
  SearchRecord : TDBPopupMenuInfoRecord;
  SelectQuery : TDataSet;
  DA: TDBAdapter;
begin
  SelectQuery := GetQuery;
  DA := TDBAdapter.Create(SelectQuery);
  try
    ReadOnlyQuery(SelectQuery);
    if Active then
      Memo2.PopupMenu := nil;

    if ListViewSelected = nil then
      if GetSelectionCount = 0 then
      begin
        HidePanelTimer.Enabled := True;
        Exit;
      end;
    HidePanelTimer.Enabled := False;
    BeginScreenUpdate(PropertyPanel.Handle);
    try
      PropertyPanel.Show;
    finally
      EndScreenUpdate(PropertyPanel.Handle, False);
    end;
    WorkQuery := GetQuery;
    try
      if (GetSelectionCount > 1) then
      begin
        SelectedInfo.One := False;
        SelectedInfo.Nil_ := False;
        Size := 0;
        SetLength(SelectedInfo.Ids, 0);
        SetLength(ArDates, 0);
        SetLength(ArTimes, 0);
        SetLength(ArIsDates, 0);
        SetLength(ArIsTimes, 0);
        SetLength(ArInt, 0);
        ArComments := TStringList.Create;
        KeyWordList := TStringList.Create;
        ArGroups := TStringList.Create;
        try

          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
              Size := Size + SearchRecord.FileSize;
              KeyWordList.Add(SearchRecord.KeyWords);
              SetLength(SelectedInfo.Ids, Length(SelectedInfo.Ids) + 1);
              SelectedInfo.Ids[Length(SelectedInfo.Ids) - 1] := SearchRecord.ID;
              SetLength(ArDates, Length(ArDates) + 1);
              ArDates[Length(ArDates) - 1] := SearchRecord.Date;
              SetLength(ArTimes, Length(ArTimes) + 1);
              ArTimes[Length(ArTimes) - 1] := SearchRecord.Time;

              SetLength(ArInt, Length(ArInt) + 1);
              ArInt[Length(ArInt) - 1] := SearchRecord.Rating;
              ArComments.Add(SearchRecord.Comment);

              SetLength(ArIsDates, Length(ArIsDates) + 1);
              ArIsDates[Length(ArIsDates) - 1] := SearchRecord.IsDate;
              SetLength(ArIsTimes, Length(ArIsTimes) + 1);
              ArIsTimes[Length(ArIsTimes) - 1] := SearchRecord.IsTime;

              ArGroups.Add(SearchRecord.Groups);
            end;
          BeginScreenUpdate(PropertyPanel.Handle);
          try
            SelectedInfo.CommonRating := MaxStatInt(ArInt);
            RatingEdit.Rating := SelectedInfo.CommonRating;
            RatingEdit.Islayered := True;
            RatingEdit.Layered := 100;

            CurrentItemInfo.Date := MaxStatDate(ArDates);
            CurrentItemInfo.IsDate := MaxStatBool(ArIsDates);
            SelectedInfo.Date := MaxStatDate(ArDates);
            SelectedInfo.IsDate := MaxStatBool(ArIsDates);
            PanelValueIsDateSets.Visible := IsVariousBool(ArIsDates) or IsVariousDate(ArDates);
            DateTimePicker1.DateTime := SelectedInfo.Date;
            IsDatePanel.Visible := not SelectedInfo.IsDate;
            SelectedInfo.IsVariousDates := PanelValueIsDateSets.Visible;

            CurrentItemInfo.Time := MaxStatDate(TArDateTime(ArTimes));
            CurrentItemInfo.IsTime := MaxStatBool(ArIsTimes);
            SelectedInfo.Time := MaxStatTime(ArTimes);
            SelectedInfo.IsTime := MaxStatBool(ArIsTimes);
            PanelValueIsTimeSets.Visible := IsVariousBool(ArIsTimes) or IsVariousDate(TArDateTime(ArTimes));
            DateTimePicker4.DateTime := SelectedInfo.Time;
            IsTimePanel.Visible := not SelectedInfo.IsTime;
            SelectedInfo.IsVariousTimes := PanelValueIsTimeSets.Visible;

            CommonKeyWords := GetCommonWordsA(KeyWordList);
            SelectedInfo.CommonKeyWords := CommonKeyWords;
            Label4.Caption := Format(L('Size: %s'), [SizeInText(Size)]);
            Label2.Caption := L('Items') + ' = ' + Inttostr(GetSelectionCount);
            Memo1.Lines.Text := CommonKeyWords;
            SelectedInfo.IsVariousComments := IsVariousArStrings(ArComments);
            if SelectedInfo.IsVariousComments then
            begin
              SelectedInfo.CommonComment := L('<Different comments>');
              CurrentItemInfo.Comment := SelectedInfo.CommonComment;
              Memo2.PopupMenu := PopupMenu6;
            end else
            begin
              SelectedInfo.CommonComment := ArComments[0];
              CurrentItemInfo.Comment := SelectedInfo.CommonComment;
            end;
            if SelectedInfo.IsVariousComments then
            begin
              Memo2.readonly := True;
              Memo2.Cursor := CrHandPoint;
            end;
            Memo2.Text := SelectedInfo.CommonComment;
            CurrentItemInfo.Groups := GetCommonGroups(ArGroups);
            SelectedInfo.Groups := CurrentItemInfo.Groups;
            FPropertyGroups := CurrentItemInfo.Groups;
            ReloadGroups;
            Memo1Change(nil);
          finally
            EndScreenUpdate(PropertyPanel.Handle, True);
          end;
          FCurrentSelectedID := -1;
        finally
          F(ArComments);
          F(KeyWordList);
          F(ArGroups);
        end;
      end else
      begin
        RatingEdit.Islayered := False;

        Indent := 0;
        if ElvMain.Selection.First <> nil then
          Indent := ElvMain.Selection.First.Tag;

        SetSQL(SelectQuery, 'SELECT * FROM $DB$ WHERE ID=' + Inttostr(Indent));
        SelectQuery.Active := True;
        BeginScreenUpdate(PropertyPanel.Handle);
        try
          Label2.Caption := Format(L('ID = %d'), [Indent]);
          Label4.Caption := Format(L('Size = %s'), [SizeInText(DA.FileSize)]);
          Memo1.Lines.Text := DA.KeyWords;
          Memo2.Lines.Text := DA.Comment;
          RatingEdit.Rating := DA.Rating;
          CurrentItemInfo.Rating := RatingEdit.Rating;

          ElvMain.Hint := DA.Comment;
          FCurrentSelectedID := DA.ID;
          CurrentItemInfo.KeyWords := DA.KeyWords;
          CurrentItemInfo.Comment := DA.Comment;

          DateTimePicker1.DateTime := DA.Date;
          CurrentItemInfo.Date := DA.Date;
          CurrentItemInfo.IsDate := DA.IsDate;
          SelectedInfo.IsDate := CurrentItemInfo.IsDate;
          IsDatePanel.Visible := not CurrentItemInfo.IsDate;
          PanelValueIsDateSets.Visible := False;

          DateTimePicker4.DateTime := DA.Time;
          CurrentItemInfo.Time := DA.Time;
          CurrentItemInfo.IsTime := DA.IsTime;
          SelectedInfo.IsTime := CurrentItemInfo.IsTime;
          IsTimePanel.Visible := not CurrentItemInfo.IsTime;
          PanelValueIsTimeSets.Visible := False;

          CurrentItemInfo.Groups := DA.Groups;
          FPropertyGroups := CurrentItemInfo.Groups;
          ReloadGroups;
          Save.Enabled := False;
          Memo2.Cursor := CrDefault;
          Application.HintHidePause := 50 * Length(DA.Comment);
          SelectQuery.Close;
          Memo1Change(nil);
        finally
          EndScreenUpdate(PropertyPanel.Handle, True);
        end;
      end;
    finally
      FreeDS(WorkQuery);
    end;
  finally
    F(DA);
    FreeDS(SelectQuery);
  end;
end;

procedure TSearchForm.SelectTimerTimer(Sender: TObject);
begin
  if FLastSelectionCount < 2 then
  begin
    SelectTimer.Enabled := False;
    DoShowSelectInfo;
    WindowsMenuTickCount := GetTickCount;
    FLastSelectionCount := 0;
    Exit;
  end;
  if FLastSelectionCount = GetSelectionCount then
  begin
    SelectTimer.Enabled := False;
    DoShowSelectInfo;
    FLastSelectionCount := 0;
    Exit;
  end;
  FLastSelectionCount := GetSelectionCount;
end;

function TSearchForm.GetListView: TEasyListview;
begin
  Result := ElvMain;
end;

function TSearchForm.GetRegQueryRootPath: string;
begin
  Result := 'Search\DB_' + DBKernel.GetDataBaseName + '\Query';
end;

procedure TSearchForm.IsTimePanelDblClick(Sender: TObject);
begin
  if FUpdatingDB then
    Exit;
  IsTimePanel.Visible := False;
  Memo1Change(Sender);
end;

procedure TSearchForm.PmSearchOptionsPopup(Sender: TObject);
begin
  DoSearchNow1.Visible:=not FUpdatingDB;
end;

procedure TSearchForm.View2Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  N: Integer;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    GetFileListByMask(TempFolderName, TFileAssociations.Instance.ExtensionList, Info, N, True);
    if Info.Count > 0 then
    begin
      Viewer.Execute(Self, Info);
      Viewer.Show;
    end;
  finally
    F(Info);
  end;
end;

procedure TSearchForm.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  if DropFileTarget2.Files.Count > 0 then
  begin
    SearchEdit.Text := ':ScanImageW(' + DropFileTarget2.Files[0] + ':1):';
    SearchEdit.SetFocus;
  end;
end;

procedure TSearchForm.ReloadListMenu;
begin
  ListMenuScript := ReadScriptFile('scripts\SearchListMenu.dbini');
end;

procedure TSearchForm.ScriptExecuted(Sender: TObject);
begin
  LoadItemVariables(aScript,Sender as TMenuItemW);
  if Trim((Sender as TMenuItemW).Script) <> '' then
    ExecuteScript(Sender as TMenuItemW, aScript, '', FExtImagesInImageList, DBkernel.ImageList, ScriptExecuted);
end;

procedure TSearchForm.LoadExplorerValue(Sender: TObject);
begin
  SetBoolAttr(aScript,'$explorer',ExplorerPanel.Visible);
end;

function TSearchForm.GetSelectionCount : integer;
begin
  Result := ElvMain.Selection.Count;
end;

function TSearchForm.ListViewSelected : TEasyItem;
begin
  Result := ElvMain.Selection.First;
end;

function TSearchForm.ItemAtPos(X,Y : integer): TEasyItem;
begin
  Result := ItemByPointImage(ElvMain, Point(X, Y));
end;

procedure TSearchForm.N05Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  SetRating(RatingPopupMenu1.Tag,(Sender as TMenuItem).Tag);
  EventInfo.Rating:=(Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Self,RatingPopupMenu1.Tag,[EventID_Param_Rating],EventInfo);
end;

function TSearchForm.ItemIndex(item : TEasyItem) : integer;
var
  I : integer;
begin
  Result := item.Index;
  for I := 0 to item.OwnerGroup.Index - 1 do
    Result := Result + ElvMain.Groups[I].Items.Count;
end;

procedure TSearchForm.KernelEventCallBack(ID: Integer; Params: TEventFields;
  Value: TEventValues);
begin
  DBKernel.DoIDEvent(Self, ID, Params, Value);
end;

procedure TSearchForm.ShowDateOptionsLinkClick(Sender: TObject);
begin
  dblDate.Active := True;
  if pnDateRange.Visible then
    pnDateRange.Hide
  else begin
    pnDateRange.Show;
    LoadDateRange;
  end;
end;

procedure TSearchForm.LoadSizes;
begin
  SetLVThumbnailSize(ElvMain, FPictureSize);
end;

function TSearchForm.InternalGetImage(FileName: string;
  Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
var
  I : Integer;
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    if AnsiLowerCase(SearchRecord.FileName) = FileName then
    begin
      if ElvMain.Items[I].ImageIndex <> -1 then
        if FBitmapImageList[ElvMain.Items[I].ImageIndex].IsBitmap then
        begin
          Width := SearchRecord.Width;
          Height := SearchRecord.Height;
          Bitmap.Assign(FBitmapImageList[ElvMain.Items[I].ImageIndex].Graphic);
          Result := True;
        end;
      Break;
    end;
  end;
end;

function TSearchForm.FileNameExistsInList(FileName : string) : Boolean;
var
  I : Integer;
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    if AnsiLowerCase(SearchRecord.FileName) = FileName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TSearchForm.ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap) : Boolean;
var
  I : Integer;
  SearchRecord : TDBPopupMenuInfoRecord;
  ListItem : TEasyItem;
begin
  FileName := AnsiLowerCase(FileName);
  Result := False;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ListItem := ElvMain.Items[I];
    SearchRecord := GetSearchRecordFromItemData(ListItem);
    if AnsiLowerCase(SearchRecord.FileName) = FileName then
    begin
      if ListItem.ImageIndex = -1 then
        ListItem.ImageIndex := FBitmapImageList.AddBitmap(Bitmap)
      else
        FBitmapImageList.Items[ListItem.ImageIndex].Graphic := Bitmap;
      Bitmap := nil;
      ListItem.Invalidate(True);
      Result := True;
      Break;
    end;
  end;
  F(Bitmap);
end;

procedure TSearchForm.BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
var
  SelectedVisible : boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;
    FPictureSize := SizeX;
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


procedure TSearchForm.BigImagesTimerTimer(Sender: TObject);
begin
  if FListUpdating then
    Exit;
  BigImagesTimer.Enabled := False;
  //тут начинается загрузка больших картинок
  ReloadBigImages;
end;

procedure TSearchForm.ReloadBigImages;
var
  I : Integer;
  Data : TDBPopupMenuInfo;
begin
  NewFormSubState;
  Data := TDBPopupMenuInfo.Create;
  for I := 0 to ElvMain.Items.Count - 1 do
    Data.Add(GetSearchRecordFromItemData(ElvMain.Items[I]).Copy);

  RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(Self, SubStateID, nil, FPictureSize, Data, True));
end;

function TSearchForm.GetVisibleItems: TArStrings;
var
  I : integer;
  R : TRect;
  RV : TRect;
  SearchRecord : TDBPopupMenuInfoRecord;
begin
  SetLength(Result, 0);

  RV :=  ElvMain.Scrollbars.ViewableViewportRect;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    SearchRecord := GetSearchRecordFromItemData(ElvMain.Items[I]);
    r:=Rect(ElvMain.ClientRect.Left + RV.Left, ElvMain.ClientRect.Top + RV.Top, ElvMain.ClientRect.Right + RV.Left, ElvMain.ClientRect.Bottom + RV.Top);
    if RectInRect(R, TEasyCollectionItemX(ElvMain.Items[i]).GetDisplayRect) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := SearchRecord.FileName;
    end;
  end;
end;

procedure TSearchForm.LoadGroupsList(LoadAllLIst : boolean = false);
var
  Groups : TGroups;
  Size, I : integer;
  SmallB, B : TBitmap;
  JPEG : TJPEGImage;
begin
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    if not LoadAllLIst then
    begin
      SearchGroupsImageList.Clear;
      ComboBoxSearchGroups.Items.Clear;
      with ComboBoxSearchGroups.ItemsEx.Add do
      begin
        B := TBitmap.Create;
        try
          B.PixelFormat := pf24bit;
          B.Canvas.Brush.Color := Graphics.clMenu;
          B.Canvas.Pen.Color := Graphics.clMenu;
          Size := Max(ImageAllGroups.Picture.Graphic.Width, ImageAllGroups.Picture.Graphic.Height);
          B.Width := Size;
          B.Height := Size;
          B.Canvas.Draw(B.Width div 2 - ImageAllGroups.Picture.Graphic.Width div 2, B.Height div 2 - ImageAllGroups.Picture.Graphic.Height div 2,ImageAllGroups.Picture.Graphic);
          DoResize(32, 32, B, SmallB);
          SearchGroupsImageList.Add(SmallB, nil);
        finally
          B.Free;
        end;
       Data := Pointer(1);
       Caption := L('All groups');
       ImageIndex := 0;
      end;
      ComboBoxSearchGroups.ItemIndex:=0;
      Exit;
    end;
    if GroupsLoaded then
      Exit;

    GroupsLoaded := True;
    Groups := GetRegisterGroupList(True, False);

    for I := 0 to Length(Groups) - 1 do
    begin
      B := TBitmap.Create;
      try
        B.PixelFormat := pf24bit;
        JPEG := TJPEGImage.Create;
        try
          JPEG.Assign(Groups[I].GroupImage);
          B.Canvas.Brush.Color := Graphics.clMenu;
          B.Canvas.Pen.Color := Graphics.clMenu;
          Size := Max(JPEG.Width, JPEG.Height);
          B.Width := Size;
          B.Height := Size;
          B.Canvas.Draw(B.Width div 2 - JPEG.Width div 2, B.Height div 2 - JPEG.Height div 2, JPEG);
          DoResize(32, 32, B, SmallB);
          SearchGroupsImageList.Add(SmallB, nil);
        finally
          F(JPEG);
        end;
      finally
        F(B);
      end;
      with ComboBoxSearchGroups.ItemsEx.Add do
      begin
        Caption := Groups[I].GroupName;
        ImageIndex := I + 1;
        Data := nil;
      end;
    end;

    FreeGroups(Groups);
  finally
    F(SmallB);
  end;
end;

procedure TSearchForm.ComboBoxSearchGroupsSelect(Sender: TObject);
begin
  if WlStartStop.Text <> L('Stop') then
    DoSearchNow(nil);
end;

procedure TSearchForm.ComboBoxSearchGroupsDropDown(Sender: TObject);
begin
  if not GroupsLoaded then
    LoadGroupsList(True);
end;

procedure TSearchForm.SearchEditDropDown(Sender: TObject);
begin
  if not SearchEdit.ShowDropDownMenu then
  begin
    RebuildQueryList;
    SearchEdit.ShowDropDownMenu := True;
  end;
end;

procedure TSearchForm.SearchEditIconClick(Sender: TObject);
begin
  DoSearchNow(Self);
end;

procedure TSearchForm.RebuildQueryList;
var
  I : Integer;
  CurrentText: string;
  EditIndex: Integer;
begin
  CurrentText := SearchEdit.Text;
  EditIndex := SearchEdit.ShowEditIndex;
  SearchEdit.ItemsEx.Clear;

  for I := 0 to FSearchInfo.Count - 1 do
  begin
    with SearchEdit.ItemsEx.Add do
    begin
      Caption := FSearchInfo[I].Query;
      Data := FSearchInfo[I];
    end;
  end;
  SearchEdit.Text := CurrentText;
  SearchEdit.ShowEditIndex := EditIndex;
end;

procedure TSearchForm.AddNewSearchListEntry;
var
  DateRange : TDateRange;
const
  SearchTextCount = 10;
begin
  if SearchEdit.Text <> '' then
  begin
    DateRange := GetDateFilter;

    FSearchInfo.Add(Min(RtgQueryRating.Rating, RtgQueryRating.RatingRange),
                    Max(RtgQueryRating.Rating, RtgQueryRating.RatingRange),
                    DateRange.DateFrom,
                    DateRange.DateTo,
                    ComboBoxSearchGroups.Items[ComboBoxSearchGroups.ItemIndex],
                    SearchEdit.Text,
                    SortLink.Tag,
                    Decremect1.Checked);

    RebuildQueryList;
  end;
end;

procedure TSearchForm.FormResize(Sender: TObject);
var
  aTop, N, LastIndex : Integer;
begin
  LastIndex := ComboBoxSearchGroups.ItemIndex;
  aTop := ClientHeight - ComboBoxSearchGroups.Top - ComboBoxSearchGroups.Height - PnLeft.Top;
  N := Max(5, aTop div 32);
  if N <> ComboBoxSearchGroups.DropDownCount then
  begin
    ComboBoxSearchGroups.DropDownCount := N;
    ComboBoxSearchGroups.ItemIndex := LastIndex;
  end;
end;

procedure TSearchForm.ZoomIn;
begin
  ElvMain.BeginUpdate;
  try
    if FPictureSize < ListViewMaxThumbnailSize then
      FPictureSize := FPictureSize + 10;

    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;
    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(true);

    if IsSelectedVisible then
      ElvMain.Selection.First.MakeVisible(emvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TSearchForm.ZoomOut;
begin
  ElvMain.BeginUpdate;
  try
    if FPictureSize > ListViewMinThumbnailSize then
      FPictureSize:=FPictureSize - 10;

    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;
    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);
    if IsSelectedVisible then
      ElvMain.Selection.First.MakeVisible(emvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

{$REGION 'Tool bar'}

procedure TSearchForm.LoadToolBarIcons;
var
  UseSmallIcons : Boolean;
  Ico : HIcon;

  procedure AddIcon(Name : String);
  begin
    if UseSmallIcons then
      Name := Name+ '_SMALL';

    Ico := LoadIcon(HInstance, PWideChar(Name));
    ImageList_ReplaceIcon(ToolBarImageList.Handle, -1, Ico);
    DestroyIcon(Ico);
  end;

  procedure AddDisabledIcon(Name : String);
  var
    I : Integer;
  begin
    if UseSmallIcons then
      Name := Name + '_SMALL';
    Ico := LoadIcon(HInstance, PWideChar(Name));
    for I := 1 to 9 do
      ImageList_ReplaceIcon(DisabledToolBarImageList.Handle, -1, Ico);

    DestroyIcon(Ico);
  end;

begin
  UseSmallIcons := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
  TbLoad.Visible := True;

  if UseSmallIcons then
  begin
    ToolBarImageList.Width := 16;
    ToolBarImageList.Height := 16;
    DisabledToolBarImageList.Width := 16;
    DisabledToolBarImageList.Height := 16;
  end;

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

  TbSearch.ImageIndex:=0;
  TbSort.ImageIndex := 1;
  TbZoomOut.ImageIndex := 3;
  TbZoomIn.ImageIndex := 2;
  TbGroups.ImageIndex := 4;
  TbSave.ImageIndex := 5;
  TbLoad.ImageIndex := 6;
  TbExplorer.ImageIndex := 7;
  TbStopOperation.ImageIndex := 8;

  TbMain.Images := ToolBarImageList;
  TbMain.DisabledImages:= DisabledToolBarImageList;
end;

procedure TSearchForm.TbZoomOutClick(Sender: TObject);
begin
  ZoomOut;
end;

procedure TSearchForm.TbZoomInClick(Sender: TObject);
begin
  ZoomIn;
end;

procedure TSearchForm.TbExplorerClick(Sender: TObject);
var
  FileName : string;
begin
  if ElvMain.Selection.Count = 0 then
  begin
    NewExplorer;
  end else
  begin
    with ExplorerManager.NewExplorer(False) do
    begin
      FileName := GetSearchRecordFromItemData(ElvMain.Selection.First).FileName;
      DoProcessPath(FileName);
      SetOldPath(FileName);
      SetPath(ExtractFilePath(FileName));
      Show;
      SetFocus;
    end;
  end;
end;

{$ENDREGION}

procedure TSearchForm.ReRecreateGroupsList;
begin
  GroupsLoaded := False;
  LoadGroupsList;
end;

procedure TSearchForm.SortingClick(Sender: TObject);
var
  I, L, N : integer;
  aType : Byte;
  Data : TDBPopupMenuInfoRecord;
  SearchExtraInfo : TSearchDataExtension;
type
  SortList = array of TEasyItem;

  TSortItem = record                 {This defines the objects being sorted.}
    ID : Integer;
    ValueInt : Int64;
    ValueStr : string;
    ValueDouble : Double;
   end;

  TSortItems = array of TSortItem;  {This is an array of objects to be sorted.}

  aListItem = record
    Caption : string;
    Indent : Integer;
    Data : Pointer;
    ImageIndex : Integer;
   end;

  aListItems = array of aListItem;

var
  SIs : TSortItems;
  LI : aListItems;

  function L_Less_Than_R(L, R : TSortItem; aType : Byte) : Boolean;
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
      Result := AnsiCompareTextWithNum(L.ValueStr, R.ValueStr) < 0;
    end;
    if aType=2 then
    begin
      if L.ValueDouble = R.ValueDouble then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := L.ValueDouble < R.ValueDouble;
      Exit;
    end;
    if aType=3 then
    begin
      n := AnsiCompareText(ExtractFileExt(L.ValueStr), ExtractFileExt(R.ValueStr));
      if n = 0 then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := n < 0;
      Exit;
    end;
    if aType = 4 then
      Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0;
  end;

  procedure Swap(var X : TSortItems; I, J : Integer);
  var
    temp : TSortItem;
  begin
    temp := X[I];
    X[I] := X[J];
    X[J] := temp;
  end;

  procedure Qsort(var X : TSortItems; Left, Right : Integer; aType : Byte);
  label
     Again;
  var
     Pivot : TSortItem;
     P,Q : integer;
     M : integer;
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
           if Q = M then break;
           Dec(Q);
         end;
         if P > Q then
           goto Again;
         Swap(X, P, Q);
         Inc(P);
         Dec(Q);
      end;

      Again:
      if Left < Q  then Qsort(X, Left, Q, aType);
      if P < Right then Qsort(X, P, Right, aType);
   end;

  procedure QuickSort(var X:TSortItems; N : integer; aType : Byte; Increment : Boolean);
  var
    I : integer;
  begin
    Qsort(X, 0, N-1, aType);
    if not Increment then
     for I := 0 to Length(X) div 2 do
       Swap(X, I, Length(X) - 1 - I);
  end;

begin
  if Sender = nil then
    Exit;
  if not (Sender is TMenuItem) then
    Exit;
  //NOT RIGHT! SORTING BY FOLDERS-IMAGES-OTHERS
  if ((Sender as TMenuItem).Tag = -1) then exit;
  if ElvMain.Items.Count < 2 then
    Exit;

  ElvMain.Groups.BeginUpdate(false);
  try
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
        Data := GetSearchRecordFromItemData(ElvMain.Items[I]);
        case SortMethod of
          SM_ID: begin
              SIs[i].ValueInt := Data.ID;
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
             end;
          SM_TITLE: begin
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
             end;
          SM_DATE_TIME: begin
              SIs[i].ValueDouble := DateOf(Data.Date) + Data.Time;
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
             end;
          SM_RATING: begin
              SIs[i].ValueInt := Data.Rating;
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
             end;
          SM_FILE_SIZE: begin
              SIs[i].ValueInt := Data.FileSize;
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
             end;
          SM_SIZE: begin
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
              SIs[i].ValueInt := Data.Width * Data.Height;
             end;
          SM_COMPARING: begin
              SIs[i].ValueStr := ExtractFileName(Data.FileName);
              SearchExtraInfo := TSearchDataExtension(Data.Data);
              SIs[i].ValueInt := SearchExtraInfo.CompareResult.ByPixels * 10 + SearchExtraInfo.CompareResult.ByGistogramm;
             end;
        end;
        SIs[i].ID := I;
      end;

      aType := 0;
      case SortMethod of
        SM_TITLE: aType := 4;
        SM_DATE_TIME: aType := 2;
        SM_ID, SM_RATING, SM_FILE_SIZE, SM_SIZE, SM_COMPARING: aType := 1;
      end;

      QuickSort(SIs, L, aType, SortDecrement);

      ElvMain.BeginUpdate;
      try
        ElvMain.Items.Clear;

        EmptyFillListInfo;

        for I := 0 to L - 1 do
        begin
          AddItemInListViewByGroups(TDBPopupMenuInfoRecord(TDataObject(LI[SIs[i].ID].Data).Data), False);
          ElvMain.Items[i].ImageIndex := LI[SIs[i].ID].ImageIndex;
          ElvMain.Items[i].Data := LI[SIs[i].ID].Data;
        end;
      except
        on e : Exception do
          EventLog(':TSearchForm::SortingClick() throw exception: ' + e.Message);
      end;
    finally
      ElvMain.EndUpdate;
    end;
  finally
    ElvMain.Groups.EndUpdate(False);
  end;
  ElvMain.Realign;
end;

procedure TSearchForm.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
  Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
  BigImagesSizeForm.Execute(self,fPictureSize, BigSizeCallBack);
end;

procedure TSearchForm.DoSetSearchByComparing;
begin
  FSearchByCompating := True;
end;

procedure TSearchForm.SortingPopupMenuPopup(Sender: TObject);
var
  I : Integer;
begin
  SortbyCompare1.Visible := FSearchByCompating;

  for I := 0 to SortingPopupMenu.Items.Count - 1 do
    SortingPopupMenu.Items[i].Enabled := not FListUpdating;
end;

procedure TSearchForm.SortbyCompare1Click(Sender: TObject);
begin
  SortbyCompare1.Checked := True;
  SortLink.Tag := 6;
  SortLink.Text := L('Sort by compare result');
  SortingClick(Sender);
end;

procedure TSearchForm.LoadQueryList;
var
  I, RatingFrom, RatingTo, SortMethod : integer;
  SortDesc : Boolean;
  DateFrom, DateTo : TDateTime;
  GroupName, Query : string;
  QueryCount : Integer;
  RegQueryPath : string;
  FNow : TDateTime;
begin

  QueryCount := Settings.ReadInteger(RegQueryRootPath, 'Count', 0);
  FNow := Now;
  for I := QueryCount - 1 downto 0 do
  begin
    RegQueryPath := RegQueryRootPath + IntToStr(I);
    RatingFrom := Settings.ReadInteger(RegQueryPath, 'RatingFrom', 0);
    RatingTo := Settings.ReadInteger(RegQueryPath, 'RatingTo', 5);
    DateFrom := Settings.ReadDateTime(RegQueryPath, 'DateFrom', FNow - 365);
    DateTo := Settings.ReadDateTime(RegQueryPath, 'DateTo', FNow);
    GroupName := Settings.ReadString(RegQueryPath, 'GroupName');
    Query := Settings.ReadString(RegQueryPath, 'Query');
    SortMethod := Settings.ReadInteger(RegQueryPath, 'SortMethod', SM_DATE_TIME);
    SortDesc := Settings.ReadBool(RegQueryPath, 'SortDesc', True);

    if Query <> '' then
      FSearchInfo.Add(RatingFrom, RatingTo, DateFrom, DateTo, GroupName, Query, SortMethod, SortDesc);
  end;

  if FSearchInfo.Count = 0 then
    FSearchInfo.Add(0, 5, FNow - 365, FNow, '', '', SM_DATE_TIME, True);

  if FSearchInfo[0].SortDecrement then
    Decremect1Click(Self)
  else
    Increment1Click(Self);

  case FSearchInfo[0].SortMethod of
    SM_ID        : SortbyID1Click(nil);
    SM_TITLE     : SortbyName1Click(nil);
    SM_DATE_TIME : SortbyDate1Click(nil);
    SM_RATING    : SortbyRating1Click(nil);
    SM_FILE_SIZE : SortbyFileSize1Click(nil);
    SM_SIZE      : SortbySize1Click(nil);
    else
     SortbyDate1Click(nil);
  end;

  RtgQueryRating.Rating := FSearchInfo[0].RatingFrom;
  RtgQueryRating.RatingRange := FSearchInfo[0].RatingTo;
  SearchEdit.Text := Settings.ReadString(RegQueryRootPath, 'Text', '');
end;

procedure TSearchForm.SaveQueryList;
var
  I : Integer;
  RegQueryPath : string;
const
  MaxQueriesToSave = 20;
begin
  Settings.WriteInteger(RegQueryRootPath, 'Count', FSearchInfo.Count);
  for I := 0 to Min(MaxQueriesToSave, FSearchInfo.Count) - 1 do
  begin
    RegQueryPath := RegQueryRootPath + IntToStr(I);
    Settings.WriteInteger(RegQueryPath, 'RatingFrom', FSearchInfo[I].RatingFrom);
    Settings.WriteInteger(RegQueryPath, 'RatingTo', FSearchInfo[I].RatingTo);
    Settings.WriteDateTime(RegQueryPath, 'DateFrom', FSearchInfo[I].DateFrom);
    Settings.WriteDateTime(RegQueryPath, 'DateTo', FSearchInfo[I].DateTo);
    Settings.WriteString(RegQueryPath, 'GroupName', FSearchInfo[I].GroupName);
    Settings.WriteString(RegQueryPath, 'Query', FSearchInfo[I].Query);
    Settings.WriteInteger(RegQueryPath, 'SortMethod', FSearchInfo[I].SortMethod);
    Settings.WriteBool(RegQueryPath, 'SortDesc', FSearchInfo[I].SortDecrement);
  end;
  Settings.WriteString(RegQueryRootPath, 'Text', SearchEdit.Text);
end;

function TSearchForm.TreeView: TShellTreeView;
begin
  if FShellTreeView = nil then
  begin
    FShellTreeView := TShellTreeView.Create(Self);
    FShellTreeView.Parent := ExplorerPanel;
    FShellTreeView.Align := alClient;
    FShellTreeView.AutoRefresh := False;
    FShellTreeView.PopupMenu := PopupMenu8;
    FShellTreeView.RightClickSelect := True;
    FShellTreeView.ShowRoot := False;
    FShellTreeView.OnChange := ShellTreeView1Change;
    FShellTreeView.UseShellImages := False;
    FShellTreeView.ObjectTypes := [];
  end;

  Result := FShellTreeView;
end;

procedure TSearchForm.CreateBackground;
var
  BackgroundImage : TPNGImage;
  Bitmap, SearchBackgroundBMP : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := 150;
    Bitmap.Height := 150;
    Bitmap.Canvas.Brush.Color := clWindow;
    Bitmap.Canvas.Pen.Color := clWindow;
    Bitmap.Canvas.Rectangle(0,0,150,150);
    BackgroundImage := GetSearchBackground;
    try
      SearchBackgroundBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(BackgroundImage, SearchBackgroundBMP, clWindow);
        Bitmap.Canvas.Draw(0, 0, SearchBackgroundBMP);
      finally
        F(SearchBackgroundBMP);
      end;
    finally
      F(BackgroundImage);
    end;
    ElvMain.BackGround.Image := Bitmap;
  finally
    F(Bitmap);
  end;
end;

procedure TSearchForm.LoadDateRange;
var
  DS: TDataSet;
  DateRangeBackgroundImage: TPNGImage;
  DateRangeBackgroundImageBMP: TBitmap;
  BackgroundImage: TBitmap;
begin
  if not elvDateRange.BackGround.Image.Empty then
    Exit;

  elvDateRange.BackGround.Enabled := True;
  elvDateRange.BackGround.Tile := False;
  elvDateRange.BackGround.AlphaBlend := True;
  elvDateRange.BackGround.OffsetTrack := True;
  elvDateRange.BackGround.BlendAlpha := 220;

  BackgroundImage := TBitmap.Create;
  try
    BackgroundImage.PixelFormat := pf24bit;
    BackgroundImage.Width := 100;
    BackgroundImage.Height := 100;
    BackgroundImage.Canvas.Brush.Color := clWindow;
    BackgroundImage.Canvas.Pen.Color := clWindow;
    BackgroundImage.Canvas.Rectangle(0, 0, 100, 100);
    elvDateRange.BackGround.Image := BackgroundImage;
  finally
    F(BackgroundImage);
  end;

  DateRangeBackgroundImage := GetDateRangeImage;
  try
    DateRangeBackgroundImageBMP := TBitmap.Create;
    try
      LoadPNGImage32bit(DateRangeBackgroundImage, DateRangeBackgroundImageBMP, clWindow);
      elvDateRange.BackGround.Image.Canvas.Draw(0, 0, DateRangeBackgroundImageBMP);
    finally
      DateRangeBackgroundImageBMP.Free;
     end;
  finally
    DateRangeBackgroundImage.Free;
  end;
  elvDateRange.Refresh;

  DS := GetQuery(True);

  ForwardOnlyQuery(DS);
  TADOQuery(DS).ExecuteOptions := [eoAsyncFetch, eoAsyncFetchNonBlocking];
  SetSQL(DS, 'SELECT DISTINCT DateToAdd FROM $DB$ WHERE IsDate = True ORDER BY DateToAdd DESC');
  TADOQuery(DS).OnFetchProgress := FetchProgress;

  TOpenQueryThread.Create(Self, DS, DBRangeOpened);
end;

procedure TSearchForm.FetchProgress(DataSet: TCustomADODataSet; Progress,
  MaxProgress: Integer; var EventStatus: TEventStatus);
begin
  Application.ProcessMessages;
end;

procedure TSearchForm.elvDateRangeItemClick(Sender: TCustomEasyListview;
  Item: TEasyItem; KeyStates: TCommonKeyStates;
  HitInfo: TEasyItemHitTestInfoSet);
var
  I : Integer;
begin
  if not Item.Selected or ((elvDateRange.Selection.Count>1) and CtrlKeyDown) then
  begin
    if elvDateRange.Selection.First<>nil then
    begin
      for I := 0 to elvDateRange.Items.Count - 1 do
        if elvDateRange.Items[I].Selected then
          elvDateRange.Items[I].Selected := False;
    end
  end;
end;

function TSearchForm.DateRangeItemAtPos(X, Y : Integer): TEasyItem;
var
  R : TRect;
  I : integer;
begin
  Result := nil;
  R :=  elvDateRange.Scrollbars.ViewableViewportRect;
  for I := 0 to elvDateRange.Groups.Count - 1 do
  begin
    Result := elvDateRange.Groups[0].ItemByPoint(Point(R.Left + X, R.Top + Y));
    if Result <> nil then
      Exit;
  end;
end;

procedure TSearchForm.elvDateRangeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item : TEasyItem;
  I : integer;
begin
  if CtrlKeyDown then
  begin
    Item:=DateRangeItemAtPos(X, Y);
    if not Item.Selected or ((elvDateRange.Selection.Count > 1) and CtrlKeyDown) then
    begin
      if elvDateRange.Selection.First<>nil then
      begin
        for I := 0 to elvDateRange.Items.Count - 1 do
          if elvDateRange.Items[I].Selected then
            elvDateRange.Items[I].Selected := False;
      end;
    end;
  end;
end;

procedure TSearchForm.DBRangeOpened(Sender : TObject; DS : TDataSet);
var
  Date : TDateTime;
  CurrentYear : Integer;
  CurrentMonth : Integer;
  DA: TDBAdapter;
begin
  DA := TDBAdapter.Create(DS);
  try
    dblDate.Hide;

    Application.ProcessMessages;
    lsDate.Color := elvDateRange.Color;
    lsDate.Active := True;
    lsDate.Visible := True;
    CurrentYear := 0;
    CurrentMonth := 0;
    elvDateRange.Groups.Clear;
    elvDateRange.Header.Columns.Clear;
    elvDateRange.Header.Columns.Add.Width := 150;

    DS.First;
    while not DS.EOF do
    begin
      Application.ProcessMessages;
      Date := DA.Date;
      if YearOf(Date) <> CurrentYear then
      begin
        CurrentYear := YearOf(Date);
        with elvDateRange.Groups.Add do
        begin
          Caption := FormatDateTime('yyyy',Date);
          Visible := True;
          Tag := CurrentYear;
        end;
      end;

      Date := DA.Date;
      if MonthOf(Date) <> CurrentMonth then
      begin
        CurrentMonth := MonthOf(Date);
        with elvDateRange.Items.Add do
        begin
          Caption := FormatDateTime('mmmm',Date);
          Tag := CurrentMonth;
        end;
      end;
      DS.Next;
    end;
  finally
    F(DA);
    FreeDS(DS);
  end;
  lsDate.Active := False;
  lsDate.Visible := False;
end;

procedure TSearchForm.elvDateRangeResize(Sender: TObject);
begin
  elvDateRange.BackGround.OffsetX := elvDateRange.Width - elvDateRange.BackGround.Image.Width;
  elvDateRange.BackGround.OffsetY := elvDateRange.Height - elvDateRange.BackGround.Image.Height;
  dblDate.Left := elvDateRange.Left + (elvDateRange.Left + elvDateRange.Width) div 2 - dblDate.Width div 2;
  dblDate.Top := elvDateRange.Top + (elvDateRange.Top + elvDateRange.Height) div 2 - dblDate.Height div 2;
end;

function TSearchForm.GetDateFilter: TDateRange;
var
  I, J : Integer;
begin
  Result.DateFrom := 0;
  Result.DateTo := 0;
  if elvDateRange.Selection.Count > 1 then
  begin
    for I := 0 to elvDateRange.Groups.Count - 1 do
      for J := 0 to elvDateRange.Groups[I].ItemCount - 1 do
      begin
        if elvDateRange.Groups[I].Items[j].Selected then
        begin
          if Result.DateFrom = 0 then
            if elvDateRange.Groups[I].Item[J].Tag < 12 then
              Result.DateFrom := EncodeDateTime(elvDateRange.Groups[I].Tag, elvDateRange.Groups[i].Item[j].Tag + 1,1,0,0,0,0)
            else
              Result.DateFrom := EncodeDateTime(elvDateRange.Groups[I].Tag + 1, 1, 1, 0, 0, 0, 0);

        end;
        if not elvDateRange.Groups[I].Items[J].Selected then
          if Result.DateFrom <> 0 then
            if Result.DateTo = 0 then
            begin
              if elvDateRange.Groups[I].Item[J].Tag < 12 then
                Result.DateTo := EncodeDateTime(elvDateRange.Groups[I].Tag, elvDateRange.Groups[i].Item[j].Tag + 1, 1, 0, 0, 0, 0)
              else
                Result.DateTo := EncodeDateTime(elvDateRange.Groups[I].Tag + 1, 1, 1, 0, 0, 0, 0);
            end;
      end;
  end else if elvDateRange.Selection.Count = 1 then
  begin
    Result.DateFrom := EncodeDateTime(elvDateRange.Selection.First.OwnerGroup.Tag, elvDateRange.Selection.First.Tag, 1, 0, 0, 0, 0);
    if elvDateRange.Selection.First.Tag < 12 then
      Result.DateTo := EncodeDateTime(elvDateRange.Selection.First.OwnerGroup.Tag, elvDateRange.Selection.First.Tag + 1, 1, 0, 0 ,0, 0)
    else
      Result.DateTo := EncodeDateTime(elvDateRange.Selection.First.OwnerGroup.Tag + 1, 1, 1, 0, 0, 0, 0);
  end else if elvDateRange.Selection.Count = 0 then
  begin
    Result.DateFrom := EncodeDateTime(1990, 1, 1, 0, 0, 0, 0);
    Result.DateTo := Trunc(Now);
  end;
end;

procedure TSearchForm.AddItemInListViewByGroups(DataRecord : TDBPopupMenuInfoRecord; ReplaceBitmap : Boolean);
var
  new: TEasyItem;
  i, i10 : integer;
  DataObject : TDataObject;
  SearchExtraInfo : TSearchDataExtension;
begin
  if (SortMethod = 0) or not ShowGroups then
  begin
    if ElvMain.Groups.Count = 0 then
      with ElvMain.Groups.Add do
      begin
        Visible := True;
        Caption := L('Records found') + ':';
      end;
  end;

  if ShowGroups then
  begin

  if SortMethod = SM_FILE_SIZE then
  begin
    if not SortDecrement then
    begin
      if (FFillListInfo.LastSize = 0) and (DataRecord.FileSize < 100 * 1024) then
      begin
        FFillListInfo.LastSize := Max(1, DataRecord.FileSize);
        with ElvMain.Groups.Add do
        begin
          Caption := FLessThan + ' ' + SizeInText(1024 * 100);
          Visible := True;
        end;
      end else
      begin
        if DataRecord.FileSize < 1000 * 1024 then
        begin
          i10 := Trunc(DataRecord.FileSize / (100 * 1024)) * 10 * 1024;
          I := i10*10;
          if (FFillListInfo.LastSize < i + i10) and (DataRecord.FileSize > 100 * 1024) then
          with ElvMain.Groups.Add do
          begin
            FFillListInfo.LastSize := i + i10;
            Caption := FMoreThan + ' ' + SizeInText(I);
            Visible := True;
          end;
        end else
        begin
          if DataRecord.FileSize < 1024*1024*10 then
          begin
            i10 := Trunc(DataRecord.FileSize / (1024*1024))*100*1024;
            I:= Round(i10 * 10 / (1024 * 1024)) * 1024 * 1024;
            if I = 0 then
              with ElvMain.Groups.Add do
              begin
                I := 1024 * 1024;
                FFillListInfo.LastSize := I + i10;
                Caption := FMoreThan + ' ' + SizeInText(I);
                Visible := True;
              end;
            if (FFillListInfo.LastSize < I + i10) and (DataRecord.FileSize > 1024 * 1024) then
            with ElvMain.Groups.Add do
            begin
              FFillListInfo.LastSize := I + i10;
              Caption := FMoreThan + ' ' + SizeInText(I);
              Visible := True;
            end;
          end else
          begin
            if DataRecord.FileSize < 1024 * 1024 * 100 then
            begin
              i10 := Trunc(DataRecord.FileSize / (1024 * 1024 * 10)) * 1000 * 1024;
              I := Round(i10 * 10 / (1024 * 1024 * 10)) * 1024 * 1024 * 10;
              if (I = 0) then
              with ElvMain.Groups.Add do
              begin
                I := 1024 * 1024 * 10;
                FFillListInfo.LastSize := I + i10;
                Caption := FMoreThan + ' ' + SizeInText(I);
                Visible := True;
              end;
              if (FFillListInfo.LastSize < i + i10) and (DataRecord.FileSize > 1024 * 1024 * 10) then
                with ElvMain.Groups.Add do
                begin
                 FFillListInfo.LastSize := I + i10;
                 Caption := FMoreThan + ' ' + SizeInText(I);
                 Visible := True;
                end;
            end else
            begin
              with ElvMain.Groups.Add do
              begin
                FFillListInfo.LastSize := 1024 * 1024 * 100;
                Caption := FMoreThan + ' ' + SizeInText(1024 * 1024 * 100);
                Visible := True;
              end;
            end;
          end;
        end;
      end;
    end else
    begin
      if DataRecord.FileSize < 901*1024 then
      begin
        i10:=Trunc(DataRecord.FileSize / (1024 * 100)) * 1024 * 100;
        if (Abs(FFillListInfo.LastSize - DataRecord.FileSize)>1024*100) and (DataRecord.FileSize > 0) or (FFillListInfo.LastSize = 0) then
          with ElvMain.Groups.Add do
          begin
            FFillListInfo.LastSize := i10 + 1024 * 100;
            Caption := FLessThan + ' ' + SizeInText(i10 + 1024 * 100);
            Visible := True;
          end;
       end else
       begin
         if DataRecord.FileSize < 1024 * 1024 * 10 then
         begin
           i10 := Trunc(DataRecord.FileSize / (1024 * 1024)) * 1024 * 1024;
           if (Abs(FFillListInfo.LastSize - DataRecord.FileSize) > 1024 * 1024) and (DataRecord.FileSize > 1024 * 1024) or (FFillListInfo.LastSize = 0) then
             with ElvMain.Groups.Add do
             begin
              FFillListInfo.LastSize:=i10 + 1024 * 1024;
              Caption := FLessThan + ' ' + SizeInText(i10 + 1024 * 1024);
              Visible := True;
             end;
          end else
        begin
         if DataRecord.FileSize < 1024 * 1024 * 100 then
         begin
           i10 := Trunc(DataRecord.FileSize / (1024 * 1024 * 10)) * 1024 * 1024 * 10;
           if (Abs(FFillListInfo.LastSize - DataRecord.FileSize) > 1024 * 1024 * 10) and (DataRecord.FileSize > 1024 * 1024 * 10) or (FFillListInfo.LastSize = 0)  then
             with ElvMain.Groups.Add do
             begin
               FFillListInfo.LastSize := i10 + 1024 * 1024 * 10;
               Caption := FLessThan + ' ' + SizeInText(i10 + 1024 * 1024 * 10);
               Visible := True;
             end;
           end else
           begin
             with ElvMain.Groups.Add do
             begin
               FFillListInfo.LastSize := 1024 * 1024 * 100;
               Caption := FMoreThan + ' ' + SizeInText(1024 * 1024 * 100);
               Visible := True;
             end;
           end;
         end;
       end;
     end;
   end;

    if SortMethod = SM_TITLE then
    if ExtractFileName(DataRecord.FileName)<>'' then
    begin
     if FFillListInfo.LastChar <> ExtractFilename(DataRecord.FileName)[1] then
      begin
        FFillListInfo.LastChar := ExtractFilename(DataRecord.FileName)[1];
        with ElvMain.Groups.Add do
        begin
         Caption := FFillListInfo.LastChar;
         Visible := True;
        end;
      end;
    end;

    if SortMethod = SM_RATING then
    if FFillListInfo.LastRating <> DataRecord.Rating then
    begin
      FFillListInfo.LastRating := DataRecord.Rating;
      with ElvMain.Groups.Add do
      begin
        if DataRecord.Rating = 0 then
          Caption := L('No rating') + ':'
        else
          Caption := L('Rating') + ': ' + IntToStr(DataRecord.Rating);

        Visible := True;
      end;
    end;

    if SortMethod = SM_DATE_TIME then
    if (YearOf(DataRecord.Date) <> FFillListInfo.LastYear) or (MonthOf(DataRecord.Date) <> FFillListInfo.LastMonth) then
    begin
      FFillListInfo.LastYear := YearOf(DataRecord.Date);
      FFillListInfo.LastMonth := MonthOf(DataRecord.Date);
      with ElvMain.Groups.Add do
      begin
        Caption := FormatDateTime('yyyy, mmmm', DataRecord.Date);
        Visible := True;
      end;
    end;
  end;

  DataObject := TDataObject.Create;
  DataObject.Include := DataRecord.Include;
  DataObject.Data := DataRecord;
  New := ElvMain.Items.Add(DataObject);
  if not DataObject.Include then
    New.BorderColor := GetListItemBorderColor(DataObject);
  New.Tag := DataRecord.ID;
  if ReplaceBitmap then
  begin
    SearchExtraInfo := TSearchDataExtension(DataRecord.Data);
    if SearchExtraInfo.Bitmap <> nil then
      New.ImageIndex := FBitmapImageList.AddBitmap(SearchExtraInfo.Bitmap)
    else
      New.ImageIndex := FBitmapImageList.AddIcon(SearchExtraInfo.Icon, True);

    SearchExtraInfo.Bitmap := nil;
    SearchExtraInfo.Icon := nil;
  end;
  New.Caption := ExtractFileName(DataRecord.FileName);
end;

procedure TSearchForm.LoadDataPacket(Packet: TDBPopupMenuInfo);
var
  I : Integer;
begin
  ElvMain.BeginUpdate;
  try
    for I := 0 to Packet.Count - 1 do
      AddItemInListViewByGroups(Packet.Extract(0), True);
  finally
    ElvMain.EndUpdate;
  end;
end;

{$REGION 'Properties'}

function TSearchForm.GetSearchText: string;
begin
  Result := SearchEdit.Text;
end;

procedure TSearchForm.SetSearchText(Value: string);
begin
  SearchEdit.Text := Value;
end;

function TSearchForm.GetSortMethod: Integer;
begin
  Result := SortLink.Tag;
end;

function TSearchForm.GetShowGroups: Boolean;
begin
  Result := Settings.Readbool('Options', 'UseGroupsInSearch', True);
end;

function TSearchForm.GetSortDecrement: Boolean;
begin
  Result := Decremect1.Checked;
end;

{$ENDREGION}

procedure TSearchForm.EmptyFillListInfo;
begin
  FFillListInfo.LastYear := 0;
  FFillListInfo.LastMonth := 0;
  FFillListInfo.LastRating := -1;
  FFillListInfo.LastSize := 0;
  FFillListInfo.LastChar := #0;
end;

procedure TSearchForm.dblDateDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := clWindow;
  Buffer.Canvas.Brush.Color := clWindow;
  Buffer.Canvas.Rectangle(0, 0, Buffer.Width, Buffer.Height);
end;

procedure TSearchForm.StopLoadingList;
begin
  NewFormState;
  TbStopOperation.Enabled := False;
  NotifySearchingEnd;
end;

procedure TSearchForm.SearchEditChange(Sender: TObject);
begin
  if not FCanBackgroundSearch then
    Exit;

  TmrSearchResultsCount.Enabled := False;
  TmrSearchResultsCount.Enabled := True;
end;

procedure TSearchForm.TmrSearchResultsCountTimer(Sender: TObject);
begin
  TmrSearchResultsCount.Enabled := False;
  StartSearchThread(True)
end;

procedure TSearchForm.elvDateRangeItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
  SearchEditChange(Sender);
end;

function TSearchForm.GetFormID: string;
begin
  Result := 'Search';
end;

{$REGION 'Search Indicator'}

procedure TSearchForm.NitifyEstimateStart;
begin
  if FIsEstimatingActive <> True then
  begin
    FIsEstimatingActive := True;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.NitifyEstimateEnd;
begin
  if FIsEstimatingActive <> False then
  begin
    FIsEstimatingActive := False;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.NotifySearchingStart;
begin
  if FIsSearchingActive <> True then
  begin
    FIsSearchingActive := True;
    FProgressValue := -1;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.NotifySearchingEnd;
begin
  if FIsSearchingActive <> False then
  begin
    FIsSearchingActive := False;
    FIsEstimatingActive := False;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.UpdateEstimateState(EstimateCount: Integer);
begin
  if FEstimateCount <> EstimateCount then
  begin
    FEstimateCount := EstimateCount;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.UpdateProgressState(ProgressValue: Extended);
begin
  if FProgressValue <> ProgressValue then
  begin
    FProgressValue := ProgressValue;
    UpdateSearchState;
  end;
end;

procedure TSearchForm.UpdateSearchState;
var
  Counter : string;
begin
  if FIsSearchingActive then
  begin
    if FProgressValue < 0 then
    begin
      WlStartStop.Text := L('Stop');
      LsData.BringToFront;
      LsData.Top := ElvMain.Top + 3;
      LsData.Left := ElvMain.Left + ElvMain.Width - 16 - 2 - 3 - GetSystemMetrics(SM_CXVSCROLL);
      LsData.Color := ElvMain.Color;
      LsData.Show;
      LsSearchResults.Left := WlStartStop.Left + WlStartStop.Width + 5;
      LsSearchResults.Color := SearchPanelA.Color;
      LsSearchResults.Show;
      UpdateVistaProgressState(TBPF_INDETERMINATE);
    end else
    begin
      if FW7TaskBar <> nil then
      begin
        UpdateVistaProgressState(TBPF_NORMAL);
        FW7TaskBar.SetProgressValue(Handle, Max(0, Min(100, Round(FProgressValue))), 100);
      end;
      LsSearchResults.Hide;
      WlStartStop.Text := Format(L('Stop (%s%%)'), [FormatFloat('##0.0', FProgressValue)]);
      LsData.BringToFront;
      LsData.Top := ElvMain.Top + 3;
      LsData.Left := ElvMain.Left + ElvMain.Width - 16 - 2 - 3 - GetSystemMetrics(SM_CXVSCROLL);
      LsData.Color := ElvMain.Color;
      LsData.Show;
    end;
  end else if FIsEstimatingActive then
  begin
    UpdateVistaProgressState(TBPF_NOPROGRESS);
    WlStartStop.Text := L('Search');
    LsSearchResults.Left := WlStartStop.Left + WlStartStop.Width + 5;
    LsSearchResults.Color := SearchPanelA.Color;
    LsSearchResults.Show;
  end else
  begin
    UpdateVistaProgressState(TBPF_NOPROGRESS);
    LsSearchResults.Hide;
    WlStartStop.Text := L('Search');
    LsData.Hide;
    if FEstimateCount > 1000 then
      Counter := '1000+'
    else if FEstimateCount > -1 then
      Counter := IntToStr(FEstimateCount)
    else
      Counter := '';

    if Counter <> '' then
      WlStartStop.Text := Format(L('Search (%s results)'), [Counter])
    else
      WlStartStop.Text := (L('Search'));
  end;
end;

procedure TSearchForm.UpdateVistaProgressState(State: TBPF);
begin
  if FW7TaskBar <> nil then
  begin
    if FLastProgressState <> State then
    begin
      //to reset state to 'NORMAL'
      FW7TaskBar.SetProgressValue(Handle, 1, 1);
      FW7TaskBar.SetProgressState(Handle, State);
      FLastProgressState := State;
    end;
  end;
end;

{$ENDREGION}

{$REGION 'CUSTOM FORM overrides'}

procedure TSearchForm.StartSearch(Text: string);
begin
  SearchEdit.Text := Text;
  WlStartStop.OnClick(Self);
  Show;
end;

procedure TSearchForm.StartSearch;
begin
  DoSearchNow(Self);
end;

procedure TSearchForm.StartSearchDirectory(Directory: string; FileID: Integer);
begin
  if FileID <> 0 then
    SearchEdit.Text := ':Folder(' + IntToStr(FileID) + '):'
  else
    SearchEdit.Text := ':Folder(' + Text + '):';

  SetPath(Directory);
  DoSearchNow(Self);
  Show;
  SetFocus;
end;

procedure TSearchForm.StartSearchDirectory(Directory: string);
begin
  StartSearchDirectory(Directory, 0);
end;

procedure TSearchForm.StartSearchSimilar(FileName: string);
begin
  SearchEdit.Text := ':ScanImageW(' + FileName + ':1):';
  SetPath(ExtractFilePath(FileName));
  DoSearchNow(Self);
  Show;
  SetFocus;
end;

{$ENDREGION}

end.
