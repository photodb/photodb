unit SlideShow;

interface

uses
  Shellapi,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  Menus,
  Buttons,
  SaveWindowPos,
  DB,
  ComObj,
  ShlObj,
  AppEvnts,
  ImgList,
  UnitDBKernel,
  jpeg,
  Win32crc,
  CommCtrl,
  uMemoryEx,
  StdCtrls,
  math,
  ToolWin,
  ComCtrls,
  Tlayered_Bitmap,
  GraphicCrypt,
  FormManegerUnit,
  UnitUpdateDBThread,
  DBCMenu,
  dolphin_db,
  uSearchTypes,
  ShellContextMenu,
  DropSource,
  DropTarget,
  GIFImage,
  uFileUtils,
  Effects,
  GraphicsCool,
  UnitUpdateDBObject,
  DragDropFile,
  DragDrop,
  uVistaFuncs,
  UnitDBDeclare,
  UnitFileExistsThread,
  uBitmapUtils,
  uGUIDUtils,
  uCDMappingTypes,
  uDBForm,
  uThreadForm,
  uLogger,
  uConstants,
  uTime,
  uFastLoad,
  uResources,
  uW7TaskBar,
  uMemory,
  UnitBitmapImageList,
  uFaceDetection,
  uListViewUtils,
  uFormListView,
  uImageSource,
  uDBPopupMenuInfo,
  uGraphicUtils,
  uShellIntegration,
  uSysUtils,
  uDBUtils,
  uRuntime,
  CCR.Exif,
  uDBBaseTypes,
  uViewerTypes,
  uSettings,
  uAssociations,
  LoadingSign,
  uExifUtils,
  uInterfaces,
  WebLink,
  uPeopleSupport,
  u2DUtils,
  uVCLHelpers,
  uAnimatedJPEG,
  ExplorerTypes,
  uPathProviders,
  uPathProviderUtils,
  uPortableClasses,
  uPortableDeviceUtils,
  uPortableDeviceManager,
  uShellNamespaceUtils,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  uThemesUtils,
  Themes,
  uBaseWinControl;

type
  TViewer = class(TViewerForm, IImageSource, IFaceResultForm)
    PmMain: TPopupActionBar;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    FullScreen1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    N4: TMenuItem;
    MTimer1: TMenuItem;
    MouseTimer: TTimer;
    DBItem1: TMenuItem;
    AeMain: TApplicationEvents;
    AddToDB1: TMenuItem;
    Onlythisfile1: TMenuItem;
    AllFolder1: TMenuItem;
    GoToSearchWindow1: TMenuItem;
    Explorer1: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    SetasDesktopWallpaper1: TMenuItem;
    Copy1: TMenuItem;
    SbHorisontal: TScrollBar;
    SbVertical: TScrollBar;
    Panel1: TPanel;
    ImlToolBarNormal: TImageList;
    ImlToolBarHot: TImageList;
    ImlToolBarDisabled: TImageList;
    BottomImage: TPanel;
    TbrActions: TToolBar;
    TbBack: TToolButton;
    TbForward: TToolButton;
    TbSeparator1: TToolButton;
    TbFitToWindow: TToolButton;
    TbRealSize: TToolButton;
    TbSlideShow: TToolButton;
    TbSeparator2: TToolButton;
    TbZoomOut: TToolButton;
    TbZoomIn: TToolButton;
    Properties1: TMenuItem;
    Rotate1: TMenuItem;
    RotateCCW1: TMenuItem;
    RotateCW1: TMenuItem;
    Rotateon1801: TMenuItem;
    Center1: TMenuItem;
    Stretch1: TMenuItem;
    Tile1: TMenuItem;
    Resize1: TMenuItem;
    DropFileTarget1: TDropFileTarget;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    ImageFrameTimer: TTimer;
    SlideShow1: TMenuItem;
    SlideTimer: TTimer;
    TbFullScreen: TToolButton;
    TbSeparator3: TToolButton;
    TbRotateCCW: TToolButton;
    TbRotateCW: TToolButton;
    TbInfo: TToolButton;
    ImageEditor1: TMenuItem;
    TbEditImage: TToolButton;
    Print1: TMenuItem;
    TbSeparator4: TToolButton;
    TbPrint: TToolButton;
    TbSeparator7: TToolButton;
    TbSeparator5: TToolButton;
    TbDelete: TToolButton;
    TbSeparator6: TToolButton;
    TbRating: TToolButton;
    RatingPopupMenu: TPopupActionBar;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    SendTo1: TMenuItem;
    SendToSeparator: TMenuItem;
    TimerDBWork: TTimer;
    TbSeparatorPageNumber: TToolButton;
    TbPageNumber: TToolButton;
    PopupMenuPageSelecter: TPopupActionBar;
    LsLoading: TLoadingSign;
    TbEncrypt: TToolButton;
    N5: TMenuItem;
    ByEXIF1: TMenuItem;
    PmSteganography: TPopupActionBar;
    AddHiddenInfo1: TMenuItem;
    ExtractHiddenInfo1: TMenuItem;
    LsDetectingFaces: TLoadingSign;
    WlFaceCount: TWebLink;
    PmFaces: TPopupActionBar;
    MiFaceDetectionStatus: TMenuItem;
    MiDetectionMethod: TMenuItem;
    PmFace: TPopupActionBar;
    MiClearFaceZone: TMenuItem;
    MiClearFaceZoneSeparatpr: TMenuItem;
    MiCurrentPerson: TMenuItem;
    MiCurrentPersonSeparator: TMenuItem;
    MiPreviousSelections: TMenuItem;
    MiPreviousSelectionsSeparator: TMenuItem;
    MiCreatePerson: TMenuItem;
    MiOtherPersons: TMenuItem;
    MiFindPhotosSeparator: TMenuItem;
    MiFindPhotos: TMenuItem;
    N9: TMenuItem;
    MiRefreshFaces: TMenuItem;
    MiDrawFace: TMenuItem;
    N10: TMenuItem;
    ImFacePopup: TImageList;
    PmObject: TPopupActionBar;
    N12: TMenuItem;
    Createnote1: TMenuItem;
    TbConvert: TToolButton;
    TbExplore: TToolButton;
    procedure FormCreate(Sender: TObject);
    function LoadImage_(Sender: TObject; FullImage: Boolean; BeginZoom: Extended; RealZoom: Boolean): Boolean;
    procedure RecreateDrawImage(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Next_(Sender: TObject);
    Procedure Previous_(Sender: TObject);
    procedure NextImageClick(Sender: TObject);
    procedure PreviousImageClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FullScreen1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure PmMainPopup(Sender: TObject);
    procedure MTimer1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer;
      params: TEventFields; Value: TEventValues);
    procedure LoadListImages(List: TstringList);
    Procedure ShowFile(FileName: String);
    Procedure ShowFolder(Files: Tstrings; CurrentN: Integer);
    function ShowFolderA(FileName: string; ShowPrivate: Boolean): Boolean;
    procedure UpdateRecord(FileNo: Integer);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure DoWaitToImage(Sender: TObject);
    procedure EndWaitToImage(Sender: TObject);
    procedure Onlythisfile1Click(Sender: TObject);
    procedure AllFolder1Click(Sender: TObject);
    procedure GoToSearchWindow1Click(Sender: TObject);
    procedure Explorer1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Copy1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SbHorisontalScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure RealSizeClick(Sender: TObject);
    procedure FitToWindowClick(Sender: TObject);
    procedure TbZoomOutClick(Sender: TObject);
    procedure TbZoomInClick(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure RotateCCW1Click(Sender: TObject);
    procedure RotateCW1Click(Sender: TObject);
    procedure Rotateon1801Click(Sender: TObject);
    procedure Stretch1Click(Sender: TObject);
    procedure Center1Click(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Resize1Click(Sender: TObject);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure ReloadCurrent;
    procedure Pause;
    procedure ImageFrameTimerTimer(Sender: TObject);
    procedure UpdateInfo(SID : TGUID; Info : TDBPopupMenuInfoRecord);
    procedure TbSlideShowClick(Sender: TObject);
    procedure SlideTimerTimer(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure TbDeleteClick(Sender: TObject);
    procedure TbRatingClick(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure AeMainHint(Sender: TObject);
    procedure UpdateInfoAboutFileName(FileName: string; Info: TDBPopupMenuInfoRecord);
    procedure SendTo1Click(Sender: TObject);
    procedure TimerDBWorkTimer(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure LsLoadingGetBackGround(Sender: TObject; X, Y, W, H: Integer; Bitmap: TBitmap);
    procedure TbEncryptClick(Sender: TObject);
    procedure ByEXIF1Click(Sender: TObject);
    procedure PmSteganographyPopup(Sender: TObject);
    procedure AddHiddenInfo1Click(Sender: TObject);
    procedure ExtractHiddenInfo1Click(Sender: TObject);
    procedure TbEncryptMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TbPageNumberClick(Sender: TObject);
    procedure WlFaceCountMouseEnter(Sender: TObject);
    procedure WlFaceCountMouseLeave(Sender: TObject);
    procedure WlFaceCountClick(Sender: TObject);
    procedure PmFacesPopup(Sender: TObject);
    procedure SelectCascade(Sender: TObject);
    procedure MiCreatePersonClick(Sender: TObject);
    procedure MiOtherPersonsClick(Sender: TObject);
    procedure PmFacePopup(Sender: TObject);
    procedure MiFindPhotosClick(Sender: TObject);
    procedure MiClearFaceZoneClick(Sender: TObject);
    procedure MiRefreshFacesClick(Sender: TObject);
    procedure MiFaceDetectionStatusClick(Sender: TObject);
    procedure MiCurrentPersonClick(Sender: TObject);
    procedure MiDrawFaceClick(Sender: TObject);
    procedure Createnote1Click(Sender: TObject);
    procedure TbExploreClick(Sender: TObject);
  private
    { Private declarations }
    WindowsMenuTickCount: Cardinal;
    FImageExists: Boolean;
    FStaticImage: Boolean;
    FLoading: Boolean;
    AnimatedImage: TGraphic;
    SlideNO: Integer;
    AnimatedBuffer: TBitmap;
    FOverlayBuffer: TBitmap;
    FValidImages: Integer;
    FForwardThreadExists: Boolean;
    FForwardThreadSID: TGUID;
    FForwardThreadNeeds: Boolean;
    FForwardThreadFileName: string;
    FTransparentImage: Boolean;
    FCurrentlyLoadedFile: String;
    FPlay: boolean;
    LockEventRotateFileList: TStrings;
    LastZValue: Extended;
    FCreating: Boolean;
    FW7TaskBar: ITaskbarList3;
    FProgressMessage: Cardinal;
    FIsWaiting: Boolean;
    FFaces: TFaceDetectionResult;
    FFaceDetectionComplete: Boolean;
    FHoverFace: TFaceDetectionResultItem;
    FDisplayAllFaces: Boolean;
    FDrawingFace: Boolean;
    FDrawFaceStartPoint: TPoint;
    FDrawFace: TFaceDetectionResultItem;
    FPersonMouseMoveLock: Boolean;
    FIsSelectingFace: Boolean;
    FIsClosing: Boolean;
    procedure SetImageExists(const Value: Boolean);
    procedure SetPropStaticImage(const Value: Boolean);
    procedure SetLoading(const Value: Boolean);
    procedure SetValidImages(const Value: Integer);
    procedure SetForwardThreadExists(const Value: Boolean);
    procedure SetForwardThreadSID(const Value: TGUID);
    procedure SetForwardThreadNeeds(const Value: Boolean);
    procedure SetForwardThreadFileName(const Value: string);
    procedure SetTransparentImage(const Value: Boolean);
    procedure SetCurrentlyLoadedFile(const Value: String);
    procedure SetPlay(const Value: boolean);
    procedure SendToItemPopUpMenu(Sender: TObject);
    procedure OnPageSelecterClick(Sender: TObject);
    procedure SelectPreviousPerson(Sender: TObject);
    procedure SetDisplayRating(const Value: Integer);
    procedure UpdateCrypted;
    procedure SelectPerson(P: TPerson);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    function GetFormID: string; override;
    procedure ApplyStyle; override;
    function GetItem: TDBPopupMenuInfoRecord; override;
    procedure RefreshFaces;
    procedure RefreshFaceDetestionState;
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
    function GetImageRect: TRect;
    function GetVisibleImageWidth: Integer;
    function GetVisibleImageHeight: Integer;
    function BufferPointToImagePoint(P: TPoint): TPoint;
    function ImagePointToBufferPoint(P: TPoint): Tpoint;
    function Buffer: TBitmap;
  public
    { Public declarations }
    CurrentInfo: TDBPopupMenuInfo;
    ZoomerOn: Boolean;
    Zoom: Real;
    WaitingList: Boolean;
    FCurrentPage: Integer;
    FPageCount: Integer;
    CursorZoomIn, CursorZoomOut: HIcon;
    DBCanDrag: Boolean;
    DBDragPoint: TPoint;
    FOldPoint: TPoint;
    WaitGrayScale: Integer;
    FSID: TGUID;
    RealImageWidth: Integer;
    RealImageHeight: Integer;
    RealZoomInc: Extended;
    DrawImage: TBitmap;
    FBImage: TBitmap;
    constructor Create(AOwner: TComponent); override;
    function GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
    procedure ExecuteDirectoryWithFileOnThread(FileName: string);
    function Execute(Sender: TObject; Info: TDBPopupMenuInfo): Boolean;
    function ExecuteW(Sender: TObject; Info: TDBPopupMenuInfo; LoadBaseFile: string): Boolean;
    procedure LoadLanguage;
    procedure LoadPopupMenuLanguage;
    procedure ReAllignScrolls(IsCenter: Boolean; CenterPoint: TPoint);
    function HeightW: Integer;
    function GetImageRectA: TRect;
    procedure RecreateImLists;
    function GetSID : TGUID;
    procedure SetStaticImage(Image: TBitmap; Transparent: Boolean);
    procedure SetAnimatedImage(Image: TGraphic);
    procedure NextSlide;
    function GetFirstImageNO: Integer;
    function GetNextImageNO: Integer;
    function GetPreviousImageNOX(NO: Integer): Integer;
    function GetNextImageNOX(NO: Integer): Integer;
    procedure LoadingFailed(FileName: string);
    function GetPreviousImageNO: Integer;
    procedure PrepareNextImage;
    procedure SetFullImageState(State: Boolean; BeginZoom: Extended; Pages, Page: Integer);
    procedure DoUpdateRecordWithDataSet(FileName: string; DS: TDataSet);
    procedure DoSetNoDBRecord(Info: TDBPopupMenuInfoRecord);
    procedure MakePagesLinks;
    procedure SetProgressPosition(Position, Max: Integer);
    function GetPageCaption: string;
    procedure ClearFaces;
    procedure UpdateFaceDetectionState;
    procedure CheckFaceIndicatorVisibility;
    procedure UpdateCursor;
    property DisplayRating: Integer write SetDisplayRating;
    procedure FinishDetectionFaces;
  published
    property ImageExists: Boolean read FImageExists write SetImageExists;
    property StaticImage: Boolean read FStaticImage write SetPropStaticImage;
    property Loading: Boolean read FLoading write SetLoading;
    property ValidImages: Integer read FValidImages write SetValidImages;
    property ForwardThreadExists: Boolean read FForwardThreadExists write SetForwardThreadExists;
    property ForwardThreadSID: TGUID read FForwardThreadSID write SetForwardThreadSID;
    property ForwardThreadNeeds: Boolean read FForwardThreadNeeds write SetForwardThreadNeeds;
    property ForwardThreadFileName: string read FForwardThreadFileName write SetForwardThreadFileName;
    property TransparentImage: Boolean read FTransparentImage write SetTransparentImage;
    property CurrentlyLoadedFile: string read FCurrentlyLoadedFile write SetCurrentlyLoadedFile;
    property Play: Boolean read FPlay write SetPlay;
    property Item: TDBPopupMenuInfoRecord read GetItem;
  end;

var
  Viewer: TViewer;

const
  CursorZoomInNo = 130;
  CursorZoomOutNo = 131;

implementation

uses
  UnitUpdateDB, PropertyForm, SlideShowFullScreen, uFormSelectPerson,
  uManagerExplorer, FloatPanelFullScreen, UnitSizeResizerForm, uFormAddImage,
  DX_Alpha, UnitViewerThread, ImEditor, PrintMainForm, UnitFormCont,
  UnitLoadFilesToPanel, CommonDBSupport, UnitSlideShowScanDirectoryThread,
  UnitSlideShowUpdateInfoThread, UnitCryptImageForm, uFormSteganography,
  uFormCreatePerson, uFaceDetectionThread, uFormEditObject;

{$R *.dfm}

function PxMultiply(R: TPoint; OriginalSize: TSize; Image: TBitmap): TPoint; overload;
begin
  Result := R;
  if (OriginalSize.cx <> 0) and (OriginalSize.cy <> 0) then
  begin
    Result.X := Round(R.X * Image.Width / OriginalSize.cx);
    Result.Y := Round(R.Y * Image.Height / OriginalSize.cy);
  end;
end;

function PxMultiply(R: TPoint; Image: TBitmap; OriginalSize: TSize): TPoint; overload;
begin
  Result := R;
  if (Image.Width <> 0) and (Image.Height <> 0) then
  begin
    Result.X := Round(R.X * OriginalSize.cx / Image.Width);
    Result.Y := Round(R.Y * OriginalSize.cy / Image.Height);
  end;
end;

procedure TViewer.FormCreate(Sender: TObject);
begin
  RegisterMainForm(Viewer);
  FIsClosing := False;
  TLoad.Instance.StartPersonsThread;
  TW.I.Start('TViewer.FormCreate');
  FDrawingFace := False;
  FPersonMouseMoveLock := False;
  FIsSelectingFace := False;
  FCreating := True;
  LsLoading.Active := True;
  CurrentInfo := TDBPopupMenuInfo.Create;
  FCurrentPage := 0;
  FPageCount := 1;
  WaitingList := False;
  LastZValue := 1;
  FDrawFace := nil;
  LockEventRotateFileList := TStringList.Create;
  RatingPopupMenu.Images := DBKernel.ImageList;
  N01.ImageIndex := DB_IC_DELETE_INFO;
  N11.ImageIndex := DB_IC_RATING_1;
  N21.ImageIndex := DB_IC_RATING_2;
  N31.ImageIndex := DB_IC_RATING_3;
  N41.ImageIndex := DB_IC_RATING_4;
  N51.ImageIndex := DB_IC_RATING_5;
  FPlay := False;
  FCurrentlyLoadedFile := '';
  TransparentImage := False;
  ForwardThreadFileName := '';
  ForwardThreadNeeds := False;
  ForwardThreadExists := False;
  SlideTimer.Enabled := False;
  AnimatedImage := nil;
  FLoading := True;
  FImageExists := False;
  DoubleBuffered := True;
  DBCanDrag := False;
  DropFileTarget1.Register(Self);
  SlideTimer.Interval := Math.Min(Math.Max(Settings.ReadInteger('Options', 'FullScreen_SlideDelay', 40), 1), 100) * 100;
  FullScreenNow := False;
  SlideShowNow := False;
  Drawimage := TBitmap.Create;
  FbImage := TBitmap.Create;
  FOverlayBuffer := TBitmap.Create;
  FbImage.PixelFormat := pf24bit;
  DrawImage.PixelFormat := pf24bit;

  LsDetectingFaces.Color := Theme.PanelColor;

  TW.I.Start('AnimatedBuffer');
  AnimatedBuffer := TBitmap.Create;
  AnimatedBuffer.PixelFormat := pf24bit;

  FFaces := TFaceDetectionResult.Create;
  FFaceDetectionComplete := False;
  FHoverFace := nil;
  FDisplayAllFaces := False;
  WlFaceCount.ImageList := DBkernel.ImageList;

  MTimer1.Caption := L('Stop timer');
  MTimer1.ImageIndex := DB_IC_PAUSE;

  SaveWindowPos1.Key := RegRoot + 'SlideShow';
  SaveWindowPos1.SetPosition;
  PmMain.Images := DBKernel.ImageList;
  Exit1.ImageIndex := DB_IC_EXIT;
  FullScreen1.ImageIndex := DB_IC_DESKTOP;
  Next1.ImageIndex := DB_IC_NEXT;
  Previous1.ImageIndex := DB_IC_PREVIOUS;
  DBItem1.ImageIndex := DB_IC_NOTES;
  AddtoDB1.ImageIndex := DB_IC_NEW;
  Copy1.ImageIndex := DB_IC_COPY;
  Onlythisfile1.ImageIndex := DB_IC_ADD_SINGLE_FILE;
  AllFolder1.ImageIndex := DB_IC_ADD_FOLDER;
  GoToSearchWindow1.ImageIndex := DB_IC_ADDTODB;
  Explorer1.ImageIndex := DB_IC_FOLDER;
  SetasDesktopWallpaper1.ImageIndex := DB_IC_WALLPAPER;
  Properties1.ImageIndex := DB_IC_PROPERTIES;
  Stretch1.ImageIndex := DB_IC_WALLPAPER;
  Center1.ImageIndex := DB_IC_WALLPAPER;
  Tile1.ImageIndex := DB_IC_WALLPAPER;
  RotateCCW1.ImageIndex := DB_IC_ROTETED_270;
  RotateCW1.ImageIndex := DB_IC_ROTETED_90;
  Rotateon1801.ImageIndex := DB_IC_ROTETED_180;
  Rotate1.ImageIndex := DB_IC_ROTETED_0;
  ByEXIF1.ImageIndex := DB_IC_ROTATE_MAGIC;
  Resize1.ImageIndex := DB_IC_RESIZE;
  SlideShow1.ImageIndex := DB_IC_DO_SLIDE_SHOW;
  ImageEditor1.ImageIndex := DB_IC_IMEDITOR;
  Print1.ImageIndex := DB_IC_PRINTER;
  SendTo1.ImageIndex := DB_IC_SEND;
  PmSteganography.Images := DBKernel.ImageList;
  AddHiddenInfo1.ImageIndex := DB_IC_STENO;
  ExtractHiddenInfo1.ImageIndex := DB_IC_DESTENO;

  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  TW.I.Start('LoadLanguage');
  LoadLanguage;

  WlFaceCount.Visible := FaceDetectionManager.IsActive;
  LsDetectingFaces.Visible := FaceDetectionManager.IsActive;

  TW.I.Start('LoadCursor');
  CursorZoomIn := LoadCursor(HInstance,'ZOOMIN');
  CursorZoomOut := LoadCursor(HInstance,'ZOOMOUT');
  Screen.Cursors[CursorZoomInNo]  := CursorZoomIn;
  Screen.Cursors[CursorZoomOutNo] := CursorZoomOut;
  TW.I.Start('MakePagesLinks');
  MakePagesLinks;
  FCreating := False;
  TW.I.Start('RecreateImLists - END');
  FProgressMessage := RegisterWindowMessage('SLIDE_SHOW_PROGRESS');
  PostMessage(Handle, FProgressMessage, 0, 0);
end;

function TViewer.LoadImage_(Sender: TObject; FullImage: Boolean; BeginZoom: Extended;
  RealZoom: Boolean): Boolean;
var
  NeedsUpdating: Boolean;
begin
  Result := False;

  if (not Item.InfoLoaded) and (Item.ID = 0) then
    NeedsUpdating := True
  else
    NeedsUpdating := False;

  Caption := Format(L('View') + ' - %s   [%d/%d]', [ExtractFileName(Item.FileName), CurrentFileNumber + 1,
    CurrentInfo.Count]);

  DisplayRating := Item.Rating;
  TbRotateCCW.Enabled := not IsDevicePath(Item.FileName);
  TbRotateCW.Enabled := not IsDevicePath(Item.FileName);
  UpdateCrypted;

  FSID := GetGUID;
  if not ForwardThreadExists or (ForwardThreadFileName <> Item.FileName) or (CurrentInfo.Count = 0)
    or FullImage then
  begin

    Result := True;
    if not RealZoom then
      TViewerThread.Create(Self, Item, FullImage, 1,         FSID, False, FCurrentPage)
    else
      TViewerThread.Create(Self, Item, FullImage, BeginZoom, FSID, False, FCurrentPage);

    ForwardThreadExists := False;

    if NeedsUpdating then
    begin
      DisplayRating := Item.Rating;
      TimerDBWork.Enabled := True;
      TbRotateCCW.Enabled := False;
      TbRotateCW.Enabled := False;
      UpdateCrypted;
      TSlideShowUpdateInfoThread.Create(Self, StateID, Item.FileName);
    end;

  end else
    ForwardThreadNeeds := True;

  SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
  InvalidateRect(Handle, ClientRect, False);
  DoWaitToImage(Sender);

  TW.I.Start('LoadImage_ - end');
end;

procedure TViewer.RecreateDrawImage(Sender: TObject);
var
  Fh, Fw: Integer;
  Zx, Zy, Zw, Zh, X1, X2, Y1, Y2: Integer;
  ImRect, BeginRect: TRect;
  Z: Real;
  FileName: string;
  TempImage, B: TBitmap;
  ACopyRect: TRect;

  procedure DrawRect(X1, Y1, X2, Y2: Integer);
  begin
    if TransparentImage then
    begin
      Drawimage.Canvas.Brush.Color := Theme.WindowColor;
      Drawimage.Canvas.Pen.Color := 0;
      Drawimage.Canvas.Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
    end;
  end;

  procedure ShowErrorText(FileName: string);
  var
    MessageText: string;
  begin
    if FileName <> '' then
    begin
      MessageText := L('Can''t display file') + ':';
      if not FullScreenNow then
        DrawImage.Canvas.Font.Color := Theme.WindowTextColor
      else
        DrawImage.Canvas.Font.Color := Theme.HighlightTextColor;

      DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(MessageText) div 2,
        DrawImage.Height div 2 - DrawImage.Canvas.Textheight(MessageText) div 2, MessageText);

      DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(FileName) div 2,
        DrawImage.Height div 2 - DrawImage.Canvas.TextHeight(FileName) div 2 + DrawImage.Canvas.TextHeight
          (FileName) + 4, FileName);
    end;
  end;

begin
  Z := 0;
  FileName := FCurrentlyLoadedFile;
  if FullScreenNow then
  begin
    DrawImage.Width := Monitor.Width;
    DrawImage.Height := Monitor.Height;
    DrawImage.Canvas.Brush.Color := 0;
    DrawImage.Canvas.Pen.Color := 0;
    DrawImage.Canvas.Rectangle(0, 0, DrawImage.Width, DrawImage.Height);
    if (FbImage.Height = 0) or (FbImage.Width = 0) then
      Exit;
    FW := FBImage.Width;
    FH := FBImage.Height;
    ProportionalSize(Monitor.Width, Monitor.Height, FW, FH);
    if ImageExists then
    begin
      if Settings.ReadboolW('Options','SlideShow_UseCoolStretch', True) then
      begin
        if ZoomerOn then
          Z := RealZoomInc * Zoom
        else
        begin
          if RealImageWidth * RealImageHeight <> 0 then
          begin
            if (Item.Rotation = DB_IMAGE_ROTATE_90) or
              (Item.Rotation = DB_IMAGE_ROTATE_270) then
              Z := Min(FW / RealImageHeight, FH / RealImageWidth)
            else
              Z := Min(FW / RealImageWidth, FH / RealImageHeight);
          end else
            Z := 1;
        end;
        if (Z < ZoomSmoothMin) then
          StretchCool(Monitor.Width div 2 - FW div 2, Monitor.Height div 2 - FH div 2, FW, FH, FBImage, DrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := pf24bit;
            TempImage.Width := FW;
            TempImage.Height := FH;
            SmoothResize(Fw, Fh, FbImage, TempImage);
            DrawImage.Canvas.Draw(Monitor.Width div 2 - FW div 2, Monitor.Height div 2 - FH div 2, TempImage);
          finally
            F(TempImage);
          end;
        end;
      end else
      begin
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.StretchDraw(Rect(Monitor.Width div 2 - Fw div 2, Monitor.Height div 2 - Fh div 2,
            Monitor.Width div 2 - Fw div 2 + Fw, Monitor.Height div 2 - Fh div 2 + Fh), FBImage);
      end;
    end else
      ShowErrorText(FileName);

    if FullScreenView <> nil then
      FullScreenView.Canvas.Draw(0, 0, DrawImage);
    Exit;
  end;
  DrawImage.Width := Clientwidth;
  DrawImage.Height := HeightW;
  DrawImage.Canvas.Brush.Color := Theme.WindowColor;
  DrawImage.Canvas.Pen.Color := Theme.WindowColor;
  DrawImage.Canvas.Rectangle(0, 0, DrawImage.Width, DrawImage.Height);
  if (FbImage.Height = 0) or (FbImage.Width = 0) then
    begin
      ShowErrorText(FileName);
      Refresh;
      Exit;
    end;
  if (FbImage.Width > ClientWidth) or (FbImage.Height > HeightW) then
  begin
    if FbImage.Width / FbImage.Height < DrawImage.Width / DrawImage.Height then
    begin
      Fh := DrawImage.Height;
      Fw := Round(Drawimage.Height * (FbImage.Width / FbImage.Height));
    end else
    begin
      Fw := DrawImage.Width;
      Fh := Round(DrawImage.Width * (FbImage.Height / FbImage.Width));
    end;
  end else
  begin
    Fh := FbImage.Height;
    Fw := FbImage.Width;
  end;
  X1 := ClientWidth div 2 - Fw div 2;
  Y1 := (HeightW) div 2 - Fh div 2;
  X2 := X1 + Fw;
  Y2 := Y1 + Fh;
  ImRect := GetImageRectA;
  Zx := ImRect.Left;
  Zy := ImRect.Top;
  Zw := ImRect.Right - ImRect.Left;
  Zh := ImRect.Bottom - ImRect.Top;
  if ImageExists or Loading then
  begin
    if Settings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True) then
    begin
      if ZoomerOn and not FIsWaiting then
      begin
        DrawRect(ImRect.Left, ImRect.Top, ImRect.Right, ImRect.Bottom);
        if Zoom <= 1 then
        begin
          if (Zoom < ZoomSmoothMin) then
            StretchCoolW(Zx, Zy, Zw, Zh, Rect(Round(SbHorisontal.Position / Zoom), Round(SbVertical.Position / Zoom),
                Round((SbHorisontal.Position + Zw) / Zoom), Round((SbVertical.Position + Zh) / Zoom)), FbImage, DrawImage)
          else
          begin
            ACopyRect := Rect(Round(SbHorisontal.Position / Zoom), Round(SbVertical.Position / Zoom),
              Round((SbHorisontal.Position + Zw) / Zoom), Round((SbVertical.Position + Zh) / Zoom));
            TempImage := TBitmap.Create;
            try
              TempImage.PixelFormat := Pf24bit;
              TempImage.Width := Zw;
              TempImage.Height := Zh;
              B := TBitmap.Create;
              try
                B.PixelFormat := Pf24bit;
                B.Width := (ACopyRect.Right - ACopyRect.Left);
                B.Height := (ACopyRect.Bottom - ACopyRect.Top);
                B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), FBImage.Canvas, ACopyRect);
                SmoothResize(Zw, Zh, B, TempImage);
              finally
                F(B);
              end;
              DrawImage.Canvas.Draw(Zx, Zy, TempImage);
            finally
              F(TempImage);
            end;
          end;
        end else
          Interpolate(Zx, Zy, Zw, Zh, Rect(Round(SbHorisontal.Position / Zoom), Round(SbVertical.Position / Zoom),
              Round((SbHorisontal.Position + Zw) / Zoom), Round((SbVertical.Position + Zh) / Zoom)), FbImage, DrawImage);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        if ZoomerOn then
          Z := RealZoomInc * Zoom
        else
        begin
          if RealImageWidth * RealImageHeight <> 0 then
          begin
            if (Item.Rotation = DB_IMAGE_ROTATE_90) or
              (Item.Rotation = DB_IMAGE_ROTATE_270) then
              Z := Min(Fw / RealImageHeight, Fh / RealImageWidth)
            else
              Z := Min(Fw / RealImageWidth, Fh / RealImageHeight);
          end else
            Z := 1;
        end;
        if (Z < ZoomSmoothMin) then
          StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FbImage, DrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := Pf24bit;
            TempImage.Width := X2 - X1;
            TempImage.Height := Y2 - Y1;
            SmoothResize(X2 - X1, Y2 - Y1, FbImage, TempImage);
            DrawImage.Canvas.Draw(X1, Y1, TempImage);
          finally
            F(TempImage);
          end;
        end;
      end;
    end else
    begin
      if ZoomerOn and not FIsWaiting then
      begin
        ImRect := Rect(Round(SbHorisontal.Position / Zoom), Round((SbVertical.Position) / Zoom),
          Round((SbHorisontal.Position + Zw) / Zoom), Round((SbVertical.Position + Zh) / Zoom));
        BeginRect := GetImageRectA;
        DrawRect(BeginRect.Left, BeginRect.Top, BeginRect.Right, BeginRect.Bottom);
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.CopyMode := SRCCOPY;
        DrawImage.Canvas.CopyRect(BeginRect, FbImage.Canvas, ImRect);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FBImage);
      end;
    end;
  end else
    ShowErrorText(FileName);

  if (not FIsWaiting) and (RealImageHeight * RealImageWidth <> 0) then
  begin
    if ZoomerOn then
      Z := RealZoomInc * Zoom
    else
    begin
      if (Item.Rotation = DB_IMAGE_ROTATE_90) or
        (Item.Rotation = DB_IMAGE_ROTATE_270) then
        Z := Min(Fw / RealImageHeight, Fh / RealImageWidth)
      else
        Z := Min(Fw / RealImageWidth, Fh / RealImageHeight);
    end;
    if WaitingList then
      Caption := Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d] - ' + L('Loading list of images') + '...',
        [ExtractFileName(Item.FileName), RealImageWidth, RealImageHeight,
        LastZValue * 100, CurrentFileNumber + 1, CurrentInfo.Count])
    else
      Caption := Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d]',
        [ExtractFileName(Item.FileName), RealImageWidth, RealImageHeight, Z * 100,
        CurrentFileNumber + 1, CurrentInfo.Count]) + GetPageCaption;
  end;
  LastZValue := Z;
  BeginScreenUpdate(Handle);
  try
    RefreshFaces;
  finally
    EndScreenUpdate(Handle, True);
  end;
end;

procedure TViewer.FormResize(Sender: TObject);
begin
  TW.I.Start('TViewer.FormResize');
  if FCreating or FIsClosing then
    Exit;
  DrawImage.Width := ClientWidth;
  DrawImage.Height := HeightW;
  if not FIsWaiting then
    ReAllignScrolls(False, Point(0, 0));
  TbrActions.Left := ClientWidth div 2 - TbrActions.Width div 2;
  BottomImage.Top := ClientHeight - TbrActions.Height;
  BottomImage.Width := ClientWidth;
  BottomImage.Height := TbrActions.Height;
  BottomImage.Show;

  LsLoading.Left := ClientWidth div 2 - LsLoading.Width div 2;
  LsLoading.Top := ClientHeight div 2 - LsLoading.Height div 2;

  RecreateDrawImage(Sender);
  TbrActions.Refresh;
  TbrActions.Realign;
  CheckFaceIndicatorVisibility;
  Repaint;
  TW.I.Start('TViewer.FormResize - end');
end;

procedure TViewer.Next_(Sender: TObject);
begin
  if CurrentInfo.Count < 2 then
    Exit;
  Inc(CurrentFileNumber);
  if CurrentFileNumber >= CurrentInfo.Count then
    CurrentFileNumber := 0;
  FCurrentPage := 0;
  if SlideShowNow then
    if Item.Crypted or ValidCryptGraphicFile(Item.FileName)  then
      if DBKernel.FindPasswordForCryptImageFile(Item.FileName) = '' then
        Exit;
  if not SlideShowNow then
    LoadImage_(Sender, False, Zoom, False)
end;

procedure TViewer.Previous_(Sender: TObject);
begin
  if CurrentInfo.Count < 2 then
    Exit;
  Dec(CurrentFileNumber);
  if CurrentFileNumber < 0 then
    CurrentFileNumber := CurrentInfo.Count - 1;
  FCurrentPage := 0;
  if not SlideShowNow then
    LoadImage_(Sender, False, Zoom, False);
end;

procedure TViewer.NextImageClick(Sender: TObject);
begin
  if not SlideShowNow then
  begin
    if FullScreenNow then
      if Play then
        SlideTimer.Restart;

    Next_(Sender);
  end else
  begin
    if DirectShowForm <> nil then
      DirectShowForm.Next;
  end;
end;

procedure TViewer.PreviousImageClick(Sender: TObject);
begin
  if not SlideShowNow then
  begin
    if FullScreenNow then
      if Play then
        SlideTimer.Restart;

    Previous_(Sender);
  end else
  begin
    if DirectShowForm <> nil then
      DirectShowForm.Previous;
  end;
end;

procedure TViewer.FormDestroy(Sender: TObject);
begin
  UnRegisterMainForm(Self);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);

  F(FDrawFace);
  F(FFaces);
  F(FOverlayBuffer);
  F(CurrentInfo);
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;
  F(FbImage);
  F(DrawImage);
  F(AnimatedBuffer);
  F(AnimatedImage);
  F(LockEventRotateFileList);
end;

procedure TViewer.SpeedButton5Click(Sender: TObject);
begin
  Close;
end;

procedure TViewer.FullScreen1Click(Sender: TObject);
begin
  if Loading then
    Exit;
  FullScreenNow := True;
  SlideTimer.Enabled := True;
  Play := True;
  LsLoading.Hide;
  RecreateDrawImage(Sender);
  if FullScreenView = nil then
    Application.CreateForm(TFullScreenView, FullScreenView);
  MTimer1.ImageIndex := DB_IC_PAUSE;
  MTimer1Click(Sender);
  FullScreenView.Show;
  Hide;
end;

procedure TViewer.Exit1Click(Sender: TObject);
begin
  if not FullScreenNow and not SlideShowNow then
  begin
    Close;
  end;
  if FullScreenNow then
  begin
    R(FloatPanel);
    FullScreenNow := False;
    RecreateDrawImage(Sender);
    SlideTimer.Enabled := False;
    Play := False;
    if FullScreenView <> nil then
      FullScreenView.Close;
    Show;
  end;
  if SlideShowNow then
  begin
    R(FloatPanel);
    SlideShowNow := False;
    Loading := True;
    ImageExists := False;
    LoadImage_(Sender, False, Zoom, False);
    if DirectShowForm <> nil then
      DirectShowForm.Close;
    Show;
  end;
end;

procedure TViewer.PaintBox1DblClick(Sender: TObject);
begin
  FullScreen1Click(Sender);
end;

procedure TViewer.FormPaint(Sender: TObject);
begin
  if SlideShowNow or FullScreenNow then
    Exit;

  Canvas.Draw(0, 0, Buffer);
end;

procedure TViewer.SelectCascade(Sender: TObject);
var
  FileName: string;
begin
  FileName := StringReplace(TMenuItem(Sender).Caption, '&', '', [RfReplaceAll]);
  Settings.WriteString('Face', 'DetectionMethod', FileName);
  ReloadCurrent;
end;

procedure TViewer.SelectPreviousPerson(Sender: TObject);
var
  P: TPerson;
  PersonID: Integer;
begin
  P := TPerson.Create;
  try
    PersonID := TMenuItem(Sender).Tag;
    PersonManager.FindPerson(PersonID, P);
    if not P.Empty then
      SelectPerson(P);
  finally
    F(P);
  end;
end;

procedure TViewer.PmFacePopup(Sender: TObject);
var
  I, LatestPersonsIndex: Integer;
  RI: TFaceDetectionResultItem;
  PA: TPersonArea;
  P: TPerson;
  SelectedPersons: TPersonCollection;
  LatestPersons: Boolean;
  MI: TMenuItem;
begin
  RI := TFaceDetectionResultItem(PmFace.Tag);
  PA := TPersonArea(RI.Data);

  ImFacePopup.Clear;
  ImageList_AddIcon(ImFacePopup.Handle, Icons[DB_IC_DELETE_INFO + 1]);
  ImageList_AddIcon(ImFacePopup.Handle, Icons[DB_IC_PEOPLE + 1]);
  ImageList_AddIcon(ImFacePopup.Handle, Icons[DB_IC_SEARCH + 1]);

  MiCurrentPerson.Visible := (RI.Data <> nil) and (PA.PersonID > 0);
  MiCurrentPersonSeparator.Visible := (RI.Data <> nil) and (PA.PersonID > 0);
  P := TPerson.Create;
  try
    if (PA <> nil) and (PA.PersonID > 0) then
    begin
      PersonManager.FindPerson(PA.PersonID, P);
      MiCreatePerson.Visible := P.Empty;
      if not P.Empty then
      begin
        MiFindPhotosSeparator.Visible := True;
        MiFindPhotos.Visible := True;
        MiCurrentPerson.ImageIndex := ImFacePopup.Add(P.CreatePreview(16, 16), nil);
        MiCurrentPerson.Caption := P.Name
      end else
        MiCurrentPerson.Caption := L('Unknown Person');
    end else
    begin
      MiCreatePerson.Visible := True;
      MiFindPhotosSeparator.Visible := False;
      MiFindPhotos.Visible := False;
    end;

    SelectedPersons := TPersonCollection.Create;
    try
      //remove last persons
      LatestPersons := False;
      LatestPersonsIndex := 0;
      for I := PmFace.Items.Count - 1 downto 0 do
      begin
        if PmFace.Items[I] = MiPreviousSelections then
        begin
          LatestPersons := False;
          LatestPersonsIndex := I;
        end;

        if LatestPersons then
          PmFace.Items.Remove(PmFace.Items[I]);

        if PmFace.Items[I] = MiPreviousSelectionsSeparator then
          LatestPersons := True;
      end;

      //add current persons
      PersonManager.FillLatestSelections(SelectedPersons);

      if not P.Empty then
        for I := 0 to SelectedPersons.Count - 1 do
        begin
          if SelectedPersons[I].ID = P.ID then
          begin
            SelectedPersons.DeleteAt(I);
            Break;
          end;
        end;

      for I := 0 to SelectedPersons.Count - 1 do
      begin
        MI := TMenuItem.Create(PmFace);
        MI.Tag := SelectedPersons[I].ID;
        MI.Caption := SelectedPersons[I].Name;
        MI.OnClick := SelectPreviousPerson;
        MI.ImageIndex := ImFacePopup.Add(SelectedPersons[I].CreatePreview(16, 16), nil);
        PmFace.Items.Insert(LatestPersonsIndex + 1, MI);
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
      FPersonMouseMoveLock := True;
    finally
      F(SelectedPersons);
    end;
  finally
    F(P);
  end;
end;

procedure TViewer.RefreshFaceDetestionState;
begin
  if Settings.ReadBool('FaceDetection', 'Enabled', True) then
    MiFaceDetectionStatus.Caption := L('Disable face detection')
  else
    MiFaceDetectionStatus.Caption := L('Enable face detection');
end;

procedure TViewer.PmFacesPopup(Sender: TObject);
var
  FileList: TStrings;
  I, Found: Integer;
  SearchRec: TSearchRec;
  Directory, DetectionMethod: string;
  MI: TMenuItem;
begin
  RefreshFaceDetestionState;

  MiDetectionMethod.Caption := L('Detection method');
  MiRefreshFaces.Caption := L('Refresh faces');

  DetectionMethod := Settings.ReadString('Face', 'DetectionMethod', DefaultCascadeFileName);
  FileList := TStringList.Create;
  try
    Directory := IncludeTrailingBackslash(ProgramDir) + CascadesDirectory;
    Found := FindFirst(Directory + '\*.xml', FaAnyFile, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          FileList.Add(Directory + '\' + SearchRec.Name);
        Found := SysUtils.FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;

    MiDetectionMethod.Clear;
    for I := 0 to FileList.Count - 1 do
    begin
      MI := TMenuItem.Create(PmFaces);
      MI.Caption := ExtractFileName(FileList[I]);
      MI.OnClick := SelectCascade;
      MI.ExSetDefault(MI.Caption = DetectionMethod);
      MiDetectionMethod.Add(MI);
    end;
  finally
    F(FileList);
  end;
end;

procedure TViewer.PmMainPopup(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
  I: Integer;

  procedure InitializeInfo;
  begin
    MenuRecord := CurrentInfo[CurrentFileNumber].Copy;
    MenuRecord.Selected := True;
    Info.Add(MenuRecord);
  end;

begin
  LoadPopupMenuLanguage;
  if CurrentInfo.Count = 0 then
    Exit;
  Info := TDBPopupMenuInfo.Create;
  try
    Info.IsPlusMenu := False;
    Info.IsListItem := False;
    for I := N2.MenuIndex + 1 to DBItem1.MenuIndex - 1 do
      PmMain.Items.Delete(N2.MenuIndex + 1);
    if Item.ID <> 0 then
    begin
      AddToDB1.Visible := False;
      DBItem1.Visible := True;
      DBItem1.Caption := Format(L('Collection Item [%d]'), [Item.ID]);
      InitializeInfo;
      TDBPopupMenu.Instance.AddDBContMenu(Self, DBItem1, Info);
    end else
    begin
      if Settings.ReadBool('Options', 'UseUserMenuForViewer', True) then
        if not(SlideShowNow or FullScreenNow) then
        begin
          InitializeInfo;
          TDBPopupMenu.Instance.SetInfo(Self, Info);
          TDBPopupMenu.Instance.AddUserMenu(PmMain.Items, True, N2.MenuIndex + 1);
        end;

      AddToDB1.Visible := not FolderView;
      DBItem1.Visible := False;
    end;
    FullScreen1.Visible := not(FullScreenNow or SlideShowNow);
    SlideShow1.Visible := not(FullScreenNow or SlideShowNow);
    begin
      AddToDB1.Visible := AddToDB1.Visible and not(SlideShowNow or FullScreenNow) and not Item.Crypted and not FolderView and not IsDevicePath(Item.FileName);
      DBItem1.Visible := not(SlideShowNow or FullScreenNow) and (Item.ID <> 0)  and not IsDevicePath(Item.FileName);
      SetasDesktopWallpaper1.Visible := not(SlideShowNow) and ImageExists and not Item.Crypted and IsWallpaper(Item.FileName) and not IsDevicePath(Item.FileName);
      Rotate1.Visible := not(SlideShowNow) and ImageExists  and not IsDevicePath(Item.FileName);
      Properties1.Visible := not(SlideShowNow or FullScreenNow);
      GoToSearchWindow1.Visible := not(SlideShowNow);
      Explorer1.Visible := not(SlideShowNow);
      Resize1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      Print1.Visible := not(SlideShowNow) and ImageExists;
      ImageEditor1.Visible := not(SlideShowNow) and ImageExists;
      SendTo1.Visible := not(SlideShowNow) and ImageExists and (Item.ID = 0);
    end;
  finally
    F(Info);
  end;
end;

procedure TViewer.PmSteganographyPopup(Sender: TObject);
begin
  AddHiddenInfo1.Caption := L('Hide data in image');
  ExtractHiddenInfo1.Caption := L('Extract hidden data');
  ExtractHiddenInfo1.Visible := ExtInMask('|PNG|BMP|JPG|JPEG|', GetExt(Item.FileName));
end;

procedure TViewer.MTimer1Click(Sender: TObject);
begin
  if not SlideShowNow then
  begin
    if MTimer1.ImageIndex = DB_IC_PAUSE then
    begin
      MTimer1.Caption := L('Start timer');
      MTimer1.ImageIndex := DB_IC_PLAY;
      if FloatPanel <> nil then
      begin
        FloatPanel.TbPlay.Down := False;
        FloatPanel.TbPause.Down := True;
      end;
      SlideTimer.Enabled := False;
      Play := False;
    end else
    begin
      MTimer1.Caption := L('Stop timer');
      MTimer1.ImageIndex := DB_IC_PAUSE;
      if FloatPanel <> nil then
      begin
        FloatPanel.TbPlay.Down := True;
        FloatPanel.TbPause.Down := False;
      end;
      SlideTimer.Enabled := True;
      Play := True;
    end;
  end else
  begin
    if MTimer1.ImageIndex = DB_IC_PAUSE then
    begin
      if DirectShowForm <> nil then
        DirectShowForm.Pause;
      MTimer1.Caption := L('Start timer');
      MTimer1.ImageIndex := DB_IC_PLAY;
      FloatPanel.TbPlay.Down := False;
      FloatPanel.TbPause.Down := True;
    end else
    begin
      if DirectShowForm <> nil then
        DirectShowForm.Play;
      MTimer1.Caption := L('Stop timer');
      MTimer1.ImageIndex := DB_IC_PAUSE;
      FloatPanel.TbPlay.Down := True;
      FloatPanel.TbPause.Down := False;
    end;
  end;
end;

procedure TViewer.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  StartPoint, P, DrawFaceEndPoint: TPoint;
  DragImage: TBitmap;
  W, H: Integer;
  FileName: string;
  I: Integer;
  OldHoverFace: TFaceDetectionResultItem;
  FaceRect: TRect;
begin
  StartPoint := Point(X, Y);

  if not FPersonMouseMoveLock then
  begin
    P := BufferPointToImagePoint(StartPoint);
    OldHoverFace := FHoverFace;
    FHoverFace := nil;

    for I := 0 to FFaces.Count - 1 do
      if PtInRect(NormalizeRect(FFaces[I].Rect), PxMultiply(P, FBImage, FFaces[I].ImageSize)) then
      begin
        FHoverFace := FFaces[I];
        Break;
      end;

    if OldHoverFace <> FHoverFace then
      RefreshFaces;

    if FDrawingFace then
    begin
      DrawFaceEndPoint := Point(P.X, P.Y);
      FaceRect := Rect(FDrawFaceStartPoint, DrawFaceEndPoint);
      FDrawFace.Rect := NormalizeRect(FaceRect);

      RefreshFaces;
      Exit;
    end;
  end;
  FPersonMouseMoveLock := False;

  if DBCanDrag then
  begin
    GetCursorPos(P);
    if (Abs(DBDragPoint.X - P.X) > 5) or (Abs(DBDragPoint.Y - P.Y) > 5) then
    begin
      DropFileSource1.Files.Clear;
      if CurrentInfo.Count > 0 then
      begin
        FileName := Item.FileName;
        DropFileSource1.Files.Add(FileName);
        DropFileSource1.ShowImage := FImageExists;
        W := FbImage.Width;
        H := FbImage.Height;
        ProportionalSize(ThImageSize, ThImageSize, W, H);

        DragImage := TBitmap.Create;
        try
          DoResize(W, H, FbImage, DragImage);
          CreateDragImage(DragImage, DragImageList, Font, ExtractFileName(FileName));
        finally
          F(DragImage);
        end;

        DropFileSource1.ImageIndex := 0;
        DropFileSource1.Execute;
        Invalidate;
      end;
      DBCanDrag := False;
    end;
  end;

  if (Abs(FOldPoint.X - X) < 5) and (Abs(FOldPoint.Y - Y) < 5) then
    Exit;

  FOldPoint := Point(X, Y);
end;

procedure TViewer.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  I: Integer;
begin
  if Viewer = nil then
    Exit;

  if SetNewIDFileData in Params then
  begin
    for I := 0 to CurrentInfo.Count - 1 do
      if AnsiLowerCase(CurrentInfo[I].FileName) = AnsiLowerCase(Value.name) then
      begin
        CurrentInfo[I].ID := ID;
        CurrentInfo[I].Date := Value.Date;
        CurrentInfo[I].Time := Value.Time;
        CurrentInfo[I].IsDate := True;
        CurrentInfo[I].IsTime := Value.IsTime;
        CurrentInfo[I].Rating := Value.Rating;
        CurrentInfo[I].Rotation := Value.Rotate;
        CurrentInfo[I].Comment := Value.Comment;
        CurrentInfo[I].KeyWords := Value.Comment;
        CurrentInfo[I].Links := Value.Links;
        CurrentInfo[I].Groups := Value.Groups;
        CurrentInfo[I].IsDate := True;
        CurrentInfo[I].IsTime := Value.IsTime;
        CurrentInfo[I].InfoLoaded := True;
        CurrentInfo[I].Crypted := Value.Crypt;
        CurrentInfo[I].Links := '';

        if I = CurrentFileNumber then
          DisplayRating := CurrentInfo[I].Rating;
        Break;
      end;
    Exit;
  end;


  if ID > 0 then
  begin
    for I := 0 to CurrentInfo.Count - 1 do
      if CurrentInfo[I].ID = ID then
      begin
        if EventID_Param_Private in Params then
          CurrentInfo[I].Access := Value.Access;
        if EventID_Param_IsDate in Params then
          CurrentInfo[I].IsDate := Value.IsDate;
        if EventID_Param_IsTime in Params then
          CurrentInfo[I].IsTime := Value.IsTime;
        if EventID_Param_Crypt in Params then
        begin
          CurrentInfo[I].Crypted := Value.Crypt;
          UpdateCrypted;
        end;
        if EventID_Param_Groups in Params then
          CurrentInfo[I].Groups := Value.Groups;
        if EventID_Param_Date in Params then
          CurrentInfo[I].Date := Value.Date;
        if EventID_Param_Time in Params then
          CurrentInfo[I].Time := Value.Time;
        if EventID_Param_Rating in Params then
        begin
          CurrentInfo[I].Rating := Value.Rating;
          if I = CurrentFileNumber then
            DisplayRating := CurrentInfo[I].Rating;
        end;
        if (EventID_Param_Rotate in Params) then
          CurrentInfo[I].Rotation := Value.Rotate;

        if EventID_Param_Name in Params then
          CurrentInfo[I].FileName := Value.name;
        if EventID_Param_KeyWords in Params then
          CurrentInfo[I].KeyWords := Value.KeyWords;
        if EventID_Param_Links in Params then
          CurrentInfo[I].Links := Value.Links;
        if EventID_Param_Comment in Params then
          CurrentInfo[I].Comment := Value.Comment;
        if EventID_Param_Delete in Params then
        begin
          CurrentInfo[I].InfoLoaded := True;
          CurrentInfo[I].ID := 0;
          if I = CurrentFileNumber then
            LoadImage_(Sender, False, Zoom, False);
          Exit;
        end;
      end;
  end else
  begin
    if EventID_Param_Crypt in Params then
    begin
      for I := 0 to CurrentInfo.Count - 1 do
        if AnsiLowerCase(CurrentInfo[I].FileName) = AnsiLowerCase(Value.NewName) then
        begin
          CurrentInfo[I].Crypted := Value.Crypt;
          UpdateCrypted;
        end;
    end;
  end;

  if [EventID_Param_Rotate, EventID_Param_Image, EventID_Param_Name] * Params <> [] then
  begin
    for I := 0 to LockEventRotateFileList.Count - 1 do
      if AnsiLowerCase(Value.Name) = LockEventRotateFileList[I] then
      begin
        LockEventRotateFileList.Delete(I);
        Exit;
      end;
  end;

  if (EventID_Param_Name in Params) then
  begin
    if Item.FileName = Value.Name then
    begin
      if Value.NewName <> '' then
        Item.FileName := Value.NewName;
      Item.InfoLoaded := False;
      LoadImage_(Sender, False, Zoom, False);
      Exit;
    end;

    if ID = -1 then
      for I := 0 to CurrentInfo.Count - 1 do
        if CurrentInfo[I].FileName = Value.NewName then
        begin
          CurrentInfo[I].InfoLoaded := False;
          if I = CurrentFileNumber then
            LoadImage_(Sender, False, Zoom, False);
          Exit;
        end;

  end;
  if CurrentInfo.Count - 1 < CurrentFileNumber then
    Exit;

  if Id = Item.ID then
  begin
    if (EventID_Param_Rotate in Params) then
      Item.Rotation := Value.Rotate;
    if (EventID_Param_Rotate in Params) or (EventID_Param_Image in Params) then
      LoadImage_(Sender, False, Zoom, False);
  end;
end;

procedure TViewer.ClearFaces;
var
  I: Integer;
begin
  for I := ControlCount - 1 downto 0 do
    if (Controls[I] is TLoadingSign) and (Controls[I] <> LsLoading) then
      TLoadingSign(Controls[I]).Free;
end;

procedure TViewer.LoadListImages(List: TStringList);
var
  I: Integer;
  FileName: string;
  FQuery: TDataSet;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  if List.Count = 0 then
    Exit;

  CurrentInfo.Clear;
  FQuery := GetQuery;
  try
    ReadOnlyQuery(FQuery);
    for I := 0 to List.Count - 1 do
    begin
      FileName := List[I];
      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName, True))
          + ' AND FFileName LIKE :FFileName');
      SetStrParam(FQuery, 0, NormalizeDBStringLike(AnsiLowerCase(FileName)));
      FQuery.Active := True;
      if FQuery.RecordCount <> 0 then
      begin
        FQuery.First;
        InfoItem := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
        CurrentInfo.Add(InfoItem);
      end else
      begin
        InfoItem := TDBPopupMenuInfoRecord.Create;
        InfoItem.FileName := FileName;
        InfoItem.Crypted := ValidCryptGraphicFile(FileName);
        InfoItem.InfoLoaded := True;
        CurrentInfo.Add(InfoItem);
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
  CurrentFileNumber := 0;
  LoadImage_(nil, False, Zoom, False);
  Show;
  SetFocus;
  if CurrentInfo.Count < 2 then
  begin
    TbBack.Enabled := False;
    TbForward.Enabled := False;
    SetProgressPosition(0, 0);
    if FloatPanel <> nil then
      FloatPanel.SetButtonsEnabled(False);
  end else
  begin
    SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
    TbBack.Enabled := True;
    TbForward.Enabled := True;
    if FloatPanel <> nil then
      FloatPanel.SetButtonsEnabled(True);
  end;
end;

procedure TViewer.LoadPopupMenuLanguage;
begin
  BeginTranslate;
  try
    Next1.Caption := L('Next');
    Previous1.Caption := L('Previous');
    MTimer1.Caption := L('Timer');
    Copy1.Caption := L('Copy');
    FullScreen1.Caption := L('Full screen');
    DBItem1.Caption := L('Collection item');
    AddToDB1.Caption := L('Add to collection');
    GoToSearchWindow1.Caption := L('Search photos');
    Explorer1.Caption := L('Explorer');
    Exit1.Caption := L('Exit');
    Onlythisfile1.Caption := L('Only this file');
    AllFolder1.Caption := L('Full directory with this file');
    Properties1.Caption := L('Properties');
    SetasDesktopWallpaper1.Caption := L('Set as desktop wallpaper');
    Stretch1.Caption := L('Stretch');
    Center1.Caption := L('Center');
    Tile1.Caption := L('Tile');
    Rotate1.Caption := L('Rotate image');
    RotateCCW1.Caption := L('Left');
    RotateCW1.Caption := L('Right');
    Rotateon1801.Caption := L('180 Degree');
    Resize1.Caption := L('Resize');
    SlideShow1.Caption := L('Slide show');
    ImageEditor1.Caption := L('Image editor');
    Print1.Caption := L('Print');
    SendTo1.Caption := L('Send to');
    ByEXIF1.Caption := L('By EXIF');
  finally
    EndTranslate;
  end;
end;

procedure TViewer.LsLoadingGetBackGround(Sender: TObject; X, Y, W, H: Integer;
  Bitmap: TBitmap);
begin
  if FCreating then
    Exit;
  if (Buffer = nil) or Buffer.Empty then
  begin
    Bitmap.Canvas.Pen.Color := Theme.WindowColor;
    Bitmap.Canvas.Brush.Color := Theme.WindowColor;
    Bitmap.Canvas.Rectangle(0, 0, W, H);
  end else
    Bitmap.Canvas.CopyRect(Rect(0, 0, W, H), Buffer.Canvas, Rect(X, Y, X + W, Y + H));
end;

procedure TViewer.ShowFile(FileName: String);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  Info:= TDBPopupMenuInfo.Create;
  try
    InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    InfoItem.Crypted := ValidCryptGraphicFile(FileName);
    Info.Add(InfoItem);
    Execute(nil, Info);
  finally
    F(Info);
  end;
end;

procedure TViewer.ShowFolder(Files: TStrings; CurrentN : integer);
var
  I: Integer;
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  Info:= TDBPopupMenuInfo.Create;
  try
    for I := 0 to Files.Count - 1 do
    begin
      InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(Files[I]);
      InfoItem.Crypted := ValidCryptGraphicFile(Files[I]);
      Info.Add(InfoItem);
    end;
    Info.Position := CurrentN;
    Execute(nil, Info);
  finally
    F(Info);
  end;
end;

procedure TViewer.UpdateRecord(FileNo: integer);
var
  DS: TDataSet;
  FileName: string;
begin
  DS := GetQuery;
  try
    ReadOnlyQuery(DS);
    FileName := CurrentInfo[FileNo].FileName;
    SetSQL(DS, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName, True))
        + ' AND FFileName LIKE :FFileName');
    SetStrParam(DS, 0, AnsiLowerCase(FileName));
    DS.Active := True;
    if DS.RecordCount = 0 then
      Exit;
    CurrentInfo[FileNo] := TDBPopupMenuInfoRecord.CreateFromDS(DS);
  finally
    FreeDS(DS);
  end;
end;

procedure TViewer.WlFaceCountClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PmFaces.Popup(P.X, P.Y);
end;

procedure TViewer.WlFaceCountMouseEnter(Sender: TObject);
begin
  FDisplayAllFaces := True;
  RefreshFaces;
end;

procedure TViewer.WlFaceCountMouseLeave(Sender: TObject);
begin
  FDisplayAllFaces := False;
  RefreshFaces;
end;

procedure TViewer.WndProc(var Message: TMessage);
var
  C: TColor;
  DC: HDC;
  BrushInfo: TagLOGBRUSH;
  Brush: HBrush;
  Top: Integer;
begin
  if (Message.Msg = WM_ERASEBKGND) and StyleServices.Enabled then
  begin
    Message.Result := 1;

    DC := TWMEraseBkgnd(Message).DC;
    if DC = 0 then
      Exit;

    C := Theme.WindowColor;
    brushInfo.lbStyle := BS_SOLID;
    brushInfo.lbColor := ColorToRGB(C);
    Brush := CreateBrushIndirect(brushInfo);

    Top := Height;
    if Buffer<> nil then
      Top := Buffer.Height;
    if SbHorisontal.Visible then
      Top := SbHorisontal.Top;

    FillRect(DC, Rect(0, Top, Width, Height), Brush);

    if(Brush > 0) then
      DeleteObject(Brush);

    Exit;
  end;

  inherited;

  if Message.Msg = WM_COMMAND then
  begin
    if Message.WParamLo = 40001 then
      Previous_(Self);

    if Message.WParamLo = 40002 then
      Next_(Self);
  end;
end;

procedure TViewer.AeMainMessage(var Msg: tagMSG;
  var Handled: Boolean);
var
  FButtons: array[0..1] of TThumbButton;
  P, PL: TPoint;
begin
  if Msg.message = FProgressMessage then
  begin
    FW7TaskBar := CreateTaskBarInstance;
    if FW7TaskBar <> nil then
    begin
      FButtons[0].iId := 40001;
      FButtons[0].dwFlags := THBF_ENABLED;
      FButtons[0].hIcon := LoadImage(HInstance, PChar('Z_PREVIOUS_NORM'), IMAGE_ICON, 16, 16, 0);
	      StringToWideChar(L('Previous'), FButtons[0].szTip, 260);
	    FButtons[0].dwMask := THB_ICON or THB_FLAGS or THB_TOOLTIP;

	    FButtons[1].iId := 40002;
	    FButtons[1].dwFlags := THBF_ENABLED;
	    FButtons[1].hIcon := LoadImage(HInstance, PChar('Z_NEXT_NORM'), IMAGE_ICON, 16, 16, 0);
	      StringToWideChar(L('Next'), FButtons[1].szTip, 260);
	    FButtons[1].dwMask := THB_ICON or THB_FLAGS or THB_TOOLTIP;
      FW7TaskBar.ThumbBarAddButtons(Handle, 2, @FButtons);

      SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
    end;
  end;

  if not Active or SlideShowNow or FullScreenNow then
    Exit;

  if Msg.message = WM_RBUTTONUP then
  begin
    GetCursorPos(P);
    PL := TbEncrypt.ScreenToClient(P);
    if PtInRect(TbEncrypt.ClientRect, PL) then
      PmSteganography.Popup(P.X, P.Y);
  end;

  if Msg.message = WM_KEYUP then
  begin
    if (Msg.WParam = VK_SHIFT) then
    begin
      RefreshFaces;
      UpdateCursor;
      Handled := True;
    end;
  end;

  if Msg.message = WM_KEYDOWN then
  begin
    WindowsMenuTickCount := GetTickCount;

    if Msg.WParam = VK_LEFT then
      PreviousImageClick(Self);

    if Msg.WParam = VK_RIGHT then
      NextImageClick(Self);

    if Msg.Hwnd = Handle then
      if Msg.WParam = VK_ESCAPE then
        Close;

    if (Msg.WParam = VK_DELETE) then
      TbDeleteClick(Self);

    if (Msg.WParam = VK_SHIFT) then
    begin
      RefreshFaces;
      UpdateCursor;
      Handled := True;
    end;

    if (Msg.wParam = Byte(' ')) then
      Next_(Self);

    if ShiftKeyDown then
    begin
      if Msg.wParam = Byte('R') then ByEXIF1Click(Self);
      if Msg.wParam = Byte('E') then ImageEditor1Click(Self);
    end else if CtrlKeyDown then
    begin
      if Msg.wParam = Byte('F') then FitToWindowClick(Self);
      if Msg.wParam = Byte('A') then RealSizeClick(Self);
      if Msg.wParam = Byte('S') then TbSlideShowClick(Self);
      if Msg.wParam = VK_RETURN then FullScreen1Click(Self);
      if Msg.wParam = Byte('I') then TbZoomOutClick(Self);
      if Msg.wParam = Byte('O') then TbZoomInClick(Self);
      if Msg.wParam = Byte('L') then RotateCCW1Click(Self);
      if Msg.wParam = Byte('R') then RotateCW1Click(Self);
      if Msg.wParam = Byte('D') then TbDeleteClick(Self);
      if Msg.wParam = Byte('P') then Print1Click(Self);
      if Msg.wParam = Byte('E') then TbExploreClick(Self);
      if Msg.wParam = Byte('Z') then Properties1Click(Self);
      if Msg.wParam = Byte('X') then TbEncryptClick(Self);
      if Msg.wParam = Byte('W') then Resize1Click(Self);
      if Msg.wParam = Byte('C') then Copy1Click(Self);

      if (Msg.wParam = Byte('0')) or (Msg.wParam = Byte(VK_NUMPAD0)) then N51Click(N01);
      if (Msg.wParam = Byte('1')) or (Msg.wParam = Byte(VK_NUMPAD1)) then N51Click(N11);
      if (Msg.wParam = Byte('2')) or (Msg.wParam = Byte(VK_NUMPAD2)) then N51Click(N21);
      if (Msg.wParam = Byte('3')) or (Msg.wParam = Byte(VK_NUMPAD3)) then N51Click(N31);
      if (Msg.wParam = Byte('4')) or (Msg.wParam = Byte(VK_NUMPAD4)) then N51Click(N41);
      if (Msg.wParam = Byte('5')) or (Msg.wParam = Byte(VK_NUMPAD5)) then N51Click(N51);
    end else
    begin
      if Msg.wParam = VK_RETURN then
      begin
        if WindowState = wsNormal then
          WindowState := wsMaximized
        else if WindowState = wsMaximized then
          WindowState := wsNormal;
      end;
    end;

    if CtrlKeyDown and ShiftKeyDown then
    begin
      if Msg.wParam = VK_OEM_PLUS then
        RotateCW1Click(Self);

      if Msg.wParam = VK_OEM_MINUS then
        RotateCCW1Click(Self);
    end;
    Msg.message := 0;
  end;

  if (Msg.message = WM_RBUTTONDOWN) or (Msg.message = WM_RBUTTONUP) then
    if (Msg.Hwnd = BottomImage.Handle) or (Msg.Hwnd = TbrActions.Handle) or (Msg.Hwnd = SbHorisontal.Handle) or
      (Msg.Hwnd = SbVertical.Handle) then
      Msg.message := 0;

  if (Msg.message = WM_MOUSEWHEEL) then
  begin
    if ZoomerOn or CtrlKeyDown or ShiftKeyDown then
    begin
      if NativeInt(Msg.WParam) > 0 then
        TbZoomOutClick(Self)
      else
        TbZoomInClick(Self);
      Msg.message := 0;
    end else
    begin
      if NativeInt(Msg.WParam) > 0 then
        Previous_(Self)
      else
        Next_(Self);
    end;
  end;
end;

function TViewer.ShowFolderA(FileName: string; ShowPrivate: Boolean): Boolean;
var
  N: Integer;
  Info: TDBPopupMenuInfo;
begin
  Result := False;
  if FileExistsSafe(FileName) or DirectoryExistsSafe(FileName) then
  begin
    FileName := LongFileName(FileName);
    Info := TDBPopupMenuInfo.Create;
    try
      GetFileListByMask(FileName, TFileAssociations.Instance.ExtensionList, Info, N, ShowPrivate);
      if Info.Count > 0 then
      begin
        Execute(Self, info);
        Result := True;
      end;
    finally
      F(Info);
    end;
  end;
end;

//TODO: remove ShowFolderA and use ExecuteDirectoryWithFileOnThread instead of
procedure TViewer.ExecuteDirectoryWithFileOnThread(FileName: String);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  NewFormState;
  WaitingList := True;
  TSlideShowScanDirectoryThread.Create(Self, StateID, FileName);

  Info := TDBPopupMenuInfo.Create;
  try
    InfoItem:= TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    InfoItem.Crypted := ValidCryptGraphicFile(FileName);
    Info.Add(InfoItem);
    ExecuteW(Self, Info, '');
    Caption := Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d] - ' + L('Loading list of images') + '...',
      [ExtractFileName(Item.FileName), RealImageWidth, RealImageHeight,
      LastZValue * 100, CurrentFileNumber + 1, CurrentInfo.Count]);
  finally
    F(Info);
  end;
end;

function TViewer.Execute(Sender: TObject; Info: TDBPopupMenuInfo) : boolean;
begin
  NewFormState;
  WaitingList := False;
  Result := ExecuteW(Sender, Info, '');
end;

function TViewer.ExecuteW(Sender: TObject; Info: TDBPopupMenuInfo; LoadBaseFile : String) : boolean;
var
  I: Integer;
  FOldImageExists, NotifyUser: Boolean;
  CurrentItem, DBItem: TDBPopupMenuInfoRecord;
begin
  TW.I.Start('ExecuteW');
  Result := True;
  SlideTimer.Enabled := False;
  Play := False;
  FullScreenNow := False;
  SlideShowNow := False;
  FOldImageExists := ImageExists;
  ImageExists := False;
  if LoadBaseFile = '' then
    ImageFrameTimer.Enabled := False;
  TW.I.Start('ToolButton1.Enabled');

  CurrentItem := nil;
  if LoadBaseFile <> '' then
    CurrentItem := Item.Copy;

  try
    CurrentInfo.Clear;
    for I := 0 to Info.Count - 1 do
    begin
      DBItem := Info[I];
      if DBItem.Selected then
      begin
        CurrentInfo.Add(DBItem.Copy);
        if DBItem.IsCurrent then
          CurrentInfo.Position := CurrentInfo.Count - 1;
      end;
    end;
    if CurrentInfo.Count < 2 then
      CurrentInfo.Assign(Info);

    if (CurrentItem <> nil) and (CurrentInfo.Count > 0)
      and (CurrentInfo[CurrentInfo.Position].ID = 0) then
        CurrentInfo[CurrentInfo.Position].Assign(CurrentItem);
  finally
    F(CurrentItem);
  end;

  SetProgressPosition(Info.Position + 1, Info.Count);
  if Info.Count = 0 then
  begin
    TbBack.Enabled := False;
    TbForward.Enabled := False;
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
  end else
  begin
    TbBack.Enabled := True;
    TbForward.Enabled := True;
    TbFitToWindow.Enabled := True;
    TbRealSize.Enabled := True;
    TbSlideShow.Enabled := True;
    TbZoomOut.Enabled := True;
    TbZoomIn.Enabled := True;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
  end;

  TW.I.Start('DoProcessPath');

  for I := 0 to CurrentInfo.Count - 1 do
  begin
    NotifyUser := False;
    if I = CurrentInfo.Position then
      NotifyUser := CurrentInfo.Position < CurrentInfo.Count;

    CurrentInfo[I].FileName := ProcessPath(CurrentInfo[I].FileName, NotifyUser);
  end;

  begin
    if CurrentInfo.Count = 0 then
      Exit;
    if not FullScreenNow then
      if FullScreenView <> nil then
        FullScreenView.Close;
    if not SlideShowNow then
      if DirectShowForm <> nil then
        DirectShowForm.Close;

    CurrentFileNumber := CurrentInfo.Position;
    if not ((LoadBaseFile <> '') and (AnsiLowerCase(Item.FileName) = AnsiLowerCase(LoadBaseFile))) then
    begin
      Loading := True;
      TW.I.Start('LoadImage_');

      LoadImage_(Sender, False, Zoom, False);
    end else
    begin
      Caption := Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d]',
        [ExtractFileName(Item.FileName), RealImageWidth, RealImageHeight,
        LastZValue * 100, CurrentFileNumber + 1, CurrentInfo.Count]) + GetPageCaption;
      DisplayRating := Item.Rating;
      FImageExists := FOldImageExists;
      TbRotateCW.Enabled := TbRotateCCW.Enabled;
    end;
  end;

  if CurrentInfo.Count < 2 then
  begin
    TbBack.Enabled := False;
    TbForward.Enabled := False;
    SetProgressPosition(0, 0);
    if FloatPanel <> nil then
      FloatPanel.SetButtonsEnabled(False);

  end else
  begin
    TbBack.Enabled := True;
    TbForward.Enabled := True;
    SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
    if FloatPanel <> nil then
      FloatPanel.SetButtonsEnabled(True);
  end;
  TW.I.Start('ExecuteW - end');
end;

constructor TViewer.Create(AOwner: TComponent);
begin
  inherited;
  ZoomerOn := False;
  Zoom := 1;
  FIsWaiting := False;
  RealZoomInc := 1;
end;

procedure TViewer.Createnote1Click(Sender: TObject);
//var
//  Area: TFaceDetectionResultItem;
 // O: TImageObject;
begin
//  Area := TFaceDetectionResultItem(PmFace.Tag);

//  O := nil;
  try
//    CreateObject(Item.ID, Area, O);
    RefreshFaces;
  finally
 //   F(O);
  end;
end;

procedure TViewer.CreateParams(var Params: TCreateParams);
begin
  TW.I.Start('CreateParams');
  Inherited CreateParams(Params);
  TW.I.Start('GetDesktopWindow');
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;

  //Windows explorer window class - EEePc touch pad support
  Params.WinClassName := 'AVL_AVView';
  TW.I.Start('CreateParams - END');
end;

procedure TViewer.MiClearFaceZoneClick(Sender: TObject);
var
  FR: TFaceDetectionResultItem;
  FA: TPersonArea;
begin
  FHoverFace := nil;

  FR := TFaceDetectionResultItem(PmFace.Tag);
  if FR.Data <> nil then
  begin
    FA := TPersonArea(FR.Data);
    PersonManager.RemovePersonFromPhoto(Item.ID, FA);
  end;
  FFaces.RemoveFaceResult(FR);
  UpdateFaceDetectionState;
  RefreshFaces;
end;

procedure TViewer.MiCreatePersonClick(Sender: TObject);
var
  Face, TmpFace: TFaceDetectionResultItem;
  R, FaceRect: TRect;
  P1, P2: TPoint;
  BmpFace3X: TBitmap;
  P: TPerson;
  W, H: Integer;
begin
  Face := TFaceDetectionResultItem(PmFace.Tag);
  R := Face.Rect;
  P1 := R.TopLeft;
  P2 := R.BottomRight;
  P1 := PxMultiply(P1, Face.ImageSize, FBImage);
  P2 := PxMultiply(P2, Face.ImageSize, FBImage);

  R := Rect(P1, P2);
  W := RectWidth(R);
  H := RectHeight(R);
  InflateRect(R, W, H);
  FaceRect := Rect(W, H, 2 * W, 2 * H);

  if R.Left < 0 then
  begin
    FaceRect := MoveRect(FaceRect, R.Left, 0);
    R.Left := 0;
  end;
  if R.Top < 0 then
  begin
    FaceRect := MoveRect(FaceRect, 0, R.Top);
    R.Top := 0;
  end;
  if R.Bottom > FBImage.Height then
    R.Bottom := FBImage.Height;
  if R.Right > FBImage.Width then
    R.Right := FBImage.Width;

  BmpFace3X := TBitmap.Create;
  try
    BmpFace3X.PixelFormat := pf24Bit;
    BmpFace3X.SetSize(RectWidth(R), RectHeight(R));
    BmpFace3X.Canvas.CopyRect(BmpFace3X.ClientRect, FBImage.Canvas, R);
    //BmpFace3X contains image of person
    TmpFace := TFaceDetectionResultItem.Create;
    try
      TmpFace.X := FaceRect.Left;
      TmpFace.Y := FaceRect.Top;
      TmpFace.Width := RectWidth(FaceRect);
      TmpFace.Height := RectHeight(FaceRect);
      CreatePerson(Item, Face, TmpFace, BmpFace3X, P);
      RefreshFaces;
      F(P);
    finally
      F(TmpFace);
    end;
  finally
    F(BmpFace3X);
  end;
end;

procedure TViewer.MiOtherPersonsClick(Sender: TObject);
var
  FormFindPerson: TFormFindPerson;
  P: TPerson;
  Result: Integer;
begin
  Application.CreateForm(TFormFindPerson, FormFindPerson);
  try
    P := nil;
    Result := FormFindPerson.Execute(Item, P);
    if (P <> nil) and (Result = SELECT_PERSON_OK) then
      SelectPerson(P);
    if Result = SELECT_PERSON_CREATE_NEW then
      MiCreatePersonClick(Sender);
  finally
    F(FormFindPerson);
  end;
end;

procedure TViewer.SelectPerson(P: TPerson);
var
  PA: TPersonArea;
  RI: TFaceDetectionResultItem;
begin
  RI := TFaceDetectionResultItem(PmFace.Tag);
  if P <> nil then
  begin
    PA := TPersonArea(RI.Data);
    if Item.ID = 0 then
    begin
      Item.Include := True;
      AddImage(Item);
    end;

    if Item.ID <> 0 then
    begin
      if (PA = nil) or (PA.PersonID <= 0) then
      begin
        PA := TPersonArea.Create(Item.ID, P.ID, RI);
        try
          PersonManager.AddPersonForPhoto(Self, PA);
          RI.Data := PA.Clone;

          RefreshFaces;
        finally
          F(PA);
        end;
      end else
      begin
        PersonManager.ChangePerson(PA, P.ID);
        RefreshFaces;
      end;
    end;
  end;
end;

procedure TViewer.MiCurrentPersonClick(Sender: TObject);
var
  FR: TFaceDetectionResultItem;
  PA: TPersonArea;
begin
  FR := TFaceDetectionResultItem(PmFace.Tag);
  PA := TPersonArea(FR.Data);
  if (PA <> nil) then
  begin
    if EditPerson(PA.PersonID) then
      RefreshFaces;
  end;
end;

procedure TViewer.MiDrawFaceClick(Sender: TObject);
begin
  FIsSelectingFace := True;
  UpdateCursor;
end;

procedure TViewer.MiFaceDetectionStatusClick(Sender: TObject);
var
  IsActive: Boolean;
begin
  IsActive := Settings.ReadBool('FaceDetection', 'Enabled', True);
  Settings.WriteBool('FaceDetection', 'Enabled', not IsActive);
  ReloadCurrent;
end;

procedure TViewer.MiFindPhotosClick(Sender: TObject);
var
  P: TPerson;
  PA: TPersonArea;
  FR: TFaceDetectionResultItem;
begin
  FR := TFaceDetectionResultItem(PmFace.Tag);
  PA := TPersonArea(FR.Data);
  if PA = nil then
    Exit;
  P := TPerson.Create;
  try
    PersonManager.FindPerson(PA.PersonID, P);
    if P.Empty then
      Exit;

    with ExplorerManager.NewExplorer(False) do
    begin
      SetPath(cPersonsPath + '\' + P.Name);
      Show;
    end;
  finally
    F(P);
  end;
end;

procedure TViewer.DoWaitToImage(Sender: TObject);
begin
  FIsWaiting := True;
  LsLoading.RecteateImage;
  LsLoading.Show;
end;

procedure TViewer.EndWaitToImage(Sender: TObject);
begin
  FIsWaiting := False;
  LsLoading.Hide;
end;

procedure TViewer.Onlythisfile1Click(Sender: TObject);
begin
  UpdaterDB.AddFile(Item.FileName)
end;

procedure TViewer.AddHiddenInfo1Click(Sender: TObject);
begin
  HideDataInImage(Item.FileName);
end;

procedure TViewer.AllFolder1Click(Sender: TObject);
begin
  UpdaterDB.AddDirectory(ExtractFileDir(Item.FileName))
end;

procedure TViewer.ApplyStyle;
begin
  inherited;
  TW.I.Start('RecreateImLists');
  RecreateImLists;
end;

procedure TViewer.GoToSearchWindow1Click(Sender: TObject);
var
  NewSearch: TSearchCustomForm;
begin
  if FullScreenNow then
    Exit1Click(Self);
  NewSearch := SearchManager.GetAnySearch;
  NewSearch.Show;
  NewSearch.SetFocus;
end;

procedure TViewer.Explorer1Click(Sender: TObject);
begin
  if FullScreenNow then
    Exit1Click(Self);
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(Item.FileName);
    SetPath(ExtractFileDir(Item.FileName));
    Show;
  end;
end;

procedure TViewer.ExtractHiddenInfo1Click(Sender: TObject);
begin
  ExtractDataFromImage(Item.FileName);
end;

procedure TViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Viewer := nil;
  if FullScreenView <> nil then
    Exit1Click(nil);
  if DirectShowForm <> nil then
    DirectShowForm.Close;
  FIsClosing := True;
  Action := caFree;
end;

procedure TViewer.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Viewer');
    TW.I.Start('ToolButton2.Hint');
    TbBack.Hint := L('Back (left arrow)');
    TbForward.Hint := L('Forward (right arrow)'); ;
    TbFitToWindow.Hint := L('Fit to window (Ctrl+F)');
    TbRealSize.Hint := L('Original size (Ctrl+A)');
    TbSlideShow.Hint := L('Slide show (Ctrl+S)');
    TbFullScreen.Hint := L('Full screen (Ctrl+Enter)');
    TbZoomOut.Hint := L('Zoom in (Ctrl+I)');
    TbZoomIn.Hint := L('Zoom out (Ctrl+O)');
    TbRotateCCW.Hint := L('Rotate left (Ctrl+L)');
    TbRotateCW.Hint := L('Rotate right (Ctrl+R)');
    TbDelete.Hint := L('Delete (Ctrl+D)');
    TbPrint.Hint := L('Print (Ctrl+P)');
    TbRating.Hint := L('Rating (Ctrl+rating)');
    TbEditImage.Hint := L('Image editor (Shift+E)');
    TbInfo.Hint := L('Properties (Ctrl+Z)');
    TbEncrypt.Hint := L('Encrypt/Decrypt (Ctrl+X)');
    TbExplore.Hint := L('Explorer (Ctrl+E)');
    TbConvert.Hint := L('Resize (Ctrl+W)');

    MiCreatePerson.Caption := L('Create person');
    MiOtherPersons.Caption := L('Other person');
    MiFindPhotos.Caption := L('Find photos');
    MiClearFaceZone.Caption := L('Clear face zone');
    MiPreviousSelections.Caption := L('Previous selections') + ':';
    MiDrawFace.Caption := L('Select person');
  finally
    EndTranslate;
  end;
end;

procedure TViewer.Copy1Click(Sender: TObject);
var
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
    if not IsDevicePath(Item.FileName) then
    begin
      FileList.Add(Item.FileName);
      Copy_Move(Application.Handle, True, FileList)
    end else
    begin
      FileList.Add(ExtractFileName(Item.FileName));
      ExecuteShellPathRelativeToMyComputerMenuAction(Handle, PhotoDBPathToDevicePath(ExtractFilePath(Item.FileName)), FileList, Point(0, 0), nil, AnsiString('Copy'));
    end;
  finally
     F(FileList);
  end;
end;

procedure TViewer.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  PA: TPersonArea;
begin
  if StaticImage and (FHoverFace = nil) and (ShiftKeyDown or (Button = mbMiddle) or FIsSelectingFace) and not DBCanDrag then
  begin
    FIsSelectingFace := False;
    FDrawingFace := True;
    P := Point(X, Y);
    F(FDrawFace);
    FDrawFace := TFaceDetectionResultItem.Create;
    FDrawFace.ImageWidth := FBImage.Width;
    FDrawFace.ImageHeight := FBImage.Height;

    FDrawFaceStartPoint := BufferPointToImagePoint(P);
    FDrawFace.Rect := Rect(FDrawFaceStartPoint, FDrawFaceStartPoint);

    PA := TPersonArea.Create(0, -1, nil);
    FDrawFace.Data := PA;
    UpdateCursor;
    Exit;
  end;

  WindowsMenuTickCount := GetTickCount;
  if CurrentInfo.Count = 0 then
    Exit;

  if Button = MbLeft then
    if FileExistsSafe(Item.FileName) then
    begin
      DBCanDrag := True;
      GetCursorPos(DBDragPoint);
    end;
end;

procedure TViewer.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  FDrawingFace := False;
  if FDrawFace <> nil then
  begin
    FFaces.Add(FDrawFace);
    PmFace.Tag := NativeInt(FDrawFace);
    FHoverFace := FDrawFace;
    FDrawFace := nil;
    FFaces.SaveToFile(FFaces.PersistanceFileName);
    UpdateFaceDetectionState;
    Invalidate;
    RefreshFaces;

    P := Point(X, Y);
    P := ClientToScreen(P);
    PmFace.Popup(P.X, P.Y);
    UpdateCursor;
  end;
  F(FDrawFace);
  DBCanDrag := False;
end;

procedure TViewer.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if CtrlKeyDown or ShiftKeyDown then
    TbZoomOutClick(Self)
end;

procedure TViewer.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if CtrlKeyDown or ShiftKeyDown then
    TbZoomInClick(Self);
end;

procedure TViewer.SbHorisontalScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if ScrollPos > (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize then
    ScrollPos := (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize;
  RecreateDrawImage(Sender);
end;

procedure TViewer.ReAllignScrolls(IsCenter: Boolean; CenterPoint: TPoint);
var
  Inc_: Integer;
  Pos, M, Ps: Integer;
  V1, V2: Boolean;

begin
  Panel1.Visible := False;
  if not ZoomerOn then
  begin
    SbHorisontal.Position := 0;
    SbHorisontal.Visible := False;
    SbVertical.Position := 0;
    SbVertical.Visible := False;
    Exit;
  end;
  V1 := SbHorisontal.Visible;
  V2 := SbVertical.Visible;
  if not SbHorisontal.Visible and not SbVertical.Visible then
  begin
    SbHorisontal.Visible := FbImage.Width * Zoom > ClientWidth;
    if SbHorisontal.Visible then
      Inc_ := SbHorisontal.Height
    else
      Inc_ := 0;
    SbVertical.Visible := FbImage.Height * Zoom > HeightW - Inc_;
  end;
  begin
    if SbVertical.Visible then
      Inc_ := SbVertical.Width
    else
      Inc_ := 0;
    SbHorisontal.Visible := FbImage.Width * Zoom > ClientWidth - Inc_;
    SbHorisontal.Width := ClientWidth - Inc_;
    if SbHorisontal.Visible then
      Inc_ := SbHorisontal.Height
    else
      Inc_ := 0;
    SbHorisontal.Top := HeightW - Inc_;
  end;
  begin
    if SbHorisontal.Visible then
      Inc_ := SbHorisontal.Height
    else
      Inc_ := 0;
    SbVertical.Visible := FbImage.Height * Zoom > HeightW - Inc_;
    SbVertical.Height := HeightW - Inc_;
    if SbVertical.Visible then
      Inc_ := SbVertical.Width
    else
      Inc_ := 0;
    SbVertical.Left := ClientWidth - Inc_;
  end;
  begin
    if SbVertical.Visible then
      Inc_ := SbVertical.Width
    else
      Inc_ := 0;
    SbHorisontal.Visible := FbImage.Width * Zoom > ClientWidth - Inc_;
    SbHorisontal.Width := ClientWidth - Inc_;
    if SbHorisontal.Visible then
      Inc_ := SbHorisontal.Height
    else
      Inc_ := 0;
    SbHorisontal.Top := HeightW - Inc_;
  end;
  if not SbHorisontal.Visible then
    SbHorisontal.Position := 0;
  if not SbVertical.Visible then
    SbVertical.Position := 0;
  if SbHorisontal.Visible and not V1 then
  begin
    SbHorisontal.PageSize := 0;
    SbHorisontal.Position := 0;
    SbHorisontal.Max := 100;
    SbHorisontal.Position := 50;
  end;
  if SbVertical.Visible and not V2 then
  begin
    SbVertical.PageSize := 0;
    SbVertical.Position := 0;
    SbVertical.Max := 100;
    SbVertical.Position := 50;
  end;
  Panel1.Width := SbVertical.Width;
  Panel1.Height := SbHorisontal.Height;
  Panel1.Left := ClientWidth - Panel1.Width;
  Panel1.Top := HeightW - Panel1.Height;
  Panel1.Visible := SbHorisontal.Visible and SbVertical.Visible;
  if SbHorisontal.Visible then
  begin
    if SbVertical.Visible then
      Inc_ := SbVertical.Width
    else
      Inc_ := 0;
    M := Round(FbImage.Width * Zoom);
    Ps := ClientWidth - Inc_;
    if Ps > M then
      Ps := 0;
    if (SbHorisontal.Max <> SbHorisontal.PageSize) then
      Pos := Round(SbHorisontal.Position * ((M - Ps) / (SbHorisontal.Max - SbHorisontal.PageSize)))
    else
      Pos := SbHorisontal.Position;
    if M < SbHorisontal.PageSize then
      SbHorisontal.PageSize := Ps;
    SbHorisontal.Max := M;
    SbHorisontal.PageSize := Ps;
    SbHorisontal.LargeChange := Ps div 10;
    SbHorisontal.Position := Math.Min(SbHorisontal.Max, Pos);
  end;
  if SbVertical.Visible then
  begin
    if SbHorisontal.Visible then
      Inc_ := SbHorisontal.Height
    else
      Inc_ := 0;
    M := Round(FbImage.Height * Zoom);
    Ps := HeightW - Inc_;
    if Ps > M then
      Ps := 0;
    if SbVertical.Max <> SbVertical.PageSize then
      Pos := Round(SbVertical.Position * ((M - Ps) / (SbVertical.Max - SbVertical.PageSize)))
    else
      Pos := SbVertical.Position;
    if M < SbVertical.PageSize then
      SbVertical.PageSize := Ps;
    SbVertical.Max := M;
    SbVertical.PageSize := Ps;
    SbVertical.LargeChange := Ps div 10;
    SbVertical.Position := Math.Min(SbVertical.Max, Pos);
  end;
  if SbHorisontal.Position > SbHorisontal.Max - SbHorisontal.PageSize then
    SbHorisontal.Position := SbHorisontal.Max - SbHorisontal.PageSize;
  if SbVertical.Position > SbVertical.Max - SbVertical.PageSize then
    SbVertical.Position := SbVertical.Max - SbVertical.PageSize;
end;

procedure TViewer.RealSizeClick(Sender: TObject);
begin
  Cursor := CrDefault;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  if not ZoomerOn and (RealZoomInc > 1) then
  begin
    ZoomerOn := True;
    Zoom := 1;
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    SbHorisontal.PageSize := 0;
    SbHorisontal.Max := 100;
    SbHorisontal.Position := 50;
    SbVertical.PageSize := 0;
    SbVertical.Max := 100;
    SbVertical.Position := 50;
    LoadImage_(Sender, True, 1, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end else
  begin
    Zoom := 1;
    ZoomerOn := True;
    FormResize(Sender);
  end;
end;

procedure TViewer.FinishDetectionFaces;
begin
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;
end;

procedure TViewer.FitToWindowClick(Sender: TObject);
begin
  Cursor := CrDefault;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  ZoomerOn := False;
  Zoom := 1;
  FormResize(Sender);
end;

procedure TViewer.TbZoomOutClick(Sender: TObject);
var
  Z: Real;
begin
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  Cursor := CursorZoomOutNo;
  if not ZoomerOn and (RealZoomInc > 1) then
  begin
    ZoomerOn := True;
    if (RealImageWidth < ClientWidth) and (RealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(RealImageWidth / ClientWidth, RealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Max(Z * 0.8, 0.01);
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    LoadImage_(Sender, True, Z, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end else
  begin
    if ZoomerOn then
    begin
      Z := Zoom;
    end else
    begin
      if (RealImageWidth < ClientWidth) and (RealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(RealImageWidth / ClientWidth, RealImageHeight / (HeightW));
      Z := 1 / Z;
    end;
    ZoomerOn := True;
    Zoom := Max(Z * 0.8, 0.05);
    FormResize(Sender);
  end;
end;

procedure TViewer.TbZoomInClick(Sender: TObject);
var
  Z: Real;
begin
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  Cursor := CursorZoomInNo;
  if not ZoomerOn and (RealZoomInc > 1) then
  begin
    ZoomerOn := True;
    if (RealImageWidth < ClientWidth) and (RealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(RealImageWidth / ClientWidth, RealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Min(Z * (1 / 0.8), 16);
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    LoadImage_(Sender, True, Z, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end else
  begin
    if ZoomerOn then
    begin
      Z := Zoom;
    end else
    begin
      if (RealImageWidth < ClientWidth) and (RealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(RealImageWidth / ClientWidth, RealImageHeight / (HeightW));
      Z := 1 / Z;
    end;

    ZoomerOn := True;
    Zoom := Min(Z * (1 / 0.8), 16);
    FormResize(Sender);
  end;
end;

procedure TViewer.FormClick(Sender: TObject);
var
  P, ScreenRect, ImagePoint: TPoint;
  ImRect: TRect;
  I: Integer;
  Dy, Dx, X, Y, Z: Extended;
begin
  GetCursorPos(ScreenRect);
  P := ScreenToClient(ScreenRect);

  ImagePoint := BufferPointToImagePoint(P);
  for I := 0 to FFaces.Count - 1 do
    if PtInRect(FFaces[I].Rect, PxMultiply(ImagePoint, FBImage, FFaces[I].ImageSize)) then
    begin
      FHoverFace := FFaces[I];
      RefreshFaces;
      PmFace.Tag := NativeInt(FFaces[I]);
      PmFace.Popup(ScreenRect.X, ScreenRect.Y);
      Exit;
    end;

  if Cursor = CrDefault then
  begin
    if Settings.Readbool('Options', 'NextOnClick', False) then
    begin
      NextImageClick(Sender);
      Exit;
    end else
    begin
      if SlideShowNow or FullScreenNow then
      begin
        NextImageClick(Sender);
        Exit;
      end;
    end;
    Exit;
  end;
  if Cursor = CursorZoomInNo then
  begin
    Z := Zoom;
    Zoom := Min(Z * (1 / 0.8), 16);
    ImRect := GetImageRectA;
    X := P.X;
    Y := P.Y;
    Dx := (X - (ImRect.Right - ImRect.Left) div 2) / (ImRect.Right - ImRect.Left);
    SbHorisontal.Position := SbHorisontal.Position + Round(SbHorisontal.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    SbVertical.Position := SbVertical.Position + Round(SbVertical.PageSize * Dy);
  end;
  if Cursor = CursorZoomOutNo then
  begin
    Z := Zoom;
    Zoom := Max(Z * 0.8, 0.05);
    ImRect := GetImageRectA;
    X := P.X;
    Y := P.Y;
    Dx := (X - (ImRect.Right - ImRect.Left) div 2) / (ImRect.Right - ImRect.Left);
    SbHorisontal.Position := SbHorisontal.Position + Round(SbHorisontal.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    SbVertical.Position := SbVertical.Position + Round(SbVertical.PageSize * Dy);
  end;
  FormResize(Sender);
end;

function TViewer.HeightW: Integer;
begin
  Result := ClientHeight - TbrActions.Height - 3;
end;

function TViewer.GetImageRectA: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if SbHorisontal.Visible then
  begin
    FX := 0;
  end else
  begin
    if SbVertical.Visible then
      Increment := SbVertical.width
    else
      Increment := 0;
    FX := Max(0, Round(ClientWidth / 2 - Increment - FBImage.Width * Zoom / 2));
  end;
  if SbVertical.Visible then
  begin
    FY := 0;
  end else
  begin
    if SbHorisontal.Visible then
      Increment := SbHorisontal.Height
    else
      Increment := 0;
    FY := Max(0,
      Round(HeightW / 2 - Increment - FBImage.Height * Zoom / 2));
  end;
  if SbVertical.Visible then
    Increment := SbVertical.width
  else
    Increment := 0;
  FW := round(Min(ClientWidth - Increment, FBImage.Width * Zoom));
  if SbHorisontal.Visible then
    Increment := SbHorisontal.Height
  else
    Increment := 0;
  FH := Round(Min(HeightW - Increment, FBImage.Height * Zoom));
  FH := FH;

  Result := Rect(FX, FY, FW + FX, FH + FY);
end;

function TViewer.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := CurrentInfo[CurrentFileNumber];
end;

procedure TViewer.RecreateImLists;
const
  IconsCount = 26;
var
  Icons: array [0 .. 1, 0 .. IconsCount] of HIcon;
  I, J: Integer;
  B: TBitmap;
  Imlists: array [0 .. 2] of TImageList;

const
  Names: array [0 .. 1, 0 .. IconsCount] of string = (
    ('Z_NEXT_NORM', 'Z_PREVIOUS_NORM', 'Z_BESTSIZE_NORM',
    'Z_FULLSIZE_NORM', 'Z_FULLSCREEN_NORM', 'Z_ZOOMIN_NORM', 'Z_ZOOMOUT_NORM', 'Z_FULLSCREEN', 'Z_LEFT_NORM',
    'Z_RIGHT_NORM', 'Z_INFO_NORM', 'IMEDITOR', 'PRINTER', 'DELETE_INFO', 'RATING_STAR', 'TRATING_1', 'TRATING_2',
    'TRATING_3', 'TRATING_4', 'TRATING_5', 'Z_DB_NORM', 'Z_DB_WORK', 'Z_PAGES', 'KEY', 'DECRYPTFILE',
    'EXPLORER', 'RESIZE'),

    ('Z_NEXT_HOT', 'Z_PREVIOUS_HOT',  'Z_BESTSIZE_HOT',
    'Z_FULLSIZE_HOT', 'Z_FULLSCREEN_HOT', 'Z_ZOOMIN_HOT', 'Z_ZOOMOUT_HOT', 'Z_FULLSCREEN', 'Z_LEFT_HOT',
    'Z_RIGHT_HOT', 'Z_INFO_HOT', 'IMEDITOR', 'PRINTER', 'DELETE_INFO', 'RATING_STAR', 'TRATING_1', 'TRATING_2',
    'TRATING_3', 'TRATING_4', 'TRATING_5', 'Z_DB_NORM', 'Z_DB_WORK', 'Z_PAGES', 'KEY', 'DECRYPTFILE',
    'EXPLORER', 'RESIZE')
    );

begin
  TW.I.Start('LoadIcon');
  for I := 0 to 1 do
    for J := 0 to IconsCount do
      Icons[I, J] := LoadImage(HInstance, PWideChar(Names[I, J]), IMAGE_ICON, 16, 16, 0);

  Imlists[0] := ImlToolBarNormal;
  Imlists[1] := ImlToolBarHot;
  Imlists[2] := ImlToolBarDisabled;
  TW.I.Start('Clear');
  if not FCreating then
    for I := 0 to 2 do
      Imlists[I].Clear;

  B := TBitmap.Create;
  try
    B.Width := 16;
    B.Height := 16;
    B.Canvas.Brush.Color := Theme.PanelColor;
    B.Canvas.Pen.Color := Theme.PanelColor;
    TW.I.Start('ImageList_ReplaceIcon');
    for I := 0 to 1 do
      for J := 0 to IconsCount do
      begin
        ImageList_ReplaceIcon(Imlists[I].Handle, -1, Icons[I, J]);
        if I = 0 then
        begin
          if J in [0, 1, 8, 9, 12, 14, 22, 23] then
          begin
            B.Canvas.Rectangle(0, 0, 16, 16);
            DrawIconEx(B.Canvas.Handle, 0, 0, Icons[I, J], 16, 16, 0, 0, DI_NORMAL);
            GrayScale(B);
            Imlists[2].Add(B, nil);
          end else
            ImageList_ReplaceIcon(Imlists[2].Handle, -1, Icons[I, J]);
        end;
      end;

    for I := 15 to 19 do
    begin
      B.Canvas.Rectangle(0, 0, 16, 16);
      DrawIconEx(B.Canvas.Handle, 0, 0, Icons[0, I], 16, 16, 0, 0, DI_NORMAL);
      GrayScale(B);
      Imlists[0].Add(B, nil);
      Imlists[1].Add(B, nil);
    end;

    TW.I.Start('DestroyIcon');
    for I := 0 to 1 do
      for J := 0 to IconsCount do
        DestroyIcon(Icons[I, J]);

  finally
    F(B);
  end;

  TW.I.Start('RecreateImLists - end');
end;

procedure TViewer.RefreshFaces;
var
  I: Integer;
  P1, P2: TPoint;
  Rct, R, FaceTextRect: TRect;
  PA: TPersonArea;
  P: TPerson;

  procedure DrawFace(Face: TFaceDetectionResultItem);
  var
    S: string;
  begin
    FOverlayBuffer.Canvas.Brush.Style := bsClear;
    FOverlayBuffer.Canvas.Pen.Style := psDash;
    FOverlayBuffer.Canvas.Pen.Width := 1;

    P1 := Face.Rect.TopLeft;
    P2 := Face.Rect.BottomRight;

    P1 := PxMultiply(P1, Face.ImageSize, FBImage);
    P2 := PxMultiply(P2, Face.ImageSize, FBImage);

    P1 := ImagePointToBufferPoint(P1);
    P2 := ImagePointToBufferPoint(P2);
    R := Rect(P1, P2);
    FOverlayBuffer.Canvas.Pen.Color := Theme.WindowColor;
    FOverlayBuffer.Canvas.Rectangle(R);
    InflateRect(R, -1, -1);
    FOverlayBuffer.Canvas.Pen.Color := clGray;
    FOverlayBuffer.Canvas.Rectangle(R);
    if Face.Data <> nil then
    begin
      PA := TPersonArea(Face.Data);

      P := TPerson.Create;
      try
        PersonManager.FindPerson(PA.PersonID, P);
        if not P.Empty or (PA.PersonID = -1) then
        begin
          if not P.Empty then
            S := P.Name
          else
            S := L('New person');

          R := Rect(R.Left, R.Bottom + 8, Max(R.Left + 20, R.Right), R.Bottom + 500);
          Rct := R;
          FOverlayBuffer.Canvas.Font := Font;
          FOverlayBuffer.Canvas.Font.Color := Theme.GradientText;
          DrawText(FOverlayBuffer.Canvas.Handle, PChar(S), Length(S), R, DrawTextOpt or DT_CALCRECT);
          R.Right := Max(R.Right, Rct.Right);
          FaceTextRect := R;
          InflateRect(R, 4, 4);
          DrawRoundGradientVert(FOverlayBuffer, R, Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, 8, 220);
          DrawText(FOverlayBuffer.Canvas.Handle, PChar(S), Length(S), FaceTextRect, DrawTextOpt);
        end;
      finally
        F(P);
      end;
    end;
  end;

begin
  if (FFaces.Count > 0) or FDrawingFace then
  begin
    FOverlayBuffer.Assign(DrawImage);

    if not ShiftKeyDown and not FDisplayAllFaces then
    begin
      if FHoverFace <> nil then
        DrawFace(FHoverFace);
    end else
    begin
      for I := 0 to FFaces.Count - 1 do
        DrawFace(FFaces[I]);
    end;

    if FDrawingFace and (FDrawFace <> nil) then
      DrawFace(FDrawFace);
  end else
    FOverlayBuffer.SetSize(0, 0);

  Refresh;
end;

procedure TViewer.RotateCCW1Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;

    RotateImages(Self, Info, DB_IMAGE_ROTATE_270, True);

    LockEventRotateFileList.Add(AnsiLowerCase(Item.FileName));
    Rotate270A(FbImage);
    FFaces.RotateLeft;
    if ZoomerOn then
      FitToWindowClick(Sender);

    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
end;

procedure TViewer.RotateCW1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;

    RotateImages(Self, Info, DB_IMAGE_ROTATE_90, True);

    LockEventRotateFileList.Add(AnsiLowerCase(Item.FileName));

    Rotate90A(FbImage);
    FFaces.RotateRight;
    if ZoomerOn then
      FitToWindowClick(Sender);

    ReAllignScrolls(True, Point(0, 0));
    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
end;

procedure TViewer.ByEXIF1Click(Sender: TObject);
var
  ExifData: TExifData;
begin
  ExifData := TExifData.Create;
  try
    ExifData.LoadFromGraphic(Item.FileName);
    case ExifOrientationToRatation(Ord(ExifData.Orientation)) of
      DB_IMAGE_ROTATE_180:
        begin
          Rotateon1801Click(Sender);
        end;
      DB_IMAGE_ROTATE_90:
        begin
          RotateCW1Click(Sender);
        end;
      DB_IMAGE_ROTATE_270:
        begin
          RotateCCW1Click(Sender);
        end;
    end;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  F(ExifData);
end;

procedure TViewer.Rotateon1801Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;

    LockEventRotateFileList.Add(AnsiLowerCase(Item.FileName));

    RotateImages(Self, Info, DB_IMAGE_ROTATE_180, True);
    if ZoomerOn then
      FitToWindowClick(Sender);

    ReAllignScrolls(True, Point(0, 0));
    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
end;

procedure TViewer.Stretch1Click(Sender: TObject);
begin
  SetDesktopWallpaper(Item.FileName, WPSTYLE_STRETCH);
end;

procedure TViewer.Center1Click(Sender: TObject);
begin
  SetDesktopWallpaper(Item.FileName, WPSTYLE_CENTER);
end;

procedure TViewer.Tile1Click(Sender: TObject);
begin
  SetDesktopWallpaper(Item.FileName, WPSTYLE_TILE);
end;

procedure TViewer.Properties1Click(Sender: TObject);
begin
  if not IsDevicePath(Item.Path) then
  begin
    if Item.ID <> 0 then
      PropertyManager.NewIDProperty(Item.ID).Execute(Item.ID)
    else
      PropertyManager.NewFileProperty(Item.FileName).ExecuteFileNoEx(Item.FileName);
  end else
  begin
    ExecuteProviderFeature(Self, Item.Path, PATH_FEATURE_PROPERTIES)
  end;
end;

procedure TViewer.Resize1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
begin
  List := TDBPopupMenuInfo.Create;
  try
    List.Add(Item.Copy);
    List[0].Selected := True;
    ResizeImages(Self, List);
  finally
    F(List);
  end;
end;

procedure TViewer.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  FNames: TStrings;
  P: TPoint;
begin
  if CurrentInfo.Count = 0 then
    Exit;

  if (GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
  begin
    FNames := TStringList.Create;
    try
      FNames.Add(Item.FileName);
      GetProperties(FNames, MousePos, Self);
    finally
      F(FNames);
    end;
    Exit;
  end;
  P := ClientToScreen(MousePos);
  PmMain.Popup(P.X, P.Y);
end;

procedure TViewer.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  FileList : TStringList;
begin
  if not DBCanDrag then
  begin
    FileList := TStringList.Create;
    try
      DropFileTarget1.Files.AssignTo(FileList);
      LoadListImages(FileList);
    finally
      F(FileList);
    end;
  end;
end;

procedure TViewer.ReloadCurrent;
begin
  LoadImage_(Self, False, Zoom, False);
end;

procedure TViewer.Pause;
begin
  if DirectShowForm <> nil then
    DirectShowForm.Pause;
  MTimer1.Caption := L('Start timer');
  MTimer1.ImageIndex := DB_IC_PLAY;
  FloatPanel.TbPlay.Down := False;
  FloatPanel.TbPause.Down := True;
end;

procedure TViewer.SetImageExists(const Value: Boolean);
begin
  FImageExists := Value;
end;

procedure TViewer.SetPropStaticImage(const Value: Boolean);
begin
  FStaticImage := Value;
end;

function TViewer.GetSID: TGUID;
begin
  Result := FSID;
end;

procedure TViewer.SetStaticImage(Image: TBitmap; Transparent: Boolean);
begin
  if CurrentFileNumber > CurrentInfo.Count - 1 then
    Exit;
  FCurrentlyLoadedFile := Item.FileName;
  TransparentImage := Transparent;
  ForwardThreadExists := False;
  ForwardThreadNeeds := False;
  F(FBImage);
  FbImage := Image;
  StaticImage := True;
  ImageExists := True;
  Loading := False;
  if not ZoomerOn then
    Cursor := CrDefault;
  TbFitToWindow.Enabled := True;
  TbRealSize.Enabled := True;
  TbSlideShow.Enabled := True;
  TbZoomOut.Enabled := True;
  TbZoomIn.Enabled := True;
  TbRotateCCW.Enabled := not IsDevicePath(Item.FileName);
  TbRotateCW.Enabled := not IsDevicePath(Item.FileName);
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  EndWaitToImage(Self);

  ReAllignScrolls(False, Point(0, 0));
  ValidImages := 1;
  F(FOverlayBuffer);
  FFaces.Clear;
  FFaceDetectionComplete := False;
  UpdateFaceDetectionState;
  FOverlayBuffer := TBitmap.Create;
  RecreateDrawImage(Self);
  PrepareNextImage;
end;

procedure TViewer.SetLoading(const Value: Boolean);
begin
  FLoading := Value;
  TbSlideShow.Enabled := not Value;
  if CurrentInfo.Count = 0 then
    TbSlideShow.Enabled := False;
end;

procedure TViewer.SetAnimatedImage(Image: TGraphic);
var
  I: Integer;
  Gif: TGifImage;
begin
  F(AnimatedImage);
  AnimatedImage := Image;
  FCurrentlyLoadedFile := Item.FileName;
  ForwardThreadExists := False;
  StaticImage := False;
  ImageExists := True;
  Loading := False;
  if not ZoomerOn then
    Cursor := CrDefault;
  TbFitToWindow.Enabled := True;
  TbRealSize.Enabled := True;
  TbSlideShow.Enabled := True;
  TbZoomOut.Enabled := True;
  TbZoomIn.Enabled := True;

  TbRotateCCW.Enabled := not IsDevicePath(Item.FileName);
  TbRotateCW.Enabled := not IsDevicePath(Item.FileName);

  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  EndWaitToImage(Self);
  ReAllignScrolls(False, Point(0, 0));
  SlideNO := -1;
  ZoomerOn := False;
  ValidImages := 0;
  TransparentImage := False;

  if AnimatedImage is TGIFImage then
  begin
    Gif := (AnimatedImage as TGIFImage);
    for I := 0 to Gif.Images.Count - 1 do
    begin
      if not Gif.Images[I].Empty then
        ValidImages := ValidImages + 1;
      if Gif.Images[I].Transparent then
        TransparentImage := True;
    end;
  end else if AnimatedImage is TAnimatedJPEG then
  begin
    TransparentImage := False;
    ValidImages := TAnimatedJPEG(AnimatedImage).Count;
  end;

  AnimatedBuffer.Width := AnimatedImage.Width;
  AnimatedBuffer.Height := AnimatedImage.Height;
  if FullScreenNow then
  begin
    AnimatedBuffer.Canvas.Brush.Color := 0;
    AnimatedBuffer.Canvas.Pen.Color := 0;
  end else
  begin
    AnimatedBuffer.Canvas.Brush.Color := Theme.WindowColor;
    AnimatedBuffer.Canvas.Pen.Color := Theme.WindowColor;
  end;
  AnimatedBuffer.Canvas.Rectangle(0, 0, AnimatedBuffer.Width, AnimatedBuffer.Height);
  ImageFrameTimer.Interval := 1;
  ImageFrameTimer.Enabled := True;

  FFaces.Clear;
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;
end;

procedure TViewer.ImageFrameTimerTimer(Sender: TObject);
begin
  NextSlide;
end;

function TViewer.GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
begin
  Result := False;
  if AnsiLowerCase(FileName) = AnsiLowerCase(Item.FileName) then
  begin
    Result := True;
    if (Item.Width > 0) and (Item.Height > 0) then
    begin
      Width := Item.Width;
      Height := Item.Height;
    end else
    begin
      Width := FbImage.Width;
      Height := FbImage.Height;
    end;
    Bitmap.Assign(FbImage);
  end;
end;

procedure TViewer.NextSlide;
var
  C, PreviousNumber: Integer;
  R, Bounds_: TRect;
  Im: TGifImage;
  DisposalMethod: TDisposalMethod;
  Del: Integer;
  TimerEnabled: Boolean;
  Gsi: TGIFSubImage;
begin
  TimerEnabled := False;
  Del := 1;
  if not (ImageExists and not StaticImage) then
    Exit;
  if SlideNO = -1 then
  begin
    SlideNO := GetFirstImageNO;
  end else
  begin
    SlideNO := GetNextImageNO;
  end;

  if FullScreenNow then
  begin
    AnimatedBuffer.Canvas.Brush.Color := 0;
    AnimatedBuffer.Canvas.Pen.Color := 0;
  end else
  begin
    AnimatedBuffer.Canvas.Brush.Color := Theme.WindowColor;
    AnimatedBuffer.Canvas.Pen.Color := Theme.WindowColor;
  end;

  if (AnimatedImage is TGIFImage) then
  begin
    Im := (AnimatedImage as TGIFImage);
    R := Im.Images[SlideNO].BoundsRect;
    TimerEnabled := False;
    PreviousNumber := GetPreviousImageNO;
    DisposalMethod := DmNone;
    if Im.Animate then
      if Im.Images.Count > 1 then
      begin
        Gsi := Im.Images[SlideNO];
        if Gsi.Empty then
          Exit;
        if Im.Images[PreviousNumber].Empty then
          DisposalMethod := DmNone
        else
        begin
          if Im.Images[PreviousNumber].GraphicControlExtension <> nil then
            DisposalMethod := Im.Images[PreviousNumber].GraphicControlExtension.Disposal
          else
            DisposalMethod := DmNone;
        end;
        Del := 100;
        if Im.Images[SlideNO].GraphicControlExtension <> nil then
          Del := Im.Images[SlideNO].GraphicControlExtension.Delay * 10;
        if Del = 10 then
          Del := 100;
        if Del = 0 then
          Del := 100;
        TimerEnabled := True;
      end
      else
        DisposalMethod := DmNone;
    if SlideNO = 0 then
      DisposalMethod := DmBackground;
    if (DisposalMethod = DmBackground) then
    begin
      Bounds_ := Im.Images[PreviousNumber].BoundsRect;
      if FullScreenNow then
      begin
        AnimatedBuffer.Canvas.Pen.Color := 0;
        AnimatedBuffer.Canvas.Brush.Color := 0;
      end else
      begin
        AnimatedBuffer.Canvas.Pen.Color := Theme.WindowColor;
        AnimatedBuffer.Canvas.Brush.Color := Theme.WindowColor;
      end;

      AnimatedBuffer.Canvas.Rectangle(Bounds_);
    end;

    if DisposalMethod = DmPrevious then
    begin
      C := SlideNO;
      Dec(C);
      if C < 0 then
        C := Im.Images.Count - 1;
      Im.Images[C].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[SlideNO].Transparent, False);
    end;
    Im.Images[SlideNO].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[SlideNO].Transparent, False);

  end else if AnimatedImage is TAnimatedJPEG then
  begin
    AnimatedBuffer.Assign(TAnimatedJPEG(AnimatedImage).Images[SlideNO]);
    Del := Animation3DDelay;
    TimerEnabled := True;
  end;

  if CurrentFileNumber <= CurrentInfo.Count - 1 then
    case Item.Rotation of
      DB_IMAGE_ROTATE_0:
        FbImage.Assign(AnimatedBuffer);
      DB_IMAGE_ROTATE_90:
        Rotate90(AnimatedBuffer, FbImage);
      DB_IMAGE_ROTATE_180:
        Rotate180(AnimatedBuffer, FbImage);
      DB_IMAGE_ROTATE_270:
        Rotate270(AnimatedBuffer, FbImage)
    end;

  RecreateDrawImage(Self);
  ImageFrameTimer.Enabled := False;
  ImageFrameTimer.Interval := Del;
  if not TimerEnabled then
    ImageFrameTimer.Enabled := False
  else
    ImageFrameTimer.Enabled := True;
  if ValidImages = 1 then
    ImageFrameTimer.Enabled := False;
end;

procedure TViewer.SetValidImages(const Value: Integer);
begin
  FValidImages := Value;
end;

function TViewer.GetFirstImageNO: Integer;
var
  I: Integer;
begin
  Result := 0;
  if ValidImages = 0 then
    Result := 0
  else
  begin
    if (AnimatedImage is TGIFImage) then
    begin
      for I := 0 to (AnimatedImage as TGIFImage).Images.Count - 1 do
        if not(AnimatedImage as TGIFImage).Images[I].Empty then
        begin
          Result := I;
          Break;
        end;
    end else if (AnimatedImage is TAnimatedJPEG) then
    begin
      Result := 0;
    end;
  end;
end;

function TViewer.GetFormID: string;
begin
  Result := 'Viewer';
end;

function TViewer.GetNextImageNO: Integer;
var
  Im: TGIFImage;
begin
  Result := 0;
  if ValidImages = 0 then
    Result := 0
  else
  begin
    if (AnimatedImage is TGIFImage) then
    begin
      Im := (AnimatedImage as TGIFImage);
      Result := SlideNO;
      Inc(Result);
      if Result >= Im.Images.Count then
        Result := 0;

      if Im.Images[Result].Empty then
        Result := GetNextImageNOX(Result);
    end else if (AnimatedImage is TAnimatedJPEG) then
    begin
      //onle 2 slides
      Result := IIF(SlideNO = 1, 0, 1);
    end;
  end;
end;

function TViewer.GetPreviousImageNO: Integer;
var
  Im: TGIFImage;
begin
  Result := 0;
  if ValidImages = 0 then
    Result := 0
  else
  begin
    if (AnimatedImage is TGIFImage) then
    begin
      Im := (AnimatedImage as TGIFImage);
      Result := SlideNO;
      Dec(Result);
      if Result < 0 then
        Result := Im.Images.Count - 1;

      if Im.Images[Result].Empty then
        Result := GetPreviousImageNOX(Result);
    end else if (AnimatedImage is TAnimatedJPEG) then
    begin
      Result := IIF(SlideNO = 1, 0, 1);
    end;

  end;
end;

function TViewer.GetNextImageNOX(NO: Integer): Integer;
var
  Im: TGIFImage;
begin
  Result := 0;
  if ValidImages = 0 then
    Result := 0
  else
  begin
    if (AnimatedImage is TGIFImage) then
    begin
      Im := (AnimatedImage as TGIFImage);
      Result := NO;
      Inc(Result);
      if Result >= Im.Images.Count then
        Result := 0;

      if Im.Images[Result].Empty then
        Result := GetNextImageNOX(Result);
    end else if (AnimatedImage is TAnimatedJPEG) then
    begin
      Result := IIF(NO = 1, 0, 1);
    end;
  end;
end;

function TViewer.GetPreviousImageNOX(NO: Integer): Integer;
var
  Im: TGIFImage;
begin
  Result := 0;
  if ValidImages = 0 then
    Result := 0
  else
  begin
    if (AnimatedImage is TGIFImage) then
    begin
      Im := (AnimatedImage as TGIFImage);
      Result := NO;
      Dec(Result);
      if Result < 0 then
        Result := Im.Images.Count - 1;

      if Im.Images[Result].Empty then
        Result := GetPreviousImageNOX(Result);
    end else if (AnimatedImage is TAnimatedJPEG) then
    begin
      Result := IIF(NO = 1, 0, 1);
    end;
  end;
end;

procedure TViewer.SetForwardThreadExists(const Value: Boolean);
begin
  FForwardThreadExists := Value;
end;

procedure TViewer.SetForwardThreadSID(const Value: TGUID);
begin
  FForwardThreadSID := Value;
end;

procedure TViewer.SetForwardThreadNeeds(const Value: Boolean);
begin
  FForwardThreadNeeds := Value;
end;

procedure TViewer.SetForwardThreadFileName(const Value: string);
begin
  FForwardThreadFileName := Value;
end;

procedure TViewer.SetTransparentImage(const Value: Boolean);
begin
  FTransparentImage := Value;
end;

procedure TViewer.LoadingFailed(FileName: String);
begin
  Loading := False;
  FCurrentlyLoadedFile := FileName;
  Cursor := CrDefault;
  TbFitToWindow.Enabled := False;
  TbRealSize.Enabled := False;
  TbSlideShow.Enabled := False;
  TbZoomOut.Enabled := False;
  TbZoomIn.Enabled := False;
  TbRotateCCW.Enabled := False;
  TbRotateCW.Enabled := False;
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  EndWaitToImage(Self);
  ReAllignScrolls(False, Point(0, 0));
  ImageExists := False;
  ValidImages := 0;
  ForwardThreadExists := False;
  ForwardThreadNeeds := False;

  FFaces.Clear;
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;

  Invalidate;
  RecreateDrawImage(Self);
  PrepareNextImage;
end;

procedure TViewer.SetCurrentlyLoadedFile(const Value: String);
begin
  FCurrentlyLoadedFile := Value;
end;

procedure TViewer.PrepareNextImage;
var
  N: Integer;
begin
  ForwardThreadSID := GetGUID;
  if CurrentInfo.Count > 1 then
  begin
    N := CurrentFileNumber;
    Inc(N);
    if N >= CurrentInfo.Count then
      N := 0;
    ForwardThreadExists := True;
    ForwardThreadFileName := CurrentInfo[N].FileName;
    TViewerThread.Create(Self, CurrentInfo[N], False, 1, ForwardThreadSID, True, 0);
  end;
end;

procedure TViewer.SetFullImageState(State: Boolean; BeginZoom : Extended; Pages, Page : integer);
begin
  FPageCount := Pages;
  FCurrentPage := Page;
  MakePagesLinks;
  if State then
  begin
    ZoomerOn := True;
    Zoom := BeginZoom;
  end else
  begin
    ZoomerOn := False;
    Zoom := 1;
  end;
end;

procedure TViewer.UpdateCrypted;
begin
  TbEncrypt.Enabled := StaticPath(Item.FileName) and not IsDevicePath(Item.FileName);;
  if Item.Crypted then
    TbEncrypt.ImageIndex := 24
  else
    TbEncrypt.ImageIndex := 23;
end;

procedure TViewer.UpdateCursor;
begin
  if FDrawingFace or ShiftKeyDown or FIsSelectingFace then
    Cursor := crCross
  else
    Cursor := crDefault;
end;

procedure TViewer.CheckFaceIndicatorVisibility;
begin
  WlFaceCount.Visible := (WlFaceCount.Left + WlFaceCount.Width + 3 < TbrActions.Left) and StaticImage and FaceDetectionManager.IsActive;
  LsDetectingFaces.Visible := ((LsDetectingFaces.Left + LsDetectingFaces.Width + 3 < TbrActions.Left) and not FFaceDetectionComplete) and StaticImage and Settings.ReadBool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive and FaceDetectionManager.IsActive;
end;

procedure TViewer.UpdateFaceDetectionState;
var
  IsDetectionActive: Boolean;
begin
  if Visible and not HandleAllocated then
    Exit;

  BeginScreenUpdate(Handle);
  try
    IsDetectionActive := Settings.ReadBool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive;
    if not FFaceDetectionComplete and IsDetectionActive then
    begin
      WlFaceCount.Text := L('Detecting faces') + '...';
      LsDetectingFaces.Show;
      WlFaceCount.ImageIndex := -1;
      WlFaceCount.IconWidth := 0;
      WlFaceCount.IconHeight := 0;
      WlFaceCount.Left := LsDetectingFaces.Left + LsDetectingFaces.Width;
    end else
    begin
      LsDetectingFaces.Hide;
      WlFaceCount.Left := 6;
      WlFaceCount.IconWidth := 16;
      WlFaceCount.IconHeight := 16;
      WlFaceCount.ImageIndex := DB_IC_PEOPLE;
      if IsDetectionActive then
      begin
        if FFaces.Count > 0 then
          WlFaceCount.Text := Format(L('Faces: %d'), [FFaces.Count])
        else
          WlFaceCount.Text := L('No faces found');
      end else
      begin
        WlFaceCount.Text := L('Face detection disabled');
      end;
    end;
    CheckFaceIndicatorVisibility;
  finally
    EndScreenUpdate(Handle, True);
  end;
end;

procedure TViewer.UpdateFaces(FileName: string; Faces: TFaceDetectionResult);
begin
  if Item.FileName = FileName then
  begin
    FFaces.Assign(Faces);
    FFaceDetectionComplete := True;
    UpdateFaceDetectionState;
    RecreateDrawImage(nil);
  end;
end;

procedure TViewer.UpdateInfo(SID: TGUID; Info: TDBPopupMenuInfoRecord);
begin
  Item.Assign(Info);
  DisplayRating := Info.Rating;
  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := TbRotateCCW.Enabled;
  UpdateCrypted;
end;

procedure TViewer.TbSlideShowClick(Sender: TObject);
begin
  if Loading or (CurrentInfo.Position = -1) then
    Exit;
  SlideShowNow := True;
  SlideTimer.Enabled := False;
  Play := False;
  LsLoading.Hide;
  Application.CreateForm(TDirectShowForm, DirectShowForm);
  MTimer1.ImageIndex := DB_IC_PLAY;
  MTimer1Click(Sender);
  DirectShowForm.Execute(Sender);
  Hide;
end;

procedure TViewer.SlideTimerTimer(Sender: TObject);
begin
  NextImageClick(Sender);
end;

procedure TViewer.SetPlay(const Value: boolean);
begin
  FPlay := Value;
end;

procedure TViewer.ImageEditor1Click(Sender: TObject);
begin
  if FullScreenNow then
    FullScreenView.Close;


  with EditorsManager.NewEditor do
  begin
    Show;
    OpenFileName(Item.FileName);
  end;
end;

procedure TViewer.Print1Click(Sender: TObject);
var
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    if FileExistsSafe(Item.FileName) or IsDevicePath(Item.FileName) then
      Files.Add(Item.FileName);
    if Files.Count > 0 then
      GetPrintForm(Files);
  finally
    F(Files);
  end;
end;

procedure TViewer.TbDeleteClick(Sender: TObject);
var
  FQuery: TDataSet;
  Files: TStrings;
  EventInfo: TEventValues;
  SQL_, DeviceName, DevicePath: string;
  DeleteID: Integer;
  DItem: IPDItem;
  Device: IPDevice;
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to delete file to recycle bin?'), L('Delete confirmation'),
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    DeleteID := 0;
    if Item.ID <> 0 then
    begin
      FQuery := GetQuery;
      try
        DeleteID := Item.ID;
        SQL_ := Format('DELETE FROM $DB$ WHERE ID = %d', [Item.ID]);
        SetSQL(FQuery, SQL_);
        ExecSQL(FQuery);
      finally
        FreeDS(FQuery);
      end;
    end;

    if not IsDevicePath(Item.FileName) then
    begin
      Files := TStringList.Create;
      try
        Files.Add(Item.FileName);
        SilentDeleteFiles(Handle, Files, True);
      finally
        F(Files);
      end;
    end else
    begin
      DeviceName := ExtractDeviceName(Item.FileName);
      DevicePath := ExtractDeviceItemPath(Item.FileName);
      Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
      if Device <> nil then
      begin
        DItem := Device.GetItemByPath(DevicePath);
        if DItem <> nil then
          if not Device.Delete(DItem.ItemKey) then
            Exit;
      end;
    end;

    CurrentInfo.Delete(CurrentFileNumber);

    if CurrentInfo.Count = 0 then
    begin
      Close;
      DBKernel.DoIDEvent(Self, DeleteID, [EventID_Param_Delete], EventInfo);
      Exit;
    end;
    if CurrentFileNumber > CurrentInfo.Count - 1 then
      CurrentFileNumber := CurrentInfo.Count - 1;

    if Item.ID <> 0 then
      DBKernel.DoIDEvent(Self, DeleteID, [EventID_Param_Delete], EventInfo);
    if CurrentInfo.Count < 2 then
    begin
      TbBack.Enabled := False;
      TbForward.Enabled := False;
      SetProgressPosition(0, 0);
      if FloatPanel <> nil then
        FloatPanel.SetButtonsEnabled(False);
    end else
    begin
      TbBack.Enabled := True;
      TbForward.Enabled := True;
      SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
      if FloatPanel <> nil then
        FloatPanel.SetButtonsEnabled(True);
    end;
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    LoadImage_(Sender, False, 1, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end;
end;

procedure TViewer.TbEncryptClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;
    Item.Crypted := ValidCryptGraphicFile(Item.FileName);
    if not Item.Crypted then
      EncryptPhohos(Self, L('photo'), Info)
    else if ID_OK = MessageBoxDB(Handle, L('Do you really want to decrypt this file?'), L('Decrypt confirmation'),
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      DecryptPhotos(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TViewer.TbEncryptMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if Button = mbRight then
  begin
    P := Point(X, Y);
    P := TControl(Sender).ClientToScreen(P);
    PmSteganography.Popup(P.X, P.Y);
  end;
end;

procedure TViewer.TbExploreClick(Sender: TObject);
var
  E: TCustomExplorerForm;
  F: TDBForm;
begin
  F := TFormCollection.Instance.GetFormByBounds<TCustomExplorerForm>(Self.BoundsRect);
  if F is TCustomExplorerForm then
  begin
    F.Show;
    Close;
    Exit;
  end;
  E := ExplorerManager.NewExplorer(False);
  E.SetOldPath(Item.FileName);
  E.SetPath(ExtractFileDir(Item.FileName));
  E.SetBounds(Self.BoundsRect.Left, Self.BoundsRect.Top, Self.BoundsRect.Width, Self.BoundsRect.Height);
  E.Show;
  Close;
end;

procedure TViewer.TbPageNumberClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PopupMenuPageSelecter.Popup(P.X, P.Y);
end;

procedure TViewer.TbRatingClick(Sender: TObject);
var
  P: TPoint;
  I, Rating: Integer;
begin
  Rating := Item.Rating;
  if Rating < 0 then
    Rating := - Rating div 10;
  GetCursorPos(P);
  for I := 0 to 5 do
    (FindComponent('N' + IntToStr(I) + '1') as TMenuItem).ExSetDefault(False);

  (FindComponent('N' + IntToStr(Rating) + '1') as TMenuItem).ExSetDefault(True);

  RatingPopupMenu.Popup(P.X, P.Y);
end;

procedure TViewer.N51Click(Sender: TObject);
var
  Str: string;
  NewRating: Integer;
  EventInfo: TEventValues;
  FileInfo: TDBPopupMenuInfoRecord;
begin
  Str := StringReplace(TMenuItem(Sender).Caption, '&', '', [RfReplaceAll]);
  NewRating := StrToInt(Str);

  if Item.ID > 0 then
  begin
    SetRating(Item.ID, NewRating);
    EventInfo.Rating := NewRating;
    DBKernel.DoIDEvent(Self, Item.ID, [EventID_Param_Rating], EventInfo);
  end else
  begin
    FileInfo := TDBPopupMenuInfoRecord.Create;
    try
      FileInfo.FileName := Item.FileName;
      FileInfo.Rating := NewRating;
      FileInfo.Include := True;
      UpdaterDB.AddFileEx(FileInfo, True, True);
    finally
      F(FileInfo);
    end;
  end;

end;

procedure TViewer.AeMainHint(Sender: TObject);
begin
  Application.HintPause := 1000;
  Application.HintHidePause := 5000;
end;

procedure TViewer.UpdateInfoAboutFileName(FileName: String;
  Info: TDBPopupMenuInfoRecord);
var
  I: Integer;
begin
  for I := 0 to CurrentInfo.Count - 1 do
    if not CurrentInfo[I].InfoLoaded then
      if CurrentInfo[I].FileName = FileName then
      begin
        CurrentInfo[I].Assign(Info);
        Exit;
      end;
end;

procedure TViewer.SendTo1Click(Sender: TObject);
begin
  ManagerPanels.FillSendToPanelItems(Sender as TMenuItem, SendToItemPopUpMenu);
  SendToSeparator.Visible := (Sender as TMenuItem).Count = 1;
end;

procedure TViewer.SendToItemPopUpMenu(Sender: TObject);
var
  NumberOfPanel: Integer;
  InfoNames: TArStrings;
  InfoIDs: TArInteger;
  Infoloaded: TArBoolean;
  Panel: TFormCont;
begin
  NumberOfPanel := (Sender as TMenuItem).Tag;
  Setlength(InfoNames, 1);
  Setlength(InfoIDs, 0);
  Setlength(Infoloaded, 1);
  Infoloaded[0] := True;
  if Item.ID <> 0 then
  begin
    Setlength(InfoIDs, 1);
    InfoIDs[0] := Item.ID;
  end else
  begin
    Setlength(InfoNames, 1);
    InfoNames[0] := Item.FileName;
  end;

  if NumberOfPanel >= 0 then
    Panel := ManagerPanels[NumberOfPanel]
  else
    Panel := ManagerPanels.NewPanel;

  Panel.Show;
  LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, True, Panel);
  LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, False, Panel);
end;

procedure TViewer.DoUpdateRecordWithDataSet(FileName: string; DS: TDataSet);
var
  I: Integer;
begin
  FileName := AnsiLowerCase(FileName);
  for I := 0 to CurrentInfo.Count - 1 do
    if AnsiLowerCase(CurrentInfo[I].FileName) = FileName then
    begin
      CurrentInfo[I].ReadFromDS(DS);

      if not Loading then
      begin
        if CurrentInfo[I].Rotation <> 0 then
          if I = CurrentFileNumber then
          begin
            ApplyRotate(FbImage, CurrentInfo[I].Rotation);
            RecreateDrawImage(Self);
          end;
      end;
      Break;
    end;

  DisplayRating := Item.Rating;
  TbRotateCCW.Enabled := not IsDevicePath(FileName);
  TbRotateCW.Enabled := not IsDevicePath(FileName);
  UpdateCrypted;
end;

procedure TViewer.DoSetNoDBRecord(Info: TDBPopupMenuInfoRecord);
var
  I: integer;
begin
  for I := 0 to CurrentInfo.Count - 1 do
    if (not CurrentInfo[I].InfoLoaded) or (CurrentInfo[I].ID = 0) then
      if CurrentInfo[I].FileName = Info.FileName then
      begin
        CurrentInfo[I].Assign(Info);
        CurrentInfo[I].InfoLoaded := True;
        Break;
      end;
  DisplayRating := Item.Rating;

  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := TbRotateCCW.Enabled;
  UpdateCrypted;
end;

procedure TViewer.TimerDBWorkTimer(Sender: TObject);
begin
  if not (TbRating.ImageIndex in [20..21]) then
  begin
    TimerDBWork.Enabled := False;
    Exit;
  end;

  if TbRating.ImageIndex = 20 then
    TbRating.ImageIndex := 21
  else
    TbRating.ImageIndex :=20;
end;

procedure TViewer.MakePagesLinks;
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  if not FCreating then
  begin
    TbPageNumber.Visible := FPageCount > 1;
    TbSeparatorPageNumber.Visible := FPageCount > 1;
    BeginScreenUpdate(BottomImage.Handle);
    try
      TbrActions.Visible := True;
      TbrActions.AutoSize := True;
      TbrActions.AutoSize := False;
      TbrActions.Left := ClientWidth div 2 - TbrActions.Width div 2;
    finally
      EndScreenUpdate(BottomImage.Handle, True);
    end;
  end;
  PopupMenuPageSelecter.Items.Clear;
  for I := 0 to FPageCount - 1 do
  begin
    MenuItem := TMenuItem.Create(PopupMenuPageSelecter);
    MenuItem.Caption := IntToStr(I + 1);
    MenuItem.OnClick := OnPageSelecterClick;
    MenuItem.Tag := I;
    if I = FCurrentPage then
      MenuItem.ExSetDefault(True);
    PopupMenuPageSelecter.Items.Add(MenuItem);
  end;
end;

procedure TViewer.OnPageSelecterClick(Sender: TObject);
begin
  FCurrentPage := TMenuItem(Sender).Tag;
  ReloadCurrent;
end;

procedure TViewer.MiRefreshFacesClick(Sender: TObject);
begin
  FFaces.RemoveCache;
  ReloadCurrent;
end;

function TViewer.GetPageCaption: String;
begin
  if FPageCount > 1 then
    Result := Format(L('Page %d from %d'), [FCurrentPage + 1, FPageCount])
  else
    Result := '';
end;

procedure TViewer.SetDisplayRating(const Value: Integer);
begin
  TbRating.Enabled := (not (FolderView and (Item.ID = 0)) and not DBReadOnly) and not IsDevicePath(Item.Path);

  if Value >= 0 then
    TbRating.ImageIndex := 14 + Abs(Value)
  else
    TbRating.ImageIndex := - (Value div 10) + ImlToolBarNormal.Count - 6;
end;

procedure TViewer.SetProgressPosition(Position, Max: Integer);
begin
  if FW7TaskBar <> nil then
  begin
    if Max < 2 then
      FW7TaskBar.SetProgressState(Handle, TBPF_NOPROGRESS)
    else
    begin
      FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
      FW7TaskBar.SetProgressValue(Handle, Position, Max);
    end;
  end;
end;

function TViewer.GetImageRect: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if SbHorisontal.Visible then
  begin
    FX := 0;
  end else
  begin
    if SbVertical.Visible then
      Increment := SbVertical.Width
    else
      Increment := 0;
    FX := Max(0, Round(GetVisibleImageWidth / 2 - Increment - FBImage.Width * Zoom / 2));
  end;
  if SbVertical.Visible then
  begin
    FY := 0;
  end else
  begin
    if SbHorisontal.Visible then
      Increment := SbHorisontal.Height
    else
      Increment := 0;
    FY := Max(0, Round(GetVisibleImageHeight / 2 - Increment - FBImage.Height * Zoom / 2));
  end;
  if SbVertical.Visible then
    Increment := SbVertical.Width
  else
    Increment := 0;
  FW := Round(Min(GetVisibleImageWidth - Increment, FBImage.Width * Zoom));
  if SbHorisontal.Visible then
    Increment := SbHorisontal.Height
  else
    Increment := 0;
  FH := Round(Min(GetVisibleImageHeight - Increment, FBImage.Height * Zoom));
  FH := FH;
  Result := Rect(FX, FY, FW + FX, FH + FY);
end;

function TViewer.BufferPointToImagePoint(P: TPoint): TPoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if ZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if SbHorisontal.Visible then
      Result.X := Round((SbHorisontal.Position + P.X) / Zoom)
    else
      Result.X := Round((P.X - X1) / Zoom);
    if SbVertical.Visible then
      Result.Y := Round((SbVertical.Position + P.Y) / Zoom)
    else
      Result.Y := Round((P.Y - Y1) / Zoom);
  end else
  begin
    if (FBImage.Height = 0) or (FBImage.Width = 0) then
      Exit;
    if (FBImage.Width > GetVisibleImageWidth) or (FBImage.Height > GetVisibleImageHeight) then
    begin
      if FBImage.Width / FBImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FBImage.Width / FBImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FBImage.Height / FBImage.Width));
      end;
    end else
    begin
      Fh := FBImage.Height;
      Fw := FBImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if Fw <> 0 then
      Result.X := Round((P.X - X1) * (FBImage.Width / Fw));
    if Fh <> 0 then
      Result.Y := Round((P.Y - Y1) * (FBImage.Height / Fh));
  end;
end;

function TViewer.ImagePointToBufferPoint(P: TPoint): Tpoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if ZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if SbHorisontal.Visible then
      Result.X := Round(P.X * Zoom - SbHorisontal.Position)
    else
      Result.X := Round((P.X * Zoom + X1));
    if SbVertical.Visible then
      Result.Y := Round(P.Y * Zoom - SbVertical.Position)
    else
      Result.Y := Round((P.Y * Zoom + Y1));
  end else
  begin
    if (FBImage.Height = 0) or (FBImage.Width = 0) then
      Exit;
    if (FBImage.Width > GetVisibleImageWidth) or (FBImage.Height > GetVisibleImageHeight) then
    begin
      if FBImage.Width / FBImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FBImage.Width / FBImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FBImage.Height / FBImage.Width));
      end;
    end else
    begin
      Fh := FBImage.Height;
      Fw := FBImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if FBImage.Width <> 0 then
      Result.X := Round(X1 + P.X * (Fw / FBImage.Width));
    if FBImage.Height <> 0 then
      Result.Y := Round(Y1 + P.Y * (Fh / FBImage.Height));
  end;
end;

function TViewer.GetVisibleImageHeight: Integer;
begin
  Result := ClientHeight - BottomImage.Height;
end;

function TViewer.GetVisibleImageWidth: Integer;
begin
  Result := ClientWidth;
end;

function TViewer.Buffer: TBitmap;
begin
  if (FOverlayBuffer = nil) or FOverlayBuffer.Empty then
    Result := DrawImage
  else
    Result := FOverlayBuffer;
end;

initialization

  Viewer := nil;

end.
