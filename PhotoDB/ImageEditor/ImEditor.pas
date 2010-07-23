unit ImEditor;

interface

{$DEFINE PHOTODB}

uses

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WebLink, StdCtrls, ExtCtrls, ComCtrls, ExtDlgs, jpeg, GIFImage, Math,
  DropSource, DropTarget, ToolsUnit, CropToolUnit, SaveWindowPos, dEXIF,
  ImageHistoryUnit, RotateToolUnit, ResizeToolUnit, clipbrd,
  EffectsToolUnit, RedEyeToolUnit, ColorToolUnit, Spin, Menus, Language,
  CustomSelectTool, TextToolUnit, BrushToolUnit,InsertImageToolUnit,
  GraphicsBaseTypes
{$IFDEF PHOTODB}
  ,GraphicCrypt, Dolphin_DB, UnitPasswordForm, Searching, UnitJPEGOptions,
  ExplorerUnit, FormManegerUnit, UnitDBKernel, PropertyForm, Buttons,
  UnitCrypting, GraphicEx, GraphicsCool, uScript, UnitScripts, PngImage, TiffImageUnit,
  RAWImage, DragDrop, DragDropFile, uVistaFuncs, UnitDBDeclare, UnitDBFileDialogs,
  UnitDBCommonGraphics, UnitCDMappingSupport, uLogger
{$ENDIF}
  ;

Type TTool=(ToolNone,ToolPen,ToolCrop,ToolRotate,ToolResize,ToolEffects,
ToolColor,ToolRedEye, ToolText, ToolBrush, ToolInsertImage);

type
  TCompresJPEGToSizeCallback = procedure(CurrentSize, CompressionRate : integer; var break : boolean) of object;

{$DEFINE PICTURE24BITMODE}

type
  TVBrushType = array of TPoint;

  type
    TWindowEnableState = record
     Control : TControl;
     Enabled : boolean;
    end;

   TWindowEnableStates = array of TWindowEnableState;

type
  TImageEditor = class(TForm)
    ToolsPanel: TPanel;
    ButtomPanel: TPanel;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    NullPanel: TPanel;
    DropFileTarget1: TDropFileTarget;
    ToolSelectPanel: TPanel;
    OpenFileLink: TWebLink;
    CropLink: TWebLink;
    SaveWindowPos1: TSaveWindowPos;
    ZoomInLink: TWebLink;
    ZoomOutLink: TWebLink;
    UndoLink: TWebLink;
    RedoLink: TWebLink;
    PaintBox1: TPaintBox;
    StatusBar1: TStatusBar;
    RotateLink: TWebLink;
    ResizeLink: TWebLink;
    EffectsLink: TWebLink;
    FitToSizeLink: TWebLink;
    ColorsLink: TWebLink;
    Image1: TImage;
    RedEyeLink: TWebLink;
    SaveLink: TWebLink;
    FullSiseLink: TWebLink;
    DestroyTimer: TTimer;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    OpenFile1: TMenuItem;
    Search1: TMenuItem;
    Explorer1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Properties1: TMenuItem;
    N3: TMenuItem;
    ZoomIn1: TMenuItem;
    ZoomOut1: TMenuItem;
    FullScreen1: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    TextLink: TWebLink;
    BrushLink: TWebLink;
    N4: TMenuItem;
    Print1: TMenuItem;
    InsertImageLink: TWebLink;
    NewEditor1: TMenuItem;
    N5: TMenuItem;
    Actions1: TMenuItem;
    TempPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure OpenFile(Sender: TObject);
    procedure LoadProgramImageFormat(Pic : TPicture);
    procedure FormPaint(Sender: TObject);
    procedure ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
    procedure LoadJPEGImage(JPEG : TJPEGImage);
    procedure LoadBMPImage(Bitmap : TBitmap);
    procedure LoadGIFImage(GIF : TGIFImage);
    procedure LoadImageVariousformat(Image : TGraphic);
    procedure MakeImage;
    procedure ScrollBar2Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    function GetVisibleImageHeight : Integer;
    function BufferPointToImagePoint(P : TPoint) : Tpoint;
    function ImagePointToBufferPoint(P : TPoint) : Tpoint;
    function GetVisibleImageWidth : Integer;
    function GetImageRectA: TRect;
    function OpenFileName(FileName : String) : boolean;
    procedure CropLinkClick(Sender: TObject);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ShowTools(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MakeImageAndPaint;
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ZoomOutLinkClick(Sender: TObject);
    procedure FitToSizeLinkClick(Sender: TObject);
    procedure RecteareImageProc(Sender: TObject);
    procedure SetPointerToNewImage(Image : TBitmap);
    procedure RotateLinkClick(Sender: TObject);
    procedure SetTemporaryImage(Image : TBitmap);
    procedure CancelTemporaryImage(Destroy : Boolean);
    procedure HistoryChanged(Sender: TObject; Action : THistoryAction);
    procedure MakeCaption;
    function GetZoom : Extended;
    procedure ResizeLinkClick(Sender: TObject);
    procedure UndoLinkClick(Sender: TObject);
    procedure RedoLinkClick(Sender: TObject);
    procedure ZoomInLinkClick(Sender: TObject);
    procedure EffectsLinkClick(Sender: TObject);
    procedure ColorsLinkClick(Sender: TObject);
    procedure RedEyeLinkClick(Sender: TObject);
    procedure SaveLinkClick(Sender: TObject);
    procedure DisableHistory;
    procedure EnableHistory;
    procedure FullSiseLinkClick(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Search1Click(Sender: TObject);
    procedure Explorer1Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Paste1Click(Sender: TObject);
    procedure LoadBitmap(Bitmap : TBitmap);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FullScreen1Click(Sender: TObject);
    function GetCurrentImage : TBitmap;
    procedure Copy1Click(Sender: TObject);
    procedure TextLinkClick(Sender: TObject);
    procedure BrushLinkClick(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure InsertImageLinkClick(Sender: TObject);
    procedure NewEditor1Click(Sender: TObject);
    procedure MakePCurrentImage;
    procedure MakeTempLayer;
    procedure DeleteTempLayer;
    procedure Actions1Click(Sender: TObject);
    procedure ReadActions(Actions : TArStrings);
    procedure ReadNextAction(Sender: TObject);
    procedure ReadActionsFile(FileName : string);
    procedure SaveImageFile(FileName : string; AfterEnd : boolean = false);
  private           
    { Private declarations }
   EXIFSection : TimgData;
   SaveAfterEndActions : boolean;
   SaveAfterEndActionsFileName : string;
   ForseSave : boolean;
   ForseSaveFileName : string;
   NewActions : TArStrings;
   NewActionsCounter : integer;
   OldBrushPos : TPoint;
   LockedImage : Boolean;
   CurrentImage, Buffer, Temp : TBitmap;
   PBuffer : PARGBArray;
   PCurrentImage : PARGBArray;
   PCurrentImage32 : PARGB32Array;
   TempLayer : TBitmap;
   PTempLayer : PARGB32Array;
   Tool : TTool;
   ZoomerOn : Boolean;
   Zoom : Extended;
   TempImage : Boolean;
   ImageHistory : TBitmapHistory;
   CurrentFileName : String;
   FilePassWord : String;
    FCloseOnFailture: boolean;
    fSaved : boolean;
    EState : TWindowEnableStates;
    procedure SetCloseOnFailture(const Value: boolean);
  protected
    procedure CreateParams(VAR Params: TCreateParams); override;
  public
   FScript : string;
   FScriptProc : string;
   ActionForm : TForm;
   VBrush : TVBrushType;
   VirtualBrushCursor : Boolean;
   Transparency : extended;
   FStatusProgress : TProgressBar;
   WindowID : TGUID;
   procedure LoadLanguage;
   procedure CMMOUSELEAVE(var Message: TWMNoParams); message CM_MOUSELEAVE;
  published
  ToolClass : TToolsPanelClass;
  Property CloseOnFailture : boolean read FCloseOnFailture write SetCloseOnFailture;
    { Public declarations }
  end;

  TArEditors = array of TImageEditor;

  TManagerEditors = class(TObject)
   Private
   Public
    FEditors : TArEditors;

    Constructor Create;
    Destructor Destroy; override;
    Function NewEditor : TImageEditor;
    Procedure AddEditor(Editor : TImageEditor);
    Procedure RemoveEditor(Editor : TImageEditor);
    Function IsEditor(Editor : TForm) : Boolean;
    Function EditorsCount : Integer;
    Function GetAnyEditor : TImageEditor;
   published
  end;

var
  deltwo : integer= 2;
  EditorsManager : TManagerEditors;

const
{$IFDEF PHOTODB}
  IMRELEASE = not DBInDebug;
{$ENDIF}
{$IFNDEF PHOTODB}
  IMRELEASE = false;
{$ENDIF}

  CUR_UPDOWN = 140;
  CUR_LEFTRIGHT = 141;
  CUR_TOPRIGHT = 142;
  CUR_RIGHTBOTTOM = 143;
  CUR_HAND = 144;
  CUR_CROP = 145;

  ImageEditorProductName = 'DBImage Editor v1.2';

function NormalizeRect(R : TRect) : TRect;
procedure ClearBrush(var Brush : TVBrushType);
procedure MakeRadialBrush(var Brush : TVBrushType; Size : Integer);

implementation

uses UnitEditorFullScreenForm

{$IFDEF PHOTODB}
, PrintMainForm, UnitActionsForm
{$ENDIF}
;

{$R *.dfm}
{$R cursors.res}
//{$R editor.res}

Function CompresJPEGToSize(jS : TGraphic; var ToSize : integer; Progressive : boolean; var CompressionRate : integer; CallBack : TCompresJPEGToSizeCallback = nil) : TJPEGImage;
var
 ms : TMemoryStream;
 jd : TJPEGImage;
 max_size, cur_size, cur_cr, cur_cr_inc : integer;
 isbreak : boolean;
begin
 max_size:=ToSize;
 cur_cr:=50;
 cur_cr_inc:=50;
 isbreak:=false;
 repeat
  jd:= TJpegImage.Create;
  jd.Assign(js);
  jd.CompressionQuality:=cur_cr;
  jd.ProgressiveEncoding:=Progressive;
  jd.ProgressiveDisplay:=Progressive;
  jd.Compress;
  ms:=TMemoryStream.Create;
  jd.SaveToStream(ms);
  ms.Seek(0,soFromBeginning);
  cur_size:=ms.Size;
  if Assigned(CallBack) then CallBack(cur_size,cur_cr,isbreak);
  if isbreak then
  begin
   Result:=nil;
   jd.free;
   ms.free;
   CompressionRate:=-1;
   ToSize:=-1;
   exit;
  end;
  if ((cur_size<max_size) and (cur_cr_inc=1)) or (cur_cr=1) then begin ms.free; break; end;
  cur_cr_inc:=Round(cur_cr_inc / 2);
  if cur_cr_inc<1 then cur_cr_inc:=1;
  if cur_size<max_size then begin cur_cr:=cur_cr+cur_cr_inc; end else cur_cr:=cur_cr-cur_cr_inc;
  if (cur_size<max_size) and (cur_cr=99) then cur_cr_inc:=2;
  jd.free;
  ms.free;
 until false;
 CompressionRate:=cur_cr;
 ToSize:=cur_size;
 Result:=jd;
end;

procedure DisableControls(Window : TImageEditor);

 procedure off(Control : TWinControl);
 begin
  Control.Enabled:=False;
  Control.Invalidate;
 end;

begin
 With Window do
 begin
 DropFileTarget1.Unregister;
 off(SaveLink);
 off(UndoLink);
 off(RedoLink);
 off(OpenFileLink);
 off(CropLink);
 off(RotateLink);
 off(ResizeLink);
 off(EffectsLink);
 off(ColorsLink);
 off(RedEyeLink);
 off(TextLink);
 off(BrushLink);
 off(InsertImageLink);
 end;
end;

procedure EnableControls(Window : TImageEditor);

 procedure on_(Control : TWinControl);
 begin
  Control.Enabled:=true;
  Control.Invalidate;
 end;

begin     
 With Window do
 begin
 DropFileTarget1.Register(Window);
 on_(SaveLink);
 on_(UndoLink);
 on_(RedoLink);
 on_(OpenFileLink);
 on_(CropLink);
 on_(RotateLink);
 on_(ResizeLink);
 on_(EffectsLink);
 on_(ColorsLink);
 on_(RedEyeLink);
 on_(TextLink);
 on_(BrushLink);
 on_(InsertImageLink);
 end;
end;

procedure ClearBrush(var Brush : TVBrushType);
begin
 SetLength(Brush,0);
end;

procedure MakeRadialBrush(var Brush : TVBrushType; Size : Integer);
var
  i : integer;
  Count : Integer;
begin
 Count:=Round(Size*4/sqrt(2));
 SetLength(Brush,Count);
 for i:=0 to Length(Brush)-1 do
 begin
  Brush[i].X:=Round(Size*cos(2*i*pi/Count));
  Brush[i].Y:=Round(Size*sin(2*i*pi/Count));
 end;
end;

function NormalizeRect(R : TRect) : TRect;
begin
 Result.Left:=Min(R.Left,R.Right);
 Result.Right:=Max(R.Left,R.Right);
 Result.Top:=Min(R.Top,R.Bottom);
 Result.Bottom:=Max(R.Top,R.Bottom);
end;

function CreateProgressBar(StatusBar:TStatusBar; index:integer):TProgressBar;
var
  findleft : integer;
  i : integer;
begin
 Result:=TProgressBar.Create(Statusbar);
 Result.parent:=Statusbar;
 Result.visible:=true;
 Result.top:=2;
 FindLeft:=0;
 for i:=0 to index-1 do
 FindLeft:=FindLeft+Statusbar.Panels[i].width+1;
 Result.left:=findleft;
 Result.width:=Statusbar.Panels[index].width-4;
 Result.height:=Statusbar.height-2;
end;

procedure TImageEditor.FormCreate(Sender: TObject);
var
  i : integer;

{Function LoadLinkIcons : Boolean;
begin
 try
 CropLink.Icon:= CropLink.Icon;
 OpenFileLink.Icon:= OpenFileLink.Icon;
 ZoomInLink.Icon:= ZoomInLink.Icon;
 ZoomOutLink.Icon:= ZoomOutLink.Icon;
 FitToSizeLink.Icon:= FitToSizeLink.Icon;
 ColorsLink.Icon:= ColorsLink.Icon;
 RedEyeLink.Icon:= RedEyeLink.Icon;
 SaveLink.Icon:= SaveLink.Icon;
 UndoLink.Icon:= UndoLink.Icon;
 RedoLink.Icon:= RedoLink.Icon;
 RotateLink.Icon:= RotateLink.Icon;
 ResizeLink.Icon:= ResizeLink.Icon;
 EffectsLink.Icon:= EffectsLink.Icon;
 TextLink.Icon:= TextLink.Icon;
 BrushLink.Icon:= BrushLink.Icon;
 FullSiseLink.Icon:= FullSiseLink.Icon;
 InsertImageLink.Icon:= InsertImageLink.Icon;
 OpenFileLink.SetDefault;
 CropLink.SetDefault;
 RotateLink.SetDefault;
 ColorsLink.SetDefault;
 ResizeLink.SetDefault;
 EffectsLink.SetDefault;
 RedEyeLink.SetDefault;
 TextLink.SetDefault;
 BrushLink.SetDefault;
 InsertImageLink.SetDefault;
 except
  Result:=false;
  exit;
 end;
 Result:=true;
end;    }

begin
 EXIFSection:=nil;
 NewActionsCounter:=-1;
 FScript:='';
 SaveAfterEndActions:=false;
 ForseSave:=false;
 WindowID:=GetGUID;
 ClearBrush(VBrush);
 ToolClass:=nil;
 PTempLayer:=nil;
 EditorsManager.AddEditor(self);
 FCloseOnFailture:=true;
 ImageHistory := TBitmapHistory.Create;
 ImageHistory.OnHistoryChange:=HistoryChanged;
 CurrentImage:=TBitmap.Create;
 CurrentImage.PixelFormat:=pf32bit;
 CurrentImage.Width:=0;
 CurrentImage.Height:=0;
 Buffer:=TBitmap.Create;
 Buffer.PixelFormat:=pf24bit;
 Tool:=ToolNone;
 fStatusProgress:=CreateProgressBar(StatusBar1,1);
 LockedImage:=false;
 TempImage:=false;
 Screen.Cursors[CUR_UPDOWN]:=LoadCursor(HInstance,'UPDOWN');
 Screen.Cursors[CUR_LEFTRIGHT]:=LoadCursor(HInstance,'LEFTRIGHT');
 Screen.Cursors[CUR_TOPRIGHT]:=LoadCursor(HInstance,'TOPLEFTBOTTOMRIGHT');
 Screen.Cursors[CUR_RIGHTBOTTOM]:=LoadCursor(HInstance,'TOPRIGHTLEFTBOTTOM');
 Screen.Cursors[CUR_HAND]:=LoadCursor(HInstance,'HAND');
 Screen.Cursors[CUR_CROP]:=LoadCursor(HInstance,'CROP');

 DropFileTarget1.Register(Self);
 
 LoadLanguage;

 {for i:=1 to 10 do
 begin
  if LoadLinkIcons then break;
 end; }

 {$IFDEF PHOTODB}
  DBkernel.RegisterForm(self);
  Application.CreateForm(TActionsForm,ActionForm);
  TActionsForm(ActionForm).SetParent(self);
  TActionsForm(ActionForm).LoadIcons;
 {$ENDIF}

 ZoomerOn:=false;
 Zoom:=0.5;
 SaveWindowPos1.SetPosition;
 {$IFNDEF PHOTODB}

 if FileExists(ParamStr(1)) then
 OpenFileName(ParamStr(1));

 {$ENDIF}
 {$IFDEF PHOTODB}
 VirtualBrushCursor:=DBKernel.ReadBool('Editor','VirtualCursor',false);
 FormManager.RegisterMainForm(Self);
 PopupMenu1.Images:=DBKernel.ImageList;
 Exit1.ImageIndex:=DB_IC_EXIT;
 Search1.ImageIndex:=DB_IC_ADDTODB;
 Explorer1.ImageIndex:=DB_IC_EXPLORER;
 Properties1.ImageIndex:=DB_IC_PROPERTIES;
 ZoomOut1.ImageIndex:=DB_IC_ZOOMIN;
 ZoomIn1.ImageIndex:=DB_IC_ZOOMOUT;
 Paste1.ImageIndex:=DB_IC_PASTE;
 Print1.ImageIndex:=DB_IC_PRINTER;
 OpenFile1.ImageIndex:=DB_IC_LOADFROMFILE;
 Copy1.ImageIndex:=DB_IC_COPY;
 FullScreen1.ImageIndex:=DB_IC_DESKTOP;
 NewEditor1.ImageIndex:=DB_IC_IMEDITOR;

 Actions1.ImageIndex:=DB_IC_NEW_SHELL;
 {$ENDIF}                  
end;

procedure TImageEditor.LoadProgramImageFormat(Pic: TPicture);
var
  Loaded : boolean;
begin
 Loaded:=false;
 if Pic.Graphic is TJPEGImage then
 begin
  LoadJPEGImage(Pic.Graphic as TJPEGImage);
  Loaded:=true;
 end;
 if Pic.Graphic is TBitmap then
 begin
  LoadBMPImage(Pic.Graphic as TBitmap);
  Loaded:=true;
 end;
 if Pic.Graphic is TGIFImage then
 begin
  LoadGIFImage(Pic.Graphic as TGIFImage);
  Loaded:=true;
 end;
 if not Loaded then
 LoadImageVariousformat(Pic.Graphic);
end;

procedure TImageEditor.OpenFile(Sender: TObject);
var
  OpenPictureDialog : DBOpenPictureDialog;
begin
 OpenPictureDialog := DBOpenPictureDialog.Create;
 OpenPictureDialog.Filter:=Dolphin_DB.GetGraphicFilter;
 
 if OpenPictureDialog.Execute then OpenFileName(OpenPictureDialog.FileName);
 OpenPictureDialog.Free;
end;

procedure TImageEditor.FormPaint(Sender: TObject);
begin
 Canvas.Draw(0,ButtomPanel.Height,Buffer);
end;

procedure TImageEditor.LoadBMPImage(Bitmap: TBitmap);
var
  i, j : integer;
  p : PARGB;
begin
 {$IFDEF PHOTODB}
   StatusBar1.Panels[0].Text:=TEXT_MES_IM_LOADING_BMP;
 {$ENDIF}
 {$IFNDEF PHOTODB}
   StatusBar1.Panels[0].Text:='Loading JPEG format';
 {$ENDIF}
 StatusBar1.Repaint;
 StatusBar1.Refresh;
 FStatusProgress.Max:=Bitmap.Height+Bitmap.Height div 2;
 FStatusProgress.Position:=0;

 CurrentImage.Width:=Bitmap.Width;
 CurrentImage.Height:=Bitmap.Height;

 FStatusProgress.Position:=Bitmap.Height div 2;

 CurrentImage.PixelFormat:=pf24bit;

 if Bitmap.PixelFormat=pf24bit then
 begin
  MakePCurrentImage;
  Bitmap.PixelFormat:=pf24bit;
  for i:=0 to Bitmap.Height-1 do
  begin
   p:=Bitmap.ScanLine[i];
   for j:=0 to Bitmap.Width-1 do
   begin
    PCurrentImage[i,j].r:=p[j].r;
    PCurrentImage[i,j].g:=p[j].g;
    PCurrentImage[i,j].b:=p[j].b;
   end;
   if i mod 50=0 then
   FStatusProgress.Position:=i+Bitmap.Height div 2;
  end;
 end else
 begin
  CurrentImage.Assign(Bitmap);
  CurrentImage.PixelFormat:=pf24bit;
  MakePCurrentImage;
 end;

 FStatusProgress.Position:=0;
 StatusBar1.Panels[0].Text:='';
end;

procedure TImageEditor.LoadGIFImage(GIF: TGIFImage);
var
  i, j : integer;
begin
 {$IFDEF PHOTODB}
   StatusBar1.Panels[0].Text:=TEXT_MES_IM_LOADING_GIF;
 {$ENDIF}
 {$IFNDEF PHOTODB}
   StatusBar1.Panels[0].Text:='Loading JPEG format';
 {$ENDIF}
 StatusBar1.Repaint;
 StatusBar1.Refresh;
 FStatusProgress.Max:=GIF.Height*2;
 FStatusProgress.Position:=0;
 CurrentImage.Width:=GIF.Width;
 CurrentImage.Height:=GIF.Height;
 FStatusProgress.Position:=GIF.Height div 2;
 CurrentImage.Assign(GIF);
 FStatusProgress.Position:=GIF.Height;
 CurrentImage.PixelFormat:=pf32bit;
 MakePCurrentImage;
 for i:=0 to GIF.Height-1 do
 begin
//  p32:=CurrentImage.ScanLine[i];
  for j:=0 to GIF.Width-1 do
  begin
   if GIF.Images[0].Transparent then
   begin
    if GIF.Images[0].Pixels[j,i]=GIF.Images[0].GraphicControlExtension.TransparentColorIndex then
    PCurrentImage32[i,j].l:=0 else PCurrentImage32[i,j].l:=255;
   end else PCurrentImage32[i,j].l:=255;
  end;
  if i mod 50=0 then
  FStatusProgress.Position:=i+GIF.Height;
 end;
 CurrentImage.PixelFormat:=pf24bit;
 MakePCurrentImage;
 FStatusProgress.Position:=0;
 StatusBar1.Panels[0].Text:='';
end;

procedure TImageEditor.LoadJPEGImage(JPEG: TJPEGImage);
 {$IFDEF PICTURE32BITMODE}
var
  Temp : TBitmap;
  i, j : integer;
  p : PARGB;
 {$ENDIF}
begin
 {$IFDEF PHOTODB}
   StatusBar1.Panels[0].Text:=TEXT_MES_IM_LOADING_JPEG;
 {$ENDIF}
 {$IFNDEF PHOTODB}
   StatusBar1.Panels[0].Text:='Loading JPEG format';
 {$ENDIF}
 StatusBar1.Repaint;
 StatusBar1.Refresh;
 {$IFDEF PICTURE24BITMODE}
 FStatusProgress.Max:=2;
 FStatusProgress.Position:=0;
 CurrentImage.Assign(JPEG);
 FStatusProgress.Position:=1;
 CurrentImage.PixelFormat:=pf24bit;
 {$ENDIF}
 {$IFDEF PICTURE32BITMODE}
 FStatusProgress.Max:=JPEG.Height*2;
 FStatusProgress.Position:=0;
 Temp := TBitmap.Create;
 Temp.Assign(JPEG);
 FStatusProgress.Position:=JPEG.Height div 2;
 Temp.PixelFormat:=pf24bit;
 CurrentImage.Width:=Temp.Width;
 CurrentImage.Height:=Temp.Height;
 CurrentImage.PixelFormat:=pf32bit;
 FStatusProgress.Position:=JPEG.Height;
 MakePCurrentImage;
 for i:=0 to Temp.Height-1 do
 begin
  p:=Temp.ScanLine[i];
  for j:=0 to Temp.Width-1 do
  begin
   PCurrentImage32[i,j].r:=p[j].r;
   PCurrentImage32[i,j].g:=p[j].g;
   PCurrentImage32[i,j].b:=p[j].b;
   PCurrentImage32[i,j].l:=255;
  end;
  if i mod 50=0 then
  FStatusProgress.Position:=i+JPEG.Height;
 end;
 Temp.Free;
 {$ENDIF}
 CurrentImage.PixelFormat:=pf24bit;
 MakePCurrentImage;
 FStatusProgress.Position:=0;
 StatusBar1.Panels[0].Text:='';
end;

procedure TImageEditor.LoadImageVariousformat(Image: TGraphic);
begin
 CurrentImage.Width:=Temp.Width;
 CurrentImage.Height:=Temp.Height;
 CurrentImage.Assign(Image);
 CurrentImage.PixelFormat:=pf24bit;
 MakePCurrentImage;
end;

procedure TImageEditor.MakeImage;
var
  i, j : integer;
  fh,fw : integer;
  zx,zy,zw,zh, x1,x2,y1,y2 : integer;
  ImRect, BeginRect : TRect;
  CropClass : TCropToolPanelClass;
  CustomSelectToolClass : TCustomSelectToolClass;
  Pt1, Pt2 : TPoint;
  
begin
 if LockedImage then exit;
 for i:=0 to Buffer.Height-1 do
 begin
  for j:=0 to Buffer.Width-1 do
  begin
   PBuffer[i,j].r:=0;
   PBuffer[i,j].g:=0;
   PBuffer[i,j].b:=0;
  end;
 end;

  if (CurrentImage.Height=0) or (CurrentImage.width=0) then exit;
  if (CurrentImage.Width>GetVisibleImageWidth) or (CurrentImage.Height>GetVisibleImageHeight) then
  begin
   if CurrentImage.Width/CurrentImage.Height<Buffer.Width/Buffer.Height then
   begin
    fh:=Buffer.Height;
    fw:=round(Buffer.Height*(CurrentImage.width/CurrentImage.Height));
   end else begin
    fw:=Buffer.width;
    fh:=round(Buffer.width*(CurrentImage.Height/CurrentImage.width));
   end;
  end else begin
   fh:=CurrentImage.Height;
   fw:=CurrentImage.Width;
  end;
  x1:=GetVisibleImageWidth div 2 - fw div 2;
  y1:=GetVisibleImageHeight div 2 - fh div 2;
  x2:=x1+fw;
  y2:=y1+fh;
  ImRect:=GetImageRectA;
  zx:=ImRect.Left;
  zy:=ImRect.Top;
  zw:=ImRect.Right-ImRect.Left;
  zh:=ImRect.Bottom-ImRect.Top;

  begin
   If false then
   begin

    if ZoomerOn  then
    begin
     if Zoom<=1 then
     StretchCoolW(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),CurrentImage,Buffer) else
     Interpolate(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),CurrentImage,Buffer);
    end else
    begin
     StretchFastA(x1,y1,CurrentImage.Width,CurrentImage.Height,x2-x1,y2-y1,PCurrentImage,PBuffer);
    end;
   end else
   begin
    if ZoomerOn then
    begin
     ImRect:=Rect(Round(ScrollBar1.Position/zoom),Round((ScrollBar2.Position)/zoom),Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom));
     BeginRect:=GetImageRectA;
     SetStretchBltMode(Buffer.Canvas.Handle, 0);
     Buffer.Canvas.CopyMode:=SRCCOPY;
     if Zoom<=1 then
     begin
      StretchFast(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),PCurrentImage,PBuffer);
     end else
     Buffer.Canvas.CopyRect(BeginRect,CurrentImage.Canvas,ImRect);
    end else
    begin
     Buffer.Canvas.StretchDraw(rect(x1,y1,x2,y2),CurrentImage);
    end;
   end;
  end;

  if TempLayer<>nil then
  if Tool=ToolBrush then
  begin
   if ZoomerOn then
   begin
    StretchFastATransW(zx,zy,zw,zh,Rect(Round(ScrollBar1.Position/zoom), Round(ScrollBar2.Position/zoom), Round((ScrollBar1.Position+zw)/zoom),Round((ScrollBar2.Position+zh)/zoom)),PTempLayer,PBuffer,Transparency,(ToolClass as TBrushToolClass).MethodDrawChooser.ItemIndex);
   end else
   begin
    StretchFastATrans(x1,y1,CurrentImage.Width,CurrentImage.Height,x2-x1,y2-y1,PTempLayer,PBuffer,Transparency,(ToolClass as TBrushToolClass).MethodDrawChooser.ItemIndex);
   end;
  end;

 Case Tool of
  ToolNone : exit;
  ToolCrop :
  begin
   CropClass:=(ToolClass as TCropToolPanelClass);
   pt1:=Point(ImagePointToBufferPoint(CropClass.FirstPoint).x,ImagePointToBufferPoint(CropClass.FirstPoint).y);
   pt2:=Point(ImagePointToBufferPoint(CropClass.SecondPoint).x,ImagePointToBufferPoint(CropClass.SecondPoint).y);
   CropClass.DoCropToolToImage(Buffer,Rect(pt1,pt2));
  end;

  ToolRedEye, ToolText, ToolInsertImage :
  begin
   CustomSelectToolClass:=(ToolClass as TCustomSelectToolClass);
   if not CustomSelectToolClass.Termnating then
   begin
    pt1:=Point(ImagePointToBufferPoint(CustomSelectToolClass.FirstPoint).x,ImagePointToBufferPoint(CustomSelectToolClass.FirstPoint).y);
    pt2:=Point(ImagePointToBufferPoint(CustomSelectToolClass.SecondPoint).x,ImagePointToBufferPoint(CustomSelectToolClass.SecondPoint).y);
    CustomSelectToolClass.DoEffect(Buffer,Rect(pt1,pt2),false);
    CustomSelectToolClass.DoBorder(Buffer,Rect(pt1,pt2));
   end;
  end;

 end;
end;

procedure TImageEditor.ScrollBar2Change(Sender: TObject);
begin
 MakeImage;
 FormPaint(nil);
end;

procedure TImageEditor.FormResize(Sender: TObject);
var
 i : integer;
begin
 Buffer.Width:=Math.Max(1,GetVisibleImageWidth);
 Buffer.Height:=Math.Max(1,GetVisibleImageHeight);
 SetLength(PBuffer,Buffer.Height);
 for i:=0 to Buffer.Height-1 do
 PBuffer[i]:=Buffer.ScanLine[i];

 ToolsPanel.Left:=ClientWidth-ToolsPanel.Width;
 ToolsPanel.Height:=ClientHeight-ButtomPanel.Height-StatusBar1.Height;
 ReAllignScrolls(false,Point(0,0));
 MakeImage;
 FormPaint(nil);
 MakeCaption;
 StatusBar1.Top:=ClientHeight-StatusBar1.Height;
 StatusBar1.Width:=ClientWidth;
end;

procedure TImageEditor.ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
var
  inc_ : integer;
  pos, m, ps : integer;
  v1,v2 : boolean;
begin
 if Tool=ToolBrush then
 begin
  (ToolClass as TBrushToolClass).NewCursor;
 end;
 LockedImage:=true;
 if not ZoomerOn then
 begin
  ScrollBar1.Width:=1;
  ScrollBar1.Position:=0;
  ScrollBar1.Visible:=false;
  ScrollBar2.Position:=0;
  ScrollBar2.Visible:=false;
  NullPanel.Visible:=false;
  LockedImage:=false;
  Exit;
 end;
 v1:=ScrollBar1.Visible;
 v2:=ScrollBar2.Visible;
 if not ScrollBar1.Visible and not ScrollBar2.Visible then
 begin
  ScrollBar1.Visible:=CurrentImage.Width*Zoom>GetVisibleImageWidth;
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar2.Visible:=CurrentImage.height*Zoom>GetVisibleImageHeight-inc_;
 end;
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar1.Visible:=CurrentImage.Width*zoom>GetVisibleImageWidth-inc_;
  ScrollBar1.Width:=GetVisibleImageWidth-inc_{-2};
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar1.Top:=ClientHeight-inc_-StatusBar1.Height;
 end;
 begin
  if ScrollBar1.Visible then inc_:=ScrollBar1.height else inc_:=0;
  ScrollBar2.Visible:=CurrentImage.Height*zoom>{GetVisibleImageWidth}GetVisibleImageHeight-inc_;
  ScrollBar2.Height:=GetVisibleImageHeight-Inc_;
//  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar2.Left:=GetVisibleImageWidth-ScrollBar2.Width;
 end;
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  ScrollBar1.Visible:=CurrentImage.Width*Zoom>GetVisibleImageWidth-inc_;
  ScrollBar1.Width:=GetVisibleImageWidth-Inc_;
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  ScrollBar1.Top:=ClientHeight-Inc_-StatusBar1.Height;
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
 if ScrollBar1.Visible then
 begin
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  m:=Round(CurrentImage.Width*zoom);
  ps:=Buffer.Width-inc_;
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
  m:=Round(CurrentImage.Height*zoom);
  ps:=GetVisibleImageHeight-inc_;
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
 NullPanel.Visible:=ScrollBar1.Visible and ScrollBar2.Visible;
 NullPanel.Width:=ScrollBar2.Width;
 NullPanel.Height:=ScrollBar1.Height;
 NullPanel.Top:=ScrollBar1.Top;
 NullPanel.Left:=ScrollBar2.Left;
 ToolsPanel.Realign;
 LockedImage:=false;
end;

function TImageEditor.GetVisibleImageHeight: Integer;
begin
 Result:=ClientHeight-ButtomPanel.Height-StatusBar1.Height;
end;

function TImageEditor.GetVisibleImageWidth: Integer;
begin
 Result:=ClientWidth-ToolsPanel.Width;
end;

function TImageEditor.GetImageRectA: TRect;
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
   zx:=Max(0,Round(GetVisibleImageWidth/deltwo-inc_-CurrentImage.Width*Zoom/deltwo));
  end;
  if ScrollBar2.Visible then
  begin
   zy:=0;
  end else
  begin
   if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
   zy:=Max(0,Round(GetVisibleImageHeight/deltwo-inc_-CurrentImage.Height*Zoom/deltwo));
  end;
  if ScrollBar2.Visible then inc_:=ScrollBar2.Width else inc_:=0;
  zw:=Round(Min(GetVisibleImageWidth-inc_,CurrentImage.Width*Zoom));
  if ScrollBar1.Visible then inc_:=ScrollBar1.Height else inc_:=0;
  zh:=Round(Min(GetVisibleImageHeight-inc_,CurrentImage.Height*Zoom));
  zh:=zh;
  Result:=Rect(zx,zy,zw+zx,zh+zy);
end;

procedure TImageEditor.CropLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolCrop;
 ToolSelectPanel.Hide;
 ToolClass:=TCropToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 (ToolClass as TCropToolPanelClass).ProcRecteateImage:=RecteareImageProc;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 ToolClass.OnClosePanel:=ShowTools;
 (ToolClass as TCropToolPanelClass).FirstPoint:=Point(CurrentImage.Width div 3,CurrentImage.Height div 3);
 (ToolClass as TCropToolPanelClass).SecondPoint:=Point(CurrentImage.Width*2 div 3,CurrentImage.Height*2 div 3);
 MakeImage;
 FormPaint(nil);
end;

procedure TImageEditor.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if DropFileTarget1.Files.Count<>0 then
 begin
  OpenFileName(DropFileTarget1.Files[0]);
 end;
end;

function TImageEditor.OpenFileName(FileName: String): boolean;
var
  pic : TPicture;
  PassWord : String;
  Res : integer;
  
  Procedure DoExit;
  begin
   if CurrentFileName='' then
   if FCloseOnFailture then Close;
  end;

begin
 DoProcessPath(FileName);
 Result:=false;

 if Tool<>ToolNone then
 begin
  MessageBoxDB(Handle,TEXT_MES_CANT_OPEN_IMAGE_BECAUSE_EDITING,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_WARNING);
  exit;
 end;

 if ImageHistory.CanBack then
 begin
  Res:=MessageBoxDB(Handle,TEXT_MES_IMAGE_CHANGED_SAVE_Q,TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_WARNING);
  if Res=ID_YES then
  begin
   SaveLinkClick(self);
   if not fSaved then exit;
  end;
  if Res=ID_CANCEL then exit;
  if Res=ID_NO then ;
 end;

 {$IFDEF PHOTODB}
 pic:=nil;
 try
  pic := TPicture.Create;
  if ValidCryptGraphicFile(FileName) then
  begin
   PassWord:=DBkernel.FindPasswordForCryptImageFile(FileName);
   if PassWord='' then
   begin
    PassWord:=GetImagePasswordFromUser(FileName);
   end;
   if PassWord<>'' then
   begin
    Pic.Graphic:=DeCryptGraphicFile(FileName,PassWord,true);
    if EXIFSection<>nil then
    begin
     EXIFSection.free;
     EXIFSection:=nil;
    end;
   end
   else
   begin
    Pic.free;
    DoExit;
    Exit;
   end
  end else
  begin     
   if GetGraphicClass(GetExt(FileName),false) = TRAWImage then
   begin
    pic.Graphic:=TRAWImage.Create;
    //by default RAW is half-sized
    (pic.Graphic as TRAWImage).LoadHalfSize:=false;
    pic.Graphic.LoadFromFile(FileName);
    if EXIFSection<>nil then
    begin
     EXIFSection.free;
     EXIFSection:=nil;
    end;
   end else
   begin
    pic.LoadFromFile(FileName);
    try
     EXIFSection:=TImgData.Create();
     EXIFSection.ProcessFile(FileName);
     if EXIFSection.HasEXIF then
     if EXIFSection.HasThumbnail then
     begin
      EXIFSection.ExifObj.ProcessThumbnail;
      EXIFSection.ExifObj.removeThumbnail;
     end;
    except
     if EXIFSection<>nil then
     EXIFSection.Free;
     EXIFSection:=nil;
    end;
   end;
  end;
 except
  Pic.free;
  DoExit;
  Exit;
 End;
 FilePassWord:=PassWord;
 {$ENDIF}
 (ActionForm as TActionsForm).Reset;
 {$IFNDEF PHOTODB}
 pic := TPicture.Create;
 try
  pic.LoadFromFile(FileName);
 except
  pic.free;
  DoExit;
  exit;
 end;
 {$ENDIF}
 LoadProgramImageFormat(pic);
 pic.free;
 ImageHistory.Clear;
 CurrentImage.PixelFormat:=pf24bit;
 MakePCurrentImage;
 ImageHistory.Add(CurrentImage,'{{59168903-29EE-48D0-9E2E-7F34C913B94A}}["'+FileName+'"]');
 CurrentFileName:=FileName;
 MakeCaption;
 MakeImage;
 FormPaint(self);
 FormResize(self);
 CropLink.Enabled:=True;
 RotateLink.Enabled:=True;
 ColorsLink.Enabled:=True;
 ResizeLink.Enabled:=True;
 EffectsLink.Enabled:=True;
 RedEyeLink.Enabled:=True;
 TextLink.Enabled:=True;
 BrushLink.Enabled:=True;
 InsertImageLink.Enabled:=True;
 SaveLink.Enabled:=True;
 CropLink.SetDefault;
 RotateLink.SetDefault;
 ColorsLink.SetDefault;
 ResizeLink.SetDefault;
 EffectsLink.SetDefault;
 RedEyeLink.SetDefault;
 TextLink.SetDefault;
 SaveLink.SetDefault;
 BrushLink.SetDefault;
 InsertImageLink.SetDefault;
 Result:=true;
end;

procedure TImageEditor.ScrollBar1Scroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
 if ScrollPos>(Sender as TScrollBar).Max-(Sender as TScrollBar).PageSize then
 ScrollPos:=(Sender as TScrollBar).Max-(Sender as TScrollBar).PageSize;
end;

function TImageEditor.BufferPointToImagePoint(P: TPoint): TPoint;
var
  x1,y1 : integer;
  ImRect : TRect;
  fh,fw : integer;
begin
 if ZoomerOn then
 begin
  ImRect:=GetImageRectA;
  x1:=ImRect.Left;
  y1:=ImRect.Top;
  if ScrollBar1.Visible then
  Result.X:=Round((ScrollBar1.Position+P.X)/Zoom) else
  Result.X:=Round((P.X-x1)/Zoom);
  if ScrollBar2.Visible then
  Result.Y:=Round((ScrollBar2.Position+P.Y)/Zoom) else
  Result.Y:=Round((P.Y-y1)/Zoom);
 end else
 begin
  if (CurrentImage.Height=0) or (CurrentImage.width=0) then exit;
  if (CurrentImage.Width>GetVisibleImageWidth) or (CurrentImage.Height>GetVisibleImageHeight) then
  begin
   if CurrentImage.Width/CurrentImage.Height<Buffer.Width/Buffer.Height then
   begin
    fh:=Buffer.Height;
    fw:=round(Buffer.Height*(CurrentImage.width/CurrentImage.Height));
   end else begin
    fw:=Buffer.width;
    fh:=round(Buffer.width*(CurrentImage.Height/CurrentImage.width));
   end;
  end else begin
   fh:=CurrentImage.Height;
   fw:=CurrentImage.Width;
  end;
  x1:=GetVisibleImageWidth div 2 - fw div 2;
  y1:=GetVisibleImageHeight div 2 - fh div 2;
  Result:=Point(0,0);
  if fw<>0 then
  Result.X:=Round((P.X-x1)*(CurrentImage.Width/fw));
  if fh<>0 then
  Result.Y:=Round((P.Y-y1)*(CurrentImage.Height/fh));
 end;
end;

function TImageEditor.ImagePointToBufferPoint(P: TPoint): Tpoint;
var
  x1,y1 : integer;
  ImRect : TRect;
  fh,fw : integer;
begin
 if ZoomerOn then
 begin
  ImRect:=GetImageRectA;
  x1:=ImRect.Left;
  y1:=ImRect.Top;
  if ScrollBar1.Visible then
  Result.X:=Round(P.X*Zoom-ScrollBar1.Position) else
  Result.X:=Round((P.X*Zoom+x1));
  if ScrollBar2.Visible then
  Result.Y:=Round(P.Y*Zoom-ScrollBar2.Position) else
  Result.Y:=Round((P.Y*Zoom+y1));
 end else
 begin
  if (CurrentImage.Height=0) or (CurrentImage.width=0) then exit;
  if (CurrentImage.Width>GetVisibleImageWidth) or (CurrentImage.Height>GetVisibleImageHeight) then
  begin
   if CurrentImage.Width/CurrentImage.Height<Buffer.Width/Buffer.Height then
   begin
    fh:=Buffer.Height;
    fw:=round(Buffer.Height*(CurrentImage.Width/CurrentImage.Height));
   end else begin
    fw:=Buffer.width;
    fh:=round(Buffer.Width*(CurrentImage.Height/CurrentImage.Width));
   end;
  end else begin
   fh:=CurrentImage.Height;
   fw:=CurrentImage.Width;
  end;
  x1:=GetVisibleImageWidth div 2 - fw div 2;
  y1:=GetVisibleImageHeight div 2 - fh div 2;
  Result:=Point(0,0);
  if CurrentImage.Width<>0 then
  Result.X:=Round(x1+P.X*(fw/CurrentImage.Width));
  if CurrentImage.Height<>0 then
  Result.Y:=Round(y1+P.Y*(fh/CurrentImage.Height));
 end;
end;

procedure TImageEditor.ShowTools(Sender: TObject);
begin
 DeleteTempLayer;
 Tool:=ToolNone;
 ToolSelectPanel.Show;
 ToolClass:=nil;
 Cursor:=CrDefault;
 MakeImageAndPaint;
 ToolSelectPanel.Invalidate;
 EnableHistory;
 FStatusProgress.Position:=0;
end;

procedure TImageEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  aFScript : TScript;
  c : integer;
begin
 if FScript<>'' then
 if ScriptsManager.ScriptExists(FScript) then
 begin
  aFScript:=ScriptsManager.GetScriptByID(FScript);
  ExecuteScript(nil,aFScript,FScriptProc+'("'+FScript+'");',c,nil);
 end;
 try
  if ToolClass<>nil then ToolClass.ClosePanel;
 except
  on e : Exception do EventLog(':TImageEditor::FormClose() throw exception: '+e.Message);
 end;
 DestroyTimer.Enabled:=true;
end;

procedure TImageEditor.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CropClass : TCropToolPanelClass;
  CustomSelectToolClass : TCustomSelectToolClass;
  BrushClass : TBrushToolClass;
  P, ImagePoint, TopLeftPoint, RightBottomPoint : TPoint;
  De : Integer;
  InImage : Boolean;
begin
 if mbLeft<>Button then exit;
 Case Tool of
  ToolNone : exit;

  ToolCrop :
  begin
   CropClass:=(ToolClass as TCropToolPanelClass);
   ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));

   P.X:=math.Min(CurrentImage.Width,math.max(0,ImagePoint.X));
   P.Y:=math.Min(CurrentImage.Height,math.max(0,ImagePoint.Y));
   if (ImagePoint.X<>P.X) or (ImagePoint.Y<>P.Y) then
   begin
    Cursor:=CrDefault;
    exit;
   end;

   ImagePoint.X:=math.Min(CurrentImage.Width,math.max(0,ImagePoint.X));
   ImagePoint.Y:=math.Min(CurrentImage.Height,math.max(0,ImagePoint.Y));

   De:=Max(1,Round(5/GetZoom));
   TopLeftPoint.X:=Math.Min(CropClass.SecondPoint.X,CropClass.FirstPoint.X);
   RightBottomPoint.X:=Math.Max(CropClass.SecondPoint.X,CropClass.FirstPoint.X);
   TopLeftPoint.Y:=Math.Min(CropClass.SecondPoint.Y,CropClass.FirstPoint.Y);
   RightBottomPoint.Y:=Math.Max(CropClass.SecondPoint.Y,CropClass.FirstPoint.Y);
   InImage := PtInRect(Rect(TopLeftPoint.X-de,TopLeftPoint.Y-de,RightBottomPoint.X+de,RightBottomPoint.Y+de),ImagePoint);
   CropClass.xTop:=(Abs(ImagePoint.Y-TopLeftPoint.Y)<=de) and InImage;
   CropClass.xLeft:=(Abs(ImagePoint.X-TopLeftPoint.X)<=de) and InImage;
   CropClass.xRight:=(Abs(ImagePoint.X-RightBottomPoint.X)<=de) and InImage;
   CropClass.xBottom:=(Abs(ImagePoint.Y-RightBottomPoint.Y)<=de) and InImage;
   CropClass.xCenter:=PtInRect(Rect(TopLeftPoint.X+de,TopLeftPoint.Y+de,RightBottomPoint.X-de,RightBottomPoint.Y-de),ImagePoint);
   CropClass.BeginDragPoint:=ImagePoint;
   CropClass.BeginFirstPoint:=CropClass.FirstPoint;
   CropClass.BeginSecondPoint:=CropClass.SecondPoint;
   if CropClass.xTop or CropClass.xLeft or CropClass.xRight or CropClass.xBottom or CropClass.xCenter then
   CropClass.ResizingRect:=true;
   if CropClass.ResizingRect then
   begin
   end else
   begin
    CropClass.FirstPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    CropClass.SecondPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    CropClass.MakingRect:=True;
   end;
  end;

  ToolRedEye, ToolText, ToolInsertImage:
  begin
   CustomSelectToolClass:=(ToolClass as TCustomSelectToolClass);
   ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
   De:=Round(5/GetZoom);
   TopLeftPoint.X:=Math.Min(CustomSelectToolClass.SecondPoint.X,CustomSelectToolClass.FirstPoint.X);
   RightBottomPoint.X:=Math.Max(CustomSelectToolClass.SecondPoint.X,CustomSelectToolClass.FirstPoint.X);
   TopLeftPoint.Y:=Math.Min(CustomSelectToolClass.SecondPoint.Y,CustomSelectToolClass.FirstPoint.Y);
   RightBottomPoint.Y:=Math.Max(CustomSelectToolClass.SecondPoint.Y,CustomSelectToolClass.FirstPoint.Y);

   InImage := PtInRect(Rect(TopLeftPoint.X-de,TopLeftPoint.Y-de,RightBottomPoint.X+de,RightBottomPoint.Y+de),ImagePoint);

   CustomSelectToolClass.xTop:=(Abs(ImagePoint.Y-TopLeftPoint.Y)<=De) and InImage;
   CustomSelectToolClass.xLeft:=(Abs(ImagePoint.X-TopLeftPoint.X)<=De) and InImage;
   CustomSelectToolClass.xRight:=(Abs(ImagePoint.X-RightBottomPoint.X)<=De) and InImage;
   CustomSelectToolClass.xBottom:=(Abs(ImagePoint.Y-RightBottomPoint.Y)<=De) and InImage;
   CustomSelectToolClass.xCenter:=PtInRect(Rect(TopLeftPoint.X+de,TopLeftPoint.Y+de,RightBottomPoint.X-de,RightBottomPoint.Y-de),ImagePoint);
   CustomSelectToolClass.BeginDragPoint:=ImagePoint;
   CustomSelectToolClass.BeginFirstPoint:=CustomSelectToolClass.FirstPoint;
   CustomSelectToolClass.BeginSecondPoint:=CustomSelectToolClass.SecondPoint;
   if CustomSelectToolClass.xTop or CustomSelectToolClass.xLeft or CustomSelectToolClass.xRight or CustomSelectToolClass.xBottom or CustomSelectToolClass.xCenter then
   CustomSelectToolClass.ResizingRect:=true;
   if CustomSelectToolClass.ResizingRect then
   begin
   end else
   begin
    CustomSelectToolClass.FirstPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    CustomSelectToolClass.SecondPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    CustomSelectToolClass.MakingRect:=True;
   end;
  end;

  ToolBrush:
  begin
   BrushClass :=(ToolClass as TBrushToolClass);
   ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
   BrushClass.SetBeginPoint(ImagePoint);
  end;

 end;
 MakeImageAndPaint;
end;

procedure TImageEditor.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  CropClass : TCropToolPanelClass;
  CustomSelectToolClass : TCustomSelectToolClass;
  BrushClass : TBrushToolClass;
  P, ImagePoint, TopLeftPoint, RightBottomPoint, p1,p2,p11,p22 : TPoint;
  De, w,h, i, ax,ay, ry : integer;
  Col : TColor;
  Prop : Extended;
  InImage : boolean;

  function Znak(x : Extended) : Extended;
  begin
   if x>=0 then Result:=1 else Result:=-1;
  end;

begin

 Case Tool of
  ToolNone : exit;

  ToolCrop :
  begin
   CropClass:=(ToolClass as TCropToolPanelClass);
   if CropClass.MakingRect then
   begin
    ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    p.X:=math.Min(CurrentImage.Width,math.max(0,ImagePoint.X));
    p.Y:=math.Min(CurrentImage.Height,math.max(0,ImagePoint.Y));
    if CropClass.KeepProportions then
    begin
     w:=-(CropClass.FirstPoint.X-p.X);
     h:=-(CropClass.FirstPoint.Y-p.Y);
     if w*h=0 then exit;
     if CropClass.ProportionsHeight<>0 then
     Prop:=CropClass.ProportionsWidth/CropClass.ProportionsHeight else
     Prop:=1;
     if abs(w/h)<abs(Prop) then
     begin
      if w<0 then w:=-Round(abs(h)*(Prop)) else
      w:=Round(abs(h)*(Prop));
      if CropClass.FirstPoint.X+w>CurrentImage.Width then
      begin
       w:=CurrentImage.Width-CropClass.FirstPoint.X;
       h:=Round(Znak(h)*w/prop);
      end;
      if CropClass.FirstPoint.X+w<0 then
      begin
       w:=-CropClass.FirstPoint.X;
       h:=-Round(Znak(h)*w/prop);
      end;

      CropClass.SecondPoint:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end else
     begin
      if h<0 then h:=-Round(abs(w)*(1/Prop)) else
      h:=Round(abs(w)*(1/Prop));
      if CropClass.FirstPoint.Y+h>CurrentImage.height then
      begin
       h:=CurrentImage.height-CropClass.FirstPoint.Y;
       w:=Round(Znak(w)*(h*Prop));
      end;
      if CropClass.FirstPoint.Y+h<0 then
      begin
       h:=-CropClass.FirstPoint.Y;
       w:=-Round(Znak(w)*(h*Prop));
      end;

      CropClass.SecondPoint:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end;
    end else
    begin
     CropClass.SecondPoint:=p;
    end;
    MakeImageAndPaint;
   end else
   begin
    ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    ImagePoint.X:=math.Min(CurrentImage.Width,math.max(0,ImagePoint.X));
    ImagePoint.Y:=math.Min(CurrentImage.Height,math.max(0,ImagePoint.Y));

    P:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    p.X:=math.Min(CurrentImage.Width,math.max(1,p.X));
    p.Y:=math.Min(CurrentImage.Height,math.max(1,p.Y));
    if CropClass.KeepProportions then
    begin
     w:=-(CropClass.FirstPoint.X-p.X);
     h:=-(CropClass.FirstPoint.Y-p.Y);
     if w*h=0 then exit;
     if CropClass.ProportionsHeight<>0 then
     Prop:=CropClass.ProportionsWidth/CropClass.ProportionsHeight else
     Prop:=1;
     if h=0 then exit;
     if Prop=0 then exit;
     if abs(w/h)>abs(Prop) then
     begin
      if w<0 then w:=-Round(abs(h)*(Prop)) else
      w:=Round(abs(h)*(Prop));
      P:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end else
     begin
      if h<0 then h:=-Round(abs(w)*(1/Prop)) else
      h:=Round(abs(w)*(1/Prop));
      P:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end;
    end else
    begin
     P:=p;
    end;





    Cursor:=CUR_CROP;
    De:=Max(1,Round(5/GetZoom));
    if CropClass.ResizingRect then
    begin
     if CropClass.ResizingRect then
     begin
      if CropClass.xCenter then
      begin
       w:=ImagePoint.X-CropClass.BeginDragPoint.X;
       h:=ImagePoint.Y-CropClass.BeginDragPoint.Y;
       w:=Math.max(w,Math.max(-CropClass.BeginFirstPoint.X,-CropClass.BeginSecondPoint.X));
       h:=Math.max(h,Math.max(-CropClass.BeginFirstPoint.Y,-CropClass.BeginSecondPoint.Y));
       w:=Math.Min(w,CurrentImage.Width-Math.max(CropClass.BeginFirstPoint.X,CropClass.BeginSecondPoint.X));
       h:=Math.Min(h,CurrentImage.Height-Math.max(CropClass.BeginFirstPoint.Y,CropClass.BeginSecondPoint.Y));
       CropClass.FirstPoint:=Point(CropClass.BeginFirstPoint.X+w,CropClass.BeginFirstPoint.Y+h);
       CropClass.SecondPoint:=Point(CropClass.BeginSecondPoint.X+w,CropClass.BeginSecondPoint.Y+h);
      end;
      
      if not CropClass.KeepProportions then
      begin

      if CropClass.xLeft and not CropClass.xRight then
      begin
       if CropClass.FirstPoint.X>CropClass.SecondPoint.X then
       CropClass.SecondPoint:=Point(ImagePoint.X,CropClass.SecondPoint.Y) else
       CropClass.FirstPoint:=Point(ImagePoint.X,CropClass.FirstPoint.Y);
      end;
      if CropClass.xTop and not CropClass.xBottom then
      begin
       if CropClass.FirstPoint.Y>CropClass.SecondPoint.Y then
       CropClass.SecondPoint:=Point(CropClass.SecondPoint.X,ImagePoint.Y) else
       CropClass.FirstPoint:=Point(CropClass.FirstPoint.X,ImagePoint.Y);
      end;
      if CropClass.xRight then
      begin
       if CropClass.FirstPoint.X<CropClass.SecondPoint.X then
       CropClass.SecondPoint:=Point(ImagePoint.X,CropClass.SecondPoint.Y) else
       CropClass.FirstPoint:=Point(ImagePoint.X,CropClass.FirstPoint.Y);
      end;
      if CropClass.xBottom then
      begin
       if CropClass.FirstPoint.Y<CropClass.SecondPoint.Y then
       CropClass.SecondPoint:=Point(CropClass.SecondPoint.X,ImagePoint.Y) else
       CropClass.FirstPoint:=Point(CropClass.FirstPoint.X,ImagePoint.Y);
      end;

      end else
      begin

      if CropClass.ProportionsHeight<>0 then
      Prop:=CropClass.ProportionsWidth/CropClass.ProportionsHeight else
      Prop:=1;

      p1:=Point(Math.Min(CropClass.FirstPoint.X,CropClass.SecondPoint.X),Math.Min(CropClass.FirstPoint.Y,CropClass.SecondPoint.Y));
      p2:=Point(Math.Max(CropClass.FirstPoint.X,CropClass.SecondPoint.X),Math.Max(CropClass.FirstPoint.Y,CropClass.SecondPoint.Y));

      if CropClass.xLeft and not CropClass.xTop and not CropClass.xRight then
      begin
       p11:=Point(ImagePoint.X,P1.Y);
       p22:=Point(P2.X,P11.Y+Round((P2.X-P11.X)/Prop));
       if p22.Y>CurrentImage.Height then
       begin
        p22:=Point(P2.X,CurrentImage.Height);
        p11:=Point(P2.X-Round((CurrentImage.Height-P11.Y)*Prop),P1.Y);
       end;
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      if CropClass.xTop and not CropClass.xLeft and not CropClass.xBottom then
      begin
       p11:=Point(P1.X,ImagePoint.Y);
       p22:=Point(P11.X+Round((P2.Y-P11.Y)*Prop),P2.Y);
       if p22.X>CurrentImage.Width then
       begin
        p22:=Point(CurrentImage.Width,P2.Y);
        p11:=Point(P1.X,P2.Y-Round((CurrentImage.Width-P1.X)/Prop));
       end;
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      if CropClass.xTop and CropClass.xLeft and not CropClass.xBottom then
      begin
       w:=abs(P2.X-ImagePoint.X);
       h:=abs(P2.Y-ImagePoint.Y);
       if abs(w/h)>abs(Prop) then
       begin
        p11:=Point(ImagePoint.X,P2.Y-Round((P2.X-ImagePoint.X)/prop));
       end else
       begin
        p11:=Point(P2.X-Round((P2.Y-ImagePoint.Y)*prop),ImagePoint.Y);
       end;
       if P11.X<0 then
       begin
        P11:=Point(0,P2.Y-Round(P2.X/Prop))
       end;
       if P11.Y<0 then
       begin
        P11:=Point(P2.X-Round(P2.Y*Prop),0)
       end;

       p22:=Point(P2.X,P2.Y);
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      if CropClass.xRight and not CropClass.xBottom then
      begin
       p22:=Point(ImagePoint.X,P2.Y);
       p11:=Point(P1.X,P22.Y-Round((P22.X-P1.X)/Prop));
       if p11.Y<0 then
       begin
        p22:=Point(P1.X+Round(P2.Y*Prop),P2.Y);
        p11:=Point(P1.X,0);
       end;
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      if CropClass.xBottom and not CropClass.xRight then
      begin
       p22:=Point(P2.X,ImagePoint.Y);
       p11:=Point(P22.X-Round((P22.Y-P1.Y)*Prop),P1.Y);
       if p11.X<0 then
       begin
        p22:=Point(P2.X,P1.Y+Round(P2.X/Prop));
        p11:=Point(0,P1.Y);
       end;
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      if CropClass.xBottom and CropClass.xRight then
      begin
       w:=abs(P1.X-ImagePoint.X);
       h:=abs(P1.Y-ImagePoint.Y);
       if abs(w/h)>abs(Prop) then
       begin
        p22:=Point(ImagePoint.X,P1.Y-Round((P1.X-ImagePoint.X)/prop));
       end else
       begin
        p22:=Point(P1.X-Round((P1.Y-ImagePoint.Y)*prop),ImagePoint.Y);
       end;

       if P22.X>CurrentImage.Width then
       begin
        P22:=Point(CurrentImage.Width,P1.Y+Round((CurrentImage.Width-P1.X)/Prop))
       end;
       if P22.Y>CurrentImage.Height then
       begin
        P22:=Point(P1.X+Round((CurrentImage.Height-P1.Y)*Prop),CurrentImage.Height)
       end;

       p11:=Point(P1.X,P1.Y);
       CropClass.FirstPoint:=p11;
       CropClass.SecondPoint:=p22;
      end;

      end;
      MakeImageAndPaint;
     end;
    end else
    begin
     ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
     P.X:=math.Min(CurrentImage.Width,math.max(0,ImagePoint.X));
     P.Y:=math.Min(CurrentImage.Height,math.max(0,ImagePoint.Y));
     if (ImagePoint.X<>P.X) or (ImagePoint.Y<>P.Y) then
     begin
      Cursor:=CrDefault;
      exit;
     end;
     TopLeftPoint.X:=Math.Min(CropClass.SecondPoint.X,CropClass.FirstPoint.X);
     RightBottomPoint.X:=Math.Max(CropClass.SecondPoint.X,CropClass.FirstPoint.X);
     TopLeftPoint.Y:=Math.Min(CropClass.SecondPoint.Y,CropClass.FirstPoint.Y);
     RightBottomPoint.Y:=Math.Max(CropClass.SecondPoint.Y,CropClass.FirstPoint.Y);
     InImage := PtInRect(Rect(TopLeftPoint.X-de,TopLeftPoint.Y-de,RightBottomPoint.X+de,RightBottomPoint.Y+de),ImagePoint);
     CropClass.xTop:=(Abs(ImagePoint.Y-TopLeftPoint.Y)<=de) and InImage;
     CropClass.xLeft:=(Abs(ImagePoint.X-TopLeftPoint.X)<=de) and InImage;
     CropClass.xRight:=(Abs(ImagePoint.X-RightBottomPoint.X)<=de) and InImage;
     CropClass.xBottom:=(Abs(ImagePoint.Y-RightBottomPoint.Y)<=de) and InImage;
     CropClass.xCenter:=PtInRect(Rect(TopLeftPoint.X+de,TopLeftPoint.Y+de,RightBottomPoint.X-de,RightBottomPoint.Y-de),ImagePoint);
     CropClass.BeginDragPoint:=ImagePoint;
     CropClass.BeginFirstPoint:=CropClass.FirstPoint;
     CropClass.BeginSecondPoint:=CropClass.SecondPoint;
     if (CropClass.xTop and CropClass.xLeft) or (CropClass.xRight and CropClass.xBottom) then
     begin
      Cursor:=CUR_TOPRIGHT;
     end;
     if Cursor=CUR_CROP then
     if (CropClass.xBottom and CropClass.xLeft) or (CropClass.xRight and CropClass.xTop) then
     begin
      Cursor:=CUR_RIGHTBOTTOM;
     end;
     if Cursor=CUR_CROP then
     if CropClass.xRight or CropClass.xLeft then
     begin
      Cursor:=CUR_LEFTRIGHT;
     end;
     if Cursor=CUR_CROP then
     if CropClass.xTop or CropClass.xBottom then
     begin
      Cursor:=CUR_UPDOWN;
     end;
     if Cursor=CUR_CROP then
     begin
      if CropClass.xCenter then
      begin
       Cursor:=CUR_HAND;
      end;
     end;
    end;
   end;
  end;

  ToolRedEye, ToolText, ToolInsertImage:
  begin
   CustomSelectToolClass:=(ToolClass as TCustomSelectToolClass);
   if CustomSelectToolClass.MakingRect then
   begin
    CustomSelectToolClass.SecondPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    MakeImageAndPaint;
   end else
   begin
    ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    Cursor:=CrDefault;
    De:=Round(5/GetZoom);
    if CustomSelectToolClass.ResizingRect then
    begin
     if CustomSelectToolClass.ResizingRect then
     begin
      if CustomSelectToolClass.xCenter then
      begin
       CustomSelectToolClass.FirstPoint:=Point(CustomSelectToolClass.BeginFirstPoint.X+ImagePoint.X-CustomSelectToolClass.BeginDragPoint.X,CustomSelectToolClass.BeginFirstPoint.Y+ImagePoint.Y-CustomSelectToolClass.BeginDragPoint.Y);
       CustomSelectToolClass.SecondPoint:=Point(CustomSelectToolClass.BeginSecondPoint.X+ImagePoint.X-CustomSelectToolClass.BeginDragPoint.X,CustomSelectToolClass.BeginSecondPoint.Y+ImagePoint.Y-CustomSelectToolClass.BeginDragPoint.Y);
      end;
      if CustomSelectToolClass.xLeft then
      begin
       if CustomSelectToolClass.FirstPoint.X>CustomSelectToolClass.SecondPoint.X then
       CustomSelectToolClass.SecondPoint:=Point(ImagePoint.X,CustomSelectToolClass.SecondPoint.Y) else
       CustomSelectToolClass.FirstPoint:=Point(ImagePoint.X,CustomSelectToolClass.FirstPoint.Y);
      end;
      if CustomSelectToolClass.xTop then
      begin
       if CustomSelectToolClass.FirstPoint.Y>CustomSelectToolClass.SecondPoint.Y then
       CustomSelectToolClass.SecondPoint:=Point(CustomSelectToolClass.SecondPoint.X,ImagePoint.Y) else
       CustomSelectToolClass.FirstPoint:=Point(CustomSelectToolClass.FirstPoint.X,ImagePoint.Y);
      end;
      if CustomSelectToolClass.xRight then
      begin
       if CustomSelectToolClass.FirstPoint.X<CustomSelectToolClass.SecondPoint.X then
       CustomSelectToolClass.SecondPoint:=Point(ImagePoint.X,CustomSelectToolClass.SecondPoint.Y) else
       CustomSelectToolClass.FirstPoint:=Point(ImagePoint.X,CustomSelectToolClass.FirstPoint.Y);
      end;
      if CustomSelectToolClass.xBottom then
      begin
       if CustomSelectToolClass.FirstPoint.Y<CustomSelectToolClass.SecondPoint.Y then
       CustomSelectToolClass.SecondPoint:=Point(CustomSelectToolClass.SecondPoint.X,ImagePoint.Y) else
       CustomSelectToolClass.FirstPoint:=Point(CustomSelectToolClass.FirstPoint.X,ImagePoint.Y);
      end;
      MakeImageAndPaint;
     end;
    end else
    begin
     TopLeftPoint.X:=Math.Min(CustomSelectToolClass.SecondPoint.X,CustomSelectToolClass.FirstPoint.X);
     RightBottomPoint.X:=Math.Max(CustomSelectToolClass.SecondPoint.X,CustomSelectToolClass.FirstPoint.X);
     TopLeftPoint.Y:=Math.Min(CustomSelectToolClass.SecondPoint.Y,CustomSelectToolClass.FirstPoint.Y);
     RightBottomPoint.Y:=Math.Max(CustomSelectToolClass.SecondPoint.Y,CustomSelectToolClass.FirstPoint.Y);

     InImage := PtInRect(Rect(TopLeftPoint.X-de,TopLeftPoint.Y-de,RightBottomPoint.X+de,RightBottomPoint.Y+de),ImagePoint);

     CustomSelectToolClass.xTop:=(Abs(ImagePoint.Y-TopLeftPoint.Y)<=de) and InImage;
     CustomSelectToolClass.xLeft:=(Abs(ImagePoint.X-TopLeftPoint.X)<=de) and InImage;
     CustomSelectToolClass.xRight:=(Abs(ImagePoint.X-RightBottomPoint.X)<=de) and InImage;
     CustomSelectToolClass.xBottom:=(Abs(ImagePoint.Y-RightBottomPoint.Y)<=de) and InImage;
     CustomSelectToolClass.xCenter:=PtInRect(Rect(TopLeftPoint.X+de,TopLeftPoint.Y+de,RightBottomPoint.X-de,RightBottomPoint.Y-de),ImagePoint);
     CustomSelectToolClass.BeginDragPoint:=ImagePoint;
     CustomSelectToolClass.BeginFirstPoint:=CustomSelectToolClass.FirstPoint;
     CustomSelectToolClass.BeginSecondPoint:=CustomSelectToolClass.SecondPoint;
     if (CustomSelectToolClass.xTop and CustomSelectToolClass.xLeft) or (CustomSelectToolClass.xRight and CustomSelectToolClass.xBottom) then
     begin
      Cursor:=CUR_TOPRIGHT;
     end;
     if Cursor=CrDefault then
     if (CustomSelectToolClass.xBottom and CustomSelectToolClass.xLeft) or (CustomSelectToolClass.xRight and CustomSelectToolClass.xTop) then
     begin
      Cursor:=CUR_RIGHTBOTTOM;
     end;
     if Cursor=CrDefault then
     if CustomSelectToolClass.xRight or CustomSelectToolClass.xLeft then
     begin
      Cursor:=CUR_LEFTRIGHT;
     end;
     if Cursor=CrDefault then
     if CustomSelectToolClass.xTop or CustomSelectToolClass.xBottom then
     begin
      Cursor:=CUR_UPDOWN;
     end;
     if Cursor=CrDefault then
     begin
      if CustomSelectToolClass.xCenter then
      begin
       Cursor:=CUR_HAND;
      end;
     end;
    end;
   end;
  end;


  ToolBrush:
  begin
   BrushClass :=(ToolClass as TBrushToolClass);
   ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
   BrushClass.SetNextPoint(ImagePoint);
   if not VirtualBrushCursor then
   Cursor:=67 else
   begin
    Cursor:=CrCross;
    ry:=ButtomPanel.Height;
    w:=Buffer.Width;
    h:=Buffer.Height;
    for i:=0 to Length(VBrush)-1 do
    begin
     ax:=OldBrushPos.X+VBrush[i].X;
     ay:=OldBrushPos.Y+VBrush[i].Y-ry;
     if (ax>=0) and (ay>=0) and (ax<w) and (ay<h) then
     Col:=RGB(PBuffer[ay,ax].r,PBuffer[ay,ax].g,PBuffer[ay,ax].b) else Col:=0;
     SetPixel(Canvas.Handle,OldBrushPos.X+VBrush[i].X,OldBrushPos.Y+VBrush[i].Y, Col);
    end;

    for i:=0 to Length(VBrush)-1 do
    begin
     ax:=OldBrushPos.X+VBrush[i].X;
     ay:=OldBrushPos.Y+VBrush[i].Y-ry;
     if (ax>=0) and (ay>=0) and (ax<w) and (ay<h) then
     Col:=RGB(PBuffer[ay,ax].r,PBuffer[ay,ax].g,PBuffer[ay,ax].b) else Col:=0;
     SetPixel(Canvas.Handle,X+VBrush[i].X,Y+VBrush[i].Y, Col xor $FFFFFF);
    end;

    OldBrushPos:=Point(X,Y);
   end;
  end;

 end;
end;

procedure TImageEditor.MakeImageAndPaint;
begin
 MakeImage;
 FormPaint(self);
end;

procedure TImageEditor.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CropClass : TCropToolPanelClass;
  CustomSelectToolClass : TCustomSelectToolClass;
  BrushClass : TBrushToolClass;
  P : TPoint;
  w,h : integer;
  Prop : extended;

  function Znak(x : Extended) : Extended;
  begin
   if x>=0 then Result:=1 else Result:=-1;
  end;

begin
 if mbLeft<>Button then exit;
 Case Tool of
  ToolNone : exit;
  ToolCrop :
  begin
   CropClass:=(ToolClass as TCropToolPanelClass);
   if CropClass.MakingRect then
   begin
    P:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
    P.X:=math.Min(CurrentImage.Width,math.max(0,P.X));
    P.Y:=math.Min(CurrentImage.Height,math.max(0,P.Y));

    if CropClass.KeepProportions then
    begin
     w:=-(CropClass.FirstPoint.X-p.X);
     h:=-(CropClass.FirstPoint.Y-p.Y);
     if w*h=0 then exit;
     if CropClass.ProportionsHeight<>0 then
     Prop:=CropClass.ProportionsWidth/CropClass.ProportionsHeight else
     Prop:=1;
     if abs(w/h)<abs(Prop) then
     begin
      if w<0 then w:=-Round(abs(h)*(Prop)) else
      w:=Round(abs(h)*(Prop));
      if CropClass.FirstPoint.X+w>CurrentImage.Width then
      begin
       w:=CurrentImage.Width-CropClass.FirstPoint.X;
       h:=Round(Znak(h)*w/prop);
      end;
      if CropClass.FirstPoint.X+w<0 then
      begin
       w:=-CropClass.FirstPoint.X;
       h:=-Round(Znak(h)*w/prop);
      end;

      CropClass.SecondPoint:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end else
     begin
      if h<0 then h:=-Round(abs(w)*(1/Prop)) else
      h:=Round(abs(w)*(1/Prop));
      if CropClass.FirstPoint.Y+h>CurrentImage.height then
      begin
       h:=CurrentImage.height-CropClass.FirstPoint.Y;
       w:=Round(Znak(w)*(h*Prop));
      end;
      if CropClass.FirstPoint.Y+h<0 then
      begin
       h:=-CropClass.FirstPoint.Y;
       w:=-Round(Znak(w)*(h*Prop));
      end;

      CropClass.SecondPoint:=Point(CropClass.FirstPoint.X+w,CropClass.FirstPoint.Y+h);
     end;
    end else
    begin
     CropClass.SecondPoint:=p;
    end;
   end;

   CropClass.ResizingRect:=false;
   CropClass.MakingRect:=false;
  end;

  ToolRedEye, ToolText, ToolInsertImage :
  begin
   CustomSelectToolClass:=(ToolClass as TCustomSelectToolClass);
   if CustomSelectToolClass.MakingRect then
   begin
    CustomSelectToolClass.SecondPoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
   end;
   CustomSelectToolClass.ResizingRect:=false;
   CustomSelectToolClass.MakingRect:=false;
  end;

  ToolBrush:
  begin
   BrushClass :=(ToolClass as TBrushToolClass);
//   ImagePoint:=BufferPointToImagePoint(Point(X,Y-ButtomPanel.Height));
   BrushClass.SetEndPoint(Point(0,0));
  end;

 end;
end;

procedure TImageEditor.FormDestroy(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 DBkernel.UnRegisterForm(self);
 FormManager.UnRegisterMainForm(Self);
 ActionForm.Release;
 if UseFreeAfterRelease then ActionForm.Free;
 {$ENDIF}
 SaveWindowPos1.SavePosition;
 CurrentImage.Free;
 Buffer.Free;
 ImageHistory.Free;
end;

procedure TImageEditor.ZoomOutLinkClick(Sender: TObject);
begin
 if not ZoomerOn then
 begin
  Zoom:=GetZoom;
  ZoomerOn:=true;
 end;
 Zoom:=Zoom/1.2;
 if Zoom<0.01 then Zoom:=0.01;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.FitToSizeLinkClick(Sender: TObject);
begin
 ZoomerOn:=False;
 MakeImageAndPaint;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.RecteareImageProc(Sender: TObject);
begin
 MakeImageAndPaint;
 ReAllignScrolls(false,Point(0,0));
// MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.SetPointerToNewImage(Image: TBitmap);
begin
 if TempImage then
 begin
  Temp.free;
  Temp:=nil;
  TempImage:=false;
 end;
 Pointer(CurrentImage):=Pointer(Image);
 MakePCurrentImage;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.RotateLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolRotate;
 ToolSelectPanel.Hide;
 ToolClass:=TRotateToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

procedure TImageEditor.CancelTemporaryImage(Destroy: Boolean);
begin
 if not TempImage then exit;
 TempImage:=false;
 if Destroy then
 if CurrentImage<>nil then CurrentImage.Free;
 Pointer(CurrentImage):=Pointer(Temp);
 MakePCurrentImage;
 Temp:=nil;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.SetTemporaryImage(Image: TBitmap);
begin
 if not TempImage then
 begin
  Pointer(Temp):=Pointer(CurrentImage);
  Pointer(CurrentImage):=Pointer(Image);
 end else
 begin
  CurrentImage.free;
  Pointer(CurrentImage):=Pointer(Image);
 end;
 MakePCurrentImage;
 if Visible then
 begin
  ReAllignScrolls(false,Point(0,0));
  MakeImageAndPaint;
  MakeCaption;
 end;
 TempImage:=true;
end;

procedure TImageEditor.HistoryChanged(Sender: TObject; Action : THistoryAction);
var
  aAction : string;
begin
//
 aAction:=ImageHistory.Actions[ImageHistory.fposition];
 TActionsForm(ActionForm).AddAction(aAction,Action);

 FSaved:=false;
 UndoLink.Enabled:=ImageHistory.CanBack;
 UndoLink.Invalidate;
 RedoLink.Enabled:=ImageHistory.CanForward;
 RedoLink.Invalidate;
end;

procedure TImageEditor.MakeCaption;
begin
 Caption:=ImageEditorProductName+'  "'+ExtractFileName(CurrentFileName)+format('"  [%dx%d px.]',[CurrentImage.Width,CurrentImage.Height])+format('  %d%% ',[Round(GetZoom*100)]);
end;

function TImageEditor.GetZoom: Extended;
var
//  ImRect : TRect;
  fw, fh : integer;
begin
 if ZoomerOn then Result:=Zoom else
 begin
  Result:=1;
  if (CurrentImage.Height=0) or (CurrentImage.width=0) then exit;
  if (Buffer.Height=0) or (Buffer.width=0) then exit;
  if (CurrentImage.Width>GetVisibleImageWidth) or (CurrentImage.Height>GetVisibleImageHeight) then
  begin
   if CurrentImage.Width/CurrentImage.Height<Buffer.Width/Buffer.Height then
   begin
    fh:=Buffer.Height;
    fw:=round(Buffer.Height*(CurrentImage.width/CurrentImage.Height));
   end else begin
    fw:=Buffer.width;
    fh:=round(Buffer.width*(CurrentImage.Height/CurrentImage.width));
   end;
  end else begin
   fh:=CurrentImage.Height;
   fw:=CurrentImage.Width;
  end;
  Result:=min(fw/CurrentImage.Width,fh/CurrentImage.Height);
 end;
end;

procedure TImageEditor.ResizeLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolResize;
 ToolSelectPanel.Hide;
 ToolClass:=TResizeToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 (ToolClass as TResizeToolPanelClass).ChangeSize(Sender);
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

procedure TImageEditor.UndoLinkClick(Sender: TObject);
var
  Image : TBitmap;
begin
 if not ImageHistory.CanBack then exit;
 Image:=TBitmap.Create;
 Image.Assign(ImageHistory.DoBack);
// HistoryChanged(Self);
 CurrentImage.Free;
 SetPointerToNewImage(Image);
end;

procedure TImageEditor.RedoLinkClick(Sender: TObject);
var
  Image : TBitmap;
begin
 if not ImageHistory.CanForward then exit;
 Image:=TBitmap.Create;
 Image.Assign(ImageHistory.DoForward);
// HistoryChanged(Self);
 CurrentImage.Free;
 SetPointerToNewImage(Image);
end;

procedure TImageEditor.ZoomInLinkClick(Sender: TObject);
begin
 if not ZoomerOn then
 begin
  Zoom:=GetZoom;
  ZoomerOn:=true;
 end;
 Zoom:=Zoom*1.2;
 if Zoom>16 then Zoom:=16;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.EffectsLinkClick(Sender: TObject);
var
  BaseImage : TBitmap;
begin
 DisableHistory;
 Tool:=ToolEffects;
 ToolSelectPanel.Hide;
 ToolClass:=TEffectsToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 ToolClass.OnClosePanel:=ShowTools;
 BaseImage:=Tbitmap.Create;
 BaseImage.Assign(Image1.Picture.Graphic);
 (ToolClass as TEffectsToolPanelClass).SetBaseImage(BaseImage);
 (ToolClass as TEffectsToolPanelClass).FillEffects;
 BaseImage.Free;
 ToolClass.Show;
end;

procedure TImageEditor.ColorsLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolColor;
 ToolSelectPanel.Hide;
 ToolClass:=TColorToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;   
end;

procedure TImageEditor.RedEyeLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolRedEye;
 ToolSelectPanel.Hide;
 ToolClass:=TRedEyeToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 (ToolClass as TRedEyeToolPanelClass).ProcRecteateImage:=RecteareImageProc;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

procedure TImageEditor.SaveLinkClick(Sender: TObject);
var
  Image : TGraphic;
  Replace : Boolean;
  ext : string;
  {$IFDEF PHOTODB}
  ID : integer;
  cr : integer;
  to_size : integer;
  SavePictureDialog : DBSavePictureDialog;
  FileName : string;
  {$ENDIF}
begin
 SavePictureDialog:= DBSavePictureDialog.Create;
 SavePictureDialog.Filter:='JPEG Image File (*.jpg)|*.jpg|GIF Image (*.gif)|*.gif|Bitmaps (*.bmp)|*.bmp|PNG Files (*.png)|*.png|TIFF files (*.tiff)|*.tiff';
 SavePictureDialog.FilterIndex:=1;

 fSaved:=false;
 if ForseSave then SavePictureDialog.SetFileName(ForseSaveFileName) else
 SavePictureDialog.SetFileName(CurrentFileName);
 Replace:=false;
 if ForseSave or SavePictureDialog.Execute then
 begin
  if ForseSave then FileName:=ForseSaveFileName else
  FileName:=SavePictureDialog.FileName;
  if ForseSave then
  begin
   ext:=GetExt(ForseSaveFileName);
   if (ext<>'JPG') and (ext<>'JPEG') and (ext<>'JPE') and (ext<>'GIF') and (ext<>'BMP') then
   begin
    FileName:=ChangeFileExt(FileName,'.jpg');
    ext:='JPG';
   end;
   if (ext='JPG') or (ext='JPEG') or (ext='JPE') then
   begin
    SavePictureDialog.FilterIndex:=1;
   end else
   if (ext='GIF') then
   begin
    SavePictureDialog.FilterIndex:=2;
   end else
   if (ext='BMP') then
   begin
    SavePictureDialog.FilterIndex:=3;
   end else
   if (ext='PNG') then
   begin
    SavePictureDialog.FilterIndex:=4;
   end  else
   if (ext='TIFF') then
   begin
    SavePictureDialog.FilterIndex:=5;
   end else exit;
  end;
  ID:=0;
  Case SavePictureDialog.GetFilterIndex of
   1 :
    begin
     ID:=0;
     if (GetExt(FileName)<>'JPG') and (GetExt(FileName)<>'JPEG') then
     FileName:=FileName+'.jpg';
     if FileExists(FileName) then
     begin
      if not ForseSave then
      if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
      Replace:=true;
      {$IFDEF PHOTODB}
      ID:=GetIdByFileName(FileName);
      {$ENDIF}
     end;
     {$IFDEF PHOTODB}
      if DBKernel.ReadBool('','JPEGOptimizeMode',false) then
      begin
       if not ForseSave then SetJPEGOptions;
       to_size:=DBKernel.ReadInteger('','JPEGOptimizeSize',100)*1024;
       Image:=CompresJPEGToSize(CurrentImage,to_size,DBKernel.ReadBool('','JPEGProgressiveMode',false),cr);
      end else
      begin
       Image:=TJPEGImage.Create;
       Image.Assign(CurrentImage);
      end;

     {$ENDIF}

     {$IFNDEF PHOTODB}
     Image:=TJPEGImage.Create;
     Image.Assign(CurrentImage);
     {$ENDIF}

     (Image as TJPEGImage).ProgressiveEncoding:=true;
     {$IFNDEF PHOTODB}
     (Image as TJPEGImage).CompressionQuality:=75;
     {$ENDIF}
     {$IFDEF PHOTODB}
     if not DBKernel.ReadBool('','JPEGOptimizeMode',false) then
     begin
      if not ForseSave then SetJPEGOptions;
      (Image as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
      (Image as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
      (Image as TJPEGImage).ProgressiveDisplay:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
     end;
     {$ENDIF}
     try
      if EXIFSection<>nil then
      begin
       if EXIFSection.ExifObj<>nil then
       begin
        try
         EXIFSection.ExifObj.WriteThruInt('Orientation',1); //Normal orientation!!!
         EXIFSection.ExifObj.AdjExifSize(CurrentImage.Width,CurrentImage.Height);
        except
         MessageBoxDB(Handle, PChar(Format(TEXT_MES_CANT_MODIRY_EXIF_TO_FILE_F,[FileName])),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
        end;
       end;  
       try
        EXIFSection.WriteEXIFJpeg((Image as TJPEGImage),FileName);
       except
        MessageBoxDB(Handle, PChar(Format(TEXT_MES_CANT_WRITE_EXIF_TO_FILE_F,[FileName])),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
       end;
      end else
      begin
       Image.SaveToFile(FileName);
      end;
      fSaved:=true;
     except
      MessageBoxDB(Handle, PChar(Format(TEXT_MES_CANT_WRITE_TO_FILE_F,[FileName])),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
     Image.Free;
     {$IFDEF PHOTODB}
     if Replace then
     UpdateImageRecord(FileName,ID);
     {$ENDIF}
    end;
   2 :
    begin
    if (GetExt(FileName)<>'GIF') then
     FileName:=FileName+'.gif';
     if FileExists(FileName) then
     begin
      if not ForseSave then
      if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
      Replace:=true;
      {$IFDEF PHOTODB}
      ID:=GetIdByFileName(FileName);
      {$ENDIF}
     end;
     Image:=TGIFImage.Create;
     Image.Assign(CurrentImage);
     (Image as TGIFImage).OptimizeColorMap;
     try
      Image.SaveToFile(FileName);
      fSaved:=true;
     except
      MessageBoxDB(Handle,Format(TEXT_MES_CANT_WRITE_TO_FILE_F,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
     Image.Free;
     {$IFDEF PHOTODB}
     if Replace then
     UpdateImageRecord(FileName,ID);
     {$ENDIF}
    end;

    
   3 :
    begin
     if (GetExt(FileName)<>'BMP') then
     FileName:=FileName+'.bmp';
     if FileExists(FileName) then
     begin
      if not ForseSave then
      if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
      Replace:=true;
      {$IFDEF PHOTODB}
      ID:=GetIdByFileName(FileName);
      {$ENDIF}
     end;
     Image:=TBitmap.Create;
     Image.Assign(CurrentImage);
     try
      Image.SaveToFile(FileName);
      fSaved:=true;
     except
      MessageBoxDB(Handle,Format(TEXT_MES_CANT_WRITE_TO_FILE_F,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
     Image.Free;
     {$IFDEF PHOTODB}
     if Replace then
     UpdateImageRecord(FileName,ID);
     {$ENDIF}
    end;

   4 :
    begin
     if (GetExt(FileName)<>'PNG') then
     FileName:=FileName+'.png';
     if FileExists(FileName) then
     begin
      if not ForseSave then
      if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
      Replace:=true;
      {$IFDEF PHOTODB}
      ID:=GetIdByFileName(FileName);
      {$ENDIF}
     end;
     Image:=TPngGraphic.Create;
     Image.Assign(CurrentImage);
     try
      Image.SaveToFile(FileName);
      fSaved:=true;
     except
      MessageBoxDB(Handle,Format(TEXT_MES_CANT_WRITE_TO_FILE_F,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
     Image.Free;
     {$IFDEF PHOTODB}
     if Replace then
     UpdateImageRecord(FileName,ID);
     {$ENDIF}
    end;

   5 :
    begin
     if (GetExt(FileName)<>'TIFF') then
     FileName:=FileName+'.TIFF';
     if FileExists(FileName) then
     begin
      if not ForseSave then
      if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
      Replace:=true;
      {$IFDEF PHOTODB}
      ID:=GetIdByFileName(FileName);
      {$ENDIF}
     end;
     Image:=TTiffGraphic.Create;
     Image.Assign(CurrentImage);
     try
      Image.SaveToFile(FileName);
      fSaved:=true;
     except
      MessageBoxDB(Handle,Format(TEXT_MES_CANT_WRITE_TO_FILE_F,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
     end;
     Image.Free;
     {$IFDEF PHOTODB}
     if Replace then
     UpdateImageRecord(FileName,ID);
     {$ENDIF}
    end;


  end;
  {$IFDEF PHOTODB}
  if FilePassWord<>'' then
  GraphicCrypt.CryptGraphicFileV1(FileName,FilePassWord,0);
  {$ENDIF}
 end;  
 SavePictureDialog.Free;
end;

procedure TImageEditor.DisableHistory;
begin
 FStatusProgress.Max:=100;
 DropFileTarget1.Unregister;
 UndoLink.Enabled:=False;
 UndoLink.Invalidate;
 SaveLink.Enabled:=False;
 SaveLink.Invalidate;
 RedoLink.Enabled:=False;
 RedoLink.Invalidate;
end;

procedure TImageEditor.EnableHistory;
begin
 DropFileTarget1.Register(Self);
 UndoLink.Enabled:=ImageHistory.CanBack;
 UndoLink.Invalidate;
 SaveLink.Enabled:=true;
 SaveLink.Invalidate;
 RedoLink.Enabled:=ImageHistory.CanForward;
 RedoLink.Invalidate;
end;

procedure TImageEditor.FullSiseLinkClick(Sender: TObject);
begin
 if not ZoomerOn then
 begin
  Zoom:=GetZoom;
  ZoomerOn:=true;
 end;
 Zoom:=1;
 ReAllignScrolls(false,Point(0,0));
 MakeImageAndPaint;
 MakeCaption;
end;

procedure TImageEditor.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 EditorsManager.RemoveEditor(self);
 Release;
 if UseFreeAfterRelease then Free;
end;

procedure TImageEditor.SetCloseOnFailture(const Value: boolean);
begin
 FCloseOnFailture := Value;
end;

procedure TImageEditor.Exit1Click(Sender: TObject);
begin
 Close;
end;

procedure TImageEditor.Search1Click(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 With SearchManager.GetAnySearch do
 begin
  Show;
  SetFocus;
 end;
 {$ENDIF}
end;

procedure TImageEditor.Explorer1Click(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 With ExplorerManager.NewExplorer(False) do
 begin
  SetOldPath(CurrentFileName);
  SetPath(GetDirectory(CurrentFileName));
  Show;
  SetFocus;
 end;
 {$ENDIF}
end;

procedure TImageEditor.LoadLanguage;
begin
 ZoomOut1.Caption:=TEXT_MES_ZOOM_IN;
 ZoomIn1.Caption:=TEXT_MES_ZOOM_OUT;
 SaveLink.Text:=TEXT_MES_SAVE;       
 ZoomOutLink.Text:=TEXT_MES_ZOOM_IN;
 ZoomInLink.Text:=TEXT_MES_ZOOM_OUT;
 FullSiseLink.Text:=TEXT_MES_IM_REAL_SIZE;
 FitToSizeLink.Text:=TEXT_MES_IM_FIT_TO_SIZE;
 UndoLink.Text:=TEXT_MES_IM_UNDO;
 RedoLink.Text:=TEXT_MES_IM_REDO;
 OpenFileLink.Text:=TEXT_MES_OPEN;
 CropLink.Text:=TEXT_MES_CROP;
 RotateLink.Text:=TEXT_MES_ROTATE;
 ResizeLink.Text:=TEXT_MES_IM_RESIZE;
 EffectsLink.Text:=TEXT_MES_EFFECTS;
 ColorsLink.Text:=TEXT_MES_COLORS;
 RedEyeLink.Text:=TEXT_MES_RED_EYE;
 Search1.Caption:=TEXT_MES_SEARCHING;
 Explorer1.Caption:=TEXT_MES_EXPLORER;
 Properties1.Caption:=TEXT_MES_PROPERTIES;
 Exit1.Caption:=TEXT_MES_EXIT;
 Paste1.Caption:=TEXT_MES_PASTE;
 OpenFile1.Caption:=TEXT_MES_OPEN_FILE;
 FullScreen1.Caption:=TEXT_MES_FULL_SCREEN;
 Copy1.Caption:=TEXT_MES_COPY;
 Print1.Caption:=TEXT_MES_PRINT;
 BrushLink.Text:=TEXT_MES_BRUSH;
 InsertImageLink.Text:=TEXT_MES_INSERT_IMAGE;
 TextLink.Text:=TEXT_MES_TEXT;
 NewEditor1.Caption:=TEXT_MES_NEW_EDITOR;
 Actions1.Caption:=TEXT_MES_ACTIONS;
end;

procedure TImageEditor.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 {$IFDEF PHOTODB}
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
 {$ENDIF}
end;

procedure TImageEditor.Properties1Click(Sender: TObject);
{$IFDEF PHOTODB}
var
  PR : TImageDBRecordA;
{$ENDIF}
begin
 {$IFDEF PHOTODB}
 pr:=GetImageIDW(CurrentFileName,false);
 if pr.count<>0 then
 begin
  PropertyManager.NewIDProperty(pr.ids[0]).Execute(pr.ids[0]);
 end else
 begin
  if FileExists(CurrentFileName) then
  PropertyManager.NewFileProperty(CurrentFileName).ExecuteFileNoEx(CurrentFileName) else
  MessageBoxDB(Handle,TEXT_MES_VIRTUAL_FILE,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
 {$ENDIF}
end;

procedure TImageEditor.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  P1, P : TPoint;
  PIm : TRect;
begin
 GetCursorPos(P1);
 P:=ScreenToClient(P1);
 PIm:=rect(0,ButtomPanel.Height,ButtomPanel.Width-ToolSelectPanel.Width,ButtomPanel.Height+ToolSelectPanel.Height);
 if PtInRect(PIm,P) then
 PopupMenu1.Popup(P1.X,P1.Y);
end;

procedure TImageEditor.Paste1Click(Sender: TObject);
var
  B : TBitmap;
  Res : integer;
begin
 if Tool<>ToolNone then
 begin
  MessageBoxDB(Handle,TEXT_MES_CANT_OPEN_IMAGE_BECAUSE_EDITING,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  exit;
 end;
 if ImageHistory.CanBack then
 begin
  Res:=MessageBoxDB(Handle,TEXT_MES_IMAGE_CHANGED_SAVE_Q,TEXT_MES_WARNING,TD_BUTTON_YESNOCANCEL,TD_ICON_WARNING);
  if Res=ID_YES then
  begin
   SaveLinkClick(self);
   if not fSaved then exit;
  end;
  if Res=ID_CANCEL then exit;
  if Res=ID_NO then ;
 end;
 if ClipBoard.HasFormat(CF_BITMAP) then
 begin
  B := TBitmap.Create;
  B.Assign(ClipBoard);
  B.PixelFormat:=pf24bit;
  LoadBitmap(B);
  B.Free;
 end;
end;

procedure TImageEditor.LoadBitmap(Bitmap : TBitmap);
begin
 LoadBMPImage(Bitmap);
 ImageHistory.Clear;

 CurrentImage.PixelFormat:=pf24bit;
 ImageHistory.Add(CurrentImage,'');
 CurrentFileName:='';
 MakeCaption;
 MakeImage;
 FormPaint(self);
 FormResize(self);
 CropLink.Enabled:=True;
 RotateLink.Enabled:=True;
 ColorsLink.Enabled:=True;
 ResizeLink.Enabled:=True;
 EffectsLink.Enabled:=True;
 RedEyeLink.Enabled:=True;
 TextLink.Enabled:=True;
 BrushLink.Enabled:=True;
 InsertImageLink.Enabled:=True;
 SaveLink.Enabled:=True;
 CropLink.SetDefault;
 RotateLink.SetDefault;
 ColorsLink.SetDefault;
 ResizeLink.SetDefault;
 EffectsLink.SetDefault;
 RedEyeLink.SetDefault;
 TextLink.SetDefault;
 BrushLink.SetDefault;
 SaveLink.SetDefault;
 InsertImageLink.SetDefault;
end;

procedure TImageEditor.FormKeyPress(Sender: TObject; var Key: Char);
begin
{$IFDEF PHOTODB}
 if ((Key='V') or (Key='v')) and CtrlKeyDown then Paste1Click(Sender);
 if (Key=#10)  and CtrlKeyDown and Focused then FullScreen1Click(Sender);
 {$ENDIF}
end;

procedure TImageEditor.PopupMenu1Popup(Sender: TObject);
begin
 Paste1.Visible:=ClipBoard.HasFormat(CF_BITMAP);
end;

procedure TImageEditor.FullScreen1Click(Sender: TObject);
begin
{$IFDEF PHOTODB}
 Application.CreateForm(TEditorFullScreenForm,EditorFullScreenForm);
 EditorFullScreenForm.SetImage(CurrentImage);
 EditorFullScreenForm.CreateDrawImage;
 EditorFullScreenForm.Show;
{$ENDIF}
end;

function TImageEditor.GetCurrentImage: TBitmap;
begin
 Pointer(Result):=Pointer(CurrentImage);
end;

procedure TImageEditor.Copy1Click(Sender: TObject);
begin
 ClipBoard.Assign(CurrentImage);
end;

procedure TImageEditor.TextLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolText;
 ToolSelectPanel.Hide;
 ToolClass:=TextToolClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 (ToolClass as TCustomSelectToolClass).ProcRecteateImage:=RecteareImageProc;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

procedure TImageEditor.BrushLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolBrush;
 MakeTempLayer;
 ToolSelectPanel.Hide;
 ToolClass:=TBrushToolClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 (ToolClass as TBrushToolClass).FDrawlayer:=PTempLayer;
 (ToolClass as TBrushToolClass).ProcRecteateImage:=RecteareImageProc;
 (ToolClass as TBrushToolClass).SetOwner(self);
 (ToolClass as TBrushToolClass).Initialize;
 (ToolClass as TBrushToolClass).NewCursor;
 if not VirtualBrushCursor then
 Cursor:=67 else Cursor:=CrCross;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

procedure TImageEditor.Print1Click(Sender: TObject);
var
 Bitmap : TBitmap;
begin
{$IFDEF PHOTODB}
 Bitmap := TBitmap.Create;
 Bitmap.PixelFormat:=pf24bit;
 Bitmap.Assign(CurrentImage);
 GetPrintForm(Bitmap);
{$ENDIF}
end;

procedure TImageEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Result : integer;
begin
 if ForseSave then
 begin
  CanClose:=true;
  exit;
 end;
 if ImageHistory.CanBack and not fSaved then
 begin
  Result:=MessageBoxDB(Handle,TEXT_MES_IMAGE_CHANGED_SAVE_Q,TEXT_MES_WARNING,TD_BUTTON_YESNOCANCEL,TD_ICON_WARNING);
  if Result=ID_YES then
  begin
   SaveLinkClick(self);
   CanClose:=fSaved;
  end;
  if Result=ID_CANCEL then CanClose:=false;
  if Result=ID_NO then CanClose:=true;
 end;
end;

procedure TImageEditor.InsertImageLinkClick(Sender: TObject);
begin
 DisableHistory;
 Tool:=ToolInsertImage;
 ToolSelectPanel.Hide;
 ToolClass:=InsertImageToolPanelClass.Create(ToolsPanel);
 ToolClass.Editor:=Self;
 ToolClass.ImageHistory:=ImageHistory;
 ToolClass.SetTempImage:=SetTemporaryImage;
 ToolClass.CancelTempImage:=CancelTemporaryImage;
 ToolClass.Image:=CurrentImage;
 ToolClass.SetImagePointer:=SetPointerToNewImage;
 (ToolClass as TCustomSelectToolClass).ProcRecteateImage:=RecteareImageProc;
 ToolClass.OnClosePanel:=ShowTools;
 ToolClass.Show;
end;

{ TManagerEditors }

procedure TManagerEditors.AddEditor(Editor: TImageEditor);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FEditors)-1 do
 if FEditors[i]=Editor then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FEditors,Length(FEditors)+1);
  FEditors[Length(FEditors)-1]:=Editor;
 end;
end;

constructor TManagerEditors.Create;
begin
 SetLength(FEditors,0);
end;

destructor TManagerEditors.Destroy;
begin
 SetLength(FEditors,0);
 inherited;
end;

function TManagerEditors.EditorsCount: Integer;
begin
 Result:=Length(FEditors);
end;

function TManagerEditors.GetAnyEditor: TImageEditor;
begin
 if EditorsCount=0 then Result:=NewEditor else Result:=FEditors[0];
end;

function TManagerEditors.IsEditor(Editor: TForm): Boolean;
var
  i : Integer;
begin
 Result:=False;
 for i:=0 to Length(FEditors)-1 do
 if FEditors[i]=Editor then
 begin
  Result:=True;
  Break;
 end;
end;

function TManagerEditors.NewEditor: TImageEditor;
begin
 Application.CreateForm(TImageEditor,Result);
end;

procedure TManagerEditors.RemoveEditor(Editor: TImageEditor);
var
  i, j : integer;
begin
 For i:=0 to Length(FEditors)-1 do
 if FEditors[i]=Editor then
 begin
  For j:=i to Length(FEditors)-2 do
  FEditors[j]:=FEditors[j+1];
  SetLength(FEditors,Length(FEditors)-1);
  break;
 end;
end;

procedure TImageEditor.NewEditor1Click(Sender: TObject);
begin
 EditorsManager.NewEditor.Show;
end;

procedure TImageEditor.MakePCurrentImage;
var
  i : integer;
begin
 if CurrentImage.PixelFormat=pf24bit then
 begin
  SetLength(PCurrentImage,CurrentImage.Height);
  SetLength(PCurrentImage32,0);
  for i:=0 to CurrentImage.Height-1 do
  PCurrentImage[i]:=CurrentImage.ScanLine[i];
 end;
 if CurrentImage.PixelFormat=pf32bit then
 begin
  SetLength(PCurrentImage,0);
  SetLength(PCurrentImage32,CurrentImage.Height);
  for i:=0 to CurrentImage.Height-1 do
  PCurrentImage32[i]:=CurrentImage.ScanLine[i];
 end;
end;

procedure TImageEditor.DeleteTempLayer;
begin
 if TempLayer<>nil then
 TempLayer.Free;
 TempLayer:=nil;
end;

procedure TImageEditor.MakeTempLayer;
var
  i,j : integer;
begin
 TempLayer:=TBitmap.Create;
 TempLayer.PixelFormat:=pf32bit;
 TempLayer.Width:=CurrentImage.Width;
 TempLayer.Height:=CurrentImage.Height;
 SetLength(PTempLayer,TempLayer.Height);
 for i:=0 to TempLayer.Height-1 do
 PTempLayer[i]:=TempLayer.ScanLine[i];
 for i:=0 to TempLayer.Height-1 do
 begin
  for j:=0 to TempLayer.Width-1 do
  begin
   PTempLayer[i,j].r:=0;
   PTempLayer[i,j].g:=0;
   PTempLayer[i,j].b:=0;
   PTempLayer[i,j].l:=255;
  end;
 end;
end;

procedure TImageEditor.CMMOUSELEAVE(var Message: TWMNoParams);
var
  i, ry ,w ,h, ax, ay  : integer;
  Col : TColor;
begin
 ry:=ButtomPanel.Height;
 w:=Buffer.Width;
 h:=Buffer.Height;
 for i:=0 to Length(VBrush)-1 do
 begin
  ax:=OldBrushPos.X+VBrush[i].X;
  ay:=OldBrushPos.Y+VBrush[i].Y-ry;
  if (ax>=0) and (ay>=0) and (ax<w) and (ay<h) then
  Col:=RGB(PBuffer[ay,ax].r,PBuffer[ay,ax].g,PBuffer[ay,ax].b) else Col:=0;
  SetPixel(Canvas.Handle,OldBrushPos.X+VBrush[i].X,OldBrushPos.Y+VBrush[i].Y, Col);
 end;
end;

procedure TImageEditor.Actions1Click(Sender: TObject);
begin
 ActionForm.Show;
end;

procedure TImageEditor.ReadActions(Actions: TArStrings);
begin
 SetLength(EState,0);
 DisableControls(self);
 NewActions := Actions;
 NewActionsCounter := -1;
 ReadNextAction(nil);
end;

procedure TImageEditor.ReadNextAction(Sender: TObject);
var
  Action, ID, Filter_ID : string;
  BaseImage : TBitmap;

  procedure BaseConfigureTool;
  begin
   ToolClass.Editor:=Self;
   ToolClass.ImageHistory:=ImageHistory;
   ToolClass.SetTempImage:=SetTemporaryImage;
   ToolClass.CancelTempImage:=CancelTemporaryImage;
   ToolClass.Image:=CurrentImage;
   ToolClass.SetImagePointer:=SetPointerToNewImage;
   ToolClass.OnClosePanel:=nil;
  end;

begin
 ToolClass:=nil;

 inc(NewActionsCounter);
 if NewActionsCounter>Length(NewActions)-1 then
 begin
  EnableControls(self);
  if SaveAfterEndActions then
  SaveImageFile(SaveAfterEndActionsFileName);
  NewActionsCounter:=-1;
  exit;
 end;
 Action:=NewActions[NewActionsCounter];
 ID:=Copy(Action,2,38);
 Filter_ID:=Copy(Action,42,38);

 
 if ID='{59168903-29EE-48D0-9E2E-7F34C913B94A}' then begin ReadNextAction(Self); exit; end;
 if ID='{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}' then begin ReadNextAction(Self); exit; {CROP} end;
 if ID='{747B3EAF-6219-4A96-B974-ABEB1405914B}' then begin ToolClass:=TRotateToolPanelClass.Create(TempPanel); BaseConfigureTool; end;
 if ID='{29C59707-04DA-4194-9B53-6E39185CC71E}' then begin ToolClass:=TResizeToolPanelClass.Create(TempPanel); BaseConfigureTool; end;
 if ID='{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}' then
 begin
  ToolClass:=TEffectsToolPanelClass.Create(TempPanel);
  BaseConfigureTool;

  BaseImage:=TBitmap.Create;
  BaseImage.Assign(Image1.Picture.Graphic);
  (ToolClass as TEffectsToolPanelClass).SetBaseImage(BaseImage);
  BaseImage.Free;
  Filter_ID:=Copy(Action,42,Length(Action)-42);
  (ToolClass as TEffectsToolPanelClass).FillEffects(Filter_ID);

 end;
 if ID='{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}' then begin ToolClass:=TColorToolPanelClass.Create(TempPanel); BaseConfigureTool; end;
 if ToolClass<>nil then
 ToolClass.ExecuteProperties(Action,ReadNextAction) else ReadNextAction(Self);

end;

procedure TImageEditor.ReadActionsFile(FileName: string);
var
  aActions : TArStrings;
begin
 aActions:=LoadActionsFromfileA(FileName);
 ReadActions(aActions);
end;

procedure TImageEditor.SaveImageFile(FileName: string; AfterEnd : boolean = false);
begin
 if AfterEnd and (NewActionsCounter<>-1) then
 begin
  SaveAfterEndActions := true;
  SaveAfterEndActionsFileName:=FileName;
  exit;
 end;
 ForseSave:=true;
 ForseSaveFileName:=FileName;

 SaveLinkClick(nil);
 Close;
end;

initialization

EditorsManager := TManagerEditors.Create;

finalization

EditorsManager.Free;

end.
