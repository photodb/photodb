unit UnitFormCont;

interface

uses
  Clipbrd, dolphin_db, DBCMenu, ComCtrls, CommCtrl, ImgList, ExtCtrls, StdCtrls,
  UnitDBKernel, db, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, GraphicCrypt, ShellContextMenu, GraphicsCool,
  Dialogs, activex, jpeg, Menus, DmProgress, Buttons, acDlgSelect,  Math,
  DropSource, DropTarget, AppEvnts, WebLink, MPCommonUtilities, uVistaFuncs,
  DBCtrls, UnitBitmapImageList, EasyListview, DragDropFile, DragDrop,
  ToolWin, PanelCanvas, UnitPanelLoadingBigImagesThread, UnitDBDeclare,
  UnitDBFileDialogs, UnitPropeccedFilesSupport, UnitDBCommonGraphics,
  UnitDBCommon, UnitCDMappingSupport, uLogger, uConstants, uThreadForm,
  uListViewUtils, uDBDrawing, uFileUtils, uResources, GraphicEx, TwButton;

type
  TFormCont = class(TThreadForm)
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
    Panel4: TPanel;
    Hinttimer: TTimer;
    SlideShow1: TMenuItem;
    ImageList1: TImageList;
    ApplicationEvents1: TApplicationEvents;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget2: TDropFileTarget;
    Label2: TLabel;
    WebLink2: TWebLink;
    GroupBox1: TGroupBox;
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
    ToolButton6: TToolButton;
    TbSeparator: TToolButton;
    TbZoomIn: TToolButton;
    TbZoomOut: TToolButton;
    BigImagesTimer: TTimer;
    WebLink1: TWebLink;
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
    procedure AddNewItem(Image : tbitmap; Info : TOneRecordInfo);
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
    procedure WebLink1Click(Sender: TObject);
    procedure WebLink2Click(Sender: TObject);
    procedure ExportLinkClick(Sender: TObject);
    procedure ExCopyLinkClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure UpdateTheme(Sender: TObject);
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
    MouseDowned : Boolean;
    PopupHandled : boolean;
    LoadingThItem, ShLoadingThItem : TEasyItem;

    ElvMain : TEasyListView;
    FilePushed : boolean;
    FilePushedName : string;

    Data : TImageContRecordArray;

    FilesToDrag : TArStrings;
    DBCanDrag : Boolean;
    DBDragPoint : TPoint;
    WindowsMenuTickCount : Cardinal;
    ItemByMouseDown : Boolean;
    ItemSelectedByMouseDown : Boolean;
    function hintrealA(item: TObject): boolean;
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
    { protected declarations }
  protected
  procedure CreateParams(VAR Params: TCreateParams); override;
    { Private declarations }
  public
    { Public declarations }
    WindowID: TGUID;
    SID: TGUID;
    BigImagesSID: TGUID;
    procedure DoStopLoading(CID: TGUID);
    function IsSelectedVisible: Boolean;
    procedure AddFileName(FileName: string);
    procedure ZoomOut;
    procedure ZoomIn;
    function GetVisibleItems: TArStrings;
    function FileNameExistsInList(FileName: string): Boolean;
    procedure ReplaseBitmapWithPath(FileName: string; Bitmap: TBitmap);
    procedure AddThread;
    procedure BigSizeCallBack(Sender: TObject; SizeX, SizeY: Integer);
    procedure LoadLanguage;
    procedure LoadToolBarIcons;
    procedure LoadSizes;
    procedure CreateBackgroundImage;
  private
    FPictureSize : integer;
    FThreadCount : integer;
    FBitmapImageList : TBitmapImageList;
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
  ManagerPanels : TManagePanels;

implementation

uses language, Searching, UnitImHint, UnitLoadFilesToPanel, UnitHintCeator,
     SlideShow, ExplorerUnit, UnitSizeResizerForm, UnitImageConverter,
     UnitRotateImages, UnitExportImagesForm, CommonDBSupport,
     UnitStringPromtForm, Loadingresults, UnitBigImagesSize;

{$R *.dfm}

{ TFormCont }

procedure TFormCont.RefreshItemByID(ID: Integer);
var
  Index: Integer;
  FData: TImageContRecordArray;
begin
  Index := GetListItemByID(Id).index;
  SetLength(FData, 1);
  FData[0] := Data[index];

  TPanelLoadingBigImagesThread.Create(Self, BigImagesSID, nil, FPictureSize, Copy(FData));
end;

procedure TFormCont.CreateBackgroundImage;
var
  BackgroundImage : TPNGGraphic;
  Bitmap, SearchBackgroundBMP : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := Pf24bit;
    Bitmap.Canvas.Brush.Color := Theme_ListColor;
    Bitmap.Canvas.Pen.Color := Theme_ListColor;
    Bitmap.Width := 120;
    Bitmap.Height := 120;

    BackgroundImage := GetImagePanelImage;
    try
      SearchBackgroundBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(BackgroundImage, SearchBackgroundBMP, Theme_ListColor);
        Bitmap.Canvas.Draw(0, 0, SearchBackgroundBMP);
      finally
        SearchBackgroundBMP.Free;
       end;
    finally
      BackgroundImage.Free;
    end;
    ElvMain.BackGround.Image := Bitmap;
  finally
    Bitmap.Free;
  end;
end;

procedure TFormCont.FormCreate(Sender: TObject);
begin
  FilePushedName := '';
  FThreadCount := 0;
  SID := GetGUID;
  BigImagesSID := GetGUID;
  FPictureSize := ThSizePanelPreview;
  DBKernel.RegisterProcUpdateTheme(UpdateTheme, Self);
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
  ElvMain.HotTrack.Color := Theme_ListFontColor;

  SetLVSelection(ElvMain);

  FPictureSize := ThSizePanelPreview;
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

  ConvertTo32BitImageList(DragImageList);

  WindowID := GetGUID;
  FilePushed := False;
  LoadLanguage;

  ElvMain.HotTrack.Enabled := DBKernel.Readbool('Options', 'UseHotSelect', True);

  DropFileTarget2.register(Self);
  FBitmapImageList := TBitmapImageList.Create;
  ManagerPanels.AddPanel(Self);
  DBkernel.RecreateThemeToForm(Self);
  ElvMain.DoubleBuffered := True;

  ManagerPanels.AddPanel(Self);

  Caption := Format(TEXT_MES_PANEL_CAPTION, [Inttostr(ManagerPanels.PanelIndex(Self) + 1)]);

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

  Label2.Caption := TEXT_MES_ACTIONS + ':';
  Rename1.Caption := TEXT_MES_RENAME;
  WebLink1.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_RESIZE + 1]);
  WebLink2.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CONVERT + 1]);
  ExportLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EXPORT_IMAGES + 1]);
  ExCopyLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_COPY + 1]);

  RatingPopupMenu1.Images := DBkernel.ImageList;

  N00.ImageIndex := DB_IC_DELETE_INFO;
  N01.ImageIndex := DB_IC_RATING_1;
  N02.ImageIndex := DB_IC_RATING_2;
  N03.ImageIndex := DB_IC_RATING_3;
  N04.ImageIndex := DB_IC_RATING_4;
  N05.ImageIndex := DB_IC_RATING_5;

  WebLink2.Top := WebLink1.Top + WebLink1.Height + 5;
  ExportLink.Top := WebLink2.Top + WebLink2.Height + 5;
  ExCopyLink.Top := ExportLink.Top + ExportLink.Height + 5;

  DBkernel.RegisterForm(Self);
  LoadToolBarIcons;
end;

procedure TFormCont.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ManagerPanels.RemovePanel(Self);
  TerminateTimer.Enabled := True;
end;

procedure TFormCont.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  i:integer;
  Info : TDBPopupMenuInfo;
  item : TEasyItem;
  menus : TArMenuitem;
  FileNames : TArStrings;
begin
 if CopyFilesSynchCount>0 then WindowsMenuTickCount:=GetTickCount;

 Item:=ItemByPointImage(ElvMain, Point(MousePos.x,MousePos.y));
 if (Item=nil) or ((MousePos.x=-1) and (MousePos.y=-1)) then Item:=ElvMain.Selection.First;

 HintTimer.Enabled:=false;
 if item <>nil then
 begin
  loadingthitem:= nil;
  application.HideHint;
  if ImHint<>nil then
  ImHint.close;
  hinttimer.Enabled:=false;
  info:=GetCurrentPopUpMenuInfo(item);
  info.AttrExists:=false;
  if not (GetTickCount-WindowsMenuTickCount>WindowsMenuTime) then
  begin
   info.IsPlusMenu:=false;
   info.IsListItem:=false;
   setlength(menus,1);
   menus[0]:=Tmenuitem.Create(nil);
   menus[0].Caption:=TEXT_MES_DELETE_FROM_LIST;
   menus[0].Tag:=item.Index;
   menus[0].ImageIndex:=DB_IC_DELETE_INFO;
   menus[0].OnClick:=DeleteIndexItemFromPopUpMenu;
   TDBPopupMenu.Instance.ExecutePlus(ElvMain.ClientToScreen(MousePos).x,ElvMain.ClientToScreen(MousePos).y,Info,menus);
  end else
  begin
   SetLength(FileNames,0);
   For i:=0 to Info.Count - 1 do
   if Info[I].Selected then
   begin
    SetLength(FileNames,Length(FileNames)+1);
    FileNames[Length(FileNames)-1]:=Info[i].FileName;
   end;
   GetProperties(FileNames,MousePos,ElvMain);
  end;
 end else PopupMenu1.Popup(ElvMain.ClientToScreen(MousePos).x,ElvMain.ClientToScreen(MousePos).y);
end;

procedure TFormCont.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i : integer;
  MenuInfo : TDBPopupMenuInfo;
  item, itemsel : TEasyItem;
begin

  Item:=ItemAtPos(x,y);
  if Item = nil then
    ElvMain.Selection.ClearAll;

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
    for i:=0 to ElvMain.Items.Count-1 do
    if ElvMain.Items[i].Selected then
    if itemsel<>ElvMain.Items[i] then
    ElvMain.Items[i].Selected:=false;
    if [ssShift]*Shift<>[] then
     ElvMain.Selection.SelectRange(itemsel,ElvMain.Selection.FocusedItem,false,false) else
    begin
     ItemSelectedByMouseDown:=true;
     itemsel.Selected:=true;
     itemsel.Focused:=true;
    end;
   end else ItemByMouseDown:=true;
   itemsel.Focused:=true;
  end;

  WindowsMenuTickCount:=GetTickCount;
  if (Button = mbLeft) and (Item<>nil) then
  begin
    DBCanDrag:=True;
    SetLength(FilesToDrag,0);
    GetCursorPos(DBDragPoint);
    MenuInfo:=Self.GetCurrentPopUpMenuInfo(Item);
    SetLength(FilesToDrag,0);
    For i:=0 to MenuInfo.Count-1 do
    if ElvMain.Items[i].Selected then
    If FileExists(MenuInfo[I].FileName) then
    begin
     SetLength(FilesToDrag,Length(FilesToDrag)+1);
     FilesToDrag[Length(FilesToDrag)-1]:=MenuInfo[I].FileName;
    end;
    If Length(FilesToDrag)=0 then DBCanDrag:=false;
  end;
end;

procedure TFormCont.DeleteIndexItemByID(ID : integer);
var
  i, j : integer;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  if i>ElvMain.Items.Count-1 then break;
  if Data[i].ID=ID then
  begin
   ElvMain.Items.Delete(i);
   FBitmapImageList.Delete(ElvMain.Items[i].ImageIndex);
   for j:=i to ElvMain.Items.Count-1 do
   begin
    ElvMain.Items[j].ImageIndex:=ElvMain.Items[j].ImageIndex-1;
    Data[j]:=Data[j+1];
   end;
   SetLength(Data,Length(Data)-1);
  end;
 end;
end;

procedure TFormCont.DeleteIndexItemFromPopUpMenu(Sender: TObject);
var
  i, j : integer;
  p_i : pinteger;
begin
 p_i:=@i;
 ElvMain.Groups.BeginUpdate(true);
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  if i>ElvMain.Items.Count-1 then break;
  if ElvMain.Items[i].Selected then
  begin
   FBitmapImageList.Delete(ElvMain.Items[i].ImageIndex);
   ElvMain.Items.Delete(i);
   ElvMain.Groups.Rebuild(true);
   for j:=i to ElvMain.Items.Count-1 do
   begin
    ElvMain.Items[j].ImageIndex:=ElvMain.Items[j].ImageIndex-1;
    Data[j]:=Data[j+1];
   end;
   SetLength(Data,Length(Data)-1);
   p_i^:=i-1;
  end;
 end;
 Sender.Free;
 ElvMain.Groups.EndUpdate;
end;

procedure TFormCont.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i, ReRotation : integer;
  item: TEasyItem;
  RefreshParams : TEventFields;
begin
 if EventID_Repaint_ImageList in params then
 begin
  ElvMain.Refresh;
  exit;
 end;

 if ID=-2 then exit;

 For i:=0 to Length(Data)-1 do
 if Data[i].ID=ID then
 begin
  if EventID_Param_Rotate in params then
  begin
   ReRotation:=GetNeededRotation(Data[i].Rotation,Value.Rotate);
   Data[i].Rotation:=Value.Rotate;
  end;

  if EventID_Param_Private in params then Data[i].Access:=Value.Access;
  if EventID_Param_KeyWords in params then Data[i].KeyWords:=Value.KeyWords;
  if EventID_Param_Crypt in params then Data[i].Crypted:=Value.Crypt;
  if EventID_Param_Date in params then Data[i].Date:=Value.Date;
  if EventID_Param_Time in params then Data[i].Time:=Value.Time;
  if EventID_Param_Rotate in params then Data[i].Rotation:=Value.Rotate;
  if EventID_Param_Rating in params then Data[i].Rating:=Value.Rating;
  if EventID_Param_Comment in params then Data[i].Comment:=Value.Comment;
  if EventID_Param_IsDate in params then Data[i].IsDate:=Value.IsDate;
  if EventID_Param_IsTime in params then Data[i].IsTime:=Value.IsTime;
  if EventID_Param_Groups in params then Data[i].Groups:=Value.Groups;
  if EventID_Param_Links in params then Data[i].Links:=Value.Links;
  if EventID_Param_Include in params then
  begin
   Data[i].Include:=Value.Include;
   item:=GetListItemById(id);
   if item<>nil then
   if item.Data<>nil then
   Boolean(TDataObject(item.Data).Include):=Value.Include;
   item.BorderColor := GetListItemBorderColor(TDataObject(item.Data));
  end;
 end;

 if [EventID_Param_Rotate]*params<>[] then
 begin
  for i:=0 to Length(Data)-1 do
  if Data[i].ID=ID then
  begin
   if ElvMain.Items[i].ImageIndex>-1 then
   begin
     ApplyRotate(FBitmapImageList[ElvMain.Items[i].ImageIndex].Bitmap, ReRotation);
   end;
  end;
 end;

 if (EventID_Param_Image in params) then
 if GetListItemById(id)<>nil then
 begin
  //TODO: normal image
  RefreshItemByID(id);
 end;
 if (EventID_Param_Include in params) then ElvMain.Refresh;
 if (EventID_Param_Delete in params) then
 begin
  DeleteIndexItemByID(ID);
 end;

 if SetNewIDFileData in params then
 begin
  for i:=0 to length(Data)-1 do
  if AnsiLowerCase(Data[i].FileName)=Value.Name then
  begin
   Data[i].ID:=ID;
   Data[i].IsDate:=true;
   Data[i].IsTime:=Value.IsTime;
   Data[i].Date:=Value.Date;
   Data[i].Time:=Value.Time;
   ElvMain.Refresh;
   break;
  end;
  exit;
 end;

 RefreshParams:=[EventID_Param_Private,EventID_Param_Rotate,EventID_Param_Name,EventID_Param_Rating,EventID_Param_Crypt];
 if RefreshParams*params<>[] then
 begin
  ElvMain.Repaint;
 end;

 if [EventID_Param_DB_Changed] * params<>[] then
 begin
  Close;
 end;
end;

procedure TFormCont.AddNewItem(Image : Tbitmap; Info : TOneRecordInfo);
var
  New: TEasyItem;
  L: Integer;
begin
  if Info.ItemId <> 0 then
  begin
    if ExistsItemById(Info.ItemId) then
      Exit;
  end else
  begin
    if ExistsItemByFileName(Info.ItemFileName) then
      Exit;
  end;

 new := ElvMain.Items.Add;

 new.Tag:=Info.ItemId;
 new.Data:=TDataObject.Create;
 TDataObject(new.Data).Include:=Info.ItemInclude;
 new.BorderColor := GetListItemBorderColor(TDataObject(new.Data));

 new.Caption:=ExtractFileName(Info.ItemFileName);

 L:=Length(Data);
 SetLength(Data,Length(Data)+1);

 Data[L].Rotation:=Info.ItemRotate;
 Data[L].ID:=Info.ItemId;
 Data[L].FileName:=Info.ItemFileName;
 Data[L].Access:=Info.ItemAccess;
 Data[L].Rating:=Info.ItemRating;
 Data[L].FileSize:=Info.ItemSize;
 Data[L].Comment:=Info.ItemComment;
 Data[L].Date:=Info.ItemDate;
 Data[L].Time:=Info.ItemTime;
 Data[L].IsDate:=Info.ItemIsDate;
 Data[L].IsTime:=Info.ItemIsTime;
 Data[L].Groups:=Info.ItemGroups;
 Data[L].ImTh:=Info.ItemImTh;
 Data[L].Crypted:=Info.ItemCrypted;
 Data[L].Include:=Info.ItemInclude;
 Data[L].Links:=Info.ItemLinks;
 Data[L].KeyWords:=Info.ItemKeyWords;
 Data[L].Exists:=0;

 FBitmapImageList.AddBitmap(Image);
 New.ImageIndex:=FBitmapImageList.Count-1;
end;

procedure TFormCont.ListView1SelectItem(Sender: TObject; Item: TEasyItem;
      Selected: Boolean);
var
  Image : TBitmap;
  w,h : integer;
begin
 Application.HideHint;
 if ImHint<>nil then
 ImHint.close;
 if Selected=false then
 begin
  WebLink1.Visible:=false;
  WebLink2.Visible:=false;
  ExportLink.Visible:=false;
  ExCopyLink.Visible:=false;
  Panel3.Visible:=false;
  TbResize.Enabled:=false;
  TbConvert.Enabled:=false;
  TbExport.Enabled:=false;
  TbCopy.Enabled:=false;
 end else
 begin
  if image1.Picture.Bitmap<>nil then
  image1.Picture.Graphic:=nil;

  Image:=TBitmap.Create;
  Image.PixelFormat:=pf24bit;
  w:=FBitmapImageList[Item.ImageIndex].Bitmap.Width;
  h:=FBitmapImageList[Item.ImageIndex].Bitmap.Height;
  ProportionalSize(50,50,w,h);
  DoResize(w,h,FBitmapImageList[Item.ImageIndex].Bitmap,Image);
  image1.Picture.Bitmap.Assign(Image);
  Image.Free;

  LabelName.Caption:=ExtractFileName(Data[Item.Index].FileName);// else
  LabelID.Caption:=Format(TEXT_MES_ID_FORMATA,[IntToStr(Data[Item.Index].ID)]);
  Panel3.Visible:=true;
  WebLink1.Visible:=true;
  WebLink2.Visible:=true;
  ExportLink.Visible:=true;
  ExCopyLink.Visible:=true;
  TbResize.Enabled:=true;
  TbConvert.Enabled:=true;
  TbExport.Enabled:=true;
  TbCopy.Enabled:=true;
  LabelSize.Visible:=true;
  LabelSize.Caption:=Format(TEXT_MES_D_ITEMS,[SelCount]);
 end;
end;

procedure TFormCont.Close1Click(Sender: TObject);
begin
 ManagerPanels.RemovePanel(self);
 TerminateTimer.Enabled:=true;
end;

procedure TFormCont.SelectAll1Click(Sender: TObject);
begin
 ElvMain.Selection.SelectAll;
 ElvMain.SetFocus;
end;

procedure TFormCont.Clear1Click(Sender: TObject);
begin
 SetLength(Data,0);
 FBitmapImageList.Clear;
 ElvMain.Items.Clear;
end;

procedure TFormCont.SaveToFile1Click(Sender: TObject);
var
  n : integer;
  IDList : TArInteger;
  FileList : TArStrings;
  i : integer;
  SaveDialog : DBSaveDialog;
  FileName : string;
  ItemsImThArray : TArStrings;
  ItemsIDArray : TArInteger;
begin
 SaveDialog:=DBSaveDialog.Create;
 SaveDialog.Filter:='DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl|DataDase ImTh Results (*.ith)|*.ith';
 SaveDialog.FilterIndex:=1;

 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;
  n:=SaveDialog.GetFilterIndex;
  if n=1 then
  begin
   if GetExt(FileName)<>'IDS' then
   FileName:=FileName+'.ids';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;

   SetLength(ItemsIDArray,Length(Data));
   for i:=0 to Length(Data)-1 do
   ItemsIDArray[i]:=Data[i].ID;

   SaveIDsTofile(FileName,ItemsIDArray);
  end;
  if n=2 then
  begin
   if GetExt(FileName)<>'DBL' then
   FileName:=FileName+'.dbl';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
   SetLength(IDList,0);
   SetLength(FileList,0);
   for i:=0 to Length(Data)-1 do
   begin
    if Data[i].ID=0 then
    begin
     SetLength(FileList,Length(FileList)+1);
     FileList[Length(FileList)-1]:=Data[i].FileName;
    end else
    begin
     SetLength(IDList,Length(IDList)+1);
     IDList[Length(IDList)-1]:=Data[i].ID;
    end;
   end;
   SaveListTofile(FileName,IDList,FileList);
  end;
  if n=3 then
  begin
   if GetExt(FileName)<>'ITH' then
   FileName:=FileName+'.ith';
   if FileExists(FileName) then
   if ID_OK<>MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;

   SetLength(ItemsImThArray,Length(Data));
   for i:=0 to Length(Data)-1 do
   ItemsImThArray[i]:=Data[i].ImTh;

   SaveImThsTofile(FileName,ItemsImThArray);
  end;
 end;
 SaveDialog.Free;
 FilePushed:=false;
end;

function TFormCont.hintrealA(item: TObject): boolean;
var
  p, p1 : tpoint;
begin
 getcursorpos(p);
 p1:=ElvMain.ScreenToClient(p);
 result:=not ((not self.Active) or (not ElvMain.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (ItemAtPos(p1.X,p1.y)=nil) or (item<>loadingthitem));
end;

procedure TFormCont.HinttimerTimer(Sender: TObject);
var
  p, p1 : TPoint;
  index, i : integer;
begin
 GetCursorPos(p);
 p1:=ElvMain.ScreenToClient(p);
 if (not self.Active) or (not ElvMain.Focused) or (ItemAtPos(p1.X,p1.y)<>LoadingThItem) or (shloadingthitem<>loadingthitem) then
 begin
  HintTimer.Enabled:=false;
  exit;
 end;
 if LoadingThItem=nil then exit;
 index:=LoadingThItem.index;
 if index<0 then exit;
 HintTimer.Enabled:=false;

 if FPictureSize>=Dolphin_DB.ThHintSize then exit;
 UnitHintCeator.fitem:= LoadingThItem;
 UnitHintCeator.fInfo:=RecordInfoOne(ProcessPath(Data[Index].FileName),Data[Index].ID,Data[Index].Rotation,Data[Index].Rating,Data[Index].Access,Data[Index].FileSize,Data[index].Comment,Data[index].KeyWords,'','',Data[index].Groups,Data[index].Date,Data[index].IsDate ,Data[index].IsTime,Data[index].Time, Data[index].Crypted, Data[index].Include, true, Data[index].Links);
 UnitHintCeator.threct:=rect(p.X,p.Y,p.x+100,p.Y+100);
 UnitHintCeator.work_.Add(ProcessPath(Data[LoadingThItem.index].FileName));
 UnitHintCeator.hr:=HintRealA;
 UnitHintCeator.Owner:=Self;

  if not (CtrlKeyDown or ShiftKeyDown) then
  if DBKernel.Readbool('Options','UseHotSelect',true) then
  if not LoadingThItem.Selected then
  begin
   if not (CtrlKeyDown or ShiftKeyDown) then
   for i:=0 to ElvMain.Items.Count-1 do
   if ElvMain.Items[i].Selected then
   if LoadingThItem<>ElvMain.Items[i] then
   ElvMain.Items[i].Selected:=false;
   if ShiftKeyDown then
   ElvMain.Selection.SelectRange(loadingthitem,ElvMain.Selection.FocusedItem,false,false) else
   if not ShiftKeyDown then
   begin
    LoadingThItem.Selected:=true;
   end;
  end;
  LoadingThItem.Focused:=true;

 HintCeator.Create(false);
end;

procedure TFormCont.ListView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  p : TPoint;
  I : Integer;
  SelectedItem, Item: TEasyItem;
  R : TRect;
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
      for I := 0 to Length(FilesToDrag) - 1 do
        DropFileSource1.Files.Add(FilesToDrag[I]);
      ElvMain.Refresh;

      Application.HideHint;
      if ImHint <> nil then
        if not UnitImHint.Closed then
          ImHint.Close;
      HintTimer.Enabled := False;

      DropFileSource1.ImageHotSpotX := SpotX;
      DropFileSource1.ImageHotSpotY := SpotY;

      DropFileSource1.ImageIndex := 0;
      DropFileSource1.Execute;
      DBCanDrag := False;
    end;
  end;

  if LoadingThItem = ItemAtPos(X, Y) then
    Exit;
  LoadingThItem := ItemAtPos(X, Y);
  if LoadingThItem = nil then
  begin
    Application.HideHint;
    if ImHint <> nil then
      if not UnitImHint.Closed then
        ImHint.Close;
    HintTimer.Enabled := False;
  end
  else
  begin
    HintTimer.Enabled := False;
    if Self.Active then
    begin
      if DBKernel.Readbool('Options', 'AllowPreview', True) then
        HintTimer.Enabled := True;
      ShLoadingThItem := LoadingThItem;
    end;
  end;
end;

procedure TFormCont.FormDeactivate(Sender: TObject);
begin
 HintTimer.Enabled:=false;
end;

function TFormCont.GetListItemByID( ID : integer): TEasyItem;
var
  i : integer;
begin
 result:=nil;
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  if ElvMain.Items[i].Tag=ID then
  begin
   Result:=ElvMain.Items[i];
   break;
  end;
 end;
end;

procedure TFormCont.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
 DropFileTarget2.Unregister;
 FBitmapImageList.Free;
 DBkernel.UnRegisterForm(self);
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
end;

procedure TFormCont.Copy1Click(Sender: TObject);
var
  i : integer;
  s : string;
begin
 s:='';
 for i:=0 to length(Data)-1 do
 s:=s+inttostr(Data[i].ID)+'$';
 Clipboard.AsText:=s;
end;

procedure TFormCont.Paste1Click(Sender: TObject);
var
  s,s1 : string;
  fids_ : tarinteger;
  i,n:integer;
  param : TArStrings;
  b : TArBoolean;
begin
  s :=Clipboard.AsText;
  for i:=length(s) downto 1 do
  if not (s[i] in cifri) and (s[i]<>'$') then delete(s,i,1);
  if length(s)<2 then exit;
  n:=1;
  for i:=1 to length(s) do
  if s[i]='$' then
  begin
   s1:=copy(s,n,i-n);
   n:=i+1;
   setlength(fids_,length(fids_)+1);
  fids_[length(fids_)-1]:=strtointdef(s1,0);
  end;
  Setlength(param,1);
  Setlength(b,1);
  LoadFilesToPanel.Create(param,fids_,b,false,true,self);
end;

procedure TFormCont.LoadFromFile1Click(Sender: TObject);
var
  fids_ : TArInteger;
  param : TArStrings;
  b : TArBoolean;
  OpenDialog : DBOpenDialog;
begin

 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='All supported (*.ids,*.dbl)|*.dbl;*.ids|DataDase Results (*.ids)|*.ids|DataDase FileList (*.dbl)|*.dbl';
 OpenDialog.FilterIndex:=1;

 if FilePushed then OpenDialog.SetFileName(FilePushedName);

 if FilePushed or OpenDialog.Execute then
 begin
  if GetExt(OpenDialog.FileName)='IDS' then
  begin
   fids_:=LoadIDsFromfileA(OpenDialog.FileName);
   SetLength(param,1);
   Setlength(b,1);
   LoadFilesToPanel.Create(param,fids_,b,false,true,self);
  end;
  if GetExt(OpenDialog.FileName)='DBL' then
  begin
   LoadDblFromfile(OpenDialog.FileName,fids_,param);
   LoadFilesToPanel.Create(param,fids_,b,false,true,self);
   LoadFilesToPanel.Create(param,fids_,b,false,false,self);
  end;
 end;
 OpenDialog.Free;
 FilePushed:=false;
end;

procedure TFormCont.SlideShow1Click(Sender: TObject);
var
  Info: TRecordsInfo;
  DBInfo: TDBPopupMenuInfo;
begin
  Info := RecordsInfoNil;
  DBInfo := GetCurrentPopUpMenuInfo(nil);
  DBPopupMenuInfoToRecordsInfo(DBInfo, Info);
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.Execute(Sender, Info);
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
  i, MenuLength : integer;
  MenuRecord : TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfo.Create;
  Result.IsListItem:=false;
  Result.IsPlusMenu:=false;
  MenuLength:=Length(Data);

  for i:=0 to MenuLength-1 do
  begin
    MenuRecord := TDBPopupMenuInfoRecord.CreateFromContRecord(Data[i]);
    Result.Add(MenuRecord);
  end;
 For i:=0 to ElvMain.Items.Count-1 do
 Result[i].Selected:=ElvMain.Items[i].Selected;

 Result.Position:=0;
 If Item=nil then
 begin
 end else begin
  If SelCount=1 then
  begin
   Result.IsListItem:=true;
   Result.ListItem:=ListView1Selected;
   Result.Position:=ListView1Selected.Index;
  end;
  If SelCount>1 then
  begin
   Result.Position:=Item.Index;
  end;
 end;
end;


procedure TFormCont.LoadLanguage;
begin
  Label1.Caption := TEXT_MES_QUICK_INFO + ':';
  SlideShow1.Caption := TEXT_MES_SLIDE_SHOW;
  SelectAll1.Caption := TEXT_MES_SELECT_ALL;
  Copy1.Caption := TEXT_MES_COPY;
  Paste1.Caption := TEXT_MES_PASTE;
  LoadFromFile1.Caption := TEXT_MES_LOAD_FROM_FILE;
  SaveToFile1.Caption := TEXT_MES_SAVE_TO_FILE;
  Clear1.Caption := TEXT_MES_CLEAR;
  Close1.Caption := TEXT_MES_CLOSE;
  WebLink1.Text := TEXT_MES_SIZE;
  WebLink2.Text := TEXT_MES_TYPE;
  ExportLink.Text := TEXT_MES_EXPORT;
  ExCopyLink.Text := TEXT_MES_EX_COPY;
  GroupBox1.Caption := TEXT_MES_PHOTO;

  TbResize.Caption := TEXT_MES_SIZE;
  TbConvert.Caption := TEXT_MES_TYPE;
  TbExport.Caption := TEXT_MES_EXPORT;
  TbCopy.Caption := TEXT_MES_EX_COPY;
  ToolButton6.Caption := TEXT_MES_CLOSE;
end;

procedure TFormCont.LoadSizes;
begin
  SetLVThumbnailSize(ElvMain, fPictureSize);
end;

procedure TFormCont.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

function TFormCont.ExistsItemByFileName(FileName: string): Boolean;
var
  i : integer;
begin
 result:=false;
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(Data)-1 do
 if AnsiLowerCase(Data[i].FileName)=FileName then
 begin
  Result:=true;
  break;
 end;
end;

procedure TFormCont.AddFileName(FileName: String);
var
  Param : TArStrings;
  Ids : TArInteger;
  b : TArBoolean;
begin
 SetLength(Param,1);
 Param[0]:=FileName;
 Setlength(b,1);
 Setlength(ids,1);
 LoadFilesToPanel.Create(param,ids,b,false,false,self);
end;

procedure TFormCont.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Y : Integer;
  Info : TImageContRecord;
begin
  if Item.Data = nil then
    Exit;

  if Item.ImageIndex < 0 then
    Exit;

  Info := Data[Item.Index];

  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y,
    True, Info.ID, Info.FileName,
    Info.Rating, Info.Rotation, Info.Access, Info.Crypted, Info.Exists);
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
  i : integer;
  r : TRect;
  t : array of boolean;
  rv : TRect;
begin
 SetLength(Result,0);
 SetLength(t,0);
 rv :=  ElvMain.Scrollbars.ViewableViewportRect;
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  r:=Rect(ElvMain.ClientRect.Left+rv.Left,ElvMain.ClientRect.Top+rv.Top,ElvMain.ClientRect.Right+rv.Left,ElvMain.ClientRect.Bottom+rv.Top);
  if RectInRect(r,TEasyCollectionItemX(ElvMain.Items[i]).GetDisplayRect) then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:=Data[i].FileName;
  end;
 end;
end;

procedure TFormCont.AddThread;
begin
  Inc(FThreadCount);
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
  FPanels.Free;
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
    MenuitemSentToNew.Caption := TEXT_MES_NEW_PANEL;
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

Function TManagePanels.NewPanel : TFormCont;
Var
  i, FTag : integer;
  s : string;

  Function TagExists(Tag : Integer) : Boolean;
  var i:integer;
  begin
   result:=false;
   For i:=0 to FPanels.Count - 1 do
   if Self[i].Tag=Tag then
   begin
    Result:=True;
    Break;
   end;
  end;

begin
 s:='';
 FTag:=0;
 If FPanels.Count = 0 then
 begin
  FTag:=1;
  s:=Format(TEXT_MES_PANEL_CAPTION,[IntToStr(FTag)]);
 end;
 If FPanels.Count > 0 then
 begin
  For i:=0 to FPanels.Count-1 do
  if not TagExists(i+1) then
  begin
   s:=format(TEXT_MES_PANEL_CAPTION,[inttostr(i+1)]);
   FTag:=i+1;
   break;
  end;
  if FTag=0 then
  begin
   s:=format(TEXT_MES_PANEL_CAPTION,[inttostr(FPanels.Count+1)]);
   FTag:=FPanels.Count+1;
  end;
 end;
 Application.CreateForm(TFormCont,Result);
 if s<>'' then
 begin
  Result.Caption:=s;
  Result.Tag:=FTag;
 end;
end;

function TManagePanels.PanelIndex(Panel: TFormCont): Integer;
begin
  FPanels.Indexof(Panel);
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
  Info: TRecordsInfo;
  Pos, MousePos: TPoint;
  Item: TEasyItem;
begin

  GetCursorPos(MousePos);
  Pos := ElvMain.ScreenToClient(MousePos);
  Item := ItemAtPos(Pos.X, Pos.Y);
  if (Item <> nil) and (Item.ImageIndex > -1) then
  begin
    Item := ItemByPointStar(ElvMain, Pos, FPictureSize, FBitmapImageList[Item.ImageIndex].Graphic);
    if Item <> nil then
    begin
      if ItemAtPos(Pos.X, Pos.Y).Tag <> 0 then
      begin
        RatingPopupMenu1.Tag := ItemAtPos(Pos.X, Pos.Y).Tag;
        Application.HideHint;
        if (ImHint <> nil) and not not UnitImHint.Closed then
          ImHint.Close;
        LoadingThitem := nil;
        RatingPopupMenu1.Popup(MousePos.X, MousePos.Y);
        Exit;
      end;
    end;
  end;

  Application.HideHint;
  if ImHint <> nil then
    if not UnitImHint.Closed then
      ImHint.Close;
  HintTimer.Enabled := False;
  if ListView1Selected <> nil then
  begin
    MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    DBPopupMenuInfoToRecordsInfo(MenuInfo, Info);
    Viewer.Execute(Sender, Info);
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
      if ImHint <> nil then
        if not UnitImHint.Closed then
          ImHint.Close;
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
  i : integer;
  Param : TArStrings;
  Ids : TArInteger;
  b : TArBoolean;
begin
 if DBCanDrag then exit;
 for i:=0 to DropFileTarget2.Files.Count-1 do
 begin
  if ExtinMask(SupportedExt,GetExt(DropFileTarget2.Files[i])) then
  begin
   SetLength(Param,Length(Param)+1);
   Param[Length(Param)-1]:=DropFileTarget2.Files[i];
  end else
  begin
   FilePushed:=true;
   FilePushedName:=DropFileTarget2.Files[i];
   LoadFromFile1Click(nil);
  end;
 end;
 SetLength(ids,1);
 SetLength(b,1);
 LoadFilesToPanel.Create(param,ids,b,false,false,self);
end;

procedure TFormCont.WebLink1Click(Sender: TObject);
var
  I: Integer;
  List: TDBPopupMenuInfo;
  ImageInfo: TDBPopupMenuInfoRecord;
begin
  List := TDBPopupMenuInfo.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        ImageInfo := TDBPopupMenuInfoRecord.CreateFromContRecord(Data[I]);
        List.Add(ImageInfo);
      end;
    ResizeImages(List);
  finally
    List.Free;
  end;
end;

procedure TFormCont.WebLink2Click(Sender: TObject);
var
  i : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(Data[i].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=Data[i].ID;
 end;
 ConvertImages(ImageList,IDList);
end;

procedure TFormCont.ExportLinkClick(Sender: TObject);
var
  i : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(Data[i].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=Data[i].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=Data[i].Rotation;
 end;
 ExportImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATE_90);
end;

procedure TFormCont.ExCopyLinkClick(Sender: TObject);

type
 TDestDype = record
  Dest : String;
  Files : array of String;
 end;

var
  FileName, Temp, UpDir, Dir, NewDir : String;
  l1,l2 : integer;
  i : integer;
  DestWide : array of TDestDype;

  procedure AddFileToDestWide(NewDir,NewFileName : String);
  var
    i : integer;
  begin
   for i:=0 to Length(DestWide)-1 do
   if AnsiLowerCase(DestWide[i].Dest)=AnsiLowerCase(NewDir) then
   begin
    SetLength(DestWide[i].Files,Length(DestWide[i].Files)+1);
    DestWide[i].Files[Length(DestWide[i].Files)-1]:=NewFileName;
    Exit;
   end;
   SetLength(DestWide,Length(DestWide)+1);
   With DestWide[Length(DestWide)-1] do
   begin
    Dest:=NewDir;
    SetLength(Files,1);
    Files[0]:=NewFileName;
   end;
  end;

begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SELECT_PLACE_TO_COPY,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(Dir) then
 begin
  SetLength(DestWide,0);
  FormatDir(Dir);
  for i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   FileName:=ProcessPath(Data[i].FileName);
   Temp:=GetDirectory(FileName);
   UnFormatDir(Temp);
   l1:=Length(Temp);
   Temp:=GetDirectory(Temp);
   FormatDir(Temp);
   l2:=Length(Temp);
   UpDir:=Copy(FileName,l2+1,l1-l2);
   NewDir:=Dir+UpDir;
   AddFileToDestWide(NewDir,FileName);
  end;
 end;
 For i:=0 To Length(DestWide)-1 do
 begin
  FormatDir(DestWide[i].Dest);
  CreateDirA(DestWide[i].Dest);
  CopyFiles(Handle,DestWide[i].Files,DestWide[i].Dest,false,true);
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
  if PromtString(TEXT_MES_ENTER_TEXT, TEXT_MES_ENTER_CAPTION_OF_PANEL, S) then
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
  I: Integer;
  Item: TEasyItem;
begin

  Item := Self.ItemAtPos(X, Y);
  if Item <> nil then
    if Item.Selected then
    begin
      if (Shift = []) and Item.Selected then
        if ItemByMouseDown then
        begin
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
              if Item <> ElvMain.Items[I] then
                ElvMain.Items[I].Selected := False;
        end;
      if not(EbcsDragSelecting in ElvMain.States) then
        if ([SsCtrl] * Shift <> []) and not ItemSelectedByMouseDown and (Button = MbLeft) then
          Item.Selected := False;
    end;

  if MouseDowned then
    if Button = MbRight then
    begin
      ListView1ContextPopup(ElvMain, Point(X, Y), Handled);
      PopupHandled := True;
    end;

  MouseDowned := False;
end;

procedure TFormCont.UpdateTheme(Sender: TObject);
begin
  CreateBackgroundImage;
  ElvMain.Selection.FullCellPaint := DBKernel.Readbool('Options', 'UseListViewFullRectSelect', False);
  ElvMain.Selection.RoundRectRadius := DBKernel.ReadInteger('Options', 'UseListViewRoundRectSize', 3);
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
  Ico : TIcon;

  procedure AddIcon(Name : String);
  begin
    Ico := TIcon.Create;
    Ico.Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar(Name));
    ToolBarImageList.AddIcon(Ico);
  end;

  procedure AddDisabledIcon(Name : String);
  begin
    Ico := TIcon.Create;
    Ico.Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar(Name));
    ToolBarDisabledImageList.AddIcon(Ico);
  end;

begin

  ConvertTo32BitImageList(ToolBarImageList);
  ConvertTo32BitImageList(ToolBarDisabledImageList);

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
    if FPictureSize > 40 then
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
    if FPictureSize < 550 then
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
    ElvMain.EndUpdate();
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
begin
  BigImagesTimer.Enabled := False;
  BigImagesSID := GetGUID;

  TbStop.Enabled := True;

  // тут начинается загрузка больших картинок
  TPanelLoadingBigImagesThread.Create(Self, BigImagesSID, nil, FPictureSize, Copy(Data));
end;

function TFormCont.FileNameExistsInList(FileName: string): Boolean;
var
  I: Integer;
begin
  FileName := AnsiLowerCase(FileName);
  Result := False;
  for I := 0 to Length(Data) - 1 do
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
  for I := 0 to Length(Data) - 1 do
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

procedure TFormCont.DoStopLoading(CID: TGUID);
begin
  if IsEqualGUID(CID, SID) or IsEqualGUID(CID, BigImagesSID) then
  begin
    if IsEqualGUID(CID, SID) then
      Dec(FThreadCount);
    if FThreadCount = 0 then
      TbStop.Enabled := False;
  end;
end;

function TFormCont.IsSelectedVisible: boolean;
var
  i : integer;
  r : TRect;
  t : array of boolean;
  rv : TRect;
begin
 Result:=false;
 SetLength(t,0);
 rv :=  ElvMain.Scrollbars.ViewableViewportRect;
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  r:=Rect(ElvMain.ClientRect.Left+rv.Left,ElvMain.ClientRect.Top+rv.Top,ElvMain.ClientRect.Right+rv.Left,ElvMain.ClientRect.Bottom+rv.Top);
  if RectInRect(r,TEasyCollectionItemX(ElvMain.Items[i]).GetDisplayRect) then
  begin
   if ElvMain.Items[i].Selected then
   begin
    Result:=true;
    exit;
   end;
  end;
 end;
end;

procedure TFormCont.TerminateTimerTimer(Sender: TObject);
begin
 TerminateTimer.Enabled:=false;
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
  Dolphin_DB.SetRating(RatingPopupMenu1.Tag,(Sender as TMenuItem).Tag);
  EventInfo.Rating:=(Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Sender,RatingPopupMenu1.Tag,[EventID_Param_Rating],EventInfo);
end;

procedure TFormCont.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
 Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
 BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
end;

Initialization
 ManagerPanels := TManagePanels.Create;

Finalization
 ManagerPanels.Free;

end.
