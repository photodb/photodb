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
  UnitDBCommon, UnitCDMappingSupport, uLogger, uConstants, uThreadForm;

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
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
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
    ImageBackGround: TImage;
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
    BigImagesTimer: TTimer;
    WebLink1: TWebLink;
    RedrawTimer: TTimer;
    ToolButton10: TToolButton;
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
    procedure SpeedButton2Click(Sender: TObject);
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
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure TerminateTimerTimer(Sender: TObject);
    procedure N05Click(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
  private
    MouseDowned : Boolean;
    PopupHandled : boolean;
    LoadingThItem, ShLoadingThItem : TEasyItem;

    ListView1 : TEasyListView;
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
    procedure EasyListview1DblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
    procedure EasyListview1ItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    Procedure ListView1Resize(Sender : TObject);
    procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem;
      const SearchBuffer: WideString; var CompareResult: Integer);
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
   WindowID : TGUID;   
   SID : TGUID;
   BigImagesSID : TGUID;
   procedure DoStopLoading(CID: TGUID);
   function IsSelectedVisible: boolean;
   procedure AddFileName(FileName: String);
   function GetPictureSize : integer;
   procedure ZoomOut;
   procedure ZoomIn;
   function GetVisibleItems : TArStrings;
   function FileNameExistsInList(FileName : string) : boolean;
   procedure ReplaseBitmapWithPath(FileName : string; Bitmap : TBitmap);
   procedure AddThread;         
   procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
  private
   fPictureSize : integer;
   fThreadCount : integer;
  published
  FBitmapImageList : TBitmapImageList;
  procedure LoadLanguage;
  procedure LoadToolBarIcons();

    { Public declarations }
  end;

  TManagePanels = class(TObject)
   Private
    FPanels : TList;
    function GetPanelByIndex(Index: Integer): TFormCont;
   Public
    constructor Create;
    destructor Destroy; override;
    Function NewPanel : TFormCont;
    Procedure FreePanel(Panel : TFormCont);
    Procedure AddPanel(Panel : TFormCont);
    Procedure RemovePanel(Panel : TFormCont);
    Function GetPanelsTexts : TStrings;
    Function ExistsPanel(Panel : TForm; CID : TGUID) : Boolean;
    Function Count : integer;
    function IsPanelForm(Panel: TForm): Boolean;
    property Items[Index: Integer]: TFormCont read GetPanelByIndex; default;
  end;


var
  FormsCount_ : integer = 0;
  ManagerPanels : TmanagePanels;

implementation

uses language, Searching, UnitImHint, UnitLoadFilesToPanel, UnitHintCeator,
     SlideShow, ExplorerUnit, UnitSizeResizerForm, UnitImageConverter,
     UnitRotateImages, UnitExportImagesForm, CommonDBSupport,
     UnitStringPromtForm, Loadingresults, UnitBigImagesSize;

{$R *.dfm}

{ TFormCont }

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(hwnd, nil, 0, {DW_FRAME + }RDW_INVALIDATE +
    RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (erase) then
    Windows.InvalidateRect(hwnd, nil, True);
end;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint): TEasyItem;
var
  i: Integer;
  r : TRect;
  RectArray: TEasyRectArrayObject;
begin
  Result := nil;
  i := 0;
  r :=  EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X:=ViewportPoint.X+r.Left;         
  ViewportPoint.Y:=ViewportPoint.Y+r.Top;
  while not Assigned(Result) and (i < EasyListview.Items.Count) do
  begin
      EasyListview.Items[i].ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);

      if PtInRect(RectArray.IconRect, ViewportPoint) then
       Result := EasyListview.Items[i];
      if PtInRect(RectArray.TextRect, ViewportPoint) then
       Result := EasyListview.Items[i];
    Inc(i)
  end
end;

procedure TFormCont.RefreshItemByID(ID: integer);
var
  Index : integer;
  fData : TImageContRecordArray;
begin
 Index:=GetListItemByID(id).Index;
 SetLength(fData,1);
 fData[0]:=Data[Index];
 
 TPanelLoadingBigImagesThread.Create(false,self,BigImagesSID,nil,fPictureSize,Copy(fData));
end;

procedure TFormCont.FormCreate(Sender: TObject);
var
  i : integer;
begin
 FilePushedName:='';
 fThreadCount:=0;
 SID:=GetGUID;
 BigImagesSID:=GetGUID;
 fPictureSize:=ThSizePanelPreview;
 DBKernel.RegisterProcUpdateTheme(UpdateTheme,self);
 ListView1 := TEasyListView.Create(self);
 ListView1.Parent:=self;
 ListView1.Align:=AlClient;

     MouseDowned:=false;
     PopupHandled:=false;
     ListView1.BackGround.Enabled:=true;
     ListView1.BackGround.Tile:=false;
     ListView1.BackGround.AlphaBlend:=true;
     ListView1.BackGround.OffsetTrack:=true;
     ListView1.BackGround.BlendAlpha:=220;
     ListView1.BackGround.Image:=TBitmap.create;
     ListView1.BackGround.Image.PixelFormat:=pf24bit;
     ListView1.BackGround.Image.Width:=120;
     ListView1.BackGround.Image.Height:=120;
     ListView1.BackGround.Image.Canvas.Brush.Color:=Theme_ListColor;
     ListView1.BackGround.Image.Canvas.Pen.Color:=Theme_ListColor;
     ListView1.BackGround.Image.Canvas.Rectangle(0,0,120,120);

     for i:=1 to 20 do
     begin
      try
       ListView1.BackGround.Image.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
       break;
      except
       Sleep(50);
      end;
     end;

     ListView1.Font.Color:=0;
     ListView1.View:=elsThumbnail;
     ListView1.DragKind:=dkDock;       
     ListView1.HotTrack.Color:=Theme_ListFontColor;

     ListView1.Selection.FullRowSelect:=true;
     ListView1.Selection.UseFocusRect:=true;

     ListView1.Selection.MouseButton:= [cmbRight];
     ListView1.Selection.AlphaBlend:=true;
     ListView1.Selection.AlphaBlendSelRect:=true;
     ListView1.Selection.MultiSelect:=true;
     ListView1.Selection.RectSelect:=true;
     ListView1.Selection.EnableDragSelect:=true;
     ListView1.Selection.TextColor:=Theme_ListFontColor;

     ListView1.CellSizes.Thumbnail.Width:=ThSizePanelPreview+12;
     ListView1.CellSizes.Thumbnail.Height:=ThSizePanelPreview+38;
     ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
     ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);

     ListView1.IncrementalSearch.Enabled:=true;
     ListView1.OnItemThumbnailDraw:=EasyListview1ItemThumbnailDraw;

     ListView1.OnDblClick:=EasyListview1DblClick;

     ListView1.OnIncrementalSearch:=Listview1IncrementalSearch;
     ListView1.OnMouseDown:=ListView1MouseDown;
     ListView1.OnMouseUp:=ListView1MouseUp;
     ListView1.OnMouseMove:=ListView1MouseMove;
     ListView1.OnItemSelectionChanged:=EasyListview1ItemSelectionChanged;
     ListView1.OnMouseWheel:=ListView1MouseWheel;
     ListView1.OnResize:=ListView1Resize;
     ListView1.Groups.Add;    
     ListView1.HotTrack.Cursor:=CrArrow;
                       
   ConvertTo32BitImageList(DragImageList);

 WindowID:=GetGUID;
 FilePushed:=false;
 LoadLanguage;


 ListView1.HotTrack.Enabled:=DBKernel.Readbool('Options','UseHotSelect',true);

 DropFileTarget2.Register(Self);
 FBitmapImageList := TBitmapImageList.Create;
 ManagerPanels.AddPanel(self);
 DBkernel.RecreateThemeToForm(self);
 ListView1.DoubleBuffered:=true;
 inc(FormsCount_);
 Caption:=format(TEXT_MES_PANEL_CAPTION,[inttostr(FormsCount_)]);
 Tag:=FormsCount_;
 DBKernel.RegisterChangesID(self,ChangedDBDataByID);
 PopupMenu1.Images:=DBKernel.ImageList;
 Copy1.ImageIndex:=DB_IC_COPY;
 Paste1.ImageIndex:=DB_IC_PASTE;
 LoadFromFile1.ImageIndex:=DB_IC_LOADFROMFILE;
 SaveToFile1.ImageIndex:=DB_IC_SAVETOFILE;
 SelectAll1.ImageIndex:=DB_IC_SELECTALL;
 Close1.ImageIndex:=DB_IC_EXIT;
 Clear1.ImageIndex:=DB_IC_DELETE_INFO;
 SlideShow1.ImageIndex:=DB_IC_SLIDE_SHOW;

 Rename1.ImageIndex:=DB_IC_RENAME;

 Label2.Caption:=TEXT_MES_ACTIONS+':';
 Rename1.Caption:=TEXT_MES_RENAME;
 WebLink1.LoadFromHIcon(UnitDBKernel.icons[DB_IC_RESIZE+1]);
 WebLink2.LoadFromHIcon(UnitDBKernel.icons[DB_IC_CONVERT+1]);
 ExportLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_EXPORT_IMAGES+1]);
 ExCopyLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_COPY+1]);
                                 
 RatingPopupMenu1.Images:=DBkernel.ImageList;

 N00.ImageIndex:=DB_IC_DELETE_INFO;
 N01.ImageIndex:=DB_IC_RATING_1;
 N02.ImageIndex:=DB_IC_RATING_2;
 N03.ImageIndex:=DB_IC_RATING_3;
 N04.ImageIndex:=DB_IC_RATING_4;
 N05.ImageIndex:=DB_IC_RATING_5;

 WebLink2.Top:=WebLink1.Top+WebLink1.Height+5;
 ExportLink.Top:=WebLink2.Top+WebLink2.Height+5;
 ExCopyLink.Top:=ExportLink.Top+ExportLink.Height+5;
                           
 DBkernel.RegisterForm(self);
 LoadToolBarIcons;
end;

procedure TFormCont.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 ManagerPanels.RemovePanel(self);
 TerminateTimer.Enabled:=true;
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

 Item:=ItemByPointImage(ListView1, Point(MousePos.x,MousePos.y)); 
 if (Item=nil) or ((MousePos.x=-1) and (MousePos.y=-1)) then Item:=ListView1.Selection.First;

 HintTimer.Enabled:=false;
 if item <>nil then
 begin
  loadingthitem:= nil;
  application.HideHint;
  if ImHint<>nil then
  ImHint.close;
  hinttimer.Enabled:=false;
  info:=GetCurrentPopUpMenuInfo(item);
  info.IsAttrExists:=false;
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
   TDBPopupMenu.Instance.ExecutePlus(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y,Info,menus);
  end else
  begin
   SetLength(FileNames,0);
   For i:=0 to length(Info.ItemFileNames_)-1 do
   if Info.ItemSelected_[i] then
   begin
    SetLength(FileNames,Length(FileNames)+1);
    FileNames[Length(FileNames)-1]:=Info.ItemFileNames_[i];
   end;
   GetProperties(FileNames,MousePos,ListView1);
  end;
 end else PopupMenu1.Popup(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y);
end;

procedure TFormCont.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i : integer;
  MenuInfo : TDBPopupMenuInfo;
  item, itemsel : TEasyItem;
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
    for i:=0 to Listview1.Items.Count-1 do
    if Listview1.Items[i].Selected then
    if itemsel<>Listview1.Items[i] then
    Listview1.Items[i].Selected:=false;
    if [ssShift]*Shift<>[] then
     Listview1.Selection.SelectRange(itemsel,Listview1.Selection.FocusedItem,false,false) else
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
    For i:=0 to length(MenuInfo.ItemFileNames_)-1 do
    if ListView1.Items[i].Selected then
    If FileExists(MenuInfo.ItemFileNames_[i]) then
    begin
     SetLength(FilesToDrag,Length(FilesToDrag)+1);
     FilesToDrag[Length(FilesToDrag)-1]:=MenuInfo.ItemFileNames_[i];
    end;
    If Length(FilesToDrag)=0 then DBCanDrag:=false;
  end;
end;

procedure TFormCont.DeleteIndexItemByID(ID : integer);
var
  i, j : integer;
begin
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if i>ListView1.Items.Count-1 then break;
  if Data[i].ID=ID then
  begin
   ListView1.Items.Delete(i);
   FBitmapImageList.Delete(ListView1.Items[i].ImageIndex);
   for j:=i to listView1.Items.Count-1 do
   begin
    ListView1.Items[j].ImageIndex:=ListView1.Items[j].ImageIndex-1;
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
 ListView1.Groups.BeginUpdate(true);
 for i:=0 to ListView1.Items.Count-1 do
 begin
  if i>ListView1.Items.Count-1 then break;  
  if ListView1.Items[i].Selected then
  begin
   FBitmapImageList.Delete(ListView1.Items[i].ImageIndex);
   ListView1.Items.Delete(i);
   ListView1.Groups.Rebuild(true);
   for j:=i to listView1.Items.Count-1 do
   begin
    ListView1.Items[j].ImageIndex:=ListView1.Items[j].ImageIndex-1;
    Data[j]:=Data[j+1];
   end;
   SetLength(Data,Length(Data)-1);
   p_i^:=i-1;
  end;
 end;
 Sender.Free;
 ListView1.Groups.EndUpdate;
end;

procedure TFormCont.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i, ReRotation : integer;
  item: TEasyItem;
  RefreshParams : TEventFields;
begin  
 if EventID_Repaint_ImageList in params then
 begin
  ListView1.Refresh;
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
   Boolean(TDataObject(item.Data).Data^):=Value.Include;
  end;
 end;

 if [EventID_Param_Rotate]*params<>[] then
 begin
  for i:=0 to Length(Data)-1 do
  if Data[i].ID=ID then
  begin
   if ListView1.Items[i].ImageIndex>-1 then
   begin
     ApplyRotate(FBitmapImageList[ListView1.Items[i].ImageIndex].Bitmap, ReRotation);
   end;
  end;
 end;

 if (EventID_Param_Image in params) then
 if GetListItemById(id)<>nil then
 begin
  //TODO: normal image
  RefreshItemByID(id);
 end;
 if (EventID_Param_Include in params) then ListView1.Refresh;
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
   ListView1.Refresh;
   break;
  end;
  exit;
 end;

 RefreshParams:=[EventID_Param_Private,EventID_Param_Rotate,EventID_Param_Name,EventID_Param_Rating,EventID_Param_Crypt];
 if RefreshParams*params<>[] then
 begin
  ListView1.Repaint;
 end;

 if [EventID_Param_DB_Changed] * params<>[] then
 begin
  Close;
 end;
end;

procedure TFormCont.AddNewItem(Image : Tbitmap; Info : TOneRecordInfo);
var
  New: TEasyItem;
  p : PBoolean;
  L : integer;
begin
 if Info.ItemId<>0 then
 begin
  if ExistsItemById(Info.ItemId) then exit;
 end else
 begin
  if ExistsItemByFileName(Info.ItemFileName) then exit;
 end;

 new := ListView1.Items.Add;

 new.Tag:=Info.ItemId;

 Getmem(p,SizeOf(Boolean));
 p^:=Info.ItemInclude; 
 new.Data:=TDataObject.Create;
 TDataObject(new.Data).Data:=p;

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
  ToolButton1.Enabled:=false;  
  ToolButton2.Enabled:=false;
  ToolButton3.Enabled:=false;
  ToolButton4.Enabled:=false;
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
  ToolButton1.Enabled:=true;
  ToolButton2.Enabled:=true;
  ToolButton3.Enabled:=true;
  ToolButton4.Enabled:=true;
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
 ListView1.Selection.SelectAll;
 ListView1.SetFocus;
end;

procedure TFormCont.Clear1Click(Sender: TObject);
begin
 SetLength(Data,0);
 FBitmapImageList.Clear;
 ListView1.Items.Clear;
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

procedure TFormCont.SpeedButton2Click(Sender: TObject);
begin
 DropFileTarget2.Unregister;
 if SpeedButton2.Down then
 FormStyle:=fsStayOnTop else
 FormStyle:=fsNormal;
 DropFileTarget2.Register(Panel1);
end;

function TFormCont.hintrealA(item: TObject): boolean;
var
  p, p1 : tpoint;
begin
 getcursorpos(p);
 p1:=listview1.ScreenToClient(p);
 result:=not ((not self.Active) or (not listview1.Focused) or (ItemAtPos(p1.X,p1.y)<>loadingthitem) or (ItemAtPos(p1.X,p1.y)=nil) or (item<>loadingthitem));
end;

procedure TFormCont.HinttimerTimer(Sender: TObject);
var
  p, p1 : TPoint;
  index, i : integer;
begin
 GetCursorPos(p);
 p1:=ListView1.ScreenToClient(p);
 if (not self.Active) or (not ListView1.Focused) or (ItemAtPos(p1.X,p1.y)<>LoadingThItem) or (shloadingthitem<>loadingthitem) then
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
   for i:=0 to Listview1.Items.Count-1 do
   if Listview1.Items[i].Selected then
   if LoadingThItem<>Listview1.Items[i] then
   Listview1.Items[i].Selected:=false;
   if ShiftKeyDown then
   Listview1.Selection.SelectRange(loadingthitem,Listview1.Selection.FocusedItem,false,false) else
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
  p : Tpoint;
  i, n, MaxH, MaxW, ImH,ImW : integer;
  TempImage, DragImage : TBitmap;
  SelectedItem, item: TEasyItem;
  FileName : string;
  R : TRect;
  EasyRect : TEasyRectArrayObject;
Const
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK+DT_CENTER;

  function GetImageByIndex(index : integer) : TBitmap;
  begin
   Result:=FBitmapImageList[index].Bitmap;
   Result:=RemoveBlackColor(Result);
  end;

begin
 If DBCanDrag then
 begin
  GetCursorPos(p);
  If (abs(DBDragPoint.x-p.x)>3) or (abs(DBDragPoint.y-p.y)>3) then
  begin

   p:=DBDragPoint;

   item:=ItemAtPos(ListView1.ScreenToClient(p).x,ListView1.ScreenToClient(p).y);
   if item=nil then exit;
   if Listview1.Selection.FocusedItem=nil then
   Listview1.Selection.FocusedItem:=item;
   //Creating Draw image
   TempImage:=TBitmap.create;
   TempImage.PixelFormat:=pf32bit;
   TempImage.Width:=fPictureSize+Min(ListView1.Selection.Count,10)*7+5;
   TempImage.Height:=fPictureSize+Min(ListView1.Selection.Count,10)*7+45+1;
   MaxH:=0;
   MaxW:=0;
   TempImage.Canvas.Brush.Color := 0;
   TempImage.Canvas.FillRect(Rect(0, 0, TempImage.Width, TempImage.Height));

   if ListView1.Selection.Count<2 then
   begin
    DragImage:=nil;
    if item<>nil then
    DragImage:=GetImageByIndex(item.ImageIndex) else
    if ListView1.Selection.First<>nil then
    DragImage:=GetImageByIndex(Listview1.Selection.First.ImageIndex);

    TempImage.Canvas.Draw(0,0, DragImage);
    n:=0;
    MaxH:=DragImage.Height;
    MaxW:=DragImage.Width;
    ImH:=DragImage.Height;
    ImW:=DragImage.Width;
    DragImage.Free;
   end else
   begin
    SelectedItem:=Listview1.Selection.First;
    n:=1;
    for i:=1 to 9 do
    begin
     if SelectedItem<>item then
     begin
      DragImage:=GetImageByIndex(SelectedItem.ImageIndex);
      TempImage.Canvas.Draw(n,n, DragImage);
      Inc(n,7);
      if DragImage.Height+n>MaxH then MaxH:=DragImage.Height+n;
      if DragImage.Width+n>MaxW then MaxW:=DragImage.Width+n;
      DragImage.Free;
     end;
     SelectedItem:=Listview1.Selection.Next(SelectedItem);
     if SelectedItem=nil then break;
    end;
    DragImage:=GetImageByIndex(Listview1.Selection.FocusedItem.ImageIndex);
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
   FileName:=ExtractFileName(Data[Item.Index].FileName);
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
   ListView1.Refresh;

   Application.HideHint;
   if ImHint<>nil then
   if not UnitImHint.closed then
   ImHint.close;
   HintTimer.Enabled:=false;

   item.ItemRectArray(nil,ListView1.Canvas,EasyRect);

   DBDragPoint:=ListView1.ScreenToClient(DBDragPoint);

   ImW:=(EasyRect.IconRect.Right-EasyRect.IconRect.Left) div 2 - ImW div 2;
   ImH:=(EasyRect.IconRect.Bottom-EasyRect.IconRect.Top) div 2 - ImH div 2;
   DropFileSource1.ImageHotSpotX:=Min(MaxW,Max(1,DBDragPoint.X-EasyRect.IconRect.Left+n-ImW));
   DropFileSource1.ImageHotSpotY:=Min(MaXH,Max(1,DBDragPoint.Y-EasyRect.IconRect.Top+n-ImH+ListView1.Scrollbars.ViewableViewportRect.Top));

   DropFileSource1.Execute;
   DBCanDrag:=false;
  end;
 end;
 
 if LoadingThItem=ItemAtPos(X,Y) then exit;
 LoadingThItem:=ItemAtPos(X,Y);
 if LoadingThItem= nil then
 begin
  Application.HideHint;
  if ImHint<>nil then
  if not UnitImHint.closed then
  ImHint.close;
  HintTimer.Enabled:=false;
 end else begin
  HintTimer.Enabled:=false;
  if self.Active then
  begin
   if DBKernel.Readbool('Options','AllowPreview',True) then
   HintTimer.Enabled:=true;
   ShLoadingThItem:=LoadingThItem;
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
 for i:=0 to listview1.Items.Count-1 do
 begin
  if ListView1.Items[i].Tag=ID then
  begin
   Result:=listview1.Items[i];
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
  LoadFilesToPanel.Create(false,param,fids_,b,false,true,self);
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
   LoadFilesToPanel.Create(false,param,fids_,b,false,true,self);
  end;
  if GetExt(OpenDialog.FileName)='DBL' then
  begin
   LoadDblFromfile(OpenDialog.FileName,fids_,param);
   LoadFilesToPanel.Create(false,param,fids_,b,false,true,self);
   LoadFilesToPanel.Create(false,param,fids_,b,false,false,self);
  end;
 end;
 OpenDialog.Free;
 FilePushed:=false;
end;

procedure TFormCont.SlideShow1Click(Sender: TObject);
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

function TFormCont.ExistsItemById(id: integer): boolean;
var
  i : integer;
begin
 result:=false;
 for i:=1 to ListView1.Items.Count do
 if ListView1.Items[i-1].Tag=ID then
 begin
  Result:=true;
  break;
 end;
end;

function TFormCont.GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
var
  i, MenuLength : integer;
begin
 Result.Position:=0;
 Result.IsListItem:=false;
 Result.IsPlusMenu:=false;
 Result.IsDateGroup:=True;
 MenuLength:=Length(Data);

 SetLength(Result.ItemFileNames_,MenuLength);
 SetLength(Result.ItemComments_,MenuLength);
 SetLength(Result.ItemFileSizes_,MenuLength);
 SetLength(Result.ItemRotations_,MenuLength);
 SetLength(Result.ItemIDs_,MenuLength);
 SetLength(Result.ItemSelected_,MenuLength);
 SetLength(Result.ItemAccess_,MenuLength);
 SetLength(Result.ItemRatings_,MenuLength);
 SetLength(Result.ItemDates_,MenuLength);
 SetLength(Result.ItemTimes_,MenuLength);
 SetLength(Result.ItemIsDates_,MenuLength);
 SetLength(Result.ItemIsTimes_,MenuLength);
 SetLength(Result.ItemGroups_,MenuLength);
 SetLength(Result.ItemCrypted_,MenuLength);
 SetLength(Result.ItemKeyWords_,MenuLength);
 SetLength(Result.ItemLoaded_,MenuLength);
 SetLength(Result.ItemAttr_,MenuLength);
 SetLength(Result.ItemInclude_,MenuLength);
 SetLength(Result.ItemLinks_,MenuLength);
 
 For i:=0 to MenuLength-1 do
 begin
  Result.ItemFileNames_[i]:=ProcessPath(Data[i].FileName);
  Result.ItemComments_[i]:=Data[i].Comment;
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
  Result.ItemInclude_[i]:=Data[i].Include;
  Result.ItemKeyWords_[i]:=Data[i].KeyWords;
  Result.ItemLinks_[i]:=Data[i].Links;
  Result.ItemLoaded_[i]:=true;
 end;
 For i:=0 to ListView1.Items.Count-1 do
 if ListView1.Items[i].Selected then
 Result.ItemSelected_[i]:=true else
 Result.ItemSelected_[i]:=false;
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
 Label1.Caption:=TEXT_MES_QUICK_INFO+':';
 SlideShow1.Caption:= TEXT_MES_SLIDE_SHOW;
 SelectAll1.Caption:= TEXT_MES_SELECT_ALL;
 Copy1.Caption:=TEXT_MES_COPY ;
 Paste1.Caption:= TEXT_MES_PASTE ;
 LoadFromFile1.Caption:= TEXT_MES_LOAD_FROM_FILE;
 SaveToFile1.Caption:= TEXT_MES_SAVE_TO_FILE;
 Clear1.Caption:= TEXT_MES_CLEAR;
 Close1.Caption:= TEXT_MES_CLOSE;
 WebLink1.Text:=TEXT_MES_SIZE;
 WebLink2.Text:=TEXT_MES_TYPE;
 ExportLink.Text:=TEXT_MES_EXPORT;
 ExCopyLink.Text:=TEXT_MES_EX_COPY;
 GroupBox1.Caption:=TEXT_MES_PHOTO;

 ToolButton1.Caption:=TEXT_MES_SIZE;  
 ToolButton2.Caption:=TEXT_MES_TYPE;
 ToolButton3.Caption:=TEXT_MES_EXPORT;
 ToolButton4.Caption:=TEXT_MES_EX_COPY;
 ToolButton6.Caption:=TEXT_MES_CLOSE;
end;

procedure TFormCont.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);  
 Params.WndParent := GetDesktopWindow;
 with params do
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
 LoadFilesToPanel.Create(false,param,ids,b,false,false,self);
end;

procedure TFormCont.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  r, r1 : TRect;
  b : TBitmap;
  w,h, index, ind : integer;
  Exists : integer;
begin
 index:=0;
 ind:=0;
 if Item.Data=nil then exit;
 try
  r1:=ARect;
  if Item.ImageIndex<0 then exit;

  if not Boolean(TDataObject(Item.Data).Data^) then
  ListView1.PaintInfoItem.fBorderColor:=$00FFFF
  else ListView1.PaintInfoItem.fBorderColor:=Theme_ListSelectColor;

  b:=TBitmap.Create;
  b.PixelFormat:=pf24bit;
  b.Width:=fPictureSize;
  b.Height:=fPictureSize;
  FillRectNoCanvas(b,Theme_ListColor);

  w:=FBitmapImageList[Item.ImageIndex].Bitmap.Width;
  h:=FBitmapImageList[Item.ImageIndex].Bitmap.Height;
  ProportionalSize(fPictureSize,fPictureSize,w,h);
  b.Canvas.StretchDraw(Rect(fPictureSize div 2 - w div 2,fPictureSize div 2 - h div 2,w+(fPictureSize div 2 - w div 2),h+(fPictureSize div 2 - h div 2)),FBitmapImageList[Item.ImageIndex].Bitmap);

  r.Left:=r1.Left-2;
  r.Top:=r1.Top-2;
  index:=Item.Index;
  DrawAttributes(b,fPictureSize,Data[index].Rating,Data[index].Rotation,Data[index].Access,Data[index].FileName,Data[index].Crypted,Data[index].Exists,Data[index].ID);

  if ProcessedFilesCollection.ExistsFile(Data[index].FileName)<>nil then
  DrawIconEx(b.Canvas.Handle,2,b.Height-18,UnitDBKernel.icons[DB_IC_RELOADING+1],16,16,0,0,DI_NORMAL);


  ACanvas.Draw(r.Left,r.Top,b);

  b.free;

 except
   on e : Exception do EventLog(':TFormCont::EasyListview1ItemThumbnailDraw() throw exception: '+e.Message);
 end;
end;

procedure TFormCont.EasyListview1DblClick(Sender: TCustomEasyListview;
    Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState);
begin
 ListView1DblClick(Sender);
end;

procedure TFormCont.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 if Item<>nil then
 ListView1SelectItem(Sender,Item,Item.Selected);
end;

procedure TFormCont.ListView1Resize(Sender: TObject);
begin
 Listview1.BackGround.OffsetX:=ListView1.Width-Listview1.BackGround.Image.Width;
 Listview1.BackGround.OffsetY:=ListView1.Height-Listview1.BackGround.Image.Height;
end;

function TFormCont.GetPictureSize: integer;
begin
 Result:=fPictureSize;
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
 rv :=  Listview1.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  r:=Rect(ListView1.ClientRect.Left+rv.Left,ListView1.ClientRect.Top+rv.Top,ListView1.ClientRect.Right+rv.Left,ListView1.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView1.Items[i].DisplayRect) then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:=Data[i].FileName;
  end;
 end;
end;

procedure TFormCont.AddThread;
begin
 Inc(fThreadCount);
end;

procedure TFormCont.BigSizeCallBack(Sender: TObject; SizeX,
  SizeY: integer);
var
  SelectedVisible : boolean;
begin
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 FPictureSize:=SizeX;
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;

 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);

 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

{ TmanagePanels }

procedure TmanagePanels.AddPanel(Panel: TFormCont);
var
  i : integer;
  b : boolean;
begin
  if FPanels.IndexOf(Panel) > -1 then
    Exit;

  FPanels.Add(Panel);
end;

function TManagePanels.Count: integer;
begin
 Result := FPanels.Count;
end;

constructor TmanagePanels.Create;
begin
  FPanels := TList.Create;
end;

destructor TmanagePanels.Destroy;
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

procedure TManagePanels.FreePanel(Panel: TFormCont);
begin
//
end;

function TManagePanels.GetPanelsTexts: TStrings;
var
  i : integer;
  b : Boolean;
  S : string;
begin   
 Result:=TStringList.Create;

 for i := 0 to FPanels.Count - 1 do
   Result.Add(Self[i].Caption);
   
 Repeat
 b:=False;
  For i:=0 to Result.Count-2 do
  If Comparestr(Result[i],Result[i+1])>0 then
  begin
   S:=Result[i];
   Result[i]:=Result[i+1];
   Result[i+1]:=S;
   b:=True;
  end;
 Until not b;
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
  MenuInfo : TDBPopupMenuInfo;
  info : TRecordsInfo;   
  p,p1 : TPoint;
  Item : TEasyItem;
begin

  GetCursorPos(p1);
  p:=ListView1.ScreenToClient(p1);
  Item:=ItemByPointStar(Listview1,p);
  if Item<>nil then
  begin
   if ItemAtPos(p.x,p.y).Tag<>0 then
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
  end;

 Application.HideHint;
 if ImHint<>nil then
 if not UnitImHint.closed then
 ImHint.close;
 HintTimer.Enabled:=false;
 if ListView1Selected<>nil then
 begin
  MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
  If Viewer=nil then
  Application.CreateForm(TViewer,Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.execute(Sender,info);
 end;
end;

procedure TFormCont.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then
 ListView1DblClick(Sender);
end;

procedure TFormCont.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  i : integer;
  b : Boolean;
begin
 if Msg.hwnd=ListView1.Handle then
 begin

  
  //middle mouse button
  if Msg.message=519 then
  begin
   Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
   BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
   Msg.message:=0;
  end;

  if Msg.message=WM_MOUSEWHEEL then
  begin
   if Msg.wParam>0 then i:=1 else i:=-1;
   if CtrlKeyDown then
   begin
    ListView1MouseWheel(ListView1,[ssCtrl],i,Point(0,0),b);
    Msg.message:=0;
   end;
  end;
  if Msg.message=516 then
  begin
   WindowsMenuTickCount:=gettickCount;
  end;
  if Msg.message=256 then
  begin
   WindowsMenuTickCount:=GetTickCount;

   //109-
   if (Msg.wParam=109) then ZoomIn;
   //107+
   if (Msg.wParam=107) then ZoomOut;
   //93-context menu button
   if (Msg.wParam=93) then
   begin
    ListView1ContextPopup(ListView1,Point(-1,-1),b);
   end;

   if (Msg.wParam=46) then DeleteIndexItemFromPopUpMenu(nil);
   if (Msg.wParam=65) and CtrlKeyDown then SelectAll1Click(Nil);
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
 LoadFilesToPanel.Create(false,param,ids,b,false,false,self);
end;

procedure TFormCont.WebLink1Click(Sender: TObject);
var
  i : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(Data[i].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=Data[i].ID;
 end; 
 ResizeImages(ImageList,IDList);
end;

procedure TFormCont.WebLink2Click(Sender: TObject);
var
  i : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
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
 for i:=0 to ListView1.Items.Count-1 do
 If ListView1.Items[i].Selected then
 begin
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(Data[i].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=Data[i].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=Data[i].Rotation;
 end;
 ExportImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATED_90);
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
  for i:=0 to ListView1.Items.Count-1 do
  If ListView1.Items[i].Selected then
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
 SlideShow1.Visible:=ListView1.Items.Count<>0;
 SelectAll1.Visible:=ListView1.Items.Count<>0;
 Copy1.Visible:=ListView1.Items.Count<>0;
 SaveToFile1.Visible:=ListView1.Items.Count<>0;
 Clear1.Visible:=ListView1.Items.Count<>0;
end;

procedure TFormCont.Rename1Click(Sender: TObject);
var
  s : string;
begin
 s:=Caption;
 if PromtString(TEXT_MES_ENTER_TEXT,TEXT_MES_ENTER_CAPTION_OF_PANEL,s) then
 Caption:=s;
end;

Function TFormCont.SelCount : integer;
begin
 Result:= ListView1.Selection.Count;
end;

Function TFormCont.ListView1Selected : TEasyItem;
begin
  Result:= ListView1.Selection.First;
end;

function TFormCont.ItemAtPos(X,Y : integer): TEasyItem;
var
  r : TRect;
begin
 r :=  Listview1.Scrollbars.ViewableViewportRect;
 Result:=Listview1.Groups[0].ItemByPoint(Point(r.left+x,r.top+y));
end;

procedure TFormCont.ListView1MouseUp(Sender: TObject; Button: TMouseButton;
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
     for i:=0 to Listview1.Items.Count-1 do
     if Listview1.Items[i].Selected then
     if item<>Listview1.Items[i] then
     Listview1.Items[i].Selected:=false;
    end;                    
    if not (ebcsDragSelecting in Listview1.States) then 
    if ([ssCtrl]*Shift<>[]) and not ItemSelectedByMouseDown and (Button=mbLeft) then
    item.Selected:=false;
   end;

 if MouseDowned then
 if Button=mbRight then
 begin
  ListView1ContextPopup(ListView1,Point(X,Y),Handled);
  PopupHandled:=true;
 end;

 MouseDowned:=false;
end;

procedure TFormCont.UpdateTheme(Sender: TObject);
var
  b : TBitmap;
begin

  if ListView1<>nil then
  begin
   if ListView1.BackGround.Image<>nil then
   ListView1.BackGround.Image:=nil;
   b:=TBitmap.create;
   b.PixelFormat:=pf24bit;
   b.Width:=150;
   b.Height:=150;
   b.Canvas.Brush.Color:=ListView1.Color;
   b.Canvas.Pen.Color:=ListView1.Color;
   b.Canvas.Rectangle(0,0,150,150);
   b.Canvas.Draw(0,0,ImageBackGround.Picture.Graphic);
   ListView1.BackGround.Image:=b;
   b.Free;
  end;
  ListView1.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
  ListView1.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);
end;

procedure TFormCont.Listview1IncrementalSearch(Item: TEasyCollectionItem;
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

procedure TFormCont.LoadToolBarIcons;
var
  Ico : TIcon;

  procedure AddIcon(Name : String);
  begin
   Ico:=TIcon.Create;
   Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   ToolBarImageList.AddIcon(Ico);
  end;

  procedure AddDisabledIcon(Name : String);
  begin
   Ico:=TIcon.Create;
   Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
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

 ToolButton1.Enabled:=false;
 ToolButton2.Enabled:=false;
 ToolButton3.Enabled:=false;
 ToolButton4.Enabled:=false; 
 ToolButton10.Enabled:=false;

 ToolButton1.ImageIndex:=0;
 ToolButton2.ImageIndex:=1;
 ToolButton3.ImageIndex:=2;
 ToolButton4.ImageIndex:=3;
 ToolButton5.ImageIndex:=4;    
 ToolButton8.ImageIndex:=5;
 ToolButton9.ImageIndex:=6;
 ToolButton10.ImageIndex:=7;

 ToolBar1.Images := ToolBarImageList;
 ToolBar1.DisabledImages := ToolBarDisabledImageList;
end;

procedure TFormCont.ToolButton8Click(Sender: TObject);
begin    
 ZoomIn;
end;

procedure TFormCont.ToolButton9Click(Sender: TObject);
begin   
 ZoomOut;
end;

procedure TFormCont.ZoomIn;
var
  SelectedVisible : boolean;
begin
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize>40 then FPictureSize:=FPictureSize-10;
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);

 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TFormCont.ZoomOut;
var
  SelectedVisible : boolean;
begin                 
 ListView1.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 if FPictureSize<550 then FPictureSize:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Width:=FPictureSize+10;
 ListView1.CellSizes.Thumbnail.Height:=FPictureSize+36;  
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;   
 ListView1.Scrollbars.ReCalculateScrollbars(false,true);
 ListView1.Groups.ReIndexItems;
 ListView1.Groups.Rebuild(true);
 if SelectedVisible then
 ListView1.Selection.First.MakeVisible(emvTop);
 ListView1.EndUpdate();
end;

procedure TFormCont.ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
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

procedure TFormCont.BigImagesTimerTimer(Sender: TObject);
begin
 BigImagesTimer.Enabled:=false;
 BigImagesSID:=GetGUID;
                 
 ToolButton10.Enabled:=true;

 //тут начинается загрузка больших картинок
 TPanelLoadingBigImagesThread.Create(false,self,BigImagesSID,nil,fPictureSize,Copy(Data));
end;

function TFormCont.FileNameExistsInList(FileName : string) : boolean;
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 Result:=false;
 for i:=0 to Length(Data)-1 do
 begin
  if AnsiLowerCase(Data[i].FileName)=FileName then
  begin
   Result:=true;
   break;
  end;
 end;
end;

procedure TFormCont.ReplaseBitmapWithPath(FileName : string; Bitmap : TBitmap);
var
  i : integer;
begin
 FileName:=AnsiLowerCase(FileName);
 for i:=0 to Length(Data)-1 do
 begin
  if AnsiLowerCase(Data[i].FileName)=FileName then
  begin
   FBitmapImageList[i].Bitmap.Assign(Bitmap);
   ListView1.Refresh;
   break;
  end;
 end;
end;

procedure TFormCont.ToolButton10Click(Sender: TObject);
begin
 SID:=Dolphin_DB.GetGUID;
 BigImagesSID:=Dolphin_DB.GetGUID;
 ToolButton10.Enabled:=false;
 //todo: break
end;

procedure TFormCont.DoStopLoading(CID: TGUID);
begin
 if IsEqualGUID(CID, SID) or IsEqualGUID(CID, BigImagesSID) then
 begin
  if IsEqualGUID(CID, SID) then
    Dec(fThreadCount);
  if fThreadCount=0 then
    ToolButton10.Enabled:=false;
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
 rv :=  Listview1.Scrollbars.ViewableViewportRect;
 for i:=0 to ListView1.Items.Count-1 do
 begin
  r:=Rect(ListView1.ClientRect.Left+rv.Left,ListView1.ClientRect.Top+rv.Top,ListView1.ClientRect.Right+rv.Left,ListView1.ClientRect.Bottom+rv.Top);
  if RectInRect(r,ListView1.Items[i].DisplayRect) then
  begin
   if ListView1.Items[i].Selected then
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
 if UseFreeAfterRelease then Free;
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
