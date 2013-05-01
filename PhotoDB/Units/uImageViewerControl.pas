unit uImageViewerControl;

interface

uses
  Generics.Collections,
  System.Types,
  System.Math,
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.ComCtrls,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Graphics.Utils,
  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,
  ExplorerTypes,
  GIFImage,
  Effects,
  DBCMenu,

  uMemory,
  uConstants,
  u2DUtils,
  uDBForm,
  uIImageViewer,
  uFaceDetection,
  uFaceDetectionThread,
  uPeopleRepository,
  uGraphicUtils,
  uBitmapUtils,
  uAssociations,
  uVCLHelpers,
  uImageZoomHelper,
  uFormCreatePerson,
  uFormSelectPerson,
  uFormInterfaces,
  uCollectionEvents,
  uThemesUtils,
  uDBIcons,
  uDBContext,
  uDBEntities,
  uDBManager,
  uSettings,
  uExifInfo,
  uPortableDeviceUtils,
  uManagerExplorer,
  uAnimationHelper,
  uStringUtils,
  uTranslate,
  uImageViewCount,
  uTranslateUtils;

type
  TRequireImageHandler = procedure(Sender: TObject; Item: TMediaItem; Width, Height: Integer) of object;

type
  TImageViewerControl = class(TBaseWinControl)
  private
    FContext: IDBContext;
    FPeopleRepository: IPeopleRepository;

    FImageViewer: IImageViewer;

    FExifInfo: IExifInfo;
    FShowInfo: Boolean;
    FLastInfoHeight: Integer;

    FLsLoading: TLoadingSign;
    FHorizontalScrollBar: TScrollBar;
    FVerticalScrollBar: TScrollBar;
    FApplicationEvents: TApplicationEvents;
    FItem: TMediaItem;
    FOnImageRequest: TRequireImageHandler;
    FImageFrameTimer: TTimer;
    FLockEventRotateFileList: TStrings;

    FImageViewTimer: TTimer;

    FWlFaceCount: TWebLink;
    FLsDetectingFaces: TLoadingSign;
    FTbrActions: TToolBar;

    FFrameNumber: Integer;

    FCanvas: TCanvas;
    FDrawImage: TBitmap;
    FOverlayBuffer: TBitmap;
    FFullImage: TBitmap;
    FAnimatedImage: TGraphic;
    FAnimatedBuffer: TBitmap;

    FIsWaiting: Boolean;
    FLoading: Boolean;
    FImageExists: Boolean;
    FIsStaticImage: Boolean;
    FTransparentImage: Boolean;
    FDBCanDrag: Boolean;

    FRealImageWidth: Integer;
    FRealImageHeight: Integer;

    FZoomerOn: Boolean;
    FZoom: Real;
    FImageScale: Double;
    FLoadImageSize: TSize;

    FText: string;

    FDrawFace: TFaceDetectionResultItem;
    FFaces: TFaceDetectionResult;
    FFaceDetectionComplete: Boolean;
    FHoverFace: TFaceDetectionResultItem;
    FDrawingFace: Boolean;
    FPersonMouseMoveLock: Boolean;
    FDrawFaceStartPoint: TPoint;
    FIsSelectingFace: Boolean;
    FDisplayAllFaces: Boolean;
    FFaceMenu: TPopupActionBar;
    FImFacePopup: TImageList;
    FFacesMenu: TPopupActionBar;
    FIsHightlitingPerson: Boolean;
    FExplorer: TCustomExplorerForm;

   {$REGION Face menu}
    MiClearFaceZone: TMenuItem;
    MiClearFaceZoneSeparator: TMenuItem;
    MiCurrentPerson: TMenuItem;
    MiCurrentPersonAvatar: TMenuItem;
    MiCurrentPersonSeparator: TMenuItem;
    MiPreviousSelections: TMenuItem;
    MiPreviousSelectionsSeparator: TMenuItem;
    MiCreatePerson: TMenuItem;
    MiOtherPersons: TMenuItem;
    MiFindPhotosSeparator: TMenuItem;
    MiFindPhotos: TMenuItem;
   {$ENDREGION}
   {$REGION Faces menu}
    MiDrawFace: TMenuItem;
    MiDrawFaceSeparator: TMenuItem;
    MiRefreshFaces: TMenuItem;
    MiRefreshFacesSeparator: TMenuItem;
    MiDetectionMethod: TMenuItem;
    MiFaceDetectionStatus: TMenuItem;
    MiAutoHideFacesPanel: TMenuItem;
   {$ENDREGION}

    FOnRequestNextImage: TNotifyEvent;
    FOnRequestPreviousImage: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnStopPersonSelection: TNotifyEvent;

    procedure ChangeContext;
    function Buffer: TBitmap;
    procedure RecreateImage;
    procedure DrawImageInfo;
    function GetIsFastDrawing: Boolean;
    procedure ReAlignScrolls(IsCenter: Boolean);
    function GetItem: TMediaItem;
    function GetImageRectA: TRect;
    function HeightW: Integer;
    procedure UpdateCursor;
    procedure UpdateFaceDetectionState;

    procedure RefreshFaces;
    procedure SelectPerson(P: TPerson);
    function GetFaceMenu: TPopupActionBar;
    function GetFacesMenu: TPopupActionBar;

    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);

    procedure OnScrollChanged(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure FImageFrameTimerOnTimer(Sender: TObject);
    procedure OnApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure PmFacesPopup(Sender: TObject);
    procedure PmFacePopup(Sender: TObject);

    procedure GetFaceInfo(Face: TFaceDetectionResultItem; BmpFace3X: TBitmap; out FaceRect: TRect);

    procedure MiClearFaceZoneClick(Sender: TObject);
    procedure MiCreatePersonClick(Sender: TObject);
    procedure MiOtherPersonsClick(Sender: TObject);
    procedure MiFindPhotosClick(Sender: TObject);
    procedure MiCurrentPersonClick(Sender: TObject);
    procedure MiCurrentPersonAvatarClick(Sender: TObject);
    procedure SelectPreviousPerson(Sender: TObject);

    procedure MiDrawFaceClick(Sender: TObject);
    procedure MiRefreshFacesClick(Sender: TObject);
    procedure MiFaceDetectionStatusClick(Sender: TObject);
    procedure MiAutoHideFacesPanelClick(Sender: TObject);
    procedure WlFaceCountClick(Sender: TObject);
    procedure WlFaceCountMouseEnter(Sender: TObject);
    procedure WlFaceCountMouseLeave(Sender: TObject);
    procedure SelectCascade(Sender: TObject);

    procedure ImageViewTimerOnTimer(Sender: TObject);

    procedure LsLoadingGetBackGround(Sender: TObject; X, Y, W, H: Integer; Bitmap: TBitmap);

    procedure RequestNextImage;
    procedure RequestPreviousImage;
    function GetExplorer: TCustomExplorerForm;
    procedure SetExplorer(const Value: TCustomExplorerForm);
    procedure SetShowInfo(const Value: Boolean);
  protected
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
    procedure DblClick; override;
    procedure Resize; override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;

    function DrawElement(DC: HDC): Boolean; override;
    procedure NextFrame;

    function L(StringToTranslate: string): string;

    function BufferPointToImagePoint(P: TPoint): TPoint;
    function ImagePointToBufferPoint(P: TPoint): TPoint;
    function GetVisibleImageWidth: Integer;
    function GetVisibleImageHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure StartLoadingImage;
    procedure StopLoadingImage;
    procedure LoadStaticImage(Item: TMediaItem; Image: TBitmap; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
    procedure LoadAnimatedImage(Item: TMediaItem; Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
    procedure FailedToLoadImage(ErrorMessage: string);

    procedure ZoomOut;
    procedure ZoomIn;

    procedure RotateCW;
    procedure RotateCCW;

    procedure SetText(Text: string);
    procedure ReloadCurrent;
    procedure UpdateItemInfo(Item: TMediaItem);

    function IsAnimatedImage: Boolean;

    procedure SetFaceDetectionControls(AWlFaceCount: TWebLink; ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
    procedure HightlitePerson(PersonID: Integer);
    procedure HightliteReset;
    procedure StartPersonSelection;
    procedure StopPersonSelection;
    procedure CheckFaceIndicatorVisibility;

    procedure FinishDetectingFaces;
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);

    procedure UpdateAvatar(PersonID: Integer);

    property ImageViewer: IImageViewer read FImageViewer write FImageViewer;
    property IsFastDrawing: Boolean read GetIsFastDrawing;
    property Item: TMediaItem read GetItem;
    property FullImage: TBitmap read FFullImage;
    property OnImageRequest: TRequireImageHandler read FOnImageRequest write FOnImageRequest;
    property PmFace: TPopupActionBar read GetFaceMenu;
    property PmFaces: TPopupActionBar read GetFacesMenu;

    property OnRequestNextImage: TNotifyEvent read FOnRequestNextImage write FOnRequestNextImage;
    property OnRequestPreviousImage: TNotifyEvent read FOnRequestPreviousImage write FOnRequestPreviousImage;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnStopPersonSelection: TNotifyEvent read FOnStopPersonSelection write FOnStopPersonSelection;
    property Text: string read FText write SetText;
    property Explorer: TCustomExplorerForm read GetExplorer write SetExplorer;
    property ShowInfo: Boolean read FShowInfo write SetShowInfo;
  end;

implementation

{ TImageViewerControl }

function TImageViewerControl.Buffer: TBitmap;
begin
  if (FOverlayBuffer = nil) or FOverlayBuffer.Empty then
    Result := FDrawImage
  else
    Result := FOverlayBuffer;
end;

procedure TImageViewerControl.Click;
var
  P, ScreenRect, ImagePoint: TPoint;
  //ImRect: TRect;
  I: Integer;
  //Dy, Dx, X, Y, Z: Extended;
begin
  inherited;
  GetCursorPos(ScreenRect);
  P := ScreenToClient(ScreenRect);

  ImagePoint := BufferPointToImagePoint(P);
  for I := 0 to FFaces.Count - 1 do
    if PtInRect(FFaces[I].Rect, PxMultiply(ImagePoint, FFullImage, FFaces[I].ImageSize)) then
    begin
      FHoverFace := FFaces[I];
      RefreshFaces;
      PmFace.Tag := NativeInt(FFaces[I]);
      PmFace.DoPopupEx(ScreenRect.X, ScreenRect.Y);
      Exit;
    end;

{  if Cursor = CursorZoomInNo then
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
  FormResize(Sender);   }
end;

constructor TImageViewerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  ControlStyle := ControlStyle + [csOpaque, csPaintBlackOpaqueOnGlass];

  ChangeContext;

  FImageViewTimer := TTimer.Create(Self);
  FImageViewTimer.Enabled := False;
  FImageViewTimer.Interval := 1000;
  FImageViewTimer.OnTimer := ImageViewTimerOnTimer;

  FLsLoading := TLoadingSign.Create(Self);
  FLsLoading.Parent := Self;
  FLsLoading.Width := 32;
  FLsLoading.Height := 32;
  FLsLoading.FillPercent := 60;
  FLsLoading.GetBackGround := LsLoadingGetBackGround;
  FLsLoading.Active := True;

  FHorizontalScrollBar := TScrollBar.Create(Self);
  FHorizontalScrollBar.Visible := False;
  FHorizontalScrollBar.Parent := Self;
  FHorizontalScrollBar.Kind := sbHorizontal;
  FHorizontalScrollBar.OnScroll := OnScrollChanged;

  FVerticalScrollBar := TScrollBar.Create(Self);
  FVerticalScrollBar.Visible := False;
  FVerticalScrollBar.Parent := Self;
  FVerticalScrollBar.Kind := sbVertical;
  FVerticalScrollBar.OnScroll := OnScrollChanged;

  FDrawImage := TBitmap.Create;
  FDrawImage.PixelFormat := pf24bit;

  FOverlayBuffer := TBitmap.Create;
  FOverlayBuffer.PixelFormat := pf24bit;

  FFullImage := TBitmap.Create;
  FFullImage.PixelFormat := pf24bit;

  FAnimatedBuffer := TBitmap.Create;
  FAnimatedBuffer.PixelFormat := pf24bit;

  FImageFrameTimer := TTimer.Create(Self);
  FImageFrameTimer.Enabled := False;
  FImageFrameTimer.OnTimer := FImageFrameTimerOnTimer;

  FApplicationEvents := TApplicationEvents.Create(Self);
  FApplicationEvents.OnMessage := OnApplicationMessage;

  FOnRequestNextImage := nil;
  FOnRequestPreviousImage := nil;
  FOnStopPersonSelection := nil;

  FFaceMenu := nil;
  FFacesMenu := nil;
  FImFacePopup := TImageList.Create(Self);
  FImFacePopup.ColorDepth := cd32Bit;

  FWlFaceCount := nil;
  FLsDetectingFaces := nil;
  FTbrActions := nil;

  FDBCanDrag := False;
  FShowInfo := AppSettings.ReadBool('Viewer', 'DisplayInfo', False);
  FLastInfoHeight := 0;

  FIsWaiting := False;
  FZoomerOn := False;
  FZoom := 1;
  FTransparentImage := False;
  FLoading := False;
  FImageExists := False;
  FRealImageWidth := 0;
  FRealImageHeight := 0;
  FImageScale := 1;
  FAnimatedImage := nil;
  FFrameNumber := -1;
  FLoadImageSize.cx := 0;
  FLoadImageSize.cy := 0;
  FText := '';
  FIsHightlitingPerson := False;
  FExplorer := nil;

  FLockEventRotateFileList := TStringList.Create;

  FDrawFace := nil;
  FDrawingFace := False;
  FFaces := TFaceDetectionResult.Create;
  FPersonMouseMoveLock := False;
  FIsSelectingFace := False;
  FDisplayAllFaces := False;

  FItem := TMediaItem.Create;

  CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TImageViewerControl.DblClick;
begin
  inherited;
  if Assigned(FOnDblClick) then
    FOnDblClick(Self);
end;

destructor TImageViewerControl.Destroy;
begin
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
  F(FAnimatedImage);
  F(FAnimatedBuffer);
  F(FDrawImage);
  F(FOverlayBuffer);
  F(FFullImage);
  F(FCanvas);
  F(FItem);
  F(FDrawFace);
  F(FFaces);
  F(FLockEventRotateFileList);
  inherited;
end;

procedure TImageViewerControl.DoContextPopup(MousePos: TPoint;
  var Handled: Boolean);
var
  Info: TMediaItemCollection;
begin
  inherited;

  if FItem = nil then
    Exit;

  if not IsGraphicFile(FItem.FileName) then
    Exit;

  if FText <> '' then
    Exit;
  
  Info := TMediaItemCollection.Create;
  try
    Info.Add(FItem.Copy);
    Info.Position := 0;
    Info[0].Selected := True;

    TDBPopupMenu.Instance.Execute(TDBForm(Self.OwnerForm), ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y, Info);
  finally
    F(Info);
  end;
end;

function TImageViewerControl.DrawElement(DC: HDC): Boolean;
begin
  Result := BitBlt(DC, 0, 0, Buffer.Width, Buffer.Height, Buffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TImageViewerControl.DrawImageInfo;
const
  PaddingVertical = 3;
var
  I: Integer;
  Infos: TList<string>;
  InfoHeightMax,
  InfoWidthMax,
  InfoHeight,
  InfoBarHeight,
  InfoWidth: Integer;
  InfosCountByColumn: Integer;
  Val, Make, Model: string;

  LineInfos: TStringList;

  function GetInfo(Name: string): string;
  begin
    if FExifInfo = nil then
      Exit('');

    Val := FExifInfo.GetValueByKey(Name);
    if Val <> '' then
      Result := Val;
  end;

  function AddInfo(Name: string; Format: string): Boolean;
  begin
    Result := False;
    if FExifInfo = nil then
      Exit;

    Val := FExifInfo.GetValueByKey(Name);
    if Val <> '' then
    begin
      LineInfos.Add(FormatEx(Format, [Val]));
      Result := True;
    end;
  end;

  procedure AppendInfo(Name: string; Format: string; DefaultValue: string);
  begin
    if FExifInfo = nil then
      Exit;

    Val := FExifInfo.GetValueByKey(Name);
    if (Val <> '') and (Val <> DefaultValue) then
      LineInfos[LineInfos.Count - 1] := LineInfos[LineInfos.Count - 1] + FormatEx(Format, [Val]);
  end;

begin
  if not ShowInfo then
    Exit;

  //Prepaire draw information
  Infos := TList<string>.Create;
  try
    Infos.Add(FormatEx('{0} x {1} - {2}', [FItem.Width, FItem.Height, SizeInText(FItem.FileSize)]));

    if YearOf(FItem.Date) > cMinEXIFYear then
      Infos.Add(FormatDateTime('yyyy.mm.dd HH:MM:SS', FItem.Date + FItem.Time))
    else
    begin
      if FExifInfo <> nil then
      begin
        Val := FExifInfo.GetValueByKey('DateTime');
        if Val <> '' then
          Infos.Add(Val);
      end;
    end;

    LineInfos := TStringList.Create;
    try
      AddInfo('FNumber', 'F/{0}');
      if AddInfo('ExposureTime', '{0}') then
        AppendInfo('ExposureBiasValue', ' {0}', '0');
      AddInfo('ISOSpeedRatings', 'ISO {0}');
      AddInfo('FocalLength', '{0}');

      if LineInfos.Count > 0 then
        Infos.Add(LineInfos.Join('  '));
    finally
      F(LineInfos);
    end;

    LineInfos := TStringList.Create;
    try
      AddInfo('CameraModel', '{0}');
      if LineInfos.Count = 0 then
      begin
        Make := GetInfo('Make');
        Model := GetInfo('Model');
        if (Model <> '') and (Make <> '') and (Model.IndexOf(Make) = -1) then
          Infos.Add(Make + ' ' + Model)
        else if Model <> '' then
          Infos.Add(Model);
      end;
      AddInfo('Lens', '{0}');

      if LineInfos.Count > 0 then
        Infos.Add(LineInfos.Join(' + '));
    finally
      F(LineInfos);
    end;

    InfoHeightMax := 0;
    InfoWidthMax := 0;
    InfosCountByColumn := Min(4, Infos.Count);
    for I := 0 to InfosCountByColumn - 1 do
    begin
      InfoHeight := FDrawImage.Canvas.TextHeight(Infos[I]) + 2;
      InfoWidth := FDrawImage.Canvas.TextHeight(Infos[I]);
      if InfoHeight > InfoHeightMax then
        InfoHeightMax := InfoHeight;
      if InfoWidth > InfoWidthMax then
        InfoWidthMax := InfoWidth;
    end;

    InfoBarHeight := InfosCountByColumn * InfoHeightMax + PaddingVertical * 2;
    if (FLastInfoHeight > InfoBarHeight) and (FExifInfo = nil) then
      InfoBarHeight := FLastInfoHeight
    else
      FLastInfoHeight := InfoBarHeight;

   // AddFontResourceEx('N:\MyriadPro\MyriadPro-Regular.otf', FR_PRIVATE or FR_NOT_ENUM, 0);

    FDrawImage.Canvas.Font.Quality := fqAntialiased;
    //FDrawImage.Canvas.Font.Quality := fqClearTypeNatural;
    FDrawImage.Canvas.Font.Name := 'MyriadPro-Regular';//'MS Sans Serif';
    //FDrawImage.Canvas.Font.Name := 'MS Sans Serif';
    FDrawImage.Canvas.Font.Size := 10;

    DrawTransparentColorGradient(FDrawImage, Theme.ListViewColor, 0, FDrawImage.Height - InfoBarHeight, FDrawImage.Width, InfoBarHeight, 200, 0);

    for I := 0 to InfosCountByColumn - 1 do
    begin
      FDrawImage.Canvas.TextOut(5, FDrawImage.Height - InfoBarHeight + I * InfoHeightMax + PaddingVertical, Infos[I]);
    end;
  finally
    F(Infos);
  end;
end;

procedure TImageViewerControl.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TImageViewerControl.FImageFrameTimerOnTimer(Sender: TObject);
begin
  NextFrame;
end;

procedure TImageViewerControl.FinishDetectingFaces;
begin
  F(FDrawFace);
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;
end;

function TImageViewerControl.L(StringToTranslate: string): string;
begin
  Result := TA(StringToTranslate, 'Viewer');
end;

procedure TImageViewerControl.LoadAnimatedImage(Item: TMediaItem;
  Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
begin
  FText := '';
  F(FItem);
  FItem := Item.Copy;
  FExifInfo := Exif;

  F(FAnimatedImage);
  FAnimatedImage := Image;
  FLoadImageSize.cx := FAnimatedImage.Width;
  FLoadImageSize.cy := FAnimatedImage.Height;

  FRealImageWidth := RealWidth;
  FRealImageHeight := RealHeight;
  if Item.ID = 0 then
    Item.Rotation := Rotation;

  {FCurrentlyLoadedFile := Item.FileName;
  ForwardThreadExists := False;
  FForwardThreadReady := False; }
  FIsStaticImage := False;
  FImageExists := True;
  FLoading := False;

  if not FZoomerOn then
    Cursor := crDefault;

  {TbFitToWindow.Enabled := True;
  TbRealSize.Enabled := True;
  TbSlideShow.Enabled := True;
  TbZoomOut.Enabled := True;
  TbZoomIn.Enabled := True;    }

  //TbRotateCCW.Enabled := not IsDevicePath(Item.FileName);
  //TbRotateCW.Enabled := not IsDevicePath(Item.FileName);

  {TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;}

  ReAlignScrolls(False);
  FFrameNumber := -1;
  FZoomerOn := False;
  FTransparentImage := FAnimatedImage.IsTransparentAnimation;

  FAnimatedBuffer.SetSize(FAnimatedImage.Width, FAnimatedImage.Height);

  FAnimatedBuffer.Canvas.Brush.Color := Theme.PanelColor;
  FAnimatedBuffer.Canvas.Pen.Color := Theme.PanelColor;

  FAnimatedBuffer.Canvas.Rectangle(0, 0, FAnimatedBuffer.Width, FAnimatedBuffer.Height);
  FImageFrameTimer.Interval := 1;
  FImageFrameTimer.Enabled := True;

  FFaces.Clear;
  FHoverFace := nil;
  FOverlayBuffer.SetSize(0, 0);
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;

  StopLoadingImage;
  FImageViewTimer.Restart;
end;

procedure TImageViewerControl.LoadStaticImage(Item: TMediaItem; Image: TBitmap; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double; Exif: IExifInfo);
begin
  FText := '';
  F(FItem);
  FItem := Item.Copy;
  FExifInfo := Exif;

  FImageScale := ImageScale;

  //FTransparentImage := Transparent;
  F(FAnimatedImage);
  F(FFullImage);
  FFullImage := Image;
  FLoadImageSize.cx := FFullImage.Width;
  FLoadImageSize.cy := FFullImage.Height;

  FRealImageWidth := RealWidth;
  FRealImageHeight := RealHeight;
  if FItem.ID = 0 then
    FItem.Rotation := Rotation;

  FIsStaticImage := True;
  FImageExists := True;
  FLoading := False;
  if not FZoomerOn then
    Cursor := crDefault;

  ReAlignScrolls(False);
  FOverlayBuffer.SetSize(0, 0);
  FFaces.Clear;
  FHoverFace := nil;
  FFaceDetectionComplete := False;
  FIsHightlitingPerson := False;
  UpdateFaceDetectionState;
  StopLoadingImage;
  RecreateImage;
  FImageViewTimer.Restart;
end;

procedure TImageViewerControl.FailedToLoadImage(ErrorMessage: string);
var
  S: string;
begin
  Cursor := crDefault;
  FRealImageHeight := 0;
  FRealImageWidth := 0;
  FExifInfo := nil;
  //RealZoomInc := FRealZoomScale;
  //ViewerForm.Item.Encrypted := FIsEncrypted;
  //if FIsNewDBInfo then
  //  ViewerForm.UpdateInfo(FSID, FInfo);
  Item.Rotation := DB_IMAGE_ROTATE_0;
  FImageExists := False;

  FLsLoading.Hide;
  ReAlignScrolls(False);

  FFaces.Clear;
  if FImageViewer <> nil then
  FImageViewer.UpdateFaces(FItem.FileName, FFaces);
  FHoverFace := nil;
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;

  if ErrorMessage <> '' then
    S := FormatEx(TA('Error loading image: {0}, {1}', 'Errors'), [ExtractFileName(FItem.FileName), ErrorMessage])
  else
    S := FormatEx(TA('Error loading image: {0}', 'Errors'), [ExtractFileName(FItem.FileName)]);
  SetText(S);
  Invalidate;
  RecreateImage;
end;

procedure TImageViewerControl.LsLoadingGetBackGround(Sender: TObject; X, Y, W,
  H: Integer; Bitmap: TBitmap);
begin
  if (Buffer = nil) or Buffer.Empty then
  begin
    Bitmap.Canvas.Pen.Color := Theme.PanelColor;
    Bitmap.Canvas.Brush.Color := Theme.PanelColor;
    Bitmap.Canvas.Rectangle(0, 0, W, H);
  end else
    Bitmap.Canvas.CopyRect(Rect(0, 0, W, H), Buffer.Canvas, Rect(X, Y, X + W, Y + H));
end;

procedure TImageViewerControl.MiAutoHideFacesPanelClick(Sender: TObject);
begin
  MiAutoHideFacesPanel.Checked := not MiAutoHideFacesPanel.Checked;
  AppSettings.WriteBool('FaceDetection', 'AutoHidePanel', MiAutoHideFacesPanel.Checked);
end;

procedure TImageViewerControl.MiClearFaceZoneClick(Sender: TObject);
var
  FR: TFaceDetectionResultItem;
  FA: TPersonArea;
begin
  FHoverFace := nil;

  FR := TFaceDetectionResultItem(PmFace.Tag);
  if FR.Data <> nil then
  begin
    FA := TPersonArea(FR.Data);
    FPeopleRepository.RemovePersonFromPhoto(Item.ID, FA);
  end;
  FFaces.RemoveFaceResult(FR);
  FHoverFace := nil;
  UpdateFaceDetectionState;

  if FImageViewer <> nil then
    FImageViewer.UpdateFaces(FItem.FileName, FFaces);

  RefreshFaces;
end;

function TImageViewerControl.GetExplorer: TCustomExplorerForm;
begin
  if FExplorer <> nil then
    Exit(FExplorer);

  Result := ExplorerManager.NewExplorer(False);
end;

procedure TImageViewerControl.GetFaceInfo(Face: TFaceDetectionResultItem; BmpFace3X: TBitmap; out FaceRect: TRect);
var
  R: TRect;
  P1, P2: TPoint;
  W, H: Integer;
begin
  FaceRect := Rect(0, 0, 0, 0);
  R := Face.Rect;
  P1 := R.TopLeft;
  P2 := R.BottomRight;
  P1 := PxMultiply(P1, Face.ImageSize, FFullImage);
  P2 := PxMultiply(P2, Face.ImageSize, FFullImage);

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
  if R.Bottom > FFullImage.Height then
    R.Bottom := FFullImage.Height;
  if R.Right > FFullImage.Width then
    R.Right := FFullImage.Width;

  BmpFace3X.SetSize(RectWidth(R), RectHeight(R));
  BmpFace3X.Canvas.CopyRect(BmpFace3X.ClientRect, FFullImage.Canvas, R);
end;

procedure TImageViewerControl.MiCreatePersonClick(Sender: TObject);
var
  Face, TmpFace: TFaceDetectionResultItem;
  FaceRect: TRect;
  BmpFace3X: TBitmap;
  P: TPerson;
begin
  Face := TFaceDetectionResultItem(PmFace.Tag);

  BmpFace3X := TBitmap.Create;
  try
    BmpFace3X.PixelFormat := pf24Bit;

    GetFaceInfo(Face, BmpFace3X, FaceRect);

    TmpFace := TFaceDetectionResultItem.Create;
    try
      TmpFace.X := FaceRect.Left;
      TmpFace.Y := FaceRect.Top;
      TmpFace.Width := RectWidth(FaceRect);
      TmpFace.Height := RectHeight(FaceRect);
      CreatePerson(Item, Face, TmpFace, BmpFace3X, P);

      if FImageViewer <> nil then
        FImageViewer.UpdateFaces(FItem.FileName, FFaces);

      RefreshFaces;
      F(P);
    finally
      F(TmpFace);
    end;
  finally
    F(BmpFace3X);
  end;
end;

procedure TImageViewerControl.UpdateAvatar(PersonID: Integer);
var
  I: Integer;
  Face: TFaceDetectionResultItem;
  FaceRect: TRect;
  BmpFace3X: TBitmap;
begin
  Face := nil;
  for I := 0 to FFaces.Count - 1 do
  begin
    if (FFaces[I].Data <> nil) and (TPersonArea(FFaces[I].Data).PersonID = PersonID) then
      Face := FFaces[I];
  end;

  if Face = nil then
    Exit;

  BmpFace3X := TBitmap.Create;
  try
    BmpFace3X.PixelFormat := pf24Bit;

    GetFaceInfo(Face, BmpFace3X, FaceRect);

    EditPerson(PersonID, BmpFace3X);
    RefreshFaces;
  finally
    F(BmpFace3X);
  end;
end;

procedure TImageViewerControl.MiCurrentPersonAvatarClick(Sender: TObject);
var
  FR: TFaceDetectionResultItem;
  PA: TPersonArea;
begin
  FR := TFaceDetectionResultItem(PmFace.Tag);
  PA := TPersonArea(FR.Data);
  if (PA <> nil) then
    UpdateAvatar(PA.PersonID);
end;

procedure TImageViewerControl.MiCurrentPersonClick(Sender: TObject);
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

procedure TImageViewerControl.MiDrawFaceClick(Sender: TObject);
begin
  FIsSelectingFace := True;
  UpdateCursor;
end;

procedure TImageViewerControl.MiFaceDetectionStatusClick(Sender: TObject);
var
  IsActive: Boolean;
begin
  IsActive := AppSettings.ReadBool('FaceDetection', 'Enabled', True);
  AppSettings.WriteBool('FaceDetection', 'Enabled', not IsActive);
  ReloadCurrent;
end;

procedure TImageViewerControl.MiFindPhotosClick(Sender: TObject);
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
    FPeopleRepository.FindPerson(PA.PersonID, P);
    if P.Empty then
      Exit;

    with Explorer do
    begin
      SetPath(cPersonsPath + '\' + P.Name);
      Show;
    end;
  finally
    F(P);
  end;
end;

procedure TImageViewerControl.MiOtherPersonsClick(Sender: TObject);
var
  FormFindPerson: TFormFindPerson;
  P: TPerson;
  Result: Integer;
begin
  Application.CreateForm(TFormFindPerson, FormFindPerson);
  try
    P := nil;
    try
      Result := FormFindPerson.Execute(Item, P);
      if (P <> nil) and (Result = SELECT_PERSON_OK) then
        SelectPerson(P);
      if Result = SELECT_PERSON_CREATE_NEW then
        MiCreatePersonClick(Sender);
    finally
      F(P);
    end;
  finally
    F(FormFindPerson);
  end;
end;

procedure TImageViewerControl.MiRefreshFacesClick(Sender: TObject);
begin
  FFaces.RemoveCache;
  ReloadCurrent;
end;

procedure TImageViewerControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  PA: TPersonArea;
begin
  inherited;

  if FIsSelectingFace and (Button = mbRight) then
  begin
    FIsSelectingFace := False;
    StopPersonSelection;
  end;

  if FIsStaticImage and (FHoverFace = nil) and (ShiftKeyDown or (Button = mbMiddle) or FIsSelectingFace) and not FDBCanDrag then
  begin
    FIsSelectingFace := False;
    FDrawingFace := True;
    P := Point(X, Y);
    F(FDrawFace);
    FDrawFace := TFaceDetectionResultItem.Create;
    FDrawFace.ImageWidth := FFullImage.Width;
    FDrawFace.ImageHeight := FFullImage.Height;

    FDrawFaceStartPoint := BufferPointToImagePoint(P);
    FDrawFace.Rect := Rect(FDrawFaceStartPoint, FDrawFaceStartPoint);

    PA := TPersonArea.Create(0, -1, nil);
    FDrawFace.Data := PA;
    UpdateCursor;
    Exit;
  end;

  {WindowsMenuTickCount := GetTickCount;
  if CurrentInfo.Count = 0 then
    Exit;

  if Button = MbLeft then
    if FileExistsSafe(Item.FileName) then
    begin
      DBCanDrag := True;
      GetCursorPos(DBDragPoint);
    end; }
end;

procedure TImageViewerControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  StartPoint, P, DrawFaceEndPoint: TPoint;
  //DragImage: TBitmap;
  //FileName: string;
  I: Integer;
  OldHoverFace: TFaceDetectionResultItem;
  FaceRect: TRect;
begin
  inherited;
  FIsHightlitingPerson := False;
  StartPoint := Point(X, Y);

  if not FPersonMouseMoveLock and not IsPopupMenuActive then
  begin
    P := BufferPointToImagePoint(StartPoint);
    OldHoverFace := FHoverFace;
    FHoverFace := nil;

    for I := 0 to FFaces.Count - 1 do
      if PtInRect(NormalizeRect(FFaces[I].Rect), PxMultiply(P, FFullImage, FFaces[I].ImageSize)) then
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

{  if DBCanDrag then
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
        W := FFullImage.Width;
        H := FFullImage.Height;
        ProportionalSize(ThImageSize, ThImageSize, W, H);

        DragImage := TBitmap.Create;
        try
          DoResize(W, H, FFullImage, DragImage);
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

  FOldPoint := Point(X, Y); }
end;

procedure TImageViewerControl.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
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
    PmFace.DoPopupEx(P.X, P.Y);
    UpdateCursor;

    if Assigned(FOnStopPersonSelection) then
      FOnStopPersonSelection(Self);
  end;
  F(FDrawFace);
  FDBCanDrag := False;
end;


procedure TImageViewerControl.NextFrame;
begin
  if not (FImageExists and not FIsStaticImage) then
    Exit;

  FAnimatedImage.ProcessNextFrame(FAnimatedBuffer, FFrameNumber, Theme.PanelColor, FImageFrameTimer,
    procedure
    begin
      case Item.Rotation and DB_IMAGE_ROTATE_MASK of
        DB_IMAGE_ROTATE_0:
          FFullImage.Assign(FAnimatedBuffer);
        DB_IMAGE_ROTATE_90:
          Rotate90(FAnimatedBuffer, FFullImage);
        DB_IMAGE_ROTATE_180:
          Rotate180(FAnimatedBuffer, FFullImage);
        DB_IMAGE_ROTATE_270:
          Rotate270(FAnimatedBuffer, FFullImage)
      end;

      RecreateImage;
    end
  );

end;

function TImageViewerControl.GetFaceMenu: TPopupActionBar;
begin
  if FFaceMenu <> nil then
    Exit(FFaceMenu);

  FFaceMenu := TPopupActionBar.Create(Self);
  FFaceMenu.OnPopup := PmFacePopup;
  FFaceMenu.Images := FImFacePopup;

  MiClearFaceZone := TMenuItem.Create(FFaceMenu);
  MiClearFaceZone.ImageIndex := 0;
  MiClearFaceZone.Caption := L('Clear face zone');
  MiClearFaceZone.OnClick := MiClearFaceZoneClick;

  MiClearFaceZoneSeparator := TMenuItem.Create(FFaceMenu);
  MiClearFaceZoneSeparator.Caption := '-';

  MiCurrentPerson := TMenuItem.Create(FFaceMenu);
  MiCurrentPerson.Visible := False;
  MiCurrentPerson.OnClick := MiCurrentPersonClick;

  MiCurrentPersonAvatar := TMenuItem.Create(FFaceMenu);
  MiCurrentPersonAvatar.Caption := L('Update avatar');
  MiCurrentPersonAvatar.Visible := False;
  MiCurrentPersonAvatar.ImageIndex := 3;
  MiCurrentPersonAvatar.OnClick := MiCurrentPersonAvatarClick;

  MiCurrentPersonSeparator := TMenuItem.Create(FFaceMenu);
  MiCurrentPersonSeparator.Caption := '-';

  MiPreviousSelections := TMenuItem.Create(FFaceMenu);
  MiPreviousSelections.Caption := L('Previous selections') + ':';
  MiPreviousSelections.Enabled := False;

  MiPreviousSelectionsSeparator := TMenuItem.Create(FFaceMenu);
  MiPreviousSelectionsSeparator.Caption := '-';

  MiCreatePerson := TMenuItem.Create(FFaceMenu);
  MiCreatePerson.Caption := L('Create person');
  MiCreatePerson.ImageIndex := 1;
  MiCreatePerson.OnClick := MiCreatePersonClick;

  MiOtherPersons := TMenuItem.Create(FFaceMenu);
  MiOtherPersons.Caption := L('Other person');
  MiOtherPersons.ImageIndex := 1;
  MiOtherPersons.OnClick := MiOtherPersonsClick;

  MiFindPhotosSeparator := TMenuItem.Create(FFaceMenu);
  MiFindPhotosSeparator.Caption := '-';

  MiFindPhotos := TMenuItem.Create(FFaceMenu);
  MiFindPhotos.Caption := L('Find photos');
  MiFindPhotos.ImageIndex := 2;
  MiFindPhotos.OnClick := MiFindPhotosClick;

  FFaceMenu.Items.Add(MiClearFaceZone);
  FFaceMenu.Items.Add(MiClearFaceZoneSeparator);
  FFaceMenu.Items.Add(MiCurrentPerson);
  FFaceMenu.Items.Add(MiCurrentPersonAvatar);
  FFaceMenu.Items.Add(MiCurrentPersonSeparator);
  FFaceMenu.Items.Add(MiPreviousSelections);
  FFaceMenu.Items.Add(MiPreviousSelectionsSeparator);
  FFaceMenu.Items.Add(MiCreatePerson);
  FFaceMenu.Items.Add(MiOtherPersons);
  FFaceMenu.Items.Add(MiFindPhotosSeparator);
  FFaceMenu.Items.Add(MiFindPhotos);

  Exit(FFaceMenu);
end;

function TImageViewerControl.GetFacesMenu: TPopupActionBar;
begin
  if FFacesMenu <> nil then
    Exit(FFacesMenu);

  FFacesMenu := TPopupActionBar.Create(Self);
  FFacesMenu.OnPopup := PmFacesPopup;

  MiDrawFace := TMenuItem.Create(FFacesMenu);
  MiDrawFace.Caption := L('Select person');
  MiDrawFace.OnClick := MiDrawFaceClick;

  MiDrawFaceSeparator := TMenuItem.Create(FFacesMenu);
  MiDrawFaceSeparator.Caption := '-';

  MiRefreshFaces := TMenuItem.Create(FFacesMenu);
  MiRefreshFaces.OnClick := MiRefreshFacesClick;

  MiRefreshFacesSeparator := TMenuItem.Create(FFacesMenu);
  MiRefreshFacesSeparator.Caption := '-';

  MiDetectionMethod := TMenuItem.Create(FFacesMenu);

  MiFaceDetectionStatus := TMenuItem.Create(FFacesMenu);
  MiFaceDetectionStatus.OnClick := MiFaceDetectionStatusClick;

  MiAutoHideFacesPanel := TMenuItem.Create(FFacesMenu);
  MiAutoHideFacesPanel.Caption := L('Auto hide panel');
  MiAutoHideFacesPanel.OnClick := MiAutoHideFacesPanelClick;
  MiAutoHideFacesPanel.Checked := AppSettings.ReadBool('FaceDetection', 'AutoHidePanel', False);

  FFacesMenu.Items.Add(MiDrawFace);
  FFacesMenu.Items.Add(MiDrawFaceSeparator);
  FFacesMenu.Items.Add(MiRefreshFaces);
  FFacesMenu.Items.Add(MiRefreshFacesSeparator);
  FFacesMenu.Items.Add(MiDetectionMethod);
  FFacesMenu.Items.Add(MiFaceDetectionStatus);
  FFacesMenu.Items.Add(MiAutoHideFacesPanel);

  Result := FFacesMenu;
end;

function TImageViewerControl.GetImageRectA: TRect;
begin
  Result := TImageZoomHelper.GetImageVisibleRect(FHorizontalScrollBar, FVerticalScrollBar,
      TSize.Create(FFullImage.Width, FFullImage.Height),
      TSize.Create(ClientWidth, HeightW),
      FZoom);
end;

function TImageViewerControl.IsAnimatedImage: Boolean;
begin
  Result := FAnimatedImage <> nil;
end;

function TImageViewerControl.GetIsFastDrawing: Boolean;
begin
  Result := False;
end;

function TImageViewerControl.GetItem: TMediaItem;
begin
  Result := FItem;
end;

function TImageViewerControl.GetVisibleImageHeight: Integer;
begin
  Result := ClientHeight{ - BottomImage.Height};
end;

function TImageViewerControl.GetVisibleImageWidth: Integer;
begin
  Result := ClientWidth;
end;

function TImageViewerControl.HeightW: Integer;
begin
  Result := ClientHeight;
end;

function TImageViewerControl.BufferPointToImagePoint(P: TPoint): TPoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if FZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if FHorizontalScrollBar.Visible then
      Result.X := Round((FHorizontalScrollBar.Position + P.X) / FZoom)
    else
      Result.X := Round((P.X - X1) / FZoom);
    if FVerticalScrollBar.Visible then
      Result.Y := Round((FVerticalScrollBar.Position + P.Y) / FZoom)
    else
      Result.Y := Round((P.Y - Y1) / FZoom);
  end else
  begin
    if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
      Exit;
    if (FFullImage.Width > GetVisibleImageWidth) or (FFullImage.Height > GetVisibleImageHeight) then
    begin
      if FFullImage.Width / FFullImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FFullImage.Width / FFullImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FFullImage.Height / FFullImage.Width));
      end;
    end else
    begin
      Fh := FFullImage.Height;
      Fw := FFullImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if Fw <> 0 then
      Result.X := Round((P.X - X1) * (FFullImage.Width / Fw));
    if Fh <> 0 then
      Result.Y := Round((P.Y - Y1) * (FFullImage.Height / Fh));
  end;
end;

function TImageViewerControl.ImagePointToBufferPoint(P: TPoint): TPoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if FZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if FHorizontalScrollBar.Visible then
      Result.X := Round(P.X * FZoom - FHorizontalScrollBar.Position)
    else
      Result.X := Round((P.X * FZoom + X1));
    if FVerticalScrollBar.Visible then
      Result.Y := Round(P.Y * FZoom - FVerticalScrollBar.Position)
    else
      Result.Y := Round((P.Y * FZoom + Y1));
  end else
  begin
    if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
      Exit;
    if (FFullImage.Width > GetVisibleImageWidth) or (FFullImage.Height > GetVisibleImageHeight) then
    begin
      if FFullImage.Width / FFullImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FFullImage.Width / FFullImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FFullImage.Height / FFullImage.Width));
      end;
    end else
    begin
      Fh := FFullImage.Height;
      Fw := FFullImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if FFullImage.Width <> 0 then
      Result.X := Round(X1 + P.X * (Fw / FFullImage.Width));
    if FFullImage.Height <> 0 then
      Result.Y := Round(Y1 + P.Y * (Fh / FFullImage.Height));
  end;
end;

procedure TImageViewerControl.ImageViewTimerOnTimer(Sender: TObject);
begin
  FImageViewTimer.Enabled := False;
  if Item.ID > 0 then
    ImageViewCounter.ImageViewed(FContext, Item.ID);
end;

procedure TImageViewerControl.OnApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  R: TRect;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    if not OwnerForm.Active then
      Exit;

    R.TopLeft := ClientToScreen(BoundsRect.TopLeft);
    R.BottomRight := ClientToScreen(BoundsRect.BottomRight);

    if PtInRect(R, Msg.pt) and (WindowFromPoint(Msg.pt) = Handle) then
    begin
      Handled := True;
      Msg.Message := 0;
      if NativeInt(Msg.wParam) < 0 then
        RequestNextImage
      else
        RequestPreviousImage;
    end;
  end;
end;

procedure TImageViewerControl.OnScrollChanged(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if ScrollPos > (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize then
    ScrollPos := (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize;
  RecreateImage;
end;

procedure TImageViewerControl.PmFacePopup(Sender: TObject);
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

  FImFacePopup.Clear;
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_DELETE_INFO]);
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_PEOPLE]);
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_SEARCH]);
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_EDIT_PROFILE]);

  MiCurrentPerson.Visible := (RI.Data <> nil) and (PA.PersonID > 0);
  MiCurrentPersonAvatar.Visible := MiCurrentPerson.Visible;
  MiCurrentPersonSeparator.Visible := MiCurrentPerson.Visible;
  P := TPerson.Create;
  try
    if (PA <> nil) and (PA.PersonID > 0) then
    begin
      FPeopleRepository.FindPerson(PA.PersonID, P);
      MiCreatePerson.Visible := P.Empty;
      if not P.Empty then
      begin
        MiFindPhotosSeparator.Visible := True;
        MiFindPhotos.Visible := True;
        MiCurrentPerson.ImageIndex := FImFacePopup.Add(P.CreatePreview(16, 16), nil);
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
      FPeopleRepository.FillLatestSelections(SelectedPersons);

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
        MI.ImageIndex := FImFacePopup.Add(SelectedPersons[I].CreatePreview(16, 16), nil);
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

procedure TImageViewerControl.PmFacesPopup(Sender: TObject);
var
  FileList: TStrings;
  I, Found: Integer;
  SearchRec: TSearchRec;
  Directory, DetectionMethod: string;
  MI: TMenuItem;
begin
  if AppSettings.ReadBool('FaceDetection', 'Enabled', True) then
    MiFaceDetectionStatus.Caption := L('Disable face detection')
  else
    MiFaceDetectionStatus.Caption := L('Enable face detection');

  MiDetectionMethod.Caption := L('Detection method');
  MiRefreshFaces.Caption := L('Refresh faces');

  DetectionMethod := AppSettings.ReadString('Face', 'DetectionMethod', DefaultCascadeFileName);
  FileList := TStringList.Create;
  try
    Directory := IncludeTrailingBackslash(ProgramDir) + CascadesDirectory;
    Found := FindFirst(Directory + '\*.xml', FaAnyFile, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          FileList.Add(Directory + '\' + SearchRec.Name);
        Found := FindNext(SearchRec);
      end;
    finally
      System.SysUtils.FindClose(SearchRec);
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

procedure TImageViewerControl.ZoomIn;
var
  Z: Real;
begin
  //TbRealSize.Down := False;
  //TbFitToWindow.Down := False;
 // Cursor := CursorZoomInNo;
  if not FZoomerOn and (FImageScale > 1) then
  begin
    FZoomerOn := True;
    if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Min(Z * (1 / 0.8), 16);
    {
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;  }

    //LoadImage_(Sender, True, Z, True);
    FLoadImageSize.cx := FRealImageWidth;
    FLoadImageSize.cy := FRealImageHeight;
    FOnImageRequest(Self, Item, FLoadImageSize.cx, FLoadImageSize.cy);

    {TbrActions.Refresh;
    TbrActions.Realign;    }
  end else
  begin
    if FZoomerOn then
    begin
      Z := FZoom;
    end else
    begin
      if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
      Z := 1 / Z;
    end;

    FZoomerOn := True;
    FZoom := Min(Z * (1 / 0.8), 16);
    ReAlignScrolls(False);
    RecreateImage;
  end;
end;

procedure TImageViewerControl.ZoomOut;
var
  Z: Real;
begin
  //TbRealSize.Down := False;
  //TbFitToWindow.Down := False;
  //Cursor := CursorZoomOutNo;
  if not FZoomerOn and (FImageScale > 1) then
  begin
    FZoomerOn := True;
    if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Max(Z * 0.8, 0.01);
    {TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False; }

    //TODO: LoadImage_(Sender, True, Z, True);

    FLoadImageSize.cx := FRealImageWidth;
    FLoadImageSize.cy := FRealImageHeight;
    FOnImageRequest(Self, Item, FLoadImageSize.cx, FLoadImageSize.cy);

    //TbrActions.Refresh;
    //TbrActions.Realign;
  end else
  begin
    if FZoomerOn then
    begin
      Z := FZoom;
    end else
    begin
      if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
      Z := 1 / Z;
    end;
    FZoomerOn := True;
    FZoom := Max(Z * 0.8, 0.05);
    ReAlignScrolls(False);
    RecreateImage;
  end;
end;

procedure TImageViewerControl.RecreateImage;
var
  Fh, Fw: Integer;
  ZX, ZY, ZW, ZH, X1, X2, Y1, Y2: Integer;
  ImRect, BeginRect: TRect;
  Z, Zoom: Double;
  TempImage, B: TBitmap;
  ACopyRect: TRect;
  ImageEffectiveWidth,
  ImageEffectiveHeight: Integer;

  procedure DrawRect(X1, Y1, X2, Y2: Integer);
  begin
    if FTransparentImage then
    begin
      FDrawimage.Canvas.Brush.Color := Theme.PanelColor;
      FDrawimage.Canvas.Pen.Color := 0;
      FDrawimage.Canvas.Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
    end;
  end;

  procedure ShowInfoText(InfoText, InfoTextLine2: string);
  var
    Text: string;
    TextRect, R: TRect;
  begin
    FDrawImage.Canvas.Font.Color := Theme.PanelFontColor;

    Text := InfoText + #13 + InfoTextLine2;
    R := GetClientRect;
    if R.Right > 300 then
      R.Right := 300;
    DrawText(FDrawImage.Canvas.Handle, Text, Length(Text), R, DT_CENTER or DT_WORDBREAK or DT_CALCRECT);

    TextRect.Left := Width div 2 - R.Width div 2;
    TextRect.Top := Height div 2 - R.Height div 2;
    TextRect.Width := R.Width;
    TextRect.Height := R.Height;

    DrawText(FDrawImage.Canvas.Handle, Text, Length(Text), TextRect, DT_CENTER or DT_WORDBREAK);
  end;

  procedure ShowErrorText(FileName: string);
  var
    MessageText: string;
  begin
    if FileName <> '' then
    begin
      MessageText := L('Can''t display file') + ':';
      ShowInfoText(MessageText, FileName);
    end;
  end;

begin
  FDrawImage.SetSize(Clientwidth, HeightW);

  DrawBackground(FDrawImage.Canvas);

  if FText <> '' then
  begin
    ShowInfoText(FText, '');
    Refresh;
    Exit;
  end;

  if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
  begin
    ShowErrorText(Item.FileName);
    Refresh;
    Exit;
  end;

  if IsRotatedImageProportions(Item.Rotation) then
  begin
    ImageEffectiveWidth := FRealImageHeight;
    ImageEffectiveHeight := FRealImageWidth;
  end else
  begin
    ImageEffectiveWidth := FRealImageWidth;
    ImageEffectiveHeight := FRealImageHeight;
  end;

  if FDrawImage.Height = 0 then
    Exit;
  if ImageEffectiveHeight = 0 then
    Exit;
  if ImageEffectiveWidth = 0 then
    Exit;

  if (ImageEffectiveWidth > ClientWidth) or (ImageEffectiveHeight > HeightW) then
  begin
    if ImageEffectiveWidth / ImageEffectiveHeight < FDrawImage.Width / FDrawImage.Height then
    begin
      FH := FDrawImage.Height;
      FW := Round(FDrawImage.Height * (ImageEffectiveWidth / ImageEffectiveHeight));
    end else
    begin
      FW := FDrawImage.Width;
      FH := Round(FDrawImage.Width * (ImageEffectiveHeight / ImageEffectiveWidth));
    end;
  end else
  begin
    FH := ImageEffectiveHeight;
    FW := ImageEffectiveWidth;
  end;

  X1 := ClientWidth div 2 - FW div 2;
  Y1 := (HeightW) div 2 - FH div 2;
  X2 := X1 + FW;
  Y2 := Y1 + FH;
  ImRect := GetImageRectA;
  ZX := ImRect.Left;
  ZY := ImRect.Top;
  ZW := ImRect.Right - ImRect.Left;
  ZH := ImRect.Bottom - ImRect.Top;

  Zoom := FZoom;
  if FFullImage.Width < FRealImageWidth then
    Zoom := FZoom * ImageEffectiveWidth / FFullImage.Width;

  if FImageExists or FLoading then
  begin
    if not IsFastDrawing then
    begin
      if FZoomerOn and not FIsWaiting then
      begin
        DrawRect(ImRect.Left, ImRect.Top, ImRect.Right, ImRect.Bottom);
        if Zoom <= 1 then
        begin
          if (Zoom < ZoomSmoothMin) then
            StretchCoolW(ZX, ZY, ZW, ZH, Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
                Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom)), FFullImage, FDrawImage)
          else
          begin
            ACopyRect := Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
              Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom));
            TempImage := TBitmap.Create;
            try
              TempImage.PixelFormat := pf24bit;
              TempImage.SetSize(ZW, ZH);
              B := TBitmap.Create;
              try
                B.PixelFormat := Pf24bit;
                B.Width := (ACopyRect.Right - ACopyRect.Left);
                B.Height := (ACopyRect.Bottom - ACopyRect.Top);
                B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), FFullImage.Canvas, ACopyRect);
                SmoothResize(ZW, ZH, B, TempImage);
              finally
                F(B);
              end;
              FDrawImage.Canvas.Draw(ZX, ZY, TempImage);
            finally
              F(TempImage);
            end;
          end;
        end else
          Interpolate(ZX, ZY, ZW, ZH, Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
              Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom)), FFullImage, FDrawImage);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        if FZoomerOn then
          Z := FImageScale * Zoom
        else
        begin
          if FRealImageWidth * FRealImageHeight <> 0 then
          begin
            if IsRotatedImageProportions(Item.Rotation) then
              Z := Zoom * Min(FW / FRealImageHeight, FH / FRealImageWidth)
            else
              Z := Zoom * Min(FW / FRealImageWidth, FH / FRealImageHeight);
          end else
            Z := Zoom;
        end;
        if (Z < ZoomSmoothMin) then
          StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FFullImage, FDrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := Pf24bit;
            TempImage.SetSize(X2 - X1, Y2 - Y1);
            SmoothResize(X2 - X1, Y2 - Y1, FFullImage, TempImage);
            FDrawImage.Canvas.Draw(X1, Y1, TempImage);
          finally
            F(TempImage);
          end;
        end;
      end;
    end else
    begin
      if FZoomerOn and not FIsWaiting then
      begin
        BeginRect := GetImageRectA;
        DrawRect(BeginRect.Left, BeginRect.Top, BeginRect.Right, BeginRect.Bottom);
        SetStretchBltMode(FDrawImage.Canvas.Handle, STRETCH_HALFTONE);
        FDrawImage.Canvas.CopyMode := SRCCOPY;
        FDrawImage.Canvas.CopyRect(BeginRect, FFullImage.Canvas, ImRect);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        SetStretchBltMode(FDrawImage.Canvas.Handle, STRETCH_HALFTONE);
        FDrawImage.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FFullImage);
      end;
    end;
  end else
    ShowErrorText(Item.FileName);

  DrawImageInfo;

  BeginScreenUpdate(Handle);
  try
    RefreshFaces;
  finally
    EndScreenUpdate(Handle, True);
  end;
end;

procedure TImageViewerControl.ReAlignScrolls(IsCenter: Boolean);
begin
  TImageZoomHelper.ReAlignScrolls(IsCenter,
    FHorizontalScrollBar, FVerticalScrollBar, nil,
    TSize.Create(FFullImage.Width, FFullImage.Height),
    TSize.Create(ClientWidth, HeightW),
    FZoom, FZoomerOn);
end;

procedure TImageViewerControl.RefreshFaces;
const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK + DT_CENTER;

var
  I: Integer;
  P1, P2: TPoint;
  Rct, R, FaceTextRect: TRect;
  PA: TPersonArea;
  P: TPerson;

  procedure DrawFaceText(Text: string);
  begin
    R := Rect(R.Left, R.Bottom + 8, Max(R.Left + 20, R.Right), R.Bottom + 500);
    Rct := R;
    FOverlayBuffer.Canvas.Font := Font;
    FOverlayBuffer.Canvas.Font.Color := Theme.GradientText;
    DrawText(FOverlayBuffer.Canvas.Handle, PChar(Text), Length(Text), R, DrawTextOpt or DT_CALCRECT);
    R.Right := Max(R.Right, Rct.Right);
    FaceTextRect := R;
    InflateRect(R, 4, 4);
    DrawRoundGradientVert(FOverlayBuffer, R, Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, 8, 220);
    DrawText(FOverlayBuffer.Canvas.Handle, PChar(Text), Length(Text), FaceTextRect, DrawTextOpt);
  end;

  procedure DrawFace(Face: TFaceDetectionResultItem; Hightligh: Boolean = False);
  var
    S: string;
  begin
    FOverlayBuffer.Canvas.Brush.Style := bsClear;
    FOverlayBuffer.Canvas.Pen.Style := psDash;
    FOverlayBuffer.Canvas.Pen.Width := 1;

    P1 := Face.Rect.TopLeft;
    P2 := Face.Rect.BottomRight;

    P1 := PxMultiply(P1, Face.ImageSize, FFullImage);
    P2 := PxMultiply(P2, Face.ImageSize, FFullImage);

    P1 := ImagePointToBufferPoint(P1);
    P2 := ImagePointToBufferPoint(P2);
    R := Rect(P1, P2);

    if Hightligh then
      MixWithColor(FOverlayBuffer, 127, Theme.PanelColor, R);

    FOverlayBuffer.Canvas.Pen.Color := Theme.PanelColor;
    FOverlayBuffer.Canvas.Rectangle(R);
    InflateRect(R, -1, -1);
    FOverlayBuffer.Canvas.Pen.Color := clGray;
    FOverlayBuffer.Canvas.Rectangle(R);
    if Face.Data <> nil then
    begin
      PA := TPersonArea(Face.Data);

      P := TPerson.Create;
      try
        FPeopleRepository.FindPerson(PA.PersonID, P);
        if not P.Empty or (PA.PersonID = -1) then
        begin
          if not P.Empty then
            S := P.Name
          else
            S := L('New person');

          DrawFaceText(S);
        end;
      finally
        F(P);
      end;
    end else
      DrawFaceText(L('Click to select person'));
  end;

begin
  if (FFaces.Count > 0) or FDrawingFace then
  begin
    FOverlayBuffer.Assign(FDrawImage);

    if not ShiftKeyDown and not FDisplayAllFaces then
    begin
      if FHoverFace <> nil then
        DrawFace(FHoverFace, FIsHightlitingPerson);
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

procedure TImageViewerControl.ReloadCurrent;
begin
  if FText = '' then
    FOnImageRequest(Self, Item, Screen.DesktopWidth, Screen.DesktopHeight);
end;

procedure TImageViewerControl.RequestNextImage;
begin
  if Assigned(FOnRequestNextImage) then
    FOnRequestNextImage(Self);
end;

procedure TImageViewerControl.RequestPreviousImage;
begin
  if Assigned(FOnRequestPreviousImage) then
    FOnRequestPreviousImage(Self);
end;

procedure TImageViewerControl.HightliteReset;
begin
  FIsHightlitingPerson := False;
  FHOverFace := nil;
  RefreshFaces;
end;

procedure TImageViewerControl.Resize;
var
  W, H: Integer;
  Size: TSize;
begin
  inherited;

  Size.cx := ClientWidth;
  Size.cy := HeightW;
  FDrawImage.SetSize(Size.cx, Size.cy);

  W := FRealImageWidth;
  H := FRealImageHeight;
  ProportionalSize(Size.cx, Size.cy, W, H);
  if ((W > FLoadImageSize.cx) or (H > FLoadImageSize.cy)) and (FText = '') then
  begin
    FLoadImageSize.cx := Screen.DesktopWidth;
    FLoadImageSize.cy := Screen.DesktopHeight;
    FOnImageRequest(Self, Item, Screen.DesktopWidth, Screen.DesktopHeight);
  end;

  if not FIsWaiting then
    ReAlignScrolls(False);

  FLsLoading.Left := ClientWidth div 2 - FLsLoading.Width div 2;
  FLsLoading.Top := ClientHeight div 2 - FLsLoading.Height div 2;

  RecreateImage;
  CheckFaceIndicatorVisibility;
end;

procedure TImageViewerControl.RotateCCW;
var
  Info : TMediaItemCollection;
begin
  Info := TMediaItemCollection.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;

    BatchProcessingForm.RotateImages(TDBForm(Self.OwnerForm), Info, DB_IMAGE_ROTATE_270, True);

    FLockEventRotateFileList.Add(AnsiLowerCase(Item.FileName));
    Exchange(FRealImageWidth, FRealImageHeight);
    Rotate270A(FFullImage);
    FFaces.RotateLeft;
    //if FZoomerOn then
    //  FitToWindowClick(Sender);

    ReAlignScrolls(True);
    RecreateImage;
  finally
    F(Info);
  end;
end;

procedure TImageViewerControl.RotateCW;
var
  Info: TMediaItemCollection;
begin
  Info := TMediaItemCollection.Create;
  try
    Info.Add(Item.Copy);
    Info[0].Selected := True;

    BatchProcessingForm.RotateImages(TDBForm(Self.OwnerForm), Info, DB_IMAGE_ROTATE_90, True);

    FLockEventRotateFileList.Add(AnsiLowerCase(Item.FileName));

    Rotate90A(FFullImage);
    Exchange(FRealImageWidth, FRealImageHeight);
    FFaces.RotateRight;
    //if FZoomerOn then
    //  FitToWindowClick(Sender);

    ReAlignScrolls(True);
    RecreateImage;
  finally
    F(Info);
  end;
end;

procedure TImageViewerControl.SelectCascade(Sender: TObject);
var
  FileName: string;
begin
  FileName := StringReplace(TMenuItem(Sender).Caption, '&', '', [RfReplaceAll]);
  AppSettings.WriteString('Face', 'DetectionMethod', FileName);
  ReloadCurrent;
end;

procedure TImageViewerControl.SelectPerson(P: TPerson);
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
      CollectionAddItemForm.Execute(Item);
    end;

    if Item.ID <> 0 then
    begin
      if (PA = nil) or (PA.PersonID <= 0) then
      begin
        PA := TPersonArea.Create(Item.ID, P.ID, RI);
        try
          FPeopleRepository.AddPersonForPhoto(TDBForm(Self.OwnerForm), PA);
          RI.Data := PA.Clone;

        finally
          F(PA);
        end;
      end else
        FPeopleRepository.ChangePerson(PA, P.ID);

      if FImageViewer <> nil then
        FImageViewer.UpdateFaces(FItem.FileName, FFaces);

      RefreshFaces;
    end;
  end;
end;

procedure TImageViewerControl.HightlitePerson(PersonID: Integer);
var
  I: Integer;
begin
  FHoverFace := nil;
  for I := 0 to FFaces.Count - 1 do
    if FFaces[I].Data <> nil then
      if TPersonArea(FFaces[I].Data).PersonID = PersonID then
      begin
        FHoverFace := FFaces[I];
        FIsHightlitingPerson := True;
        RefreshFaces;
        Break;
      end;
end;

procedure TImageViewerControl.SelectPreviousPerson(Sender: TObject);
var
  P: TPerson;
  PersonID: Integer;
begin
  P := TPerson.Create;
  try
    PersonID := TMenuItem(Sender).Tag;
    FPeopleRepository.FindPerson(PersonID, P);
    if not P.Empty then
      SelectPerson(P);
  finally
    F(P);
  end;
end;

procedure TImageViewerControl.SetExplorer(const Value: TCustomExplorerForm);
begin
  FExplorer := Value;
end;

procedure TImageViewerControl.SetFaceDetectionControls(AWlFaceCount: TWebLink;
  ALsDetectingFaces: TLoadingSign; ATbrActions: TToolBar);
begin
  FWlFaceCount := AWlFaceCount;
  FWlFaceCount.PopupMenu := PmFaces;
  FWlFaceCount.OnClick := WlFaceCountClick;
  FWlFaceCount.OnMouseEnter := WlFaceCountMouseEnter;
  FWlFaceCount.OnMouseLeave := WlFaceCountMouseLeave;
  FLsDetectingFaces := ALsDetectingFaces;
  FTbrActions := ATbrActions;
end;

procedure TImageViewerControl.SetShowInfo(const Value: Boolean);
begin
  FShowInfo := Value;
  AppSettings.WriteBool('Viewer', 'DisplayInfo', Value);
  RecreateImage;
end;

procedure TImageViewerControl.SetText(Text: string);
begin
  FText := Text;
  StopLoadingImage;
  FFaces.Clear;
  if FImageViewer <> nil then
    FImageViewer.UpdateFaces(FItem.FileName, FFaces);

  FOverlayBuffer.SetSize(0, 0);
  CheckFaceIndicatorVisibility;
  RecreateImage;
end;

procedure TImageViewerControl.StartLoadingImage;
begin
  FImageViewTimer.Enabled := False;
  FIsWaiting := True;
  FLsLoading.RecteateImage;
  FLsLoading.Show;
end;

procedure TImageViewerControl.StartPersonSelection;
begin
  MiDrawFaceClick(MiDrawFace);
end;

procedure TImageViewerControl.StopLoadingImage;
begin
  FIsWaiting := False;
  FLsLoading.Hide;
end;

procedure TImageViewerControl.StopPersonSelection;
begin
  FIsSelectingFace := False;
  UpdateCursor;
  RecreateImage;
  if Assigned(FOnStopPersonSelection) then
    FOnStopPersonSelection(Self);
end;

procedure TImageViewerControl.UpdateCursor;
begin
  if FDrawingFace or ShiftKeyDown or FIsSelectingFace then
    Cursor := crCross
  else
    Cursor := crDefault;
end;

procedure TImageViewerControl.ChangeContext;
begin
  FContext := DBManager.DBContext;
  FPeopleRepository := FContext.People;
end;

procedure TImageViewerControl.ChangedDBDataByID(Sender: TObject; ID: Integer;
  Params: TEventFields; Value: TEventValues);
var
  I: Integer;
begin
  if Params * [EventID_Param_DB_Changed] <> [] then
     ChangeContext;

  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(FItem.FileName) = AnsiLowerCase(Value.FileName) then
    begin
      FItem.ID := ID;
      FItem.Date := Value.Date;
      FItem.Time := Value.Time;
      FItem.IsDate := True;
      FItem.IsTime := Value.IsTime;
      FItem.Rating := Value.Rating;
      FItem.Rotation := Value.Rotation;
      FItem.Comment := Value.Comment;
      FItem.KeyWords := Value.Comment;
      FItem.Links := Value.Links;
      FItem.Groups := Value.Groups;
      FItem.IsDate := True;
      FItem.IsTime := Value.IsTime;
      FItem.InfoLoaded := True;
      FItem.Encrypted := Value.IsEncrypted;
      FItem.Links := Value.Links;
    end;
  end;

  if [EventID_Param_Rotate, EventID_Param_Image, EventID_Param_Name] * Params <> [] then
  begin
    for I := 0 to FLockEventRotateFileList.Count - 1 do
      if AnsiLowerCase(Value.FileName) = FLockEventRotateFileList[I] then
      begin
        FLockEventRotateFileList.Delete(I);
        Exit;
      end;
  end;

  if Id = Item.ID then
  begin
    if (EventID_Param_Rotate in Params) then
      Item.Rotation := Value.Rotation;
    if (EventID_Param_Rotate in Params) or (EventID_Param_Image in Params) and (Text = '') then
      FOnImageRequest(Sender, Item, Screen.DesktopWidth, Screen.DesktopHeight);
  end;
end;

procedure TImageViewerControl.CheckFaceIndicatorVisibility;
var
  IsDevice: Boolean;
begin
  if FTbrActions = nil then
    Exit;

  IsDevice := IsDevicePath(Item.FileName);
  FWlFaceCount.Visible := (FWlFaceCount.Left + FWlFaceCount.Width + 3 < FTbrActions.Left) and FIsStaticImage and FaceDetectionManager.IsActive and not IsDevice and (FText = '');
  FLsDetectingFaces.Visible := ((FLsDetectingFaces.Left + FLsDetectingFaces.Width + 3 < FTbrActions.Left) and not FFaceDetectionComplete) and FIsStaticImage and AppSettings.ReadBool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive and FaceDetectionManager.IsActive and not IsDevice and (FText = '');
end;

procedure TImageViewerControl.UpdateFaceDetectionState;
var
  IsDetectionActive: Boolean;
begin
  if Visible and not HandleAllocated then
    Exit;
  if FWlFaceCount = nil then
    Exit;

  BeginScreenUpdate(Handle);
  try
    IsDetectionActive := AppSettings.ReadBool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive;
    if not FFaceDetectionComplete and IsDetectionActive then
    begin
      FWlFaceCount.Text := L('Detecting faces') + '...';
      FLsDetectingFaces.Show;
      FWlFaceCount.ImageIndex := -1;
      FWlFaceCount.IconWidth := 0;
      FWlFaceCount.IconHeight := 0;
      FWlFaceCount.Left := FLsDetectingFaces.Left + FLsDetectingFaces.Width + 2;
    end else
    begin
      FLsDetectingFaces.Hide;
      FWlFaceCount.Left := 6;
      FWlFaceCount.IconWidth := 16;
      FWlFaceCount.IconHeight := 16;
      FWlFaceCount.ImageIndex := DB_IC_PEOPLE;
      if IsDetectionActive then
      begin
        if FFaces.Count > 0 then
          FWlFaceCount.Text := Format(L('Faces: %d'), [FFaces.Count])
        else
          FWlFaceCount.Text := L('No faces found');
      end else
      begin
        FWlFaceCount.Text := L('Face detection disabled');
      end;
    end;
    CheckFaceIndicatorVisibility;
  finally
    EndScreenUpdate(Handle, False);
  end;
end;

procedure TImageViewerControl.UpdateFaces(FileName: string;
  Faces: TFaceDetectionResult);
begin
  if Faces = FFaces then
    Exit;

  if Item.FileName = FileName then
  begin
    FFaces.Assign(Faces);
    FFaceDetectionComplete := True;
    UpdateFaceDetectionState;
    RecreateImage;
  end;
end;

procedure TImageViewerControl.UpdateItemInfo(Item: TMediaItem);
begin
  if FItem = nil then
    FItem := Item.Copy
  else
    FItem.Assign(Item);
end;

procedure TImageViewerControl.WlFaceCountClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PmFaces.DoPopupEx(P.X, P.Y);
end;

procedure TImageViewerControl.WlFaceCountMouseEnter(Sender: TObject);
begin
  FDisplayAllFaces := True;
  RefreshFaces;
end;

procedure TImageViewerControl.WlFaceCountMouseLeave(Sender: TObject);
begin
  FDisplayAllFaces := False;
  RefreshFaces;
end;

end.
