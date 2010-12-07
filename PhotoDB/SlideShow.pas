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
  uListViewUtils, uFormListView, uImageSource, uDBPopupMenuInfo, uPNGUtils;

type
  TRotatingImageInfo = record
    FileName: string;
    Rotating: Integer;
    Enabled: Boolean;
  end;

type
  TViewer = class(TThreadForm, IImageSource)
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
    procedure UpdateInfo(SID : TGUID; Info : TOneRecordInfo);
    procedure TbSlideShowClick(Sender: TObject);
    procedure SlideTimerTimer(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure TbDeleteClick(Sender: TObject);
    procedure TbRatingClick(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure UpdateInfoAboutFileName(FileName : String; info : TOneRecordInfo);
    procedure SendTo1Click(Sender: TObject);
    procedure NewPanel1Click(Sender: TObject);
    procedure TimerDBWorkTimer(Sender: TObject);
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
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    WaitingList: Boolean;
    FCurrentPage: Integer;
    FPageCount: Integer;
    CursorZoomIn, CursorZoomOut: HIcon;
    DBCanDrag: Boolean;
    DBDragPoint: TPoint;
    Old_width, Old_height, Old_top, Old_left: Integer;
    Old_rect: Trect;
    FOldPoint: TPoint;
    WaitGrayScale: Integer;
    WaitImage: TBitmap;
    FSID: TGUID;
    function GetImage(FileName : string; Bitmap : TBitmap) : Boolean;
    procedure ExecuteDirectoryWithFileOnThread(FileName : String);
    function Execute(Sender: TObject; Info: TRecordsInfo) : boolean;
    function ExecuteW(Sender: TObject; Info : TRecordsInfo; LoadBaseFile : String) : boolean;
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
    Property ImageExists : Boolean read FImageExists write SetImageExists;
    Property StaticImage : Boolean read FStaticImage Write SetPropStaticImage;
    Property Loading : Boolean read FLoading write SetLoading;
    Property ValidImages : Integer read FValidImages write SetValidImages;
    Property ForwardThreadExists : Boolean read FForwardThreadExists write SetForwardThreadExists;
    Property ForwardThreadSID : TGUID read FForwardThreadSID write SetForwardThreadSID;
    Property ForwardThreadNeeds : Boolean read FForwardThreadNeeds write SetForwardThreadNeeds;
    Property ForwardThreadFileName : string read FForwardThreadFileName write SetForwardThreadFileName;
    Property TransparentImage : Boolean read FTransparentImage write SetTransparentImage;
    Property CurrentlyLoadedFile : String read FCurrentlyLoadedFile write SetCurrentlyLoadedFile;
    Property Play : boolean read FPlay write SetPlay;
  end;

var
  Viewer: TViewer;
  UseOnlySelf: Boolean = False;
  ZoomerOn: Boolean = False;
  IncGrayScale: Integer = 20;
  Zoom: Real = 1;
  RealZoomInc: Extended = 1;
  RealImageWidth: Integer = 0;
  RealImageHeight: Integer = 0;
  DelTwo: Integer = 2;
  UseOnlyDefaultDraw: Boolean = False;
  CurrentInfo: TRecordsInfo;
  FullScreenNow, SlideShowNow: Boolean;
  DrawImage: TBitmap;
  FBImage: Tbitmap;
  Fcsrbmp, FNewCsrBmp, Fnowcsrbmp: TBitmap;
  CurrentFileNumber: Integer;

const
  CursorZoomInNo = 130;
  CursorZoomOutNo = 131;

implementation

uses UnitUpdateDB, PropertyForm, SlideShowFullScreen,
  ExplorerUnit, FloatPanelFullScreen, UnitSizeResizerForm,
  DX_Alpha, UnitViewerThread, ImEditor, PrintMainForm, UnitFormCont,
  UnitLoadFilesToPanel, CommonDBSupport, UnitSlideShowScanDirectoryThread,
  UnitSlideShowUpdateInfoThread;

{$R *.dfm}

procedure TViewer.FormCreate(Sender: TObject);
begin
  TW.I.Start('TViewer.FormCreate');
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
  AnimatedImage:=nil;
  FLoading:=true;
  FImageExists:=false;
  DBCanDrag:=false;
  DropFileTarget1.Register(self);
  SlideTimer.Interval:=Math.Min(Math.Max(DBKernel.ReadInteger('Options','FullScreen_SlideDelay',40),1),100)*100;
  IncGrayScale:=Math.Min(Math.Max(DBKernel.ReadInteger('Options','SlideShow_GrayScale',20),1),100);
  FullScreenNow:=false;
  SlideShowNow:=false;
  TbrActions.DoubleBuffered:=True;
  drawimage:=Tbitmap.Create;
  FbImage:=TBitmap.Create;
  FbImage.PixelFormat:=pf24bit;
  drawimage.PixelFormat:=pf24bit;
  TW.I.Start('fcsrbmp');
  Fcsrbmp := TBitmap.create;
  Fcsrbmp.PixelFormat:=pf24bit;
  Fcsrbmp.Canvas.Brush.Color:=0;
  Fcsrbmp.Canvas.pen.Color:=0;
  TW.I.Start('fnewcsrbmp');
  WaitImage := TBitmap.create;
  WaitImage.PixelFormat:=pf24bit;
  FNewCsrBmp := TBitmap.create;
  FNewCsrBmp.PixelFormat:=pf24bit;
  FNewCsrBmp.Canvas.Brush.Color:=0;
  FNewCsrBmp.Canvas.pen.Color:=0;
  Fnowcsrbmp := TBitmap.create;
  Fnowcsrbmp.PixelFormat:=pf24bit;
  Fnowcsrbmp.Assign(FNewCsrBmp);

  TW.I.Start('AnimatedBuffer');
  AnimatedBuffer := TBitmap.create;
  AnimatedBuffer.PixelFormat:=pf24bit;
  MTimer1.Caption:= L('Stop timer');
  MTimer1.ImageIndex:=DB_IC_PAUSE;

  SaveWindowPos1.Key := RegRoot+'SlideShow';
  SaveWindowPos1.SetPosition;
  PopupMenu1.Images:=DBKernel.imageList;
  Shell1.ImageIndex:=DB_IC_SHELL;
  Exit1.ImageIndex:=DB_IC_EXIT;
  FullScreen1.ImageIndex:=DB_IC_DESKTOP;
  Next1.ImageIndex:=DB_IC_NEXT;
  Previous1.ImageIndex:=DB_IC_PREVIOUS;
  DBItem1.ImageIndex:=DB_IC_NOTES;
  AddtoDB1.ImageIndex:=DB_IC_NEW;
  Copy1.ImageIndex:=DB_IC_COPY;
  Onlythisfile1.ImageIndex:=DB_IC_ADD_SINGLE_FILE;
  AllFolder1.ImageIndex:=DB_IC_ADD_FOLDER;
  GoToSearchWindow1.ImageIndex:=DB_IC_ADDTODB;
  Explorer1.ImageIndex:=DB_IC_FOLDER;
  SetasDesktopWallpaper1.ImageIndex:=DB_IC_WALLPAPER;
  ZoomOut1.ImageIndex:=DB_IC_ZOOMOUT;
  ZoomIn1.ImageIndex:=DB_IC_ZOOMIN;
  RealSize1.ImageIndex:=DB_IC_REALSIZE;
  BestSize1.ImageIndex:=DB_IC_BESTSIZE;
  Properties1.ImageIndex:=DB_IC_PROPERTIES;
  Stretch1.ImageIndex:=DB_IC_WALLPAPER;
  Center1.ImageIndex:=DB_IC_WALLPAPER;
  Tile1.ImageIndex:=DB_IC_WALLPAPER;
  RotateCCW1.ImageIndex:=DB_IC_ROTETED_270;
  RotateCW1.ImageIndex:=DB_IC_ROTETED_90;
  Rotateon1801.ImageIndex:=DB_IC_ROTETED_180;
  Rotate1.ImageIndex:=DB_IC_ROTETED_0;
  Resize1.ImageIndex:=DB_IC_RESIZE;
  SlideShow1.ImageIndex:=DB_IC_DO_SLIDE_SHOW;
  ImageEditor1.ImageIndex:=DB_IC_IMEDITOR;
  Print1.ImageIndex:=DB_IC_PRINTER;
  SendTo1.ImageIndex:=DB_IC_SEND;
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
  text : string;
  NeedsUpdating : Boolean;
begin
 Result:=false;

 SetProgressPosition(CurrentFileNumber + 1, Length(CurrentInfo.ItemFileNames));
 if (not CurrentInfo.LoadedImageInfo[CurrentFileNumber]) and (CurrentInfo.ItemIds[CurrentFileNumber]=0) then
 NeedsUpdating:=true else NeedsUpdating:=false;
 CurrentInfo.LoadedImageInfo[CurrentFileNumber]:=true;
 DoWaitToImage(Sender);
 Rotate:=CurrentInfo.ItemRotates[CurrentFileNumber];
// DBKernel.RegisterChangesIDbyID(self,ChangedDBDataByID,CurrentInfo.ItemIds[CurrentFileNumber]);
 if CheckFileExistsWithSleep(FileName,false) then
 begin
  Caption:=Format(L('View') + ' - %s   [%d/%d]',[ExtractFileName(FileName),CurrentFileNumber+1, Length(CurrentInfo.LoadedImageInfo)]);

  DisplayRating := CurrentInfo.ItemRatings[CurrentFileNumber];

  TbRotateCCW.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
  TbRotateCW.Enabled:=TbRotateCCW.Enabled;

  FSID:=GetGUID;
  if not ForwardThreadExists or (ForwardThreadFileName<>FileName) or (Length(CurrentInfo.ItemIds)=0) or FullImage then
  begin
   if NeedsUpdating then
   begin
    if not DBKernel.ReadBool('SlideShow','UseFastSlideShowImageLiading',true) then
    begin
     UpdateRecord(CurrentFileNumber);
     Rotate:=CurrentInfo.ItemRotates[CurrentFileNumber];
     DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];

     TbRotateCCW.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
     TbRotateCW.Enabled:=TbRotateCCW.Enabled;
    end else
    begin
     DisplayRating := - CurrentInfo.ItemIds[CurrentFileNumber];
     TimerDBWork.Enabled:=true;
     TbRotateCCW.Enabled:=false;
     TbRotateCW.Enabled:=false;
     TSlideShowUpdateInfoThread.Create(Self, StateID, CurrentInfo.ItemFileNames[CurrentFileNumber]);
     Rotate:=0;
    end;
   end;

   Result:=true;
   if not RealZoom then
   TViewerThread.Create(FileName,Rotate,FullImage,1,FSID,false,false, fCurrentPage) else
   TViewerThread.Create(FileName,Rotate,FullImage,BeginZoom,FSID,false,false, fCurrentPage);
   ForwardThreadExists:=false;
  end else ForwardThreadNeeds:=true;
 end else
 begin
  Caption:=Format(L('View') + ' - %s   [%d/%d]',[ExtractFileName(FileName),CurrentFileNumber+1,Length(CurrentInfo.LoadedImageInfo)]);
  DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];

  TbRotateCCW.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
  TbRotateCW.Enabled:=TbRotateCCW.Enabled;

  Text:=Format(L('File %s not found!'),[Mince(FileName,80)]);
  FbImage.Canvas.Rectangle(0,0,FbImage.width,FbImage.Height);
  FbImage.Width:=FbImage.Canvas.TextWidth(text);
  FbImage.Height:=FbImage.Canvas.TextHeight(text);
  FbImage.Canvas.TextOut(0,0,text);
  RecreateDrawImage(Sender);
  FormPaint(Sender);
  Result:=false;
 end;
 TW.I.Start('LoadImage_ - end');
end;

procedure TViewer.RecreateDrawImage(Sender: TObject);
var
  fh,fw : integer;
  zx,zy,zw,zh, x1,x2,y1,y2 : integer;
  ImRect, BeginRect : TRect;
  z : real;
  FileName : string;
  TempImage, b : TBitmap;
  aCopyRect : TRect;
  text_error_out : string;

 procedure DrawRect(x1,y1,x2,y2 : Integer);
 begin
  if TransparentImage then
  begin
   drawimage.Canvas.Brush.Color:=ClBtnFace;
   drawimage.Canvas.Pen.Color:=0;
   drawimage.Canvas.Rectangle(x1-1,y1-1,x2+1,y2+1);
  end;
 end;

begin
  z:=0;
  UseOnlyDefaultDraw:=false;
  FileName:=FCurrentlyLoadedFile;
  if FullScreenNow then
  begin
   DrawImage.Width:=Screen.Width;
   DrawImage.Height:=Screen.Height;
   DrawImage.Canvas.Brush.Color:=0;
   DrawImage.Canvas.pen.Color:=0;
   DrawImage.Canvas.Rectangle(0,0,DrawImage.Width,DrawImage.Height);
   if (FbImage.Height=0) or (FbImage.width=0) then exit;
   fw:=FbImage.Width;
   fh:=FbImage.Height;
   ProportionalSize(Screen.Width,Screen.Height,fw,fh);
   if ImageExists then
   begin
    If false{DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True)} then
    begin
     if ZoomerOn then z:=RealZoomInc*Zoom else
     begin
      if RealImageWidth*RealImageHeight<>0 then
      begin
       if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_270) then
       z:=min(fw/RealImageHeight,fh/RealImageWidth) else
       z:=min(fw/RealImageWidth,fh/RealImageHeight);
      end else z:=1;
     end;
     if (Z<ZoomSmoothMin) or UseOnlyDefaultDraw then
     StretchCool(Screen.Width div 2 - fw div 2,Screen.Height div 2 - fh div 2,fw,fh,FbImage,DrawImage)
     else begin
      TempImage := TBitmap.Create;
      TempImage.PixelFormat:=pf24bit;
      TempImage.Width:=fw;
      TempImage.Height:=fh;
      SmoothResize(fw,fh,FbImage,TempImage);
      DrawImage.Canvas.Draw(Screen.Width div 2 - fw div 2,Screen.Height div 2 - fh div 2,TempImage);
      TempImage.Free;
     end;
    end else
    begin
     SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
     DrawImage.Canvas.StretchDraw(rect(Screen.Width div 2 - fw div 2,Screen.Height div 2 - fh div 2,Screen.Width div 2 - fw div 2+fw,Screen.Height div 2 - fh div 2+fh),FbImage);
    end;
   end else
   begin
    DrawImage.Canvas.Font.Color:=$FFFFFF;
    text_error_out := L('Error showing image!');
    DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(text_error_out) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2,text_error_out);
    DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(FileName) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2+DrawImage.Canvas.Textheight(FileName)+4,FileName);
   end;
   if FullScreenView<>nil then
   FullScreenView.Canvas.Draw(0,0,DrawImage);
   exit;
  end;
  DrawImage.Width:=Clientwidth;
  DrawImage.Height:=HeightW;
  DrawImage.Canvas.Brush.Color:=ClBtnFace;
  DrawImage.Canvas.pen.Color:=ClBtnFace;
  DrawImage.Canvas.Rectangle(0,0,DrawImage.Width,DrawImage.Height);
  if (FbImage.Height=0) or (FbImage.width=0) then exit;
  if (FbImage.width>ClientWidth) or (FbImage.Height>HeightW) then
  begin
   if FbImage.width/FbImage.Height<DrawImage.width/DrawImage.Height then
   begin
    fh:=DrawImage.Height;
    fw:=round(drawimage.Height*(FbImage.width/fbImage.Height));
   end else begin
    fw:=DrawImage.width;
    fh:=round(DrawImage.width*(FbImage.Height/fbImage.width));
   end;
  end else begin
   fh:=FbImage.Height;
   fw:=FbImage.Width;
  end;
  x1:=ClientWidth div 2 - fw div 2;
  y1:=(HeightW) div 2 - fh div 2;
  x2:=x1+fw;
  y2:=y1+fh;
  ImRect:=GetImageRectA;
  zx:=ImRect.Left;
  zy:=ImRect.Top;
  zw:=ImRect.Right-ImRect.Left;
  zh:=ImRect.Bottom-ImRect.Top;
  if ImageExists or Loading then
  begin
   If DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True) then
   begin
    if ZoomerOn and not WaitImageTimer.Enabled then
    begin
     DrawRect(ImRect.Left,ImRect.Top,ImRect.Right,ImRect.Bottom);
     if Zoom<=1 then
     begin
      if (Zoom<ZoomSmoothMin) or UseOnlyDefaultDraw then
      StretchCoolW(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),FbImage,DrawImage)
      else begin
       aCopyRect :=  Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom));
       TempImage := TBitmap.Create;
       TempImage.PixelFormat:=pf24bit;
       TempImage.Width:=zw;
       TempImage.Height:=zh;
       B:= TBitmap.Create;
       B.PixelFormat:=pf24bit;
       B.Width:=(aCopyRect.Right-aCopyRect.Left);
       B.Height:=(aCopyRect.Bottom-aCopyRect.Top);
       B.Canvas.CopyRect(Rect(0,0,B.Width,B.Height),FBImage.Canvas,aCopyRect);
       SmoothResize(zw,zh,B,TempImage);
       B.Free;
       DrawImage.Canvas.Draw(zx,zy,TempImage);
       TempImage.Free;
      end;

     end else
     Interpolate(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),FbImage,DrawImage);
    end else
    begin
     DrawRect(x1,y1,x2,y2);
     if ZoomerOn then z:=RealZoomInc*Zoom else
     begin
      if RealImageWidth*RealImageHeight<>0 then
      begin
       if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_270) then
       z:=min(fw/RealImageHeight,fh/RealImageWidth) else
       z:=min(fw/RealImageWidth,fh/RealImageHeight);
      end else z:=1;
     end;
     if (Z<ZoomSmoothMin) or UseOnlyDefaultDraw then
     StretchCool(x1,y1,x2-x1,y2-y1,FbImage,DrawImage)
     else begin
      TempImage := TBitmap.Create;
      TempImage.PixelFormat:=pf24bit;
      TempImage.Width:=x2-x1;
      TempImage.Height:=y2-y1;
      SmoothResize(x2-x1,y2-y1,FbImage,TempImage);
      DrawImage.Canvas.Draw(x1,y1,TempImage);
      TempImage.Free;
     end;
    end;
   end else
   begin
    if ZoomerOn and not WaitImageTimer.Enabled then
    begin
      ImRect:=Rect(Round(ScrollBar1.Position/zoom),Round((ScrollBar2.Position)/zoom),Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom));
      BeginRect:=GetImageRectA;
      DrawRect(BeginRect.Left,BeginRect.Top,BeginRect.Right,BeginRect.Bottom);
      SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
      DrawImage.Canvas.CopyMode:=SRCCOPY;
      DrawImage.Canvas.CopyRect(BeginRect,FbImage.Canvas,ImRect);
    end else
    begin
     DrawRect(x1,y1,x2,y2);
     SetStretchBltMode(DrawImage.Canvas.Handle, STRETCH_HALFTONE);
     DrawImage.Canvas.StretchDraw(rect(x1,y1,x2,y2),FbImage);
    end;
   end;
  end else
  begin
   DrawImage.Canvas.Font.Color:=0;
   DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(text_error_out) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2,text_error_out);
   DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(FileName) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2+DrawImage.Canvas.Textheight(FileName)+4,FileName);
  end;
  if WaitImageTimer.Enabled and FImageExists then
  begin
   TW.I.Start('WaitImageTimer');
   WaitImage.Width:=DrawImage.Width;
   WaitImage.Height:=DrawImage.Height;
   GrayScaleImage(DrawImage,WaitImage,WaitGrayScale);
   Canvas.Draw(0,0,WaitImage);
   TW.I.Start('WaitImageTimer - end');
   exit;
  end;
  if (not WaitImageTimer.Enabled) and (RealImageHeight*RealImageWidth<>0) then
  begin
   if ZoomerOn then z:=RealZoomInc*Zoom else
   begin
    if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATE_270) then
    z:=min(fw/RealImageHeight,fh/RealImageWidth) else
    z:=min(fw/RealImageWidth,fh/RealImageHeight);
   end;
   if WaitingList then
   Caption:=Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d] - ' + L('Loading list of images') + '...',[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)]) else
   Caption:=Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d]', [ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,z*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)])+GetPageCaption;
  end;
  LastZValue:=z;
 FormPaint(Sender);
end;

procedure TViewer.FormResize(Sender: TObject);
begin
 TW.I.Start('TViewer.FormResize');
 if FCreating then
   Exit;
 DrawImage.width:=ClientWidth;
 DrawImage.Height:=HeightW;
 if not WaitImageTimer.Enabled then
 ReAllignScrolls(False,Point(0,0));
 RecreateDrawImage(Sender);
 ToolsBar.Left:=ClientWidth div 2- ToolsBar.Width div 2;
 BottomImage.Top:=ClientHeight - ToolsBar.Height;
 BottomImage.Width:=ClientWidth;
 BottomImage.Height:=ToolsBar.Height;
 Canvas.Brush.Color:=ClBtnFace;
 Canvas.Pen.Color:=ClBtnFace;
 Canvas.Rectangle(0,HeightW,ClientWidth,ClientHeight);
 if StaticImage then  else
 begin
  Canvas.Rectangle(0,0,Width,HeightW);
  FormPaint(Sender);
 end;
 TbrActions.Refresh;
 TW.I.Start('TViewer.FormResize - end');
end;

procedure TViewer.Next_(Sender: TObject);
begin
  if Length(CurrentInfo.ItemFileNames)<2 then exit;
  inc(CurrentFileNumber);
  if CurrentFileNumber>=Length(CurrentInfo.ItemFileNames) then
  CurrentFileNumber:=0;
  fCurrentPage:=0;
  if SlideShowNow then
  if CurrentInfo.ItemCrypted[CurrentFileNumber] or ValidCryptGraphicFile(CurrentInfo.ItemFileNames[CurrentFileNumber]) then
  if DBKernel.FindPasswordForCryptImageFile(CurrentInfo.ItemFileNames[CurrentFileNumber])='' then exit;
  if not SlideShowNow then
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false) else
end;

procedure TViewer.Previous_(Sender: TObject);
begin
  if Length(CurrentInfo.ItemFileNames)<2 then exit;
  Dec(CurrentFileNumber);
  if CurrentFileNumber<0 then
  CurrentFileNumber:=Length(CurrentInfo.ItemFileNames)-1;
  fCurrentPage:=0;
  if not SlideShowNow then
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
end;

procedure TViewer.NextImageClick(Sender: TObject);
begin
 if not SlideShowNow then
 begin
  if FullScreenNow then
  if Play then
  begin
   SlideTimer.Enabled:=false;
   SlideTimer.Enabled:=true;
  end;
  Next_(Sender);
 end else
 begin
  if DirectShowForm<>nil then
  DirectShowForm.Next(false);
 end;
end;

procedure TViewer.PreviousImageClick(Sender: TObject);
begin
 if not SlideShowNow then
 begin
  if FullScreenNow then
  if Play then
  begin
   SlideTimer.Enabled:=false;
   SlideTimer.Enabled:=true;
  end;
  Previous_(Sender);
 end else
 begin
  if DirectShowForm<>nil then
  DirectShowForm.Previous;
 end;
end;

procedure TViewer.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PWideChar(CurrentInfo.ItemFileNames[CurrentFileNumber]), nil, nil, SW_NORMAL);
end;

procedure TViewer.FormDestroy(Sender: TObject);
begin
  CurrentInfo := RecordsInfoNil;
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
 if Loading then exit;
 FullScreenNow:=true;
 SlideTimer.Enabled:=true;
 Play:=true;
 WaitImageTimer.Enabled:=false;
 RecreateDrawImage(Sender);
 if FullScreenView=nil then
 Application.CreateForm(TFullScreenView, FullScreenView);
 MTimer1.ImageIndex:=DB_IC_PAUSE;
 MTimer1Click(Sender);
 FullScreenView.show;
end;

procedure TViewer.Exit1Click(Sender: TObject);
begin
 if not FullScreenNow and not SlideShowNow then
 begin
  Close;
 end;
 if FullScreenNow then
 begin
  FloatPanel.Release;
  FloatPanel.Free;
  FloatPanel:=nil;
  FullScreenNow:=false;
  RecreateDrawImage(Sender);
  SlideTimer.Enabled:=false;
  Play:=false;
  if FullScreenView<>nil then FullScreenView.Close;
 end;
 if SlideShowNow then
 begin
  FloatPanel.Release;
  FloatPanel.Free;
  FloatPanel:=nil;
  SlideShowNow:=false;
  Loading:=true;
  ImageExists:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
  if DirectShowForm<>nil then DirectShowForm.Close;
 end;
end;

procedure TViewer.PaintBox1DblClick(Sender: TObject);
begin
 FullScreen1Click(sender);
end;

procedure TViewer.FormPaint(Sender: TObject);
begin
 if SlideShowNow or FullScreenNow then exit;
 if WaitImageTimer.Enabled then
 begin
   if FImageExists then
     Canvas.Draw(0,0,WaitImage)
 end else
   Canvas.draw(0,0,DrawImage);
end;

procedure TViewer.NewPicture(Sender: TObject);
var
  fh,fw,x1,x2,y1,y2 : integer;
begin
 if not SlideShowNow then
 begin
  Fcsrbmp.Assign(Fnowcsrbmp);
  FNewCsrBmp.Canvas.Rectangle(0,0,FNewCsrBmp.width,FNewCsrBmp.Height);
  if (FbImage.Height=0) or (FbImage.width=0) then exit;
  if (FbImage.width>FNewCsrBmp.width) or (FbImage.Height>FNewCsrBmp.Height) then
  begin
   if FbImage.width/FbImage.Height<FNewCsrBmp.width/FNewCsrBmp.Height then
   begin
    fh:=FNewCsrBmp.Height;
    fw:=round(FNewCsrBmp.Height*(FbImage.width/fbImage.Height));
   end else begin
    fw:=FNewCsrBmp.width;
    fh:=round(FNewCsrBmp.width*(FbImage.Height/fbImage.width));
   end;
  end else begin
   fh:=FbImage.Height;
   fw:=FbImage.width;
  end;
  x1:=Screen.Width div 2 - fw div 2;
  y1:=Screen.Height div 2 - fh div 2;
  x2:=Screen.Width div 2 + fw div 2;
  y2:=Screen.Height div 2 + fh div 2;
  If DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True) then
  StretchCool(x1,y1,x2-x1,y2-y1,FbImage,FNewCsrBmp) else
  FNewCsrBmp.Canvas.StretchDraw(rect(x1,y1,x2,y2),FbImage);
 end else
 begin
  if DirectShowForm=nil then exit;
  FNewCsrBmp.Canvas.Rectangle(0,0,FNewCsrBmp.width,FNewCsrBmp.Height);
  if (FbImage.Height=0) or (FbImage.width=0) then exit;
  if (FbImage.width>FNewCsrBmp.width) or (FbImage.Height>FNewCsrBmp.Height) then
  begin
   if FbImage.width/FbImage.Height<FNewCsrBmp.width/FNewCsrBmp.Height then
   begin
    fh:=FNewCsrBmp.Height;
    fw:=round(FNewCsrBmp.Height*(FbImage.width/fbImage.Height));
   end else begin
    fw:=FNewCsrBmp.width;
    fh:=round(FNewCsrBmp.width*(FbImage.Height/fbImage.width));
   end;
  end else begin
   fh:=FbImage.Height;
   fw:=FbImage.width;
  end;
  x1:=Screen.Width div 2 - fw div 2;
  y1:=Screen.Height div 2 - fh div 2;
  x2:=Screen.Width div 2 + fw div 2;
  y2:=Screen.Height div 2 + fh div 2;
  If DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True) then
  StretchCool(x1,y1,x2-x1,y2-y1,FbImage,FNewCsrBmp) else
  FNewCsrBmp.Canvas.StretchDraw(rect(x1,y1,x2,y2),FbImage);
  if DirectShowForm.FirstLoad then
  begin
   DirectShowForm.SetFirstImage(FNewCsrBmp);
  end else
  begin
   DirectShowForm.NewImage(FNewCsrBmp);
  end;
 end;
end;

procedure TViewer.PopupMenu1Popup(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
  I: Integer;

  procedure InitializeInfo;
  begin
    MenuRecord := TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(CurrentInfo, CurrentFileNumber);
    Info.Add(MenuRecord);
  end;

begin
  LoadPopupMenuLanguage;
 if Length(CurrentInfo.ItemIds)=0 then exit;
 Info := TDBPopupMenuInfo.Create;
 try
 Info.IsPlusMenu:=false;
 Info.IsListItem:=false;
 For i:=N2.MenuIndex+1 to DBItem1.MenuIndex-1 do
 PopupMenu1.Items.Delete(N2.MenuIndex+1);
 if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
 begin
  AddToDB1.Visible:=false;
  DBItem1.Visible:=true;
  DBItem1.Caption:=Format(L('DB Item [%d]'),[CurrentInfo.ItemIds[CurrentFileNumber]]);
  InitializeInfo;
  TDBPopupMenu.Instance.AddDBContMenu(DBItem1,info);
 end else
 begin

  if DBKernel.ReadBool('Options','UseUserMenuForViewer',true) then
  if not (SlideShowNow or FullScreenNow) then
  begin
   InitializeInfo;
   TDBPopupMenu.Instance.SetInfo(info);
   TDBPopupMenu.Instance.AddUserMenu(PopupMenu1.Items,true,N2.MenuIndex+1);
  end;

  AddToDB1.Visible:=True;
  DBItem1.Visible:=false;
 end;
 FullScreen1.Visible:=not (FullScreenNow or SlideShowNow);
 SlideShow1.Visible:=not (FullScreenNow or SlideShowNow);
 begin
  AddToDB1.Visible:=AddToDB1.Visible and not (SlideShowNow or FullScreenNow) and not CurrentInfo.ItemCrypted[CurrentFileNumber];
  ZoomOut1.Visible:=not (SlideShowNow or FullScreenNow) and ImageExists;
  ZoomIn1.Visible:=not (SlideShowNow or FullScreenNow) and ImageExists;
  RealSize1.Visible:=not (SlideShowNow or FullScreenNow) and ImageExists;
  BestSize1.Visible:=not (SlideShowNow or FullScreenNow) and ImageExists;
  DBItem1.Visible:=not (SlideShowNow or FullScreenNow) and (CurrentInfo.ItemIds[CurrentFileNumber]<>0);
  SetasDesktopWallpaper1.Visible:=not (SlideShowNow) and ImageExists and not CurrentInfo.ItemCrypted[CurrentFileNumber] and IsWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber]);
  Rotate1.Visible:=not (SlideShowNow) and ImageExists;
  Properties1.Visible:=not (SlideShowNow or FullScreenNow);
  GoToSearchWindow1.Visible:=not (SlideShowNow);
  Explorer1.Visible:=not (SlideShowNow);
  Resize1.Visible:=not (SlideShowNow or FullScreenNow) and ImageExists;
  Shell1.Visible:=not (SlideShowNow or FullScreenNow);
  Print1.Visible:=not (SlideShowNow) and ImageExists;
  ImageEditor1.Visible:=not (SlideShowNow) and ImageExists;
  SendTo1.Visible:=not (SlideShowNow) and ImageExists and (CurrentInfo.ItemIds[CurrentFileNumber]=0);
 end;

 Tools1.Visible:=Resize1.Visible or Print1.Visible or ImageEditor1.Visible or GoToSearchWindow1.Visible;
 NewPanel1.Visible:=Tools1.Visible;
 finally
   F(Info);
 end;
end;

procedure TViewer.MTimer1Click(Sender: TObject);
begin
 if not SlideShowNow then
 begin
  if MTimer1.ImageIndex=DB_IC_PAUSE then
  begin
   MTimer1.Caption:= L('Start timer');
   MTimer1.ImageIndex:=DB_IC_PLAY;
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Down:=false;
    FloatPanel.ToolButton2.Down:=true;
   end;
   SlideTimer.Enabled:=false;
   Play:=false;
  end else begin
   MTimer1.Caption:=L('Stop timer');
   MTimer1.ImageIndex:=DB_IC_PAUSE;
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Down:=true;
    FloatPanel.ToolButton2.Down:=false;
   end;
   SlideTimer.Enabled:=true;
   Play:=true;
  end;
 end else
 begin
  if MTimer1.ImageIndex=DB_IC_PAUSE then
  begin
   if DirectShowForm<>nil then
   DirectShowForm.Pause;
   MTimer1.Caption:=L('Start timer');
   MTimer1.ImageIndex:=DB_IC_PLAY;
   FloatPanel.ToolButton1.Down:=false;
   FloatPanel.ToolButton2.Down:=true;
  end else begin
   if DirectShowForm<>nil then
   DirectShowForm.Play;
   MTimer1.Caption:=L('Stop timer');
   MTimer1.ImageIndex:=DB_IC_PAUSE;
   FloatPanel.ToolButton1.Down:=true;
   FloatPanel.ToolButton2.Down:=false;
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
      if Length(CurrentInfo.ItemFileNames) > 0 then
      begin
        FileName := CurrentInfo.ItemFileNames[CurrentFileNumber];
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
  i : integer;
begin
 if Viewer=nil then exit;

 if [EventID_Param_Rotate,EventID_Param_Image,EventID_Param_Name]*params<>[] then
 begin
  for i:=0 to LockEventRotateFileList.Count-1 do
  if AnsiLowerCase(Value.Name)=LockEventRotateFileList[i] then
  begin
   LockEventRotateFileList.Delete(i);
   exit;
  end;
 end;

 if SetNewIDFileData in params then
 begin
  for i:=0 to Length(CurrentInfo.ItemIds)-1 do
  if AnsiLowerCase(CurrentInfo.ItemFileNames[i])=AnsiLowerCase(Value.Name) then
  begin
   CurrentInfo.ItemIds[i]:=ID;
   CurrentInfo.ItemDates[i]:=Value.Date;
   CurrentInfo.ItemTimes[i]:=Value.Time;
   CurrentInfo.ItemIsDates[i]:=true;
   CurrentInfo.ItemIsTimes[i]:=Value.IsTime;
   break;
  end;
  exit;
 end;


 if ID>0 then
 begin
  for i:=0 to Length(CurrentInfo.ItemIds)-1 do
  if CurrentInfo.ItemIds[i]=ID then
  begin
   if EventID_Param_Private in params then
   CurrentInfo.ItemAccesses[i]:=Value.Access;
   if EventID_Param_IsDate in params then
   CurrentInfo.ItemIsDates[i]:=Value.IsDate;
   if EventID_Param_IsTime in params then
   CurrentInfo.ItemIsTimes[i]:=Value.IsTime;
   if EventID_Param_Crypt in params then
   CurrentInfo.ItemCrypted[i]:=Value.Crypt;
   if EventID_Param_Groups in params then
   CurrentInfo.ItemGroups[i]:=Value.Groups;
   if EventID_Param_Date in params then
   CurrentInfo.ItemDates[i]:=Value.Date;
   if EventID_Param_Time in params then
   CurrentInfo.ItemTimes[i]:=Value.Time;
   if EventID_Param_Rating in params then
   begin
    CurrentInfo.ItemRatings[i]:=Value.Rating;
    if i=CurrentFileNumber then
      DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];
   end;
   if EventID_Param_Name in params then
   CurrentInfo.ItemFileNames[i]:=Value.Name;
   if EventID_Param_KeyWords in params then
   CurrentInfo.ItemKeyWords[i]:=Value.KeyWords;
   if EventID_Param_Links in params then
   CurrentInfo.ItemLinks[i]:=Value.Links;
   if EventID_Param_Comment in params then
   CurrentInfo.ItemComments[i]:=Value.Comment;
   if EventID_Param_Delete in params then
   begin
    CurrentInfo.LoadedImageInfo[i]:=true;
    CurrentInfo.ItemIds[i]:=0;
    if i=CurrentFileNumber then
    LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
    exit;
   end;
  end;
 end;
 If (EventID_Param_Name in params) then
 begin
  if CurrentInfo.ItemFileNames[CurrentFileNumber]=Value.Name then
  begin
   if Value.NewName<>'' then
   CurrentInfo.ItemFileNames[CurrentFileNumber]:=Value.NewName;
   CurrentInfo.LoadedImageInfo[CurrentFileNumber]:=false;
   LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
   exit;
  end;

  if ID=-1 then
  for i:=0 to Length(CurrentInfo.ItemIds)-1 do
  if CurrentInfo.ItemFileNames[i]=Value.NewName then
  begin
   CurrentInfo.LoadedImageInfo[i]:=false;
   if i=CurrentFileNumber then
   LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
   exit;
  end;

 end;
 if Length(CurrentInfo.ItemIds)-1<CurrentFileNumber then exit;
 if id=CurrentInfo.ItemIds[CurrentFileNumber] then
 begin
  If (EventID_Param_Rotate in params) then
  CurrentInfo.ItemRotates[CurrentFileNumber]:=Value.Rotate;
  If (EventID_Param_Rotate in params) or (EventID_Param_Image in params) then
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
 end;
end;

procedure TViewer.LoadListImages(List: TstringList);
var
  i : integer;
  FileName : string;
  fQuery : TDataSet;
begin
 if List.Count=0 then exit;
 CurrentInfo:=RecordsInfoNil;
 fQuery:=GetQuery;
 for i := 0 to List.Count-1 do
 begin
  FileName:=List[i];
  SetSQL(fQuery,'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FileName))+' AND FFileName LIKE :FFileName');
  SetStrParam(fQuery,0,Delnakl(NormalizeDBStringLike(AnsiLowerCase(FileName))));
  fQuery.active:=true;
  if fQuery.RecordCount<>0 then
  begin
   fQuery.First;
   AddRecordsInfoOne(CurrentInfo,fQuery.FieldByName('FFileName').AsString,fQuery.FieldByName('ID').AsInteger, fQuery.FieldByName('Rotated').AsInteger,fQuery.FieldByName('Rating').AsInteger,fQuery.FieldByName('Access').AsInteger,fQuery.FieldByName('Comment').AsString,fQuery.FieldByName('KeyWords').AsString,fQuery.FieldByName('Owner').AsString,fQuery.FieldByName('Collection').AsString,fQuery.FieldByName('Groups').AsString,fQuery.FieldByName('DateToAdd').AsDateTime,fQuery.FieldByName('IsDate').AsBoolean,fQuery.FieldByName('IsTime').AsBoolean,fQuery.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')),true,fQuery.FieldByName('Include').AsBoolean,fQuery.FieldByName('Links').AsString);
  end else begin
  AddRecordsInfoOne(CurrentInfo,FileName,0,0,0,0,'','','','','',0,false,false,0,ValidCryptGraphicFile(FileName),true,false,'');
  end;
 end;
 FreeDS(fQuery);
 CurrentFileNumber:=0;
 LoadImage_(nil,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
 Show;
 SetFocus;
 if Length(CurrentInfo.ItemFileNames)<2 then
 begin
  TbBack.Enabled := False;
  TbForward.Enabled := False;
  SetProgressPosition(0, 0);
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton4.Enabled:=false;
   FloatPanel.ToolButton5.Enabled:=false;
   FloatPanel.ToolButton1.Enabled:=false;
   FloatPanel.ToolButton2.Enabled:=false;
  end;
 end else
 begin
  SetProgressPosition(CurrentFileNumber + 1, Length(CurrentInfo.ItemFileNames));
  TbBack.Enabled := True;
  TbForward.Enabled := True;
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton4.Enabled:=True;
   FloatPanel.ToolButton5.Enabled:=True;
   FloatPanel.ToolButton1.Enabled:=True;
   FloatPanel.ToolButton2.Enabled:=True;
  end;
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
  Info: TRecordsInfo;
begin
  Info := RecordsInfoOne(FileName, 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0,
    ValidCryptGraphicFile(FileName), False, False, '');
  Execute(nil, Info);
end;

procedure TViewer.ShowFolder(Files: Tstrings; CurrentN : integer);
var
  I: Integer;
  Info: TRecordsInfo;
begin
  Info := RecordsInfoNil;
  if Files = nil then
    Exit;
  for I := 0 to Files.Count - 1 do
  begin
    AddRecordsInfoOne(Info, Files[I], 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0,
      ValidCryptGraphicFile(Files[I]), False, False, '');
  end;
  Info.Position := CurrentN;
  Execute(nil, Info);
end;

procedure TViewer.UpdateRecord(FileNo: integer);
var
  DS : TDataSet;
  FileName : string;
begin
  DS := GetQuery;
  try
    FileName := CurrentInfo.ItemFileNames[FileNo];
    SetSQL(DS,'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FileName))+' AND FFileName LIKE :FFileName');
    SetStrParam(DS, 0, DelNakl(AnsiLowerCase(FileName)));
    DS.Active := True;
    if DS.RecordCount=0 then
      Exit;
    SetRecordsInfoOne(CurrentInfo,FileNo,DS.FieldByName('FFileName').AsString,DS.FieldByName('ID').AsInteger,DS.FieldByName('Rotated').AsInteger,DS.FieldByName('Rating').AsInteger,DS.FieldByName('Access').AsInteger,DS.FieldByName('Comment').AsString,DS.FieldByName('Groups').AsString,DS.FieldByName('DateToAdd').AsDateTime,DS.FieldByName('IsDate').AsBoolean,DS.FieldByName('IsTime').AsBoolean,DS.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(DS.FieldByName('thum')),DS.FieldByName('Include').AsBoolean,DS.FieldByName('Links').AsString);
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

      SetProgressPosition(CurrentFileNumber + 1, Length(CurrentInfo.ItemFileNames));
    end;
  end;

  if not Active or SlideShowNow or FullScreenNow then
    Exit;

    if Msg.message = WM_KEYDOWN then
    begin
      WindowsMenuTickCount := GetTickCount;

      if Msg.WParam = VK_LEFT then
        PreviousImageClick(nil);

      if Msg.WParam = VK_RIGHT then
        NextImageClick(nil);

      if Msg.Hwnd = Handle then
        if Msg.WParam = VK_ESCAPE then
          Close;

      if (Msg.WParam = VK_DELETE) then
        TbDeleteClick(nil);

      if (Msg.wParam = Byte(' ')) then
        Next_(nil);

      if CtrlKeyDown then
      begin
        if Msg.wParam = Byte('F') then FitToWindowClick(nil);
        if Msg.wParam = Byte('A') then RealSizeClick(nil);
        if Msg.wParam = Byte('S') then TbSlideShowClick(nil);
        if Msg.wParam = VK_RETURN then FullScreen1Click(nil);
        if Msg.wParam = Byte('I') then TbZoomOutClick(nil);
        if Msg.wParam = Byte('O') then TbZoomInClick(nil);
        if Msg.wParam = Byte('L') then RotateCCW1Click(nil);
        if Msg.wParam = Byte('R') then RotateCW1Click(nil);
        if Msg.wParam = Byte('D') then TbDeleteClick(nil);
        if Msg.wParam = Byte('P') then Print1Click(nil);
        if Msg.wParam = Byte('E') then ImageEditor1Click(nil);
        if Msg.wParam = Byte('Z') then Properties1Click(nil);

        if (Msg.wParam = Byte('0')) or (Msg.wParam = Byte(VK_NUMPAD0)) then N51Click(N01);
        if (Msg.wParam = Byte('1')) or (Msg.wParam = Byte(VK_NUMPAD1)) then N51Click(N11);
        if (Msg.wParam = Byte('2')) or (Msg.wParam = Byte(VK_NUMPAD2)) then N51Click(N21);
        if (Msg.wParam = Byte('3')) or (Msg.wParam = Byte(VK_NUMPAD3)) then N51Click(N31);
        if (Msg.wParam = Byte('4')) or (Msg.wParam = Byte(VK_NUMPAD4)) then N51Click(N41);
        if (Msg.wParam = Byte('5')) or (Msg.wParam = Byte(VK_NUMPAD5)) then N51Click(N51);
      end;

    Msg.message:=0;
  end;

  if (Msg.message = WM_RBUTTONDOWN) or (Msg.message = WM_RBUTTONUP) then
    if (Msg.Hwnd = BottomImage.Handle) or (Msg.Hwnd = TbrActions.Handle) or (Msg.Hwnd = ScrollBar1.Handle) or
      (Msg.Hwnd = ScrollBar2.Handle) then
      Msg.message := 0;

  if (Msg.message = WM_MOUSEWHEEL) then
  begin
    if ZoomerOn or CtrlKeyDown then
    begin
      if Msg.WParam > 0 then
        TbZoomOutClick(nil)
      else
        TbZoomInClick(nil);
    end else
    begin
      if Msg.WParam > 0 then
        Previous_(nil)
      else
        Next_(nil);
    end;
  end;
end;

procedure TViewer.ShowFolderA(FileName : string; ShowPrivate : Boolean);
var
  N : integer;
  Info : TRecordsInfo;
begin
  if FileExists(FileName) then
  begin
    FileName := LongFileName(FileName);
    GetFileListByMask(FileName, SupportedExt, Info, N, ShowPrivate);
    if Length(info.ItemFileNames) > 0 then
      Execute(Self, info);
  end;
end;

procedure TViewer.ExecuteDirectoryWithFileOnThread(FileName : String);
var
  Info: TRecordsInfo;
begin
  NewFormState;
  WaitingList := True;
  TSlideShowScanDirectoryThread.Create(Self, StateID, FileName);
  Info := RecordsInfoOne(FileName, 0,0,0,0,'','','','','',0, False, False, 0, ValidCryptGraphicFile(FileName), False, False, '');
  ExecuteW(Self, Info, '');
  Caption := Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d] - ' + L('Loading list of images') + '...',[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]), RealImageWidth, RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)]);

end;

function TViewer.Execute(Sender: TObject; Info: TRecordsInfo) : boolean;
begin
  NewFormState;
  WaitingList:=false;
  Result:=ExecuteW(Sender, Info, '');
end;

function TViewer.ExecuteW(Sender: TObject; Info: TRecordsInfo; LoadBaseFile : String) : boolean;
var
  i : integer;
  s, Dir, text_out : String;
  si : TStartupInfo;
  p  : TProcessInformation;
  TempInfo : TOneRecordInfo;
  LoadImage : TPNGImage;
  LoadImageBMP : TBitmap;
  FOldImageExists : Boolean;

begin
 TW.I.Start('ExecuteW');
 Result:=true;
 SlideTimer.Enabled:=false;
 Play:=false;
 //Loading:=true;
 FullScreenNow:=false;
 SlideShowNow:=false;
 FOldImageExists := ImageExists;
 ImageExists:=false;
 if LoadBaseFile = '' then
   ImageFrameTimer.Enabled := False;
 TW.I.Start('ToolButton1.Enabled');
 if Length(Info.ItemFileNames)=0 then
 begin
  SetProgressPosition(0, 0);
  TbBack.Enabled := False;
  TbForward.Enabled := False;
  TbFitToWindow.Enabled:=false;
  TbRealSize.Enabled:=false;
  TbSlideShow.Enabled:=false;
  TbZoomOut.Enabled:=false;
  TbZoomIn.Enabled:=false;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
 end else
 begin
  SetProgressPosition(Info.Position + 1, Length(Info.ItemFileNames));
  TbBack.Enabled := True;
  TbForward.Enabled := True;
  TbFitToWindow.Enabled:=true;
  TbRealSize.Enabled:=true;
  TbSlideShow.Enabled:=true;
  TbZoomOut.Enabled:=true;
  TbZoomIn.Enabled:=true;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
 end;
 TW.I.Start('SlideShow_UseExternelViewer');
 if not UseOnlySelf then
 if not ((FormManager.MainFormsCount=1) and FormManager.IsMainForms(self)) then

 if DBKernel.ReadboolW('Options','SlideShow_UseExternelViewer',False) then
 begin
  s:='';
  if Length(Info.ItemFileNames)=0 then Exit;
  For i:=Info.Position to Length(Info.ItemFileNames)-1 do
  s:=s+' "'+Info.ItemFileNames[i]+'" ';
  For i:=0 to Info.Position-1 do
  s:=s+' "'+Info.ItemFileNames[i]+'" ';
  Dir:=GetDirectory(DBKernel.ReadStringW('Options','SlideShow_ExternelViewer'));
  If AnsiLowercase(Dir)=AnsiLowercase(ProgramDir) then Exit;
  UnFormatDir(Dir);
  FillChar( Si, SizeOf( Si ) , 0 );
  with Si do begin
   cb := SizeOf( Si);
   dwFlags := startf_UseShowWindow;
   wShowWindow := 4;
  end;
  for i:=Length(Dir) downto 1 do
  if dir[i]='"' then
  Delete(Dir,i,1);
  CreateProcess(nil,PChar(Format(DBKernel.ReadStringW('Options','SlideShow_ExternelViewer'),[S])),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(Dir),si,p);
  Result:=false;
  Exit;
 end;
 if (LoadBaseFile<>'') and (Length(CurrentInfo.ItemIds)=1) then
 begin
  TempInfo:=GetRecordFromRecords(CurrentInfo,0);
 end else
 begin
  TempInfo.ItemId:=-1;
 end;
 CurrentInfo:=RecordsInfoNil;
 CurrentInfo.Position:=-1;
 for i:=0 to length(Info.ItemFileNames)-1 do
// All file operations in threads! if FileExists(Info.ItemFileNames[i]) then
 begin
  if (Info.Position<=i) and (CurrentInfo.Position=-1) then
  CurrentInfo.Position:=Length(CurrentInfo.ItemFileNames);
  if TempInfo.ItemId>0 then
  if AnsiLowerCase(TempInfo.ItemFileName)=AnsiLowerCase(Info.ItemFileNames[i]) then
  begin
   AddToRecordsInfoOneInfo(CurrentInfo,TempInfo);
   CurrentInfo.Position:=length(CurrentInfo.ItemIds)-1;
   continue;
  end;
   AddRecordsInfoOne(CurrentInfo,Info.ItemFileNames[i],Info.ItemIds[i],Info.ItemRotates[i],Info.ItemRatings[i],Info.ItemAccesses[i],'',Info.ItemKeyWords[i],'','',Info.ItemGroups[i],Info.ItemDates[i],Info.ItemIsDates[i],Info.ItemIsTimes[i],Info.ItemTimes[i],Info.ItemCrypted[i],Info.LoadedImageInfo[i],Info.ItemInclude[i],Info.ItemLinks[i]);
 end;
 If CurrentInfo.Position=-1 then CurrentInfo.Position:=0;

 TW.I.Start('DoProcessPath');
 if CurrentInfo.Position < Length(CurrentInfo.ItemFileNames) then
   DoProcessPath(CurrentInfo.ItemFileNames[CurrentInfo.Position],true);
 for i:=0 to length(CurrentInfo.ItemFileNames)-1 do
 DoProcessPath(CurrentInfo.ItemFileNames[i]);

 begin
  If Length(CurrentInfo.ItemFileNames)=0 then exit;
  if not FullScreenNow then
  if FullScreenView<>nil then
  FullScreenView.Close;
  if not SlideShowNow then
  if DirectShowForm<>nil then
  DirectShowForm.Close;

  CurrentFileNumber:=CurrentInfo.Position;
  if not ((LoadBaseFile<>'') and (AnsiLowerCase(CurrentInfo.ItemFileNames[CurrentFileNumber])=AnsiLowerCase(LoadBaseFile))) then
  begin
   Loading := True;
   TW.I.Start('LoadImage_');
   if LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false) then
   begin
    FbImage.Canvas.Brush.Color:=ClBtnFace;
    FbImage.Canvas.pen.Color:=ClBtnFace;
    if FNewCsrBmp<>nil then
    FNewCsrBmp.Canvas.Rectangle(0,0,FNewCsrBmp.width,FNewCsrBmp.Height);
    FbImage.Width:=170;
    FbImage.Height:=170;
    FbImage.Canvas.Rectangle(0,0,FbImage.width,FbImage.Height);

    LoadImage := GetSlideShowLoadPicture;
    try
      LoadImageBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(LoadImage, LoadImageBMP, ClBtnFace);
        FbImage.Canvas.Draw(0, 0, LoadImageBMP);
      finally
        LoadImageBMP.Free;
      end;
    finally
      LoadImage.Free;
    end;

    text_out := L('Processing') + '...';
    FbImage.Canvas.TextOut(FbImage.Width div 2-FbImage.Canvas.TextWidth(text_out) div 2,FbImage.Height{ div 2}-4*FbImage.Canvas.Textheight(text_out) div 2,text_out);

    TW.I.Start('RecreateDrawImage_');
    RecreateDrawImage(Sender);
    TW.I.Start('FormPaint');
    FormPaint(Sender);
   end;

  end else
  begin
   Caption:=Format(L('View') + ' - %s   [%dx%d] %f%%   [%d/%d]',[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)])+GetPageCaption;
   DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];
   FImageExists := FOldImageExists;
   TbRotateCW.Enabled:=TbRotateCCW.Enabled;
  end;
 end;
 UseOnlySelf:=false;
 if Length(CurrentInfo.ItemFileNames)<2 then
 begin
  TbBack.Enabled := False;
  TbForward.Enabled := False;
  SetProgressPosition(0, 0);
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton1.Enabled:=false;
   FloatPanel.ToolButton2.Enabled:=false;
   FloatPanel.ToolButton4.Enabled:=false;
   FloatPanel.ToolButton5.Enabled:=false;
  end;
 end else
 begin
  TbBack.Enabled := True;
  TbForward.Enabled := True;
  SetProgressPosition(CurrentFileNumber + 1, Length(CurrentInfo.ItemFileNames));
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton1.Enabled:=True;
   FloatPanel.ToolButton2.Enabled:=True;
   FloatPanel.ToolButton4.Enabled:=True;
   FloatPanel.ToolButton5.Enabled:=True;
  end;
 end;
 TW.I.Start('ExecuteW - end');
end;

procedure TViewer.CreateParams(var Params: TCreateParams);
begin
  TW.I.Start('CreateParams');
  Inherited CreateParams(Params);
  TW.I.Start('GetDesktopWindow');
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
  TW.I.Start('CreateParams - END');
end;

procedure TViewer.WaitImageTimerTimer(Sender: TObject);
begin
 WaitGrayScale:=WaitGrayScale + IncGrayScale;
 If WaitGrayScale>100 then
 begin
  WaitGrayScale:=100;
  Exit;
 end;
 WaitImage.Width:=drawimage.Width;
 WaitImage.Height:=drawimage.Height;
 GrayScaleImage(Drawimage, WaitImage, WaitGrayScale);
 Canvas.Draw(0, 0, WaitImage);
end;

procedure TViewer.DoWaitToImage(Sender: TObject);
begin
 If WaitImageTimer.Enabled then exit;
 WaitImageTimer.Enabled:=True;
 WaitGrayScale := 0;
end;

procedure TViewer.EndWaitToImage(Sender: TObject);
begin
 WaitImageTimer.Enabled:=false;
 WaitGrayScale := 0;
end;

procedure TViewer.Onlythisfile1Click(Sender: TObject);
begin
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddFile(CurrentInfo.ItemFileNames[CurrentFileNumber])
end;

procedure TViewer.AllFolder1Click(Sender: TObject);
begin
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddDirectory(GetDirectory(CurrentInfo.ItemFileNames[CurrentFileNumber]),nil)
end;

procedure TViewer.GoToSearchWindow1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 if FullScreenNow then
 Exit1Click(nil);
 NewSearch:=SearchManager.GetAnySearch;
 NewSearch.Show;
 NewSearch.SetFocus;
end;

procedure TViewer.Explorer1Click(Sender: TObject);
begin
 if FullScreenNow then
 Exit1Click(nil);
 With ExplorerManager.NewExplorer(False) do
 begin
  SetOldPath(CurrentInfo.ItemFileNames[CurrentFileNumber]);
  SetPath(GetDirectory(CurrentInfo.ItemFileNames[CurrentFileNumber]));
  Show;
 end;
end;

procedure TViewer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if FullScreenView<>nil then
 Exit1Click(nil);
 if DirectShowForm<>nil then
 DirectShowForm.Close;
 DestroyTimer.Enabled:=true;
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
    FileList.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
    Copy_Move(True, FileList);
  finally
     FileList.Free;
  end;
end;

procedure TViewer.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 WindowsMenuTickCount:=GetTickCount;
 if length(CurrentInfo.ItemFileNames)=0 then exit;
 If Button=mbLeft then
 if FileExists(CurrentInfo.ItemFileNames[CurrentFileNumber]) then
 begin
  DBCanDrag:=True;
  GetCursorPos(DBDragPoint);
 end;
end;

procedure TViewer.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 DBCanDrag:=false;
end;

procedure TViewer.ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
 if ScrollPos>(Sender as TScrollBar).Max-(Sender as TScrollBar).PageSize then
 ScrollPos:=(Sender as TScrollBar).Max-(Sender as TScrollBar).PageSize;
 RecreateDrawImage(Sender);
end;

procedure TViewer.ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
var
  inc_ : integer;
  pos, m, ps : integer;
  v1,v2 : boolean;

begin
 Panel1.Visible:=false;
 if not ZoomerOn then
 begin
  ScrollBar1.Position:=0;
  ScrollBar1.Visible:=false;
  ScrollBar2.Position:=0;
  ScrollBar2.Visible:=false;
  Exit;
 end;
 v1:=ScrollBar1.Visible;
 v2:=ScrollBar2.Visible;
 if not ScrollBar1.Visible and not ScrollBar2.Visible then
 begin
  ScrollBar1.Visible:=FbImage.Width*zoom>ClientWidth;
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar2.Visible:=FbImage.height*zoom>HeightW-inc_;
 end;
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar1.Visible:=FbImage.Width*zoom>ClientWidth-inc_;
  ScrollBar1.Width:=ClientWidth-Inc_;
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar1.Top:=HeightW-Inc_;
 end;
 begin
  if ScrollBar1.Visible then inc_:=ScrollBar1.height else inc_:=0;
  ScrollBar2.Visible:=FbImage.Height*zoom>HeightW-inc_;
  ScrollBar2.Height:=HeightW-Inc_;
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar2.Left:=ClientWidth-Inc_;
 end;
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar1.Visible:=FbImage.Width*zoom>ClientWidth-inc_;
  ScrollBar1.Width:=ClientWidth-Inc_;
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar1.Top:=HeightW-Inc_;
 end;
 if not ScrollBar1.Visible then ScrollBar1.Position:=0;
 if not ScrollBar2.Visible then ScrollBar2.Position:=0;
  if ScrollBar1.Visible and not v1 then
  begin
   ScrollBar1.PageSize:=0;
   ScrollBar1.Position:=0;
   ScrollBar1.Max:=100;
   ScrollBar1.Position:=50;
  end;
  if ScrollBar2.Visible and not v2 then
  begin
   ScrollBar2.PageSize:=0;
   ScrollBar2.Position:=0;
   ScrollBar2.Max:=100;
   ScrollBar2.Position:=50;
  end;
 Panel1.Width:=ScrollBar2.Width;
 Panel1.height:=ScrollBar1.height;
 Panel1.Left:=ClientWidth-Panel1.Width;
 Panel1.Top:=HeightW-Panel1.Height;
 Panel1.Visible:=ScrollBar1.Visible and ScrollBar2.Visible;
 if ScrollBar1.Visible then
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  m:=Round(FbImage.Width*zoom);
  ps:=ClientWidth-inc_;
  if ps>m then ps:=0;
  if (ScrollBar1.Max<>ScrollBar1.PageSize) then
  pos:=Round(ScrollBar1.Position*((m-ps)/(ScrollBar1.Max-ScrollBar1.PageSize))) else
  pos:=ScrollBar1.Position;
  if m<ScrollBar1.PageSize then
  ScrollBar1.PageSize:=ps;
  ScrollBar1.Max:=m;
  ScrollBar1.PageSize:=ps;
  ScrollBar1.LargeChange:=ps div 10;
  ScrollBar1.Position:=Math.Min(ScrollBar1.Max,pos);
 end;
 if ScrollBar2.Visible then
 begin
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  m:=Round(FbImage.Height*zoom);
  ps:=HeightW-inc_;
  if ps>m then ps:=0;
  if ScrollBar2.Max<>ScrollBar2.PageSize then
  pos:=Round(ScrollBar2.Position*((m-ps)/(ScrollBar2.Max-ScrollBar2.PageSize))) else
  pos:=ScrollBar2.Position;
  if m<ScrollBar2.PageSize then
  ScrollBar2.PageSize:=ps;
  ScrollBar2.Max:=m;
  ScrollBar2.PageSize:=ps;
  ScrollBar2.LargeChange:=ps div 10;
  ScrollBar2.Position:=Math.Min(ScrollBar2.Max,pos);
 end;
 if ScrollBar1.Position>ScrollBar1.Max-ScrollBar1.PageSize then
 ScrollBar1.Position:=ScrollBar1.Max-ScrollBar1.PageSize;
 if ScrollBar2.Position>ScrollBar2.Max-ScrollBar2.PageSize then
 ScrollBar2.Position:=ScrollBar2.Max-ScrollBar2.PageSize;
end;

procedure TViewer.RealSizeClick(Sender: TObject);
begin
 Cursor:=CrDefault;
 TbZoomOut.Down:=false;
 TbZoomIn.Down:=false;
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  Zoom:=1;
  TbFitToWindow.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  TbRealSize.Enabled:=false;
  TbSlideShow.Enabled:=false;
  TbZoomOut.Enabled:=false;
  TbZoomIn.Enabled:=false;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  ScrollBar1.PageSize:=0;
  ScrollBar1.Max:=100;
  ScrollBar1.Position:=50;
  ScrollBar2.PageSize:=0;
  ScrollBar2.Max:=100;
  ScrollBar2.Position:=50;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,1,true);
  TbrActions.Refresh;
 end else
 begin
  Zoom:=1;
  ZoomerOn:=True;
  FormResize(Sender);
 end;
end;

procedure TViewer.FitToWindowClick(Sender: TObject);
begin
 Cursor:=CrDefault;
 TbZoomOut.Down:=false;
 TbZoomIn.Down:=false;
 ZoomerOn:=False;
 Zoom:=1;
 FormResize(Sender);
end;

procedure TViewer.TbZoomOutClick(Sender: TObject);
var
//  i,n : integer;
  z : real;
begin
 TbRealSize.Down:=false;
 TbFitToWindow.Down:=false;
 Cursor:=CursorZoomOutNo;
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
  z:=1 else
  z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
  z:=1/z;
  z:=Max(z*0.8,0.01);
  TbFitToWindow.Enabled:=false;
  TbRealSize.Enabled:=false;
  TbSlideShow.Enabled:=false;
  TbZoomOut.Enabled:=false;
  TbZoomIn.Enabled:=false;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,z,true);
  TbrActions.Refresh;
 end else
 begin
  if ZoomerOn then
  begin
   z:=Zoom;
  end else
  begin
   if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
   z:=1 else
   z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
   z:=1/z;
  end;
  ZoomerOn:=True;
  Zoom:=Max(z*0.8,0.05);
  FormResize(Sender);
 end;
end;

procedure TViewer.TbZoomInClick(Sender: TObject);
var
  z : real;
begin
 TbRealSize.Down:=false;
 TbFitToWindow.Down:=false;
 Cursor:=CursorZoomInNo;
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
  z:=1 else
  z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
  z:=1/z;
  z:=Min(z*(1/0.8),16);
  TbFitToWindow.Enabled:=false;
  TbRealSize.Enabled:=false;
  TbSlideShow.Enabled:=false;
  TbZoomOut.Enabled:=false;
  TbZoomIn.Enabled:=false;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,z,true);
  TbrActions.Refresh;
 end else
 begin
  if  ZoomerOn then
  begin
   z:=Zoom;
  end else
  begin
   if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
   z:=1 else
   z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
   z:=1/z;
  end;

  ZoomerOn:=True;
  Zoom:=Min(z*(1/0.8),16);
  FormResize(Sender);
 end;
end;

procedure TViewer.FormClick(Sender: TObject);
var
  p : TPoint;
  ImRect : TRect;
  dy, dx, {xm,} x, y, z : Extended;
begin
 GetCursorPos(p);
 p:=ScreenToClient(p);
 if Cursor=CrDefault then
 begin
  if DBKernel.Readbool('Options','NextOnClick',false) then
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
 if Cursor=CursorZoomInNo then
 begin
  z:=Zoom;
  Zoom:=Min(z*(1/0.8),16);
  ImRect:=GetImageRectA;
  x:=P.x;
  y:=P.y;
  dx:=(x-(ImRect.Right-ImRect.Left) div 2)/(ImRect.Right-ImRect.Left);
  ScrollBar1.Position:=ScrollBar1.Position+Round(ScrollBar1.PageSize*dx);
  dy:=(y-(ImRect.Bottom-ImRect.Top) div 2)/(ImRect.Bottom-ImRect.Top);
  ScrollBar2.Position:=ScrollBar2.Position+Round(ScrollBar2.PageSize*dy);
 end;
 if Cursor=CursorZoomOutNo then
 begin
  z:=Zoom;
  Zoom:=Max(z*0.8,0.05);
  ImRect:=GetImageRectA;
  x:=p.x;
  y:=p.y;
  dx:=(x-(ImRect.Right-ImRect.Left) div 2)/(ImRect.Right-ImRect.Left);
  ScrollBar1.Position:=ScrollBar1.Position+Round(ScrollBar1.PageSize*dx);
  dy:=(y-(ImRect.Bottom-ImRect.Top) div 2)/(ImRect.Bottom-ImRect.Top);
  ScrollBar2.Position:=ScrollBar2.Position+Round(ScrollBar2.PageSize*dy);
 end;
 FormResize(Sender);
end;

function TViewer.HeightW: Integer;
begin
 Result:=ClientHeight-ToolsBar.Height-3;
end;

function TViewer.GetImageRectA: TRect;
var
  inc_ : Integer;
  zx, zy, zh, zw : Integer;
begin
  if ScrollBar1.Visible then
  begin
   zx:=0;
  end else
  begin
   if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
   zx:=Max(0,Round(ClientWidth/deltwo-inc_-FbImage.Width*Zoom/deltwo));
  end;
  if ScrollBar2.Visible then
  begin
   zy:=0;
  end else
  begin
   if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
   zy:=Max(0,Round(HeightW/deltwo-inc_-FbImage.Height*Zoom/deltwo));
  end;
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  zw:=Round(Min(ClientWidth-inc_,FbImage.Width*Zoom));
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  zh:=Round(Min(HeightW-inc_,FbImage.Height*Zoom));
  zh:=zh;
{  if TransparentImage then
  Result:=Rect(zx+1,zy+1,zw+zx-1,zh+zy-1)
  else }
  Result:=Rect(zx,zy,zw+zx,zh+zy);
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
          if J in [0, 1, 12, 14, 15, 22] then
          begin
            B.Canvas.Rectangle(0, 0, 16, 16);
            DrawIconEx(B.Canvas.Handle, 0, 0, Icons[I, J], 16, 16, 0, 0, DI_NORMAL);
            GrayScale(B);
            Imlists[2].Add(B, nil);
          end
          else
            ImageList_ReplaceIcon(Imlists[2].Handle, -1, Icons[I, J]);
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
  FileInfo : TDBPopupMenuInfoRecord;
  Info : TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    FileInfo := TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(CurrentInfo, CurrentFileNumber);
    Info.Add(FileInfo);

    RotateImages(Self, Info, DB_IMAGE_ROTATE_270, True);

    LockEventRotateFileList.Add(AnsiLowerCase(FileInfo.FileName));
    Rotate270A(FbImage);
    if ZoomerOn then
      RealSizeClick(Sender);

    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
end;

procedure TViewer.RotateCW1Click(Sender: TObject);
var
  FileInfo: TDBPopupMenuInfoRecord;
  Info: TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    FileInfo := TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(CurrentInfo, CurrentFileNumber);
    Info.Add(FileInfo);

    RotateImages(Self, Info, DB_IMAGE_ROTATE_90, True);

    LockEventRotateFileList.Add(AnsiLowerCase(FileInfo.FileName));

    Rotate90A(FbImage);
    if ZoomerOn then
      RealSizeClick(Sender);

    ReAllignScrolls(True, Point(0, 0));
    RecreateDrawImage(Self);
  finally
    F(Info);
  end;
end;

procedure TViewer.Rotateon1801Click(Sender: TObject);
var
  FileInfo: TDBPopupMenuInfoRecord;
  Info: TDBPopupMenuInfo;
begin
  Info := TDBPopupMenuInfo.Create;
  try
    FileInfo := TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(CurrentInfo, CurrentFileNumber);
    Info.Add(FileInfo);
    RotateImages(Self, Info, DB_IMAGE_ROTATE_180, True);
  finally
    F(Info);
  end;
end;

procedure TViewer.Stretch1Click(Sender: TObject);
begin
  SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber], WPSTYLE_STRETCH);
end;

procedure TViewer.Center1Click(Sender: TObject);
begin
  SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber], WPSTYLE_CENTER);
end;

procedure TViewer.Tile1Click(Sender: TObject);
begin
  SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber], WPSTYLE_TILE);
end;

procedure TViewer.Properties1Click(Sender: TObject);
begin
 if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
 PropertyManager.NewIDProperty(CurrentInfo.ItemIds[CurrentFileNumber]).Execute(CurrentInfo.ItemIds[CurrentFileNumber]) else
 PropertyManager.NewFileProperty(CurrentInfo.ItemFileNames[CurrentFileNumber]).ExecuteFileNoEx(CurrentInfo.ItemFileNames[CurrentFileNumber]);
end;

procedure TViewer.Resize1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
  ImageInfo: TDBPopupMenuInfoRecord;
begin
  List := TDBPopupMenuInfo.Create;
  try
    ImageInfo := TDBPopupMenuInfoRecord.CreateFromSlideShowInfo(CurrentInfo, CurrentFileNumber);
    List.Add(ImageInfo);
    ResizeImages(Self, List);
  finally
    List.Free;
  end;
end;

procedure TViewer.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  FNames: TStrings;
  P: TPoint;
begin
  if Length(CurrentInfo.ItemFileNames) = 0 then
    Exit;

  if (GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
  begin
    FNames := TStringList.Create;
    try
      FNames.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
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
      FileList.Free;
    end;
  end;
end;

procedure TViewer.ReloadCurrent;
begin
  LoadImage_(Self,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
end;

procedure TViewer.Pause;
begin
  if DirectShowForm <> nil then
    DirectShowForm.Pause;
  MTimer1.Caption := L('Start timer');
  MTimer1.ImageIndex := DB_IC_PLAY;
  FloatPanel.ToolButton1.Down := False;
  FloatPanel.ToolButton2.Down := True;
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
 if CurrentFileNumber>Length(CurrentInfo.ItemFileNames)-1 then exit;
 FCurrentlyLoadedFile:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 TransparentImage:=Transparent;
 ForwardThreadExists:=false;
 ForwardThreadNeeds:=false;
 FbImage.Free;
 FbImage:=Image;
 StaticImage:=True;
 ImageExists:=True;
 Loading:=False;
 if not ZoomerOn  then Cursor:=crDefault;
 TbFitToWindow.Enabled:=true;
 TbRealSize.Enabled:=true;
 TbSlideShow.Enabled:=true;
 TbZoomOut.Enabled:=true;
 TbZoomIn.Enabled:=true;

 TbRotateCCW.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
 TbRotateCW.Enabled:=TbRotateCCW.Enabled;

 ZoomIn1.Enabled:=True;
 ZoomOut1.Enabled:=True;
 RealSize1.Enabled:=True;
 BestSize1.Enabled:=True;
 TbRealSize.Down:=false;
 TbFitToWindow.Down:=false;
 TbZoomOut.Down:=false;
 TbZoomIn.Down:=false;
 EndWaitToImage(nil);

 if FRotatingImageInfo.Enabled then
   if AnsiLowerCase(FRotatingImageInfo.FileName)=AnsiLowerCase(FCurrentlyLoadedFile) then
     ApplyRotate(FbImage, FRotatingImageInfo.Rotating);

 ReAllignScrolls(False,Point(0,0));
 ValidImages:=1;
 RecreateDrawImage(nil);
 PrepareNextImage;
 FRotatingImageInfo.Enabled:=false;
end;

procedure TViewer.SetLoading(const Value: Boolean);
begin
  FLoading := Value;
  TbSlideShow.Enabled:=not Value;
  if Length(CurrentInfo.ItemFileNames)=0 then TbSlideShow.Enabled:=false;
end;

procedure TViewer.SetAnimatedImage(Image: TGraphic);
var
 i : integer;
 im : TGifImage;
begin
  F(AnimatedImage);
  AnimatedImage:=Image;
 FCurrentlyLoadedFile:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 ForwardThreadExists:=false;
 StaticImage:=False;
 ImageExists:=True;
 Loading:=False;
 if not ZoomerOn  then Cursor:=crDefault;
 TbFitToWindow.Enabled:=true;
 TbRealSize.Enabled:=true;
 TbSlideShow.Enabled:=true;
 TbZoomOut.Enabled:=true;
 TbZoomIn.Enabled:=true;

 TbRotateCCW.Enabled:=True;
 TbRotateCW.Enabled:=TbRotateCCW.Enabled;

 ZoomIn1.Enabled:=True;
 ZoomOut1.Enabled:=True;
 RealSize1.Enabled:=True;
 BestSize1.Enabled:=True;
 TbRealSize.Down:=false;
 TbFitToWindow.Down:=false;
 TbZoomOut.Down:=false;
 TbZoomIn.Down:=false;
 EndWaitToImage(nil);
 ReAllignScrolls(False,Point(0,0));
 SlideNO:=-1;
 ZoomerOn:=false;
 im:=(AnimatedImage as TGIFImage);
 ValidImages:=0;
 TransparentImage:=false;
 for i:=0 to im.Images.count-1 do
 begin
  if not im.Images[i].Empty then
  ValidImages:=ValidImages+1;
  if im.Images[i].Transparent then
  TransparentImage:=true;
 end;
 AnimatedBuffer.Width:=im.Width;
 AnimatedBuffer.Height:=im.Height;
 if FullScreenNow then
 begin
  AnimatedBuffer.Canvas.Brush.Color:=0;
  AnimatedBuffer.Canvas.Pen.Color:=0;
 end else
 begin
  AnimatedBuffer.Canvas.Brush.Color:=ClBtnFace;
  AnimatedBuffer.Canvas.Pen.Color:=ClBtnFace;
 end;
 AnimatedBuffer.Canvas.Rectangle(0,0,AnimatedBuffer.Width,AnimatedBuffer.Height);
 ImageFrameTimer.Interval:=1;
 ImageFrameTimer.Enabled:=true;
end;

procedure TViewer.ImageFrameTimerTimer(Sender: TObject);
begin
  NextSlide;
end;

function TViewer.GetImage(FileName: string; Bitmap: TBitmap): Boolean;
begin
  Result := False;
  if AnsiLowerCase(FileName) = AnsiLowerCase(CurrentInfo.ItemFileNames[CurrentFileNumber]) then
  begin
    Result := True;
    Bitmap.Assign(DrawImage);
  end;
end;

procedure TViewer.NextSlide;
var
  c, PreviousNumber : integer;
  r, bounds_  : TRect;
  im : TGifImage;
  DisposalMethod : TDisposalMethod;
  del : integer;
  TimerEnabled:Boolean;
  gsi : TGIFSubImage;
begin
 del:=1;
 if not (ImageExists and not StaticImage) then exit;
 if SlideNO=-1 then
 begin
  SlideNO:=GetFirstImageNO;
 end else
 begin
  SlideNO:=GetNextImageNO;
 end;
 r:=(AnimatedImage as TGIFImage).Images[SlideNO].BoundsRect;
 if FullScreenNow then
 begin
  AnimatedBuffer.Canvas.Brush.Color:=0;
  AnimatedBuffer.Canvas.Pen.Color:=0;
 end else
 begin
  AnimatedBuffer.Canvas.Brush.Color:=ClBtnFace;
  AnimatedBuffer.Canvas.Pen.Color:=ClBtnFace;
 end;
 im:=(AnimatedImage as TGIFImage);
 TimerEnabled:=false;
 PreviousNumber:=GetPreviousImageNO;
 DisposalMethod:=dmNone;
 if im.Animate then
 if im.Images.Count>1 then
 begin
 gsi:=im.Images[SlideNO];
 if gsi.Empty then exit;
 if im.Images[PreviousNumber].Empty then DisposalMethod:=dmNone else
 begin
  if im.Images[PreviousNumber].GraphicControlExtension<>nil then
  DisposalMethod:=im.Images[PreviousNumber].GraphicControlExtension.Disposal else
  DisposalMethod:=dmNone;
 end;
 del:=100;
 if im.Images[SlideNO].GraphicControlExtension<>nil then
 del:=im.Images[SlideNO].GraphicControlExtension.Delay*10;
 if del=10 then del:=100;
 if del=0 then del:=100;
 TimerEnabled:=True;
 end else
 DisposalMethod:=dmNone;
 if SlideNO=0 then DisposalMethod:=dmBackground;
 if (DisposalMethod=dmBackground) then
 begin
  bounds_:=im.Images[PreviousNumber].BoundsRect;
  if FullScreenNow then
  begin
   AnimatedBuffer.Canvas.Pen.Color:=0;
   AnimatedBuffer.Canvas.Brush.Color:=0;
  end else
  begin
   AnimatedBuffer.Canvas.Pen.Color:=ClBtnFace;
   AnimatedBuffer.Canvas.Brush.Color:=ClBtnFace;
  end;

  AnimatedBuffer.Canvas.Rectangle(bounds_);
 end;
 if DisposalMethod=dmPrevious then
 begin
  c:=SlideNO;
  dec(c);
  if c<0 then
  c:=im.Images.Count-1;
  im.Images[c].StretchDraw(AnimatedBuffer.Canvas,r,im.Images[SlideNO].Transparent,false);
 end;
 im.Images[SlideNO].StretchDraw(AnimatedBuffer.Canvas,r,im.Images[SlideNO].Transparent,false);
 if CurrentFileNumber<=Length(CurrentInfo.ItemRotates)-1 then
 case CurrentInfo.ItemRotates[CurrentFileNumber] of
  DB_IMAGE_ROTATE_0 : FbImage.Assign(AnimatedBuffer);
  DB_IMAGE_ROTATE_90 : Rotate90(AnimatedBuffer,FbImage);
  DB_IMAGE_ROTATE_180 : Rotate180(AnimatedBuffer,FbImage);
  DB_IMAGE_ROTATE_270: Rotate270(AnimatedBuffer,FbImage)
 end;
 RecreateDrawImage(nil);
 ImageFrameTimer.Enabled:=false;
 ImageFrameTimer.Interval:=del;
 if not TimerEnabled then ImageFrameTimer.Enabled:=false else
 ImageFrameTimer.Enabled:=true;
 if ValidImages=1 then ImageFrameTimer.Enabled:=false;
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
 Loading:=false;
 FCurrentlyLoadedFile:=FileName;
 Cursor:=crDefault;
 TbFitToWindow.Enabled:=false;
 TbRealSize.Enabled:=false;
 TbSlideShow.Enabled:=false;
 TbZoomOut.Enabled:=false;
 TbZoomIn.Enabled:=false;
 TbRotateCCW.Enabled:=false;
 TbRotateCW.Enabled:=false;
 ZoomIn1.Enabled:=false;
 ZoomOut1.Enabled:=false;
 RealSize1.Enabled:=false;
 BestSize1.Enabled:=false;
 TbRealSize.Down:=false;
 TbFitToWindow.Down:=false;
 TbZoomOut.Down:=false;
 TbZoomIn.Down:=false;
 EndWaitToImage(nil);
 ReAllignScrolls(False,Point(0,0));
 ImageExists:=false;
 ValidImages:=0;
 ForwardThreadExists:=false;
 ForwardThreadNeeds:=false;
 RecreateDrawImage(nil);
 PrepareNextImage;
 FRotatingImageInfo.Enabled:=false;
end;

procedure TViewer.SetCurrentlyLoadedFile(const Value: String);
begin
  FCurrentlyLoadedFile := Value;
end;

procedure TViewer.PrepareNextImage;
var
  n : integer;
begin
 ForwardThreadSID:=GetGUID;
 if Length(CurrentInfo.ItemFileNames)>1 then
 begin
  n:=CurrentFileNumber;
  inc(n);
  if n>=Length(CurrentInfo.ItemFileNames) then
  n:=0;
  ForwardThreadExists:=true;
  ForwardThreadFileName:=CurrentInfo.ItemFileNames[n];
  TViewerThread.Create(CurrentInfo.ItemFileNames[n],CurrentInfo.ItemRotates[n],false,1,ForwardThreadSID,true,not CurrentInfo.LoadedImageInfo[n], 0);
 end;
end;

procedure TViewer.SetFullImageState(State: Boolean; BeginZoom : Extended; Pages, Page : integer);
begin
 fPageCount:=Pages;
 fCurrentPage:=Page;
 MakePagesLinks;
 if State then
 begin
  ZoomerOn:=True;
  Zoom:=BeginZoom;
 end else
 begin
  ZoomerOn:=False;
  Zoom:=1;
 end;
end;

procedure TViewer.UpdateInfo(SID: TGUID; Info: TOneRecordInfo);
begin
 SetRecordsInfoOne(CurrentInfo,CurrentFileNumber,Info.ItemFileName,Info.ItemId,Info.ItemRotate,Info.ItemRating,Info.ItemAccess,Info.ItemComment,Info.ItemGroups,Info.ItemDate,Info.ItemIsDate,Info.ItemIsTime,Info.ItemTime,Info.ItemCrypted,Info.ItemInclude,Info.ItemLinks);
 DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];

 TbRotateCCW.Enabled:=True;
 TbRotateCW.Enabled:=TbRotateCCW.Enabled;
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
    OpenFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]);
  end;
end;

procedure TViewer.Print1Click(Sender: TObject);
var
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    if FileExists(CurrentInfo.ItemFileNames[CurrentFileNumber]) then
      Files.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
    if Files.Count > 0 then
      GetPrintForm(Files);
  finally
    Files.Free;
  end;
end;

procedure TViewer.TbDeleteClick(Sender: TObject);
var
  fQuery : TDataSet;
  Files : TStrings;
  EventInfo : TEventValues;
  SQL_ : string;
  i, DeleteID : Integer;
begin
 If ID_OK=MessageBoxDB(Handle,L('Do you really want to delete file to recycle bin?'), L('Delete confirn'),TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  DeleteID:=0;
  if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
  begin
   fQuery:=GetQuery;
   try
     DeleteID:=CurrentInfo.ItemIds[CurrentFileNumber];
     SQL_:=Format('DELETE FROM $DB$ WHERE ID = %d', [CurrentInfo.ItemIds[CurrentFileNumber]]);
     SetSQL(fQuery,SQL_);
     ExecSQL(fQuery);
   finally
     FreeDS(fQuery);
   end;
  end;

  Files := TStringList.Create;
  try
    Files.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
    SilentDeleteFiles(Handle, Files, true );
  finally
    F(Files);
  end;

  for i:=CurrentFileNumber to Length(CurrentInfo.ItemIds)-2 do
  begin
   With CurrentInfo do
   begin
    ItemFileNames[i]:=ItemFileNames[i+1];
    ItemIds[i]:=ItemIds[i+1];
    ItemRotates[i]:=ItemRotates[i+1];
    ItemRatings[i]:=ItemRatings[i+1];
    ItemAccesses[i]:=ItemAccesses[i+1];
    ItemComments[i]:=ItemComments[i+1];
    ItemCollections[i]:=ItemCollections[i+1];
    ItemGroups[i]:=ItemGroups[i+1];
    ItemOwners[i]:=ItemOwners[i+1];
    ItemKeyWords[i]:=ItemKeyWords[i+1];
    ItemDates[i]:=ItemDates[i+1];
    ItemIsDates[i]:=ItemIsDates[i+1];
    ItemCrypted[i]:=ItemCrypted[i+1];
    LoadedImageInfo[i]:= LoadedImageInfo[i+1];
   end;
  end;
  With CurrentInfo do
  begin
   SetLength(ItemFileNames,Length(ItemFileNames)-1);
   SetLength(ItemIds,Length(ItemIds)-1);
   SetLength(ItemRotates,Length(ItemRotates)-1);
   SetLength(ItemRatings,Length(ItemRatings)-1);
   SetLength(ItemAccesses,Length(ItemAccesses)-1);
   SetLength(ItemComments,Length(ItemComments)-1);
   SetLength(ItemCollections,Length(ItemCollections)-1);
   SetLength(ItemGroups,Length(ItemGroups)-1);
   SetLength(ItemOwners,Length(ItemOwners)-1);
   SetLength(ItemKeyWords,Length(ItemKeyWords)-1);
   SetLength(ItemDates,Length(ItemDates)-1);
   SetLength(ItemIsDates,Length(ItemIsDates)-1);
   SetLength(ItemCrypted,Length(ItemCrypted)-1);
   SetLength(LoadedImageInfo,Length(LoadedImageInfo)-1);
   if Length(CurrentInfo.ItemFileNames)=0 then
   begin
    Close;
    DBKernel.DoIDEvent(Self,DeleteID,[EventID_Param_Delete],EventInfo);
    Exit;
   end;
   if CurrentFileNumber>Length(ItemFileNames)-1 then CurrentFileNumber:=Length(ItemFileNames)-1;
  end;
  if CurrentInfo.ItemIds[CurrentFileNumber] <> 0 then
    DBKernel.DoIDEvent(Self,DeleteID,[EventID_Param_Delete],EventInfo);
  if Length(CurrentInfo.ItemFileNames)<2 then
  begin
   TbBack.Enabled := False;
   TbForward.Enabled := False;
   SetProgressPosition(0, 0);
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Enabled:=false;
    FloatPanel.ToolButton2.Enabled:=false;
    FloatPanel.ToolButton4.Enabled:=false;
    FloatPanel.ToolButton5.Enabled:=false;
   end;
  end else
  begin
   TbBack.Enabled := True;
   TbForward.Enabled := True;
   SetProgressPosition(CurrentFileNumber + 1, Length(CurrentInfo.ItemFileNames));
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Enabled:=True;
    FloatPanel.ToolButton2.Enabled:=True;
    FloatPanel.ToolButton4.Enabled:=True;
    FloatPanel.ToolButton5.Enabled:=True;
   end;
  end;
  TbFitToWindow.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  TbRealSize.Enabled:=false;
  TbSlideShow.Enabled:=false;
  TbZoomOut.Enabled:=false;
  TbZoomIn.Enabled:=false;
  TbRotateCCW.Enabled:=false;
  TbRotateCW.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,1,true);
  TbrActions.Refresh;
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

  (FindComponent('N' + IntToStr(CurrentInfo.ItemRatings[CurrentFileNumber]) + '1') as TMenuItem).default := True;
  RatingPopupMenu.Popup(P.X, P.Y);
end;

procedure TViewer.N51Click(Sender: TObject);
var
  Str: string;
  NewRating: Integer;
  EventInfo: TEventValues;
begin
  Str := StringReplace(TMenuItem(Sender).Caption, '&', '', [RfReplaceAll]);
  NewRating := StrToInt(Str);
  SetRating(CurrentInfo.ItemIds[CurrentFileNumber], NewRating);
  EventInfo.Rating := NewRating;
  DBKernel.DoIDEvent(Sender, CurrentInfo.ItemIds[CurrentFileNumber], [EventID_Param_Rating], EventInfo);
end;

procedure TViewer.ApplicationEvents1Hint(Sender: TObject);
begin
  Application.HintPause := 1000;
  Application.HintHidePause := 5000;
end;

procedure TViewer.UpdateInfoAboutFileName(FileName: String;
  info: TOneRecordInfo);
var
  I: Integer;
begin
  for I := 0 to Length(CurrentInfo.ItemFileNames) - 1 do
    if not CurrentInfo.LoadedImageInfo[I] then
      if CurrentInfo.ItemFileNames[I] = FileName then
      begin
        SetRecordToRecords(CurrentInfo, I, Info);
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
  if CurrentInfo.ItemIds[CurrentFileNumber] <> 0 then
  begin
    Setlength(InfoIDs, 1);
    InfoIDs[0] := CurrentInfo.ItemIds[CurrentFileNumber];
  end else
  begin
    Setlength(InfoNames, 1);
    InfoNames[0] := CurrentInfo.ItemFileNames[CurrentFileNumber];
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
  for I := 0 to Length(CurrentInfo.ItemFileNames) - 1 do
    if AnsiLowerCase(CurrentInfo.ItemFileNames[I]) = FileName then
    begin
      SetRecordsInfoOne(CurrentInfo, I, DS.FieldByName('FFileName').AsString,
        DS.FieldByName('ID').AsInteger, DS.FieldByName('Rotated').AsInteger,
        DS.FieldByName('Rating').AsInteger,
        DS.FieldByName('Access').AsInteger,
        DS.FieldByName('Comment').AsString,
        DS.FieldByName('Groups').AsString,
        DS.FieldByName('DateToAdd').AsDateTime,
        DS.FieldByName('IsDate').AsBoolean,
        DS.FieldByName('IsTime').AsBoolean,
        DS.FieldByName('aTime').AsDateTime,
        ValidCryptBlobStreamJPG(DS.FieldByName('thum')),
        DS.FieldByName('Include').AsBoolean,
        DS.FieldByName('Links').AsString);
      CurrentInfo.LoadedImageInfo[I] := True;
      if not Loading then
      begin
        if CurrentInfo.ItemRotates[I] <> 0 then
          if I = CurrentFileNumber then
          begin
            ApplyRotate(FbImage, CurrentInfo.ItemRotates[I]);
            RecreateDrawImage(Self);
          end;
      end else
      begin
        FRotatingImageInfo.Enabled := True;
        FRotatingImageInfo.FileName := FileName;
        FRotatingImageInfo.Rotating := CurrentInfo.ItemRotates[I];
      end;
      Break;
    end;

  DisplayRating := CurrentInfo.ItemIds[CurrentFileNumber];

  TbRotateCCW.Enabled := True;
  TbRotateCW.Enabled := TbRotateCCW.Enabled;
end;

procedure TViewer.DoSetNoDBRecord(FileName: string);
var
  I: integer;
begin
  for I := 0 to Length(CurrentInfo.ItemFileNames) - 1 do
    if not CurrentInfo.LoadedImageInfo[I] then
      if CurrentInfo.ItemFileNames[I] = FileName then
      begin
        CurrentInfo.LoadedImageInfo[I] := True;
        Break;
      end;
  DisplayRating := CurrentInfo.ItemRatings[CurrentFileNumber];

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
   TbRating.Enabled := (Value > 0);
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

Viewer:=nil;

end.
