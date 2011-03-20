unit ImEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WebLink, StdCtrls, ExtCtrls, ComCtrls, ExtDlgs, Jpeg, GIFImage, Math,
  DropSource, DropTarget, ToolsUnit, CropToolUnit, SaveWindowPos,
  ImageHistoryUnit, RotateToolUnit, ResizeToolUnit, Clipbrd,
  EffectsToolUnit, RedEyeToolUnit, ColorToolUnit, Spin, Menus,
  CustomSelectTool, TextToolUnit, BrushToolUnit, InsertImageToolUnit,
  GraphicsBaseTypes, UMemory, GraphicCrypt, Dolphin_DB, UnitPasswordForm, UnitJPEGOptions,
  ExplorerUnit, FormManegerUnit, UnitDBKernel, PropertyForm, Buttons,
  UnitCrypting, GraphicEx, GraphicsCool, UScript, UnitScripts, PngImage, TiffImageUnit,
  RAWImage, DragDrop, DragDropFile, UVistaFuncs, UnitDBDeclare, UnitDBFileDialogs,
  UnitDBCommonGraphics, UnitCDMappingSupport, uLogger,
  CCR.Exif, uEditorTypes, uShellIntegration, uRuntime, uSysUtils, uSearchTypes,
  uFileUtils, uDBUtils, uDBTypes, uDBFileTypes, uConstants, uSettings, uAssociations;

type
  TWindowEnableState = record
    Control: TControl;
    Enabled: Boolean;
  end;

  TWindowEnableStates = array of TWindowEnableState;

type
  TImageEditor = class(TImageEditorForm)
    ToolsPanel: TPanel;
    ButtomPanel: TPanel;
    ScrollBarH: TScrollBar;
    ScrollBarV: TScrollBar;
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
    SampleImage: TImage;
    RedEyeLink: TWebLink;
    SaveLink: TWebLink;
    FullSiseLink: TWebLink;
    DestroyTimer: TTimer;
    PmMain: TPopupMenu;
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
    procedure ScrollBarVChange(Sender: TObject);
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
    procedure ScrollBarHScroll(Sender: TObject; ScrollCode: TScrollCode;
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
    procedure PmMainPopup(Sender: TObject);
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
    procedure ReadActions(Actions : TStrings);
    procedure ReadNextAction(Sender: TObject);
    procedure ReadActionsFile(FileName : string);
    procedure SaveImageFile(FileName : string; AfterEnd : boolean = false);
  private
    { Private declarations }
    EXIFSection: TExifData;
    SaveAfterEndActions: Boolean;
    SaveAfterEndActionsFileName: string;
    ForseSave: Boolean;
    ForseSaveFileName: string;
    NewActions: TStrings;
    NewActionsCounter: Integer;
    OldBrushPos: TPoint;
    LockedImage: Boolean;
    CurrentImage, Buffer, Temp: TBitmap;
    PBuffer: PARGBArray;
    PCurrentImage: PARGBArray;
    PCurrentImage32: PARGB32Array;
    TempLayer: TBitmap;
    PTempLayer: PARGB32Array;
    Tool: TTool;
    ZoomerOn: Boolean;
    Zoom: Extended;
    TempImage: Boolean;
    ImageHistory: TBitmapHistory;
    CurrentFileName: string;
    FilePassWord: string;
    FCloseOnFailture: Boolean;
    FSaved: Boolean;
    EState: TWindowEnableStates;
    procedure SetCloseOnFailture(const Value: boolean);
    function CheckEditingMode : Boolean;
    procedure LoadLanguage;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
    function GetZoom : Extended; override;
  public
    { Public declarations }
    FScript: string;
    FScriptProc: string;
    ActionForm: TForm;
    FStatusProgress: TProgressBar;
    WindowID: TGUID;
    ToolClass: TToolsPanelClass;
    procedure MakeImage; override;
    procedure DoPaint; override;
    procedure CMMOUSELEAVE(var message: TWMNoParams); message CM_MOUSELEAVE;
    property CloseOnFailture: Boolean read FCloseOnFailture write SetCloseOnFailture;
  end;

  TManagerEditors = class(TObject)
  private
    FEditors: TList;
    function GetEditorByIndex(Index: Integer): TImageEditor;
  public
    constructor Create;
    destructor Destroy; override;
    function NewEditor: TImageEditor;
    procedure AddEditor(Editor: TImageEditor);
    procedure RemoveEditor(Editor: TImageEditor);
    function IsEditor(Editor: TForm): Boolean;
    function EditorsCount: Integer;
    function GetAnyEditor: TImageEditor;
    property Items[Index : Integer] : TImageEditor read GetEditorByIndex; default;
  end;

var
  EditorsManager : TManagerEditors;

const
  IMRELEASE = not DBInDebug;

  CUR_UPDOWN = 140;
  CUR_LEFTRIGHT = 141;
  CUR_TOPRIGHT = 142;
  CUR_RIGHTBOTTOM = 143;
  CUR_HAND = 144;
  CUR_CROP = 145;

  ImageEditorProductName = 'DBImage Editor v1.3';


implementation

uses UnitEditorFullScreenForm, PrintMainForm, UnitActionsForm;

{$R *.dfm}
{$R cursors.res}

procedure DisableControls(Window: TImageEditor);

  procedure ControlOff(Control: TWinControl);
  begin
    Control.Enabled := False;
    Control.Invalidate;
  end;

begin
  with Window do
  begin
    DropFileTarget1.Unregister;
    ControlOff(SaveLink);
    ControlOff(UndoLink);
    ControlOff(RedoLink);
    ControlOff(OpenFileLink);
    ControlOff(CropLink);
    ControlOff(RotateLink);
    ControlOff(ResizeLink);
    ControlOff(EffectsLink);
    ControlOff(ColorsLink);
    ControlOff(RedEyeLink);
    ControlOff(TextLink);
    ControlOff(BrushLink);
    ControlOff(InsertImageLink);
  end;
end;

procedure EnableControls(Window: TImageEditor);

  procedure ControlOn(Control: TWinControl);
  begin
    Control.Enabled := True;
    Control.Invalidate;
  end;

begin
  with Window do
  begin
    DropFileTarget1.register(Window);
    ControlOn(SaveLink);
    ControlOn(UndoLink);
    ControlOn(RedoLink);
    ControlOn(OpenFileLink);
    ControlOn(CropLink);
    ControlOn(RotateLink);
    ControlOn(ResizeLink);
    ControlOn(EffectsLink);
    ControlOn(ColorsLink);
    ControlOn(RedEyeLink);
    ControlOn(TextLink);
    ControlOn(BrushLink);
    ControlOn(InsertImageLink);
  end;
end;

procedure TImageEditor.FormCreate(Sender: TObject);
begin
  NewActions := TStringList.Create;
  EXIFSection := nil;
  NewActionsCounter := -1;
  FScript := '';
  SaveAfterEndActions := False;
  ForseSave := False;
  WindowID := GetGUID;
  ClearBrush(VBrush);
  ToolClass := nil;
  PTempLayer := nil;
  EditorsManager.AddEditor(Self);
  FCloseOnFailture := True;
  ImageHistory := TBitmapHistory.Create;
  ImageHistory.OnHistoryChange := HistoryChanged;
  CurrentImage := TBitmap.Create;
  CurrentImage.PixelFormat := Pf32bit;
  CurrentImage.Width := 0;
  CurrentImage.Height := 0;
  Buffer := TBitmap.Create;
  Buffer.PixelFormat := Pf24bit;
  Tool := ToolNone;
  FStatusProgress := CreateProgressBar(StatusBar1, 1);
  LockedImage := False;
  TempImage := False;
  Screen.Cursors[CUR_UPDOWN] := LoadCursor(HInstance, 'UPDOWN');
  Screen.Cursors[CUR_LEFTRIGHT] := LoadCursor(HInstance, 'LEFTRIGHT');
  Screen.Cursors[CUR_TOPRIGHT] := LoadCursor(HInstance, 'TOPLEFTBOTTOMRIGHT');
  Screen.Cursors[CUR_RIGHTBOTTOM] := LoadCursor(HInstance, 'TOPRIGHTLEFTBOTTOM');
  Screen.Cursors[CUR_HAND] := LoadCursor(HInstance, 'HAND');
  Screen.Cursors[CUR_CROP] := LoadCursor(HInstance, 'CROP');

  DropFileTarget1.register(Self);

  LoadLanguage;

  Application.CreateForm(TActionsForm, ActionForm);
  TActionsForm(ActionForm).SetParentForm(Self);
  TActionsForm(ActionForm).LoadIcons;

  ZoomerOn := False;
  Zoom := 0.5;
  SaveWindowPos1.SetPosition;

  VirtualBrushCursor := Settings.ReadBool('Editor', 'VirtualCursor', False);
  FormManager.RegisterMainForm(Self);
  PmMain.Images := DBKernel.ImageList;
  Exit1.ImageIndex := DB_IC_EXIT;
  Search1.ImageIndex := DB_IC_ADDTODB;
  Explorer1.ImageIndex := DB_IC_EXPLORER;
  Properties1.ImageIndex := DB_IC_PROPERTIES;
  ZoomOut1.ImageIndex := DB_IC_ZOOMIN;
  ZoomIn1.ImageIndex := DB_IC_ZOOMOUT;
  Paste1.ImageIndex := DB_IC_PASTE;
  Print1.ImageIndex := DB_IC_PRINTER;
  OpenFile1.ImageIndex := DB_IC_LOADFROMFILE;
  Copy1.ImageIndex := DB_IC_COPY;
  FullScreen1.ImageIndex := DB_IC_DESKTOP;
  NewEditor1.ImageIndex := DB_IC_IMEDITOR;
  Actions1.ImageIndex := DB_IC_NEW_SHELL;
end;

procedure TImageEditor.LoadProgramImageFormat(Pic: TPicture);
begin
  if Pic.Graphic is TJPEGImage then
  begin
    LoadJPEGImage(Pic.Graphic as TJPEGImage);
  end else if Pic.Graphic is TBitmap then
  begin
    LoadBMPImage(Pic.Graphic as TBitmap);
  end else if Pic.Graphic is TGIFImage then
  begin
    LoadGIFImage(Pic.Graphic as TGIFImage);
  end else
    LoadImageVariousformat(Pic.Graphic);
end;

procedure TImageEditor.OpenFile(Sender: TObject);
var
  OpenPictureDialog: DBOpenPictureDialog;
begin
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;

    if OpenPictureDialog.Execute then
      OpenFileName(OpenPictureDialog.FileName);
  finally
    F(OpenPictureDialog);
  end;
end;

procedure TImageEditor.DoPaint;
begin
  Canvas.Draw(0, ButtomPanel.Height, Buffer);
end;

procedure TImageEditor.FormPaint(Sender: TObject);
begin
  DoPaint;
end;

procedure TImageEditor.LoadBMPImage(Bitmap: TBitmap);
var
  I, J: Integer;
  P: PARGB;
begin
  StatusBar1.Panels[0].Text := L('Loading BMP format');
  StatusBar1.Repaint;
  StatusBar1.Refresh;

  FStatusProgress.Max := Bitmap.Height + Bitmap.Height div 2;
  FStatusProgress.Position := 0;
  FStatusProgress.Position := Bitmap.Height div 2;

  CurrentImage.Width := Bitmap.Width;
  CurrentImage.Height := Bitmap.Height;
  CurrentImage.PixelFormat := pf24bit;

  if Bitmap.PixelFormat = Pf24bit then
  begin
    MakePCurrentImage;
    for I := 0 to Bitmap.Height - 1 do
    begin
      P := Bitmap.ScanLine[I];
      for J := 0 to Bitmap.Width - 1 do
        PCurrentImage[I, J] := P[J];

      if I mod 50 = 0 then
        FStatusProgress.Position := I + Bitmap.Height div 2;
    end;
  end else
  begin
    CurrentImage.Assign(Bitmap);
    CurrentImage.PixelFormat := Pf24bit;
    MakePCurrentImage;
  end;

  FStatusProgress.Position := 0;
  StatusBar1.Panels[0].Text := '';
end;

procedure TImageEditor.LoadGIFImage(GIF: TGIFImage);
var
  I, J: Integer;
begin
  StatusBar1.Panels[0].Text := 'Loading GIF format';

   StatusBar1.Repaint;
   StatusBar1.Refresh;
   FStatusProgress.Max := GIF.Height * 2;
   FStatusProgress.Position := 0;
   CurrentImage.Width := GIF.Width;
   CurrentImage.Height := GIF.Height;
   FStatusProgress.Position := GIF.Height div 2;
   CurrentImage.Assign(GIF);
   FStatusProgress.Position := GIF.Height;
   CurrentImage.PixelFormat := Pf32bit;
   MakePCurrentImage;
   for I := 0 to GIF.Height - 1 do
   begin
     for J := 0 to GIF.Width - 1 do
     begin
       if GIF.Images[0].Transparent then
       begin
         if GIF.Images[0].Pixels[J, I] = GIF.Images[0].GraphicControlExtension.TransparentColorIndex then
           PCurrentImage32[I, J].L := 0
         else
           PCurrentImage32[I, J].L := 255;
       end else
         PCurrentImage32[I, J].L := 255;
     end;
     if I mod 50 = 0 then
       FStatusProgress.Position := I + GIF.Height;
   end;
   CurrentImage.PixelFormat := pf24bit;
   MakePCurrentImage;
   FStatusProgress.Position := 0;
   StatusBar1.Panels[0].Text := '';
end;

procedure TImageEditor.LoadJPEGImage(JPEG: TJPEGImage);
begin
  StatusBar1.Panels[0].Text := L('Loading JPEG format');
  StatusBar1.Repaint;
  StatusBar1.Refresh;
  FStatusProgress.Max := 2;
  FStatusProgress.Position := 0;
  CurrentImage.Assign(JPEG);
  FStatusProgress.Position := 1;
  CurrentImage.PixelFormat := pf24bit;
  MakePCurrentImage;
  FStatusProgress.Position := 0;
  StatusBar1.Panels[0].Text := '';
end;

procedure TImageEditor.LoadImageVariousformat(Image: TGraphic);
begin
  CurrentImage.Width := Image.Width;
  CurrentImage.Height := Image.Height;
  CurrentImage.Assign(Image);
  CurrentImage.PixelFormat := Pf24bit;
  MakePCurrentImage;
end;

procedure TImageEditor.MakeImage;
var
  I, J: Integer;
  Fh, Fw: Integer;
  Zx, Zy, Zw, Zh, X1, X2, Y1, Y2: Integer;
  ImRect, BeginRect: TRect;
  CropClass: TCropToolPanelClass;
  CustomSelectToolClass: TCustomSelectToolClass;
  Pt1, Pt2: TPoint;

begin
  if LockedImage then
    Exit;

  if (CurrentImage.Height = 0) or (CurrentImage.Width = 0) then
    Exit;

  if Tool <> ToolColor then
  begin
    for I := 0 to Buffer.Height - 1 do
    begin
      for J := 0 to Buffer.Width - 1 do
      begin
        PBuffer[I, J].R := 0;
        PBuffer[I, J].G := 0;
        PBuffer[I, J].B := 0;
      end;
    end;
  end;
  if (CurrentImage.Width > GetVisibleImageWidth) or (CurrentImage.Height > GetVisibleImageHeight) then
  begin
    if CurrentImage.Width / CurrentImage.Height < Buffer.Width / Buffer.Height then
    begin
      Fh := Buffer.Height;
      Fw := Round(Buffer.Height * (CurrentImage.Width / CurrentImage.Height));
    end else
    begin
      Fw := Buffer.Width;
      Fh := Round(Buffer.Width * (CurrentImage.Height / CurrentImage.Width));
    end;
  end else
  begin
    Fh := CurrentImage.Height;
    Fw := CurrentImage.Width;
  end;
  X1 := GetVisibleImageWidth div 2 - Fw div 2;
  Y1 := GetVisibleImageHeight div 2 - Fh div 2;
  X2 := X1 + Fw;
  Y2 := Y1 + Fh;
  ImRect := GetImageRectA;
  Zx := ImRect.Left;
  Zy := ImRect.Top;
  Zw := ImRect.Right - ImRect.Left;
  Zh := ImRect.Bottom - ImRect.Top;

  if ZoomerOn then
  begin
    ImRect := Rect(Round(ScrollBarH.Position / Zoom), Round((ScrollBarV.Position) / Zoom),
      Round((ScrollBarH.Position + Zw) / Zoom), Round((ScrollBarV.Position + Zh) / Zoom));
    BeginRect := GetImageRectA;
    SetStretchBltMode(Buffer.Canvas.Handle, 0);
    Buffer.Canvas.CopyMode := SRCCOPY;
    if Zoom <= 1 then
    begin
      StretchFast(Zx, Zy, Zw, Zh, Rect(Round(ScrollBarH.Position / Zoom), Round(ScrollBarV.Position / Zoom),
          Round((ScrollBarH.Position + Zw) / Zoom), Round((ScrollBarV.Position + Zh) / Zoom)), PCurrentImage,
        PBuffer);
    end else
      Buffer.Canvas.CopyRect(BeginRect, CurrentImage.Canvas, ImRect);
  end else
    Buffer.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), CurrentImage);

  if TempLayer <> nil then
    if Tool = ToolBrush then
    begin
      if ZoomerOn then
      begin
        StretchFastATransW(Zx, Zy, Zw, Zh, Rect(Round(ScrollBarH.Position / Zoom), Round(ScrollBarV.Position / Zoom),
            Round((ScrollBarH.Position + Zw) / Zoom), Round((ScrollBarV.Position + Zh) / Zoom)), PTempLayer, PBuffer,
          Transparency, (ToolClass as TBrushToolClass).MethodDrawChooser.ItemIndex);
      end else
      begin
        StretchFastATrans(X1, Y1, CurrentImage.Width, CurrentImage.Height, X2 - X1, Y2 - Y1, PTempLayer, PBuffer,
          Transparency, (ToolClass as TBrushToolClass).MethodDrawChooser.ItemIndex);
      end;
    end;

  case Tool of
    ToolNone:
      Exit;
    ToolCrop:
      begin
        CropClass := (ToolClass as TCropToolPanelClass);
        Pt1 := Point(ImagePointToBufferPoint(CropClass.FirstPoint).X, ImagePointToBufferPoint(CropClass.FirstPoint).Y);
        Pt2 := Point(ImagePointToBufferPoint(CropClass.SecondPoint).X,
          ImagePointToBufferPoint(CropClass.SecondPoint).Y);
        CropClass.DoCropToolToImage(Buffer, Rect(Pt1, Pt2));
      end;

    ToolRedEye, ToolText, ToolInsertImage:
      begin
        CustomSelectToolClass := (ToolClass as TCustomSelectToolClass);
        if not CustomSelectToolClass.Termnating then
        begin
          Pt1 := Point(ImagePointToBufferPoint(CustomSelectToolClass.FirstPoint).X,
            ImagePointToBufferPoint(CustomSelectToolClass.FirstPoint).Y);
          Pt2 := Point(ImagePointToBufferPoint(CustomSelectToolClass.SecondPoint).X,
            ImagePointToBufferPoint(CustomSelectToolClass.SecondPoint).Y);
          CustomSelectToolClass.DoEffect(Buffer, Rect(Pt1, Pt2), False);
          CustomSelectToolClass.DoBorder(Buffer, Rect(Pt1, Pt2));
        end;
      end;
  end;
end;

procedure TImageEditor.ScrollBarVChange(Sender: TObject);
begin
  MakeImage;
  FormPaint(Sender);
end;

procedure TImageEditor.FormResize(Sender: TObject);
var
  I: Integer;
begin
  Buffer.Width := Math.Max(1, GetVisibleImageWidth);
  Buffer.Height := Math.Max(1, GetVisibleImageHeight);
  SetLength(PBuffer, Buffer.Height);
  for I := 0 to Buffer.Height - 1 do
    PBuffer[I] := Buffer.ScanLine[I];

  ToolsPanel.Left := ClientWidth - ToolsPanel.Width;
  ToolsPanel.Height := ClientHeight - ButtomPanel.Height - StatusBar1.Height;
  ReAllignScrolls(False, Point(0, 0));
  MakeImage;
  FormPaint(Sender);
  MakeCaption;
  StatusBar1.Top := ClientHeight - StatusBar1.Height;
  StatusBar1.Width := ClientWidth;
end;

procedure TImageEditor.ReAllignScrolls(IsCenter : Boolean; CenterPoint : TPoint);
var
  Inc_: Integer;
  Pos, M, Ps: Integer;
  V1, V2: Boolean;
begin
  if Tool = ToolBrush then
    (ToolClass as TBrushToolClass).NewCursor;

  LockedImage := True;
  if not ZoomerOn then
  begin
    ScrollBarH.Width := 1;
    ScrollBarH.Position := 0;
    ScrollBarH.Visible := False;
    ScrollBarV.Position := 0;
    ScrollBarV.Visible := False;
    NullPanel.Visible := False;
    LockedImage := False;
    Exit;
  end;

  V1 := ScrollBarH.Visible;
  V2 := ScrollBarV.Visible;
  if not ScrollBarH.Visible and not ScrollBarV.Visible then
  begin
    ScrollBarH.Visible := CurrentImage.Width * Zoom > GetVisibleImageWidth;
    if ScrollBarH.Visible then
      Inc_ := ScrollBarH.Height
    else
      Inc_ := 0;
    ScrollBarV.Visible := CurrentImage.Height * Zoom > GetVisibleImageHeight - Inc_;
  end;

  begin
    if ScrollBarV.Visible then
      Inc_ := ScrollBarV.Width
    else
      Inc_ := 0;
    ScrollBarH.Visible := CurrentImage.Width * Zoom > GetVisibleImageWidth - Inc_;
    ScrollBarH.Width := GetVisibleImageWidth - Inc_;
    if ScrollBarH.Visible then
      Inc_ := ScrollBarH.Height
    else
      Inc_ := 0;
    ScrollBarH.Top := ClientHeight - Inc_ - StatusBar1.Height;
  end;
  begin
    if ScrollBarH.Visible then
      Inc_ := ScrollBarH.Height
    else
      Inc_ := 0;
    ScrollBarV.Visible := CurrentImage.Height * Zoom > GetVisibleImageHeight - Inc_;
    ScrollBarV.Height := GetVisibleImageHeight - Inc_;
    ScrollBarV.Left := GetVisibleImageWidth - ScrollBarV.Width;
  end;
  begin
    if ScrollBarV.Visible then
      Inc_ := ScrollBarV.Width
    else
      Inc_ := 0;
    ScrollBarH.Visible := CurrentImage.Width * Zoom > GetVisibleImageWidth - Inc_;
    ScrollBarH.Width := GetVisibleImageWidth - Inc_;
    if ScrollBarH.Visible then
      Inc_ := ScrollBarH.Height
    else
      Inc_ := 0;
    ScrollBarH.Top := ClientHeight - Inc_ - StatusBar1.Height;
  end;
  if not ScrollBarH.Visible then
    ScrollBarH.Position := 0;
  if not ScrollBarV.Visible then
    ScrollBarV.Position := 0;
  if ScrollBarH.Visible and not V1 then
  begin
    ScrollBarH.PageSize := 0;
    ScrollBarH.Position := 0;
    ScrollBarH.Max := 100;
    ScrollBarH.Position := 50;
  end;
  if ScrollBarV.Visible and not V2 then
  begin
    ScrollBarV.PageSize := 0;
    ScrollBarV.Position := 0;
    ScrollBarV.Max := 100;
    ScrollBarV.Position := 50;
  end;
  if ScrollBarH.Visible then
  begin
    if ScrollBarV.Visible then
      Inc_ := ScrollBarV.Width
    else
      Inc_ := 0;
    M := Round(CurrentImage.Width * Zoom);
    Ps := Buffer.Width - Inc_;
    if Ps > M then
      Ps := 0;
    if (ScrollBarH.Max <> ScrollBarH.PageSize) then
      Pos := Round(ScrollBarH.Position * ((M - Ps) / (ScrollBarH.Max - ScrollBarH.PageSize)))
    else
      Pos := ScrollBarH.Position;
    if M < ScrollBarH.PageSize then
      ScrollBarH.PageSize := Ps;
    ScrollBarH.Max := M;
    ScrollBarH.PageSize := Ps;
    ScrollBarH.LargeChange := Ps div 10;
    ScrollBarH.Position := Math.Min(ScrollBarH.Max, Pos);
  end;
  if ScrollBarV.Visible then
  begin
    if ScrollBarH.Visible then
      Inc_ := ScrollBarH.Height
    else
      Inc_ := 0;
    M := Round(CurrentImage.Height * Zoom);
    Ps := GetVisibleImageHeight - Inc_;
    if Ps > M then
      Ps := 0;
    if ScrollBarV.Max <> ScrollBarV.PageSize then
      Pos := Round(ScrollBarV.Position * ((M - Ps) / (ScrollBarV.Max - ScrollBarV.PageSize)))
    else
      Pos := ScrollBarV.Position;
    if M < ScrollBarV.PageSize then
      ScrollBarV.PageSize := Ps;
    ScrollBarV.Max := M;
    ScrollBarV.PageSize := Ps;
    ScrollBarV.LargeChange := Ps div 10;
    ScrollBarV.Position := Math.Min(ScrollBarV.Max, Pos);
  end;
  if ScrollBarH.Position > ScrollBarH.Max - ScrollBarH.PageSize then
    ScrollBarH.Position := ScrollBarH.Max - ScrollBarH.PageSize;
  if ScrollBarV.Position > ScrollBarV.Max - ScrollBarV.PageSize then
    ScrollBarV.Position := ScrollBarV.Max - ScrollBarV.PageSize;
  NullPanel.Visible := ScrollBarH.Visible and ScrollBarV.Visible;
  NullPanel.Width := ScrollBarV.Width;
  NullPanel.Height := ScrollBarH.Height;
  NullPanel.Top := ScrollBarH.Top;
  NullPanel.Left := ScrollBarV.Left;
  ToolsPanel.Realign;
  LockedImage := False;
end;

function TImageEditor.GetVisibleImageHeight: Integer;
begin
  Result := ClientHeight - ButtomPanel.Height - StatusBar1.Height;
end;

function TImageEditor.GetVisibleImageWidth: Integer;
begin
  Result := ClientWidth - ToolsPanel.Width;
end;

function TImageEditor.GetImageRectA: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if ScrollBarH.Visible then
  begin
    FX := 0;
  end else
  begin
    if ScrollBarV.Visible then
      Increment := ScrollBarV.Width
    else
      Increment := 0;
    FX := Max(0, Round(GetVisibleImageWidth / 2 - Increment - CurrentImage.Width * Zoom / 2));
  end;
  if ScrollBarV.Visible then
  begin
    FY := 0;
  end else
  begin
    if ScrollBarH.Visible then
      Increment := ScrollBarH.Height
    else
      Increment := 0;
    FY := Max(0, Round(GetVisibleImageHeight / 2 - Increment - CurrentImage.Height * Zoom / 2));
  end;
  if ScrollBarV.Visible then
    Increment := ScrollBarV.Width
  else
    Increment := 0;
  FW := Round(Min(GetVisibleImageWidth - Increment, CurrentImage.Width * Zoom));
  if ScrollBarH.Visible then
    Increment := ScrollBarH.Height
  else
    Increment := 0;
  FH := Round(Min(GetVisibleImageHeight - Increment, CurrentImage.Height * Zoom));
  FH := FH;
  Result := Rect(FX, FY, FW + FX, FH + FY);
end;

procedure TImageEditor.CropLinkClick(Sender: TObject);
var
  ToolObject : TCropToolPanelClass;
begin
  DisableHistory;
  Tool := ToolCrop;
  ToolObject := TCropToolPanelClass.Create(ToolsPanel);
  ToolClass := ToolObject;
  ToolSelectPanel.Hide;
  ToolObject.Editor := Self;
  ToolObject.ImageHistory := ImageHistory;
  ToolObject.ProcRecteateImage := RecteareImageProc;
  ToolObject.Image := CurrentImage;
  ToolObject.SetImagePointer := SetPointerToNewImage;
  ToolObject.OnClosePanel := ShowTools;
  ToolObject.FirstPoint := Point(CurrentImage.Width div 3, CurrentImage.Height div 3);
  ToolObject.SecondPoint := Point(CurrentImage.Width * 2 div 3, CurrentImage.Height * 2 div 3);
  MakeImage;
  FormPaint(Sender);
end;

procedure TImageEditor.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  if DropFileTarget1.Files.Count > 0 then
    OpenFileName(DropFileTarget1.Files[0]);
end;

function TImageEditor.OpenFileName(FileName: String): boolean;
var
  Pic: TPicture;
  PassWord: string;
  Res: Integer;

begin
  DoProcessPath(FileName);
  Result := False;

  if not CheckEditingMode then
    Exit;

  if ImageHistory.CanBack then
  begin
    Res := MessageBoxDB(Handle, L('Image was changed, save changes?'), L('Warning'), TD_BUTTON_YESNO, TD_ICON_WARNING);
    if Res = ID_YES then
    begin
      SaveLinkClick(Self);
      if not FSaved then
        Exit;
    end;
    if Res = ID_CANCEL then
      Exit;
    if Res = ID_NO then
      {do nothing};
  end;

  try
    Pic := TPicture.Create;
    try
      if ValidCryptGraphicFile(FileName) then
      begin
        PassWord := DBkernel.FindPasswordForCryptImageFile(FileName);
        if PassWord = '' then
          PassWord := GetImagePasswordFromUser(FileName);

        if PassWord <> '' then
        begin
          Pic.Graphic := DeCryptGraphicFile(FileName, PassWord, True);
          CurrentFileName := FileName;
          F(EXIFSection);
        end else
          Exit;

      end else
      begin
        if TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)) = TRAWImage then
        begin
          Pic.Graphic := TRAWImage.Create;
          // by default RAW is half-sized
          (Pic.Graphic as TRAWImage).LoadHalfSize := False;
          Pic.Graphic.LoadFromFile(FileName);
          CurrentFileName := FileName;
          F(EXIFSection);
        end else
        begin
          Pic.LoadFromFile(FileName);
          CurrentFileName := FileName;
        end;
      end;
      EXIFSection := TExifData.Create;
      EXIFSection.LoadFromGraphic(Pic.Graphic);
      FilePassWord := PassWord;
      (ActionForm as TActionsForm).Reset;
      LoadProgramImageFormat(pic);
    finally
      F(Pic);
    end;
  finally
    if CurrentFileName = '' then
      if FCloseOnFailture then
        Close;
  end;

  ImageHistory.Clear;
  CurrentImage.PixelFormat := pf24bit;
  MakePCurrentImage;
  ImageHistory.Add(CurrentImage, '{{59168903-29EE-48D0-9E2E-7F34C913B94A}}["' + FileName + '"]');
  CurrentFileName := FileName;
  MakeCaption;
  MakeImage;
  FormPaint(Self);
  FormResize(Self);
  CropLink.Enabled := True;
  RotateLink.Enabled := True;
  ColorsLink.Enabled := True;
  ResizeLink.Enabled := True;
  EffectsLink.Enabled := True;
  RedEyeLink.Enabled := True;
  TextLink.Enabled := True;
  BrushLink.Enabled := True;
  InsertImageLink.Enabled := True;
  SaveLink.Enabled := True;
  OpenFileLink.SetDefault;
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
  Result := True;
end;

procedure TImageEditor.ScrollBarHScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  NewValue : Integer;
begin
  NewValue := (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize;
  if ScrollPos > NewValue then
    ScrollPos := NewValue;
end;

function TImageEditor.BufferPointToImagePoint(P: TPoint): TPoint;
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
    if ScrollBarH.Visible then
      Result.X := Round((ScrollBarH.Position + P.X) / Zoom)
    else
      Result.X := Round((P.X - X1) / Zoom);
    if ScrollBarV.Visible then
      Result.Y := Round((ScrollBarV.Position + P.Y) / Zoom)
    else
      Result.Y := Round((P.Y - Y1) / Zoom);
  end else
  begin
    if (CurrentImage.Height = 0) or (CurrentImage.Width = 0) then
      Exit;
    if (CurrentImage.Width > GetVisibleImageWidth) or (CurrentImage.Height > GetVisibleImageHeight) then
    begin
      if CurrentImage.Width / CurrentImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (CurrentImage.Width / CurrentImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (CurrentImage.Height / CurrentImage.Width));
      end;
    end else
    begin
      Fh := CurrentImage.Height;
      Fw := CurrentImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if Fw <> 0 then
      Result.X := Round((P.X - X1) * (CurrentImage.Width / Fw));
    if Fh <> 0 then
      Result.Y := Round((P.Y - Y1) * (CurrentImage.Height / Fh));
  end;
end;

function TImageEditor.ImagePointToBufferPoint(P: TPoint): Tpoint;
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
    if ScrollBarH.Visible then
      Result.X := Round(P.X * Zoom - ScrollBarH.Position)
    else
      Result.X := Round((P.X * Zoom + X1));
    if ScrollBarV.Visible then
      Result.Y := Round(P.Y * Zoom - ScrollBarV.Position)
    else
      Result.Y := Round((P.Y * Zoom + Y1));
  end else
  begin
    if (CurrentImage.Height = 0) or (CurrentImage.Width = 0) then
      Exit;
    if (CurrentImage.Width > GetVisibleImageWidth) or (CurrentImage.Height > GetVisibleImageHeight) then
    begin
      if CurrentImage.Width / CurrentImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (CurrentImage.Width / CurrentImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (CurrentImage.Height / CurrentImage.Width));
      end;
    end else
    begin
      Fh := CurrentImage.Height;
      Fw := CurrentImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if CurrentImage.Width <> 0 then
      Result.X := Round(X1 + P.X * (Fw / CurrentImage.Width));
    if CurrentImage.Height <> 0 then
      Result.Y := Round(Y1 + P.Y * (Fh / CurrentImage.Height));
  end;
end;

procedure TImageEditor.ShowTools(Sender: TObject);
begin
  DeleteTempLayer;
  Tool := ToolNone;
  ToolSelectPanel.Show;
  F(ToolClass);
  Cursor := CrDefault;
  MakeImageAndPaint;
  ToolSelectPanel.Invalidate;
  EnableHistory;
  FStatusProgress.Position := 0;
end;

procedure TImageEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  AFScript: TScript;
  C: Integer;
begin
  if FScript <> '' then
    if ScriptsManager.ScriptExists(FScript) then
    begin
      AFScript := ScriptsManager.GetScriptByID(FScript);
      ExecuteScript(nil, AFScript, FScriptProc + '("' + FScript + '");', C, nil);
    end;
  try
    if ToolClass <> nil then
      ToolClass.ClosePanel;
  except
    on E: Exception do
      EventLog(':TImageEditor::FormClose() throw exception: ' + E.message);
  end;
  DestroyTimer.Enabled := True;
end;

procedure TImageEditor.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CropClass: TCropToolPanelClass;
  CustomSelectToolClass: TCustomSelectToolClass;
  BrushClass: TBrushToolClass;
  P, ImagePoint, TopLeftPoint, RightBottomPoint: TPoint;
  De: Integer;
  InImage: Boolean;
begin
  if MbLeft <> Button then
    Exit;

  case Tool of
    ToolNone:
      Exit;

  ToolCrop:
      begin
        CropClass := (ToolClass as TCropToolPanelClass);
        ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));

        P.X := Math.Min(CurrentImage.Width, Math.Max(0, ImagePoint.X));
        P.Y := Math.Min(CurrentImage.Height, Math.Max(0, ImagePoint.Y));
        if (ImagePoint.X <> P.X) or (ImagePoint.Y <> P.Y) then
        begin
          Cursor := CrDefault;
          Exit;
        end;

        ImagePoint.X := Math.Min(CurrentImage.Width, Math.Max(0, ImagePoint.X));
        ImagePoint.Y := Math.Min(CurrentImage.Height, Math.Max(0, ImagePoint.Y));

        De := Max(1, Round(5 / GetZoom));
        TopLeftPoint.X := Math.Min(CropClass.SecondPoint.X, CropClass.FirstPoint.X);
        RightBottomPoint.X := Math.Max(CropClass.SecondPoint.X, CropClass.FirstPoint.X);
        TopLeftPoint.Y := Math.Min(CropClass.SecondPoint.Y, CropClass.FirstPoint.Y);
        RightBottomPoint.Y := Math.Max(CropClass.SecondPoint.Y, CropClass.FirstPoint.Y);
        InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
            RightBottomPoint.Y + De), ImagePoint);
        CropClass.XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
        CropClass.XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
        CropClass.XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
        CropClass.XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
        CropClass.XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De, RightBottomPoint.X - De,
            RightBottomPoint.Y - De), ImagePoint);
        CropClass.BeginDragPoint := ImagePoint;
        CropClass.BeginFirstPoint := CropClass.FirstPoint;
        CropClass.BeginSecondPoint := CropClass.SecondPoint;
        if CropClass.XTop or CropClass.XLeft or CropClass.XRight or CropClass.XBottom or CropClass.XCenter then
          CropClass.ResizingRect := True;
        if not CropClass.ResizingRect then
        begin
          CropClass.FirstPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          CropClass.SecondPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          CropClass.MakingRect := True;
        end;
      end;

    ToolRedEye, ToolText, ToolInsertImage:
      begin
        CustomSelectToolClass := (ToolClass as TCustomSelectToolClass);
        ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
        De := Round(5 / GetZoom);
        TopLeftPoint.X := Math.Min(CustomSelectToolClass.SecondPoint.X, CustomSelectToolClass.FirstPoint.X);
        RightBottomPoint.X := Math.Max(CustomSelectToolClass.SecondPoint.X, CustomSelectToolClass.FirstPoint.X);
        TopLeftPoint.Y := Math.Min(CustomSelectToolClass.SecondPoint.Y, CustomSelectToolClass.FirstPoint.Y);
        RightBottomPoint.Y := Math.Max(CustomSelectToolClass.SecondPoint.Y, CustomSelectToolClass.FirstPoint.Y);

        InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
            RightBottomPoint.Y + De), ImagePoint);

        CustomSelectToolClass.XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
        CustomSelectToolClass.XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
        CustomSelectToolClass.XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
        CustomSelectToolClass.XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
        CustomSelectToolClass.XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De,
            RightBottomPoint.X - De, RightBottomPoint.Y - De), ImagePoint);
        CustomSelectToolClass.BeginDragPoint := ImagePoint;
        CustomSelectToolClass.BeginFirstPoint := CustomSelectToolClass.FirstPoint;
        CustomSelectToolClass.BeginSecondPoint := CustomSelectToolClass.SecondPoint;
        if CustomSelectToolClass.XTop or CustomSelectToolClass.XLeft or CustomSelectToolClass.XRight or
          CustomSelectToolClass.XBottom or CustomSelectToolClass.XCenter then
          CustomSelectToolClass.ResizingRect := True;
        if not CustomSelectToolClass.ResizingRect then
        begin
          CustomSelectToolClass.FirstPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          CustomSelectToolClass.SecondPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          CustomSelectToolClass.MakingRect := True;
        end;
      end;

    ToolBrush:
      begin
        BrushClass := (ToolClass as TBrushToolClass);
        ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
        BrushClass.SetBeginPoint(ImagePoint);
      end;

  end;
  MakeImageAndPaint;
end;

function Znak(X: Extended): Extended;
begin
  if X >= 0 then
    Result := 1
  else
    Result := -1;
end;

procedure TImageEditor.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  CropClass: TCropToolPanelClass;
  CustomSelectToolClass: TCustomSelectToolClass;
  BrushClass: TBrushToolClass;
  P, ImagePoint, TopLeftPoint, RightBottomPoint, P1, P2, P11, P22: TPoint;
  De, W, H, I, Ax, Ay, Ry: Integer;
  Col: TColor;
  Prop: Extended;
  InImage: Boolean;
begin

  case Tool of
    ToolNone:
      Exit;

    ToolCrop:
      begin
        CropClass := (ToolClass as TCropToolPanelClass);
        if CropClass.MakingRect then
        begin
          ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          P.X := Math.Min(CurrentImage.Width, Math.Max(0, ImagePoint.X));
          P.Y := Math.Min(CurrentImage.Height, Math.Max(0, ImagePoint.Y));
          if CropClass.KeepProportions then
          begin
            W := -(CropClass.FirstPoint.X - P.X);
            H := -(CropClass.FirstPoint.Y - P.Y);
            if W * H = 0 then
              Exit;
            if CropClass.ProportionsHeight <> 0 then
              Prop := CropClass.ProportionsWidth / CropClass.ProportionsHeight
            else
              Prop := 1;
            if Abs(W / H) < Abs(Prop) then
            begin
              if W < 0 then
                W := -Round(Abs(H) * (Prop))
              else
                W := Round(Abs(H) * (Prop));
              if CropClass.FirstPoint.X + W > CurrentImage.Width then
              begin
                W := CurrentImage.Width - CropClass.FirstPoint.X;
                H := Round(Znak(H) * W / Prop);
              end;
              if CropClass.FirstPoint.X + W < 0 then
              begin
                W := -CropClass.FirstPoint.X;
                H := -Round(Znak(H) * W / Prop);
              end;

              CropClass.SecondPoint := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end else
            begin
              if H < 0 then
                H := -Round(Abs(W) * (1 / Prop))
              else
                H := Round(Abs(W) * (1 / Prop));
              if CropClass.FirstPoint.Y + H > CurrentImage.Height then
              begin
                H := CurrentImage.Height - CropClass.FirstPoint.Y;
                W := Round(Znak(W) * (H * Prop));
              end;
              if CropClass.FirstPoint.Y + H < 0 then
              begin
                H := -CropClass.FirstPoint.Y;
                W := -Round(Znak(W) * (H * Prop));
              end;

              CropClass.SecondPoint := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end;
          end else
            CropClass.SecondPoint := P;

          MakeImageAndPaint;
        end else
        begin
          ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          ImagePoint.X := Math.Min(CurrentImage.Width, Math.Max(0, ImagePoint.X));
          ImagePoint.Y := Math.Min(CurrentImage.Height, Math.Max(0, ImagePoint.Y));

          P := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          P.X := Math.Min(CurrentImage.Width, Math.Max(1, P.X));
          P.Y := Math.Min(CurrentImage.Height, Math.Max(1, P.Y));
          if CropClass.KeepProportions then
          begin
            W := -(CropClass.FirstPoint.X - P.X);
            H := -(CropClass.FirstPoint.Y - P.Y);
            if W * H = 0 then
              Exit;
            if CropClass.ProportionsHeight <> 0 then
              Prop := CropClass.ProportionsWidth / CropClass.ProportionsHeight
            else
              Prop := 1;
            if H = 0 then
              Exit;
            if Prop = 0 then
              Exit;
            if Abs(W / H) > Abs(Prop) then
            begin
              if W < 0 then
                W := -Round(Abs(H) * (Prop))
              else
                W := Round(Abs(H) * (Prop));
              P := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end else
            begin
              if H < 0 then
                H := -Round(Abs(W) * (1 / Prop))
              else
                H := Round(Abs(W) * (1 / Prop));
              P := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end;
          end;

          Cursor := CUR_CROP;
          De := Max(1, Round(5 / GetZoom));
          if CropClass.ResizingRect then
          begin
            if CropClass.ResizingRect then
            begin
              if CropClass.XCenter then
              begin
                W := ImagePoint.X - CropClass.BeginDragPoint.X;
                H := ImagePoint.Y - CropClass.BeginDragPoint.Y;
                W := Math.Max(W, Math.Max(-CropClass.BeginFirstPoint.X, -CropClass.BeginSecondPoint.X));
                H := Math.Max(H, Math.Max(-CropClass.BeginFirstPoint.Y, -CropClass.BeginSecondPoint.Y));
                W := Math.Min(W, CurrentImage.Width - Math.Max(CropClass.BeginFirstPoint.X,
                    CropClass.BeginSecondPoint.X));
                H := Math.Min(H, CurrentImage.Height - Math.Max(CropClass.BeginFirstPoint.Y,
                    CropClass.BeginSecondPoint.Y));
                CropClass.FirstPoint := Point(CropClass.BeginFirstPoint.X + W, CropClass.BeginFirstPoint.Y + H);
                CropClass.SecondPoint := Point(CropClass.BeginSecondPoint.X + W, CropClass.BeginSecondPoint.Y + H);
              end;

              if not CropClass.KeepProportions then
              begin

                if CropClass.XLeft and not CropClass.XRight then
                begin
                  if CropClass.FirstPoint.X > CropClass.SecondPoint.X then
                    CropClass.SecondPoint := Point(ImagePoint.X, CropClass.SecondPoint.Y)
                  else
                    CropClass.FirstPoint := Point(ImagePoint.X, CropClass.FirstPoint.Y);
                end;
                if CropClass.XTop and not CropClass.XBottom then
                begin
                  if CropClass.FirstPoint.Y > CropClass.SecondPoint.Y then
                    CropClass.SecondPoint := Point(CropClass.SecondPoint.X, ImagePoint.Y)
                  else
                    CropClass.FirstPoint := Point(CropClass.FirstPoint.X, ImagePoint.Y);
                end;
                if CropClass.XRight then
                begin
                  if CropClass.FirstPoint.X < CropClass.SecondPoint.X then
                    CropClass.SecondPoint := Point(ImagePoint.X, CropClass.SecondPoint.Y)
                  else
                    CropClass.FirstPoint := Point(ImagePoint.X, CropClass.FirstPoint.Y);
                end;
                if CropClass.XBottom then
                begin
                  if CropClass.FirstPoint.Y < CropClass.SecondPoint.Y then
                    CropClass.SecondPoint := Point(CropClass.SecondPoint.X, ImagePoint.Y)
                  else
                    CropClass.FirstPoint := Point(CropClass.FirstPoint.X, ImagePoint.Y);
                end;

              end else
              begin

                if CropClass.ProportionsHeight <> 0 then
                  Prop := CropClass.ProportionsWidth / CropClass.ProportionsHeight
                else
                  Prop := 1;

                P1 := Point(Math.Min(CropClass.FirstPoint.X, CropClass.SecondPoint.X),
                  Math.Min(CropClass.FirstPoint.Y, CropClass.SecondPoint.Y));
                P2 := Point(Math.Max(CropClass.FirstPoint.X, CropClass.SecondPoint.X),
                  Math.Max(CropClass.FirstPoint.Y, CropClass.SecondPoint.Y));

                if CropClass.XLeft and not CropClass.XTop and not CropClass.XRight then
                begin
                  P11 := Point(ImagePoint.X, P1.Y);
                  P22 := Point(P2.X, P11.Y + Round((P2.X - P11.X) / Prop));
                  if P22.Y > CurrentImage.Height then
                  begin
                    P22 := Point(P2.X, CurrentImage.Height);
                    P11 := Point(P2.X - Round((CurrentImage.Height - P11.Y) * Prop), P1.Y);
                  end;
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

                if CropClass.XTop and not CropClass.XLeft and not CropClass.XBottom then
                begin
                  P11 := Point(P1.X, ImagePoint.Y);
                  P22 := Point(P11.X + Round((P2.Y - P11.Y) * Prop), P2.Y);
                  if P22.X > CurrentImage.Width then
                  begin
                    P22 := Point(CurrentImage.Width, P2.Y);
                    P11 := Point(P1.X, P2.Y - Round((CurrentImage.Width - P1.X) / Prop));
                  end;
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

                if CropClass.XTop and CropClass.XLeft and not CropClass.XBottom then
                begin
                  W := Abs(P2.X - ImagePoint.X);
                  H := Abs(P2.Y - ImagePoint.Y);
                  if Abs(W / H) > Abs(Prop) then
                    P11 := Point(ImagePoint.X, P2.Y - Round((P2.X - ImagePoint.X) / Prop))
                  else
                    P11 := Point(P2.X - Round((P2.Y - ImagePoint.Y) * Prop), ImagePoint.Y);

                  if P11.X < 0 then
                    P11 := Point(0, P2.Y - Round(P2.X / Prop));

                  if P11.Y < 0 then
                    P11 := Point(P2.X - Round(P2.Y * Prop), 0);

                  P22 := Point(P2.X, P2.Y);
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

                if CropClass.XRight and not CropClass.XBottom then
                begin
                  P22 := Point(ImagePoint.X, P2.Y);
                  P11 := Point(P1.X, P22.Y - Round((P22.X - P1.X) / Prop));
                  if P11.Y < 0 then
                  begin
                    P22 := Point(P1.X + Round(P2.Y * Prop), P2.Y);
                    P11 := Point(P1.X, 0);
                  end;
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

                if CropClass.XBottom and not CropClass.XRight then
                begin
                  P22 := Point(P2.X, ImagePoint.Y);
                  P11 := Point(P22.X - Round((P22.Y - P1.Y) * Prop), P1.Y);
                  if P11.X < 0 then
                  begin
                    P22 := Point(P2.X, P1.Y + Round(P2.X / Prop));
                    P11 := Point(0, P1.Y);
                  end;
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

                if CropClass.XBottom and CropClass.XRight then
                begin
                  W := Abs(P1.X - ImagePoint.X);
                  H := Abs(P1.Y - ImagePoint.Y);
                  if Abs(W / H) > Abs(Prop) then
                    P22 := Point(ImagePoint.X, P1.Y - Round((P1.X - ImagePoint.X) / Prop))
                  else
                    P22 := Point(P1.X - Round((P1.Y - ImagePoint.Y) * Prop), ImagePoint.Y);

                  if P22.X > CurrentImage.Width then
                    P22 := Point(CurrentImage.Width, P1.Y + Round((CurrentImage.Width - P1.X) / Prop));

                  if P22.Y > CurrentImage.Height then
                    P22 := Point(P1.X + Round((CurrentImage.Height - P1.Y) * Prop), CurrentImage.Height);

                  P11 := Point(P1.X, P1.Y);
                  CropClass.FirstPoint := P11;
                  CropClass.SecondPoint := P22;
                end;

              end;
              MakeImageAndPaint;
            end;
          end else
          begin
            ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
            P.X := Math.Min(CurrentImage.Width, Math.Max(0, ImagePoint.X));
            P.Y := Math.Min(CurrentImage.Height, Math.Max(0, ImagePoint.Y));
            if (ImagePoint.X <> P.X) or (ImagePoint.Y <> P.Y) then
            begin
              Cursor := CrDefault;
              Exit;
            end;
            TopLeftPoint.X := Math.Min(CropClass.SecondPoint.X, CropClass.FirstPoint.X);
            RightBottomPoint.X := Math.Max(CropClass.SecondPoint.X, CropClass.FirstPoint.X);
            TopLeftPoint.Y := Math.Min(CropClass.SecondPoint.Y, CropClass.FirstPoint.Y);
            RightBottomPoint.Y := Math.Max(CropClass.SecondPoint.Y, CropClass.FirstPoint.Y);
            InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
                RightBottomPoint.Y + De), ImagePoint);
            CropClass.XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
            CropClass.XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
            CropClass.XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
            CropClass.XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
            CropClass.XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De, RightBottomPoint.X - De,
                RightBottomPoint.Y - De), ImagePoint);
            CropClass.BeginDragPoint := ImagePoint;
            CropClass.BeginFirstPoint := CropClass.FirstPoint;
            CropClass.BeginSecondPoint := CropClass.SecondPoint;

            if (CropClass.XTop and CropClass.XLeft) or (CropClass.XRight and CropClass.XBottom) then
              Cursor := CUR_TOPRIGHT;

            if Cursor = CUR_CROP then
              if (CropClass.XBottom and CropClass.XLeft) or (CropClass.XRight and CropClass.XTop) then
                Cursor := CUR_RIGHTBOTTOM;

            if Cursor = CUR_CROP then
              if CropClass.XRight or CropClass.XLeft then
                Cursor := CUR_LEFTRIGHT;

            if Cursor = CUR_CROP then
              if CropClass.XTop or CropClass.XBottom then
                Cursor := CUR_UPDOWN;

            if (Cursor = CUR_CROP) and CropClass.XCenter then
              Cursor := CUR_HAND;

          end;
        end;
      end;

    ToolRedEye, ToolText, ToolInsertImage:
      begin
        CustomSelectToolClass := (ToolClass as TCustomSelectToolClass);
        if CustomSelectToolClass.MakingRect then
        begin
          CustomSelectToolClass.SecondPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          MakeImageAndPaint;
        end else
        begin
          ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          Cursor := CrDefault;
          De := Round(5 / GetZoom);
          if CustomSelectToolClass.ResizingRect then
          begin
            if CustomSelectToolClass.ResizingRect then
            begin
              if CustomSelectToolClass.XCenter then
              begin
                CustomSelectToolClass.FirstPoint := Point
                  (CustomSelectToolClass.BeginFirstPoint.X + ImagePoint.X - CustomSelectToolClass.BeginDragPoint.X,
                  CustomSelectToolClass.BeginFirstPoint.Y + ImagePoint.Y - CustomSelectToolClass.BeginDragPoint.Y);
                CustomSelectToolClass.SecondPoint := Point
                  (CustomSelectToolClass.BeginSecondPoint.X + ImagePoint.X - CustomSelectToolClass.BeginDragPoint.X,
                  CustomSelectToolClass.BeginSecondPoint.Y + ImagePoint.Y - CustomSelectToolClass.BeginDragPoint.Y);
              end;
              if CustomSelectToolClass.XLeft then
              begin
                if CustomSelectToolClass.FirstPoint.X > CustomSelectToolClass.SecondPoint.X then
                  CustomSelectToolClass.SecondPoint := Point(ImagePoint.X, CustomSelectToolClass.SecondPoint.Y)
                else
                  CustomSelectToolClass.FirstPoint := Point(ImagePoint.X, CustomSelectToolClass.FirstPoint.Y);
              end;
              if CustomSelectToolClass.XTop then
              begin
                if CustomSelectToolClass.FirstPoint.Y > CustomSelectToolClass.SecondPoint.Y then
                  CustomSelectToolClass.SecondPoint := Point(CustomSelectToolClass.SecondPoint.X, ImagePoint.Y)
                else
                  CustomSelectToolClass.FirstPoint := Point(CustomSelectToolClass.FirstPoint.X, ImagePoint.Y);
              end;
              if CustomSelectToolClass.XRight then
              begin
                if CustomSelectToolClass.FirstPoint.X < CustomSelectToolClass.SecondPoint.X then
                  CustomSelectToolClass.SecondPoint := Point(ImagePoint.X, CustomSelectToolClass.SecondPoint.Y)
                else
                  CustomSelectToolClass.FirstPoint := Point(ImagePoint.X, CustomSelectToolClass.FirstPoint.Y);
              end;
              if CustomSelectToolClass.XBottom then
              begin
                if CustomSelectToolClass.FirstPoint.Y < CustomSelectToolClass.SecondPoint.Y then
                  CustomSelectToolClass.SecondPoint := Point(CustomSelectToolClass.SecondPoint.X, ImagePoint.Y)
                else
                  CustomSelectToolClass.FirstPoint := Point(CustomSelectToolClass.FirstPoint.X, ImagePoint.Y);
              end;
              MakeImageAndPaint;
            end;
          end else
          begin
            TopLeftPoint.X := Math.Min(CustomSelectToolClass.SecondPoint.X, CustomSelectToolClass.FirstPoint.X);
            RightBottomPoint.X := Math.Max(CustomSelectToolClass.SecondPoint.X, CustomSelectToolClass.FirstPoint.X);
            TopLeftPoint.Y := Math.Min(CustomSelectToolClass.SecondPoint.Y, CustomSelectToolClass.FirstPoint.Y);
            RightBottomPoint.Y := Math.Max(CustomSelectToolClass.SecondPoint.Y, CustomSelectToolClass.FirstPoint.Y);

            InImage := PtInRect(Rect(TopLeftPoint.X - De, TopLeftPoint.Y - De, RightBottomPoint.X + De,
                RightBottomPoint.Y + De), ImagePoint);

            CustomSelectToolClass.XTop := (Abs(ImagePoint.Y - TopLeftPoint.Y) <= De) and InImage;
            CustomSelectToolClass.XLeft := (Abs(ImagePoint.X - TopLeftPoint.X) <= De) and InImage;
            CustomSelectToolClass.XRight := (Abs(ImagePoint.X - RightBottomPoint.X) <= De) and InImage;
            CustomSelectToolClass.XBottom := (Abs(ImagePoint.Y - RightBottomPoint.Y) <= De) and InImage;
            CustomSelectToolClass.XCenter := PtInRect(Rect(TopLeftPoint.X + De, TopLeftPoint.Y + De,
                RightBottomPoint.X - De, RightBottomPoint.Y - De), ImagePoint);
            CustomSelectToolClass.BeginDragPoint := ImagePoint;
            CustomSelectToolClass.BeginFirstPoint := CustomSelectToolClass.FirstPoint;
            CustomSelectToolClass.BeginSecondPoint := CustomSelectToolClass.SecondPoint;

            if (CustomSelectToolClass.XTop and CustomSelectToolClass.XLeft) or
              (CustomSelectToolClass.XRight and CustomSelectToolClass.XBottom) then
              Cursor := CUR_TOPRIGHT;

            if Cursor = CrDefault then
              if (CustomSelectToolClass.XBottom and CustomSelectToolClass.XLeft) or
                (CustomSelectToolClass.XRight and CustomSelectToolClass.XTop) then
                Cursor := CUR_RIGHTBOTTOM;

            if Cursor = CrDefault then
              if CustomSelectToolClass.XRight or CustomSelectToolClass.XLeft then
                Cursor := CUR_LEFTRIGHT;

            if Cursor = CrDefault then
              if CustomSelectToolClass.XTop or CustomSelectToolClass.XBottom then
                Cursor := CUR_UPDOWN;

            if (Cursor = CrDefault) and CustomSelectToolClass.XCenter then
                Cursor := CUR_HAND;
          end;
        end;
      end;

    ToolBrush:
      begin
        BrushClass := (ToolClass as TBrushToolClass);
        ImagePoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
        BrushClass.SetNextPoint(ImagePoint);
        if not VirtualBrushCursor then
          Cursor := 67
        else
        begin
          Cursor := CrCross;
          Ry := ButtomPanel.Height;
          W := Buffer.Width;
          H := Buffer.Height;
          for I := 0 to Length(VBrush) - 1 do
          begin
            Ax := OldBrushPos.X + VBrush[I].X;
            Ay := OldBrushPos.Y + VBrush[I].Y - Ry;
            if (Ax >= 0) and (Ay >= 0) and (Ax < W) and (Ay < H) then
              Col := RGB(PBuffer[Ay, Ax].R, PBuffer[Ay, Ax].G, PBuffer[Ay, Ax].B)
            else
              Col := 0;
            SetPixel(Canvas.Handle, OldBrushPos.X + VBrush[I].X, OldBrushPos.Y + VBrush[I].Y, Col);
          end;

          for I := 0 to Length(VBrush) - 1 do
          begin
            Ax := OldBrushPos.X + VBrush[I].X;
            Ay := OldBrushPos.Y + VBrush[I].Y - Ry;
            if (Ax >= 0) and (Ay >= 0) and (Ax < W) and (Ay < H) then
              Col := RGB(PBuffer[Ay, Ax].R, PBuffer[Ay, Ax].G, PBuffer[Ay, Ax].B)
            else
              Col := 0;
            SetPixel(Canvas.Handle, X + VBrush[I].X, Y + VBrush[I].Y, Col xor $FFFFFF);
          end;

          OldBrushPos := Point(X, Y);
        end;
      end;
  end;
end;

procedure TImageEditor.MakeImageAndPaint;
begin
  MakeImage;
  FormPaint(Self);
end;

procedure TImageEditor.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CropClass: TCropToolPanelClass;
  CustomSelectToolClass: TCustomSelectToolClass;
  BrushClass: TBrushToolClass;
  P: TPoint;
  W, H: Integer;
  Prop: Extended;

begin
  if MbLeft <> Button then
    Exit;

  case Tool of
    ToolNone:
      Exit;
    ToolCrop:
      begin
        CropClass := (ToolClass as TCropToolPanelClass);
        if CropClass.MakingRect then
        begin
          P := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));
          P.X := Math.Min(CurrentImage.Width, Math.Max(0, P.X));
          P.Y := Math.Min(CurrentImage.Height, Math.Max(0, P.Y));

          if CropClass.KeepProportions then
          begin
            W := -(CropClass.FirstPoint.X - P.X);
            H := -(CropClass.FirstPoint.Y - P.Y);
            if W * H = 0 then
              Exit;
            if CropClass.ProportionsHeight <> 0 then
              Prop := CropClass.ProportionsWidth / CropClass.ProportionsHeight
            else
              Prop := 1;
            if Abs(W / H) < Abs(Prop) then
            begin
              if W < 0 then
                W := -Round(Abs(H) * (Prop))
              else
                W := Round(Abs(H) * (Prop));
              if CropClass.FirstPoint.X + W > CurrentImage.Width then
              begin
                W := CurrentImage.Width - CropClass.FirstPoint.X;
                H := Round(Znak(H) * W / Prop);
              end;
              if CropClass.FirstPoint.X + W < 0 then
              begin
                W := -CropClass.FirstPoint.X;
                H := -Round(Znak(H) * W / Prop);
              end;

              CropClass.SecondPoint := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end else
            begin
              if H < 0 then
                H := -Round(Abs(W) * (1 / Prop))
              else
                H := Round(Abs(W) * (1 / Prop));
              if CropClass.FirstPoint.Y + H > CurrentImage.Height then
              begin
                H := CurrentImage.Height - CropClass.FirstPoint.Y;
                W := Round(Znak(W) * (H * Prop));
              end;
              if CropClass.FirstPoint.Y + H < 0 then
              begin
                H := -CropClass.FirstPoint.Y;
                W := -Round(Znak(W) * (H * Prop));
              end;

              CropClass.SecondPoint := Point(CropClass.FirstPoint.X + W, CropClass.FirstPoint.Y + H);
            end;
          end
          else
            CropClass.SecondPoint := P;
        end;

        CropClass.ResizingRect := False;
        CropClass.MakingRect := False;
      end;

    ToolRedEye, ToolText, ToolInsertImage:
      begin
        CustomSelectToolClass := (ToolClass as TCustomSelectToolClass);
        if CustomSelectToolClass.MakingRect then
          CustomSelectToolClass.SecondPoint := BufferPointToImagePoint(Point(X, Y - ButtomPanel.Height));

        CustomSelectToolClass.ResizingRect := False;
        CustomSelectToolClass.MakingRect := False;
      end;

    ToolBrush:
      begin
        BrushClass := (ToolClass as TBrushToolClass);
        BrushClass.SetEndPoint(Point(0, 0));
      end;

  end;
end;

procedure TImageEditor.FormDestroy(Sender: TObject);
begin
  FormManager.UnRegisterMainForm(Self);
  ActionForm.Release;
  SaveWindowPos1.SavePosition;
  F(CurrentImage);
  F(Buffer);
  F(ImageHistory);
  F(NewActions);
  F(EXIFSection);
end;

procedure TImageEditor.ZoomOutLinkClick(Sender: TObject);
begin
  if not ZoomerOn then
  begin
    Zoom := GetZoom;
    ZoomerOn := True;
  end;
  Zoom := Zoom / 1.2;
  if Zoom < 0.01 then
    Zoom := 0.01;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

procedure TImageEditor.FitToSizeLinkClick(Sender: TObject);
begin
  ZoomerOn := False;
  MakeImageAndPaint;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

procedure TImageEditor.RecteareImageProc(Sender: TObject);
begin
  MakeImageAndPaint;
  ReAllignScrolls(False, Point(0, 0));
  MakeCaption;
end;

procedure TImageEditor.SetPointerToNewImage(Image: TBitmap);
begin
  if TempImage then
  begin
    F(Temp);
    TempImage := False;
  end;
  CurrentImage := Image;
  MakePCurrentImage;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

procedure TImageEditor.RotateLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolRotate;
  ToolSelectPanel.Hide;
  ToolClass := TRotateToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.CancelTemporaryImage(Destroy: Boolean);
begin
  if not TempImage then
    Exit;
  TempImage := False;

  if Destroy then
    F(CurrentImage);
  CurrentImage := Temp;
  Temp := nil;
  MakePCurrentImage;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

function TImageEditor.CheckEditingMode: Boolean;
begin
  Result := Tool = ToolNone;
  if not Result then
    MessageBoxDB(Handle, L('Unable to open the image as you edit another image.'), L('Error'), TD_BUTTON_OK, TD_ICON_WARNING);
end;

procedure TImageEditor.SetTemporaryImage(Image: TBitmap);
begin
  if not TempImage then
  begin
    Temp := CurrentImage;
    CurrentImage := Image;
  end else
  begin
    F(CurrentImage);
    CurrentImage := Image;
  end;
  MakePCurrentImage;
  if Visible then
  begin
    ReAllignScrolls(False, Point(0, 0));
    MakeImageAndPaint;
    MakeCaption;
  end;
  TempImage := True;
end;

procedure TImageEditor.HistoryChanged(Sender: TObject; Action : THistoryAction);
var
  SAction: string;
begin
  SAction := ImageHistory.Actions[ImageHistory.Position];
  TActionsForm(ActionForm).AddAction(SAction, Action);

  FSaved := False;
  UndoLink.Enabled := ImageHistory.CanBack;
  UndoLink.Invalidate;
  RedoLink.Enabled := ImageHistory.CanForward;
  RedoLink.Invalidate;
end;

procedure TImageEditor.MakeCaption;
begin
  Caption := ImageEditorProductName + '  "' + ExtractFileName(CurrentFileName) + Format('"  [%dx%d px.]',
    [CurrentImage.Width, CurrentImage.Height]) + Format('  %d%% ', [Round(GetZoom * 100)]);
end;

function TImageEditor.GetZoom: Extended;
var
  Fw, Fh: Integer;
begin
  if ZoomerOn then
    Result := Zoom
  else
  begin
    Result := 1;

    if (CurrentImage.Height = 0) or (CurrentImage.Width = 0) then
      Exit;

    if (Buffer.Height = 0) or (Buffer.Width = 0) then
      Exit;

    if (CurrentImage.Width > GetVisibleImageWidth) or (CurrentImage.Height > GetVisibleImageHeight) then
    begin
      if CurrentImage.Width / CurrentImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (CurrentImage.Width / CurrentImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (CurrentImage.Height / CurrentImage.Width));
      end;
    end else
    begin
      Fh := CurrentImage.Height;
      Fw := CurrentImage.Width;
    end;
    Result := Min(Fw / CurrentImage.Width, Fh / CurrentImage.Height);
  end;
end;

procedure TImageEditor.ResizeLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolResize;
  ToolSelectPanel.Hide;
  ToolClass := TResizeToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  (ToolClass as TResizeToolPanelClass).ChangeSize(Sender);
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.UndoLinkClick(Sender: TObject);
var
  Image: TBitmap;
begin
  if not ImageHistory.CanBack then
    Exit;

  Image := TBitmap.Create;
  Image.Assign(ImageHistory.DoBack);
  F(CurrentImage);
  SetPointerToNewImage(Image);
end;

procedure TImageEditor.RedoLinkClick(Sender: TObject);
var
  Image: TBitmap;
begin
  if not ImageHistory.CanForward then
    Exit;

  Image := TBitmap.Create;
  Image.Assign(ImageHistory.DoForward);
  F(CurrentImage);
  SetPointerToNewImage(Image);
end;

procedure TImageEditor.ZoomInLinkClick(Sender: TObject);
begin
  if not ZoomerOn then
  begin
    Zoom := GetZoom;
    ZoomerOn := True;
  end;
  Zoom := Zoom * 1.2;
  if Zoom > 16 then
    Zoom := 16;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

procedure TImageEditor.EffectsLinkClick(Sender: TObject);
var
  BaseImage: TBitmap;
begin
  DisableHistory;
  Tool := ToolEffects;
  ToolSelectPanel.Hide;
  ToolClass := TEffectsToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  ToolClass.OnClosePanel := ShowTools;
  BaseImage := TBitmap.Create;
  try
    BaseImage.Assign(SampleImage.Picture.Graphic);
    (ToolClass as TEffectsToolPanelClass).SetBaseImage(BaseImage);
    (ToolClass as TEffectsToolPanelClass).FillEffects;
  finally
    F(BaseImage);
  end;
  ToolClass.Show;
end;

procedure TImageEditor.ColorsLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolColor;
  ToolSelectPanel.Hide;
  ToolClass := TColorToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.Init;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.RedEyeLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolRedEye;
  ToolSelectPanel.Hide;
  ToolClass := TRedEyeToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  (ToolClass as TRedEyeToolPanelClass).ProcRecteateImage := RecteareImageProc;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.SaveLinkClick(Sender: TObject);
var
  Image: TGraphic;
  Replace: Boolean;
  Ext: string;
  ID: Integer;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;

  function RewriteFile(FileName : string) : Boolean;
  begin
    Result := ID_OK = MessageBoxDB(Handle, Format(L('File "%s" already exists! Do you want to replace it?'), [FileName]), L('Warning'),
                  TD_BUTTON_OKCANCEL, TD_ICON_WARNING);
  end;

begin
  SavePictureDialog := DBSavePictureDialog.Create;
  try
    SavePictureDialog.Filter := TFileAssociations.Instance.GetFilter('.jpg|.gif|.bmp|.png|.tiff', False, False);
    SavePictureDialog.FilterIndex := 1;

    FSaved := False;
    if ForseSave then
      SavePictureDialog.SetFileName(ForseSaveFileName)
    else
      SavePictureDialog.SetFileName(CurrentFileName);

    Replace := False;

    if ForseSave or SavePictureDialog.Execute then
    begin
      if ForseSave then
        FileName := ForseSaveFileName
      else
        FileName := SavePictureDialog.FileName;
      if ForseSave then
      begin
        Ext := GetExt(ForseSaveFileName);
        if (Ext = 'JPG') or (Ext = 'JPEG') or (Ext = 'JPE') then
          SavePictureDialog.FilterIndex := 1
        else if (Ext = 'GIF') then
          SavePictureDialog.FilterIndex := 2
        else if (Ext = 'BMP') then
          SavePictureDialog.FilterIndex := 3
        else if (Ext = 'PNG') then
          SavePictureDialog.FilterIndex := 4
        else if (Ext = 'TIFF') then
          SavePictureDialog.FilterIndex := 5
        else
        begin
          FileName := ChangeFileExt(FileName, '.jpg');
          Ext := 'JPG';
        end;
      end;
      ID := 0;
      case SavePictureDialog.GetFilterIndex of
        1:
          begin
            ID := 0;
            if (GetExt(FileName) <> 'JPG') and (GetExt(FileName) <> 'JPEG') then
              FileName := FileName + '.jpg';
            if FileExistsSafe(FileName) then
            begin
              if not ForseSave then
                if RewriteFile(FileName) then
                  Exit;
              Replace := True;
              ID := GetIdByFileName(FileName);
            end;

            Image := TJPEGImage.Create;
            try
              Image.Assign(CurrentImage);
              if not ForseSave then
                SetJPEGOptions('ImageEditor');

              SetJPEGGraphicSaveOptions('ImageEditor', Image);
              TJPEGImage(Image).Compress;

              try
               if not EXIFSection.Empty then
               begin
                 EXIFSection.BeginUpdate;
                 try
                    EXIFSection.Orientation := toTopLeft;
                    EXIFSection.ExifImageWidth := Width;
                    EXIFSection.ExifImageHeight := Height;
                    EXIFSection.Thumbnail := nil;
                    Image.SaveToFile(FileName);
                    EXIFSection.SaveToGraphic(FileName);
                  finally
                    EXIFSection.EndUpdate;
                  end;
                end else
                begin
                  Image.SaveToFile(FileName);
                end;
                FSaved := True;
              except
                MessageBoxDB(Handle, PWideChar(Format(L('Can not write to file "%s". The file may be in use by another application...'), [FileName])), L('Warning'),
                  TD_BUTTON_OK, TD_ICON_ERROR);
              end;
            finally
              F(Image);
            end;

            if Replace then
              UpdateImageRecord(Self, FileName, ID);
          end;
        2:
          begin
            if (GetExt(FileName) <> 'GIF') then
              FileName := FileName + '.gif';
            if FileExists(FileName) then
            begin
              if not ForseSave then
                if RewriteFile(FileName) then
                  Exit;
              Replace := True;
              ID := GetIdByFileName(FileName);
            end;
            Image := TGIFImage.Create;
            try
              Image.Assign(CurrentImage);
              (Image as TGIFImage).OptimizeColorMap;
              try
                Image.SaveToFile(FileName);
                FSaved := True;
              except
                MessageBoxDB(Handle, Format(L('Can not write to file "%s". The file may be in use by another application...'), [FileName]), L('Error'), TD_BUTTON_OK,
                  TD_ICON_ERROR);
              end;
            finally
              F(Image);
            end;
            if Replace then
              UpdateImageRecord(Self, FileName, ID);
          end;

     3:
          begin
            if (GetExt(FileName) <> 'BMP') then
              FileName := FileName + '.bmp';
            if FileExists(FileName) then
            begin
              if not ForseSave then
                if RewriteFile(FileName) then
                  Exit;
              Replace := True;
              ID := GetIdByFileName(FileName);
            end;
            Image := TBitmap.Create;
            try
              Image.Assign(CurrentImage);
              try
                Image.SaveToFile(FileName);
                FSaved := True;
              except
                MessageBoxDB(Handle, Format(L('Can not write to file "%s". The file may be in use by another application...'), [FileName]), L('Error'), TD_BUTTON_OK,
                  TD_ICON_ERROR);
              end;
            finally
              F(Image);
            end;
            if Replace then
              UpdateImageRecord(Self, FileName, ID);
          end;

        4:
          begin
            if (GetExt(FileName) <> 'PNG') then
              FileName := FileName + '.png';
            if FileExists(FileName) then
            begin
              if not ForseSave then
                if RewriteFile(FileName) then
                  Exit;
              Replace := True;
              ID := GetIdByFileName(FileName);
            end;
            Image := TPngImage.Create;
            try
              Image.Assign(CurrentImage);
              try
                Image.SaveToFile(FileName);
                FSaved := True;
              except
                MessageBoxDB(Handle, Format(L('Can not write to file "%s". The file may be in use by another application...'), [FileName]), L('Error'), TD_BUTTON_OK,
                  TD_ICON_ERROR);
              end;
            finally
              F(Image);
            end;
            if Replace then
              UpdateImageRecord(Self, FileName, ID);
          end;

        5:
          begin
            if (GetExt(FileName) <> 'TIFF') then
              FileName := FileName + '.TIFF';
            if FileExists(FileName) then
            begin
              if not ForseSave then
                if RewriteFile(FileName) then
                  Exit;
              Replace := True;
              ID := GetIdByFileName(FileName);
            end;
            Image := TTiffGraphic.Create;
            try
              Image.Assign(CurrentImage);
              try
                Image.SaveToFile(FileName);
                FSaved := True;
              except
                MessageBoxDB(Handle, Format(L('Can not write to file "%s". The file may be in use by another application...'), [FileName]), L('Error'), TD_BUTTON_OK,
                  TD_ICON_ERROR);
              end;
              finally
              F(Image);
            end;
            if Replace then
              UpdateImageRecord(Self, FileName, ID);
          end;

      end;
      if FilePassWord <> '' then
        GraphicCrypt.CryptGraphicFileV2(FileName, FilePassWord, 0);
    end;
  finally
    F(SavePictureDialog);
  end;
end;

procedure TImageEditor.DisableHistory;
begin
  FStatusProgress.Max := 100;
  DropFileTarget1.Unregister;
  UndoLink.Enabled := False;
  UndoLink.Invalidate;
  SaveLink.Enabled := False;
  SaveLink.Invalidate;
  RedoLink.Enabled := False;
  RedoLink.Invalidate;
end;

procedure TImageEditor.EnableHistory;
begin
  DropFileTarget1.register(Self);
  UndoLink.Enabled := ImageHistory.CanBack;
  UndoLink.Invalidate;
  SaveLink.Enabled := True;
  SaveLink.Invalidate;
  RedoLink.Enabled := ImageHistory.CanForward;
  RedoLink.Invalidate;
end;

procedure TImageEditor.FullSiseLinkClick(Sender: TObject);
begin
  if not ZoomerOn then
  begin
    Zoom := GetZoom;
    ZoomerOn := True;
  end;
  Zoom := 1;
  ReAllignScrolls(False, Point(0, 0));
  MakeImageAndPaint;
  MakeCaption;
end;

procedure TImageEditor.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  EditorsManager.RemoveEditor(Self);
  Release;
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
  with SearchManager.GetAnySearch do
  begin
    Show;
    SetFocus;
  end;
end;

procedure TImageEditor.Explorer1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(CurrentFileName);
    SetPath(ExtractFileDir(CurrentFileName));
    Show;
    SetFocus;
  end;
end;

procedure TImageEditor.LoadLanguage;
begin
  BeginTranslate;
  try
    ZoomOut1.Caption := L('Zoom out');
    ZoomIn1.Caption := L('Zoom in');
    SaveLink.Text := L('Save');
    ZoomOutLink.Text := L('Zoom out');
    ZoomInLink.Text := L('Zoom in');
    FullSiseLink.Text := L('100%');
    FitToSizeLink.Text := L('Fit to window');
    UndoLink.Text := L('Undo');
    RedoLink.Text := L('Redo');
    OpenFileLink.Text := L('Open');
    CropLink.Text := L('Crop');
    RotateLink.Text := L('Rotate');
    ResizeLink.Text := L('Resize');
    EffectsLink.Text := L('Effects');
    ColorsLink.Text := L('Colors');
    RedEyeLink.Text := L('Red eye');
    Search1.Caption := L('Search');
    Explorer1.Caption := L('Explorer');
    Properties1.Caption := L('Properties');
    Exit1.Caption := L('Exit');
    Paste1.Caption := L('Paste');
    OpenFile1.Caption := L('Open file');
    FullScreen1.Caption := L('Full screen');
    Copy1.Caption := L('Copy');
    Print1.Caption := L('Print');
    BrushLink.Text := L('Brush');
    InsertImageLink.Text := L('Insert image');
    TextLink.Text := L('Text');
    NewEditor1.Caption := L('New editor');
    Actions1.Caption := L('Actions');
  finally
    EndTranslate;
  end;
end;

procedure TImageEditor.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TImageEditor.Properties1Click(Sender: TObject);
var
  PR: TImageDBRecordA;
begin
  Pr := GetImageIDW(CurrentFileName, False);
  if Pr.Count <> 0 then
    PropertyManager.NewIDProperty(Pr.Ids[0]).Execute(Pr.Ids[0])
  else
  begin
    if FileExistsSafe(CurrentFileName) then
      PropertyManager.NewFileProperty(CurrentFileName).ExecuteFileNoEx(CurrentFileName)
    else
      MessageBoxDB(Handle, L('For an unsaved file, the properties are not available.'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
end;

procedure TImageEditor.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  P1, P: TPoint;
  PIm: TRect;
begin
  GetCursorPos(P1);
  P := ScreenToClient(P1);
  PIm := Rect(0, ButtomPanel.Height, ButtomPanel.Width - ToolSelectPanel.Width,
    ButtomPanel.Height + ToolSelectPanel.Height);
  if PtInRect(PIm, P) then
    PmMain.Popup(P1.X, P1.Y);
end;

procedure TImageEditor.Paste1Click(Sender: TObject);
var
  B: TBitmap;
  Res: Integer;
begin
  if not CheckEditingMode then
    Exit;

  if ImageHistory.CanBack then
  begin
    Res := MessageBoxDB(Handle, L('Image was changed, save changes?'), L('Warning'), TD_BUTTON_YESNOCANCEL,
      TD_ICON_WARNING);
    if Res = ID_YES then
    begin
      SaveLinkClick(Self);
      if not FSaved then
        Exit;
    end;
    if Res = ID_CANCEL then
      Exit;
    if Res = ID_NO then
      {no action};
  end;
  if ClipBoard.HasFormat(CF_BITMAP) then
  begin
    B := TBitmap.Create;
    try
      B.Assign(ClipBoard);
      B.PixelFormat := pf24bit;
      LoadBitmap(B);
    finally
      F(B);
    end;
  end;
end;

procedure TImageEditor.LoadBitmap(Bitmap : TBitmap);
begin
  LoadBMPImage(Bitmap);
  ImageHistory.Clear;

  CurrentImage.PixelFormat := pf24bit;
  ImageHistory.Add(CurrentImage, '');
  CurrentFileName := '';
  MakeCaption;
  MakeImage;
  FormPaint(Self);
  FormResize(Self);
  CropLink.Enabled := True;
  RotateLink.Enabled := True;
  ColorsLink.Enabled := True;
  ResizeLink.Enabled := True;
  EffectsLink.Enabled := True;
  RedEyeLink.Enabled := True;
  TextLink.Enabled := True;
  BrushLink.Enabled := True;
  InsertImageLink.Enabled := True;
  SaveLink.Enabled := True;
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
  if ((Key = 'V') or (Key = 'v')) and CtrlKeyDown then
    Paste1Click(Sender);
  if (Key = #10) and CtrlKeyDown and Focused then
    FullScreen1Click(Sender);
end;

procedure TImageEditor.PmMainPopup(Sender: TObject);
begin
  Paste1.Visible := ClipBoard.HasFormat(CF_BITMAP);
end;

procedure TImageEditor.FullScreen1Click(Sender: TObject);
begin
  Application.CreateForm(TEditorFullScreenForm, EditorFullScreenForm);
  EditorFullScreenForm.SetImage(CurrentImage);
  EditorFullScreenForm.CreateDrawImage;
  EditorFullScreenForm.Show;
end;

function TImageEditor.GetCurrentImage: TBitmap;
begin
  Result := CurrentImage;
end;

function TImageEditor.GetFormID: string;
begin
  Result := 'Editor';
end;

procedure TImageEditor.Copy1Click(Sender: TObject);
begin
  ClipBoard.Assign(CurrentImage);
end;

procedure TImageEditor.TextLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolText;
  ToolSelectPanel.Hide;
  ToolClass := TextToolClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  (ToolClass as TCustomSelectToolClass).ProcRecteateImage := RecteareImageProc;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.BrushLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolBrush;
  MakeTempLayer;
  ToolSelectPanel.Hide;
  ToolClass := TBrushToolClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  (ToolClass as TBrushToolClass).FDrawlayer := PTempLayer;
  (ToolClass as TBrushToolClass).ProcRecteateImage := RecteareImageProc;
  (ToolClass as TBrushToolClass).SetOwner(Self);
  (ToolClass as TBrushToolClass).Initialize;
  (ToolClass as TBrushToolClass).NewCursor;
  if not VirtualBrushCursor then
    Cursor := 67
  else
    Cursor := CrCross;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

procedure TImageEditor.Print1Click(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := Pf24bit;
    Bitmap.Assign(CurrentImage);
    GetPrintForm(Bitmap);
  finally
    F(Bitmap);
  end;
end;

procedure TImageEditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Result: Integer;
begin
  if ForseSave then
  begin
    CanClose := True;
    Exit;
  end;
  if ImageHistory.CanBack and not FSaved then
  begin
    Result := MessageBoxDB(Handle, L('Image was changed, save changes?'), L('Warning'), TD_BUTTON_YESNOCANCEL,
      TD_ICON_WARNING);
    if Result = ID_YES then
    begin
      SaveLinkClick(Self);
      CanClose := FSaved;
    end;
    if Result = ID_CANCEL then
      CanClose := False;
    if Result = ID_NO then
      CanClose := True;
  end;
end;

procedure TImageEditor.InsertImageLinkClick(Sender: TObject);
begin
  DisableHistory;
  Tool := ToolInsertImage;
  ToolSelectPanel.Hide;
  ToolClass := InsertImageToolPanelClass.Create(ToolsPanel);
  ToolClass.Editor := Self;
  ToolClass.ImageHistory := ImageHistory;
  ToolClass.SetTempImage := SetTemporaryImage;
  ToolClass.CancelTempImage := CancelTemporaryImage;
  ToolClass.Image := CurrentImage;
  ToolClass.SetImagePointer := SetPointerToNewImage;
  (ToolClass as TCustomSelectToolClass).ProcRecteateImage := RecteareImageProc;
  ToolClass.OnClosePanel := ShowTools;
  ToolClass.Show;
end;

{ TManagerEditors }

procedure TManagerEditors.AddEditor(Editor: TImageEditor);
begin
  if FEditors.IndexOf(Editor) > -1 then
    Exit;

  FEditors.Add(Editor);
end;

constructor TManagerEditors.Create;
begin
  FEditors := TList.Create;
end;

destructor TManagerEditors.Destroy;
begin
  F(FEditors);
  inherited;
end;

function TManagerEditors.EditorsCount: Integer;
begin
  Result := FEditors.Count;
end;

function TManagerEditors.GetAnyEditor: TImageEditor;
begin
  if EditorsCount = 0 then
    Result := NewEditor
  else
    Result := FEditors[0];
end;

function TManagerEditors.GetEditorByIndex(Index: Integer): TImageEditor;
begin
  Result := FEditors[Index];
end;

function TManagerEditors.IsEditor(Editor: TForm): Boolean;
begin
  Result := FEditors.IndexOf(Editor) > -1;
end;

function TManagerEditors.NewEditor: TImageEditor;
begin
  Application.CreateForm(TImageEditor, Result);
end;

procedure TManagerEditors.RemoveEditor(Editor: TImageEditor);
begin
  FEditors.Remove(Editor);
end;

procedure TImageEditor.NewEditor1Click(Sender: TObject);
begin
  EditorsManager.NewEditor.Show;
end;

procedure TImageEditor.MakePCurrentImage;
var
  I: Integer;
begin
  if CurrentImage.PixelFormat = pf24bit then
  begin
    SetLength(PCurrentImage, CurrentImage.Height);
    SetLength(PCurrentImage32, 0);
    for I := 0 to CurrentImage.Height - 1 do
      PCurrentImage[I] := CurrentImage.ScanLine[I];
  end;
  if CurrentImage.PixelFormat = pf32bit then
  begin
    SetLength(PCurrentImage, 0);
    SetLength(PCurrentImage32, CurrentImage.Height);
    for I := 0 to CurrentImage.Height - 1 do
      PCurrentImage32[I] := CurrentImage.ScanLine[I];
  end;
end;

procedure TImageEditor.DeleteTempLayer;
begin
  F(TempLayer);
end;

procedure TImageEditor.MakeTempLayer;
var
  I, J: Integer;
begin
  TempLayer := TBitmap.Create;
  TempLayer.PixelFormat := pf32bit;
  TempLayer.Width := CurrentImage.Width;
  TempLayer.Height := CurrentImage.Height;
  SetLength(PTempLayer, TempLayer.Height);
  for I := 0 to TempLayer.Height - 1 do
    PTempLayer[I] := TempLayer.ScanLine[I];
  for I := 0 to TempLayer.Height - 1 do
  begin
    for J := 0 to TempLayer.Width - 1 do
    begin
      PTempLayer[I, J].R := 0;
      PTempLayer[I, J].G := 0;
      PTempLayer[I, J].B := 0;
      PTempLayer[I, J].L := 255;
    end;
  end;
end;

procedure TImageEditor.CMMOUSELEAVE(var Message: TWMNoParams);
var
  I, Ry, W, H, Ax, Ay: Integer;
  Col: TColor;
begin
  Ry := ButtomPanel.Height;
  W := Buffer.Width;
  H := Buffer.Height;
  for I := 0 to Length(VBrush) - 1 do
  begin
    Ax := OldBrushPos.X + VBrush[I].X;
    Ay := OldBrushPos.Y + VBrush[I].Y - Ry;
    if (Ax >= 0) and (Ay >= 0) and (Ax < W) and (Ay < H) then
      Col := RGB(PBuffer[Ay, Ax].R, PBuffer[Ay, Ax].G, PBuffer[Ay, Ax].B)
    else
      Col := 0;
    SetPixel(Canvas.Handle, OldBrushPos.X + VBrush[I].X, OldBrushPos.Y + VBrush[I].Y, Col);
  end;
end;

procedure TImageEditor.Actions1Click(Sender: TObject);
begin
  ActionForm.Show;
end;

procedure TImageEditor.ReadActions(Actions: TStrings);
begin
  SetLength(EState, 0);
  DisableControls(Self);
  NewActions := Actions;
  NewActionsCounter := -1;
  ReadNextAction(nil);
end;

procedure TImageEditor.ReadNextAction(Sender: TObject);
var
  Action, ID, Filter_ID: string;
  BaseImage: TBitmap;

  procedure BaseConfigureTool;
  begin
    ToolClass.Editor := Self;
    ToolClass.ImageHistory := ImageHistory;
    ToolClass.SetTempImage := SetTemporaryImage;
    ToolClass.CancelTempImage := CancelTemporaryImage;
    ToolClass.Image := CurrentImage;
    ToolClass.SetImagePointer := SetPointerToNewImage;
    ToolClass.OnClosePanel := nil;
  end;

begin
  ToolClass := nil;

  Inc(NewActionsCounter);
  if NewActionsCounter > NewActions.Count - 1 then
  begin
    EnableControls(Self);
    if SaveAfterEndActions then
      SaveImageFile(SaveAfterEndActionsFileName);
    NewActionsCounter := -1;
    Exit;
  end;
  Action := NewActions[NewActionsCounter];
  ID := Copy(Action, 2, 38);
  Filter_ID := Copy(Action, 42, 38);

  if ID = '{59168903-29EE-48D0-9E2E-7F34C913B94A}' then
  begin
    ReadNextAction(Self);
    Exit;
  end;
  if ID = '{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}' then
  begin
    { CROP }
    ReadNextAction(Self);
    Exit;
  end;
  if ID = '{747B3EAF-6219-4A96-B974-ABEB1405914B}' then
  begin
    ToolClass := TRotateToolPanelClass.Create(TempPanel);
    BaseConfigureTool;
  end;
  if ID = '{29C59707-04DA-4194-9B53-6E39185CC71E}' then
  begin
    ToolClass := TResizeToolPanelClass.Create(TempPanel);
    BaseConfigureTool;
  end;
  if ID = '{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}' then
  begin
    ToolClass := TEffectsToolPanelClass.Create(TempPanel);
    BaseConfigureTool;

    BaseImage := TBitmap.Create;
    try
      BaseImage.Assign(SampleImage.Picture.Graphic);
      (ToolClass as TEffectsToolPanelClass).SetBaseImage(BaseImage);
    finally
      F(BaseImage);
    end;
    Filter_ID := Copy(Action, 42, Length(Action) - 42);
    (ToolClass as TEffectsToolPanelClass).FillEffects(Filter_ID);
  end;
  if ID = '{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}' then
  begin
    ToolClass := TColorToolPanelClass.Create(TempPanel);
    BaseConfigureTool;
  end;
  if ToolClass <> nil then
    ToolClass.ExecuteProperties(Action, ReadNextAction)
  else
    ReadNextAction(Self);

  F(ToolClass);
end;

procedure TImageEditor.ReadActionsFile(FileName: string);
var
  AActions: TStrings;
begin
  AActions := TStringList.Create;
  try
    if LoadActionsFromfileA(FileName, AActions) then
      ReadActions(AActions);
  finally
    F(AActions);
  end;
end;

procedure TImageEditor.SaveImageFile(FileName: string; AfterEnd: Boolean = False);
begin
  if AfterEnd and (NewActionsCounter <> -1) then
  begin
    SaveAfterEndActions := True;
    SaveAfterEndActionsFileName := FileName;
    Exit;
  end;
  ForseSave := True;
  ForseSaveFileName := FileName;

  SaveLinkClick(Self);
  Close;
end;

initialization

  EditorsManager := TManagerEditors.Create;

finalization

  F(EditorsManager);

end.
