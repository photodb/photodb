unit SlideShow;

interface

uses
  Shellapi, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, Buttons, SaveWindowPos, DB, ComObj, ShlObj,
  AppEvnts, ImgList, UnitDBKernel, jpeg, Win32crc, CommCtrl,
  StdCtrls, math, ToolWin, ComCtrls, Tlayered_Bitmap, GraphicCrypt,
  FormManegerUnit, UnitUpdateDBThread, DBCMenu, dolphin_db, Searching,
  ShellContextMenu, DropSource, DropTarget, GIFImage, pngimage, uFileUtils,
  Effects, GraphicsCool, UnitUpdateDBObject, DragDropFile, DragDrop,
  uVistaFuncs, UnitDBDeclare, UnitFileExistsThread, UnitDBCommonGraphics,
  UnitCDMappingSupport, uThreadForm, uLogger, uConstants, uTime, uFastLoad,
  uResources, UnitDBCommon, uW7TaskBar, uMemory, UnitBitmapImageList,
  uListViewUtils, uFormListView, uImageSource, uDBPopupMenuInfo, uPNGUtils,
  uGraphicUtils, uShellIntegration, uSysUtils, uDBUtils, uRuntime,
  uDBBaseTypes, uViewerTypes, uSettings, uAssociations;

type
  TRotatingImageInfo = record
    FileName: string;
    Rotating: Integer;
    Enabled: Boolean;
  end;

type
  TViewer = class(TViewerForm)
    PopupMenu1: TPopupMenu;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    N1: TMenuItem;
    Shell1: TMenuItem;
    N2: TMenuItem;
    FullScreen1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    N4: TMenuItem;
    MTimer1: TMenuItem;
    MouseTimer: TTimer;
    DBItem1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    WaitImageTimer: TTimer;
    AddToDB1: TMenuItem;
    Onlythisfile1: TMenuItem;
    AllFolder1: TMenuItem;
    GoToSearchWindow1: TMenuItem;
    Explorer1: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    SetasDesktopWallpaper1: TMenuItem;
    Copy1: TMenuItem;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    Panel1: TPanel;
    ImageList1: TImageList;
    ImageList2: TImageList;
    ImageList3: TImageList;
    N5: TMenuItem;
    ZoomOut1: TMenuItem;
    ZoomIn1: TMenuItem;
    RealSize1: TMenuItem;
    BestSize1: TMenuItem;
    BottomImage: TPanel;
    ToolsBar: TPanel;
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
    DestroyTimer: TTimer;
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
    RatingPopupMenu: TPopupMenu;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    SendTo1: TMenuItem;
    N8: TMenuItem;
    Tools1: TMenuItem;
    NewPanel1: TMenuItem;
    TimerDBWork: TTimer;
    TbSeparatorPageNumber: TToolButton;
    TbPageNumber: TToolButton;
    PopupMenuPageSelecter: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    function LoadImage_(Sender: TObject; FileName : String; Rotate : integer; FullImage : Boolean; BeginZoom : Extended; RealZoom : Boolean) : boolean;
    procedure RecreateDrawImage(Sender: TObject);
    procedure FormResize(Sender: TObject);
    Procedure Next_(Sender: TObject);
    Procedure Previous_(Sender: TObject);
    procedure NextImageClick(Sender: TObject);
    procedure PreviousImageClick(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FullScreen1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure newpicture(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure MTimer1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure LoadListImages(List : TstringList);
    Procedure ShowFile(FileName : String);
    Procedure ShowFolder(Files : Tstrings; CurrentN : integer);
    Procedure ShowFolderA(FileName : string; ShowPrivate : Boolean);
    Procedure UpdateRecord(FileNo: integer);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure WaitImageTimerTimer(Sender: TObject);
    Procedure DoWaitToImage(Sender: TObject);
    Procedure EndWaitToImage(Sender: TObject);
    procedure Onlythisfile1Click(Sender: TObject);
    procedure AllFolder1Click(Sender: TObject);
    procedure GoToSearchWindow1Click(Sender: TObject);
    procedure Explorer1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Copy1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
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
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure ReloadCurrent;
    procedure Pause;
    procedure DestroyTimerTimer(Sender: TObject);
    procedure ImageFrameTimerTimer(Sender: TObject);
    procedure UpdateInfo(SID : TGUID; Info : TDBPopupMenuInfoRecord);
    procedure TbSlideShowClick(Sender: TObject);
    procedure SlideTimerTimer(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure TbDeleteClick(Sender: TObject);
    procedure TbRatingClick(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure UpdateInfoAboutFileName(FileName : String; info : TDBPopupMenuInfoRecord);
    procedure SendTo1Click(Sender: TObject);
    procedure NewPanel1Click(Sender: TObject);
    procedure TimerDBWorkTimer(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    WindowsMenuTickCount : Cardinal;
    FImageExists: Boolean;
    FStaticImage: Boolean;
    FLoading: Boolean;
    AnimatedImage : TGraphic;
    SlideNO : Integer;
    AnimatedBuffer : TBitmap;
    FValidImages: Integer;
    FForwardThreadExists: Boolean;
    FForwardThreadSID: TGUID;
    FForwardThreadNeeds: Boolean;
    FForwardThreadFileName: string;
    FTransparentImage: Boolean;
    FCurrentlyLoadedFile: String;
    FPlay: boolean;
    LockEventRotateFileList : TStrings;
    LastZValue : Extended;
    FCreating : Boolean;
    FRotatingImageInfo : TRotatingImageInfo;
    FW7TaskBar : ITaskbarList3;
    FProgressMessage : Cardinal;
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
    procedure SetDisplayRating(const Value: Integer);
  protected
    { Protected declarations }
    IncGrayScale: Integer;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    function GetFormID : string; override;
    function GetItem: TDBPopupMenuInfoRecord; override;
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
    WaitImage: TBitmap;
    FSID: TGUID;
    RealImageWidth: Integer;
    RealImageHeight: Integer;
    RealZoomInc: Extended;
    DrawImage: TBitmap;
    FBImage: TBitmap;
    Fcsrbmp, FNewCsrBmp, Fnowcsrbmp: TBitmap;
    constructor Create(AOwner: TComponent); override;
    function GetImage(FileName : string; Bitmap : TBitmap) : Boolean;
    procedure ExecuteDirectoryWithFileOnThread(FileName : String);
    function Execute(Sender: TObject; Info: TDBPopupMenuInfo) : boolean;
    function ExecuteW(Sender: TObject; Info : TDBPopupMenuInfo; LoadBaseFile : String) : boolean;
    procedure LoadLanguage;
    procedure LoadPopupMenuLanguage;
    procedure ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
    function HeightW : Integer;
    function GetImageRectA : TRect;
    procedure RecreateImLists;
    function GetSID : TGUID;
    procedure SetStaticImage(Image : TBitmap; Transparent : Boolean);
    procedure SetAnimatedImage(Image : TGraphic);
    procedure NextSlide;
    function GetFirstImageNO : integer;
    function GetNextImageNO : integer;
    function GetPreviousImageNOX(NO : Integer) : integer;
    function GetNextImageNOX(NO : Integer) : integer;
    procedure LoadingFailed(FileName : String);
    function GetPreviousImageNO : integer;
    procedure PrepareNextImage;
    procedure SetFullImageState(State : Boolean; BeginZoom : Extended; Pages, Page : integer);
    procedure DoUpdateRecordWithDataSet(FileName : string; DS : TDataSet);
    procedure DoSetNoDBRecord(FileName : string);
    procedure MakePagesLinks;
    procedure SetProgressPosition(Position, Max : Integer);
    function GetPageCaption : String;
    property DisplayRating : Integer write SetDisplayRating;
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
  UnitUpdateDB, PropertyForm, SlideShowFullScreen,
  ExplorerUnit, FloatPanelFullScreen, UnitSizeResizerForm,
  DX_Alpha, UnitViewerThread, ImEditor, PrintMainForm, UnitFormCont,
  UnitLoadFilesToPanel, CommonDBSupport, UnitSlideShowScanDirectoryThread,
  UnitSlideShowUpdateInfoThread;

{$R *.dfm}

procedure TViewer.FormCreate(Sender: TObject);
begin
  TW.I.Start('TViewer.FormCreate');
  CurrentInfo := TDBPopupMenuInfo.Create;
  FCreating := True;
  FCurrentPage := 0;
  FPageCount := 1;
  FRotatingImageInfo.Enabled := False;
  WaitingList := False;
  LastZValue := 1;
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
  DBCanDrag := False;
  DropFileTarget1.Register(Self);
  SlideTimer.Interval := Math.Min(Math.Max(Settings.ReadInteger('Options', 'FullScreen_SlideDelay', 40), 1), 100) * 100;
  IncGrayScale := Math.Min(Math.Max(Settings.ReadInteger('Options', 'SlideShow_GrayScale', 20), 1), 100);
  FullScreenNow := False;
  SlideShowNow := False;
  TbrActions.DoubleBuffered := True;
  Drawimage := Tbitmap.Create;
  FbImage := TBitmap.Create;
  FbImage.PixelFormat := pf24bit;
  Drawimage.PixelFormat := pf24bit;
  TW.I.Start('fcsrbmp');
  Fcsrbmp := TBitmap.Create;
  Fcsrbmp.PixelFormat := pf24bit;
  Fcsrbmp.Canvas.Brush.Color := 0;
  Fcsrbmp.Canvas.Pen.Color := 0;
  TW.I.Start('fnewcsrbmp');
  WaitImage := TBitmap.Create;
  WaitImage.PixelFormat := pf24bit;
  FNewCsrBmp := TBitmap.Create;
  FNewCsrBmp.PixelFormat := pf24bit;
  FNewCsrBmp.Canvas.Brush.Color := 0;
  FNewCsrBmp.Canvas.Pen.Color := 0;
  Fnowcsrbmp := TBitmap.Create;
  Fnowcsrbmp.PixelFormat := pf24bit;
  Fnowcsrbmp.Assign(FNewCsrBmp);

  TW.I.Start('AnimatedBuffer');
  AnimatedBuffer := TBitmap.Create;
  AnimatedBuffer.PixelFormat := pf24bit;
  MTimer1.Caption := L('Stop timer');
  MTimer1.ImageIndex := DB_IC_PAUSE;

  SaveWindowPos1.Key := RegRoot + 'SlideShow';
  SaveWindowPos1.SetPosition;
  PopupMenu1.Images := DBKernel.ImageList;
  Shell1.ImageIndex := DB_IC_SHELL;
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
  ZoomOut1.ImageIndex := DB_IC_ZOOMOUT;
  ZoomIn1.ImageIndex := DB_IC_ZOOMIN;
  RealSize1.ImageIndex := DB_IC_REALSIZE;
  BestSize1.ImageIndex := DB_IC_BESTSIZE;
  Properties1.ImageIndex := DB_IC_PROPERTIES;
  Stretch1.ImageIndex := DB_IC_WALLPAPER;
  Center1.ImageIndex := DB_IC_WALLPAPER;
  Tile1.ImageIndex := DB_IC_WALLPAPER;
  RotateCCW1.ImageIndex := DB_IC_ROTETED_270;
  RotateCW1.ImageIndex := DB_IC_ROTETED_90;
  Rotateon1801.ImageIndex := DB_IC_ROTETED_180;
  Rotate1.ImageIndex := DB_IC_ROTETED_0;
  Resize1.ImageIndex := DB_IC_RESIZE;
  SlideShow1.ImageIndex := DB_IC_DO_SLIDE_SHOW;
  ImageEditor1.ImageIndex := DB_IC_IMEDITOR;
  Print1.ImageIndex := DB_IC_PRINTER;
  SendTo1.ImageIndex := DB_IC_SEND;
  Tools1.ImageIndex:=DB_IC_OTHER_TOOLS;
  NewPanel1.ImageIndex:=DB_IC_PANEL;

  DBKernel.RegisterChangesID(Self,ChangedDBDataByID);
  TW.I.Start('LoadLanguage');
  LoadLanguage;

  TW.I.Start('LoadCursor');
  CursorZoomIn := LoadCursor(HInstance,'ZOOMIN');
  CursorZoomOut := LoadCursor(HInstance,'ZOOMOUT');
  Screen.Cursors[CursorZoomInNo]  := CursorZoomIn;
  Screen.Cursors[CursorZoomOutNo] := CursorZoomOut;
  TW.I.Start('MakePagesLinks');
  MakePagesLinks;
  FCreating := False;
  TW.I.Start('RecreateImLists');
  RecreateImLists;
  TW.I.Start('RecreateImLists - END');
  FProgressMessage := RegisterWindowMessage('SLIDE_SHOW_PROGRESS');
  PostMessage(Handle, FProgressMessage, 0, 0);
end;

function TViewer.LoadImage_(Sender: TObject; FileName: String; Rotate : integer; FullImage : Boolean; BeginZoom : Extended; RealZoom : Boolean) : boolean;
var
  Text: string;
  NeedsUpdating: Boolean;
begin
  Result := False;

  SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
  if (not Item.InfoLoaded) and (Item.ID = 0) then
    NeedsUpdating := True
  else
    NeedsUpdating := False;

  Item.InfoLoaded := True;
  DoWaitToImage(Sender);
  Rotate := Item.Rotation;

  if CheckFileExistsWithSleep(FileName, False) then
  begin
    Caption := Format(L('View') + ' - %s   [%d/%d]', [ExtractFileName(FileName), CurrentFileNumber + 1,
      CurrentInfo.Count]);

    DisplayRating := Item.Rating;
    TbRotateCCW.Enabled := True;
    TbRotateCW.Enabled := True;

    FSID := GetGUID;
  if not ForwardThreadExists or (ForwardThreadFileName <> FileName) or (CurrentInfo.Count = 0)
      or FullImage then
    begin
      if NeedsUpdating then
      begin
        DisplayRating := Item.Rating;
        TimerDBWork.Enabled := True;
        TbRotateCCW.Enabled := False;
        TbRotateCW.Enabled := False;
        TSlideShowUpdateInfoThread.Create(Self, StateID, Item.FileName);
        Rotate := 0;
      end;

      Result := True;
      if not RealZoom then
        TViewerThread.Create(Self, FileName, Rotate, FullImage, 1, FSID, False, False, FCurrentPage)
      else
        TViewerThread.Create(Self, FileName, Rotate, FullImage, BeginZoom, FSID, False, False, FCurrentPage);
      ForwardThreadExists := False;
    end else
      ForwardThreadNeeds := True;
  end else
  begin
    Caption := Format(L('View') + ' - %s   [%d/%d]', [ExtractFileName(FileName), CurrentFileNumber + 1,
      CurrentInfo.Count]);
    DisplayRating := Item.ID;

    TbRotateCCW.Enabled := True;
    TbRotateCW.Enabled := True;

    Text := Format(L('File %s not found!'), [Mince(FileName, 80)]);
    FbImage.Canvas.Rectangle(0, 0, FbImage.Width, FbImage.Height);
    FbImage.Width := FbImage.Canvas.TextWidth(Text);
    FbImage.Height := FbImage.Canvas.TextHeight(Text);
    FbImage.Canvas.TextOut(0, 0, Text);
    RecreateDrawImage(Sender);
    FormPaint(Sender);
    Result := False;
  end;
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
  Text_error_out: string;

  procedure DrawRect(X1, Y1, X2, Y2: Integer);
  begin
    if TransparentImage then
    begin
      Drawimage.Canvas.Brush.Color := ClBtnFace;
      Drawimage.Canvas.Pen.Color := 0;
      Drawimage.Canvas.Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
    end;
  end;

begin
  Z := 0;
  FileName := FCurrentlyLoadedFile;
  if FullScreenNow then
  begin
    DrawImage.Width := Screen.Width;
    DrawImage.Height := Screen.Height;
    DrawImage.Canvas.Brush.Color := 0;
    DrawImage.Canvas.Pen.Color := 0;
    DrawImage.Canvas.Rectangle(0, 0, DrawImage.Width, DrawImage.Height);
    if (FbImage.Height = 0) or (FbImage.Width = 0) then
      Exit;
    Fw := FbImage.Width;
    Fh := FbImage.Height;
    ProportionalSize(Screen.Width, Screen.Height, Fw, Fh);
    if ImageExists then
    begin
      if False { DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True) } then
      begin
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
          StretchCool(Screen.Width div 2 - Fw div 2, Screen.Height div 2 - Fh div 2, Fw, Fh, FbImage, DrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := pf24bit;
            TempImage.Width := Fw;
            TempImage.Height := Fh;
            SmoothResize(Fw, Fh, FbImage, TempImage);
            DrawImage.Canvas.Draw(Screen.Width div 2 - Fw div 2, Screen.Height div 2 - Fh div 2, TempImage);
          finally
            F(TempImage);
          end;
        end;
      end else
      begin
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.StretchDraw(Rect(Screen.Width div 2 - Fw div 2, Screen.Height div 2 - Fh div 2,
            Screen.Width div 2 - Fw div 2 + Fw, Screen.Height div 2 - Fh div 2 + Fh), FbImage);
      end;
    end else
    begin
      DrawImage.Canvas.Font.Color := $FFFFFF;
      Text_error_out := L('Error showing image!');
      DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(Text_error_out) div 2,
        DrawImage.Height div 2 - DrawImage.Canvas.Textheight(Text_error_out) div 2, Text_error_out);
      DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(FileName) div 2,
        DrawImage.Height div 2 - DrawImage.Canvas.Textheight(Text_error_out) div 2 + DrawImage.Canvas.Textheight
          (FileName) + 4, FileName);
    end;
    if FullScreenView <> nil then
      FullScreenView.Canvas.Draw(0, 0, DrawImage);
    Exit;
  end;
  DrawImage.Width := Clientwidth;
  DrawImage.Height := HeightW;
  DrawImage.Canvas.Brush.Color := ClBtnFace;
  DrawImage.Canvas.Pen.Color := ClBtnFace;
  DrawImage.Canvas.Rectangle(0, 0, DrawImage.Width, DrawImage.Height);
  if (FbImage.Height = 0) or (FbImage.Width = 0) then
    Exit;
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
      if ZoomerOn and not WaitImageTimer.Enabled then
      begin
        DrawRect(ImRect.Left, ImRect.Top, ImRect.Right, ImRect.Bottom);
        if Zoom <= 1 then
        begin
          if (Zoom < ZoomSmoothMin) then
            StretchCoolW(Zx, Zy, Zw, Zh, Rect(Round(ScrollBar1.Position / Zoom), Round(ScrollBar2.Position / Zoom),
                Round((ScrollBar1.Position + Zw) / Zoom), Round((ScrollBar2.Position + Zh) / Zoom)), FbImage, DrawImage)
          else
          begin
            ACopyRect := Rect(Round(ScrollBar1.Position / Zoom), Round(ScrollBar2.Position / Zoom),
              Round((ScrollBar1.Position + Zw) / Zoom), Round((ScrollBar2.Position + Zh) / Zoom));
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
          Interpolate(Zx, Zy, Zw, Zh, Rect(Round(ScrollBar1.Position / Zoom), Round(ScrollBar2.Position / Zoom),
              Round((ScrollBar1.Position + Zw) / Zoom), Round((ScrollBar2.Position + Zh) / Zoom)), FbImage, DrawImage);
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
    end
    else
    begin
      if ZoomerOn and not WaitImageTimer.Enabled then
      begin
        ImRect := Rect(Round(ScrollBar1.Position / Zoom), Round((ScrollBar2.Position) / Zoom),
          Round((ScrollBar1.Position + Zw) / Zoom), Round((ScrollBar2.Position + Zh) / Zoom));
        BeginRect := GetImageRectA;
        DrawRect(BeginRect.Left, BeginRect.Top, BeginRect.Right, BeginRect.Bottom);
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.CopyMode := SRCCOPY;
        DrawImage.Canvas.CopyRect(BeginRect, FbImage.Canvas, ImRect);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
        DrawImage.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FbImage);
      end;
    end;
  end else
  begin
    DrawImage.Canvas.Font.Color := 0;
    DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(Text_error_out) div 2,
      DrawImage.Height div 2 - DrawImage.Canvas.Textheight(Text_error_out) div 2, Text_error_out);
    DrawImage.Canvas.TextOut(DrawImage.Width div 2 - DrawImage.Canvas.TextWidth(FileName) div 2,
      DrawImage.Height div 2 - DrawImage.Canvas.Textheight(Text_error_out) div 2 + DrawImage.Canvas.Textheight
        (FileName) + 4, FileName);
  end;
  if WaitImageTimer.Enabled and FImageExists then
  begin
    TW.I.Start('WaitImageTimer');
    WaitImage.Width := DrawImage.Width;
    WaitImage.Height := DrawImage.Height;
    GrayScaleImage(DrawImage, WaitImage, WaitGrayScale);
    Canvas.Draw(0, 0, WaitImage);
    TW.I.Start('WaitImageTimer - end');
    Exit;
  end;
  if (not WaitImageTimer.Enabled) and (RealImageHeight * RealImageWidth <> 0) then
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
  FormPaint(Sender);
end;

procedure TViewer.FormResize(Sender: TObject);
begin
  TW.I.Start('TViewer.FormResize');
  if FCreating then
    Exit;
  DrawImage.Width := ClientWidth;
  DrawImage.Height := HeightW;
  if not WaitImageTimer.Enabled then
    ReAllignScrolls(False, Point(0, 0));
  RecreateDrawImage(Sender);
  ToolsBar.Left := ClientWidth div 2 - ToolsBar.Width div 2;
  BottomImage.Top := ClientHeight - ToolsBar.Height;
  BottomImage.Width := ClientWidth;
  BottomImage.Height := ToolsBar.Height;
  Canvas.Brush.Color := clBtnFace;
  Canvas.Pen.Color := clBtnFace;
  Canvas.Rectangle(0, HeightW, ClientWidth, ClientHeight);
  if not StaticImage then
  begin
    Canvas.Rectangle(0, 0, Width, HeightW);
    FormPaint(Sender);
  end;
  TbrActions.Refresh;
  TbrActions.Realign;
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
    if Item.Crypted or ValidCryptGraphicFile(Item.FileName)
      then
      if DBKernel.FindPasswordForCryptImageFile(Item.FileName) = '' then
        Exit;
  if not SlideShowNow then
    LoadImage_(Sender, Item.FileName, Item.Rotation, False,
      Zoom, False)
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
    LoadImage_(Sender, Item.FileName, Item.Rotation, False,
      Zoom, False);
end;

procedure TViewer.NextImageClick(Sender: TObject);
begin
  if not SlideShowNow then
  begin
    if FullScreenNow then
      if Play then
      begin
        SlideTimer.Enabled := False;
        SlideTimer.Enabled := True;
      end;
    Next_(Sender);
  end else
  begin
    if DirectShowForm <> nil then
      DirectShowForm.Next(False);
  end;
end;

procedure TViewer.PreviousImageClick(Sender: TObject);
begin
  if not SlideShowNow then
  begin
    if FullScreenNow then
      if Play then
      begin
        SlideTimer.Enabled := False;
        SlideTimer.Enabled := True;
      end;
    Previous_(Sender);
  end else
  begin
    if DirectShowForm <> nil then
      DirectShowForm.Previous;
  end;
end;

procedure TViewer.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(Item.FileName), nil, nil, SW_NORMAL);
end;

procedure TViewer.FormDestroy(Sender: TObject);
begin
  F(CurrentInfo);
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;
  F(FbImage);
  F(DrawImage);
  F(WaitImage);
  F(Fcsrbmp);
  F(FNewCsrBmp);
  F(Fnowcsrbmp);
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
  WaitImageTimer.Enabled := False;
  RecreateDrawImage(Sender);
  if FullScreenView = nil then
    Application.CreateForm(TFullScreenView, FullScreenView);
  MTimer1.ImageIndex := DB_IC_PAUSE;
  MTimer1Click(Sender);
  FullScreenView.Show;
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
  end;
  if SlideShowNow then
  begin
    R(FloatPanel);
    SlideShowNow := False;
    Loading := True;
    ImageExists := False;
    LoadImage_(Sender, Item.FileName, Item.Rotation, False,
      Zoom, False);
    if DirectShowForm <> nil then
      DirectShowForm.Close;
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
  if WaitImageTimer.Enabled then
  begin
    if FImageExists then
      Canvas.Draw(0, 0, WaitImage)
  end else
    Canvas.Draw(0, 0, DrawImage);
end;

procedure TViewer.NewPicture(Sender: TObject);
var
  Fh, Fw, X1, X2, Y1, Y2: Integer;
begin
  if not SlideShowNow then
  begin
    Fcsrbmp.Assign(Fnowcsrbmp);
    FNewCsrBmp.Canvas.Rectangle(0, 0, FNewCsrBmp.Width, FNewCsrBmp.Height);
    if (FbImage.Height = 0) or (FbImage.Width = 0) then
      Exit;
    if (FbImage.Width > FNewCsrBmp.Width) or (FbImage.Height > FNewCsrBmp.Height) then
    begin
      if FbImage.Width / FbImage.Height < FNewCsrBmp.Width / FNewCsrBmp.Height then
      begin
        Fh := FNewCsrBmp.Height;
        Fw := Round(FNewCsrBmp.Height * (FbImage.Width / FbImage.Height));
      end else
      begin
        Fw := FNewCsrBmp.Width;
        Fh := Round(FNewCsrBmp.Width * (FbImage.Height / FbImage.Width));
      end;
    end else
    begin
      Fh := FbImage.Height;
      Fw := FbImage.Width;
    end;
    X1 := Screen.Width div 2 - Fw div 2;
    Y1 := Screen.Height div 2 - Fh div 2;
    X2 := Screen.Width div 2 + Fw div 2;
    Y2 := Screen.Height div 2 + Fh div 2;
    if Settings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True) then
      StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FbImage, FNewCsrBmp)
    else
      FNewCsrBmp.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FbImage);
  end else
  begin
    if DirectShowForm = nil then
      Exit;
    FNewCsrBmp.Canvas.Rectangle(0, 0, FNewCsrBmp.Width, FNewCsrBmp.Height);
    if (FbImage.Height = 0) or (FbImage.Width = 0) then
      Exit;
    if (FbImage.Width > FNewCsrBmp.Width) or (FbImage.Height > FNewCsrBmp.Height) then
    begin
      if FbImage.Width / FbImage.Height < FNewCsrBmp.Width / FNewCsrBmp.Height then
      begin
        Fh := FNewCsrBmp.Height;
        Fw := Round(FNewCsrBmp.Height * (FbImage.Width / FbImage.Height));
      end else
      begin
        Fw := FNewCsrBmp.Width;
        Fh := Round(FNewCsrBmp.Width * (FbImage.Height / FbImage.Width));
      end;
    end else
    begin
      Fh := FbImage.Height;
      Fw := FbImage.Width;
    end;
    X1 := Screen.Width div 2 - Fw div 2;
    Y1 := Screen.Height div 2 - Fh div 2;
    X2 := Screen.Width div 2 + Fw div 2;
    Y2 := Screen.Height div 2 + Fh div 2;
    if Settings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True) then
      StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FbImage, FNewCsrBmp)
    else
      FNewCsrBmp.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FbImage);
    if DirectShowForm.FirstLoad then
      DirectShowForm.SetFirstImage(FNewCsrBmp)
    else
      DirectShowForm.NewImage(FNewCsrBmp);
  end;
end;

procedure TViewer.PopupMenu1Popup(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
  I: Integer;

  procedure InitializeInfo;
  begin
    MenuRecord := CurrentInfo[CurrentFileNumber].Copy;
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
      PopupMenu1.Items.Delete(N2.MenuIndex + 1);
    if Item.ID <> 0 then
    begin
      AddToDB1.Visible := False;
      DBItem1.Visible := True;
      DBItem1.Caption := Format(L('DB Item [%d]'), [Item.ID]);
      InitializeInfo;
      TDBPopupMenu.Instance.AddDBContMenu(Self, DBItem1, Info);
    end else
    begin
      if Settings.ReadBool('Options', 'UseUserMenuForViewer', True) then
        if not(SlideShowNow or FullScreenNow) then
        begin
          InitializeInfo;
          TDBPopupMenu.Instance.SetInfo(Self, Info);
          TDBPopupMenu.Instance.AddUserMenu(PopupMenu1.Items, True, N2.MenuIndex + 1);
        end;

      AddToDB1.Visible := True;
      DBItem1.Visible := False;
    end;
    FullScreen1.Visible := not(FullScreenNow or SlideShowNow);
    SlideShow1.Visible := not(FullScreenNow or SlideShowNow);
    begin
      AddToDB1.Visible := AddToDB1.Visible and not(SlideShowNow or FullScreenNow) and not Item.Crypted;
      ZoomOut1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      ZoomIn1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      RealSize1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      BestSize1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      DBItem1.Visible := not(SlideShowNow or FullScreenNow) and (Item.ID <> 0);
      SetasDesktopWallpaper1.Visible := not(SlideShowNow) and ImageExists and not Item.Crypted and IsWallpaper(Item.FileName);
      Rotate1.Visible := not(SlideShowNow) and ImageExists;
      Properties1.Visible := not(SlideShowNow or FullScreenNow);
      GoToSearchWindow1.Visible := not(SlideShowNow);
      Explorer1.Visible := not(SlideShowNow);
      Resize1.Visible := not(SlideShowNow or FullScreenNow) and ImageExists;
      Shell1.Visible := not(SlideShowNow or FullScreenNow);
      Print1.Visible := not(SlideShowNow) and ImageExists;
      ImageEditor1.Visible := not(SlideShowNow) and ImageExists;
      SendTo1.Visible := not(SlideShowNow) and ImageExists and (Item.ID = 0);
    end;
    Tools1.Visible := Resize1.Visible or Print1.Visible or ImageEditor1.Visible or GoToSearchWindow1.Visible;
    NewPanel1.Visible := Tools1.Visible;
  finally
    F(Info);
  end;
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
  P : TPoint;
  DragImage : TBitmap;
  BitmapImageList : TBitmapImageList;
  W, H : Integer;
  FileName : string;
begin
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

        BitmapImageList := TBitmapImageList.Create;
        try
          DropFileSource1.ShowImage := FImageExists;
          W := FbImage.Width;
          H := FbImage.Height;
          ProportionalSize(ThImageSize, ThImageSize, W, H);
          DragImage := TBitmap.Create;
          try
            DoResize(W, H, FbImage, DragImage);
            BitmapImageList.AddBitmap(DragImage, False);
            CreateDragImageEx(nil, DragImageList, BitmapImageList, clGradientActiveCaption,
              clGradientInactiveCaption, clHighlight, Font, ExtractFileName(FileName));
          finally
            F(DragImage);
          end;
        finally
          F(BitmapImageList);
        end;

        DropFileSource1.ImageIndex := 0;
        DropFileSource1.Execute;
        FormPaint(Self);
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

  if [EventID_Param_Rotate, EventID_Param_Image, EventID_Param_Name] * Params <> [] then
  begin
    for I := 0 to LockEventRotateFileList.Count - 1 do
      if AnsiLowerCase(Value.name) = LockEventRotateFileList[I] then
      begin
        LockEventRotateFileList.Delete(I);
        Exit;
      end;
  end;

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
        CurrentInfo[I].Links := '';

        if I = CurrentFileNumber then
          DisplayRating := CurrentInfo[I].Rating;
        Break;
      end;
    Exit;
  end;

 if ID>0 then
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
          CurrentInfo[I].Crypted := Value.Crypt;
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
            LoadImage_(Sender, CurrentInfo[I].FileName,
              CurrentInfo[I].Rotation, False, Zoom, False);
          Exit;
        end;
      end;
  end;
  if (EventID_Param_Name in Params) then
  begin
    if Item.FileName = Value.name then
    begin
      if Value.NewName <> '' then
        Item.FileName := Value.NewName;
      Item.InfoLoaded := False;
      LoadImage_(Sender, Item.FileName, Item.Rotation,
        False, Zoom, False);
      Exit;
    end;

    if ID = -1 then
      for I := 0 to CurrentInfo.Count - 1 do
        if CurrentInfo[I].FileName = Value.NewName then
        begin
          CurrentInfo[I].InfoLoaded := False;
          if I = CurrentFileNumber then
            LoadImage_(Sender, CurrentInfo[I].FileName, CurrentInfo[I].Rotation, False, Zoom, False);
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
      LoadImage_(Sender, Item.FileName, Item.Rotation,
        False, Zoom, False);
  end;
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
    for I := 0 to List.Count - 1 do
    begin
      FileName := List[I];
      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName))
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
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
  CurrentFileNumber := 0;
  LoadImage_(nil, Item.FileName, Item.Rotation, False, Zoom, False);
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
    Shell1.Caption := L('Execute');
    Copy1.Caption := L('Copy');
    FullScreen1.Caption := L('Full screen');
    Tools1.Caption := L('Tools');
    DBItem1.Caption := L('DB item');
    AddToDB1.Caption := L('Add to DB');
    GoToSearchWindow1.Caption := L('Search photos');
    Explorer1.Caption := L('Explorer');
    Exit1.Caption := L('Exit');
    Onlythisfile1.Caption := L('Only this file');
    AllFolder1.Caption := L('Full directory with this file');
    ZoomOut1.Caption := L('Zoom in');
    ZoomIn1.Caption := L('Zoom out');
    RealSize1.Caption := L('Real size');
    BestSize1.Caption := L('Fit to window');
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
    NewPanel1.Caption := L('New panel');
  finally
    EndTranslate;
  end;
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
  DS : TDataSet;
  FileName : string;
begin
  DS := GetQuery;
  try
    FileName := CurrentInfo[FileNo].FileName;
    SetSQL(DS, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName))
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

procedure TViewer.WndProc(var Message: TMessage);
begin
  inherited;

  if Message.Msg = WM_COMMAND then
  begin
    if Message.WParamLo = 40001 then
      Previous_(Self);

    if Message.WParamLo = 40002 then
      Next_(Self);
  end;
end;

procedure TViewer.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  FButtons: array[0..1] of TThumbButton;
begin
  if msg.message = FProgressMessage then
  begin
    FW7TaskBar := CreateTaskBarInstance;
    if FW7TaskBar <> nil then
    begin
      FButtons[0].iId := 40001;
      FButtons[0].dwFlags := THBF_ENABLED;
      FButtons[0].hIcon := LoadImage(DBKernel.IconDllInstance, PChar('Z_PREVIOUS_NORM'), IMAGE_ICON, 16, 16, 0);
	      StringToWideChar(L('Back'), FButtons[0].szTip, 260);
	    FButtons[0].dwMask := THB_ICON or THB_FLAGS or THB_TOOLTIP;

	    FButtons[1].iId := 40002;
	    FButtons[1].dwFlags := THBF_ENABLED;
	    FButtons[1].hIcon := LoadImage(DBKernel.IconDllInstance, PChar('Z_NEXT_NORM'), IMAGE_ICON, 16, 16, 0);
	      StringToWideChar(L('Forward'), FButtons[1].szTip, 260);
	    FButtons[1].dwMask := THB_ICON or THB_FLAGS or THB_TOOLTIP;
      FW7TaskBar.ThumbBarAddButtons(Handle, 2, @FButtons);

      SetProgressPosition(CurrentFileNumber + 1, CurrentInfo.Count);
    end;
  end;

  if not Active or SlideShowNow or FullScreenNow then
    Exit;

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

    if (Msg.wParam = Byte(' ')) then
      Next_(Self);

    if CtrlKeyDown then
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
      if Msg.wParam = Byte('E') then ImageEditor1Click(Self);
      if Msg.wParam = Byte('Z') then Properties1Click(Self);

      if (Msg.wParam = Byte('0')) or (Msg.wParam = Byte(VK_NUMPAD0)) then N51Click(N01);
      if (Msg.wParam = Byte('1')) or (Msg.wParam = Byte(VK_NUMPAD1)) then N51Click(N11);
      if (Msg.wParam = Byte('2')) or (Msg.wParam = Byte(VK_NUMPAD2)) then N51Click(N21);
      if (Msg.wParam = Byte('3')) or (Msg.wParam = Byte(VK_NUMPAD3)) then N51Click(N31);
      if (Msg.wParam = Byte('4')) or (Msg.wParam = Byte(VK_NUMPAD4)) then N51Click(N41);
      if (Msg.wParam = Byte('5')) or (Msg.wParam = Byte(VK_NUMPAD5)) then N51Click(N51);
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
    if (Msg.Hwnd = BottomImage.Handle) or (Msg.Hwnd = TbrActions.Handle) or (Msg.Hwnd = ScrollBar1.Handle) or
      (Msg.Hwnd = ScrollBar2.Handle) then
      Msg.message := 0;

  if (Msg.message = WM_MOUSEWHEEL) then
  begin
    if ZoomerOn or CtrlKeyDown or ShiftKeyDown then
    begin
      if Msg.WParam > 0 then
        TbZoomOutClick(Self)
      else
        TbZoomInClick(Self);
      Msg.message := 0;
    end else
    begin
      if Msg.WParam > 0 then
        Previous_(Self)
      else
        Next_(Self);
    end;
  end;
end;

procedure TViewer.ShowFolderA(FileName : string; ShowPrivate : Boolean);
var
  N: Integer;
  Info: TDBPopupMenuInfo;
begin
  if FileExists(FileName) then
  begin
    FileName := LongFileName(FileName);
    Info := TDBPopupMenuInfo.Create;
    try
      GetFileListByMask(FileName, TFileAssociations.Instance.ExtensionList, Info, N, ShowPrivate);
      if info.Count > 0 then
        Execute(Self, info);
    finally
      F(Info);
    end;
  end;
end;

procedure TViewer.ExecuteDirectoryWithFileOnThread(FileName : String);
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
  TmpStr, Text_out: string;
  LoadImage: TPNGImage;
  LoadImageBMP: TBitmap;
  FOldImageExists, NotifyUser: Boolean;

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

  CurrentInfo.Assign(Info);
  TW.I.Start('DoProcessPath');

  for I := 0 to CurrentInfo.Count - 1 do
  begin
    NotifyUser := False;
    if I = CurrentInfo.Position then
      NotifyUser := CurrentInfo.Position < CurrentInfo.Count;

    TmpStr := CurrentInfo[I].FileName;
    DoProcessPath(TmpStr, NotifyUser);
    CurrentInfo[I].FileName := TmpStr;
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
  if not ((LoadBaseFile<>'') and (AnsiLowerCase(Item.FileName)=AnsiLowerCase(LoadBaseFile))) then
  begin
      Loading := True;
      TW.I.Start('LoadImage_');
      if LoadImage_(Sender, Item.FIleName, Item.Rotation, False,
        Zoom, False) then
      begin
        FbImage.Canvas.Brush.Color := clBtnFace;
        FbImage.Canvas.Pen.Color := clBtnFace;
        if FNewCsrBmp <> nil then
          FNewCsrBmp.Canvas.Rectangle(0, 0, FNewCsrBmp.Width, FNewCsrBmp.Height);
        FbImage.Width := 170;
        FbImage.Height := 170;
        FbImage.Canvas.Rectangle(0, 0, FbImage.Width, FbImage.Height);

        LoadImage := GetSlideShowLoadPicture;
        try
          LoadImageBMP := TBitmap.Create;
          try
            LoadPNGImage32bit(LoadImage, LoadImageBMP, ClBtnFace);
            FbImage.Canvas.Draw(0, 0, LoadImageBMP);
          finally
            F(LoadImageBMP);
          end;
        finally
          F(LoadImage);
        end;

        Text_out := L('Processing') + '...';
        FbImage.Canvas.TextOut(FbImage.Width div 2 - FbImage.Canvas.TextWidth(Text_out) div 2,
          FbImage.Height - 4 * FbImage.Canvas.Textheight(Text_out) div 2, Text_out);

        TW.I.Start('RecreateDrawImage_');
        RecreateDrawImage(Sender);
        TW.I.Start('FormPaint');
        FormPaint(Sender);
      end;
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
  IncGrayScale := 20;
  RealZoomInc := 1;
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

procedure TViewer.WaitImageTimerTimer(Sender: TObject);
begin
  WaitGrayScale := WaitGrayScale + IncGrayScale;
  if WaitGrayScale > 100 then
  begin
    WaitGrayScale := 100;
    Exit;
  end;
  WaitImage.Width := Drawimage.Width;
  WaitImage.Height := Drawimage.Height;
  GrayScaleImage(Drawimage, WaitImage, WaitGrayScale);
  Canvas.Draw(0, 0, WaitImage);
end;

procedure TViewer.DoWaitToImage(Sender: TObject);
begin
  if WaitImageTimer.Enabled then
    Exit;
  WaitImageTimer.Enabled := True;
  WaitGrayScale := 0;
end;

procedure TViewer.EndWaitToImage(Sender: TObject);
begin
  WaitImageTimer.Enabled := False;
  WaitGrayScale := 0;
end;

procedure TViewer.Onlythisfile1Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
  UpdaterDB.AddFile(Item.FileName)
end;

procedure TViewer.AllFolder1Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
  UpdaterDB.AddDirectory(ExtractFileDir(Item.FileName), nil)
end;

procedure TViewer.GoToSearchWindow1Click(Sender: TObject);
var
  NewSearch: TSearchForm;
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

procedure TViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FullScreenView <> nil then
    Exit1Click(nil);
  if DirectShowForm <> nil then
    DirectShowForm.Close;
  DestroyTimer.Enabled := True;
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
    TbEditImage.Hint := L('Image editor (Ctrl+E)');
    TbInfo.Hint := L('Properties (Ctrl+Z)');
  finally
    EndTranslate;
  end;
end;

procedure TViewer.Copy1Click(Sender: TObject);
var
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    FileList.Add(Item.FileName);
    Copy_Move(True, FileList);
  finally
     FileList.Free;
  end;
end;

procedure TViewer.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  WindowsMenuTickCount := GetTickCount;
  if CurrentInfo.Count = 0 then
    Exit;
  if Button = MbLeft then
    if FileExists(Item.FileName) then
    begin
      DBCanDrag := True;
      GetCursorPos(DBDragPoint);
    end;
end;

procedure TViewer.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
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

procedure TViewer.ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
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
    ScrollBar1.Position := 0;
    ScrollBar1.Visible := False;
    ScrollBar2.Position := 0;
    ScrollBar2.Visible := False;
    Exit;
  end;
  V1 := ScrollBar1.Visible;
  V2 := ScrollBar2.Visible;
  if not ScrollBar1.Visible and not ScrollBar2.Visible then
  begin
    ScrollBar1.Visible := FbImage.Width * Zoom > ClientWidth;
    if ScrollBar1.Visible then
      Inc_ := ScrollBar1.Height
    else
      Inc_ := 0;
    ScrollBar2.Visible := FbImage.Height * Zoom > HeightW - Inc_;
  end;
  begin
    if ScrollBar2.Visible then
      Inc_ := ScrollBar2.Width
    else
      Inc_ := 0;
    ScrollBar1.Visible := FbImage.Width * Zoom > ClientWidth - Inc_;
    ScrollBar1.Width := ClientWidth - Inc_;
    if ScrollBar1.Visible then
      Inc_ := ScrollBar1.Height
    else
      Inc_ := 0;
    ScrollBar1.Top := HeightW - Inc_;
  end;
  begin
    if ScrollBar1.Visible then
      Inc_ := ScrollBar1.Height
    else
      Inc_ := 0;
    ScrollBar2.Visible := FbImage.Height * Zoom > HeightW - Inc_;
    ScrollBar2.Height := HeightW - Inc_;
    if ScrollBar2.Visible then
      Inc_ := ScrollBar2.Width
    else
      Inc_ := 0;
    ScrollBar2.Left := ClientWidth - Inc_;
  end;
  begin
    if ScrollBar2.Visible then
      Inc_ := ScrollBar2.Width
    else
      Inc_ := 0;
    ScrollBar1.Visible := FbImage.Width * Zoom > ClientWidth - Inc_;
    ScrollBar1.Width := ClientWidth - Inc_;
    if ScrollBar1.Visible then
      Inc_ := ScrollBar1.Height
    else
      Inc_ := 0;
    ScrollBar1.Top := HeightW - Inc_;
  end;
  if not ScrollBar1.Visible then
    ScrollBar1.Position := 0;
  if not ScrollBar2.Visible then
    ScrollBar2.Position := 0;
  if ScrollBar1.Visible and not V1 then
  begin
    ScrollBar1.PageSize := 0;
    ScrollBar1.Position := 0;
    ScrollBar1.Max := 100;
    ScrollBar1.Position := 50;
  end;
  if ScrollBar2.Visible and not V2 then
  begin
    ScrollBar2.PageSize := 0;
    ScrollBar2.Position := 0;
    ScrollBar2.Max := 100;
    ScrollBar2.Position := 50;
  end;
  Panel1.Width := ScrollBar2.Width;
  Panel1.Height := ScrollBar1.Height;
  Panel1.Left := ClientWidth - Panel1.Width;
  Panel1.Top := HeightW - Panel1.Height;
  Panel1.Visible := ScrollBar1.Visible and ScrollBar2.Visible;
  if ScrollBar1.Visible then
  begin
    if ScrollBar2.Visible then
      Inc_ := ScrollBar2.Width
    else
      Inc_ := 0;
    M := Round(FbImage.Width * Zoom);
    Ps := ClientWidth - Inc_;
    if Ps > M then
      Ps := 0;
    if (ScrollBar1.Max <> ScrollBar1.PageSize) then
      Pos := Round(ScrollBar1.Position * ((M - Ps) / (ScrollBar1.Max - ScrollBar1.PageSize)))
    else
      Pos := ScrollBar1.Position;
    if M < ScrollBar1.PageSize then
      ScrollBar1.PageSize := Ps;
    ScrollBar1.Max := M;
    ScrollBar1.PageSize := Ps;
    ScrollBar1.LargeChange := Ps div 10;
    ScrollBar1.Position := Math.Min(ScrollBar1.Max, Pos);
  end;
  if ScrollBar2.Visible then
  begin
    if ScrollBar1.Visible then
      Inc_ := ScrollBar1.Height
    else
      Inc_ := 0;
    M := Round(FbImage.Height * Zoom);
    Ps := HeightW - Inc_;
    if Ps > M then
      Ps := 0;
    if ScrollBar2.Max <> ScrollBar2.PageSize then
      Pos := Round(ScrollBar2.Position * ((M - Ps) / (ScrollBar2.Max - ScrollBar2.PageSize)))
    else
      Pos := ScrollBar2.Position;
    if M < ScrollBar2.PageSize then
      ScrollBar2.PageSize := Ps;
    ScrollBar2.Max := M;
    ScrollBar2.PageSize := Ps;
    ScrollBar2.LargeChange := Ps div 10;
    ScrollBar2.Position := Math.Min(ScrollBar2.Max, Pos);
  end;
  if ScrollBar1.Position > ScrollBar1.Max - ScrollBar1.PageSize then
    ScrollBar1.Position := ScrollBar1.Max - ScrollBar1.PageSize;
  if ScrollBar2.Position > ScrollBar2.Max - ScrollBar2.PageSize then
    ScrollBar2.Position := ScrollBar2.Max - ScrollBar2.PageSize;
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
    ZoomIn1.Enabled := False;
    ZoomOut1.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    RealSize1.Enabled := False;
    BestSize1.Enabled := False;
    ScrollBar1.PageSize := 0;
    ScrollBar1.Max := 100;
    ScrollBar1.Position := 50;
    ScrollBar2.PageSize := 0;
    ScrollBar2.Max := 100;
    ScrollBar2.Position := 50;
    LoadImage_(Sender, Item.FileName, Item.Rotation, True, 1, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end else
  begin
    Zoom := 1;
    ZoomerOn := True;
    FormResize(Sender);
  end;
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
    RealSize1.Enabled := False;
    BestSize1.Enabled := False;
    ZoomIn1.Enabled := False;
    ZoomOut1.Enabled := False;
    LoadImage_(Sender, Item.FileName, Item.Rotation, True, Z, True);
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
    RealSize1.Enabled := False;
    BestSize1.Enabled := False;
    ZoomIn1.Enabled := False;
    ZoomOut1.Enabled := False;
    LoadImage_(Sender, Item.FileName, Item.Rotation, True, Z, True);
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
  P: TPoint;
  ImRect: TRect;
  Dy, Dx, X, Y, Z: Extended;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
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
    ScrollBar1.Position := ScrollBar1.Position + Round(ScrollBar1.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    ScrollBar2.Position := ScrollBar2.Position + Round(ScrollBar2.PageSize * Dy);
  end;
  if Cursor = CursorZoomOutNo then
  begin
    Z := Zoom;
    Zoom := Max(Z * 0.8, 0.05);
    ImRect := GetImageRectA;
    X := P.X;
    Y := P.Y;
    Dx := (X - (ImRect.Right - ImRect.Left) div 2) / (ImRect.Right - ImRect.Left);
    ScrollBar1.Position := ScrollBar1.Position + Round(ScrollBar1.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    ScrollBar2.Position := ScrollBar2.Position + Round(ScrollBar2.PageSize * Dy);
  end;
  FormResize(Sender);
end;

function TViewer.HeightW: Integer;
begin
  Result := ClientHeight - ToolsBar.Height - 3;
end;

function TViewer.GetImageRectA: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if ScrollBar1.Visible then
  begin
    FX := 0;
  end else
  begin
    if ScrollBar2.Visible then
      Increment := ScrollBar2.width
    else
      Increment := 0;
    FX := Max(0, Round(ClientWidth / 2 - Increment - FBImage.Width * Zoom / 2));
  end;
  if ScrollBar2.Visible then
  begin
    FY := 0;
  end else
  begin
    if ScrollBar1.Visible then
      Increment := ScrollBar1.Height
    else
      Increment := 0;
    FY := Max(0,
      round(HeightW / 2 - Increment - FBImage.Height * Zoom / 2));
  end;
  if ScrollBar2.Visible then
    Increment := ScrollBar2.width
  else
    Increment := 0;
  FW := round(Min(ClientWidth - Increment, FBImage.Width * Zoom));
  if ScrollBar1.Visible then
    Increment := ScrollBar1.Height
  else
    Increment := 0;
  FH := round(Min(HeightW - Increment, FBImage.Height * Zoom));
  FH := FH;

  Result := rect(FX, FY, FW + FX, FH + FY);
end;

function TViewer.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := CurrentInfo[CurrentFileNumber];
end;

procedure TViewer.RecreateImLists;
var
  Icons: array [0 .. 1, 0 .. 22] of HIcon;
  I, J: Integer;
  B: TBitmap;
  Imlists: array [0 .. 2] of TImageList;
const
  Names: array [0 .. 1, 0 .. 22] of string = (('Z_NEXT_NORM', 'Z_PREVIOUS_NORM', 'Z_BESTSIZE_NORM',
      'Z_FULLSIZE_NORM', 'Z_FULLSCREEN_NORM', 'Z_ZOOMIN_NORM', 'Z_ZOOMOUT_NORM', 'Z_FULLSCREEN', 'Z_LEFT_NORM',
      'Z_RIGHT_NORM', 'Z_INFO_NORM', 'IMEDITOR', 'PRINTER', 'DELETE_INFO', 'RATING_STAR', 'TRATING_1', 'TRATING_2',
      'TRATING_3', 'TRATING_4', 'TRATING_5', 'Z_DB_NORM', 'Z_DB_WORK', 'Z_PAGES'), ('Z_NEXT_HOT', 'Z_PREVIOUS_HOT',
      'Z_BESTSIZE_HOT', 'Z_FULLSIZE_HOT', 'Z_FULLSCREEN_HOT', 'Z_ZOOMIN_HOT', 'Z_ZOOMOUT_HOT', 'Z_FULLSCREEN',
      'Z_LEFT_HOT', 'Z_RIGHT_HOT', 'Z_INFO_HOT', 'IMEDITOR', 'PRINTER', 'DELETE_INFO', 'RATING_STAR', 'TRATING_1',
      'TRATING_2', 'TRATING_3', 'TRATING_4', 'TRATING_5', 'Z_DB_NORM', 'Z_DB_WORK', 'Z_PAGES'));

begin
  TW.I.Start('LoadIcon');
  for I := 0 to 1 do
    for J := 0 to 22 do
      Icons[I, J] := LoadImage(DBKernel.IconDllInstance, PWideChar(Names[I, J]), IMAGE_ICON, 16, 16, 0);

  Imlists[0] := ImageList1;
  Imlists[1] := ImageList2;
  Imlists[2] := ImageList3;
  TW.I.Start('Clear');
  if not FCreating then
    for I := 0 to 2 do
      Imlists[I].Clear;

  TW.I.Start('BkColor');
  Imlists[0].BkColor := ClBtnFace;
  Imlists[1].BkColor := ClBtnFace;
  Imlists[2].BkColor := ClBtnFace;
  B := TBitmap.Create;
  try
    B.Width := 16;
    B.Height := 16;
    B.Canvas.Brush.Color := ClBtnFace;
    B.Canvas.Pen.Color := ClBtnFace;
    TW.I.Start('ImageList_ReplaceIcon');
    for I := 0 to 1 do
      for J := 0 to 22 do
      begin
        ImageList_ReplaceIcon(Imlists[I].Handle, -1, Icons[I, J]);
        if I = 0 then
        begin
          {if J in [0, 1, 12, 14, 15, 22] then
          begin    }
            B.Canvas.Rectangle(0, 0, 16, 16);
            DrawIconEx(B.Canvas.Handle, 0, 0, Icons[I, J], 16, 16, 0, 0, DI_NORMAL);
            GrayScale(B);
            Imlists[2].Add(B, nil);
          {end
          else
            ImageList_ReplaceIcon(Imlists[2].Handle, -1, Icons[I, J]);    }
        end;
      end;
    TW.I.Start('DestroyIcon');
    for I := 0 to 1 do
      for J := 0 to 22 do
        DestroyIcon(Icons[I, J]);

  finally
    B.Free;
  end;
  TW.I.Start('RecreateImLists - end');
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
    if ZoomerOn then
      FitToWindowClick(Sender);

    ReAllignScrolls(True, Point(0, 0));
    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
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
  if Item.ID <> 0 then
    PropertyManager.NewIDProperty(Item.ID).Execute(Item.ID)
  else
    PropertyManager.NewFileProperty(Item.FileName).ExecuteFileNoEx(Item.FileName);
end;

procedure TViewer.Resize1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
begin
  List := TDBPopupMenuInfo.Create;
  try
    List.Add(Item.Copy);
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
  PopupMenu1.Popup(P.X, P.Y);
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
  LoadImage_(Self, Item.FileName, Item.Rotation, False, Zoom, False);
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

procedure TViewer.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  FormManager.UnRegisterMainForm(Self);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  Release;
  Viewer := nil;
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

procedure TViewer.SetStaticImage(Image : TBitmap; Transparent : Boolean);
begin
  if CurrentFileNumber > CurrentInfo.Count - 1 then
    Exit;
  FCurrentlyLoadedFile := Item.FileName;
  TransparentImage := Transparent;
  ForwardThreadExists := False;
  ForwardThreadNeeds := False;
  F(FbImage);
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
  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := True;
  ZoomIn1.Enabled := True;
  ZoomOut1.Enabled := True;
  RealSize1.Enabled := True;
  BestSize1.Enabled := True;
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  EndWaitToImage(Self);

  if FRotatingImageInfo.Enabled then
    if AnsiLowerCase(FRotatingImageInfo.FileName) = AnsiLowerCase(FCurrentlyLoadedFile) then
      ApplyRotate(FbImage, FRotatingImageInfo.Rotating);

  ReAllignScrolls(False, Point(0, 0));
  ValidImages := 1;
  RecreateDrawImage(Self);
  PrepareNextImage;
  FRotatingImageInfo.Enabled := False;
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
  Im: TGifImage;
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

  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := True;

  ZoomIn1.Enabled := True;
  ZoomOut1.Enabled := True;
  RealSize1.Enabled := True;
  BestSize1.Enabled := True;
  TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;
  EndWaitToImage(Self);
  ReAllignScrolls(False, Point(0, 0));
  SlideNO := -1;
  ZoomerOn := False;
  Im := (AnimatedImage as TGIFImage);
  ValidImages := 0;
  TransparentImage := False;
  for I := 0 to Im.Images.Count - 1 do
  begin
    if not Im.Images[I].Empty then
      ValidImages := ValidImages + 1;
    if Im.Images[I].Transparent then
      TransparentImage := True;
  end;
  AnimatedBuffer.Width := Im.Width;
  AnimatedBuffer.Height := Im.Height;
  if FullScreenNow then
  begin
    AnimatedBuffer.Canvas.Brush.Color := 0;
    AnimatedBuffer.Canvas.Pen.Color := 0;
  end else
  begin
    AnimatedBuffer.Canvas.Brush.Color := clBtnFace;
    AnimatedBuffer.Canvas.Pen.Color := clBtnFace;
  end;
  AnimatedBuffer.Canvas.Rectangle(0, 0, AnimatedBuffer.Width, AnimatedBuffer.Height);
  ImageFrameTimer.Interval := 1;
  ImageFrameTimer.Enabled := True;
end;

procedure TViewer.ImageFrameTimerTimer(Sender: TObject);
begin
  NextSlide;
end;

function TViewer.GetImage(FileName: string; Bitmap: TBitmap): Boolean;
begin
  Result := False;
  if AnsiLowerCase(FileName) = AnsiLowerCase(Item.FileName) then
  begin
    Result := True;
    Bitmap.Assign(DrawImage);
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
  Del := 1;
  if not(ImageExists and not StaticImage) then
    Exit;
  if SlideNO = -1 then
  begin
    SlideNO := GetFirstImageNO;
  end else
  begin
    SlideNO := GetNextImageNO;
  end;
  R := (AnimatedImage as TGIFImage).Images[SlideNO].BoundsRect;
  if FullScreenNow then
  begin
    AnimatedBuffer.Canvas.Brush.Color := 0;
    AnimatedBuffer.Canvas.Pen.Color := 0;
  end else
  begin
    AnimatedBuffer.Canvas.Brush.Color := ClBtnFace;
    AnimatedBuffer.Canvas.Pen.Color := ClBtnFace;
  end;
  Im := (AnimatedImage as TGIFImage);
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
      AnimatedBuffer.Canvas.Pen.Color := ClBtnFace;
      AnimatedBuffer.Canvas.Brush.Color := ClBtnFace;
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
    for I := 0 to (AnimatedImage as TGIFImage).Images.Count - 1 do
      if not(AnimatedImage as TGIFImage).Images[I].Empty then
      begin
        Result := I;
        Break;
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
  if ValidImages = 0 then
    Result := 0
  else
  begin
    Im := (AnimatedImage as TGIFImage);
    Result := SlideNO;
    Inc(Result);
    if Result >= Im.Images.Count then
      Result := 0;

    if Im.Images[Result].Empty then
      Result := GetNextImageNOX(Result);
  end;
end;

function TViewer.GetPreviousImageNO: Integer;
var
  Im: TGIFImage;
begin
  if ValidImages = 0 then
    Result := 0
  else
  begin
    Im := (AnimatedImage as TGIFImage);
    Result := SlideNO;
    Dec(Result);
    if Result < 0 then
      Result := Im.Images.Count - 1;

    if Im.Images[Result].Empty then
      Result := GetPreviousImageNOX(Result);

  end;
end;

function TViewer.GetNextImageNOX(NO: Integer): Integer;
var
  Im: TGIFImage;
begin
  if ValidImages = 0 then
    Result := 0
  else
  begin
    Im := (AnimatedImage as TGIFImage);
    Result := NO;
    Inc(Result);
    if Result >= Im.Images.Count then
      Result := 0;

    if Im.Images[Result].Empty then
      Result := GetNextImageNOX(Result);
  end;
end;

function TViewer.GetPreviousImageNOX(NO: Integer): Integer;
var
  Im: TGIFImage;
begin
  if ValidImages = 0 then
    Result := 0
  else
  begin
    Im := (AnimatedImage as TGIFImage);
    Result := NO;
    Dec(Result);
    if Result < 0 then
      Result := Im.Images.Count - 1;

    if Im.Images[Result].Empty then
      Result := GetPreviousImageNOX(Result);
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
  ZoomIn1.Enabled := False;
  ZoomOut1.Enabled := False;
  RealSize1.Enabled := False;
  BestSize1.Enabled := False;
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
  RecreateDrawImage(Self);
  PrepareNextImage;
  FRotatingImageInfo.Enabled := False;
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
    TViewerThread.Create(Self, CurrentInfo[N].FileName, CurrentInfo[N].Rotation, False, 1, ForwardThreadSID,
      True, not CurrentInfo[N].InfoLoaded, 0);
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

procedure TViewer.UpdateInfo(SID: TGUID; Info: TDBPopupMenuInfoRecord);
begin
  CurrentInfo[CurrentFileNumber].Assign(Info);
  DisplayRating := Info.Rating;
  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := TbRotateCCW.Enabled;
end;

procedure TViewer.TbSlideShowClick(Sender: TObject);
begin
  if Loading or (CurrentInfo.Position = -1) then
    Exit;
  SlideShowNow := True;
  SlideTimer.Enabled := False;
  Play := False;
  WaitImageTimer.Enabled := False;
  Application.CreateForm(TDirectShowForm, DirectShowForm);
  MTimer1.ImageIndex := DB_IC_PLAY;
  MTimer1Click(Sender);
  DirectShowForm.Execute(Sender);
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
    if FileExists(Item.FileName) then
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
  SQL_: string;
  DeleteID: Integer;
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to delete file to recycle bin?'), L('Delete confirn'),
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

    Files := TStringList.Create;
    try
      Files.Add(Item.FileName);
      SilentDeleteFiles(Handle, Files, True);
    finally
      F(Files);
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
    ZoomIn1.Enabled := False;
    ZoomOut1.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;
    RealSize1.Enabled := False;
    BestSize1.Enabled := False;
    LoadImage_(Sender, Item.FileName, Item.Rotation, False, 1, True);
    TbrActions.Refresh;
    TbrActions.Realign;
  end;
end;

procedure TViewer.TbRatingClick(Sender: TObject);
var
  P: TPoint;
  I: Integer;
begin
  GetCursorPos(P);
  for I := 0 to 5 do
    (FindComponent('N' + IntToStr(I) + '1') as TMenuItem).Default := False;

  (FindComponent('N' + IntToStr(Item.Rating) + '1') as TMenuItem).default := True;
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
    if UpdaterDB = nil then
      UpdaterDB := TUpdaterDB.Create;

    FileInfo:= TDBPopupMenuInfoRecord.Create;
    try
      FileInfo.FileName := Item.FileName;
      FileInfo.Rating := NewRating;
      UpdaterDB.AddFileEx(FileInfo, True);
    finally
      F(FileInfo);
    end;
  end;

end;

procedure TViewer.ApplicationEvents1Hint(Sender: TObject);
begin
  Application.HintPause := 1000;
  Application.HintHidePause := 5000;
end;

procedure TViewer.UpdateInfoAboutFileName(FileName: String;
  info: TDBPopupMenuInfoRecord);
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

procedure TViewer.NewPanel1Click(Sender: TObject);
begin
  ManagerPanels.NewPanel.Show;
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
      end else
      begin
        FRotatingImageInfo.Enabled := True;
        FRotatingImageInfo.FileName := FileName;
        FRotatingImageInfo.Rotating := CurrentInfo[I].Rotation;
      end;
      Break;
    end;

  DisplayRating := Item.Rating;

  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := True;
end;

procedure TViewer.DoSetNoDBRecord(FileName: string);
var
  I: integer;
begin
  for I := 0 to CurrentInfo.Count - 1 do
    if not CurrentInfo[I].InfoLoaded then
      if CurrentInfo[I].FileName = FileName then
      begin
        CurrentInfo[I].InfoLoaded := True;
        Break;
      end;
  DisplayRating := Item.Rating;

  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled:=TbRotateCCW.Enabled;
end;

procedure TViewer.TimerDBWorkTimer(Sender: TObject);
begin
  if not (TbRating.ImageIndex in [20..21]) then
  begin
    TimerDBWork.Enabled := False;
    Exit;
  end;

  if TbRating.ImageIndex=20 then
    TbRating.ImageIndex:=21
  else
    TbRating.ImageIndex:=20;
end;

procedure TViewer.MakePagesLinks;
var
  I : Integer;
  MenuItem : TMenuItem;
begin
  if not FCreating then
  begin
    TbPageNumber.Visible := FPageCount > 1;
    TbSeparatorPageNumber.Visible := FPageCount > 1;
    ToolsBar.Realign;
    TbrActions.Width := TbInfo.Left + TbInfo.Width + 2;
    ToolsBar.Width := TbrActions.Width;
    ToolsBar.Left := ClientWidth div 2 - ToolsBar.Width div 2;
  end;
  PopupMenuPageSelecter.Items.Clear;
  for I := 0 to FPageCount - 1 do
  begin
    MenuItem := TMenuItem.Create(PopupMenuPageSelecter);
    MenuItem.Caption := IntToStr(I + 1);
    MenuItem.OnClick := OnPageSelecterClick;
    MenuItem.Tag := I;
    if I = FCurrentPage then
      MenuItem.Default := True;
    PopupMenuPageSelecter.Items.Add(MenuItem);
   end;
end;

procedure TViewer.OnPageSelecterClick(Sender: TObject);
begin
  FCurrentPage := TMenuItem(Sender).Tag;
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
   TbRating.Enabled := (Value >= 0);
   TbRating.ImageIndex := 14 + Abs(Value);
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

initialization

Viewer := nil;

end.
