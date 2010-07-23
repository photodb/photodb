unit Searching;

interface

uses
  UnitGroupsWork, ThreadManeger, DBCMenu, CmpUnit, FileCtrl, Dolphin_DB,
  ShellApi, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Registry, Dialogs, DB, Grids, DBGrids, Menus, ExtCtrls, StdCtrls,
  ImgList, ComCtrls, ActiveX, ShlObj, DBCtrls, JPEG, DmProgress, ClipBrd,
  SaveWindowPos, ExtDlgs , ToolWin, UnitDBKernel, Rating, Math, CommonDBSupport,
  AppEvnts, TwButton, ShellCtrls, UnitBitmapImageList, GraphicCrypt,
  ShellContextMenu, DropSource, DropTarget, DateUtils, acDlgSelect,
  ProgressActionUnit, UnitSQLOptimizing, uScript, UnitScripts, DBScriptFunctions,
  Exif, EasyListview, WebLink, MPCommonUtilities, GraphicsCool,
  UnitSearchBigImagesLoaderThread, DragDropFile,
  DragDrop, UnitPropeccedFilesSupport, uVistaFuncs, ComboBoxExDB,
  UnitDBDeclare, UnitDBFileDialogs, UnitDBCommon, UnitDBCommonGraphics,
  UnitCDMappingSupport, uThreadForm, uLogger, uConstants, uTime, CommCtrl,
  uFastload, uListViewUtils, uDBDrawing, GraphicEx, uResources,
  MPCommonObjects, ADODB;

type
  TDateRange = record
    DateFrom : TDateTime;
    DateTo : TDateTime;
  end;

  TGroupInfo = class(TObject)
  public
    Name : string;
  end;

  
  TSearchInfo = class(TObject)
  private
    FList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TSearchQuery;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: Integer]: TSearchQuery read GetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

type
  TSearchForm = class(TThreadForm)
    Panel1: TPanel;
    Image1: TImage;
    Splitter1: TSplitter;
    SaveWindowPos1: TSaveWindowPos;
    HintTimer: TTimer;
    ApplicationEvents1: TApplicationEvents;
    SearchPanelA: TPanel;
    Label1: TLabel;
    RatingQuery: TRating;
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
    PopupMenu1: TPopupMenu;
    DoSearchNow1: TMenuItem;
    Panels1: TMenuItem;
    Properties1: TMenuItem;
    Explorer2: TMenuItem;
    DateTimePicker1: TDateTimePicker;
    BackGroundSearchPanel: TPanel;
    IsDatePanel: TPanel;
    PopupMenu3: TPopupMenu;
    Datenotexists1: TMenuItem;
    PanelValueIsDateSets: TPanel;
    ImageSearchWait: TImage;
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
    PbProgress: TDmProgress;
    Label7: TLabel;
    Button1: TButton;
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
    DestroyTimer: TTimer;
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
    TbStopOperation: TToolButton;
    ToolButton15: TToolButton;
    DisabledToolBarImageList: TImageList;
    ComboBoxSelGroups: TComboBoxExDB;
    PopupMenuZoomDropDown: TPopupMenu;
    SortbyCompare1: TMenuItem;
    elvDateRange: TEasyListview;
    procedure DoSearchNow(Sender: TObject);
    procedure Edit1_KeyPress(Sender: TObject; var Key: Char);
    procedure Additem_(sender: TObject; Name_ : String; tag : integer );
    procedure FormCreate(Sender: TObject);
    procedure ListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ListViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListViewDblClick(Sender: TObject);

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

    function GetAllFiles:  TStrings;
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ManageDB1Click(Sender: TObject);
    procedure RefreshInfoByID(ID : integer);
    procedure Memo1Change(Sender: TObject);
    procedure ErrorQSL(sql : string);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure ListViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
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
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);

    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Explorer1Click(Sender: TObject);
    procedure ListViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListViewExit(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Explorer2Click(Sender: TObject);
    procedure SetPath(Value : String);
    procedure SearchPanelAContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Rating1MouseDown(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DateNotExists1Click(Sender: TObject);
    procedure IsDatePanelDblClick(Sender: TObject);
    procedure PanelValueIsDateSetsDblClick(Sender: TObject);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure BackGroundSearchPanelResize(Sender: TObject);
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
    Procedure ListViewResize(Sender : TObject);
    procedure UpdateTheme(Sender: TObject);
    Function SelCount : integer;
    procedure EasyListviewItemThumbnailDraw(
      Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
      ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure ListViewSelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
    function GetListItemByID(ID : integer) : TEasyItem;
    function GetItemNO(item : TEasyItem):integer;
    function GetSelecteditemNO(item : TEasyItem):integer;
    function ItemIndex(item : TEasyItem) : integer;
    procedure ListViewEdited(Sender: TObject; Item: TEasyItem;
      var S: String);
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    Function ListViewSelected : TEasyItem;
    Function ItemAtPos(X,Y : integer): TEasyItem;
    Function ItemAtPosStar(X,Y : integer): TEasyItem;
    procedure EasyListviewDblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
    procedure EasyListviewItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    procedure EasyListviewKeyAction(Sender: TCustomEasyListview;
      var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListviewItemEdited(Sender: TCustomEasyListview;
      Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure N05Click(Sender: TObject);
    procedure ListviewIncrementalSearch(Item: TEasyCollectionItem;
        const SearchBuffer: WideString; var CompareResult: Integer);
    procedure ShowDateOptionsLinkClick(Sender: TObject);
    procedure LoadSizes;
    function FileNameExistsInList(FileName : string) : boolean;
    procedure ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap);
    procedure ReplaceImageIndexWithPath(FileName : string; Index : integer);
    function GetImageIndexWithPath(FileName : string) : integer;

    procedure ListViewMouseWheel(Sender: TObject; Shift: TShiftState;
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
  private
    FSearchInfo : TSearchInfo;
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
    FShellTreeView : TShellTreeView;
    procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
    function DateRangeItemAtPos(X,Y : integer): TEasyItem;
    function GetDateFilter : TDateRange;
   { Protected declarations }
  protected
    procedure CreateParams(VAR Params: TCreateParams); override;
    function TreeView : TShellTreeView;
    procedure CreateBackground;
    procedure LoadDateRange;
    procedure FetchProgress(DataSet: TCustomADODataSet;
                            Progress, MaxProgress: Integer; var EventStatus: TEventStatus);
    procedure DBRangeOpened(Sender : TObject; DS : TDataSet);
    { Private declarations }
  public
    ListView: TEasyListView;
    WindowID : TGUID;
    SelectQuery : TDataSet;
    FBitmapImageList : TBitmapImageList;
    Data : TSearchRecordArray;
    MouseDowned : Boolean;
    RenameResult : Boolean;
    PopupHandled : boolean;

    LoadingThItem, ShLoadingThItem : TEasyItem;
    ItemSelectedByMouseDown : boolean;
    ItemByMouseDown : boolean;
    LastQuery : String;
    FilesToDrag : TArStrings;
    DBCanDrag : Boolean;
    DBDragPoint : TPoint;
    current_id_show : integer;
    FSearchPath, fcomment, fkeywords : string;
    thum_images_:integer;
    mouse_mov:boolean;
    frating :integer;
    SelectedInfo : TSelectedInfo;
    Creating : Boolean;
    LockChangePath : Boolean;
    result_replaceimg : integer;
    FShowen : boolean;
    aScript : TScript;
    ListMenuScript : String;
    aFS : TFileStream;

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
    procedure DoSetSearchByComparing;
    procedure LoadSearchDBParametrs;
    procedure SaveQueryList;          
    procedure LoadQueryList;
  published
    { Public declarations }
  end;

  TManagerSearchs = class(TObject)
  private
    FSearches : TList;
    function GetValueByIndex(Index: Integer): TSearchForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewSearch : TSearchForm;
    procedure AddSearch(Search : TSearchForm);
    procedure RemoveSearch(Search : TSearchForm);
    function IsSearch(Search : TForm) : Boolean;
    function SearchCount : Integer;
    property Items[Index: Integer]: TSearchForm read GetValueByIndex; default;
    function GetAnySearch : TSearchForm;
  end;

var
  SearchManager : TManagerSearchs;

implementation

uses Language, UnitManageGroups, FormManegerUnit, SlideShow, Loadingresults,
     PropertyForm, ReplaceForm, CleaningForm, Options, UnitLoadFilesToPanel,
     UnitHintCeator, UnitImHint, DBSelectUnit, UnitFormCont,
     About, activation, ExplorerUnit, InstallFormUnit, UnitUpdateDB,
     UnitUpdateDBThread, ManagerDBUnit, UnitEditGroupsForm , UnitQuickGroupInfo,
     UnitGroupReplace, UnitSavingTableForm, UnitInternetUpdate, UnitHelp,
     ImEditor, UnitGetPhotosForm, UnitListOfKeyWords, UnitDBTreeView,
     ReplaseLanguageInScript, ReplaseIconsInScript,
     UnitUpdateDBObject, UnitFormSizeListViewTh, UnitBigImagesSize,
     UnitOpenQueryThread;

{$R *.dfm}

procedure TSearchForm.DoSearchNow(Sender: TObject);
var
  WideSearch : TSearchQuery;
  FScript : TScript;
  ScriptString : string;
  ImagesCount : Integer;
  DateRange : TDateRange;
begin
  if FUpdatingDB then Exit;
  if Creating then Exit;

  SearchByCompating := False;
  ScriptString := Include('Scripts\DoSearch.dbini');

  FScript := TScript.Create('');
  try
    FScript.Description := 'New search script';
    SearchEdit.Text := SysUtils.StringReplace(SearchEdit.Text,'"',' ',[rfReplaceAll]);

    SetNamedValue(fScript, '$SearchString', AnsiQuotedStr(SearchEdit.Text, '"'));
    SetNamedValue(fScript, '$Rating', IntToStr(RatingQuery.Rating));

    ExecuteScript(nil, FScript, ScriptString, ImagesCount, nil);
    SearchEdit.Text := GetNamedValueString(FScript, '$SearchString');
    RatingQuery.Rating := GetNamedValueInt(FScript, '$Rating');
  finally
    FScript.Free;
  end;


  DateRange := GetDateFilter;

 Button1.OnClick:= BreakOperation;
 Button1.Caption:=TEXT_MES_STOP;
 PbProgress.Text:=TEXT_MES_STOPING+'...';
 Label7.Caption:=TEXT_MES_CALCULATING+'...';
 If Creating then Exit;
 try
  ListView.Items.Clear;
  FBitmapImageList.Clear;
 except
 end;
  PbProgress.Text:=TEXT_MES_INITIALIZE+'...';
  PbProgress.position:=0;
  PbProgress.Text:=TEXT_MES_QUERY_EX;

  //TODO: free object
  WideSearch := TSearchQuery.Create;
  WideSearch.Query := SearchEdit.Text;
  WideSearch.GroupName := ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption;
  if WideSearch.GroupName = TEXT_MES_ALL_GROUPS then
    WideSearch.GroupName := '';
  WideSearch.RatingFrom := Min(RatingQuery.Rating, RatingQuery.RatingRange);
  WideSearch.RatingTo := Max(RatingQuery.Rating, RatingQuery.RatingRange);
  WideSearch.DateFrom := Min(GetDateFilter.DateFrom, GetDateFilter.DateTo);
  WideSearch.DateTo := Max(GetDateFilter.DateFrom, GetDateFilter.DateTo);
  WideSearch.ShowPrivate := TwButton1.Pushed;
  WideSearch.SortDecrement := Decremect1.Checked;
  WideSearch.SortMethod := SortLink.Tag;
  NewFormState;
  TbStopOperation.Enabled:=true;

  SearchThread.Create(Self, StateID, WideSearch, BreakOperation, FPictureSize);
  AddNewSearchListEntry;
end;

procedure TSearchForm.Edit1_KeyPress(Sender: TObject; var Key: Char);
begin
  if Byte(Key) = VK_RETURN then
  begin
    Key := #0;
    DoSearchNow(Sender);
  end;
end;

procedure TSearchForm.Additem_(Sender: TObject; Name_ : String; Tag : integer );
var
  New : TEasyItem;
begin
 New := ListView.Items.Add;
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
  TW.I.Start('S -> FormCreate');
  FSearchInfo := TSearchInfo.Create;
  CanSaveQueryList := True;
  fListUpdating:=false;
  GroupsLoaded:=false;
  SearchEdit.ShowDropDownMenu:=false;

  SearchEdit.NullText := TEXT_MES_NULL_TEXT;

  ListView := TEasyListView.Create(Self);
  ListView.Parent := Self;
  ListView.Align := AlClient;

  MouseDowned := False;
  PopupHandled := False;
  ListView.BackGround.Enabled := True;
  ListView.BackGround.Tile := False;
  ListView.BackGround.AlphaBlend := True;
  ListView.BackGround.OffsetTrack := True;
  ListView.BackGround.BlendAlpha := 220;
  ListView.Font.Color:=0;
  ListView.View:=elsThumbnail;
  ListView.DragKind:=dkDock;
  ListView.Selection.MouseButton:= [cmbRight];

  ListView.Selection.FullCellPaint := DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
  ListView.Selection.RoundRectRadius := DBKernel.ReadInteger('Options','UseListViewRoundRectSize', 3);
  ListView.Selection.AlphaBlend := True;
  ListView.Selection.AlphaBlendSelRect := True;
  ListView.Selection.MultiSelect := True;
  ListView.Selection.RectSelect := True;
  ListView.Selection.EnableDragSelect := True;
  ListView.Selection.TextColor := Theme_ListFontColor;
  ListView.GroupFont.Color := Theme_ListFontColor;
  TLoad.Instance.RequaredDBSettings;
  FPictureSize := ThImageSize;
  LoadSizes();

  ListView.HotTrack.Color := Theme_ListFontColor;
  ListView.HotTrack.Cursor := CrArrow;
  ListView.IncrementalSearch.Enabled := True;
  ListView.OnItemThumbnailDraw := EasyListViewItemThumbnailDraw;
  ListView.OnDblClick := EasyListViewDblClick;
  ListView.OnIncrementalSearch := ListViewIncrementalSearch;
  ListView.OnExit := ListViewExit;
  ListView.OnMouseDown := ListViewMouseDown;
  ListView.OnMouseUp := ListViewMouseUp;
  ListView.OnMouseMove := ListViewMouseMove;
  ListView.OnItemSelectionChanged := EasyListViewItemSelectionChanged;
  ListView.OnMouseWheel := ListViewMouseWheel;
  ListView.OnKeyAction := EasyListviewKeyAction;
  ListView.OnItemEdited := EasyListViewItemEdited;
  ListView.OnResize := ListViewResize;
  ListView.Groups.Add;
  ListView.Header.Columns.Add; 
  CreateBackground;

  ConvertTo32BitImageList(DragImageList);
  DBKernel.RegisterProcUpdateTheme(UpdateTheme, Self);
  tbStopOperation.Enabled := False;

  ExplorerManager.LoadEXIF;
  WindowID:=GetGUID;
  TW.I.Start('S -> TScript');
  aScript := TScript.Create('');
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowExplorerPanel',  F_TYPE_OBJ_PROCEDURE_TOBJECT, Explorer2Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'HideExplorerPanel',  F_TYPE_OBJ_PROCEDURE_TOBJECT, Properties1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SlideShow',          F_TYPE_OBJ_PROCEDURE_TOBJECT, SlideShow1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SelectAll',          F_TYPE_OBJ_PROCEDURE_TOBJECT, SelectAll1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CopySearchResults',  F_TYPE_OBJ_PROCEDURE_TOBJECT, CopySearchResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'LoadResults',        F_TYPE_OBJ_PROCEDURE_TOBJECT, LoadResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SaveResults',        F_TYPE_OBJ_PROCEDURE_TOBJECT, SaveResults1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CloseWindow',        F_TYPE_OBJ_PROCEDURE_TOBJECT, Exit1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'LoadExplorerValue',  F_TYPE_OBJ_PROCEDURE_TOBJECT, LoadExplorerValue);

  Menu:=nil;
  SetNamedValue(aScript, '$dbname', '"'+dbname+'"');
  ReloadListMenu;

  TW.I.Start('S -> ReadScriptFile');
  MainMenuScript := ReadScriptFile('scripts\SearchMainMenu.dbini');
  TW.I.Start('S -> LoadMenuFromScript');
  LoadMenuFromScript(ScriptMainMenu.Items,DBkernel.ImageList,MainMenuScript,aScript,ScriptExecuted,FExtImagesInImageList,true);
  Menu:=ScriptMainMenu;

 ScriptListPopupMenu.Images:=DBKernel.ImageList;
 ScriptMainMenu.Images:=DBKernel.ImageList;
 TW.I.Start('S -> GetQuery');
 SelectQuery:=GetQuery(dbname);
 TW.I.Start('S -> Register');
 DropFileTarget2.Register(SearchEdit);
 DestroyCounter:=0;
 FShowen:=false;
 FUpdatingDB:=false;

 DropFileTarget1.Register(Self);

 TW.I.Start('S -> DateTimePickers');
 try

 for i:=0 to n-1 do
 begin
  Menus[i]:=TMenuItem.Create(InsertSpesialQueryPopupMenu);
  Menus[i].Caption:=Captions[i];
  Menus[i].OnClick:=InsertSpesialQueryPopupMenuItemClick;
  Menus[i].Tag:=i;
  InsertSpesialQueryPopupMenu.Items.Add(Menus[i]);
 end;
 Menus[0].Enabled:=false;
 ListView.HotTrack.Enabled:=DBKernel.Readbool('Options','UseHotSelect',true);
 Panel1.Width:=DBKernel.ReadInteger('Search','LeftPanelWidth',150);
 FBitmapImageList := TBitmapImageList.Create;
 TW.I.Start('S -> RegisterMainForm');
 FormManager.RegisterMainForm(Self);
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate() throw exception: '+e.Message);
 end;
 try
  initialization_;
 except    
   on e : Exception do EventLog(':TSearchForm::FormCreate() throw exception: '+e.Message);
 end;                
 TW.I.Start('S -> DBKernel.RegisterForm');
 DBKernel.RegisterForm(self);

 TW.I.Start('S -> LoadLanguage');
 LoadLanguage;
 SearchManager.AddSearch(Self);

 if DBKernel.ReadboolW('','DoUpdateHelp',false) then
 begin
  DoUpdateHelp;
 end;
 DBKernel.WriteBoolW('','DoUpdateHelp',false);
 try
 TW.I.Start('S -> LoadSearchTexts');
  LoadSearchTexts;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadSearchTexts throw exception: '+e.Message);
 end;
 try
 TW.I.Start('S -> LoadGroupsList');
  LoadGroupsList;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadGroupsList throw exception: '+e.Message);
 end;
 try
 TW.I.Start('S -> LoadSearchList');
  LoadSearchList;
 except
   on e : Exception do EventLog(':TSearchForm::FormCreate()/LoadSearchList throw exception: '+e.Message);
 end;
 TW.I.Start('S -> LoadToolBarIcons');
 LoadToolBarIcons;
 ToolBar1.ShowCaptions := True;
 ToolBar1.AutoSize := True;

 TW.I.Start('S -> LoadQueryList');
 LoadQueryList;
 TW.I.Start('S -> LoadSearchDBParametrs');
 LoadSearchDBParametrs;
                               
 TW.I.Start('S -> RequaredDBKernelIcons');
 TLoad.Instance.RequaredDBKernelIcons;
 Image3.Picture.Graphic:=TIcon.Create;
 DBkernel.ImageList.GetIcon(DB_IC_GROUPS,Image3.Picture.Icon);

 TW.I.Start('S -> Create - END');
end;

procedure TSearchForm.ListViewContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Info : TDBPopupMenuInfo;
  item: TEasyItem;
  FileNames : TArStrings;
  i : integer;
  S : String;
  WorkedFiles_ : TStrings;
begin
 if CopyFilesSynchCount>0 then WindowsMenuTickCount:=GetTickCount;
 HintTimer.Enabled:=false;
 Item:=ItemByPointImage(ListView, Point(MousePos.x,MousePos.y));
 if (Item=nil) or ((MousePos.x=-1) and (MousePos.y=-1)) then Item:=ListView.Selection.First;

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
   TDBPopupMenu.Instance.Execute(ListView.ClientToScreen(MousePos).x,ListView.ClientToScreen(MousePos).y,Info);
  end else
  begin
   SetLength(FileNames,0);
   For i:=0 to length(Info.ItemFileNames_)-1 do
   if Info.ItemSelected_[i] then
   begin
    SetLength(FileNames,Length(FileNames)+1);
    FileNames[Length(FileNames)-1]:=Info.ItemFileNames_[i];
   end;
   GetProperties(FileNames,MousePos,ListView);
  end;
 end else
 begin
  WorkedFiles_ := TStringList.Create;
  WorkedFiles_.Clear;
  if ListView.Selection.First=nil then

   if (Data <> nil) and (Data.Count=ListView.Items.Count) then
   begin
    for i:=1 to ListView.Items.Count do
    WorkedFiles_.Add(Data[ItemIndex(ListView.Items[i-1])].FileName);
   end else
   begin
     WorkedFiles_ := TStringList.Create;
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
   ScriptListPopupMenu.Popup(ListView.ClientToScreen(MousePos).x,ListView.ClientToScreen(MousePos).y);
 end;
end;

procedure TSearchForm.ListViewMouseDown(Sender: TObject; Button: TMouseButton;
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
    for i:=0 to ListView.Items.Count-1 do
    if ListView.Items[i].Selected then
    if itemsel<>ListView.Items[i] then
    ListView.Items[i].Selected:=false;
    if [ssShift]*Shift<>[] then
     ListView.Selection.SelectRange(itemsel,ListView.Selection.FocusedItem,false,false) else
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

procedure TSearchForm.ListViewDblClick(Sender: TObject);
var
  MenuInfo : TDBPopupMenuInfo;
  info : TRecordsInfo;
  p,p1 : TPoint;
begin

  GetCursorPos(p1);
  p:=ListView.ScreenToClient(p1);
  if ItemByPointStar(ListView,p, fPictureSize)<>nil then
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

 if ListView.Selection.First<>nil then
 begin
  MenuInfo:=GetCurrentPopUpMenuInfo(ListViewSelected);
  If Viewer=nil then
  Application.CreateForm(TViewer,Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.Execute(Sender,info);
  Viewer.Show;
 end;
end;

procedure TSearchForm.ListViewSelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
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
  ListView.Enabled:=false;

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
   for i:=0 to ListView.Items.Count-1 do
   if ListView.Items[i].Selected then
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
   for i:=0 to ListView.Items.Count-1 do
   if ListView.Items[i].Selected then
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
  ListView.Enabled:=true;
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
 PbProgress.Text:=TEXT_MES_PROGRESS_PR;
 PbProgress.Position:=0;
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
 if not (item.imageindex<=0) then
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
    FBitmapImageList[item.ImageIndex].Bitmap.Free;
    FBitmapImageList[item.ImageIndex].Bitmap:=bit;
    ListView.Refresh;
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
  ApplyRotate(bit, Data[ItemIndex(item)].Rotation);
 
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

  FBitmapImageList[item.ImageIndex].Bitmap.free;
  FBitmapImageList[item.ImageIndex].Bitmap:=bit;
  RecordInfo.ItemFileName:=SelectQuery.FieldByName('FFileName').AsString;
  RecordInfo.ItemRating:=Data[iItemIndex].Rating;
  RecordInfo.ItemRotate:=Data[iItemIndex].Rotation;
  RecordInfo.ItemAccess:=Data[iItemIndex].Access;
  RecordInfo.ItemCrypted:=Data[iItemIndex].Crypted;

  ListView.Refresh;
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
    FBitmapImageList[item.ImageIndex].Bitmap.Assign(bit);
    ListView.Refresh;
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
  ApplyRotate(bit, Data[ItemIndex(item)].Rotation);
  Exists:=0;
  DrawAttributes(bit,fPictureSize,Data[ItemIndex(item)].Rating,Data[ItemIndex(item)].Rotation,Data[ItemIndex(item)].Access,SelectQuery.FieldByName('FFileName').AsString,Data[ItemIndex(item)].Crypted,Exists);
  FBitmapImageList.AddBitmap(bit);
  ListView.Refresh;
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
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i].Tag=ID then
  begin
   result:=ListView.Items[i];
   break;
  end;
 end;
end;

function TSearchForm.GetSelectedID: tarinteger;
var
  i, c : integer;
begin
 c:=0;
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i].Selected then
  begin
   inc(c);
   SetLength(result,c);
   result[c-1]:=ListView.Items[i].Tag;
  end;
 end;
end;

function TSearchForm.GetSelectedTStrings: TStrings;
var
  i : integer;
begin
 Result:=TStringList.Create;
 if ListView.Items.Count=0 then exit;
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i].Selected then
  if FileExists(Data[ItemIndex(ListView.Items[i])].FileName) then
  Result.Add(Data[ItemIndex(ListView.Items[i])].FileName);
 end;
end;

procedure TSearchForm.FormDestroy(Sender: TObject);
begin
 DBKernel.WriteInteger('Search','LeftPanelWidth',Panel1.Width);
 DBKernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
 aScript.Free;
 FreeDS(SelectQuery);
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

 FSearchInfo.Free;
end;

procedure TSearchForm.Reloadtheme(Sender: TObject);
begin   
  DBKernel.RecreateThemeToForm(self);
  Application.HintColor:=Theme_MainColor;
end;

procedure TSearchForm.BreakOperation(Sender: TObject);
begin
 if tbStopOperation.Enabled then
 tbStopOperation.Click;
 PbProgress.Text:=TEXT_MES_STOPING+'...';
 Button1.Onclick:= Search;
 Button1.Caption:=TEXT_MES_SEARCH;
 PbProgress.Text:=TEXT_MES_DONE;
 PbProgress.Position:=0;
 ListView.Show;
 BackGroundSearchPanel.Hide;
 ListView.Groups.EndUpdate;
end;

procedure TSearchForm.Search(Sender: TObject);
begin
 DoSearchNow(Sender);
end;

procedure TSearchForm.SelectAll1Click(Sender: TObject);
begin
 ListView.Selection.SelectAll;
 ListView.SetFocus;
end;

function TSearchForm.GetAllFiles: Tstrings;
var
  i : integer;
begin
 Result:=TStringList.Create;
 for i:=1 to ListView.Items.Count do
 Result.Add(Data[ItemIndex(ListView.Items[i-1])].FileName);
end;

function TSearchForm.GetItemNO(item : TEasyItem) : integer;
var
  i : integer;
begin
 result:=0;
 if ListView.Items.Count=0 then exit;
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i]=item then
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
 if ListView.Items.Count=0 then exit;
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i].Selected then inc(c);
  if ListView.Items[i]=item then
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
 ListViewSelectItem(nil,GetlistitembyID(ID),true);
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
  ListView.Refresh;
  exit;
 end;

 if EventID_Param_GroupsChanged in params then
 begin
  ReRecreateGroupsList;
  Exit;
 end;

 if EventID_Param_DB_Changed in params then
 begin
  Caption:=ProductName+' -  ['+DBkernel.GetDataBaseName+']';
  ReRecreateGroupsList;
  FPictureSize:=Dolphin_DB.ThImageSize;
  LoadSizes;
 end;

 if ID=-2 then exit;

 if [EventID_Param_DB_Changed,EventID_Param_Refresh_Window] * params<>[] then
 begin
  FreeDS(SelectQuery);
  SelectQuery:=GetQuery(dbname);
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
 For i:=0 to Data.Count-1 do
 if Data[i].ID=ID then
 begin
  if EventID_Param_Private in params then Data[i].Access:=Value.Access;
  if EventID_Param_Crypt in params then Data[i].Crypted:=Value.Crypt;
  if EventID_Param_Include in params then
  begin
   Data[i].Include:=Value.Include;
   Boolean(TDataObject(GetListItemByID(ID).Data).Include):=Value.Include;
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
  for i:=0 to Data.Count-1 do
  if Data[i].ID=ID then
  begin
   if ListView.Items[i].ImageIndex>-1 then
   begin
    ApplyRotate(FBitmapImageList[ListView.Items[i].ImageIndex].Bitmap, ReRotation);
   end else
   begin
    FilesToUpdate := TSearchRecordArray.Create;
    with FilesToUpdate.AddNew do
    begin
      FileName:=FileName;
      Rotation:=Rotate;
    end;
    RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(True,self,StateID,nil,fPictureSize,FilesToUpdate,true));
   end;
  end;
 end;

 RefreshParams:=[EventID_Param_Private,EventID_Param_Rotate,EventID_Param_Name,EventID_Param_Rating,EventID_Param_Crypt];
 if RefreshParams*params<>[] then
 begin
  ListView.Repaint;
 end;

 RefreshParams:=[EventID_Param_Image,EventID_Param_Delete,EventID_Param_Critical];
 if RefreshParams*params<>[] then
 begin               
  with FilesToUpdate.AddNew do
  begin
    FileName:=FileName;
    Rotation:=Rotate;
  end;

  TSearchBigImagesLoaderThread.Create(false,self,StateID,nil,fPictureSize,FilesToUpdate,true);
 end;
 if ((EventID_Param_Comment in params) or (EventID_Param_KeyWords in params) or (EventID_Param_Rating in params) or (EventID_Param_Date in params) or (EventID_Param_Time in params) or (EventID_Param_IsDate in params) or (EventID_Param_IsTime in params)  or (EventID_Param_Groups in params)) and (ID=current_id_show) then
 ListViewSelectItem(Sender,GetListItemByID(ID),true);

 if (EventID_Param_include in params) then ListView.Refresh;
end;

procedure TSearchForm.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key='"' then key:='''';
end;

procedure TSearchForm.ListViewMouseMove(Sender: TObject; Shift: TShiftState; X,
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
   Item:= ListView.Selection.First;
   for i:=0 to ListView.Selection.Count-1 do
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
    Item:=ListView.Selection.Next(Item);
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
    Result:=FBitmapImageList[index].Bitmap;
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

   item:=ItemAtPos(ListView.ScreenToClient(p).x,ListView.ScreenToClient(p).y);
   if item=nil then exit;
   if ListView.Selection.FocusedItem=nil then
   ListView.Selection.FocusedItem:=item;
   //Creating Draw image
   TempImage:=TBitmap.create;
   TempImage.PixelFormat:=pf32bit;
   TempImage.Width:=fPictureSize+Min(ListView.Selection.Count,10)*7+5;
   TempImage.Height:=fPictureSize+Min(ListView.Selection.Count,10)*7+45+1;
   MaxH:=0;
   MaxW:=0;
   TempImage.Canvas.Brush.Color := 0;
   TempImage.Canvas.FillRect(Rect(0, 0, TempImage.Width, TempImage.Height));

   if ListView.Selection.Count<2 then
   begin
    DragImage:=nil;
    if item<>nil then
    DragImage:=GetImageByIndex(item.ImageIndex,item.Index) else
    if ListView.Selection.First<>nil then
    DragImage:=GetImageByIndex(ListView.Selection.First.ImageIndex,ItemIndex(ListView.Selection.First));

    TempImage.Canvas.Draw(0,0, DragImage);
    n:=0;
    MaxH:=DragImage.Height;
    MaxW:=DragImage.Width;
    ImH:=DragImage.Height;
    ImW:=DragImage.Width;
    DragImage.Free;
   end else
   begin
    SelectedItem:=ListView.Selection.First;
    n:=1;
    for i:=1 to 9 do
    begin
     if SelectedItem<>item then
     begin
      DragImage:=GetImageByIndex(SelectedItem.ImageIndex,ItemIndex(ListView.Selection.First));
      TempImage.Canvas.Draw(n,n, DragImage);
      Inc(n,7);
      if DragImage.Height+n>MaxH then MaxH:=DragImage.Height+n;
      if DragImage.Width+n>MaxW then MaxW:=DragImage.Width+n;
      DragImage.Free;
     end;
     SelectedItem:=ListView.Selection.Next(SelectedItem);
     if SelectedItem=nil then break;
    end;
    DragImage:=GetImageByIndex(ListView.Selection.FocusedItem.ImageIndex,ItemIndex(ListView.Selection.FocusedItem));
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
   FileName:=ListView.Selection.FocusedItem.Caption;
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
   ListView.Refresh;

   Application.HideHint;
   if ImHint<>nil then
   if not UnitImHint.closed then
   ImHint.close;
   HintTimer.Enabled:=false;

   item.ItemRectArray(nil,ListView.Canvas,EasyRect);

   DBDragPoint:=ListView.ScreenToClient(DBDragPoint);

   ImW:=(EasyRect.IconRect.Right-EasyRect.IconRect.Left) div 2 - ImW div 2;
   ImH:=(EasyRect.IconRect.Bottom-EasyRect.IconRect.Top) div 2 - ImH div 2;
   DropFileSource1.ImageHotSpotX:=Min(MaxW,Max(1,DBDragPoint.X-EasyRect.IconRect.Left+n-ImW));
   DropFileSource1.ImageHotSpotY:=Min(MaXH,Max(1,DBDragPoint.Y-EasyRect.IconRect.Top+n-ImH+ListView.Scrollbars.ViewableViewportRect.Top));

   DropFileSource1.Execute;
   DBCanDrag:=false;
  end;
 end;

 if ImHint<>nil then
 begin
  GetCursorPos(p);
  if WindowFromPoint(p)=ImHint.Handle then exit;
 end;

 if LoadingThItem=ItemByPointImage(ListView,Point(X,Y)) then exit;
 LoadingThItem:=ItemByPointImage(ListView,Point(X,Y));
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
  if ItemIndex(LoadingThItem)<Data.Count then
  ListView.ShowHint:= not FileExists(Data[ItemIndex(loadingthitem)].FileName) else
  ListView.ShowHint:=true;
  if LoadingThItem<>nil then
  begin
   if ItemIndex(LoadingThItem)<Data.Count-1 then
   if ItemIndex(LoadingThItem)>-1 then
   ListView.Hint:=Data[ItemIndex(LoadingThItem)].Comments;
  end;
 end;
end;

procedure TSearchForm.Options1Click(Sender: TObject);
begin
 DoOptions;
end;

procedure TSearchForm.CopySearchResults1Click(Sender: TObject);
var
  I : integer;
  Sclipbrd : string;
begin
  Sclipbrd := '';
  for I := 1 to ListView.Items.Count do
    Sclipbrd := Sclipbrd + IntToStr(ListView.Items[I - 1].Tag) + '$';

  Clipboard.AsText := Sclipbrd;
end;

procedure TSearchForm.HintTimerTimer(Sender: TObject);
var
  p, p1 : tpoint;
  Index, i : Integer;
  item: TEasyItem;
begin
 GetCursorPos(p);
 p1:=ListView.ScreenToClient(p);

 if (not Active) or (not ListView.Focused) or (ItemAtPos(p1.X,p1.y)<>LoadingThItem) or (shloadingthitem<>LoadingThItem) then

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
 if (Index<0) or (Index>Data.Count-1) then Exit;
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
   for i:=0 to ListView.Items.Count-1 do
   if ListView.Items[i].Selected then
   if LoadingThItem<>ListView.Items[i] then
   ListView.Items[i].Selected:=false;
   if ShiftKeyDown then
    ListView.Selection.SelectRange(LoadingThItem,ListView.Selection.FocusedItem,false,false) else
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
 p1:=ListView.ScreenToClient(p);
 result:=not ((not self.Active) or (not ListView.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (ItemAtPos(p1.X,p1.y)=nil) or (item<>loadingthitem));
end;

procedure TSearchForm.initialization_;
begin
 TW.I.Start('S -> initialization_');
 If DBTerminating then exit;
 DBCanDrag:=false;
 DBKernel.RegisterChangesID(self,ChangedDBDataByID);
 Caption:=ProductName+' - ['+DBkernel.GetDataBaseName+']';

 TW.I.Start('S -> DoShowSelectInfo');
 DoShowSelectInfo;
 ListView.Canvas.Pen.Color:=$0;
 ListView.Canvas.brush.Color:=$0;
 button1.onclick:= Search;
 button1.caption:=TEXT_MES_SEARCH;
 Label7.Caption:=TEXT_MES_NO_RES;
 PbProgress.Text:=TEXT_MES_NO_RES;
 SaveWindowPos1.Key:=RegRoot+'Searching';
 SaveWindowPos1.SetPosition;
 TW.I.Start('S -> Reloadtheme');
 Reloadtheme(nil);

 SortLink.UseSpecIconSize:=true;
 SortLink.SetDefault;

 ListView.DoubleBuffered:=true;

 TW.I.Start('S -> Immges');
 PopupMenu8.Images:=DBKernel.ImageList;
 OpeninExplorer1.ImageIndex:=DB_IC_EXPLORER;
 AddFolder1.ImageIndex:=DB_IC_ADD_FOLDER;

 SortbyCompare1.ImageIndex:=DB_IC_DUBLICAT;

 View2.ImageIndex:=DB_IC_SLIDE_SHOW;

 RatingPopupMenu1.Images:=DBkernel.ImageList;

 N00.ImageIndex:=DB_IC_DELETE_INFO;
 N01.ImageIndex:=DB_IC_RATING_1;
 N02.ImageIndex:=DB_IC_RATING_2;
 N03.ImageIndex:=DB_IC_RATING_3;
 N04.ImageIndex:=DB_IC_RATING_4;
 N05.ImageIndex:=DB_IC_RATING_5;


 ShowDateOptionsLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_EDIT_DATE+1]);

 TW.I.Start('S -> BackGroundSearchPanelResize');
 BackGroundSearchPanelResize(Nil);
 TW.I.Start('S -> Splitter1Moved');
 TW.I.Start('S -> DoUnLockInfo');

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

   SetLength(ItemsIDArray,Data.Count);
   for i:=0 to Data.Count-1 do
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

   SetLength(ItemsIDArray,Data.Count);
   for i:=0 to Data.Count-1 do
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

   SetLength(ItemsImThArray,Data.Count);
   for i:=0 to Data.Count-1 do
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
  EventLog('Error ['+DateTimeToStr(Now)+'] = '+e.Message);
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
  SearchEdit.Text:=':folder('+TreeView.Path+'):';
  DoSearchNow(Sender);
end;

procedure TSearchForm.RenameCurrentItem(Sender: TObject);
begin
 if ListView.Selection.First=nil then exit;
 ListView.EditManager.Enabled:=true;
end;

procedure TSearchForm.ListViewKeyPress(Sender: TObject; var Key: Char);
begin
 If key=#13 then ListViewDblClick(Sender);
 if Key in Unusedchar then key:=#0;
 //TODO: contex menu popup
end;

procedure TSearchForm.ListViewEdited(Sender: TObject; Item: TEasyItem;
  var S: String);
begin
 s:=copy(s,1,min(length(s),255));
 if AnsiLowerCase(s)=AnsiLowerCase(ExtractFileName(Data[ItemIndex(Item)].FileName)) then exit;
 begin
  If GetExt(s)<>GetExt(Data[ItemIndex(Item)].FileName) then
  If FileExists(Data[ItemIndex(Item)].FileName) then
  begin
   If ID_OK<>MessageBoxDB(Handle,TEXT_MES_REPLACE_EXT,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
   begin
    s:=ExtractFileName(Data[ItemIndex(Item)].FileName);
    Exit;
   end;
  end;
  RenameResult:=RenameFileWithDB(Data[ItemIndex(Item)].FileName,GetDirectory(Data[ItemIndex(Item)].FileName)+s, Item.Tag,false);
 end;
end;

procedure TSearchForm.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

 if ListViewSelected=nil then exit;

 if Ord(Key) = VK_F2 then
 if SelCount=1 then


  ListView.EditManager.Enabled:=true;
  ListView.Selection.First.Edit;

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
 MenuLength:=Data.Count;
 if MenuLength<ListView.Items.Count then exit;
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
 For i:=0 to ListView.Items.Count-1 do
 if ListView.Items[i].Selected then
 Result.ItemSelected_[i]:=true else
 Result.ItemSelected_[i]:=false;
 If Item=nil then
 begin
 end else
 begin
  if SelCount=1 then
  begin
   Result.IsListItem:=true;
   if ListView.Selection.First<>nil then
   begin
    Result.ListItem:=ListView.Selection.First;
    Result.Position:=ItemIndex(ListView.Selection.First);
   end;
  end;
  if SelCount>1 then
  begin
   Result.Position:=ItemIndex(Item);
  end;
 end;
end;

procedure TSearchForm.ListViewMouseUp(Sender: TObject; Button: TMouseButton;
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
     for i:=0 to ListView.Items.Count-1 do
     if ListView.Items[i].Selected then
     if item<>ListView.Items[i] then
     ListView.Items[i].Selected:=false;
    end;
    if not (ebcsDragSelecting in ListView.States) then
    if ([ssCtrl]*Shift<>[]) and not ItemSelectedByMouseDown and (Button=mbLeft) then
    item.Selected:=false;
   end;

 if MouseDowned then
 if Button=mbRight then
 begin
  ListViewContextPopup(ListView,Point(X,Y),Handled);
  PopupHandled:=true;
 end;
 MouseDowned:=false;
 DBCanDrag:=false;
 SetLength(FilesToDrag,0);
end;

procedure TSearchForm.ListViewExit(Sender: TObject);
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
end;

procedure TSearchForm.Explorer2Click(Sender: TObject);
begin
 PropertyPanel.Visible:=false;
 ExplorerPanel.Visible:=true;
 if not TreeView.UseShellImages then
 begin
  TreeView.ObjectTypes:=[otFolders];
  TreeView.UseShellImages:=true;
  TreeView.Refresh(TreeView.TopItem);
 end;
 ExplorerPanel.Align:=AlClient;
 Properties1.Checked:=false;
 Explorer2.Checked:=true;
 TreeView.FullCollapse;
 if FSearchPath<>'' then
 if DirectoryExists(FSearchPath) then
 TreeView.Path:=FSearchPath;
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
  TmpBool : Boolean;
begin
  if (Msg.message = WM_KEYDOWN) and (SearchEdit.Focused) and (Msg.wParam = VK_RETURN) then
  begin     
    Handled := True;
    Msg.Message := 0;
    DoSearchNow(nil);
  end;

  if (Msg.message = WM_KEYUP) and SearchEdit.Focused then
    Msg.Message := 0;

  if Msg.hwnd = ListView.Handle then
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

    if (Msg.message = WM_MOUSEWHEEL) and CtrlKeyDown then
    begin
      if Msg.wParam > 0 then i := 1 else i := -1;
      ListViewMouseWheel(ListView, [ssCtrl], i, Point(0,0), TmpBool);
      Msg.message := 0;
    end;

    if Msg.message = WM_KEYDOWN then
    begin
      WindowsMenuTickCount:=GetTickCount;
      //context menu button
      if (Msg.wParam = VK_APPS) then
        ListViewContextPopup(ListView,Point(-1,-1), TmpBool);

      if (Msg.wParam = Ord('r')) or (Msg.wParam = Ord('R')) and ShiftkeyDown then
      begin
        ReloadIDMenu;
        ReloadListMenu;
        MessageBoxDB(Handle,TEXT_MES_MENU_RELOADED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
      end;

      if (Msg.wParam = VK_SUBTRACT) then
        ZoomIn;
      if (Msg.wParam = VK_ADD) then
        ZoomOut;
      if (Msg.wParam = VK_DELETE) and not FUpdatingDB then
        DeleteSelected;
      if (Msg.wParam = Ord('a')) and CtrlKeyDown and not FUpdatingDB then
        SelectAll1Click(Nil);
      if (Msg.wParam = Ord('s')) and CtrlKeyDown and tbStopOperation.Enabled then
        tbStopOperationClick(nil);

    end;
  end;

  if (Msg.hwnd = FFirstTip_WND) and (Msg.message = WM_TIMER) and (Msg.WParam = 4) then
    SendMessage(FFirstTip_WND, WM_CLOSE, 1, 1);

end;

procedure TSearchForm.SetPath(Value: String);
begin
 formatDir(Value);
 FSearchPath := Value;
 LockChangePath:=true;
 If ExplorerPanel.Visible then
 TreeView.Path:=Value;
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
var
  WaitImage : TPNGGraphic;
  WaitImageBMP : TBitmap;
begin
  FListUpdating := True;
  ListView.BeginUpdate;
  ListView.Groups.BeginUpdate(False);
  if ImageSearchWait.Picture.Graphic = nil then
  begin
    WaitImage := GetSearchWait;
    try
      WaitImageBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(WaitImage, WaitImageBMP, Theme_ListColor);
        ImageSearchWait.Picture.Graphic := WaitImageBMP;
      finally
        WaitImageBMP.Free;
      end;
    finally
      WaitImage.Free;
    end;
  end;
  BackGroundSearchPanel.Visible := True;
  ListView.Visible := False;
end;

procedure TSearchForm.EndUpdate;
begin
 fListUpdating:=false;
 ListView.Visible:=true;
 BackGroundSearchPanel.Visible:=False;
 ListView.Groups.EndUpdate;
 ListView.EndUpdate;
end;

procedure TSearchForm.BackGroundSearchPanelResize(Sender: TObject);
begin
 LabelBackGroundSearching.Top:=BackGroundSearchPanel.Height div 2+128 div 2;
 LabelBackGroundSearching.Left:=BackGroundSearchPanel.Width div 2-LabelBackGroundSearching.Width div 2;
 ImageSearchWait.Top:=BackGroundSearchPanel.Height div 2-128 div 2;
 ImageSearchWait.Left:=BackGroundSearchPanel.Width div 2-128 div 2;
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
 DoSearchNow1.Caption:=TEXT_MES_DO_SEARCH_NOW;
 Panels1.Caption:=TEXT_MES_PANELS;
 Properties1.Caption:=TEXT_MES_PROPERTIES;
 Explorer2.Caption:=TEXT_MES_EXPLORER;
 EditGroups1.Caption:=TEXT_MES_EDIT_GROUPS;
 GroupsManager1.Caption:=TEXT_MES_GROUPS_MANAGER;
 Ratingnotsets1.Caption:=TEXT_MES_RATING_NOT_SETS;
 SetComent1.Caption:=TEXT_MES_SET_COM;
 Comentnotsets1.Caption:=TEXT_MES_SET_COM_NOT;
 MenuItem2.Caption:=TEXT_MES_SELECT_ALL;
 Cut1.Caption:=TEXT_MES_CUT;
 Copy2.Caption:=TEXT_MES_COPY;
 Paste1.Caption:=TEXT_MES_PASTE;
 Undo1.Caption:=TEXT_MES_UNDO;
 OpeninExplorer1.Caption:=TEXT_MES_OPEN_IN_EXPLORER;
 AddFolder1.Caption:=TEXT_MES_ADD_FOLDER;
 SortbyID1.Caption:=TEXT_MES_SORT_BY_ID;
 SortbyName1.Caption:=TEXT_MES_SORT_BY_NAME;
 SortbyDate1.Caption:=TEXT_MES_SORT_BY_DATE;
 SortbyRating1.Caption:=TEXT_MES_SORT_BY_RATING;
 SortbyFileSize1.Caption:=TEXT_MES_SORT_BY_FILESIZE;
 SortbySize1.Caption:=TEXT_MES_SORT_BY_SIZE;

 SortbyCompare1.Caption:=TEXT_MES_IMAGES_SORT_BY_COMPARE_RESULT;
 
 Increment1.Caption:=TEXT_MES_SORT_INCREMENT;
 Decremect1.Caption:=TEXT_MES_SORT_DECREMENT;

 Datenotexists1.Caption:=TEXT_MES_NO_DATE_1;
 DateExists1.Caption:=TEXT_MES_DATE_EX;
 Datenotsets1.Caption:=TEXT_MES_DATE_NOT_SETS;
 PanelValueIsDateSets.Caption:=TEXT_MES_VAR_VALUES;
 IsDatePanel.Caption:=TEXT_MES_NO_DATE_1;
 Setvalue1.Caption:=TEXT_MES_SET_VALUE;
 Setvalue2.Caption:=TEXT_MES_SET_VALUE;
 IsTimePanel.Caption:=TEXT_MES_TIME_NOT_EXISTS;
 PanelValueIsTimeSets.Caption:=TEXT_MES_VAR_VALUES;

 Timenotsets1.Caption:=TEXT_MES_TIME_NOT_SETS;
 TimeExists1.Caption:=TEXT_MES_TIME_EXISTS;
 TimenotExists1.Caption:=TEXT_MES_TIME_NOT_EXISTS;

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

procedure TSearchForm.HelpTimerTimer(Sender: TObject);
var
  DS : TDataSet;

  procedure xHint(xDS : TDataSet);

    function count :  integer;
    begin
     result:=xDS.FieldByName('Coun').AsInteger;
    end;

  begin
   if count<50 then
   DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_FIRST,Point(0,0),ListView,HelpNextClick,TEXT_MES_NEXT_HELP,HelpCloseClick) else
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
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_FIRST,Point(0,0),ListView,HelpActivationNextClick,TEXT_MES_NEXT_HELP,HelpActivationCloseClick) else
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

end;

procedure TSearchForm.PopupMenu7Popup(Sender: TObject);
begin
 Setvalue1.Visible:= not FUpdatingDB;
end;

procedure TSearchForm.PopupMenu4Popup(Sender: TObject);
begin
 EditGroups1.Visible:= not FUpdatingDB;
end;

procedure TSearchForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
 if not (key in abs_cifr) then
 if key<>#8 then Key:=#0;
end;

procedure TSearchForm.PopupMenu8Popup(Sender: TObject);
begin
 if TreeView.SelectedFolder<>nil then
 begin
  TempFolderName:=TreeView.SelectedFolder.PathName;
  OpeninExplorer1.Visible:=DirectoryExists(TreeView.SelectedFolder.PathName);
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
 With ExplorerManager.NewExplorer(False) do
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
  i: integer;
begin
 for i:=0 to ListView.Items.Count-1 do
 begin
  if ListView.Items[i].Tag=ID then
  begin
    Data.DeleteAt(i);
    ListView.Items.Delete(i);
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
begin
  if FSearches.IndexOf(Search) = -1 then
    FSearches.Add(Search);
end;

constructor TManagerSearchs.Create;
begin
  FSearches := TList.Create;
end;

destructor TManagerSearchs.Destroy;
begin
  FSearches.Free;
  inherited;
end;

function TManagerSearchs.IsSearch(Search: TForm): Boolean;
begin
  Result := FSearches.IndexOf(Search) > -1;
end;

function TManagerSearchs.NewSearch: TSearchForm;
begin
  Application.CreateForm(TSearchForm,Result);
end;

function TManagerSearchs.GetAnySearch : TSearchForm;
begin
  if SearchCount = 0 then
    Result := NewSearch
  else
    Result := FSearches[0];
end;

procedure TManagerSearchs.RemoveSearch(Search: TSearchForm);
begin
  FSearches.Remove(Search);
end;

function TManagerSearchs.SearchCount: Integer;
begin
 Result := FSearches.Count;
end;

procedure TSearchForm.NewSearch1Click(Sender: TObject);
begin
  with SearchManager.NewSearch do
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
 ListViewContextPopup(ListView,Point(0,0),Handled);
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
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_ACTIVATION_1,Point(0,0),ListView,HelpActivationNextClick,TEXT_MES_NEXT_HELP,HelpActivationCloseClick);
 end;
 if HelpActivationNO=2 then
 begin
  ListViewContextPopup(ListView,Point(0,0),Handled);
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
 SortLink.RefreshBuffer;
 SortingClick(Sender);
end;

procedure TSearchForm.Increment1Click(Sender: TObject);
begin
 Increment1.Checked:=true;
 SortLink.Icon:=Image5.Picture.Icon;
 SortLink.RefreshBuffer;
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
   DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
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
 if PbProgress.Position<>0 then exit;
 ListView.Groups.BeginUpdate(false);
 for i:=ListView.Items.Count-1 downto 0 do
 if ListView.Items[i].Selected then
 begin
  DeleteItemByID(ListView.Items[i].Tag);
 end;
 ListView.Groups.EndUpdate(false);
end;

procedure TSearchForm.HidePanelTimerTimer(Sender: TObject);
begin
 if (ListViewSelected=nil) or (SelCount=0) then
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
 if ExplorerPanel.Visible then Properties1Click(Sender) else Explorer2Click(Sender);
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
 if ListViewSelected=nil then
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

  For i:=0 to ListView.Items.Count-1 do
  if ListView.Items[i].Selected then
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
  Memo1Change(nil);
  lockwindowupdate(0);
  current_id_show:=-1;
  FreeDS(WorkQuery);
 end else begin
  rating1.Islayered:=false;
  SelectQuery.Active:=false;

  indent:=0;
  if ListView.Selection.First<>nil then
  indent:=ListView.Selection.First.Tag;

  SetSQL(SelectQuery,'SELECT * FROM '+GetDefDBName+' WHERE ID='+inttostr(indent));
  SelectQuery.active:=true;
  lockwindowupdate(Handle);
  Label2.Caption:=Format(TEXT_MES_ID_FORMATA,[inttostr(indent)]);
  Label4.Caption:=Format(TEXT_MES_SIZE_FORMATA,[sizeintextA(SelectQuery.FieldByName('FileSize').asinteger)]);
  memo1.Lines.text:=SelectQuery.FieldByName('KeyWords').asstring;
  memo2.Lines.text:=SelectQuery.FieldByName('Comment').asstring;
  Rating1.Rating:=SelectQuery.FieldByName('Rating').asinteger;
  CurrentItemInfo.ItemRating:=Rating1.Rating;

  ListView.Hint := SelectQuery.FieldByName('Comment').asstring;
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
  ListMenuScript := ReadScriptFile('scripts\SearchListMenu.dbini');
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
 Result:= ListView.Selection.Count;
end;

function TSearchForm.ListViewSelected : TEasyItem;
begin
 Result:= ListView.Selection.First;
end;

procedure TSearchForm.EasyListViewItemThumbnailDraw(
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

 ListView.PaintInfoItem.FBorderColor := GetListItemBorderColor(TDataObject(Item.Data));

 if Item.ImageIndex>-1 then
 begin
  w:=FBitmapImageList[Item.ImageIndex].Bitmap.Width;
  h:=FBitmapImageList[Item.ImageIndex].Bitmap.Height;
  ProportionalSizeA(fPictureSize,fPictureSize,w,h);
 end;

 b:=TBitmap.Create;
 b.PixelFormat:=pf24bit;
 b.Width:=fPictureSize;
 b.Height:=fPictureSize;
 FillRectNoCanvas(b,ListView.Canvas.Brush.Color);

 if Item.ImageIndex>-1 then
 begin
  b.Canvas.StretchDraw(Rect(fPictureSize div 2 - w div 2,fPictureSize div 2 - h div 2,w+(fPictureSize div 2 - w div 2),h+(fPictureSize div 2 - h div 2)),FBitmapImageList[Item.ImageIndex].Bitmap);
 end else
 begin
  b.Canvas.Draw(fPictureSize div 2 - image1.picture.Graphic.Width div 2,fPictureSize div 2 - image1.picture.Graphic.height div 2,image1.picture.Graphic);
 end;

 r.Left:=r1.Left-2;
 r.Top:=r1.Top-2;

 index:=ItemIndex(Item);
 if index>Data.Count-1 then
 begin
  EventLog(':TSearchForm.ListViewItemThumbnailDraw() Error: index = '+IntToStr(index)+', Length(Data) = '+IntToStr(Data.Count));
  exit;
 end;
 DrawAttributes(b,fPictureSize,Data[index].Rating,Data[index].Rotation,Data[index].Access,Data[index].FileName,Data[index].Crypted,Data[index].Exists,1);

 if ProcessedFilesCollection.ExistsFile(Data[index].FileName)<>nil then
 DrawIconEx(b.Canvas.Handle,2,b.Height-18,UnitDBKernel.icons[DB_IC_RELOADING+1],16,16,0,0,DI_NORMAL);

 if (Data[index].CompareResult.ByGistogramm>0) or (Data[index].CompareResult.ByPixels>0) then
 begin
  DrawIconEx(b.Canvas.Handle,fPictureSize-16,b.Height-18,UnitDBKernel.icons[DB_IC_DUBLICAT+1],16,16,0,0,DI_NORMAL);
  temp_str:=Format('%d%%\%d%%',[Round(Data[index].CompareResult.ByPixels),Round(Data[index].CompareResult.ByGistogramm)]);
  r1:=Rect(fPictureSize-16-b.Canvas.TextWidth(temp_str)-3,b.Height-16,fPictureSize-16,B.Height);
  DrawTextA(b.Canvas.Handle, PChar(temp_str), Length(temp_str), r1, DT_VCENTER+DT_CENTER);
 end;

 ACanvas.Draw(r.Left,r.Top,b);
 b.free;
end;

procedure TSearchForm.EasyListViewDblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
begin
 ListViewDblClick(Sender);
end;

procedure TSearchForm.EasyListViewItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 ListViewSelectItem(Sender,Item,false);
end;

function TSearchForm.ItemAtPosStar(X,Y : integer): TEasyItem;
begin
 result:=nil;
end;

Function TSearchForm.ItemAtPos(X,Y : integer): TEasyItem;
begin
 Result:=ItemByPointImage(ListView,Point(x,y));
end;

procedure TSearchForm.EasyListviewKeyAction(Sender: TCustomEasyListview;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
var
  aChar : Char;
begin
 aChar:=Char(CharCode);
 ListViewKeyPress(Sender,aChar);
 if CharCode=VK_F2 then ListViewKeyDown(Sender,CharCode,[]);
end;

procedure TSearchForm.EasyListViewItemEdited(Sender: TCustomEasyListview;
  Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
var
  s : string;
begin
 s:=NewValue;
 RenameResult:=true;
 ListViewEdited(Sender,Item,s);
 ListView.EditManager.Enabled:=false;
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

procedure TSearchForm.ListViewResize(Sender : TObject);
begin
 ListView.BackGround.OffsetX:=ListView.Width-ListView.BackGround.Image.Width;
 ListView.BackGround.OffsetY:=ListView.Height-ListView.BackGround.Image.Height;
end;

procedure TSearchForm.UpdateTheme(Sender: TObject);
begin
 SortLink.SetDefault;
 ListView.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
 ListView.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);
 CreateBackground;
end;

procedure TSearchForm.ListViewIncrementalSearch(Item: TEasyCollectionItem;
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
   Result:=Result+ListView.Groups[i].Items.Count;
  end;
end;

procedure TSearchForm.ShowDateOptionsLinkClick(Sender: TObject);
begin
  if pnDateRange.Visible then
    pnDateRange.Hide
  else begin
    pnDateRange.Show;
    LoadDateRange;
  end;
end;

procedure TSearchForm.LoadSizes();
begin
  ListView.CellSizes.Thumbnail.Width := FPictureSize + 10;
  ListView.CellSizes.Thumbnail.Height := FPictureSize + 36;
end;

function TSearchForm.FileNameExistsInList(FileName : string) : boolean;
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 Result:=false;
 for i:=0 to Data.Count-1 do
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
 for i:=0 to Data.Count-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   Result:=ListView.Items[i].ImageIndex;
   break;
  end;
 end;
end;

procedure TSearchForm.ReplaceImageIndexWithPath(FileName : string; Index : integer);
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Data.Count-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   ListView.Items[i].ImageIndex:=Index;
  end;
 end;
end;

procedure TSearchForm.ReplaceBitmapWithPath(FileName : string; Bitmap : TBitmap);
var
  i : integer;
  Bmp : TBitmap;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Data.Count-1 do
 begin
  if Data[i].FileName=FileName then
  begin
   if ListView.Items[i].ImageIndex=-1 then
   begin
    Bmp:=TBitmap.Create;
    Bmp.Assign(Bitmap);
    FBitmapImageList.AddBitmap(Bmp);
    ListView.Items[i].ImageIndex:=FBitmapImageList.Count-1;
   end else
   begin
    FBitmapImageList[ListView.Items[i].ImageIndex].Bitmap.Assign(Bitmap);
   end;
   ListView.Refresh;
  end;
 end;
end;

procedure TSearchForm.BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
var
  SelectedVisible : boolean;
begin
 ListView.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 FPictureSize:=SizeX;
 LoadSizes();
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;

 ListView.Scrollbars.ReCalculateScrollbars(false,true);
 ListView.Groups.ReIndexItems;
 ListView.Groups.Rebuild(true);

 if SelectedVisible then
 ListView.Selection.First.MakeVisible(emvTop);
 ListView.EndUpdate();
end;

procedure TSearchForm.ListViewMouseWheel(Sender: TObject; Shift: TShiftState;
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
 NewFormState;
 //тут начинается загрузка больших картинок
 RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(True,self,StateID,nil,fPictureSize,Data));
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
 if Data.Count<>ListView.Items.Count then exit;
 rv :=  ListView.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView.Items.Count-1 do
 begin
  r:=Rect(ListView.ClientRect.Left+rv.Left,ListView.ClientRect.Top+rv.Top,ListView.ClientRect.Right+rv.Left,ListView.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView.Items[i].DisplayRect) then
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
 rv :=  ListView.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView.Items.Count-1 do
 begin
  r:=Rect(ListView.ClientRect.Left+rv.Left,ListView.ClientRect.Top+rv.Top,ListView.ClientRect.Right+rv.Left,ListView.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView.Items[i].DisplayRect) then
  begin
   if ListView.Items[i].Selected then
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
  Group : TGroupInfo;
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
   Group := TGroupInfo.Create;
   Group.Name := TEXT_MES_ALL_GROUPS;
   Data := Group;
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
  Group : TGroupInfo;
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
  if Integer(SearchRatingList[0]^)=RatingQuery.Rating then
    exit;
 end;
 text:=SearchEdit.Text;
 Deleted:=false;

 for i:=SearchTextList.Count-1 downto 1 do
 begin
  if SearchTextList[i]=SearchEdit.Text then
  if SearchGroupsList[i] = ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption then
  if Integer(SearchRatingList[i]^)=RatingQuery.Rating then
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
   Group := TGroupInfo.Create;
   Group.Name :=ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroupsItemIndex].Caption;
   Data:=Group;
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
 SearchRatingList.Insert(0,IntPointer(RatingQuery.Rating));

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
  GroupName:=TGroupInfo(SearchEdit.ItemsEx[SearchEdit.ItemIndex].Data).Name;
  for i:=0 to ComboBoxSearchGroups.Items.Count-1 do
  if ComboBoxSearchGroups.ItemsEx[i].Caption=GroupName then
  begin
   ComboBoxSearchGroups.ItemIndex := i;
   break;
  end;
 end;
 if SearchEdit.ShowDropDownMenu then
 RatingQuery.Rating:=Integer(SearchRatingList[SearchEdit.GetItemIndex]^);
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
  UseSmallIcons : Boolean;

  procedure AddIcon(Name : String);
  begin
    if UseSmallIcons then Name:=Name+'_SMALL';
    ImageList_ReplaceIcon(ToolBarImageList.Handle, -1, LoadIcon(DBKernel.IconDllInstance, PChar(Name)));
  end;

  procedure AddDisabledIcon(Name : String);
  var
    i : integer;
  begin
    if UseSmallIcons then Name:=Name+'_SMALL';
    for i := 1 to 9 do
    ImageList_ReplaceIcon(DisabledToolBarImageList.Handle, -1, LoadIcon(DBKernel.IconDllInstance, PChar(Name)));
  end;

begin
  UseSmallIcons := DBKernel.Readbool('Options', 'UseSmallToolBarButtons', False);
  ToolButton5.Visible:=true;

  if UseSmallIcons then
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
 tbStopOperation.ImageIndex:=8;

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
 ListView.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize>40 then FPictureSize:=FPictureSize-10;
 ListView.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView.CellSizes.Thumbnail.Height:=FPictureSize+36;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;
 ListView.Scrollbars.ReCalculateScrollbars(false,true);
 ListView.Groups.ReIndexItems;
 ListView.Groups.Rebuild(true);

 if SelectedVisible then
 ListView.Selection.First.MakeVisible(emvTop);
 ListView.EndUpdate();
end;

procedure TSearchForm.ZoomOut;
var
  SelectedVisible : boolean;
begin                 
 ListView.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize<550 then FPictureSize:=FPictureSize+10;
 ListView.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView.CellSizes.Thumbnail.Height:=FPictureSize+36;  
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;   
 ListView.Scrollbars.ReCalculateScrollbars(false,true);
 ListView.Groups.ReIndexItems;
 ListView.Groups.Rebuild(true);
 if SelectedVisible then
 ListView.Selection.First.MakeVisible(emvTop);
 ListView.EndUpdate();
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
 if ListView.Selection.Count=0 then
 begin
  NewExplorer;
 end else
 begin
  With ExplorerManager.NewExplorer(False) do
  begin
   FileName:=Data[GetItemNO(ListView.Selection.First)].FileName;
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
  RatingQuery.DoDrawImageByrating(HDC,SearchEdit.Width-18,Top,Integer(SearchRatingList[index]^));
 end;
end;

procedure TSearchForm.TbStopOperationClick(Sender: TObject);
begin
 if tbStopOperation.Enabled then
 begin                      
  tbStopOperation.Enabled:=false;
  BreakOperation(Sender);
  NewFormState;
 end;
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

 if ListView.Items.Count<2 then exit;
 ListView.Groups.BeginUpdate(false);

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
 l:=ListView.Items.Count;

 SetLength(SIs,L);
 SetLength(LI,L);

 for i:=0 to l-1 do
 begin
  LI[i].Caption:=ListView.Items[i].Caption;
  LI[i].Indent:=ListView.Items[i].Tag;
  LI[i].Data:=ListView.Items[i].Data;
  LI[i].ImageIndex:=ListView.Items[i].ImageIndex;
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
                       
 ListView.BeginUpdate;
 ListView.Items.Clear;

 ShowGroups:=DBKernel.Readbool('Options','UseGroupsInSearch',true);

 FLastSize:=0;
 FLastChar:=#0;
 FLastRating:=-1;
 FLastMonth:=0;
 FLastYear:=0;

 for i:=0 to L - 1 do
 begin
  AddItemInListViewByGroups(ListView,LI[SIs[i].ID].DBData.ID,SortLink.Tag,Decremect1.Checked,
  ShowGroups,LI[SIs[i].ID].DBData.FileSize,LI[SIs[i].ID].DBData.FileName,LI[SIs[i].ID].DBData.Rating,
  LI[SIs[i].ID].DBData.Date,LI[SIs[i].ID].DBData.Include,FLastSize,FLastChar,FLastRating,FLastMonth,FLastYear);
  ListView.Items[i].ImageIndex:=LI[SIs[i].ID].ImageIndex;
  ListView.Items[i].Data:=LI[SIs[i].ID].Data;
  Data[i]:=LI[SIs[i].ID].DBData;
 end;
 ListView.EndUpdate();
 except    
   on e : Exception do EventLog(':TSearchForm::SortingClick() throw exception: '+e.Message);
 end;
 ListView.Groups.EndUpdate;  
 ListView.Realign;
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
 s:=DBKernel.ReadString('Search_DB_'+DBKernel.GetDataBaseName,'OldValue') ;
 RatingQuery.Rating:=DBKernel.ReadInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMinRating',0);
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

end;

procedure TSearchForm.LoadQueryList;
var
  i, Rating, LastRating : integer;
  Group, Query : string;
begin
 CanSaveQueryList:=false;
 lastRating:=RatingQuery.Rating;
 for i:=9 downto 0 do
 begin                               
  if DBKernel.ReadBool('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Valid',false) then
  begin
   Group := DBKernel.ReadString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Group');
   Query:= DBKernel.ReadString('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Query');
   Rating:=DBKernel.ReadInteger('Search\DB_'+DBKernel.GetDataBaseName+'\Query'+IntToStr(i),'Rating',0);
   SearchEdit.Text:=Query;
   RatingQuery.Rating:=Rating;
   try
    AddNewSearchListEntry();
   except
    on e : Exception do EventLog(':TSearchForm::LoadQueryList()/AddNewSearchListEntry throw exception: '+e.Message);
   end;
  end;
 end;
 RatingQuery.Rating:=LastRating;
 SearchEdit.Text:='';
 CanSaveQueryList:=true;
end;

procedure TSearchForm.SaveQueryList;
var
  I, Rating : integer;
  BasePath, Group : string;
begin
  if not CanSaveQueryList then
    Exit;

  BasePath := 'Search\DB_'+DBKernel.GetDataBaseName+'\Query';
  for I := 0 to 9 do
  begin
    DBKernel.WriteBool(BasePath + IntToStr(I), 'Valid', False);
  end;
  
  for I := 0 to SearchEdit.ItemsEx.Count-1 do
  begin
    Group := ComboBoxSearchGroups.ItemsEx[ComboBoxSearchGroups.GetItemIndex].Caption;
    Rating := Integer(SearchRatingList[I]^);
    DBKernel.WriteBool(BasePath + IntToStr(I), 'Valid', True);
    DBKernel.WriteString(BasePath + IntToStr(I), 'Query', SearchTextList[I]);
    DBKernel.WriteString(BasePath + IntToStr(I), 'Group', Group);
    DBKernel.WriteInteger(BasePath + IntToStr(I), 'Rating', Rating);
  end;
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
  BackgroundImage : TPNGGraphic;
  SearchBackgroundBMP : TBitmap;
begin
  ListView.BackGround.Image := TBitmap.Create;
  ListView.BackGround.Image.PixelFormat := pf24bit;
  ListView.BackGround.Image.Width := 150;
  ListView.BackGround.Image.Height := 150;
  ListView.BackGround.Image.Canvas.Brush.Color := Theme_ListColor;
  ListView.BackGround.Image.Canvas.Pen.Color := Theme_ListColor;
  ListView.BackGround.Image.Canvas.Rectangle(0,0,150,150);
  BackgroundImage := GetSearchBackground;
  try
    SearchBackgroundBMP := TBitmap.Create;
    try
      LoadPNGImage32bit(BackgroundImage, SearchBackgroundBMP, Theme_ListColor);
      ListView.BackGround.Image.Canvas.Draw(0, 0, SearchBackgroundBMP);
    finally
      SearchBackgroundBMP.Free;
     end;
  finally
    BackgroundImage.Free;
  end;
end;

function TManagerSearchs.GetValueByIndex(Index: Integer): TSearchForm;
begin
  Result := FSearches[Index];
end;

{ TSearchInfo }

constructor TSearchInfo.Create;
begin
  FList := TList.Create;
end;

destructor TSearchInfo.Destroy;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TSearchQuery(FList[I]).Free;

  FList.Free;
  inherited;
end;

function TSearchInfo.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSearchInfo.GetValueByIndex(Index: Integer): TSearchQuery;
begin
  Result := FList[Index];
end;

procedure TSearchForm.LoadDateRange;
var
  DS : TDataSet;
  DateRangeBackgroundImage : TPNGGraphic;
  DateRangeBackgroundImageBMP : TBitmap;
begin
  if not elvDateRange.BackGround.Image.Empty then
    Exit;

  elvDateRange.BackGround.Enabled := True;
  elvDateRange.BackGround.Tile := False;
  elvDateRange.BackGround.AlphaBlend := True;
  elvDateRange.BackGround.OffsetTrack := True;
  elvDateRange.BackGround.BlendAlpha := 220;
  elvDateRange.BackGround.Image := TBitmap.Create;
  elvDateRange.BackGround.Image.PixelFormat := pf24bit;
  elvDateRange.BackGround.Image.Width := 100;
  elvDateRange.BackGround.Image.Height := 100;
  elvDateRange.BackGround.Image.Canvas.Brush.Color := Theme_ListColor;
  elvDateRange.BackGround.Image.Canvas.Pen.Color := Theme_ListColor;
  elvDateRange.BackGround.Image.Canvas.Rectangle(0, 0, 100, 100);

  DateRangeBackgroundImage := GetDateRangeImage;
  try
    DateRangeBackgroundImageBMP := TBitmap.Create;
    try
      LoadPNGImage32bit(DateRangeBackgroundImage, DateRangeBackgroundImageBMP, Theme_ListColor);
      elvDateRange.BackGround.Image.Canvas.Draw(0, 0, DateRangeBackgroundImageBMP);
    finally
      DateRangeBackgroundImageBMP.Free;
     end;
  finally
    DateRangeBackgroundImage.Free;
  end;
  elvDateRange.Refresh;

  DS := GetQuery(True);

  TADOQuery(DS).CursorType := ctOpenForwardOnly;
  TADOQuery(DS).CursorLocation := clUseClient;
  TADOQuery(DS).ExecuteOptions := [eoAsyncFetch, eoAsyncFetchNonBlocking];
  TADOQuery(DS).LockType := ltReadOnly;
  SetSQL(DS, 'Select distinct DateToAdd from ' + GetDefDBname + ' where IsDate = True order by DateToAdd DESC');
  TADOQuery(DS).OnFetchProgress := FetchProgress;

  TOpenQueryThread.Create(False, DS, DBRangeOpened);
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
  i : integer;
begin
 if not Item.Selected or ((elvDateRange.Selection.Count>1) and CtrlKeyDown) then
 begin
  if elvDateRange.Selection.First<>nil then
  begin
   for i:=0 to elvDateRange.Items.Count-1 do
   if elvDateRange.Items[i].Selected then
   elvDateRange.Items[i].Selected:=false;
  end
 end;
end;

function TSearchForm.DateRangeItemAtPos(X,Y : integer): TEasyItem;
var
  r : TRect;
  i : integer;
begin
 Result:=nil;
 r :=  elvDateRange.Scrollbars.ViewableViewportRect;
 for i:=0 to elvDateRange.Groups.Count-1 do
 begin
  Result:=elvDateRange.Groups[0].ItemByPoint(Point(r.left+x,r.top+y));
  if Result<>nil then exit;
 end;
end;

procedure TSearchForm.elvDateRangeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item : TEasyItem;
  i : integer;
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
  I : integer;
  Date : TDateTime;
  CurrentYear : integer;
  CurrentMonth : integer;
begin
  CurrentYear:=0;
  CurrentMonth:=0;

  elvDateRange.Header.Columns.Add.Width := 150;

  DS.First;
  while not DS.EOF do
  begin
    Application.ProcessMessages;
    Date := DS.FieldByName('DAteToAdd').AsDateTime;
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

    Date := DS.FieldByName('DateToAdd').AsDateTime;
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
  FreeDS(DS);
end;

procedure TSearchForm.elvDateRangeResize(Sender: TObject);
begin
  elvDateRange.BackGround.OffsetX := elvDateRange.Width - elvDateRange.BackGround.Image.Width;
  elvDateRange.BackGround.OffsetY := elvDateRange.Height - elvDateRange.BackGround.Image.Height;
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

initialization

SearchManager := TManagerSearchs.create;

finalization

SearchManager.free;

end.
