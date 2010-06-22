unit SlideShow;

interface

uses
  FormManegerUnit, UnitUpdateDBThread, DBCMenu, dolphin_db, Searching, Shellapi,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, Buttons, SaveWindowPos, DB, ComObj, ShlObj,
  AppEvnts, ImgList, UnitDBKernel, FadeImage, jpeg, Win32crc, CommCtrl,
  StdCtrls, math, ToolWin, ComCtrls, Tlayered_Bitmap, GraphicCrypt,
  ShellContextMenu, DropSource, DropTarget, GIFImage, GraphicEx,
  Effects, GraphicsCool, UnitUpdateDBObject, DragDropFile, DragDrop,
  uVistaFuncs, UnitDBDeclare, UnitFileExistsThread, UnitDBCommonGraphics,
  UnitCDMappingSupport, uThreadForm, uLogger, uConstants, uTime, uFastLoad;

type
  TRotatingImageInfo = record
   FileName : string;
   Rotating : integer;
   Enabled : boolean;
  end;

type
  TViewer = class(TThreadForm)
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
    Image2: TImage;
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
    ToolBar2: TToolBar;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
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
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ImageEditor1: TMenuItem;
    ToolButton15: TToolButton;
    Print1: TMenuItem;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
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
    ToolButton23: TToolButton;
    ToolButtonPage: TToolButton;
    PopupMenuPageSelecter: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    function LoadImage_(Sender: TObject; FileName : String; Rotate : integer; FullImage : Boolean; BeginZoom : Extended; RealZoom : Boolean) : boolean;
    procedure RecreateDrawImage_(Sender: TObject);
    procedure FormResize(Sender: TObject);
    Procedure Next_(Sender: TObject);
    Procedure Previous_(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FullScreen1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
//    procedure SlideTimerTimer(Sender: TObject);
    procedure newpicture(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure MTimer1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure LoadListImages(List : TstringList);
    Procedure ShowFile(FileName : String);
    Procedure ShowFolder(Files : Tstrings; CurrentN : integer);
    Procedure ShowFolderA(File_ : string; ShowPrivate : Boolean);
    Procedure UpdateRecord(FileNo: integer);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure UpdateTheme(Sender: TObject);
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
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
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
    procedure ToolButton6Click(Sender: TObject);
    procedure SlideTimerTimer(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure ToolButton20Click(Sender: TObject);
    procedure ToolButton22Click(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure UpdateInfoAboutFileName(FileName : String; info : TOneRecordInfo);
    procedure SendTo1Click(Sender: TObject);
    procedure NewPanel1Click(Sender: TObject);
    procedure TimerDBWorkTimer(Sender: TObject);
  private
    WindowsMenuTickCount : Cardinal;
    FImageExists: Boolean;
    FStaticImage: Boolean;
    FLoading: Boolean;
    AnimatedImage : TPicture;
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
    LastZValue : extended;
    FCreating : Boolean;
    FRotatingImageInfo : TRotatingImageInfo;
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
    procedure SendToItemPopUpMenu_(Sender: TObject);
    procedure OnPageSelecterClick(Sender: TObject);
    { Private declarations }
  protected
    procedure CreateParams(VAR Params: TCreateParams); override;
  public        
    WaitingList : boolean;
    fCurrentPage : integer;
    fPageCount : integer;
    procedure ExecuteDirectoryWithFileOnThread(FileName : String);
    function Execute(Sender: TObject; Info: TRecordsInfo) : boolean;
    function ExecuteW(Sender: TObject; Info : TRecordsInfo; LoadBaseFile : String) : boolean;
    procedure LoadLanguage;
    procedure ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
    function HeightW : Integer;
    function GetImageRectA : TRect;
    procedure RecreateImLists;
    function GetSID : TGUID;
    procedure SetStaticImage(Image : TBitmap; Transparent : Boolean);
    procedure SetAnimatedImage(Image : TPicture);
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
    function GetPageCaption : String;
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
    { Public declarations }
  end;

var
  Viewer: TViewer;
  FbImage : Tbitmap;
  CurrentFileNumber : integer;
  DrawImage : TBitmap;
  FullScreenNow, SlideShowNow : boolean;
  DBCanDrag : Boolean;
  DBDragPoint : TPoint;
  old_width,old_height, old_top,old_left : integer;
  old_rect:Trect;
  CurrentInfo : TRecordsInfo;
  fcsrbmp, fnewcsrbmp, fnowcsrbmp : TBitmap;
  OldPoint : TPoint;
  WaitGrayScale : Integer;
  WaitImage : TBitmap;
  IncGrayScale : integer = 20;
  UseOnlySelf : Boolean = false;
  Zoom : real = 1;
  ZoomerOn : Boolean = false;
  RealZoomInc : Extended = 1;
  CursorZoomIn, CursorZoomOut : HIcon;
  RealImageWidth : Integer = 0;
  RealImageHeight : Integer = 0;
  UseOnlyDefaultDraw : Boolean = false;
  DelTwo : integer = 2;
  FSID : TGUID;

  Const
    CursorZoomInNo = 130;
    CursorZoomOutNo = 131;

implementation

uses  Language, UnitUpdateDB, PropertyForm, SlideShowFullScreen,
  ExplorerUnit, FloatPanelFullScreen, UnitRotateImages, UnitSizeResizerForm,
  DX_Alpha, UnitViewerThread, ImEditor, PrintMainForm, UnitFormCont,
  UnitLoadFilesToPanel, CommonDBSupport, UnitSlideShowScanDirectoryThread,
  UnitSlideShowUpdateInfoThread;

{$R *.dfm}

procedure TViewer.FormCreate(Sender: TObject);
begin        
  TW.I.Start('TViewer.FormCreate');
 FCreating := True;
 fCurrentPage := 0;
 fPageCount := 1;
 FRotatingImageInfo.Enabled:=false;
 WaitingList:=false;
 LastZValue:=1;
 LockEventRotateFileList:=TStringList.Create;
  RatingPopupMenu.Images:=DBKernel.ImageList;
  N01.ImageIndex:=DB_IC_DELETE_INFO;
  N11.ImageIndex:=DB_IC_RATING_1;
  N21.ImageIndex:=DB_IC_RATING_2;
  N31.ImageIndex:=DB_IC_RATING_3;
  N41.ImageIndex:=DB_IC_RATING_4;
  N51.ImageIndex:=DB_IC_RATING_5;
  FPlay:=false;
  FCurrentlyLoadedFile:='';
  TransparentImage:=false;
  ForwardThreadFileName:='';
  ForwardThreadNeeds:=false;
  ForwardThreadExists:=false;
  SlideTimer.Enabled:=false;
  AnimatedImage:=nil;
  FLoading:=true;
  FImageExists:=false;
  Caption:=TEXT_MES_SLIDE_SHOW;
  DBCanDrag:=false;
  DropFileTarget1.Register(self);
  SlideTimer.Interval:=Math.Min(Math.Max(DBKernel.ReadInteger('Options','FullScreen_SlideDelay',40),1),100)*100;
  IncGrayScale:=Math.Min(Math.Max(DBKernel.ReadInteger('Options','SlideShow_GrayScale',20),1),100);
  FullScreenNow:=false;
  SlideShowNow:=false;
  ToolBar2.DoubleBuffered:=True;
  drawimage:=Tbitmap.create;
  FbImage:=TBitmap.create;
  FbImage.PixelFormat:=pf24bit;
  drawimage.PixelFormat:=pf24bit;
  //drawimage.width:=Clientwidth;
  //drawimage.Height:=HeightW;
  TW.I.Start('fcsrbmp');
  fcsrbmp := TBitmap.create;
  fcsrbmp.PixelFormat:=pf24bit;
  fcsrbmp.width:=screen.Width;
  fcsrbmp.Height:=screen.Height;
  fcsrbmp.Canvas.Brush.Color:=0;
  fcsrbmp.Canvas.pen.Color:=0;
  fcsrbmp.Canvas.Rectangle(0,0,fcsrbmp.width,fcsrbmp.Height);
  TW.I.Start('fnewcsrbmp');
  WaitImage := TBitmap.create;
  WaitImage.PixelFormat:=pf24bit;
  
  fnewcsrbmp := TBitmap.create;
  fnewcsrbmp.PixelFormat:=pf24bit;
  fnewcsrbmp.width:=screen.Width;
  fnewcsrbmp.Height:=screen.Height;
  fnewcsrbmp.Canvas.Brush.Color:=0;
  fnewcsrbmp.Canvas.pen.Color:=0;
  fnewcsrbmp.Canvas.Rectangle(0,0,fnewcsrbmp.width,fnewcsrbmp.Height);
  fnowcsrbmp := TBitmap.create;
  fnowcsrbmp.PixelFormat:=pf24bit;
  fnowcsrbmp.Assign(fnewcsrbmp);
  
  TW.I.Start('AnimatedBuffer');
  AnimatedBuffer := TBitmap.create;
  AnimatedBuffer.PixelFormat:=pf24bit;    
  MTimer1.Caption:=TEXT_MES_SLIDE_STOP_TIMER;
  MTimer1.ImageIndex:=DB_IC_PAUSE;
  color:=$0;
  SaveWindowPos1.Key:=RegRoot+'SlideShow';
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

  TW.I.Start('RecreateThemeToForm');
  DBKernel.RecreateThemeToForm(self);
  DBkernel.RegisterProcUpdateTheme(UpdateTheme,self);
  DBKernel.RegisterChangesID(Self,ChangedDBDataByID);
  TW.I.Start('LoadLanguage');
  LoadLanguage;
  ToolButton2.Hint:=TEXT_MES_VIEW_SC_LEFT_ARROW;
  ToolButton1.Hint:=TEXT_MES_VIEW_SC_RIGHT_ARROW;
  ToolButton4.Hint:=TEXT_MES_VIEW_SC_FIT_TO_SIZE;
  ToolButton5.Hint:=TEXT_MES_VIEW_SC_FULL_SIZE;
  ToolButton6.Hint:=TEXT_MES_VIEW_SC_SLIDE_SHOW;
  ToolButton10.Hint:=TEXT_MES_VIEW_SC_FULLSCREEN;
  ToolButton8.Hint:=TEXT_MES_VIEW_SC_ZOOM_IN;
  ToolButton9.Hint:=TEXT_MES_VIEW_SC_ZOOM_OUT;
  ToolButton12.Hint:=TEXT_MES_VIEW_SC_ROTATE_LEFT;
  ToolButton13.Hint:=TEXT_MES_VIEW_SC_ROTATE_RIGHT;
  ToolButton20.Hint:=TEXT_MES_VIEW_SC_DELETE;
  ToolButton17.Hint:=TEXT_MES_VIEW_SC_PRINT;
  ToolButton22.Hint:=TEXT_MES_VIEW_SC_RATING;
  ToolButton15.Hint:=TEXT_MES_VIEW_SC_EDITOR;
  ToolButton14.Hint:=TEXT_MES_VIEW_SC_INFO; 
  CursorZoomIn := LoadCursor(HInstance,'ZOOMIN');
  CursorZoomOut := LoadCursor(HInstance,'ZOOMOUT');
  Screen.Cursors[CursorZoomInNo]:=CursorZoomIn;
  Screen.Cursors[CursorZoomOutNo]:=CursorZoomOut;
  TW.I.Start('MakePagesLinks');
  MakePagesLinks;
  TW.I.Stop;
  FCreating := False;
end;

function TViewer.LoadImage_(Sender: TObject; FileName: String; Rotate : integer; FullImage : Boolean; BeginZoom : Extended; RealZoom : Boolean) : boolean;
var
  text : string;
  NeedsUpdating : Boolean;
begin
 Result:=false;
 if (not CurrentInfo.LoadedImageInfo[CurrentFileNumber]) and (CurrentInfo.ItemIds[CurrentFileNumber]=0) then
 NeedsUpdating:=true else NeedsUpdating:=false;
 CurrentInfo.LoadedImageInfo[CurrentFileNumber]:=true;
 DoWaitToImage(Sender);
 Rotate:=CurrentInfo.ItemRotates[CurrentFileNumber];
// DBKernel.RegisterChangesIDbyID(self,ChangedDBDataByID,CurrentInfo.ItemIds[CurrentFileNumber]);
 if CheckFileExistsWithSleep(FileName,false) then
 begin
  Caption:=Format(TEXT_MES_SLIDE_CAPTION,[ExtractFileName(FileName),CurrentFileNumber+1,Length(CurrentInfo.LoadedImageInfo)]);
  ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];
  ToolButton22.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0);

  ToolButton12.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
  ToolButton13.Enabled:=ToolButton12.Enabled;

  FSID:=GetGUID;
  if not ForwardThreadExists or (ForwardThreadFileName<>FileName) or (Length(CurrentInfo.ItemIds)=0) or FullImage then
  begin
   if NeedsUpdating then
   begin
    if not DBKernel.ReadBool('SlideShow','UseFastSlideShowImageLiading',true) then
    begin
     UpdateRecord(CurrentFileNumber);
     Rotate:=CurrentInfo.ItemRotates[CurrentFileNumber];
     ToolButton22.Enabled:=CurrentInfo.ItemIds[CurrentFileNumber]<>0;
     ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];

     ToolButton12.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
     ToolButton13.Enabled:=ToolButton12.Enabled;
    end else
    begin            
     ToolButton22.Enabled:=false;
     ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];
     TimerDBWork.Enabled:=true;
     ToolButton12.Enabled:=false;
     ToolButton13.Enabled:=false;
     TSlideShowUpdateInfoThread.Create(Self, StateID, CurrentInfo.ItemFileNames[CurrentFileNumber]);
     Rotate:=0;
    end;
   end;

   Result:=true;
   if not RealZoom then
   TViewerThread.Create(False,FileName,Rotate,FullImage,1,FSID,false,false, fCurrentPage) else
   TViewerThread.Create(False,FileName,Rotate,FullImage,BeginZoom,FSID,false,false, fCurrentPage);
   ForwardThreadExists:=false;
  end else ForwardThreadNeeds:=true;
 end else
 begin
  Caption:=Format(TEXT_MES_SLIDE_CAPTION,[ExtractFileName(FileName),CurrentFileNumber+1,Length(CurrentInfo.LoadedImageInfo)]);
  ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];
  ToolButton22.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0);

  ToolButton12.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
  ToolButton13.Enabled:=ToolButton12.Enabled;

  Text:=Format(TEXT_MES_FILE_NOT_EXISTS_F,[Mince(FileName,30)]);
  FbImage.Canvas.Rectangle(0,0,FbImage.width,FbImage.Height);
  FbImage.Width:=FbImage.Canvas.TextWidth(text);
  FbImage.Height:=FbImage.Canvas.TextHeight(text);
  FbImage.Canvas.TextOut(0,0,text);
  RecreateDrawImage_(Sender);
  FormPaint(Sender);
  Result:=false;
 end;   
 TW.I.Stop;
end;

procedure TViewer.RecreateDrawImage_(Sender: TObject);
var
  fh,fw : integer;
  zx,zy,zw,zh, x1,x2,y1,y2 : integer;
  ImRect, BeginRect : TRect;
  z : real;
  FileName : String;
  TempImage, b : TBitmap;
  aCopyRect : TRect;

const
  text_out = TEXT_MES_CREATING+'...';
  text_error_out = TEXT_MES_UNABLE_SHOW_FILE;


 procedure DrawRect(x1,y1,x2,y2 : Integer);
 begin
  if TransparentImage then
  begin
   drawimage.Canvas.Brush.Color:=Theme_MainColor;
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
    If DBKernel.ReadboolW('Options','SlideShow_UseCoolStretch',True) then
    begin
     if ZoomerOn then z:=RealZoomInc*Zoom else
     begin
      if RealImageWidth*RealImageHeight<>0 then
      begin
       if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_270) then
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
    DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(text_error_out) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2,text_error_out);
    DrawImage.Canvas.TextOut(DrawImage.Width div 2-DrawImage.Canvas.TextWidth(FileName) div 2,DrawImage.Height div 2-DrawImage.Canvas.Textheight(text_error_out) div 2+DrawImage.Canvas.Textheight(FileName)+4,FileName);
   end;
   if FullScreenView<>nil then
   FullScreenView.Canvas.Draw(0,0,DrawImage);
   exit;
  end;
  DrawImage.Width:=Clientwidth;
  DrawImage.Height:=HeightW;
  DrawImage.Canvas.Brush.Color:=Theme_MainColor;
  DrawImage.Canvas.pen.Color:=Theme_MainColor;
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
       if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_270) then
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
  if WaitImageTimer.Enabled then
  begin
   WaitImage.Width:=DrawImage.Width;
   WaitImage.Height:=DrawImage.Height;
   GrayScaleImage(DrawImage,WaitImage,WaitGrayScale);
   Canvas.Draw(0,0,WaitImage);
   exit;
  end;
  if (not WaitImageTimer.Enabled) and (RealImageHeight*RealImageWidth<>0) then
  begin
   if ZoomerOn then z:=RealZoomInc*Zoom else
   begin
    if (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_90) or (CurrentInfo.ItemRotates[CurrentFileNumber]=DB_IMAGE_ROTATED_270) then
    z:=min(fw/RealImageHeight,fh/RealImageWidth) else
    z:=min(fw/RealImageWidth,fh/RealImageHeight);
   end;
   if WaitingList then
   Caption:=Format(TEXT_MES_SLIDE_CAPTION_EX_WAITING,[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)]) else
   Caption:=Format(TEXT_MES_SLIDE_CAPTION_EX,[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,z*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)])+GetPageCaption;
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
 RecreateDrawImage_(Sender);
 ToolsBar.Left:=ClientWidth div 2- ToolsBar.Width div 2;
 BottomImage.Top:=ClientHeight - ToolsBar.Height;
 BottomImage.Width:=ClientWidth;
 BottomImage.Height:=ToolsBar.Height;
 Canvas.Brush.Color:=Theme_MainColor;
 Canvas.Pen.Color:=Theme_MainColor;
 Canvas.Rectangle(0,HeightW,ClientWidth,ClientHeight);
 if StaticImage then  else
 begin
  Canvas.Rectangle(0,0,Width,HeightW);
  FormPaint(Sender);
 end;
 ToolBar2.Refresh;
 TW.I.Stop;
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

procedure TViewer.SpeedButton4Click(Sender: TObject);
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

procedure TViewer.SpeedButton3Click(Sender: TObject);
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
  ShellExecute(0, Nil,Pchar(CurrentInfo.ItemFileNames[CurrentFileNumber]), Nil, Nil, SW_NORMAL);
end;

function delnakl(s:string):string;
var
  j : integer;
begin
  result:=s;
  for j:=1 to length(result) do
  if result[j]='\' then result[j]:='_';
end;

procedure TViewer.FormDestroy(Sender: TObject);
begin
 DropFileTarget1.Unregister;
  try
  DBkernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
  SaveWindowPos1.SavePosition;
  except      
   on e : Exception do EventLog(':TSlideShow::FormDestroy() throw exception: '+e.Message);
  end;
  try
   if FbImage<>nil then FbImage.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/FbImage throw exception: '+e.Message);
  end;
  try
   if DrawImage<>nil then DrawImage.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/DrawImage throw exception: '+e.Message);
  end;
  try
   if WaitImage<>nil then WaitImage.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/WaitImage throw exception: '+e.Message);
  end;
  try
   if fCsrBmp<>nil then fCsrBmp.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/fCsrBmp throw exception: '+e.Message);
  end;
  try
  if fNewCsrBmp<>nil then fNewCsrBmp.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/fNewCsrBmp throw exception: '+e.Message);
  end;
  try
  if fNowCsrBmp<>nil then fNowCsrBmp.free;
  except
   on e : Exception do EventLog(':TSlideShow::FormDestroy()/fNowCsrBmp throw exception: '+e.Message);
  end;
  if AnimatedBuffer<>nil then
  AnimatedBuffer.Free;
  AnimatedBuffer:=nil;
end;

procedure TViewer.SpeedButton5Click(Sender: TObject);
begin
  close;
end;

procedure TViewer.FullScreen1Click(Sender: TObject);
begin
 if Loading then exit;
 FullScreenNow:=true;
 SlideTimer.Enabled:=true;
 Play:=true;
 WaitImageTimer.Enabled:=false;
 RecreateDrawImage_(Sender);
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
  RecreateDrawImage_(Sender);
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
 if WaitImageTimer.Enabled then Canvas.Draw(0,0,WaitImage) else Canvas.draw(0,0,DrawImage);
end;

procedure TViewer.NewPicture(Sender: TObject);
var
  fh,fw,x1,x2,y1,y2 : integer;
begin
 if not SlideShowNow then
 begin
  fcsrbmp.Assign(fnowcsrbmp);
  fnewcsrbmp.Canvas.Rectangle(0,0,fnewcsrbmp.width,fnewcsrbmp.Height);
  if (FbImage.Height=0) or (FbImage.width=0) then exit;
  if (FbImage.width>fnewcsrbmp.width) or (FbImage.Height>fnewcsrbmp.Height) then
  begin
   if FbImage.width/FbImage.Height<fnewcsrbmp.width/fnewcsrbmp.Height then
   begin
    fh:=fnewcsrbmp.Height;
    fw:=round(fnewcsrbmp.Height*(FbImage.width/fbImage.Height));
   end else begin
    fw:=fnewcsrbmp.width;
    fh:=round(fnewcsrbmp.width*(FbImage.Height/fbImage.width));
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
  StretchCool(x1,y1,x2-x1,y2-y1,FbImage,fNewCsrBmp) else
  fNewCsrBmp.Canvas.StretchDraw(rect(x1,y1,x2,y2),FbImage);
 end else
 begin
  if DirectShowForm=nil then exit;
  fnewcsrbmp.Canvas.Rectangle(0,0,fnewcsrbmp.width,fnewcsrbmp.Height);
  if (FbImage.Height=0) or (FbImage.width=0) then exit;
  if (FbImage.width>fnewcsrbmp.width) or (FbImage.Height>fnewcsrbmp.Height) then
  begin
   if FbImage.width/FbImage.Height<fnewcsrbmp.width/fnewcsrbmp.Height then
   begin
    fh:=fnewcsrbmp.Height;
    fw:=round(fnewcsrbmp.Height*(FbImage.width/fbImage.Height));
   end else begin
    fw:=fnewcsrbmp.width;
    fh:=round(fnewcsrbmp.width*(FbImage.Height/fbImage.width));
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
  StretchCool(x1,y1,x2-x1,y2-y1,FbImage,fNewCsrBmp) else
  fNewCsrBmp.Canvas.StretchDraw(rect(x1,y1,x2,y2),FbImage);
  if DirectShowForm.FirstLoad then
  begin
   DirectShowForm.SetFirstImage(fNewCsrBmp);
  end else
  begin
   DirectShowForm.NewImage(fNewCsrBmp);
  end;
 end;
end;

procedure TViewer.PopupMenu1Popup(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
  i : integer;

 procedure InitializeInfo;
 begin
  SetLength(info.ItemFileNames_,1);
  SetLength(info.ItemIDs_,1);
  SetLength(info.ItemRotations_,1);
  SetLength(info.ItemRatings_,1);
  SetLength(info.ItemComments_,1);
  SetLength(info.ItemAccess_,1);
  SetLength(info.ItemSelected_,1);
  SetLength(info.ItemDates_,1);
  SetLength(info.ItemTimes_,1);
  SetLength(info.ItemIsDates_,1);
  SetLength(info.ItemIsTimes_,1);
  SetLength(info.ItemGroups_,1);
  SetLength(info.ItemCrypted_,1);
  SetLength(info.ItemLoaded_,1);
  SetLength(info.ItemKeyWords_,1);
  SetLength(info.ItemInclude_,1);
  SetLength(info.ItemAttr_,1);
  SetLength(info.ItemLoaded_,1);
  SetLength(info.ItemFileSizes_,1);
  SetLength(info.ItemLinks_,1);
  info.ItemFileNames_[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
  info.ItemIDs_[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
  info.ItemRotations_[0]:=CurrentInfo.ItemRotates[CurrentFileNumber];
  info.ItemRatings_[0]:=CurrentInfo.ItemRatings[CurrentFileNumber];
  info.ItemComments_[0]:=CurrentInfo.ItemComments[CurrentFileNumber];
  info.ItemAccess_[0]:=CurrentInfo.ItemAccesses[CurrentFileNumber];
  info.ItemDates_[0]:=CurrentInfo.ItemDates[CurrentFileNumber];
  info.ItemTimes_[0]:=CurrentInfo.ItemTimes[CurrentFileNumber];
  info.ItemIsDates_[0]:=CurrentInfo.ItemIsDates[CurrentFileNumber];
  info.ItemIsTimes_[0]:=CurrentInfo.ItemIsTimes[CurrentFileNumber];
  info.ItemGroups_[0]:=CurrentInfo.ItemGroups[CurrentFileNumber];
  info.ItemCrypted_[0]:=CurrentInfo.ItemCrypted[CurrentFileNumber];
  info.ItemKeyWords_[0]:=CurrentInfo.ItemKeyWords[CurrentFileNumber];
  info.ItemLinks_[0]:=CurrentInfo.ItemLinks[CurrentFileNumber];
  info.ItemSelected_[0]:=True;
  info.ItemLoaded_[0]:=True;
  info.ItemAttr_[0]:=0; 
  info.ItemLoaded_[0]:=CurrentInfo.LoadedImageInfo[CurrentFileNumber];
  info.ItemFileSizes_[0]:=GetFileSizeByName(CurrentInfo.ItemFileNames[CurrentFileNumber]);
  info.ItemInclude_[0]:=CurrentInfo.ItemInclude[CurrentFileNumber];
  info.IsPlusMenu:=false;
  info.IsDateGroup:=True;
  info.Position:=0;
  info.ListItem:=nil;
  info.IsAttrExists:=false;
 end;

begin
 if Length(CurrentInfo.ItemIds)=0 then exit;
 Info.IsPlusMenu:=false;
 Info.IsListItem:=false;
 For i:=N2.MenuIndex+1 to DBItem1.MenuIndex-1 do
 PopupMenu1.Items.Delete(N2.MenuIndex+1);
 if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
 begin
  AddToDB1.Visible:=false;
  DBItem1.Visible:=true;
  DBItem1.Caption:=Format(TEXT_MES_DBITEM_FORMAT,[inttostr(CurrentInfo.ItemIds[CurrentFileNumber])]);
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
end;

procedure TViewer.MTimer1Click(Sender: TObject);
begin
 if not SlideShowNow then
 begin
  if MTimer1.ImageIndex=DB_IC_PAUSE then
  begin
   MTimer1.Caption:=TEXT_MES_START_TIMER;
   MTimer1.ImageIndex:=DB_IC_PLAY;
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Down:=false;
    FloatPanel.ToolButton2.Down:=true;
   end;
   SlideTimer.Enabled:=false;
   Play:=false;
  end else begin
   MTimer1.Caption:=TEXT_MES_STOP_TIMER;
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
   MTimer1.Caption:=TEXT_MES_START_TIMER;
   MTimer1.ImageIndex:=DB_IC_PLAY;
   FloatPanel.ToolButton1.Down:=false;
   FloatPanel.ToolButton2.Down:=true;
  end else begin
   if DirectShowForm<>nil then
   DirectShowForm.Play;
   MTimer1.Caption:=TEXT_MES_STOP_TIMER;
   MTimer1.ImageIndex:=DB_IC_PAUSE;
   FloatPanel.ToolButton1.Down:=true;
   FloatPanel.ToolButton2.Down:=false;
  end;
 end;
end;

procedure TViewer.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p : TPoint;
  DragImage : TBitmap;
  w,h : integer;
  TempImage : TBitmap;
begin
 If DBCanDrag then
 begin
  GetCursorPos(p);
  If (Abs(DBDragPoint.x-p.x)>5) or (Abs(DBDragPoint.y-p.y)>5) then
  begin
   DropFileSource1.Files.Clear;
   if Length(CurrentInfo.ItemFileNames)>0 then
   begin
    DropFileSource1.Files.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
    DragImageList.Clear;
    DragImage := TBitmap.Create;
    DragImage.PixelFormat:=pf24bit;
    DropFileSource1.ShowImage:=not WaitImageTimer.Enabled and FImageExists;
    DragImage.Width:=100;
    DragImage.Height:=100;
    w:=FbImage.Width;
    h:=FbImage.Height;
    ProportionalSize(100,100,w,h);
    DoResize(w,h,FbImage,DragImage);
    DragImageList.Masked:=false;
    DragImageList.Width:=w;
    DragImageList.Height:=h;

    TempImage:=RemoveBlackColor(DragImage);
    DragImageList.Add(TempImage,nil);
    TempImage.Free;

    DragImage.free;
    DropFileSource1.Execute;
    FormPaint(Self);
   end;
   DBCanDrag:=false;
  end;
 end;
 if (Abs(OldPoint.X-x)<5) and (Abs(OldPoint.y-y)<5) then Exit;
 OldPoint:=Point(x,y);
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
    ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];
    ToolButton22.Enabled:=CurrentInfo.ItemIds[CurrentFileNumber]<>0;
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
  Folder, FileName : string;
  fQuery : TDataSet; 
  crc : Cardinal;
begin
 if List.Count=0 then exit;
 CurrentInfo:=RecordsInfoNil;
 fQuery:=GetQuery;
 for i := 0 to List.Count-1 do
 begin
  FileName:=List[i];//NornalizeFileName(List[i]);


   Folder:=GetDirectory(FileName);
   UnFormatDir(Folder);
   CalcStringCRC32(AnsiLowerCase(Folder),crc);
   SetSQL(fQuery,'SELECT * FROM (Select * from '+GetDefDBName+' where FolderCRC='+inttostr(Integer(crc))+') WHERE FFileName like :ffilename');

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
  ToolButton2.Enabled:=false;
  ToolButton1.Enabled:=false;
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton4.Enabled:=false;
   FloatPanel.ToolButton5.Enabled:=false;
   FloatPanel.ToolButton1.Enabled:=false;
   FloatPanel.ToolButton2.Enabled:=false;
  end;
 end else
 begin
  ToolButton2.Enabled:=True;
  ToolButton1.Enabled:=True;
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton4.Enabled:=True;
   FloatPanel.ToolButton5.Enabled:=True;
   FloatPanel.ToolButton1.Enabled:=True;
   FloatPanel.ToolButton2.Enabled:=True;
  end;
 end;
end;

procedure TViewer.ShowFile(FileName: String);
var
  Info : TRecordsInfo;
begin
 Info:=RecordsInfoOne(FileName,0,0,0,0,'','','','','',0,False,False,0,ValidCryptGraphicFile(FileName),false,false,'');
 Execute(nil,Info);
end;

procedure TViewer.ShowFolder(Files: Tstrings; CurrentN : integer);
var
  i : integer;
  Info : TRecordsInfo;
begin
 Info:=RecordsInfoNil;
 If Files=nil then exit;
 for i:=0 to Files.Count-1 do
 begin
  AddRecordsInfoOne(Info,Files[i],0,0,0,0,'','','','','',0,false,false,0,ValidCryptGraphicFile(Files[i]),false,false,'');
 end;
 Info.Position:=CurrentN;
 Execute(nil,Info);
end;

procedure TViewer.UpdateRecord(FileNo: integer);
var
  DS : TDataSet;
begin
  DS:=GetQuery;
  DS.Active:=false;
  SetSQL(DS,'SELECT * FROM '+GetDefDBName+' WHERE FFileName like :ffilename');
  SetStrParam(DS,0,DelNakl(AnsiLowerCase(CurrentInfo.ItemFileNames[FileNo])));
  DS.active:=true;
  if DS.RecordCount=0 then exit;
  SetRecordsInfoOne(CurrentInfo,FileNo,DS.FieldByName('FFileName').AsString,DS.FieldByName('ID').AsInteger,DS.FieldByName('Rotated').AsInteger,DS.FieldByName('Rating').AsInteger,DS.FieldByName('Access').AsInteger,DS.FieldByName('Comment').AsString,DS.FieldByName('Groups').AsString,DS.FieldByName('DateToAdd').AsDateTime,DS.FieldByName('IsDate').AsBoolean,DS.FieldByName('IsTime').AsBoolean,DS.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(DS.FieldByName('thum')),DS.FieldByName('Include').AsBoolean,DS.FieldByName('Links').AsString);
  FreeDS(DS);
end;

procedure TViewer.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if not Active then Exit;
 if SlideShowNow then Exit;
 if FullScreenNow then Exit;
 if Msg.message=256 then
 begin
  WindowsMenuTickCount:=GetTickCount;

  if Msg.wParam=37 then SpeedButton3Click(nil);
  if Msg.wParam=39 then SpeedButton4Click(nil);
    
  if Msg.hwnd=Self.Handle then
  if Msg.wParam=27 then Close;

  if (Msg.wParam=46) then ToolButton20Click(nil);

  if (Msg.wParam=Byte('F')) and CtrlKeyDown then ToolButton5Click(nil);
  if (Msg.wParam=Byte('A')) and CtrlKeyDown then ToolButton4Click(nil);
  if (Msg.wParam=Byte('S')) and CtrlKeyDown then ToolButton6Click(nil);
  if (Msg.wParam=Byte(#13)) and CtrlKeyDown then FullScreen1Click(nil);
  if (Msg.wParam=Byte('I')) and CtrlKeyDown then ToolButton8Click(nil);
  if (Msg.wParam=Byte('O')) and CtrlKeyDown then ToolButton9Click(nil);
  if (Msg.wParam=Byte('L')) and CtrlKeyDown then RotateCCW1Click(nil);
  if (Msg.wParam=Byte('R')) and CtrlKeyDown then RotateCW1Click(nil);
  if (Msg.wParam=Byte('D')) and CtrlKeyDown then ToolButton20Click(nil);
  if (Msg.wParam=Byte('P')) and CtrlKeyDown then Print1Click(nil);
  if ((Msg.wParam=Byte('0')) or (Msg.wParam=Byte(VK_NUMPAD0))) and CtrlKeyDown then N51Click(N01);
  if ((Msg.wParam=Byte('1')) or (Msg.wParam=Byte(VK_NUMPAD1))) and CtrlKeyDown then N51Click(N11);
  if ((Msg.wParam=Byte('2')) or (Msg.wParam=Byte(VK_NUMPAD2))) and CtrlKeyDown then N51Click(N21);
  if ((Msg.wParam=Byte('3')) or (Msg.wParam=Byte(VK_NUMPAD3))) and CtrlKeyDown then N51Click(N31);
  if ((Msg.wParam=Byte('4')) or (Msg.wParam=Byte(VK_NUMPAD4))) and CtrlKeyDown then N51Click(N41);
  if ((Msg.wParam=Byte('5')) or (Msg.wParam=Byte(VK_NUMPAD5))) and CtrlKeyDown then N51Click(N51);
  if (Msg.wParam=Byte('E')) and CtrlKeyDown then ImageEditor1Click(nil);
  if (Msg.wParam=Byte('Z')) and CtrlKeyDown then Properties1Click(nil);
  if (Msg.wParam=Byte(' ')) then Next_(nil);

  Msg.message:=0;
 end;
 if (Msg.message=516) or (Msg.message=517) then
 if (Msg.hwnd=BottomImage.Handle) or (Msg.hwnd=ToolBar2.Handle) or (Msg.hwnd=ScrollBar1.Handle) or (Msg.hwnd=ScrollBar2.Handle) then
 begin
  Msg.message:=0;
 end;

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
if Msg.message<>49411 then
Showmessage(Inttostr(Msg.message));     }
 if FullScreenNow then exit;
 if Msg.message<>522 then exit;
 if not ZoomerOn then
 begin
  if Msg.wParam>0 then Previous_(nil) else Next_(nil);
 end else
 begin
  if Msg.wParam>0 then ToolButton8Click(nil) else ToolButton9Click(nil);
 end;
end;

procedure TViewer.UpdateTheme(Sender: TObject);
begin
 RecreateDrawImage_(self);
 RecreateImLists;
 ToolBar2.Refresh;
end;

procedure TViewer.ShowFolderA(File_:string; ShowPrivate : Boolean);
var
  FileName : string;
  n : integer;
  Info : TRecordsInfo;
begin
 FileName:=File_;
 If FileExists(FileName) then
 FileName:=LongFileName(FileName);
 GetFileListByMask(FileName,SupportedExt,Info,n,ShowPrivate);
 if Length(info.ItemFileNames)>0 then
 Execute(Self,info);
end;
                                                      
procedure TViewer.ExecuteDirectoryWithFileOnThread(FileName : String);
var
  Info: TRecordsInfo;
begin
  NewFormState;
  WaitingList:=true;
  TSlideShowScanDirectoryThread.Create(Self, StateID, FileName);
  Info:=RecordsInfoOne(FileName,0,0,0,0,'','','','','',0,False,False,0,ValidCryptGraphicFile(FileName),false,false,'');
  ExecuteW(Self,Info,'');
  Caption:=Format(TEXT_MES_SLIDE_CAPTION_EX_WAITING,[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)]);
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
  s, Dir : String;
  si : TStartupInfo;
  p  : TProcessInformation;
  TempInfo : TOneRecordInfo;
const text_out = TEXT_MES_GENERATING;

begin
 TW.I.Start('ExecuteW');
 Result:=true;
 SlideTimer.Enabled:=false;
 Play:=false;
 Loading:=true;
 FullScreenNow:=false;
 SlideShowNow:=false;
 ImageExists:=false;
 ImageFrameTimer.Enabled:=false;
 if Length(Info.ItemFileNames)=0 then
 begin
  ToolButton1.Enabled:=false;
  ToolButton2.Enabled:=false;
  ToolButton3.Enabled:=false;
  ToolButton4.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton6.Enabled:=false;
  ToolButton7.Enabled:=false;
  ToolButton8.Enabled:=false;
  ToolButton9.Enabled:=false;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
 end else
 begin
  ToolButton1.Enabled:=true;
  ToolButton2.Enabled:=true;
  ToolButton3.Enabled:=true;
  ToolButton4.Enabled:=true;
  ToolButton5.Enabled:=true;
  ToolButton6.Enabled:=true;
  ToolButton7.Enabled:=true;
  ToolButton8.Enabled:=true;
  ToolButton9.Enabled:=true;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
 end;
 if not UseOnlySelf then
 if not ((FormManager.MainFormsCount=1) and FormManager.IsMainForms(self)) then
 if not SafeMode then
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
   if LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false) then
   begin
//   Timer1.Enabled:=true;
//   MouseTimer.Enabled:=true;
    FbImage.Canvas.Brush.Color:=Theme_MainColor;
    FbImage.Canvas.pen.Color:=Theme_MainColor;
    if fNewCsrBMP<>nil then
    fNewCsrBMP.Canvas.Rectangle(0,0,fNewCsrBMP.width,fNewCsrBMP.Height);
    FbImage.Width:=170;
    FbImage.Height:=170;
    FbImage.Canvas.Rectangle(0,0,FbImage.width,FbImage.Height);
    try
     FbImage.Canvas.Draw(0,0,Image2.Picture.Graphic);
    except
     on e : Exception do EventLog(':TSlideShow::ExecuteW() throw exception: '+e.Message);
    end;
    FbImage.Canvas.TextOut(FbImage.Width div 2-FbImage.Canvas.TextWidth(text_out) div 2,FbImage.Height{ div 2}-4*FbImage.Canvas.Textheight(text_out) div 2,text_out);
    RecreateDrawImage_(Sender);
    FormPaint(Sender);
   end;
   ShowWindow(Handle,SW_SHOWNORMAL);
   Show;
   SetFocus;
  end else
  begin
   Caption:=Format(TEXT_MES_SLIDE_CAPTION_EX,[ExtractFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]),RealImageWidth,RealImageHeight,LastZValue*100,CurrentFileNumber+1,Length(CurrentInfo.ItemFileNames)])+GetPageCaption;
   ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];
   ToolButton22.Enabled:=CurrentInfo.ItemIds[CurrentFileNumber]<>0;

   ToolButton13.Enabled:=ToolButton12.Enabled;
  end;
 end;
 UseOnlySelf:=false;
 if Length(CurrentInfo.ItemFileNames)<2 then
 begin
  ToolButton2.Enabled:=false;
  ToolButton1.Enabled:=false;
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton1.Enabled:=false;
   FloatPanel.ToolButton2.Enabled:=false;
   FloatPanel.ToolButton4.Enabled:=false;
   FloatPanel.ToolButton5.Enabled:=false;
  end;
 end else
 begin
  ToolButton2.Enabled:=True;
  ToolButton1.Enabled:=True;
  if FloatPanel<>nil then
  begin
   FloatPanel.ToolButton1.Enabled:=True;
   FloatPanel.ToolButton2.Enabled:=True;
   FloatPanel.ToolButton4.Enabled:=True;
   FloatPanel.ToolButton5.Enabled:=True;
  end;
 end;
 Show;
end;

procedure TViewer.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);  
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TViewer.WaitImageTimerTimer(Sender: TObject);
begin
 WaitGrayScale:=WaitGrayScale+IncGrayScale;
 If WaitGrayScale>100 then
 begin
  WaitGrayScale:=100;
  Exit;
 end;
 WaitImage.Width:=drawimage.Width;
 WaitImage.Height:=drawimage.Height;
 GrayScaleImage(drawimage,WaitImage,WaitGrayScale);
 Canvas.Draw(0,0,WaitImage);
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
 LockEventRotateFileList.Free;
 if FullScreenView<>nil then
 Exit1Click(nil);
 if DirectShowForm<>nil then
 DirectShowForm.Close;
 DestroyTimer.Enabled:=true;
 CurrentInfo:=RecordsInfoNil;
end;

procedure TViewer.LoadLanguage;
begin
 Next1.Caption:= TEXT_MES_SLIDE_NEXT;
 Previous1.Caption:= TEXT_MES_SLIDE_PREVIOUS;
 MTimer1.Caption:= TEXT_MES_SLIDE_TIMER;
 Shell1.Caption:= TEXT_MES_SHELL;
 Copy1.Caption:= TEXT_MES_COPY;
 FullScreen1.Caption:= TEXT_MES_SLIDE_FULL_SCREEN;
 Tools1.Caption:=TEXT_MES_TOOLS;
 DBItem1.Caption:= TEXT_MES_DBITEM;
 AddToDB1.Caption:= TEXT_MES_ADD_TO_DB;
 GoToSearchWindow1.Caption:= TEXT_MES_GO_TO_SEARCH_WINDOW;
 Explorer1.Caption:= TEXT_MES_EXPLORER;
 Exit1.Caption:= TEXT_MES_EXIT;
 Onlythisfile1.Caption:=TEXT_MES_ADD_ONLY_THIS_FILE;
 AllFolder1.Caption:=TEXT_MES_ADD_ALL_FOLDER;
 ZoomOut1.Caption:=TEXT_MES_ZOOM_IN; 
 ZoomIn1.Caption:=TEXT_MES_ZOOM_OUT;
 RealSize1.Caption:=TEXT_MES_REAL_SIZE;
 BestSize1.Caption:=TEXT_MES_BEST_SIZE;
 Properties1.Caption:=TEXT_MES_PROPERTIES;
 SetasDesktopWallpaper1.Caption:=TEXT_MES_SET_AS_DESKTOP_WALLPAPER;
 Stretch1.Caption:=TEXT_MES_BY_STRETCH;
 Center1.Caption:=TEXT_MES_BY_CENTER;
 Tile1.Caption:=TEXT_MES_BY_TILE;
 Rotate1.Caption:=TEXT_MES_ROTATE_IMAGE;
 RotateCCW1.Caption:=TEXT_MES_ROTATE_270;
 RotateCW1.Caption:=TEXT_MES_ROTATE_90;
 Rotateon1801.Caption:=TEXT_MES_ROTATE_180;
 Resize1.Caption:=TEXT_MES_RESIZE;
 SlideShow1.Caption:=TEXT_MES_DO_SLIDE_SHOW;
 ImageEditor1.Caption:=TEXT_MES_IMAGE_EDITOR;
 Print1.Caption:=TEXT_MES_PRINT;

 ToolButton2.Caption:=TEXT_MES_SLIDE_PREVIOUS;
 ToolButton1.Caption:=TEXT_MES_NEXT;
 ToolButton14.Caption:=TEXT_MES_PROPERTIES;
 ToolButton15.Caption:=TEXT_MES_IMAGE_EDITOR_W;
 SendTo1.Caption:=TEXT_MES_SEND_TO;
 NewPanel1.Caption:=TEXT_MES_NEW_PANEL;
end;

procedure TViewer.Copy1Click(Sender: TObject);
begin
 CopyFilesToClipboard(CurrentInfo.ItemFileNames[CurrentFileNumber]);
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
 RecreateDrawImage_(Sender);
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

procedure TViewer.ToolButton4Click(Sender: TObject);
begin
 Cursor:=CrDefault;
 ToolButton8.Down:=false;
 ToolButton9.Down:=false;
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  Zoom:=1;
  ToolButton4.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton6.Enabled:=false;
  ToolButton8.Enabled:=false;
  ToolButton9.Enabled:=false;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  ScrollBar1.PageSize:=0;
  ScrollBar1.Max:=100;
  ScrollBar1.Position:=50;
  ScrollBar2.PageSize:=0;
  ScrollBar2.Max:=100;
  ScrollBar2.Position:=50;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,1,true);
  ToolBar2.Refresh;
 end else
 begin
  Zoom:=1;
  ZoomerOn:=True;
  FormResize(Sender);
 end;
end;

procedure TViewer.ToolButton5Click(Sender: TObject);
begin
 Cursor:=CrDefault;
 ToolButton8.Down:=false;
 ToolButton9.Down:=false;
 ZoomerOn:=False;
 Zoom:=1;
 FormResize(Sender);
end;

procedure TViewer.ToolButton8Click(Sender: TObject);
var
//  i,n : integer;
  z : real;
begin
 ToolButton5.Down:=false;
 ToolButton4.Down:=false;
 Cursor:=CursorZoomOutNo; 
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
  z:=1 else
  z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
  z:=1/z;
  z:=Max(z*0.8,0.01);
  ToolButton4.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton6.Enabled:=false;
  ToolButton8.Enabled:=false;
  ToolButton9.Enabled:=false;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,z,true);
  ToolBar2.Refresh;
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

procedure TViewer.ToolButton9Click(Sender: TObject);
var
  z : real;
begin
 ToolButton5.Down:=false;
 ToolButton4.Down:=false;
 Cursor:=CursorZoomInNo;
 if not ZoomerOn and (RealZoomInc>1) then
 begin
  ZoomerOn:=True;
  if (RealImageWidth<ClientWidth) and (RealImageHeight<HeightW) then
  z:=1 else
  z:=Max(RealImageWidth/ClientWidth,RealImageHeight/(HeightW));
  z:=1/z;
  z:=Min(z*(1/0.8),16);
  ToolButton4.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton6.Enabled:=false;
  ToolButton8.Enabled:=false;
  ToolButton9.Enabled:=false;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;  
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;  
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],true,z,true);
  ToolBar2.Refresh;
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
   SpeedButton4Click(Sender);
   Exit;
  end else
  begin
   if SlideShowNow or FullScreenNow then
   begin
    SpeedButton4Click(Sender);
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
  icons : array [0..1,0..22] of HIcon;
  c, i, j, k, l : integer;
  b : TBitmap;
  imlists : array [0..2] of TImageList;
Const
  Names : array [0..1,0..22] of String = (('Z_NEXT_NORM','Z_PREVIOUS_NORM','Z_BESTSIZE_NORM','Z_FULLSIZE_NORM','Z_FULLSCREEN_NORM','Z_ZOOMIN_NORM','Z_ZOOMOUT_NORM','Z_FULLSCREEN','Z_LEFT_NORM','Z_RIGHT_NORM','Z_INFO_NORM','IMEDITOR','PRINTER','DELETE_INFO','RATING_STAR','TRATING_1','TRATING_2','TRATING_3','TRATING_4','TRATING_5','Z_DB_NORM','Z_DB_WORK','Z_PAGES'),('Z_NEXT_HOT','Z_PREVIOUS_HOT','Z_BESTSIZE_HOT','Z_FULLSIZE_HOT','Z_FULLSCREEN_HOT','Z_ZOOMIN_HOT','Z_ZOOMOUT_HOT','Z_FULLSCREEN','Z_LEFT_HOT','Z_RIGHT_HOT','Z_INFO_HOT','IMEDITOR','PRINTER','DELETE_INFO','RATING_STAR','TRATING_1','TRATING_2','TRATING_3','TRATING_4','TRATING_5','Z_DB_NORM','Z_DB_WORK','Z_PAGES'));

begin
  TW.I.Start('LoadIcon');
 for i:=0 to 1 do
 for j:=0 to 22 do
 begin
  icons[i,j] := LoadIcon(DBKernel.IconDllInstance,PChar(Names[i,j]));
 end;
  TW.I.Start('FindComponent');

  imlists[0]:=ImageList1; 
  imlists[1]:=ImageList2;
  imlists[2]:=ImageList3;  
 for i:=0 to 2 do
  imlists[i].Clear;
 imlists[0].BkColor:=Theme_MainColor;
 imlists[1].BkColor:=ClBtnFace;
 imlists[2].BkColor:=Theme_MainColor;
 b:=TBitmap.create;
 b.Width:=16;
 b.Height:=16;
 b.Canvas.Brush.Color:=Theme_MainColor;
 b.Canvas.Pen.Color:=Theme_MainColor;
  TW.I.Start('ImageList_ReplaceIcon');
 for i:=0 to 1 do
 for j:=0 to 22 do
 begin
  ImageList_ReplaceIcon(imlists[i].Handle, -1, icons[i,j]);
  if i = 0 then
  begin
   b.Canvas.Rectangle(0, 0, 16, 16);
   DrawIconEx(b.Canvas.Handle, 0, 0, icons[i, j], 16, 16, 0, 0, DI_NORMAL);
   GrayScale(b);
   imlists[2].Add(B, nil);
  end;
 end;    
  TW.I.Start('DestroyIcon');
 for i:=0 to 1 do
 for j:=0 to 22 do
 begin
  DestroyIcon(icons[i,j]);
 end;
 b.free;
  TW.I.Stop;
end;

procedure TViewer.RotateCCW1Click(Sender: TObject);
var
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 SetLength(ImageList,1);
 SetLength(IDList,1);
 SetLength(RotateList,1);
 ImageList[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 IDList[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
 RotateList[0]:=CurrentInfo.ItemRotates[CurrentFileNumber];
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_270,true);

 LockEventRotateFileList.Add(AnsiLowerCase(ImageList[0]));
 Rotate270A(FbImage);
 if ZoomerOn then
 begin
  ToolButton4Click(Sender);
 end;
 RecreateDrawImage_(self);
end;

procedure TViewer.RotateCW1Click(Sender: TObject);
var
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 SetLength(ImageList,1);
 SetLength(IDList,1);
 SetLength(RotateList,1);
 ImageList[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 IDList[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
 RotateList[0]:=CurrentInfo.ItemRotates[CurrentFileNumber];
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_90,true);
                                 
 LockEventRotateFileList.Add(AnsiLowerCase(ImageList[0]));

 Rotate90A(FbImage);
 if ZoomerOn then
 begin
  ToolButton4Click(Sender);
 end;
 ReAllignScrolls(true,Point(0,0));
 RecreateDrawImage_(self);
end;

procedure TViewer.Rotateon1801Click(Sender: TObject);
var
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 SetLength(ImageList,1);
 SetLength(IDList,1);
 SetLength(RotateList,1);
 ImageList[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 IDList[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
 RotateList[0]:=CurrentInfo.ItemRotates[CurrentFileNumber];
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_180,true);
end;

procedure TViewer.Stretch1Click(Sender: TObject);
begin
 SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber],WPSTYLE_STRETCH);
end;

procedure TViewer.Center1Click(Sender: TObject);
begin
 SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber],WPSTYLE_CENTER);
end;

procedure TViewer.Tile1Click(Sender: TObject);
begin
 SetDesktopWallpaper(CurrentInfo.ItemFileNames[CurrentFileNumber],WPSTYLE_TILE);
end;

procedure TViewer.Properties1Click(Sender: TObject);
begin
 if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
 PropertyManager.NewIDProperty(CurrentInfo.ItemIds[CurrentFileNumber]).Execute(CurrentInfo.ItemIds[CurrentFileNumber]) else
 PropertyManager.NewFileProperty(CurrentInfo.ItemFileNames[CurrentFileNumber]).ExecuteFileNoEx(CurrentInfo.ItemFileNames[CurrentFileNumber]);
end;

procedure TViewer.Resize1Click(Sender: TObject);
var
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 SetLength(ImageList,1);
 SetLength(IDList,1);
 ImageList[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 IDList[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
 ResizeImages(ImageList,IDList);
end;

procedure TViewer.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  FNames : TArStrings;
  p : TPoint;
begin
 if Length(CurrentInfo.ItemFileNames)=0 then exit;
 if (GetTickCount-WindowsMenuTickCount>WindowsMenuTime) then
 begin
  SetLength(FNames,1);
  FNames[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
  GetProperties(FNames[0],MousePos,self);
  exit;
 end;
 p:=ClientToScreen(MousePos);
 PopupMenu1.Popup(p.X,p.y);
end;

procedure TViewer.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if not DBCanDrag then
 LoadListImages(DropFileTarget1.Files as TStringList);
end;

procedure TViewer.ReloadCurrent;
begin
  LoadImage_(Self,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,zoom,false);
end;

procedure TViewer.Pause;
begin
 if DirectShowForm<>nil then
 DirectShowForm.Pause;
 MTimer1.Caption:=TEXT_MES_START_TIMER;
 MTimer1.ImageIndex:=DB_IC_PLAY;
 FloatPanel.ToolButton1.Down:=false;
 FloatPanel.ToolButton2.Down:=true;
end;

procedure TViewer.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 FormManager.UnRegisterMainForm(self);
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
 Release;
 if UseFreeAfterRelease then Free;
 Viewer:=nil;
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
 Result:=FSID;
end;

procedure TViewer.SetStaticImage(Image : TBitmap; Transparent : Boolean);
{var
  n : integer;   }
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
 ToolButton4.Enabled:=true;
 ToolButton5.Enabled:=true;
 ToolButton6.Enabled:=true;
 ToolButton8.Enabled:=true;
 ToolButton9.Enabled:=true;
// ToolButton12.Enabled:=true;
// ToolButton13.Enabled:=true;

 ToolButton12.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0) or (CurrentInfo.ItemIds[CurrentFileNumber]=0);
 ToolButton13.Enabled:=ToolButton12.Enabled;

 ZoomIn1.Enabled:=True;
 ZoomOut1.Enabled:=True;
 RealSize1.Enabled:=True;
 BestSize1.Enabled:=True;
 ToolButton5.Down:=false;
 ToolButton4.Down:=false;
 ToolButton8.Down:=false;
 ToolButton9.Down:=false;
 EndWaitToImage(nil);

 if FRotatingImageInfo.Enabled then
 if AnsiLowerCase(FRotatingImageInfo.FileName)=AnsiLowerCase(FCurrentlyLoadedFile) then
 begin
  Case FRotatingImageInfo.Rotating of
   DB_IMAGE_ROTATED_270: Rotate270A(FbImage);
   DB_IMAGE_ROTATED_90: Rotate90A(FbImage);
   DB_IMAGE_ROTATED_180: Rotate180A(FbImage);
  end;
 end;

 ReAllignScrolls(False,Point(0,0));
 ValidImages:=1;
 RecreateDrawImage_(nil);
 PrepareNextImage;
 FRotatingImageInfo.Enabled:=false;
end;

procedure TViewer.SetLoading(const Value: Boolean);
begin
  FLoading := Value;
  ToolButton6.Enabled:=not Value;
  if Length(CurrentInfo.ItemFileNames)=0 then ToolButton6.Enabled:=false;
end;

procedure TViewer.SetAnimatedImage(Image: TPicture);
var
 i : integer;
 im : TGifImage;
begin
 FCurrentlyLoadedFile:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 ForwardThreadExists:=false;
 StaticImage:=False;
 ImageExists:=True;
 Loading:=False;
 if AnimatedImage<>nil then AnimatedImage.Free;
 AnimatedImage:=Image;
 if not ZoomerOn  then Cursor:=crDefault;
 ToolButton4.Enabled:=true;
 ToolButton5.Enabled:=true;
 ToolButton6.Enabled:=true;
 ToolButton8.Enabled:=true;
 ToolButton9.Enabled:=true;

 ToolButton12.Enabled:=True;
 ToolButton13.Enabled:=ToolButton12.Enabled;

 ZoomIn1.Enabled:=True;
 ZoomOut1.Enabled:=True;
 RealSize1.Enabled:=True;
 BestSize1.Enabled:=True;
 ToolButton5.Down:=false;
 ToolButton4.Down:=false;
 ToolButton8.Down:=false;
 ToolButton9.Down:=false;
 EndWaitToImage(nil);
 ReAllignScrolls(False,Point(0,0));
 SlideNO:=-1;
 ZoomerOn:=false;
 im:=(AnimatedImage.Graphic as TGIFImage);
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
  AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
 end;
 AnimatedBuffer.Canvas.Rectangle(0,0,AnimatedBuffer.Width,AnimatedBuffer.Height);
 ImageFrameTimer.Interval:=1;
 ImageFrameTimer.Enabled:=true;
end;

procedure TViewer.ImageFrameTimerTimer(Sender: TObject);
begin
 NextSlide;
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
 r:=(AnimatedImage.Graphic as TGIFImage).Images[SlideNO].BoundsRect;
 if FullScreenNow then
 begin
  AnimatedBuffer.Canvas.Brush.Color:=0;
  AnimatedBuffer.Canvas.Pen.Color:=0;
 end else
 begin
  AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
 end;
 im:=(AnimatedImage.Graphic as TGIFImage);
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
   AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
   AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
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
  DB_IMAGE_ROTATED_0 : FbImage.Assign(AnimatedBuffer);
  DB_IMAGE_ROTATED_90 : Rotate90(AnimatedBuffer,FbImage);
  DB_IMAGE_ROTATED_180 : Rotate180(AnimatedBuffer,FbImage);
  DB_IMAGE_ROTATED_270: Rotate270(AnimatedBuffer,FbImage)
 end;
 RecreateDrawImage_(nil);
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

function TViewer.GetFirstImageNO: integer;
var
  i : Integer;
begin
 Result:=0;
 if ValidImages=0 then Result:=0 else
 begin
  for i:=0 to (AnimatedImage.Graphic as TGIFImage).Images.count-1 do
  if not (AnimatedImage.Graphic as TGIFImage).Images[i].Empty then
  begin
   Result:=i;
   break;
  end;
 end;
end;

function TViewer.GetNextImageNO: integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage.Graphic as TGIFImage);
  Result:=SlideNO;
  inc(Result);
  if Result>=im.Images.Count then
  begin
   Result:=0;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetNextImageNOX(Result);
  end;
 end;
end;

function TViewer.GetPreviousImageNO: integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage.Graphic as TGIFImage);
  Result:=SlideNO;
  dec(Result);
  if Result<0 then
  begin
   Result:=im.Images.Count-1;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetPreviousImageNOX(Result);
  end;
 end;
end;

function TViewer.GetNextImageNOX(NO: Integer): integer;
var
//  i  : Integer;
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage.Graphic as TGIFImage);
  Result:=NO;
  inc(Result);
  if Result>=im.Images.Count then
  begin
   Result:=0;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetNextImageNOX(Result);
  end;
 end;
end;

function TViewer.GetPreviousImageNOX(NO: Integer): integer;
var
//  i : Integer;
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage.Graphic as TGIFImage);
  Result:=NO;
  dec(Result);
  if Result<0 then
  begin
   Result:=im.Images.Count-1;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetPreviousImageNOX(Result);
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
 Loading:=false;
 FCurrentlyLoadedFile:=FileName;
 Cursor:=crDefault;
 ToolButton4.Enabled:=false;
 ToolButton5.Enabled:=false;
 ToolButton6.Enabled:=false;
 ToolButton8.Enabled:=false;
 ToolButton9.Enabled:=false;
 ToolButton12.Enabled:=false;
 ToolButton13.Enabled:=false;
 ZoomIn1.Enabled:=false;
 ZoomOut1.Enabled:=false;
 RealSize1.Enabled:=false;
 BestSize1.Enabled:=false;
 ToolButton5.Down:=false;
 ToolButton4.Down:=false;
 ToolButton8.Down:=false;
 ToolButton9.Down:=false;
 EndWaitToImage(nil);
 ReAllignScrolls(False,Point(0,0));
 ImageExists:=false;
 ValidImages:=0;
 ForwardThreadExists:=false;
 ForwardThreadNeeds:=false;
 RecreateDrawImage_(nil);
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
  TViewerThread.Create(False,CurrentInfo.ItemFileNames[n],CurrentInfo.ItemRotates[n],false,1,ForwardThreadSID,true,not CurrentInfo.LoadedImageInfo[n], 0);
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
 ToolButton22.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0);
 ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];

 ToolButton12.Enabled:=True;
 ToolButton13.Enabled:=ToolButton12.Enabled;
end;

procedure TViewer.ToolButton6Click(Sender: TObject);
begin
 if CurrentInfo.Position=-1 then exit;
 if Loading then exit;
 SlideShowNow:=true;
 SlideTimer.Enabled:=false;
 Play:=false;
 WaitImageTimer.Enabled:=false;
 Application.CreateForm(TDirectShowForm, DirectShowForm);
 MTimer1.ImageIndex:=DB_IC_PLAY;
 MTimer1Click(Sender);
 DirectShowForm.Execute(Sender);
end;

procedure TViewer.SlideTimerTimer(Sender: TObject);
begin
 SpeedButton4Click(Sender);
end;

procedure TViewer.SetPlay(const Value: boolean);
begin
  FPlay := Value;
end;

procedure TViewer.ImageEditor1Click(Sender: TObject);
begin
 if FullScreenNow then
 FullScreenView.Close;
 With EditorsManager.NewEditor do
 begin
  Show;
  OpenFileName(CurrentInfo.ItemFileNames[CurrentFileNumber]);
 end;
end;

procedure TViewer.Print1Click(Sender: TObject);
var
  Files : TStrings;
begin
 Files:=TStringList.Create;
 if FileExists(CurrentInfo.ItemFileNames[CurrentFileNumber]) then
 Files.Add(CurrentInfo.ItemFileNames[CurrentFileNumber]);
 if Files.Count>0 then
 GetPrintForm(Files);
 Files.Free;
end;

procedure TViewer.ToolButton20Click(Sender: TObject);
var
  fQuery : TDataSet;
  s : TArStrings;
  EventInfo : TEventValues;
  SQL_ : string;
  i, DeleteID : Integer;
begin
 If ID_OK=MessageBoxDB(Handle,TEXT_MES_DEL_FILE_CONFIRM,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  DeleteID:=0;
  if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
  begin
   fQuery:=GetQuery;
   DeleteID:=CurrentInfo.ItemIds[CurrentFileNumber];
   SQL_:=Format('DELETE FROM %s WHERE ID = %d',[GetDefDBname,CurrentInfo.ItemIds[CurrentFileNumber]]);
   SetSQL(fQuery,SQL_);
   ExecSQL(fQuery);
   FreeDS(fQuery);
  end;
  SetLength(s,1);
  s[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
  SilentDeleteFiles(Handle, s , true );
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
   If Length(CurrentInfo.ItemFileNames)=0 then
   begin
    Close;
    DBKernel.DoIDEvent(nil,DeleteID,[EventID_Param_Delete],EventInfo);
    Exit;
   end;
   if CurrentFileNumber>Length(ItemFileNames)-1 then CurrentFileNumber:=Length(ItemFileNames)-1;
  end;
  if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
  DBKernel.DoIDEvent(nil,DeleteID,[EventID_Param_Delete],EventInfo);
  if Length(CurrentInfo.ItemFileNames)<2 then
  begin
   ToolButton2.Enabled:=false;
   ToolButton1.Enabled:=false;
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Enabled:=false;
    FloatPanel.ToolButton2.Enabled:=false;
    FloatPanel.ToolButton4.Enabled:=false;
    FloatPanel.ToolButton5.Enabled:=false;
   end;
  end else
  begin
   ToolButton2.Enabled:=True;
   ToolButton1.Enabled:=True;
   if FloatPanel<>nil then
   begin
    FloatPanel.ToolButton1.Enabled:=True;
    FloatPanel.ToolButton2.Enabled:=True;
    FloatPanel.ToolButton4.Enabled:=True;
    FloatPanel.ToolButton5.Enabled:=True;
   end;
  end;
  ToolButton4.Enabled:=false;
  ZoomIn1.Enabled:=false;
  ZoomOut1.Enabled:=false;
  ToolButton5.Enabled:=false;
  ToolButton6.Enabled:=false;
  ToolButton8.Enabled:=false;
  ToolButton9.Enabled:=false;
  ToolButton12.Enabled:=false;
  ToolButton13.Enabled:=false;
  RealSize1.Enabled:=false;
  BestSize1.Enabled:=false;
  LoadImage_(Sender,CurrentInfo.ItemFileNames[CurrentFileNumber],CurrentInfo.ItemRotates[CurrentFileNumber],false,1,true);
  ToolBar2.Refresh;
 end;
end;

procedure TViewer.ToolButton22Click(Sender: TObject);
var
  P : TPoint;
  i : integer;
begin
 GetCursorPos(P);
 for i:=0 to 5 do
 (FindComponent('N'+IntToStr(i)+'1') as TMenuItem).Default:=false;
 (FindComponent('N'+IntToStr(CurrentInfo.ItemRatings[CurrentFileNumber])+'1') as TMenuItem).Default:=true;
 RatingPopupMenu.Popup(P.X,P.Y);
end;

procedure TViewer.N51Click(Sender: TObject);
var
  Str : String;
  NewRating : integer;
  EventInfo : TEventValues;
  i : integer;
begin
  Str:=(Sender as TMenuItem).Caption;
  for i:=Length(Str) downto 1 do
  if Str[i]='&' then System.Delete(Str,i,1);
  NewRating:=StrToInt(str);
  SetRating(CurrentInfo.ItemIds[CurrentFileNumber],NewRating);
  EventInfo.Rating:=NewRating;
  DBKernel.DoIDEvent(Sender,CurrentInfo.ItemIds[CurrentFileNumber],[EventID_Param_Rating],EventInfo);
end;

procedure TViewer.ApplicationEvents1Hint(Sender: TObject);
begin
 Application.HintPause:=1000;
 Application.HintHidePause:=5000;
end;

procedure TViewer.UpdateInfoAboutFileName(FileName: String;
  info: TOneRecordInfo);
var
  i : integer;
begin
 for i:=0 to Length(CurrentInfo.ItemFileNames)-1 do
 if not CurrentInfo.LoadedImageInfo[i] then
 if CurrentInfo.ItemFileNames[i]=FileName then
 begin
  SetRecordToRecords(CurrentInfo,i,info);
  exit;
 end;
end;

procedure TViewer.SendTo1Click(Sender: TObject);
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

procedure TViewer.SendToItemPopUpMenu_(Sender: TObject);
var
  NumberOfPanel : Integer;
  InfoNames : TArStrings;
  InfoIDs : TArInteger;
  Infoloaded : TArBoolean;
  Panel : TFormCont;
begin
 NumberOfPanel:=(Sender As TMenuItem).Tag;
 Setlength(InfoNames,1);
 Setlength(InfoIDs,0);
 Setlength(Infoloaded,1);
 Infoloaded[0]:=true;
 if CurrentInfo.ItemIds[CurrentFileNumber]<>0 then
 begin
  Setlength(InfoIDs,1);
  InfoIDs[0]:=CurrentInfo.ItemIds[CurrentFileNumber];
 end else
 begin
  Setlength(InfoNames,1);
  InfoNames[0]:=CurrentInfo.ItemFileNames[CurrentFileNumber];
 end;
 If NumberOfPanel>=0 then
 begin
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,true,ManagerPanels[NumberOfPanel]);
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,false,ManagerPanels[NumberOfPanel]);
 end;
 If NumberOfPanel<0 then
 begin
  Panel:=ManagerPanels.NewPanel;
  Panel.Show;
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,true,Panel);
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,false,Panel);
 end;
end;

procedure TViewer.NewPanel1Click(Sender: TObject);
begin
 ManagerPanels.NewPanel.Show;
end;

procedure TViewer.DoUpdateRecordWithDataSet(FileName: string;
  DS: TDataSet);
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(CurrentInfo.ItemFileNames)-1 do
 if AnsiLowerCase(CurrentInfo.ItemFileNames[i])=FileName then
 begin
  SetRecordsInfoOne(CurrentInfo,i,DS.FieldByName('FFileName').AsString,DS.FieldByName('ID').AsInteger,DS.FieldByName('Rotated').AsInteger,DS.FieldByName('Rating').AsInteger,DS.FieldByName('Access').AsInteger,DS.FieldByName('Comment').AsString,DS.FieldByName('Groups').AsString,DS.FieldByName('DateToAdd').AsDateTime,DS.FieldByName('IsDate').AsBoolean,DS.FieldByName('IsTime').AsBoolean,DS.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(DS.FieldByName('thum')),DS.FieldByName('Include').AsBoolean,DS.FieldByName('Links').AsString);
  CurrentInfo.LoadedImageInfo[i]:=true;
  if not Loading then
  begin
   if CurrentInfo.ItemRotates[i]<>0 then
   if i = CurrentFileNumber then
   begin
    Case CurrentInfo.ItemRotates[i] of
    DB_IMAGE_ROTATED_270: Rotate270A(FbImage);
    DB_IMAGE_ROTATED_90: Rotate90A(FbImage);
    DB_IMAGE_ROTATED_180: Rotate180A(FbImage);
    end;
    RecreateDrawImage_(self);
   end;
  end else
  begin
   FRotatingImageInfo.Enabled:=true;
   FRotatingImageInfo.FileName:=FileName;
   FRotatingImageInfo.Rotating:=CurrentInfo.ItemRotates[i];
  end;
  break;
 end;
 ToolButton22.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0);
 ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];

 ToolButton12.Enabled:=True;
 ToolButton13.Enabled:=ToolButton12.Enabled;
end;

procedure TViewer.DoSetNoDBRecord(FileName: string);
var
  i : integer;
begin
 for i:=0 to Length(CurrentInfo.ItemFileNames)-1 do
 if not CurrentInfo.LoadedImageInfo[i] then
 if CurrentInfo.ItemFileNames[i]=FileName then
 begin
  CurrentInfo.LoadedImageInfo[i]:=true;
  break;
 end;
 ToolButton22.Enabled:=(CurrentInfo.ItemIds[CurrentFileNumber]<>0);
 ToolButton22.ImageIndex:=14+CurrentInfo.ItemRatings[CurrentFileNumber];

 ToolButton12.Enabled:=True;
 ToolButton13.Enabled:=ToolButton12.Enabled;
end;

procedure TViewer.TimerDBWorkTimer(Sender: TObject);
begin
 if not (ToolButton22.ImageIndex in [20..21]) then
 begin
  TimerDBWork.Enabled:=false;
  exit;
 end;
 if ToolButton22.ImageIndex=20 then
 begin
  ToolButton22.ImageIndex:=21;
 end else
 begin
  ToolButton22.ImageIndex:=20;
 end;
end;

procedure TViewer.MakePagesLinks;
var
  i : integer;
  MenuItem : TMenuItem;
begin
 ToolButtonPage.Visible:=fPageCount>1;
 ToolButton23.Visible:=fPageCount>1;
 ToolsBar.Realign;
 ToolBar2.Width:=ToolButton14.Left+ToolButton14.Width+2;
 ToolsBar.Width:=ToolBar2.Width;
 ToolsBar.Left:=ClientWidth div 2- ToolsBar.Width div 2;
 PopupMenuPageSelecter.Items.Clear;
 for i:=1 to Self.fPageCount do
 begin
  MenuItem := TMenuItem.Create(PopupMenuPageSelecter);
  MenuItem.Caption:=IntToStr(i);
  MenuItem.OnClick:=OnPageSelecterClick;
  MenuItem.Tag:=i-1; //page
  if i-1=Self.fCurrentPage then
  MenuItem.Default:=true;
  PopupMenuPageSelecter.Items.Add(MenuItem);
 end;
end;

procedure TViewer.OnPageSelecterClick(Sender: TObject);
begin
 fCurrentPage:=TMenuItem(Sender).Tag;
 ReloadCurrent;
end;

function TViewer.GetPageCaption: String;
begin
 if fPageCount>1 then
 Result:=Format(TEXT_MES_SLIDE_PAGE_CATION,[fCurrentPage+1,fPageCount]) else Result:='';
end;

initialization

Viewer:=nil;

end.
