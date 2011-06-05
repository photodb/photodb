unit UnitFormCont;

interface

uses
  Clipbrd, DBCMenu, ComCtrls, CommCtrl, ImgList, ExtCtrls, StdCtrls,
  UnitDBKernel, db, Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, GraphicCrypt, ShellContextMenu, GraphicsCool,
  Dialogs, Activex, jpeg, Menus, Buttons, acDlgSelect,  Math,
  DropSource, DropTarget, AppEvnts, WebLink, MPCommonUtilities, uVistaFuncs,
  UnitBitmapImageList, EasyListview, DragDropFile, DragDrop, uShellIntegration,
  ToolWin, PanelCanvas, UnitPanelLoadingBigImagesThread, UnitDBDeclare,
  UnitDBFileDialogs, UnitPropeccedFilesSupport, UnitDBCommonGraphics,
  UnitDBCommon, uCDMappingTypes, uLogger, uConstants, uThreadForm,
  uListViewUtils, uDBDrawing, uFileUtils, uResources, pngimage, TwButton,
  uGOM, uMemory, uFormListView, uTranslate, uDBPopupMenuInfo, uPNGUtils,
  uGraphicUtils, uDBBaseTypes, uSysUtils, uDBUtils, uDBFileTypes,
  uRuntime, uSettings, uAssociations;

type
  TDestDype = class(TObject)
  public
    Dest: string;
    Files: TStrings;
    constructor Create;
    destructor Destroy; override;
  end;

type
  TFormCont = class(TListViewForm)
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    SelectAll1: TMenuItem;
    Clear1: TMenuItem;
    Close1: TMenuItem;
    N1: TMenuItem;
    SaveToFile1: TMenuItem;
    LoadFromFile1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Panel3: TPanel;
    SaveDialog1: TSaveDialog;
    Hinttimer: TTimer;
    SlideShow1: TMenuItem;
    ImageList1: TImageList;
    ApplicationEvents1: TApplicationEvents;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget2: TDropFileTarget;
    Label2: TLabel;
    WlConvert: TWebLink;
    GbImageInfo: TGroupBox;
    Label1: TLabel;
    Image1: TImage;
    LabelName: TLabel;
    LabelID: TLabel;
    LabelSize: TLabel;
    ExportLink: TWebLink;
    ExCopyLink: TWebLink;
    Rename1: TMenuItem;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    TbResize: TToolButton;
    ToolBarImageList: TImageList;
    TbConvert: TToolButton;
    TbExport: TToolButton;
    TbCopy: TToolButton;
    ToolButton5: TToolButton;
    TbClose: TToolButton;
    TbSeparator: TToolButton;
    TbZoomIn: TToolButton;
    TbZoomOut: TToolButton;
    BigImagesTimer: TTimer;
    WlResize: TWebLink;
    RedrawTimer: TTimer;
    TbStop: TToolButton;
    ToolButton11: TToolButton;
    ToolBarDisabledImageList: TImageList;
    TerminateTimer: TTimer;
    RatingPopupMenu1: TPopupMenu;
    N00: TMenuItem;
    N01: TMenuItem;
    N02: TMenuItem;
    N03: TMenuItem;
    N04: TMenuItem;
    N05: TMenuItem;
    PopupMenuZoomDropDown: TPopupMenu;
    TwWindowsPos: TTwButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RefreshItemByID( ID: integer);
    function AddNewItem(Image : TBitmap; Info : TDBPopupMenuInfoRecord): Boolean;
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeleteIndexItemFromPopUpMenu(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Close1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure SaveToFile1Click(Sender: TObject);
    procedure HinttimerTimer(Sender: TObject);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure SlideShow1Click(Sender: TObject);
    function ExistsItemById(id : integer) : Boolean;
    function ExistsItemByFileName(FileName : string) : Boolean;
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure WlResizeClick(Sender: TObject);
    procedure WlConvertClick(Sender: TObject);
    procedure ExportLinkClick(Sender: TObject);
    procedure ExCopyLinkClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TEasyItem;
      Selected: Boolean);
    function GetListItemByID( ID : integer): TEasyItem;
    procedure TbZoomInClick(Sender: TObject);
    procedure TbZoomOutClick(Sender: TObject);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure TbStopClick(Sender: TObject);
    procedure TerminateTimerTimer(Sender: TObject);
    procedure N05Click(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure TwWindowsPosChange(Sender: TObject);
  private
    { protected declarations }
    MouseDowned: Boolean;
    PopupHandled: Boolean;
    LastMouseItem, ItemWithHint: TEasyItem;
    ElvMain: TEasyListView;
    FilePushed: Boolean;
    FilePushedName: string;
    Data: TDBPopupMenuInfo;
    FilesToDrag: TStringList;
    DBCanDrag: Boolean;
    DBDragPoint: TPoint;
    WindowsMenuTickCount: Cardinal;
    ItemByMouseDown: Boolean;
    ItemSelectedByMouseDown: Boolean;
    FPictureSize: Integer;
    FBitmapImageList: TBitmapImageList;
    FWorkerThreadCount: Integer;
    procedure DeleteIndexItemByID(ID : integer);
    procedure EasyListview1ItemThumbnailDraw(
      Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
      ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure EasyListview1DblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
      ShiftState: TShiftState; var Handled: Boolean);
    procedure EasyListview1ItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    Procedure ListView1Resize(Sender : TObject);
    procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);
    Function ListView1Selected : TEasyItem;
    Function ItemAtPos(X,Y : integer): TEasyItem;
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    Function SelCount : integer;
    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    function HintCallBack(Info: TDBPopupMenuInfoRecord): Boolean;
  protected
    { Protected declarations }
    function GetFormID : string; override;
    function GetListView : TEasyListview; override;
    function InternalGetImage(FileName : string; Bitmap : TBitmap; var Width: Integer; var Height: Integer) : Boolean; override;
  public
    { Public declarations }
    WindowID: TGUID;
    SID: TGUID;
    BigImagesSID: TGUID;
    procedure AddFileName(FileName: string);
    procedure ZoomOut;
    procedure ZoomIn;
    function GetVisibleItems: TArStrings;
    function FileNameExistsInList(FileName: string): Boolean;
    procedure ReplaseBitmapWithPath(FileName: string; Bitmap: TBitmap);
//    procedure AddThread;
    procedure BigSizeCallBack(Sender: TObject; SizeX, SizeY: Integer);
    procedure LoadLanguage;
    procedure LoadToolBarIcons;
    procedure LoadSizes;
    procedure CreateBackgroundImage;
    procedure ClearList;
    procedure AddWorkerThread;
    procedure RemoveWorkerThread;
  published
    property PictureSize : Integer read FPictureSize;
  end;

  TManagePanels = class(TObject)
  private
    FPanels: TList;
    function GetPanelByIndex(Index: Integer): TFormCont;
  public
    constructor Create;
    destructor Destroy; override;
    function PanelIndex(Panel: TFormCont) : Integer;
    function NewPanel: TFormCont;
    procedure FreePanel(Panel: TFormCont);
    procedure AddPanel(Panel: TFormCont);
    procedure RemovePanel(Panel: TFormCont);
    procedure GetPanelsTexts(List: TStrings);
    function ExistsPanel(Panel: TForm; CID: TGUID): Boolean;
    function Count: Integer;
    function IsPanelForm(Panel: TForm): Boolean;
    property Items[index: Integer]: TFormCont read GetPanelByIndex; default;
    procedure FillSendToPanelItems(MenuItem: TMenuItem; OnClick: TNotifyEvent);
  end;

var
  ManagerPanels : TManagePanels = nil;

implementation

uses UnitImHint, UnitLoadFilesToPanel, UnitHintCeator,
     SlideShow, ExplorerUnit, UnitSizeResizerForm, CommonDBSupport,
     UnitStringPromtForm, UnitBigImagesSize, FormManegerUnit;

{$R *.dfm}

{ TDestDype }

constructor TDestDype.Create;
begin
  Files := TStringList.Create;
end;

destructor TDestDype.Destroy;
begin
  F(Files);
  inherited;
end;

{ TFormCont }

procedure TFormCont.RefreshItemByID(ID: Integer);
var
  Index: Integer;
  FData: TDBPopupMenuInfo;
begin
  FData := TDBPopupMenuInfo.Create;
  try
    Index := GetListItemByID(Id).Index;
    FData.Add(Data[index].Copy);

    TPanelLoadingBigImagesThread.Create(Self, BigImagesSID, nil, FPictureSize, FData);
  finally
    F(FData);
  end;
end;

procedure TFormCont.RemoveWorkerThread;
begin
  Dec(FWorkerThreadCount);
  if FWorkerThreadCount = 0 then
    TbStop.Enabled := False;
end;

procedure TFormCont.CreateBackgroundImage;
var
  BackgroundImage : TPNGImage;
  Bitmap, SearchBackgroundBMP : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Canvas.Brush.Color := clWindow;
    Bitmap.Canvas.Pen.Color := clWindow;
    Bitmap.Width := 120;
    Bitmap.Height := 120;

    BackgroundImage := GetImagePanelImage;
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

procedure TFormCont.FormCreate(Sender: TObject);
begin
  FWorkerThreadCount := 0;
  Data := TDBPopupMenuInfo.Create;
  FilesToDrag := TStringList.Create;
  FilePushedName := '';
//  FThreadCount := 0;
  SID := GetGUID;
  BigImagesSID := GetGUID;
  FPictureSize := ThSizePanelPreview;
  ElvMain := TEasyListView.Create(Self);
  ElvMain.Parent := Self;
  ElvMain.Align := AlClient;

  MouseDowned := False;
  PopupHandled := False;
  ElvMain.BackGround.Enabled := True;
  ElvMain.BackGround.Tile := False;
  ElvMain.BackGround.AlphaBlend := True;
  ElvMain.BackGround.OffsetTrack := True;
  ElvMain.BackGround.BlendAlpha := 220;
  CreateBackgroundImage;

  ElvMain.Font.Color := 0;
  ElvMain.View := ElsThumbnail;
  ElvMain.DragKind := DkDock;
  ElvMain.HotTrack.Color := clWindowText;

  SetLVSelection(ElvMain, True);

  FPictureSize := Max(85, ThSizePanelPreview);
  LoadSizes;

  ElvMain.IncrementalSearch.Enabled := True;
  ElvMain.OnItemThumbnailDraw := EasyListview1ItemThumbnailDraw;

  ElvMain.OnDblClick := EasyListview1DblClick;

  ElvMain.OnIncrementalSearch := Listview1IncrementalSearch;
  ElvMain.OnMouseDown := ListView1MouseDown;
  ElvMain.OnMouseUp := ListView1MouseUp;
  ElvMain.OnMouseMove := ListView1MouseMove;
  ElvMain.OnItemSelectionChanged := EasyListview1ItemSelectionChanged;
  ElvMain.OnMouseWheel := ListView1MouseWheel;
  ElvMain.OnResize := ListView1Resize;
  ElvMain.Groups.Add;
  ElvMain.HotTrack.Cursor := CrArrow;

  WindowID := GetGUID;
  FilePushed := False;
  LoadLanguage;

  ElvMain.HotTrack.Enabled := Settings.Readbool('Options', 'UseHotSelect', True);

  DropFileTarget2.Register(Self);
  FBitmapImageList := TBitmapImageList.Create;
  ManagerPanels.AddPanel(Self);
  ElvMain.DoubleBuffered := True;

  ManagerPanels.AddPanel(Self);

  Caption := Format(L('Panel (%d)'), [ManagerPanels.PanelIndex(Self) + 1]);

  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  PopupMenu1.Images := DBKernel.ImageList;
  Copy1.ImageIndex := DB_IC_COPY;
  Paste1.ImageIndex := DB_IC_PASTE;
  LoadFromFile1.ImageIndex := DB_IC_LOADFROMFILE;
  SaveToFile1.ImageIndex := DB_IC_SAVETOFILE;
  SelectAll1.ImageIndex := DB_IC_SELECTALL;
  Close1.ImageIndex := DB_IC_EXIT;
  Clear1.ImageIndex := DB_IC_DELETE_INFO;
  SlideShow1.ImageIndex := DB_IC_SLIDE_SHOW;

  Rename1.ImageIndex := DB_IC_RENAME;

  WlResize.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_RESIZE + 1]);
  WlConvert.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CONVERT + 1]);
  ExportLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EXPORT_IMAGES + 1]);
  ExCopyLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_COPY + 1]);

  RatingPopupMenu1.Images := DBkernel.ImageList;

  N00.ImageIndex := DB_IC_DELETE_INFO;
  N01.ImageIndex := DB_IC_RATING_1;
  N02.ImageIndex := DB_IC_RATING_2;
  N03.ImageIndex := DB_IC_RATING_3;
  N04.ImageIndex := DB_IC_RATING_4;
  N05.ImageIndex := DB_IC_RATING_5;

  WlConvert.Top := WlResize.Top + WlResize.Height + 5;
  ExportLink.Top := WlConvert.Top + WlConvert.Height + 5;
  ExCopyLink.Top := ExportLink.Top + ExportLink.Height + 5;
  LoadToolBarIcons;
  FormManager.RegisterMainForm(Self);
end;

procedure TFormCont.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ManagerPanels.RemovePanel(Self);
  TerminateTimer.Enabled := True;
end;

procedure TFormCont.ListView1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
  Info: TDBPopupMenuInfo;
  Item: TEasyItem;
  Menus: TArMenuItem;
  FileNames: TStrings;
begin
  if CopyFilesSynchCount > 0 then
    WindowsMenuTickCount := GetTickCount;

  Item := ItemByPointImage(ElvMain, Point(MousePos.X, MousePos.Y));
  if (Item = nil) or ((MousePos.X = -1) and (MousePos.Y = -1)) then
    Item := ElvMain.Selection.First;

  HintTimer.Enabled := False;
  if Item <> nil then
  begin
    LastMouseItem := nil;
    Application.HideHint;
    THintManager.Instance.CloseHint;

    Hinttimer.Enabled := False;
    Info := GetCurrentPopUpMenuInfo(Item);
    try
      Info.AttrExists := False;
      if not(GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
      begin
        Info.IsPlusMenu := False;
        Info.IsListItem := False;
        Setlength(Menus, 1);
        Menus[0] := Tmenuitem.Create(nil);
        Menus[0].Caption := L('Delete item from list');
        Menus[0].Tag := Item.index;
        Menus[0].ImageIndex := DB_IC_DELETE_INFO;
        Menus[0].OnClick := DeleteIndexItemFromPopUpMenu;
        TDBPopupMenu.Instance.ExecutePlus(Self, ElvMain.ClientToScreen(MousePos).X, ElvMain.ClientToScreen(MousePos).Y, Info,
          Menus);
      end else
      begin
        FileNames := TStringList.Create;
        try
          for I := 0 to Info.Count - 1 do
            if Info[I].Selected then
              FileNames.Add(Info[I].FileName);

          GetProperties(FileNames, MousePos, ElvMain);
        finally
          F(FileNames);
        end;
      end;
    finally
      F(Info);
    end;

  end else
    PopupMenu1.Popup(ElvMain.ClientToScreen(MousePos).X, ElvMain.ClientToScreen(MousePos).Y);
end;

procedure TFormCont.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  MenuInfo: TDBPopupMenuInfo;
  Item, Itemsel: TEasyItem;
begin
  Item := ItemAtPos(x,y);
  if (Item = nil) and not CtrlKeyDown then
     ElvMain.Selection.ClearAll;

  MouseDowned := Button = MbRight;
  ItemSel := Item;
  ItemByMouseDown := False;

  EnsureSelectionInListView(ElvMain, ItemSel, Shift, X, Y, ItemSelectedByMouseDown, ItemByMouseDown);

  WindowsMenuTickCount := GetTickCount;
  if (Button = MbLeft) and (Item <> nil) then
  begin
    DBCanDrag := True;
    FilesToDrag.Clear;
    GetCursorPos(DBDragPoint);
    MenuInfo := GetCurrentPopUpMenuInfo(Item);
    try
      for I := 0 to MenuInfo.Count - 1 do
        if ElvMain.Items[I].Selected then
          if FileExistsSafe(MenuInfo[I].FileName) then
            FilesToDrag.Add(MenuInfo[I].FileName);

      if FilesToDrag.Count = 0 then
        DBCanDrag := False;
    finally
      F(MenuInfo);
    end;
  end;
end;

procedure TFormCont.DeleteIndexItemByID(ID : integer);
var
  I, J: Integer;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if I > ElvMain.Items.Count - 1 then
      Break;
    if Data[I].ID = ID then
    begin
      ElvMain.Items.Delete(I);
      Data.Delete(I);
      FBitmapImageList.Delete(ElvMain.Items[I].ImageIndex);
      for J := I to ElvMain.Items.Count - 1 do
        ElvMain.Items[J].ImageIndex := ElvMain.Items[J].ImageIndex - 1;
    end;
  end;
end;

procedure TFormCont.DeleteIndexItemFromPopUpMenu(Sender: TObject);
var
  I, J: Integer;
  P_i: Pinteger;
begin
  P_i := @I;
  ElvMain.Groups.BeginUpdate(True);
  try
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      if I > ElvMain.Items.Count - 1 then
        Break;
      if ElvMain.Items[I].Selected then
      begin
        FBitmapImageList.Delete(ElvMain.Items[I].ImageIndex);
        ElvMain.Items.Delete(I);
        ElvMain.Groups.Rebuild(True);
        Data.Delete(I);
        for J := I to ElvMain.Items.Count - 1 do
          ElvMain.Items[J].ImageIndex := ElvMain.Items[J].ImageIndex - 1;

        P_i^ := I - 1;
      end;
    end;
  finally
    ElvMain.Groups.EndUpdate;
  end;
end;

procedure TFormCont.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  I, ReRotation: Integer;
  Item: TEasyItem;
  RefreshParams: TEventFields;
begin
  if EventID_Repaint_ImageList in params then
  begin
    ElvMain.Refresh;
    Exit;
  end;

  if ID = -2 then
    Exit;
  ReRotation := 0;

  for I := 0 to Data.Count - 1 do
    if Data[I].ID = ID then
    begin
      if EventID_Param_Rotate in Params then
      begin
        ReRotation := GetNeededRotation(Data[I].Rotation, Value.Rotate);
        Data[I].Rotation := Value.Rotate;
      end;

      if EventID_Param_Private in Params then
        Data[I].Access := Value.Access;
      if EventID_Param_KeyWords in Params then
        Data[I].KeyWords := Value.KeyWords;
      if EventID_Param_Crypt in Params then
        Data[I].Crypted := Value.Crypt;
      if EventID_Param_Date in Params then
        Data[I].Date := Value.Date;
      if EventID_Param_Time in Params then
        Data[I].Time := Value.Time;
      if EventID_Param_Rotate in Params then
        Data[I].Rotation := Value.Rotate;
      if EventID_Param_Rating in Params then
        Data[I].Rating := Value.Rating;
      if EventID_Param_Comment in Params then
        Data[I].Comment := Value.Comment;
      if EventID_Param_IsDate in Params then
        Data[I].IsDate := Value.IsDate;
      if EventID_Param_IsTime in Params then
        Data[I].IsTime := Value.IsTime;
      if EventID_Param_Groups in Params then
        Data[I].Groups := Value.Groups;
      if EventID_Param_Links in Params then
        Data[I].Links := Value.Links;
      if EventID_Param_Name in Params then
      begin
        if Value.NewName <> '' then
          Data[I].FileName := Value.NewName
        else
          Data[I].FileName := Value.Name;
        Item := GetListItemById(Id);
          if Item <> nil then
            Item.Caption := ExtractFileName(Data[I].FileName);
      end;
      if EventID_Param_Include in params then
      begin
        Data[I].Include := Value.Include;
        Item := GetListItemById(Id);
        if Item <> nil then
          if Item.Data <> nil then
            Boolean(TDataObject(Item.Data).Include) := Value.Include;
        Item.BorderColor := GetListItemBorderColor(TDataObject(Item.Data));
      end;
    end;

  if [EventID_Param_Rotate] * Params <> [] then
  begin
    for I := 0 to Data.Count - 1 do
      if Data[I].ID = ID then
      begin
        if ElvMain.Items[I].ImageIndex > -1 then
          ApplyRotate(FBitmapImageList[ElvMain.Items[I].ImageIndex].Bitmap, ReRotation);
      end;
  end;

  if (EventID_Param_Image in Params) then
    if GetListItemById(Id) <> nil then
    begin
      // TODO: normal image
      RefreshItemByID(Id);
    end;

  if [EventID_Param_Include,
      EventID_Param_Rotate,
      EventID_Param_Private,
      EventID_Param_Access,
      EventID_Param_Crypt,
      EventID_Param_Rating ] * Params <> [] then
    ElvMain.Refresh;

  if (EventID_Param_Delete in Params) then
    DeleteIndexItemByID(ID);

  if SetNewIDFileData in Params then
  begin
    for I := 0 to Data.Count - 1 do
      if AnsiLowerCase(Data[I].FileName) = Value.Name then
      begin
        Data[I].ID := ID;
        Data[I].IsDate := True;
        Data[I].IsTime := Value.IsTime;
        Data[I].Date := Value.Date;
        Data[I].Time := Value.Time;
        Data[I].Rating := Value.Rating;
        Data[I].Crypted := Value.Crypt;
        Data[I].Comment := Value.Comment;
        Data[I].Keywords := Value.Keywords;
        Data[I].Links := Value.Links;
        Data[I].Groups := Value.Groups;
        ElvMain.Refresh;
        Break;
      end;
    Exit;
  end;

  RefreshParams := [EventID_Param_Private, EventID_Param_Rotate, EventID_Param_Name, EventID_Param_Rating,
    EventID_Param_Crypt];
  if RefreshParams * Params <> [] then
    ElvMain.Repaint;

  if [EventID_Param_DB_Changed] * Params <> [] then
    Close;
end;

function TFormCont.AddNewItem(Image : Tbitmap; Info : TDBPopupMenuInfoRecord): Boolean;
var
  New: TEasyItem;
begin
  Result := False;
  if Info = nil then
    Exit;

  if Info.Id <> 0 then
  begin
    if ExistsItemById(Info.Id) then
      Exit;
  end else
  begin
    if ExistsItemByFileName(Info.FileName) then
      Exit;
  end;

  New := ElvMain.Items.Add;

  New.Tag := Info.ID;
  New.Data := TDataObject.Create;
  TDataObject(New.Data).Include := Info.Include;
  New.BorderColor := GetListItemBorderColor(TDataObject(New.Data));
  New.Caption := ExtractFileName(Info.FileName);

  Data.Add(Info.Copy);

  FBitmapImageList.AddBitmap(Image);
  New.ImageIndex := FBitmapImageList.Count - 1;
  Result := True;
end;

procedure TFormCont.ListView1SelectItem(Sender: TObject; Item: TEasyItem;
      Selected: Boolean);
var
  Image, B: TBitmap;
  W, H: Integer;
begin
  Application.HideHint;
  THintManager.Instance.CloseHint;

  if Selected = False then
  begin
    WlResize.Visible := False;
    WlConvert.Visible := False;
    ExportLink.Visible := False;
    ExCopyLink.Visible := False;
    Panel3.Visible := False;
    TbResize.Enabled := False;
    TbConvert.Enabled := False;
    TbExport.Enabled := False;
    TbCopy.Enabled := False;
  end else
  begin
    if Image1.Picture.Bitmap <> nil then
      Image1.Picture.Graphic := nil;

    Image := TBitmap.Create;
    try
      Image.PixelFormat := FBitmapImageList[Item.ImageIndex].Bitmap.PixelFormat;
      W := FBitmapImageList[Item.ImageIndex].Bitmap.Width;
      H := FBitmapImageList[Item.ImageIndex].Bitmap.Height;
      ProportionalSize(50, 50, W, H);
      DoResize(W, H, FBitmapImageList[Item.ImageIndex].Bitmap, Image);
      if Image.PixelFormat = pf24Bit then
        Image1.Picture.Graphic := Image
      else
      begin
        B := TBitmap.Create;
        try
          LoadBMPImage32bit(Image, B, GbImageInfo.Color);
          Image1.Picture.Graphic := B
        finally
          F(B);
        end;
      end;
    finally
      F(Image);
    end;

    LabelName.Caption := ExtractFileName(Data[Item.index].FileName); // else
    LabelID.Caption := Format(L('ID = %d'), [Data[Item.index].ID]);
    Panel3.Visible := True;
    WlResize.Visible := True;
    WlConvert.Visible := True;
    ExportLink.Visible := True;
    ExCopyLink.Visible := True;
    TbResize.Enabled := True;
    TbConvert.Enabled := True;
    TbExport.Enabled := True;
    TbCopy.Enabled := True;
    LabelSize.Visible := True;
    LabelSize.Caption := Format(L('Items : %d'), [SelCount]);
  end;
end;

procedure TFormCont.Close1Click(Sender: TObject);
begin
  ManagerPanels.RemovePanel(Self);
  TerminateTimer.Enabled := True;
end;

procedure TFormCont.SelectAll1Click(Sender: TObject);
begin
  ElvMain.Selection.SelectAll;
  ElvMain.SetFocus;
end;

procedure TFormCont.Clear1Click(Sender: TObject);
begin
  Data.Clear;
  FBitmapImageList.Clear;
  ClearList;
end;

procedure TFormCont.SaveToFile1Click(Sender: TObject);
var
  N: Integer;
  IDList: TArInteger;
  FileList: TArStrings;
  I: Integer;
  SaveDialog: DBSaveDialog;
  FileName: string;
  ItemsImThArray: TArStrings;
  ItemsIDArray: TArInteger;
begin
  SaveDialog := DBSaveDialog.Create;
  SaveDialog.Filter :=
    'DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith';
  SaveDialog.FilterIndex := 1;

  if SaveDialog.Execute then
  begin
    FileName := SaveDialog.FileName;
    N := SaveDialog.GetFilterIndex;
    if N = 1 then
    begin
      if GetExt(FileName) <> 'IDS' then
        FileName := FileName + '.ids';
      if FileExistsSafe(FileName) then
        if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
          TD_ICON_WARNING) then
          Exit;

      SetLength(ItemsIDArray, Data.Count);
      for I := 0 to Data.Count - 1 do
        ItemsIDArray[I] := Data[I].ID;

      SaveIDsTofile(FileName, ItemsIDArray);
    end;
    if N = 2 then
    begin
      if GetExt(FileName) <> 'DBL' then
        FileName := FileName + '.dbl';
      if FileExistsSafe(FileName) then
        if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
          TD_ICON_WARNING) then
          Exit;
      SetLength(IDList, 0);
      SetLength(FileList, 0);
      for I := 0 to Data.Count - 1 do
      begin
        if Data[I].ID = 0 then
        begin
          SetLength(FileList, Length(FileList) + 1);
          FileList[Length(FileList) - 1] := Data[I].FileName;
        end else
        begin
          SetLength(IDList, Length(IDList) + 1);
          IDList[Length(IDList) - 1] := Data[I].ID;
        end;
      end;
      SaveListTofile(FileName, IDList, FileList);
    end;
    if N = 3 then
    begin
      if GetExt(FileName) <> 'ITH' then
        FileName := FileName + '.ith';
      if FileExistsSafe(FileName) then
        if ID_OK <> MessageBoxDB(Handle, L('File already exists! Replace?'), L('Warning'), TD_BUTTON_OKCANCEL,
          TD_ICON_WARNING) then
          Exit;

      SetLength(ItemsImThArray, Data.Count);
      for I := 0 to Data.Count - 1 do
        ItemsImThArray[I] := Data[I].LongImageID;

      SaveImThsTofile(FileName, ItemsImThArray);
    end;
  end;
  SaveDialog.Free;
  FilePushed := False;
end;

function TFormCont.HintCallBack(Info: TDBPopupMenuInfoRecord): Boolean;
var
  P, P1: Tpoint;
begin
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);

  Result := not((not Self.Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
      (ItemAtPos(P1.X, P1.Y) = nil));
end;

procedure TFormCont.HinttimerTimer(Sender: TObject);
var
  p, p1 : TPoint;
  index, i : integer;
  MenuRecord : TDBPopupMenuInfoRecord;
begin
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);
  if (not Self.Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
    (ItemWithHint <> LastMouseItem) then
  begin
    HintTimer.Enabled := False;
    Exit;
  end;
  if LastMouseItem = nil then
    Exit;
  index := LastMouseItem.index;
  if index < 0 then
    Exit;
  if FPictureSize >= ThHintSize then
    Exit;

  HintTimer.Enabled := False;

  MenuRecord := Data[Index].Copy;
  THintManager.Instance.CreateHintWindow(Self, MenuRecord, P, HintCallBack);

  if not (CtrlKeyDown or ShiftKeyDown) then
    if Settings.Readbool('Options', 'UseHotSelect', True) then
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
          LastMouseItem.Selected := True;

      end;
  LastMouseItem.Focused := True;
end;

procedure TFormCont.ListView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  p : TPoint;
  I : Integer;
  Item: TEasyItem;
  SpotX, SpotY : Integer;
begin
  if DBCanDrag then
  begin
    GetCursorPos(P);
    if (Abs(DBDragPoint.X - P.X) > 3) or (Abs(DBDragPoint.Y - P.Y) > 3) then
    begin

      P := DBDragPoint;

      Item := ItemAtPos(ElvMain.ScreenToClient(P).X, ElvMain.ScreenToClient(P).Y);
      if Item = nil then
        Exit;
      if ElvMain.Selection.FocusedItem = nil then
        ElvMain.Selection.FocusedItem := Item;

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

  if THintManager.Instance.HintAtPoint(P) <> nil then
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
  end;
end;

procedure TFormCont.FormDeactivate(Sender: TObject);
begin
  HintTimer.Enabled := False;
end;

function TFormCont.GetListItemByID(ID: Integer): TEasyItem;
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

function TFormCont.GetListView: TEasyListview;
begin
  Result := ElvMain;
end;

procedure TFormCont.FormDestroy(Sender: TObject);
begin
  FormManager.UnRegisterMainForm(Self);
  ClearList;
  DropFileTarget2.Unregister;
  F(Data);
  F(FBitmapImageList);
  F(FilesToDrag);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TFormCont.Copy1Click(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  S := '';
  for I := 0 to Data.Count - 1 do
    S := S + IntToStr(Data[I].ID) + '$';
  Clipboard.AsText := S;
end;

procedure TFormCont.Paste1Click(Sender: TObject);
var
  S, S1: string;
  Fids_: Tarinteger;
  I, N: Integer;
  Param: TArStrings;
  B: TArBoolean;
begin
  S := Clipboard.AsText;
  for I := Length(S) downto 1 do
    if not CharInSet(S[I], Cifri) and (S[I] <> '$') then
      Delete(S, I, 1);
  if Length(S) < 2 then
    Exit;
  N := 1;
  for I := 1 to Length(S) do
    if S[I] = '$' then
    begin
      S1 := Copy(S, N, I - N);
      N := I + 1;
      Setlength(Fids_, Length(Fids_) + 1);
      Fids_[Length(Fids_) - 1] := Strtointdef(S1, 0);
    end;
  Setlength(Param, 1);
  Setlength(B, 1);
  LoadFilesToPanel.Create(Param, Fids_, B, False, True, Self);
end;

procedure TFormCont.LoadFromFile1Click(Sender: TObject);
var
  Fids_: TArInteger;
  Param: TArStrings;
  B: TArBoolean;
  OpenDialog: DBOpenDialog;
begin

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter :=
      L('All supported (*.ids,*.dbl)|*.dbl;*.ids|DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl');
    OpenDialog.FilterIndex := 1;

    if FilePushed then
      OpenDialog.SetFileName(FilePushedName);

    if FilePushed or OpenDialog.Execute then
    begin
      if GetExt(OpenDialog.FileName) = 'IDS' then
      begin
        Fids_ := LoadIDsFromfileA(OpenDialog.FileName);
        SetLength(Param, 1);
        Setlength(B, 1);
        LoadFilesToPanel.Create(Param, Fids_, B, False, True, Self);
      end;
      if GetExt(OpenDialog.FileName) = 'DBL' then
      begin
        LoadDblFromfile(OpenDialog.FileName, Fids_, Param);
        LoadFilesToPanel.Create(Param, Fids_, B, False, True, Self);
        LoadFilesToPanel.Create(Param, Fids_, B, False, False, Self);
      end;
    end;
  finally
    F(OpenDialog);
  end;
  FilePushed := False;
end;

procedure TFormCont.SlideShow1Click(Sender: TObject);
var
  DBInfo: TDBPopupMenuInfo;
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  DBInfo := GetCurrentPopUpMenuInfo(nil);
  try
    Viewer.Execute(Sender, DBInfo);
    Viewer.Show;
  finally
    F(DBInfo);
  end;
end;

function TFormCont.ExistsItemById(id: integer): boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ElvMain.Items.Count do
    if ElvMain.Items[I - 1].Tag = ID then
    begin
      Result := True;
      Break;
    end;
end;

function TFormCont.GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
var
  I: Integer;
begin
  Result := TDBPopupMenuInfo.Create;
  Result.IsListItem := False;
  Result.IsPlusMenu := False;

  for I := 0 to Data.Count - 1 do
    Result.Add(Data[I].Copy);

  for I := 0 to ElvMain.Items.Count - 1 do
    Result[I].Selected := ElvMain.Items[I].Selected;

  Result.Position := 0;
  if Item <> nil then
  begin
    if SelCount = 1 then
    begin
      Result.IsListItem := True;
      Result.ListItem := ListView1Selected;
      Result.Position := ListView1Selected.index;
    end;
    if SelCount > 1 then
      Result.Position := Item.index;

  end;
end;


function TFormCont.GetFormID: string;
begin
  Result := 'Panel';
end;

procedure TFormCont.LoadLanguage;
begin
  BeginTranslate;
  try
    Label1.Caption := L('Info') + ':';
    SlideShow1.Caption := L('View');
    SelectAll1.Caption := L('Select all');
    Copy1.Caption := L('Copy');
    Paste1.Caption := L('Paste');
    LoadFromFile1.Caption := L('Load from file');
    SaveToFile1.Caption := L('Save to file');
    Clear1.Caption := L('Clear');
    Close1.Caption := L('Close');
    WlResize.Text := L('Resize');
    WlConvert.Text := L('Convert');
    ExportLink.Text := L('Export');
    ExCopyLink.Text := L('Copy');
    GbImageInfo.Caption := L('Photo');
    Label2.Caption := L('Actions') + ':';
    Rename1.Caption := L('Rename');

    TbResize.Caption := L('Resize');
    TbConvert.Caption := L('Convert');
    TbExport.Caption := L('Export');
    TbCopy.Caption := L('Copy');
    TbClose.Caption := L('Close');
  finally
    EndTranslate;
  end;
end;

procedure TFormCont.LoadSizes;
begin
  SetLVThumbnailSize(ElvMain, fPictureSize);
end;

function TFormCont.ExistsItemByFileName(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to Data.Count - 1 do
    if AnsiLowerCase(Data[I].FileName) = FileName then
    begin
      Result := True;
      Break;
    end;
end;

procedure TFormCont.AddFileName(FileName: String);
var
  Param: TArStrings;
  Ids: TArInteger;
  B: TArBoolean;
begin
  SetLength(Param, 1);
  Param[0] := FileName;
  Setlength(B, 1);
  Setlength(Ids, 1);
  LoadFilesToPanel.Create(Param, Ids, B, False, False, Self);
end;

procedure TFormCont.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Y : Integer;
  Info : TDBPopupMenuInfoRecord;
begin
  if Item.Data = nil then
    Exit;

  if Item.ImageIndex < 0 then
    Exit;

  Info := Data[Item.Index];

  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y,
    True, Info.ID, Info.ExistedFileName,
    Info.Rating, Info.Rotation, Info.Access, Info.Crypted, Info.Exists, True);
end;

procedure TFormCont.EasyListview1DblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
  ShiftState: TShiftState; var Handled: Boolean);
begin
  ListView1DblClick(Sender);
end;

procedure TFormCont.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
  if Item <> nil then
    ListView1SelectItem(Sender, Item, Item.Selected);
end;

procedure TFormCont.ListView1Resize(Sender: TObject);
begin
  ElvMain.BackGround.OffsetX := ElvMain.Width - ElvMain.BackGround.Image.Width;
  ElvMain.BackGround.OffsetY := ElvMain.Height - ElvMain.BackGround.Image.Height;
  LoadSizes;
end;

function TFormCont.GetVisibleItems: TArStrings;
var
  I: Integer;
  R: TRect;
  T: array of Boolean;
  Rv: TRect;
begin
  SetLength(Result, 0);
  SetLength(T, 0);
  Rv := ElvMain.Scrollbars.ViewableViewportRect;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    R := Rect(ElvMain.ClientRect.Left + Rv.Left, ElvMain.ClientRect.Top + Rv.Top, ElvMain.ClientRect.Right + Rv.Left,
      ElvMain.ClientRect.Bottom + Rv.Top);
    if RectInRect(R, TEasyCollectionItemX(ElvMain.Items[I]).GetDisplayRect) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := Data[I].FileName;
    end;
  end;
end;
   {
procedure TFormCont.AddThread;
begin
  Inc(FThreadCount);
end;  }

procedure TFormCont.AddWorkerThread;
begin
  Inc(FWorkerThreadCount);
  if FWorkerThreadCount = 1 then
    TbStop.Enabled := True;
end;

procedure TFormCont.BigSizeCallBack(Sender: TObject; SizeX,
  SizeY: integer);
var
  SelectedVisible: Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;
    FPictureSize := SizeX;
    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;

    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);

    if SelectedVisible then
      ElvMain.Selection.First.MakeVisible(EmvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

{ TmanagePanels }

procedure TManagePanels.AddPanel(Panel: TFormCont);
begin
  if FPanels.IndexOf(Panel) > -1 then
    Exit;

  FPanels.Add(Panel);
end;

function TManagePanels.Count: integer;
begin
  Result := FPanels.Count;
end;

constructor TManagePanels.Create;
begin
  FPanels := TList.Create;
end;

destructor TManagePanels.Destroy;
begin
  F(FPanels);
end;

function TManagePanels.GetPanelByIndex(Index: Integer): TFormCont;
begin
  Result := nil;
  if (Index > -1) and (Index < FPanels.Count) then
    Result := FPanels[Index];
end;

function TManagePanels.ExistsPanel(Panel: TForm; CID : TGUID): Boolean;
var
  Index : integer;
begin
  Result := False;
  Index := FPanels.IndexOf(Panel);
  if (Index > -1) then
    Result := IsEqualGUID(Self[Index].SID, CID) or IsEqualGUID(Self[Index].BigImagesSID, CID);
end;

procedure TManagePanels.FillSendToPanelItems(MenuItem: TMenuItem; OnClick : TNotifyEvent);
var
  PanelsTexts: TStrings;
  SendToPanel: TMenuItem;
  I: Integer;
  MenuitemSeparator: TMenuItem;
  MenuitemSentToNew: TMenuItem;
begin
  for I := 1 to MenuItem.Count - 1 do
    MenuItem.Delete(1);

  PanelsTexts := TStringList.Create;
  try
    GetPanelsTexts(PanelsTexts);
    for I := 0 to PanelsTexts.Count - 1 do
    begin
      SendToPanel := TMenuItem.Create(MenuItem);
      SendToPanel.Caption := PanelsTexts[I];
      SendToPanel.OnClick := OnClick;
      SendToPanel.ImageIndex := DB_IC_SENDTO;
      SendToPanel.Tag := I;
      MenuItem.Add(SendToPanel);
    end;
    MenuitemSeparator := TMenuItem.Create(MenuItem);
    MenuitemSeparator.Caption := '-';
    MenuItem.Add(MenuitemSeparator);
    MenuitemSentToNew := TMenuitem.Create(MenuItem);
    MenuitemSentToNew.Caption := TA('New panel', 'Panel');
    MenuitemSentToNew.OnClick := OnClick;
    MenuitemSentToNew.ImageIndex := DB_IC_SENDTO;
    MenuitemSentToNew.Tag := -1;
    MenuItem.Add(MenuitemSentToNew);
  finally
    PanelsTexts.Free;
  end;
end;

procedure TManagePanels.FreePanel(Panel: TFormCont);
begin
//
end;

procedure TManagePanels.GetPanelsTexts(List : TStrings);
var
  I: Integer;
  B: Boolean;
begin
  for I := 0 to FPanels.Count - 1 do
    List.Add(Self[I].Caption);

  repeat
    B := False;
    for I := 0 to List.Count - 2 do
      if Comparestr(List[I], List[I + 1]) > 0 then
      begin
        List.Exchange(I, I + 1);
        B := True;
      end;
  until not B;
end;

function TManagePanels.NewPanel: TFormCont;
var
  I, FTag: Integer;
  S: string;

  function TagExists(Tag: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to FPanels.Count - 1 do
      if Self[I].Tag = Tag then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  S := '';
  FTag := 0;
  if FPanels.Count = 0 then
  begin
    FTag := 1;
    S := Format(TA('Panel (%d)', 'Panel'), [FTag]);
  end;
  if FPanels.Count > 0 then
  begin
    for I := 0 to FPanels.Count - 1 do
      if not TagExists(I + 1) then
      begin
        S := Format(TA('Panel (%d)', 'Panel'), [I + 1]);
        FTag := I + 1;
        Break;
      end;
    if FTag = 0 then
    begin
      S := Format(TA('Panel (%d)', 'Panel'), [FPanels.Count + 1]);
      FTag := FPanels.Count + 1;
    end;
  end;
  Application.CreateForm(TFormCont, Result);
  if S <> '' then
  begin
    Result.Caption := S;
    Result.Tag := FTag;
  end;
end;

function TManagePanels.PanelIndex(Panel: TFormCont): Integer;
begin
  Result := FPanels.Indexof(Panel);
end;

procedure TManagePanels.RemovePanel(Panel: TFormCont);
begin
  FPanels.Remove(Panel);
end;

function TManagePanels.IsPanelForm(Panel: TForm): Boolean;
begin
  Result:= FPanels.Indexof(Panel) > -1;
end;

procedure TFormCont.ListView1DblClick(Sender: TObject);
var
  MenuInfo: TDBPopupMenuInfo;
  Pos, MousePos: TPoint;
  Item: TEasyItem;
begin

  GetCursorPos(MousePos);
  Pos := ElvMain.ScreenToClient(MousePos);
  Item := ItemAtPos(Pos.X, Pos.Y);
  if (Item <> nil) and (Item.ImageIndex > -1) and not DBReadOnly then
  begin
    Item := ItemByPointStar(ElvMain, Pos, FPictureSize, FBitmapImageList[Item.ImageIndex].Graphic);
    if Item <> nil then
    begin
      if ItemAtPos(Pos.X, Pos.Y).Tag <> 0 then
      begin
        RatingPopupMenu1.Tag := ItemAtPos(Pos.X, Pos.Y).Tag;
        Application.HideHint;
        THintManager.Instance.CloseHint;
        LastMouseItem := nil;
        RatingPopupMenu1.Popup(MousePos.X, MousePos.Y);
        Exit;
      end;
    end;
  end;

  Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;
  if ListView1Selected <> nil then
  begin
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
    try
      Viewer.Execute(Sender, MenuInfo);
      Viewer.Show;
    finally
      F(MenuInfo);
    end;
  end;
end;

procedure TFormCont.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    ListView1DblClick(Sender);
end;

procedure TFormCont.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  I: Integer;
  B: Boolean;
begin
  if Msg.Hwnd = ElvMain.Handle then
  begin

    // middle mouse button
    if Msg.message = WM_MBUTTONDOWN then
    begin
      Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
      BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
      Msg.message := 0;
    end;

    if Msg.message = WM_MOUSEWHEEL then
    begin
      if CtrlKeyDown then
      begin
        if Msg.WParam > 0 then
          I := 1
        else
          I := -1;
        ListView1MouseWheel(ElvMain, [SsCtrl], I, Point(0, 0), B);
        Msg.message := 0;
      end;

      Application.HideHint;
      THintManager.Instance.CloseHint;
    end;
    if Msg.message = WM_RBUTTONDOWN then
      WindowsMenuTickCount := GettickCount;

    if Msg.message = WM_KEYDOWN then
    begin
      WindowsMenuTickCount := GetTickCount;

      if (Msg.WParam = VK_SUBTRACT) then
        ZoomIn;
      if (Msg.WParam = VK_ADD) then
        ZoomOut;

      // 93-context menu button
      if (Msg.WParam = VK_APPS) then
        ListView1ContextPopup(ElvMain, Point(-1, -1), B);

      if (Msg.WParam = VK_DELETE) then
        DeleteIndexItemFromPopUpMenu(nil);
      if (Msg.WParam = Ord('a')) and CtrlKeyDown then
        SelectAll1Click(nil);
    end;
  end;
end;

procedure TFormCont.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  I: Integer;
  Param: TArStrings;
  Ids: TArInteger;
  B: TArBoolean;
begin
  if DBCanDrag then
    Exit;
  for I := 0 to DropFileTarget2.Files.Count - 1 do
  begin
    if IsGraphicFile(DropFileTarget2.Files[I]) then
    begin
      SetLength(Param, Length(Param) + 1);
      Param[Length(Param) - 1] := DropFileTarget2.Files[I];
    end else
    begin
      FilePushed := True;
      FilePushedName := DropFileTarget2.Files[I];
      LoadFromFile1Click(nil);
    end;
  end;
  SetLength(Ids, 1);
  SetLength(B, 1);
  LoadFilesToPanel.Create(Param, Ids, B, False, False, Self);
end;

procedure TFormCont.WlResizeClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    ResizeImages(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TFormCont.WlConvertClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    ConvertImages(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TFormCont.ExportLinkClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    ExportImages(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TFormCont.ExCopyLinkClick(Sender: TObject);
var
  FileName, Temp, UpDir, Dir, NewDir: string;
  L1, L2: Integer;
  I: Integer;
  DestWide: TList;

  procedure AddFileToDestWide(NewDir, NewFileName: string);
  var
    I: Integer;
    DestType : TDestDype;
  begin
    for I := 0 to DestWide.Count - 1 do
      if AnsiLowerCase(TDestDype(DestWide[I]).Dest) = AnsiLowerCase(NewDir) then
      begin
        TDestDype(DestWide[I]).Files.Add(NewFileName);
        Exit;
      end;

    DestType := TDestDype.Create;
    DestType.Dest := NewDir;
    DestType.Files.Add(NewFileName);
    DestWide.Add(DestType);
  end;

begin
  DestWide := TList.Create;
  try
    Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Select place to copy files'), UseSimpleSelectFolderDialog);
    if DirectoryExists(Dir) then
    begin
      Dir := IncludeTrailingBackslash(Dir);
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          FileName := ProcessPath(Data[I].FileName);
          Temp := ExtractFileDir(FileName);
          L1 := Length(Temp);
          Temp := ExtractFilePath(Temp);
          L2 := Length(Temp);
          UpDir := Copy(FileName, L2 + 1, L1 - L2);
          NewDir := Dir + UpDir;
          AddFileToDestWide(NewDir, FileName);
        end;
    end;
    for I := 0 to DestWide.Count - 1 do
    begin
      Dir := TDestDype(DestWide[I]).Dest;
      CreateDirA(Dir);
      CopyFiles(Handle, TDestDype(DestWide[I]).Files, Dir, False, True, Self);
    end;
  finally
    FreeList(DestWide);
  end;
end;

procedure TFormCont.PopupMenu1Popup(Sender: TObject);
begin
  SlideShow1.Visible := ElvMain.Items.Count > 0;
  SelectAll1.Visible := ElvMain.Items.Count > 0;
  Copy1.Visible := ElvMain.Items.Count > 0;
  SaveToFile1.Visible := ElvMain.Items.Count > 0;
  Clear1.Visible := ElvMain.Items.Count > 0;
end;

procedure TFormCont.Rename1Click(Sender: TObject);
var
  S: string;
begin
  S := Caption;
  if PromtString(L('Enter text'), L('Enter new name of panel'), S) then
    Caption := S;
end;

function TFormCont.SelCount: Integer;
begin
  Result := ElvMain.Selection.Count;
end;

function TFormCont.ListView1Selected: TEasyItem;
begin
  Result := ElvMain.Selection.First;
end;

function TFormCont.ItemAtPos(X, Y: Integer): TEasyItem;
var
  R: TRect;
begin
  R := ElvMain.Scrollbars.ViewableViewportRect;
  Result := ElvMain.Groups[0].ItemByPoint(Point(R.Left + X, R.Top + Y));
end;

procedure TFormCont.ListView1MouseUp(Sender: TObject; Button: TMouseButton;
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
      ListView1ContextPopup(ElvMain, Point(X, Y), Handled);
      PopupHandled := True;
    end;

  MouseDowned := False;
end;

procedure TFormCont.Listview1IncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
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

procedure TFormCont.LoadToolBarIcons;
var
  Ico : HIcon;

  procedure AddIcon(Name : String);
  begin
    Ico := LoadIcon(HInstance, PWideChar(Name));
    ImageList_AddIcon(ToolBarImageList.Handle, Ico);
    DestroyIcon(Ico);
  end;

  procedure AddDisabledIcon(Name : String);
  begin
    Ico := LoadIcon(HInstance, PWideChar(Name));
    ImageList_AddIcon(ToolBarDisabledImageList.Handle, Ico);
    DestroyIcon(Ico);
  end;

begin
  AddIcon('PANEL_RESIZE');
  AddIcon('PANEL_CONVERT');
  AddIcon('PANEL_EXPORT');
  AddIcon('PANEL_COPY');
  AddIcon('PANEL_CLOSE');
  AddIcon('PANEL_ZOOM_OUT');
  AddIcon('PANEL_ZOOM_IN');
  AddIcon('PANEL_BREAK');

  AddDisabledIcon('PANEL_RESIZE_GRAY');
  AddDisabledIcon('PANEL_CONVERT_GRAY');
  AddDisabledIcon('PANEL_EXPORT_GRAY');
  AddDisabledIcon('PANEL_COPY_GRAY');
  AddDisabledIcon('PANEL_CLOSE');
  AddDisabledIcon('PANEL_ZOOM_OUT');
  AddDisabledIcon('PANEL_ZOOM_IN');
  AddDisabledIcon('PANEL_BREAK_GRAY');

  TbResize.Enabled := False;
  TbConvert.Enabled := False;
  TbExport.Enabled := False;
  TbCopy.Enabled := False;
  TbStop.Enabled := False;

  TbResize.ImageIndex    := 0;
  TbConvert.ImageIndex   := 1;
  TbExport.ImageIndex    := 2;
  TbCopy.ImageIndex      := 3;
  ToolButton5.ImageIndex := 4;
  TbZoomIn.ImageIndex    := 5;
  TbZoomOut.ImageIndex   := 6;
  TbStop.ImageIndex      := 7;

  ToolBar1.Images := ToolBarImageList;
  ToolBar1.DisabledImages := ToolBarDisabledImageList;
end;

procedure TFormCont.TbZoomInClick(Sender: TObject);
begin
  ZoomIn;
end;

procedure TFormCont.TbZoomOutClick(Sender: TObject);
begin
  ZoomOut;
end;

procedure TFormCont.ZoomIn;
var
  SelectedVisible : Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;
    if FPictureSize > ListViewMinThumbnailSize then
      FPictureSize := FPictureSize - 10;
    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;
    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);

    if SelectedVisible then
      ElvMain.Selection.First.MakeVisible(EmvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TFormCont.ZoomOut;
var
  SelectedVisible : Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;
    if FPictureSize < ListViewMaxThumbnailSize then
      FPictureSize := FPictureSize + 10;
    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;
    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);
    if SelectedVisible then
      ElvMain.Selection.First.MakeVisible(EmvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TFormCont.ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if not(SsCtrl in Shift) then
    Exit;

  if WheelDelta < 0 then
    ZoomIn
  else
    ZoomOut;
end;

procedure TFormCont.BigImagesTimerTimer(Sender: TObject);
var
  FData : TDBPopupMenuInfo;
begin
  BigImagesTimer.Enabled := False;
  BigImagesSID := GetGUID;

  TbStop.Enabled := True;

  FData := TDBPopupMenuInfo.Create;
  try
    FData.Assign(Data);
    // тут начинается загрузка больших картинок
    TPanelLoadingBigImagesThread.Create(Self, BigImagesSID, nil, FPictureSize, FData);
  finally
    FData.Free;
  end;
end;

function TFormCont.InternalGetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
var
  I: Integer;
begin
  FileName := AnsiLowerCase(FileName);
  Result := False;
  for I := 0 to Data.Count - 1 do
  begin
    if AnsiLowerCase(Data[I].FileName) = FileName then
    begin
      if FBitmapImageList[I].IsBitmap then
      begin
        Width := Data[I].Width;
        Height := Data[I].Height;
        Bitmap.Assign(FBitmapImageList[I].Graphic);
        Result := True;
      end;
      Break;
    end;
  end;
end;

function TFormCont.FileNameExistsInList(FileName: string): Boolean;
var
  I: Integer;
begin
  FileName := AnsiLowerCase(FileName);
  Result := False;
  for I := 0 to Data.Count - 1 do
  begin
    if AnsiLowerCase(Data[I].FileName) = FileName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TFormCont.ReplaseBitmapWithPath(FileName : string; Bitmap : TBitmap);
var
  I : integer;
begin
  FileName:= AnsiLowerCase(FileName);
  for I := 0 to Data.Count - 1 do
  begin
    if AnsiLowerCase(Data[I].FileName) = FileName then
    begin
      FBitmapImageList[I].Bitmap.Assign(Bitmap);
      ElvMain.Refresh;
      Break;
    end;
  end;
end;

procedure TFormCont.TbStopClick(Sender: TObject);
begin
  SID := GetGUID;
  BigImagesSID := GetGUID;
  TbStop.Enabled := False;
end;
             {
procedure TFormCont.DoStopLoading(CID: TGUID);
begin
  if IsEqualGUID(CID, SID) or IsEqualGUID(CID, BigImagesSID) then
  begin
    if IsEqualGUID(CID, SID) then
      Dec(FThreadCount);
    if FThreadCount = 0 then
      TbStop.Enabled := False;
  end;
end;      }

procedure TFormCont.TerminateTimerTimer(Sender: TObject);
begin
  TerminateTimer.Enabled := False;
  Release;
end;

procedure TFormCont.TwWindowsPosChange(Sender: TObject);
begin
  DropFileTarget2.Unregister;
  if TwWindowsPos.Pushed then
    FormStyle := FsStayOnTop
  else
    FormStyle := FsNormal;
  DropFileTarget2.Register(Panel1);
end;

procedure TFormCont.N05Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  SetRating(RatingPopupMenu1.Tag,(Sender as TMenuItem).Tag);
  EventInfo.Rating:=(Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Self, RatingPopupMenu1.Tag,[EventID_Param_Rating],EventInfo);
end;

procedure TFormCont.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
  Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
  BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
end;

procedure TFormCont.ClearList;
var
  I : Integer;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
    TDataObject(ElvMain.Items[I].Data).Free;
  ElvMain.Items.Clear;
end;

initialization

  ManagerPanels := TManagePanels.Create;

Finalization
  F(ManagerPanels);

end.
