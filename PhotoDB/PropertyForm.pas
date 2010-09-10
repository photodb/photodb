unit PropertyForm;

interface

uses
  Windows, ExplorerTypes, UnitGroupsWork, UnitUpdateDB, dolphin_db, UnitDBKernel,
  Forms, DBCMenu, Menus, DB, StdCtrls, Controls, Graphics, Classes,
  ExtCtrls, ActiveX, ShellAPI, Messages, SysUtils, Variants, UnitPasswordForm,
  Dialogs, JPEG, Rating, ComCtrls, AppEvnts, Effects, ImgList, DropTarget,
  DropSource, SaveWindowPos, Grids, ValEdit, TabNotBk, GraphicCrypt, DateUtils,
  Exif, ProgressActionUnit, DmGradient, Clipbrd, WebLink, UnitLinksSupport,
  UnitSQLOptimizing, Math, CommonDBSupport, UnitUpdateDBObject, RAWImage,
  DragDropFile, DragDrop, UnitPropertyLoadImageThread, UnitINI, uLogger,
  UnitPropertyLoadGistogrammThread, uVistaFuncs, UnitDBDeclare, UnitDBCommonGraphics,
  UnitCDMappingSupport, uDBDrawing, uFileUtils, DBLoading, UnitDBCommon;

type
 TShowInfoType=(SHOW_INFO_FILE_NAME, SHOW_INFO_ID, SHOW_INFO_IDS);

type
  TPropertiesForm = class(TForm)
    Image1: TImage;
    CommentMemo: TMemo;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Shell1: TMenuItem;
    Show1: TMenuItem;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Searchforit1: TMenuItem;
    DBItem1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    PopupMenu2: TPopupMenu;
    Datenotexists1: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu4: TPopupMenu;
    SetValue1: TMenuItem;
    PopupMenu5: TPopupMenu;
    Ratingnotsets1: TMenuItem;
    PopupMenu6: TPopupMenu;
    SetComent1: TMenuItem;
    Comentnotsets1: TMenuItem;
    N2: TMenuItem;
    Copy2: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N3: TMenuItem;
    Undo1: TMenuItem;
    N4: TMenuItem;
    SelectAll1: TMenuItem;
    DateExists1: TMenuItem;
    Datenotsets1: TMenuItem;
    Image2: TImage;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    TabbedNotebook1: TTabbedNotebook;
    BtDone: TButton;
    BtSave: TButton;
    Button2: TButton;
    CopyEXIFPopupMenu: TPopupMenu;
    CopyCurrent1: TMenuItem;
    CopyAll1: TMenuItem;
    ImageList1: TImageList;
    PopupMenu7: TPopupMenu;
    PopupMenu8: TPopupMenu;
    Open1: TMenuItem;
    OpenFolder1: TMenuItem;
    Change1: TMenuItem;
    Delete1: TMenuItem;
    Addnewlink1: TMenuItem;
    IDMenu1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    RegGroupsImageList: TImageList;
    PopupMenu9: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    CreateGroup1: TMenuItem;
    ChangeGroup1: TMenuItem;
    GroupManeger1: TMenuItem;
    SearchForGroup1: TMenuItem;
    QuickInfo1: TMenuItem;
    PopupMenu10: TPopupMenu;
    Clear1: TMenuItem;
    MoveToGroup1: TMenuItem;
    PopupMenu11: TPopupMenu;
    Timenotsets1: TMenuItem;
    TimeExists1: TMenuItem;
    TimenotExists1: TMenuItem;
    DestroyTimer: TTimer;
    DropFileTarget2: TDropFileTarget;
    PopupMenu3: TPopupMenu;
    AddImThLink1: TMenuItem;
    N7: TMenuItem;
    Cancel1: TMenuItem;
    AddImThProcessingImageAndAddOriginalToProcessingPhoto1: TMenuItem;
    N8: TMenuItem;
    AddOriginalImTh1: TMenuItem;
    AddOriginalImThAndAddProcessngToOriginalImTh1: TMenuItem;
    ImageLoadingFile: TDBLoading;
    CollectionLabel: TLabel;
    CollectionMemo: TMemo;
    DateEdit: TDateTimePicker;
    DateLabel1: TLabel;
    DateSets: TPanel;
    Heightlabel: TLabel;
    heightmemo: TMemo;
    IDLabel: TMemo;
    IDLabel1: TLabel;
    IsDatePanel: TPanel;
    IsTimePanel: TPanel;
    KeyWordsMemo: TMemo;
    Label1: TLabel;
    Label4: TLabel;
    LabelName: TMemo;
    LabelName1: TLabel;
    LabelPath: TMemo;
    OwnerLabel: TLabel;
    OwnerMemo: TMemo;
    Rating1: TRating;
    RatingLabel1: TLabel;
    SizeLabel: TMemo;
    SizeLabel1: TLabel;
    TimeEdit: TDateTimePicker;
    TimeLabel: TLabel;
    TimeSets: TPanel;
    WidthLabel: TLabel;
    widthmemo: TMemo;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Image3: TImage;
    label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ValueListEditor1: TValueListEditor;
    DmGradient1: TDmGradient;
    GistogrammImage: TImage;
    Label2: TLabel;
    Label5: TLabel;
    RgGistogrammChannel: TRadioGroup;
    CheckBox1: TCheckBox;
    Label6: TLabel;
    LinksScrollBox: TScrollBox;
    procedure Execute(ID : integer);
    procedure BtDoneClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CommentMemoChange(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Searchforit1Click(Sender: TObject);
    procedure ExecuteFileNoEx(FileName : string);
    procedure BeginAdding(Sender: TObject);
    procedure EndAdding(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);

    procedure ChangedDBDataGroups(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);

    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpdateTheme(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Datenotexists1Click(Sender: TObject);
    procedure IsDatePanelDblClick(Sender: TObject);
    procedure ReloadGroups;
    procedure ComboBox1_KeyPress(Sender: TObject; var Key: Char);
    procedure ExecuteEx(IDs : TArInteger);
    procedure FormShow(Sender: TObject);
    procedure GroupsManager1Click(Sender: TObject);
    procedure Rating1MouseDown(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetValue1Click(Sender: TObject);
    procedure Ratingnotsets1Click(Sender: TObject);
    procedure PopupMenu5Popup(Sender: TObject);
    procedure CommentMemoDblClick(Sender: TObject);
    procedure PopupMenu6Popup(Sender: TObject);
    procedure Comentnotsets1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure DateExists1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Datenotsets1Click(Sender: TObject);
    procedure PopupMenu4Popup(Sender: TObject);
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure ReadExifData;
    procedure RgGistogrammChannelClick(Sender: TObject);
    procedure ResetBold;
    procedure ValueListEditor1ContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure CopyCurrent1Click(Sender: TObject);
    procedure CopyAll1Click(Sender: TObject);
    procedure ReadLinks;
    procedure Addnewlink1Click(Sender: TObject);
    procedure LinkOnPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure LinkClick(Sender: TObject);
    procedure PopupMenu7Popup(Sender: TObject);
    procedure Change1Click(Sender: TObject);
    procedure SetLinkInfo(Sender : TObject; ID : String; Info : TLinkInfo; N : integer; Action : Integer);
    procedure CloseEditLinkForm(Form : TForm; ID : String);
    procedure PopupMenu8Popup(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure OpenFolder1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    Procedure RecreateGroupsList;
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Clear1Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure ListBox2DblClick(Sender: TObject);
    function aGetGroupByCode(GroupCode : String) : integer;
    procedure CreateGroup1Click(Sender: TObject);
    procedure ChangeGroup1Click(Sender: TObject);
    procedure GroupManeger1Click(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure QuickInfo1Click(Sender: TObject);
    procedure PopupMenu9Popup(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure MoveToGroup1Click(Sender: TObject);
    procedure PanelValueIsTimeSetsDblClick(Sender: TObject);
    procedure PopupMenu11Popup(Sender: TObject);
    procedure DateEditChange(Sender: TObject);
    procedure TimeEditChange(Sender: TObject);
    procedure TimenotExists1Click(Sender: TObject);
    procedure TimeExists1Click(Sender: TObject);
    procedure Timenotsets1Click(Sender: TObject);
    procedure IsTimePanelDblClick(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure DateSetsDblClick(Sender: TObject);
    procedure TimeSetsDblClick(Sender: TObject);
    procedure LockImput;
    procedure UnLockImput;
    procedure PopupMenu10Popup(Sender: TObject);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure AddImThLink1Click(Sender: TObject);
    procedure AddOriginalImTh1Click(Sender: TObject);
    procedure AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(
      Sender: TObject);
    procedure AddOriginalImThAndAddProcessngToOriginalImTh1Click(
      Sender: TObject);
    procedure PopupMenu3Popup(Sender: TObject);
  private
    LinkDropFiles : TStrings;
    EditLinkForm : TForm;
    Links : array of TWebLink;
    FReadingInfo : Boolean;
    fSaving : boolean;
    WorkQuery : TDataSet;
    FOldGroups, FNowGroups : TGroups;
    FShowenRegGroups : TGroups;
    FPropertyLinks, ItemLinks : TLinksInfo;
    FFilesInfo : TDBPopupMenuInfo;
    FMenuRecord : TDBPopupMenuInfoRecord;
    SelectedInfo : TSelectedInfo;
    RegGroups : TGroups;
    adding_now, editing_info, no_file : Boolean;
    FDateTimeInFileExists : Boolean;
    FFileDate, FFileTime : TDateTime;
    DestroyCounter : integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMActivate(var message: TWMActivate); message WM_ACTIVATE;
    procedure WMSyscommand(var message: TWmSysCommand); message WM_SYSCOMMAND;
    { Private declarations }
  public
    SID: TGUID;
    FShowInfoType: TShowInfoType;
    CurrentItemInfo: TOneRecordInfo;
    FCurrentPass: string;
    GistogrammData: TGistogrammData;
    procedure LoadLanguage;
    function ReadCHInclude: Boolean;
    function ReadCHLinks: Boolean;
    function ReadCHDate: Boolean;
    function ReadCHTime: Boolean;
    procedure OnDoneLoadingImage(Sender: TObject);
    procedure OnDoneLoadGistogrammData(Sender: TObject);
    { Public declarations }
  end;

  TPropertyManager = class(TObject)
  private
    FPropertys : TList;
  public
    constructor Create;
    destructor Destroy; override;
    function NewSimpleProperty : TPropertiesForm;
    function NewIDProperty(ID : Integer) : TPropertiesForm;
    function NewFileProperty(FileName : string) : TPropertiesForm;

    procedure AddProperty(aProperty : TPropertiesForm);
    procedure RemoveProperty(aProperty : TPropertiesForm);
    function IsPropertyForm(aProperty: TForm): Boolean;
    function PropertyCount : Integer;
    function GetAnySimpleProperty : TPropertiesForm;
    function GetPropertyByID(ID : integer) : TPropertiesForm;
    function GetPropertyByFileName(FileName : string): TPropertiesForm;
  end;

var
  PropertyManager: TPropertyManager;

implementation

uses Language, UnitQuickGroupInfo, Searching, SlideShow, UnitHintCeator,
     UnitEditGroupsForm, UnitManageGroups, CmpUnit,
     UnitEditLinkForm, UnitHelp, ExplorerUnit, UnitNewGroupForm,
     UnitFormChangeGroup, SelectGroupForm, UnitGroupsTools;

{$R *.dfm}

{ TPropertyManager }

procedure TPropertyManager.AddProperty(aProperty: TPropertiesForm);
begin
  if FPropertys.IndexOf(aProperty) = -1 then
    FPropertys.Add(aProperty);
end;

constructor TPropertyManager.Create;
begin
  FPropertys := TList.Create;
end;

destructor TPropertyManager.Destroy;
begin
  FreeAndNil(FPropertys);
end;

function TPropertyManager.GetAnySimpleProperty: TPropertiesForm;
begin
  if PropertyCount = 0 then
    Result := NewSimpleProperty
  else
    Result := FPropertys[0];
end;

function TPropertyManager.GetPropertyByID(ID : Integer): TPropertiesForm;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if TPropertiesForm(FPropertys[I]).FShowInfoType = SHOW_INFO_ID then
      if TPropertiesForm(FPropertys[I]).CurrentItemInfo.ItemId = ID then
  begin
    Result := FPropertys[i];
    Exit;
  end;
end;

function TPropertyManager.GetPropertyByFileName(FileName : string): TPropertiesForm;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if TPropertiesForm(FPropertys[i]).FShowInfoType = SHOW_INFO_FILE_NAME then
      if AnsiLowerCase(TPropertiesForm(FPropertys[i]).CurrentItemInfo.ItemFileName) = AnsiLowerCase(FileName) then
      begin
        Result := FPropertys[i];
        Exit;
      end;
end;

function TPropertyManager.IsPropertyForm(aProperty: TForm): Boolean;
begin
  Result := FPropertys.IndexOf(aProperty) > -1;
end;

function TPropertyManager.NewFileProperty(FileName: string): TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount > 0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
  begin
    Result := GetPropertyByFileName(FileName);
    if Result <> nil then
      Exit
    else
      Result := NewSimpleProperty;
  end;
end;

function TPropertyManager.NewIDProperty(ID: Integer): TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount>0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
  begin
    Result := GetPropertyByID(ID);
    if Result <> nil then
      Exit
    else
      Result := NewSimpleProperty;
  end;
end;

function TPropertyManager.NewSimpleProperty: TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount > 0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
  begin
    Application.CreateForm(TPropertiesForm, Result);
  end;
end;

function TPropertyManager.PropertyCount: Integer;
begin
  Result := FPropertys.Count;
end;

procedure TPropertyManager.RemoveProperty(aProperty: TPropertiesForm);
begin
  FPropertys.Remove(aProperty);
end;

function TPropertiesForm.ReadCHInclude: Boolean;
begin
  Result := False;
  if FShowInfoType = SHOW_INFO_ID then
    Result := (CurrentItemInfo.ItemInclude <> CheckBox1.Checked);
  if FShowInfoType = SHOW_INFO_IDS then
  begin
    if (SelectedInfo.IsVaruousInclude) then
    begin
      if (CheckBox1.State <> CbGrayed) then
      begin
        Result := True;
        Exit;
      end;
    end
    else
    begin
      if (SelectedInfo.Include) and (CheckBox1.State = CbUnChecked) or (not SelectedInfo.Include) and
        (CheckBox1.State = CbChecked) then
      begin
        Result := True;
        Exit;
      end
    end;
  end;
end;

function TPropertiesForm.ReadCHLinks : Boolean;
begin
 Result:=not CompareLinks(FPropertyLinks,ItemLinks,true);
end;

function TPropertiesForm.ReadCHDate : Boolean;
begin
 Result:=false;
{   if FShowInfoType=SHOW_INFO_FILE_NAME then
 Result:=FDateTimeInFileExists;  }
 if FShowInfoType=SHOW_INFO_ID then
 begin
  Result:=(((CurrentItemInfo.ItemIsDate<>not IsDatePanel.Visible) or (CurrentItemInfo.ItemDate<>DateEdit.DateTime)) and not DateSets.Visible);
 end;
 if FShowInfoType=SHOW_INFO_IDS then
 begin
  Result:= ((CurrentItemInfo.ItemIsDate<>not IsDatePanel.Visible) or(CurrentItemInfo.ItemDate<>DateEdit.DateTime) or (SelectedInfo.IsVariousDates)) and not DateSets.Visible;
 end;
end;

function TPropertiesForm.ReadCHTime : Boolean;
var
  VarTime : Boolean;
begin
 Result:=false;
 if FShowInfoType=SHOW_INFO_ID then
 begin
  VarTime:=Abs(CurrentItemInfo.ItemTime-TimeOf(TimeEdit.Time))>1/(24*60*60*3);
  Result:=(((CurrentItemInfo.ItemIsTime<>not IsTimePanel.Visible) or VarTime) and not TimeSets.Visible);
 end;
 if FShowInfoType=SHOW_INFO_IDS then
 begin
  VarTime:=Abs(CurrentItemInfo.ItemTime-TimeOf(TimeEdit.Time))>1/(24*60*60*3);
  Result:= ((CurrentItemInfo.ItemIsTime<>not IsTimePanel.Visible) or VarTime or (SelectedInfo.IsVariousTimes)) and not TimeSets.Visible;
 end;
end;

procedure TPropertiesForm.Execute(ID: integer);
var
  FBS : TStream;
  fBit, B1, TempBitmap : tbitmap;
  fpic : Tpicture;
  JPEG : TJpegImage;
  fRotate : integer;
  PassWord : String;
  Exists, w, h : integer;
begin
 try
 if fSaving then
 begin
  SetFocus;
  exit;
 end;

 if EditLinkForm<>nil then
 EditLinkForm.Close;
 editing_info:=false;
 FReadingInfo:=true;
 FCurrentPass:='';
 CheckBox1.AllowGrayed:=false;
 ResetBold;
 if CurrentItemInfo.ItemId<>id then
 TabbedNotebook1.PageIndex:=0;
 DateEdit.Enabled:=true;
 TimeEdit.Enabled:=true;
 Image2.Visible:=false;
 FShowInfoType:=SHOW_INFO_ID;
 CurrentItemInfo.ItemId:=id;
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
 DBKernel.UnRegisterChangesIDbyID(Self,ChangedDBDataByID,CurrentItemInfo.ItemId);
 DBKernel.RegisterChangesIDbyID(Self,ChangedDBDataByID,CurrentItemInfo.ItemId);
 DBitem1.Visible:=true;
 BtSave.Caption:=TEXT_MES_SAVE;
 idlabel.text:=inttostr(id);
 CommentMemo.Cursor:=CrDefault;
 CommentMemo.PopupMenu:=nil;
 SetSQL(WorkQuery,'SELECT * FROM $DB$ WHERE ID='+inttostr(ID));
 WorkQuery.Active:=true;
 WorkQuery.First;
 if WorkQuery.RecordCount=0 then no_file:=true;
 If not no_file then BtSave.Enabled:=false;
 CurrentItemInfo.ItemFileName:=ProcessPath(WorkQuery.FieldByName('FFileName').AsString);
 fbit:=TBitmap.create;
 fbit.PixelFormat:=pf24bit;
 b1:=TBitmap.create;
 b1.PixelFormat:=pf24bit;
 b1.Width:=ThImageSize;
 b1.Height:=ThImageSize;
 b1.Canvas.Brush.color:=Theme_MainColor;
 b1.Canvas.pen.color:=Theme_MainColor;
 PassWord:='';
 if TBlobField(WorkQuery.FieldByName('thum'))=nil then
 begin
  fbit.free;
  b1.free;
  FReadingInfo:=false;
  exit;
 end;
 fpic:=TPicture.create;
 fpic.Graphic:=TJPEGImage.Create;
 if ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')) then
 begin
  PassWord:=DBkernel.FindPasswordForCryptBlobStream(WorkQuery.FieldByName('thum'));
  if PassWord='' then
  begin
   PassWord:=GetImagePasswordFromUserBlob(WorkQuery.FieldByName('thum'),WorkQuery.FieldByName('FFileName').AsString);
  end;
  if PassWord='' then
  begin
   fbit.Free;
   b1.Free;
   fPic.Free;
   FReadingInfo:=false;
   exit;
  end else
  begin
   JPEG := TJpegImage.Create;
   DeCryptBlobStreamJPG(WorkQuery.FieldByName('thum'), PassWord, JPEG);
   FPic.Graphic:= JPEG;
  end;
  FCurrentPass:=PassWord;
 end else
  begin
  FBS:=GetBlobStream(WorkQuery.FieldByName('thum'),bmRead);
  try
   if FBS.Size<>0 then
   FPic.Graphic.LoadFromStream(FBS) else
  except
   on e : Exception do EventLog(':TPropertiesForm::Execute()/LoadFromStream throw exception: '+e.Message);
  end;
  FBS.Free;
 end;


 //Resizing if picture too big
 if (FPic.Graphic.Width>ThSizeExplorerPreview) or (FPic.Graphic.Height>ThSizeExplorerPreview) then
 begin
  TempBitmap:=TBitmap.Create;
  TempBitmap.Assign(FPic.Graphic);
  w:=TempBitmap.Width;
  h:=TempBitmap.Height;
  ProportionalSize(ThSizeExplorerPreview,ThSizeExplorerPreview,w,h);
  try
   DoResize(w,h,TempBitmap,fbit);
  except
   on e : Exception do EventLog(':TPropertiesForm::Execute()/DoResize throw exception: '+e.Message);
  end;
  TempBitmap.Free;
 end else
 begin
  fbit.Assign(FPic.Graphic);
 end;

 b1.Width:=ThSizePropertyPreview;
 b1.height:=ThSizePropertyPreview;
 b1.Canvas.Rectangle(0,0,ThSizePropertyPreview,ThSizePropertyPreview);
 b1.Canvas.Draw(ThSizePropertyPreview div 2-fbit.Width div 2,ThSizePropertyPreview div 2 - fbit.Height div 2,fbit);

 frotate:=WorkQuery.FieldByName('Rotated').AsInteger;
 CurrentItemInfo.ItemRotate:=frotate;
 ApplyRotate(B1, frotate);
 Exists:=0;
 DrawAttributes(b1,100,WorkQuery.FieldByName('Rating').asinteger,WorkQuery.FieldByName('Rotated').asinteger,WorkQuery.FieldByName('Access').asinteger,WorkQuery.FieldByName('FFileName').AsString,ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')),Exists,ID);
 if Image1.Picture.Bitmap=nil then
 Image1.Picture.Bitmap:=TBitmap.create;
 Image1.Picture.Bitmap.Assign(b1);
 b1.free;
 fbit.Free;
 fpic.free;
 caption:=TEXT_MES_PROPERTY+' - '+ Trim(WorkQuery.FieldByName('Name').AsString);
 KeyWordsMemo.Text:=WorkQuery.FieldByName('KeyWords').AsString;
 LabelName.Text:=Trim(WorkQuery.FieldByName('Name').AsString);
 LabelPath.Text:=LongFileName(WorkQuery.FieldByName('FFileName').AsString);
 SizeLabel.text:=SizeInTextA(WorkQuery.FieldByName('FileSize').AsInteger);
 widthmemo.text:=IntToStr(WorkQuery.FieldByName('Width').AsInteger)+'px.';
 heightmemo.text:=IntToStr(WorkQuery.FieldByName('Height').AsInteger)+'px.';
 Rating1.Rating:=WorkQuery.FieldByName('Rating').AsInteger;
 Rating1.Islayered:=false;
 DateSets.Visible:=false;
 TimeSets.Visible:=false;
 CurrentItemInfo.ItemImTh:=WorkQuery.FieldByName('StrTh').AsString;
 CurrentItemInfo.ItemRating:=WorkQuery.FieldByName('Rating').AsInteger;
 CurrentItemInfo.ItemKeyWords:=WorkQuery.FieldByName('KeyWords').AsString;
 CurrentItemInfo.ItemComment:=WorkQuery.FieldByName('Comment').AsString;
 CollectionMemo.text:=Trim(WorkQuery.FieldByName('Collection').AsString);
 CurrentItemInfo.ItemCollections:=Trim(WorkQuery.FieldByName('Collection').AsString);
 OwnerMemo.text:=Trim(WorkQuery.FieldByName('Owner').AsString);
 CurrentItemInfo.ItemOwner:=Trim(WorkQuery.FieldByName('Owner').AsString);
 CurrentItemInfo.ItemDate:=WorkQuery.FieldByName('DateToAdd').AsDateTime;
 DateEdit.DateTime:=CurrentItemInfo.ItemDate;
 CurrentItemInfo.ItemIsDate:=WorkQuery.FieldByName('IsDate').AsBoolean;
 CurrentItemInfo.ItemIsTime:=WorkQuery.FieldByName('IsTime').AsBoolean;
 CurrentItemInfo.ItemTime:=WorkQuery.FieldByName('aTime').AsDateTime;
 TimeEdit.Time:=CurrentItemInfo.ItemTime;
 CheckBox1.Checked:=WorkQuery.FieldByName('Include').AsBoolean;
 CurrentItemInfo.ItemInclude:=WorkQuery.FieldByName('Include').AsBoolean;
 IsDatePanel.Visible:=not CurrentItemInfo.ItemIsDate;
 IsTimePanel.Visible:=not CurrentItemInfo.ItemIsTime;
 if length(WorkQuery.FieldByName('Comment').AsString)>5 then
 begin
  CommentMemo.Show;
  Label3.Show;
  CommentMemo.text:=WorkQuery.FieldByName('Comment').AsString
 end else
 begin
  CommentMemo.text:='';
  CommentMemo.Hide;
  Label3.Hide;
 end;
 ItemLinks:=ParseLinksInfo(WorkQuery.FieldByName('Links').AsString);
 FPropertyLinks:=CopyLinksInfo(ItemLinks);

 FNowGroups:=UnitGroupsWork.EncodeGroups(WorkQuery.FieldByName('Groups').AsString);
 FOldGroups:=CopyGroups(FNowGroups);

 DateSets.Visible:=false;
 TimeSets.Visible:=false;
 FFilesInfo:= TDBPopupMenuInfo.Create;
 FMenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
 FFilesInfo.Add(FMenuRecord);
 FFilesInfo.AttrExists:=false;
 CommentMemoChange(nil);
 Button2.Visible:=True;
 ReloadGroups;
 editing_info:=true;
 FReadingInfo:=false;
 if Visible then
 begin
  ListBox1.Refresh;
  ListBox2.Refresh;
 end;
 ImageLoadingFile.Visible:=false;
 Show;

 except
  On E : Exception do MessageBoxDB(Handle,'Error on geting info:'#13+E.Message,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
 SID:=GetGUID;
end;

procedure TPropertiesForm.BtDoneClick(Sender: TObject);
begin
 if EditLinkForm<>nil then
 begin
  EditLinkForm.Close;
  EditLinkForm:=nil;
 end;
 if FSaving then
 begin
  DestroyTimer.Interval:=100;
  DestroyCounter:=1;
  DestroyTimer.Enabled:=true;
  Hide;
  Application.ProcessMessages;
 end else
 Close;
end;

procedure TPropertiesForm.Button2Click(Sender: TObject);
begin
  if no_file then exit;
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(LabelPath.text);
    SetPath(GetDirectory(LabelPath.text));
    Show;
  end;
end;

procedure TPropertiesForm.FormCreate(Sender: TObject);
begin
 WorkQuery:=GetQuery;
 DestroyCounter:=0;
 GistogrammData.Loaded:=false;

 LinkDropFiles:=TStringList.Create;
 PropertyManager.AddProperty(self);
 ListBox1.DoubleBuffered:=true;
 ListBox2.DoubleBuffered:=true;
 FreeGroups(RegGroups);
 FreeGroups(FShowenRegGroups);

 EditLinkForm:=nil;
 SetLength(Links,0);
 FReadingInfo:=false;
 fSaving:=false;
 DropFileTarget1.Register(Self);
 DropFileTarget2.Register(LinksScrollBox);
 no_file:=false;
 editing_info:=true;
 adding_now:=false;
 Image1.Picture.Bitmap:=nil;
 DBKernel.RegisterChangesID(Self,ChangedDBDataGroups);
 DBKernel.RecreateThemeToForm(Self);
 DBkernel.RegisterProcUpdateTheme(UpdateTheme,self);
 DBkernel.RegisterForm(Self);
 TimeEdit.ParentColor:=True;
 PopupMenu1.Images:=DBKernel.ImageList;
 PopupMenu7.Images:=DBKernel.ImageList;
 Shell1.ImageIndex:=DB_IC_SHELL;
 Show1.ImageIndex:=DB_IC_SLIDE_SHOW;
 Copy1.ImageIndex:=DB_IC_COPY_ITEM;
 Searchforit1.ImageIndex:=DB_IC_SEARCH;
 Open1.ImageIndex:=DB_IC_SHELL;
 OpenFolder1.ImageIndex:=DB_IC_EXPLORER;
 IDMenu1.ImageIndex:=DB_IC_NOTES;
 Change1.ImageIndex:=DB_IC_PROPERTIES;
 Delete1.ImageIndex:=DB_IC_DELETE_INFO;
 DBItem1.ImageIndex:=DB_IC_NOTES;

 Up1.ImageIndex:=DB_IC_UP;
 Down1.ImageIndex:=DB_IC_DOWN;
 DBKernel.RegisterForm(Self);
 SaveWindowPos1.Key:=GetRegRootKey+'Properties';
 SaveWindowPos1.SetPosition;
 LoadLanguage;

 CheckBox2.Checked:=DBKernel.ReadBool('Propetry','DeleteKeyWords',True);
 CheckBox3.Checked:=DBKernel.ReadBool('Propetry','ShowAllGroups',false);
 Height:=561;
end;

procedure TPropertiesForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
  I : Integer;
begin
  if (Button = mbLeft) then
  begin
    DragImageList.Clear;
    DragImageList.Masked := False;

    DragImage := TBitmap.Create;
    try
      DragImage.PixelFormat := pf24bit;
      DragImage.Assign(Image1.Picture.Graphic);
      DragImageList.Width := DragImage.Width;
      DragImageList.Height := DragImage.Height;
      RemoveBlackColor(DragImage);
      DragImageList.Add(DragImage, nil);
    finally
      DragImage.Free;
    end;

    DropFileSource1.Files.Clear;
    if FShowInfoType = SHOW_INFO_IDS then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FileExists(ProcessPath(FFilesInfo[I].FileName)) then
         DropFileSource1.Files.Add(ProcessPath(FFilesInfo[I].FileName));
    end else
    begin
      if FileExists(ProcessPath(LabelPath.Text)) then
        DropFileSource1.Files.Add(ProcessPath(LabelPath.Text));
    end;
    if DropFileSource1.Files.Count > 0 then
    begin
      DropFileSource1.ImageIndex := 0;
      DropFileSource1.Execute;
    end;
  end;
end;

procedure TPropertiesForm.CommentMemoChange(Sender: TObject);
var
  CHInclude : boolean;
  CHLinks : boolean;
  CHTime : boolean;
  CHDate : boolean;
begin
 if not editing_info then exit;
 CHLinks:=ReadCHLinks;
 CHTime:=ReadCHTime;
 CHDate:=ReadCHDate;
 CHInclude:=ReadCHInclude;

 if FShowInfoType=SHOW_INFO_ID then
 if CHDate or CHTime or (CurrentItemInfo.ItemOwner<>OwnerMemo.text) or (CurrentItemInfo.ItemCollections<>CollectionMemo.text) or (CurrentItemInfo.ItemRating<>Rating1.Rating) or (CurrentItemInfo.ItemComment<>CommentMemo.text) or VariousKeyWords(CurrentItemInfo.ItemKeyWords,KeyWordsMemo.Text) or not CompareGroups(FOldGroups,FNowGroups)or CHInclude or CHLinks then
 BtSave.Enabled:=True else BtSave.Enabled:=False;

 if FShowInfoType=SHOW_INFO_IDS then
 if CHDate or CHTime or (not Rating1.Islayered) or (not CommentMemo.ReadOnly and SelectedInfo.IsVariousComments) or (not SelectedInfo.IsVariousComments and (CommentMemo.Text<>SelectedInfo.CommonComment)) or VariousKeyWords(CurrentItemInfo.ItemKeyWords,KeyWordsMemo.Text) or not CompareGroups(FOldGroups,FNowGroups) or CHInclude or CHLinks then
 BtSave.Enabled:=True else BtSave.Enabled:=False;
 if FShowInfoType=SHOW_INFO_FILE_NAME then
 BtSave.Enabled:=false;
 if FShowInfoType<>SHOW_INFO_IDS then
 if CurrentItemInfo.ItemComment<>CommentMemo.Text then Label3.Font.Style:=Label3.Font.Style+[fsBold] else Label3.Font.Style:=Label3.Font.Style-[fsBold];
 if FShowInfoType=SHOW_INFO_IDS then
 if (not CommentMemo.ReadOnly and SelectedInfo.IsVariousComments) or (not SelectedInfo.IsVariousComments and (CommentMemo.Text<>SelectedInfo.CommonComment)) then Label3.Font.Style:=Label3.Font.Style+[fsBold] else Label3.Font.Style:=Label3.Font.Style-[fsBold];
 if VariousKeyWords(CurrentItemInfo.ItemKeyWords,KeyWordsMemo.text) then Label1.Font.Style:=Label1.Font.Style+[fsBold] else Label1.Font.Style:=Label1.Font.Style-[fsBold];
 if CurrentItemInfo.ItemRating<>Rating1.Rating then RatingLabel1.Font.Style:=RatingLabel1.Font.Style+[fsBold] else RatingLabel1.Font.Style:=RatingLabel1.Font.Style-[fsBold];
 if (CurrentItemInfo.ItemCollections<>CollectionMemo.text) then CollectionLabel.Font.Style:=CollectionLabel.Font.Style+[fsBold] else CollectionLabel.Font.Style:=CollectionLabel.Font.Style-[fsBold];
 if (CurrentItemInfo.ItemOwner<>OwnerMemo.text) then OwnerLabel.Font.Style:=OwnerLabel.Font.Style+[fsBold] else OwnerLabel.Font.Style:=OwnerLabel.Font.Style-[fsBold];
 if ReadCHDate then DateLabel1.Font.Style:=DateLabel1.Font.Style+[fsBold] else DateLabel1.Font.Style:=DateLabel1.Font.Style-[fsBold];
 if ReadCHTime then TimeLabel.Font.Style:=TimeLabel.Font.Style+[fsBold] else TimeLabel.Font.Style:=TimeLabel.Font.Style-[fsBold];
// if not CompareGroups(CurrentItemInfo.ItemGroups,FPropertyGroups) then GroupsLabel.Font.Style:=GroupsLabel.Font.Style+[fsBold] else GroupsLabel.Font.Style:=GroupsLabel.Font.Style-[fsBold];
 if {(CurrentItemInfo.ItemInclude<>CheckBox1.Checked)}CHInclude then CheckBox1.Font.Style:=CheckBox1.Font.Style+[fsBold] else CheckBox1.Font.Style:=CheckBox1.Font.Style-[fsBold];
 if CHLinks then Label6.Font.Style:=Label6.Font.Style+[fsBold] else Label6.Font.Style:=Label6.Font.Style-[fsBold];
 if CHInclude then CheckBox1.Font.Style:=CheckBox1.Font.Style+[fsBold] else CheckBox1.Font.Style:=CheckBox1.Font.Style-[fsBold];
end;

procedure TPropertiesForm.Image1DblClick(Sender: TObject);
begin
 if no_file then exit;
 if (FShowInfoType=SHOW_INFO_ID) or (FShowInfoType=SHOW_INFO_IDS) then
 begin
  CommentMemo.show;
  Label3.Show;
 end;
end;

procedure TPropertiesForm.BtSaveClick(Sender: TObject);
var
  _sqlexectext, CommonKeyWords, KeyWords, CommonGroups, SGroups, SLinks : string;
  SLinkInfo : TLinksInfo;
  i, j : integer;
  EventInfo : TEventValues;
   xCount : integer;
  ProgressForm : TProgressActionForm;
  List : TSQLList;
  IDs : String;
  FQuery : TDataSet;
  IDArray : TArInteger;
begin
 If not DBkernel.ProgramInDemoMode then
 begin
  if CharToInt(DBkernel.GetCodeChar(14))<>CharToInt(DBkernel.GetCodeChar(7))*CharToInt(DBkernel.GetCodeChar(9)) mod 15 then exit;
 end;


 if FShowInfoType=SHOW_INFO_IDS then
 begin
  xCount:=0;
  LockImput;
  BtSave.Enabled:=false;

  ProgressForm:=nil;
  CommonKeyWords:=CurrentItemInfo.ItemKeyWords;

  If VariousKeyWords(KeywordsMemo.Text,CommonKeyWords) then
  Inc(xCount);
  If not CompareGroups(FNowGroups,FOldGroups) then
  Inc(xCount);

  if not CommentMemo.ReadOnly then
  Inc(xCount);

  if ReadCHLinks then
  Inc(xCount);

  if xCount>0 then
  begin
   ProgressForm:=GetProgressWindow;
   ProgressForm.OperationCount:=xCount;
   ProgressForm.OperationPosition:=0;
   ProgressForm.OneOperation:=false;
   ProgressForm.MaxPosCurrentOperation:=FFilesInfo.Count;
   ProgressForm.xPosition:=0;
   ProgressForm.DoShow;
  end;
  //[BEGIN] Include Support

  if ReadCHInclude then
  begin
   _sqlexectext:='Update $DB$ Set Include = :Include Where ID in (';
   for I := 0 to FFilesInfo.Count - 1 do
     if i=0 then
       _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' '
     else
       _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
   _sqlexectext:=_sqlexectext+')';
   SetSQL(WorkQuery,_sqlexectext);
   SetBoolParam(WorkQuery,0,CheckBox1.Checked);
   ExecSQL(WorkQuery);
   EventInfo.Include:=CheckBox1.Checked;
   for I := 0 to FFilesInfo.Count - 1 do
     DBKernel.DoIDEvent(Sender,FFilesInfo[I].ID,[EventID_Param_Include],EventInfo);
  end;
  //[END] Include Support

  //[BEGIN] Rating Support

  if not Rating1.Islayered then
  begin
   _sqlexectext:='Update $DB$ Set Rating = :Rating Where ID in (';
   for I := 0 to FFilesInfo.Count - 1 do
   if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
   _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
   _sqlexectext:=_sqlexectext+')';
   WorkQuery.active:=false;
   SetSQL(WorkQuery,_sqlexectext);
   SetIntParam(WorkQuery,0,Rating1.Rating);
   ExecSQL(WorkQuery);
   EventInfo.Rating:=Rating1.Rating;
   for I := 0 to FFilesInfo.Count - 1 do
   DBKernel.DoIDEvent(Sender,FFilesInfo[I].ID,[EventID_Param_Rating],EventInfo);
  end;
  //[END] Rating Support

  //[BEGIN] KeyWords Support
  CommonKeyWords:=CurrentItemInfo.ItemKeyWords;

  If VariousKeyWords(KeywordsMemo.Text,CommonKeyWords) then
  begin
   FreeSQLList(List);
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   for I := 0 to FFilesInfo.Count - 1 do
   begin
    KeyWords:=FFilesInfo[I].KeyWords;
    ReplaceWords(CurrentItemInfo.ItemKeyWords, KeywordsMemo.Text, KeyWords);
    if VariousKeyWords(KeyWords,FFilesInfo[I].KeyWords) then
    begin
     AddQuery(List,KeyWords,FFilesInfo[I].ID);
    end;
   end;
   PackSQLList(List,VALUE_TYPE_KEYWORDS);
   ProgressForm.MaxPosCurrentOperation:=Length(List);
   for i:=0 to Length(List)-1 do
   begin
    IDs:='';
    for j:=0 to Length(List[i].IDs)-1 do
    begin
     if j<>0 then IDs:=IDs+' , ';
     IDs:=IDs+' '+IntToStr(List[i].IDs[j])+' ';
    end;
    ProgressForm.xPosition:=ProgressForm.xPosition+1;
    {!!!}   Application.ProcessMessages;
    _sqlexectext:='Update $DB$ Set KeyWords = '+NormalizeDBString(List[i].Value)+' Where ID in ('+IDs+')';
    WorkQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
    ExecSQL(WorkQuery);
    EventInfo.KeyWords:=List[i].Value;
    for j:=0 to Length(List[i].IDs)-1 do
    DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_KeyWords],EventInfo);
   end;
  end;
  //[END] KeyWords Support

  //[BEGIN] Groups Support

  CommonGroups:=CodeGroups(FOldGroups);
  If not CompareGroups(FNowGroups, FOldGroups) then
  begin
   FreeSQLList(List);
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   For I := 0 to FFilesInfo.Count - 1 do
   begin
    SGroups:=FFilesInfo[I].Groups;
    ReplaceGroups(CommonGroups,CodeGroups(FNowGroups),SGroups);
    if not CompareGroups(SGroups,FFilesInfo[I].Groups) then
    begin
     AddQuery(List,SGroups,FFilesInfo[I].ID);
    end;
   end;

   PackSQLList(List,VALUE_TYPE_GROUPS);
   ProgressForm.MaxPosCurrentOperation:=Length(List);
   for i:=0 to Length(List)-1 do
   begin
    IDs:='';
    for j:=0 to Length(List[i].IDs)-1 do
    begin
     if j<>0 then IDs:=IDs+' , ';
     IDs:=IDs+' '+IntToStr(List[i].IDs[j])+' ';
    end;
    ProgressForm.xPosition:=ProgressForm.xPosition+1;
    {!!!}   Application.ProcessMessages;
    _sqlexectext:='Update $DB$ Set Groups = '+normalizeDBString(List[i].Value)+' Where ID in ('+IDs+')';
    WorkQuery.Close;
    SetSQL(WorkQuery,_sqlexectext);
    ExecSQL(WorkQuery);
    EventInfo.Groups:=List[i].Value;
    for j:=0 to Length(List[i].IDs)-1 do
    DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_Groups],EventInfo);
   end;
  end;
  //[END] Groups Support

  //[BEGIN] Links Support
  if ReadCHLinks then
  begin
   FreeSQLList(List);
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   For I := 0 to FFilesInfo.Count - 1 do
   begin
    SLinks:=FFilesInfo[I].Links;
    SLinkInfo:=ParseLinksInfo(SLinks);
    ReplaceLinks(ItemLinks,FPropertyLinks,SLinkInfo);
    SLinks:=CodeLinksInfo(SLinkInfo);
    if not CompareLinks(SLinks,FFilesInfo[I].Links) then
    begin
     AddQuery(List,SLinks,FFilesInfo[I].ID);
    end;
   end;
   PackSQLList(List,VALUE_TYPE_LINKS);
   ProgressForm.MaxPosCurrentOperation:=Length(List);
   for i:=0 to Length(List)-1 do
   begin
    IDs:='';
    for j:=0 to Length(List[i].IDs)-1 do
    begin
     if j<>0 then IDs:=IDs+' , ';
     IDs:=IDs+' '+IntToStr(List[i].IDs[j])+' ';
    end;
    ProgressForm.xPosition:=ProgressForm.xPosition+1;
    {!!!}   Application.ProcessMessages;
    _sqlexectext:='Update $DB$ Set Links = '+normalizeDBString(List[i].Value)+' Where ID in ('+IDs+')';
    SetSQL(WorkQuery,_sqlexectext);
    ExecSQL(WorkQuery);
   end;
  end;
  //[END] Links Support

  //[BEGIN] Commnet Support

  if not CommentMemo.ReadOnly then
  if CommentMemo.Text<>SelectedInfo.Comment then
  begin
   ProgressForm.OperationPosition:=ProgressForm.OperationPosition+1;
   ProgressForm.xPosition:=0;
   _sqlexectext:='Update $DB$ Set Comment = '+normalizeDBString(CommentMemo.Text)+' Where ID in (';
   for I := 0 to FFilesInfo.Count - 1 do
   if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
   _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
   _sqlexectext:=_sqlexectext+')';
   SetSQL(WorkQuery,_sqlexectext);
   ExecSQL(WorkQuery);
   EventInfo.Comment:=CommentMemo.Text;
   for I := 0 to FFilesInfo.Count - 1 do
   begin
    ProgressForm.xPosition:=ProgressForm.xPosition+1;
    {!!!} Application.ProcessMessages;
    DBKernel.DoIDEvent(Sender,FFilesInfo[I].ID,[EventID_Param_Comment],EventInfo);
   end;
  end;
  //[END] Commnet Support

  //[BEGIN] Date Support

  If not DateSets.Visible then
  begin
   FQuery := GetQuery;
   if IsDatePanel.Visible then
   begin
    _sqlexectext:='Update $DB$ Set IsDate = :IsDate Where ';
    for I := 0 to FFilesInfo.Count - 1 do
    if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
    _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
    SetBoolParam(FQuery,0,false);
    ExecSQL(FQuery);
    EventInfo.IsDate:=False;
    for I := 0 to FFilesInfo.Count - 1 do
    DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_IsDate], EventInfo);
   end else
   begin
    _sqlexectext:='Update $DB$ Set DateToAdd=:DateToAdd, IsDate=TRUE Where ID in (';
    for I := 0 to FFilesInfo.Count - 1 do
    if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
    _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
    _sqlexectext:=_sqlexectext+')';
    FQuery.Active:=false;
    SetSQL(FQuery,_sqlexectext);
    SetDateParam(FQuery,'DateToAdd',DateEdit.DateTime);
    ExecSQL(FQuery);
    EventInfo.Date:=DateEdit.DateTime;
    EventInfo.IsDate:=True;
    for I := 0 to FFilesInfo.Count - 1 do
    DBKernel.DoIDEvent(Sender,FFilesInfo[I].ID,[EventID_Param_Date,EventID_Param_IsDate],EventInfo);
   end;
   FreeDS(FQuery);
  end;
  //[END] Date Support

  //[BEGIN] Time Support

  If not TimeSets.Visible then
  begin
   if IsTimePanel.Visible then
   begin
    _sqlexectext:='Update $DB$ Set IsTime = :IsTime Where ID in (';
    for I := 0 to FFilesInfo.Count - 1 do
    if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
    _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
    _sqlexectext:=_sqlexectext+')';
    WorkQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
    SetBoolParam(WorkQuery,0,false);
    ExecSQL(FQuery);
    EventInfo.IsTime:=False;
    for I := 0 to FFilesInfo.Count - 1 do
    DBKernel.DoIDEvent(Sender,FFilesInfo[I].ID,[EventID_Param_IsTime],EventInfo);
   end else
   begin
    _sqlexectext:='Update $DB$ Set aTime = :aTime, IsTime = True Where ID in (';
    for I := 0 to FFilesInfo.Count - 1 do
    if i=0 then _sqlexectext:=_sqlexectext+' '+inttostr(FFilesInfo[I].ID)+' ' else
    _sqlexectext:=_sqlexectext+' , '+inttostr(FFilesInfo[I].ID)+'';
    _sqlexectext:=_sqlexectext+')';
    WorkQuery.active:=false;
    SetSQL(WorkQuery,_sqlexectext);
    SetDateParam(WorkQuery,'aTime',TimeOf(TimeEdit.Time));
    ExecSQL(FQuery);
    EventInfo.Time:=TimeEdit.Time;
    EventInfo.IsTime:=True;
    for I := 0 to FFilesInfo.Count - 1 do
    DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID,[EventID_Param_Time,EventID_Param_IsTime],EventInfo);
   end;
  end;
  //[END] Time Support

  if ProgressForm<>nil then
  begin
   ProgressForm.Release;
  end;

  UnLockImput;
  BtSave.Enabled:=true;
  if Visible then
  begin
    SetLength(IDArray, FFilesInfo.Count);
    for I := 0 to FFilesInfo.Count - 1 do
      IDArray[I] := FFilesInfo[I].ID;

    ExecuteEx(IDArray);
  end;
  Exit;
 end;

 if FShowInfoType=SHOW_INFO_ID then
 begin
  _sqlexectext:='Update $DB$';
  _sqlexectext:=_sqlexectext+' set Comment='+normalizeDBString(CommentMemo.text)+' , KeyWords='+normalizeDBString(KeyWordsMemo.text)+' , Rating = ' + inttostr(Rating1.Rating)+' , Owner = '+normalizeDBString(OwnerMemo.text)+' , Collection = '+normalizeDBString(CollectionMemo.text)+', DateToAdd = :Date, IsDate = :IsDate, Groups = '+NormalizeDBString(CodeGroups(FNowGroups))+', Include = :Include, Links = '+NormalizeDBString(CodeLinksInfo(FPropertyLinks))+', aTime = :aTime , IsTime = :IsTime';
  _sqlexectext:=_sqlexectext+ ' Where ID=:ID';
  WorkQuery.active:=false;
  SetSQL(WorkQuery,_sqlexectext);
  SetDateParam(WorkQuery,'Date',DateEdit.DateTime);
  SetIntParam(WorkQuery,5,CurrentItemInfo.ItemId);  //Must be LAST PARAM!
  SetBoolParam(WorkQuery,1,not IsDatePanel.Visible);
  SetBoolParam(WorkQuery,2,CheckBox1.Checked);
  SetDateParam(WorkQuery,'aTime',TimeOf(TimeEdit.Time));
  SetBoolParam(WorkQuery,4,not IsTimePanel.Visible);


  ExecSQL(WorkQuery);
  EventInfo.Comment:=CommentMemo.text;
  EventInfo.KeyWords:=KeyWordsMemo.text;
  EventInfo.Rating:=Rating1.Rating;
  EventInfo.Owner:=OwnerMemo.text;
  EventInfo.Collection:=CollectionMemo.text;
  EventInfo.Groups:=CodeGroups(FNowGroups);
  EventInfo.Include:=CheckBox1.Checked;
  EventInfo.Date:=DateEdit.DateTime;
  EventInfo.Time:=TimeOf(TimeEdit.Time);
  EventInfo.IsDate:=not IsDatePanel.Visible;
  EventInfo.IsTime:=not IsTimePanel.Visible;
  DBKernel.DoIDEvent(Sender,CurrentItemInfo.ItemId,[EventID_Param_Comment,EventID_Param_KeyWords,EventID_Param_Rating,EventID_Param_Owner,EventID_Param_Collection,EventID_Param_Date,EventID_Param_Time,EventID_Param_IsDate,EventID_Param_IsTime,EventID_Param_Groups,EventID_Param_Include],EventInfo);
 end else
 begin
  If UpdaterDB=nil then
  UpdaterDB:=TUpdaterDB.Create;
  UpdaterDB.AddFile(CurrentItemInfo.ItemFileName);
 end;
end;

procedure TPropertiesForm.Copy1Click(Sender: TObject);
var
  I : Integer;
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    if FShowInfoType <> SHOW_INFO_IDS then
      FileList.Add(LabelPath.Text)
    else
    begin
    for i:=0 to FFilesInfo.Count - 1 do
     if FileExists(FFilesInfo[I].FileName) then
       FileList.Add(FFilesInfo[I].FileName);

    end;
    Copy_Move(True, FileList);
  finally
    FileList.Free;
  end;
end;

procedure TPropertiesForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PWideChar(LabelPath.Text), nil, nil, SW_NORMAL);
end;

procedure TPropertiesForm.Show1Click(Sender: TObject);
var
  Info : TRecordsInfo;
begin
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 if FShowInfoType=SHOW_INFO_IDS then DBPopupMenuInfoToRecordsInfo(FFilesInfo,Info) else Info:=GetRecordsFromOne(CurrentItemInfo);
 Viewer.Execute(Sender,Info);
end;

procedure TPropertiesForm.Searchforit1Click(Sender: TObject);
var
  PR : TImageDBRecordA;
  NewSearch : TSearchForm;
begin
 if FShowInfoType=SHOW_INFO_ID then
 begin
  if FileExists(CurrentItemInfo.ItemFileName) then
  begin
   NewSearch:=SearchManager.NewSearch;
   NewSearch.Show;
   NewSearch.SearchEdit.Text:=inttostr(CurrentItemInfo.ItemId)+'$';
   NewSearch.DoSearchNow(nil);
  end else
  begin
   pr:=GetImageIDW(CurrentItemInfo.ItemFileName,true);
   if pr.Count<>0 then
   begin
    Execute(pr.ids[0]);
   end else
   begin
    MessageBoxDB(Handle,TEXT_MES_UNABLE_FIND_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
  end;
 end else begin
  pr:=GetImageIDW(CurrentItemInfo.ItemFileName,true);
  if pr.Count<>0 then
  begin
   Execute(pr.ids[0]);
  end else
  begin
   MessageBoxDB(Handle, TEXT_MES_UNABLE_FIND_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
 end;
end;

procedure TPropertiesForm.ExecuteFileNoEx(FileName: string);
var
  Exif : TExif;
  RAWExif : TRAWExif;
  Options : TPropertyLoadImageThreadOptions;
begin
 if fSaving  then
 begin
  SetFocus;
  exit;
 end;
 DoProcessPath(FileName);
 SetLength(FPropertyLinks,0);
 SetLength(FNowGroups,0);

 Exif := TExif.Create;
 FFileDate:=0;
 try
  Exif.ReadFromFile(FileName);
  FFileDate:=Exif.Date;
  FFileTime:=Exif.Time;
 except
  EventLog('Error reading EXIF in file "'+FileName+'"');
 end;
 Exif.Free;
 FDateTimeInFileExists:=FFileDate<>0;
 if not FDateTimeInFileExists then
 begin
  if RAWImage.IsRAWSupport and RAWImage.IsRAWImageFile(FileName) then
  begin
   RAWExif:=ReadRAWExif(FileName);
   if RAWExif.isEXIF then
   begin
    FDateTimeInFileExists:=true;
    FFileDate:=DateOf(RAWExif.TimeStamp);
    FFileTime:=TimeOf(RAWExif.TimeStamp);
   end;
   RAWExif.Free;
  end;
 end;

 if EditLinkForm<>nil then
 EditLinkForm.Close;
 ResetBold;
 FCurrentPass:='';
 TabbedNotebook1.PageIndex:=0;
 caption:=TEXT_MES_PROPERTY+' - '+ ExtractFileName(FileName);
 CurrentItemInfo.ItemRotate:=0;
 no_file:=false;

 FShowInfoType:=SHOW_INFO_FILE_NAME;
 DBitem1.Visible:=false;
 DBKernel.RegisterChangesID(Self,ChangedDBDataByID);
 Editing_info:=false;
 CurrentItemInfo.ItemFileName:=FileName;
 OwnerMemo.ReadOnly:=true;

 Rating1.Enabled:=false;
 Rating1.Islayered:=false;
 CommentMemo.PopupMenu:=nil;
 Label3.Font.Style:=Label3.Font.Style-[fsBold];
 Label1.Font.Style:=Label1.Font.Style-[fsBold];
 RatingLabel1.Font.Style:=Label1.Font.Style-[fsBold];

 LabelName.text:=ExtractFileName(FileName);

 LabelPath.Text:=LongFileName(FileName);

 Label3.Hide;
 CommentMemo.Hide;
 CommentMemo.ReadOnly:=true;
 CommentMemo.Cursor:=CrDefault;
 Rating1.Rating:=0;
 Image2.Visible:=false;
 CollectionMemo.text:=TEXT_MES_NOT_AVALIABLE;
 CollectionMemo.ReadOnly:=true;
 IDLabel.Text:=TEXT_MES_NOT_AVALIABLE;
 KeyWordsMemo.text:=TEXT_MES_NOT_AVALIABLE;
 OwnerMemo.text:=TEXT_MES_NOT_AVALIABLE;
 KeyWordsMemo.ReadOnly:=true;


 DateEdit.Enabled:=false;
 if FFileDate<>0 then DateEdit.DateTime:=FFileDate else
 DateEdit.DateTime:=now;
 TimeEdit.Enabled:=false;
 TimeEdit.Time:=FFileTime;

 IsDatePanel.Visible:=not FDateTimeInFileExists;
 IsTimePanel.Visible:=not FDateTimeInFileExists;
 DateSets.Visible:=false;
 TimeSets.Visible:=false;
 If not Fileexists(FileName) then exit;
 If not ExtInMask(SupportedExt,getext(FileName)) then exit;

 SID:=GetGUID;
 Options.FileName:=FileName;
 Options.OnDone:=OnDoneLoadingImage;
 Options.SID:=SID;
 Options.Owner:=Self;
 TPropertyLoadImageThread.Create(Options);


 WidthMemo.Text:=TEXT_MES_LOADING___;
 HeightMemo.Text:=TEXT_MES_LOADING___;


 SizeLabel.text:=SizeInTextA(GetFileSize(FileName));
 BtSave.Caption:=TEXT_MES_ADD_FILE;
 Button2.Visible:=True;

 ImageLoadingFile.Visible:=true;
 Show;
end;

procedure TPropertiesForm.BeginAdding(Sender: TObject);
begin
 Image1DblClick(Sender);
 BtSave.Enabled:=false;
 adding_now:=true;
end;

procedure TPropertiesForm.EndAdding(Sender: TObject);
var
  PR : TImageDBRecordA;
begin
 adding_now:=false;
 pr:=getimageIDW(CurrentItemInfo.ItemFileName,false);
 if pr.count<>0 then
 begin
  Execute(pr.ids[0]);
 end else begin
  MessageBoxDB(Handle,TEXT_MES_UNABLE_FIND_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
end;

procedure TPropertiesForm.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  i, ID_ : integer;
begin
 if ID=-2 then exit;
 if Visible then
 begin
  Case FShowInfoType of
    SHOW_INFO_ID:
    begin
     if EventID_Param_Delete in params then
     begin
      Close;
      Exit;
     end;
     if EventID_Param_GroupsChanged in params then
     begin
      Exit;
     end;
     if id=CurrentItemInfo.ItemId then Execute(ID);
    end;
    SHOW_INFO_IDS:
    begin
     for i:=0 to FFilesInfo.Count - 1 do
     if FFilesInfo[I].ID = ID then
       Image2.Visible:=True;
    end;
    SHOW_INFO_FILE_NAME:
    begin
     If (AnsiLowerCase(Value.NewName)=AnsiLowerCase(CurrentItemInfo.ItemFileName)) and FileExists(Value.NewName) then
     begin
      ID_:=GetIdByFileName(CurrentItemInfo.ItemFileName);
      if ID_=0 then ExecuteFileNoEx(Value.NewName) else Execute(ID_);
     end;
     If (AnsiLowerCase(Value.Name)=AnsiLowerCase(CurrentItemInfo.ItemFileName)) then
     if FileExists(Value.NewName) and not FileExists(Value.Name) then ExecuteFileNoEx(Value.NewName)
    end;
  end;
 end;
end;

procedure TPropertiesForm.PopupMenu1Popup(Sender: TObject);
begin
 Shell1.Visible:=FileExists(CurrentItemInfo.ItemFileName);
 if FShowInfoType<>SHOW_INFO_IDS then
 Show1.Visible:=FileExists(CurrentItemInfo.ItemFileName);
 if FShowInfoType<>SHOW_INFO_IDS then Show1.Visible:=True;
 Copy1.Visible:=FileExists(CurrentItemInfo.ItemFileName);
 if FShowInfoType=SHOW_INFO_IDS then
 Copy1.Visible:=True;
 DBItem1.Clear;
 FFilesInfo.AttrExists:=false;
 TDBPopupMenu.Instance.AddDBContMenu(DBItem1,FFilesInfo);
end;

procedure TPropertiesForm.FormDestroy(Sender: TObject);
begin
 LinkDropFiles.Free;
 FreeDS(WorkQuery);
 DropFileTarget1.Unregister;
 SaveWindowPos1.SavePosition;
 DBKernel.UnRegisterForm(Self);
 DBkernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
end;

procedure TPropertiesForm.UpdateTheme(Sender: TObject);
begin
 if Visible then
 begin
  if FShowInfoType=SHOW_INFO_FILE_NAME then ExecuteFileNoEx(CurrentItemInfo.ItemFileName);
  if FShowInfoType=SHOW_INFO_ID then Execute(CurrentItemInfo.ItemId);
 end;
end;

procedure TPropertiesForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if not Active then exit;

 if Msg.hwnd=ListBox1.Handle then
 if Msg.message=256 then
 if Msg.wParam=46 then
 begin
  //???if not DBkernel.UserRights.SetInfo then
  //???Button7Click(nil);
 end;

 //???if not DBkernel.UserRights.SetInfo then
 //???If (Msg.hwnd=CheckBox1.Handle) or (Msg.hwnd=CheckBox3.Handle) or (Msg.hwnd=CheckBox3.Handle) then
 //???begin
 //??? If Msg.message=513 then Msg.message:=0;
 //??? If Msg.message=515 then Msg.message:=0;
 //???end;

 if Msg.message=256 then
 begin
  if Msg.wParam=27 then Close;
 end;

 if (Msg.hwnd=DateEdit.Handle) or (Msg.hwnd=TimeEdit.Handle) then
 begin
  if msg.message=513 then
  begin
    CommentMemoChange(nil);
  end;
 end;
end;

procedure TPropertiesForm.Datenotexists1Click(Sender: TObject);
begin
 IsDatePanel.Visible:=True;
 if FShowInfoType=SHOW_INFO_IDS then
 DateSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.IsDatePanelDblClick(Sender: TObject);
begin
 if fSaving then Exit;
 if FShowInfoType=SHOW_INFO_FILE_NAME then Exit;
 IsDatePanel.Visible:=False;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.ReloadGroups;
var
  i : integer;
  SmallB : TBitmap;
  GroupImageValid : Boolean;

  procedure CreateDefaultGroupImage;
  begin
   SmallB.Width:=16;
   SmallB.Height:=16;
   SmallB.Canvas.Pen.Color:=Theme_MainColor;
   SmallB.Canvas.Brush.Color:=Theme_MainColor;
   SmallB.Canvas.Rectangle(0,0,16,16);
   DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
   GroupImageValid:=true;
  end;

begin
 ListBox1.Clear;
 for i:=0 to Length(FNowGroups)-1 do
 begin
  ListBox1.Items.Add(FNowGroups[i].GroupName);
 end;
end;

procedure TPropertiesForm.ComboBox1_KeyPress(Sender: TObject; var Key: Char);
begin
 Key:=#0;
end;

procedure TPropertiesForm.ExecuteEx(IDs: TArInteger);
var
  b : Graphics.TBitmap;
  s, CommonKeyWords,  SQL : String;
  ArDir : TArStrings;
  FirstID : boolean;
  i, n, m, aLeft, num, len, k : integer;
  Size : int64;
  Ico : TIcon;
  ArWidth, ArHeight : TArInteger;
  MenuRecord : TDBPopupMenuInfoRecord;
const
  AllocBy = 300;

begin
 if fSaving  then
 begin
  SetFocus;
  exit;
 end;
 //aSetLength(0);
 if EditLinkForm<>nil then
 EditLinkForm.Close;
 ResetBold;
 CheckBox1.AllowGrayed:=true;
 TabbedNotebook1.PageIndex:=0;
 if Length(IDs)=0 then Exit;
 BtSave.Caption:=TEXT_MES_SAVE;
 Image2.Visible:=false;
 DateEdit.Enabled:=true;
 TimeEdit.Enabled:=true;
 DBKernel.RegisterChangesID(Self,ChangedDBDataByID);
 editing_info:=True;

 FShowInfoType:=SHOW_INFO_IDS;
 if Image1.Picture.Bitmap=nil then
 Image1.Picture.Bitmap:=Graphics.Tbitmap.create;
 b:=Image1.Picture.Bitmap;
 b.Width:=100;
 b.Height:=100;
 b.PixelFormat:=pf24bit;
 b.Canvas.Brush.color:=Theme_MainColor;
 b.Canvas.Pen.color:=RGB(Round(GetRValue(Theme_MainColor)*0.8),Round(GetGValue(Theme_MainColor)*0.8),Round(GetBValue(Theme_MainColor)*0.8));
 b.Canvas.Rectangle(0,0,100,100);
 Ico := TIcon.Create;
 Ico.Handle:=UnitDBKernel.icons[DB_IC_MANY_FILES+1];
 b.Canvas.Draw(100 div 2-Ico.Width div 2,100 div 2-Ico.Height div 2,Ico);
 Ico.Free;
 Size := 0;
 n := Trunc(Length(IDs)/AllocBy);
 if Length(IDs)/AllocBy-n>0 then inc(n);
 aLeft:=Length(IDs);
 for k:=1 to n do
 begin
  m:=Min(aLeft,Min(aLeft,AllocBy));


  FirstID:=True;
  SQL:='Select ID, FFileName, Comment, Owner, Collection, Rotated, Access, Rating, DateToAdd, aTime, IsDate, IsTime, Groups, FileSize, KeyWords, Width, Height, Thum, Include, Links FROM $DB$ Where ID in (';
  for i:=1 to m do
  begin
   Dec(aLeft);
   num:=i-1+AllocBy*(k-1);

   if FirstID then
   begin
    SQL:=SQL+' '+inttostr(IDs[num])+' ';
    FirstID:=False;
   end else SQL:=SQL+' , '+inttostr(IDs[num])+' ';
  end;
  SQL:=SQL+')';
  WorkQuery.Active:=false;
  SetSQL(WorkQuery,SQL);
  try
   WorkQuery.Active:=True;
  except
   MessageBoxDB(Handle,TEXT_MES_UNABLE_TO_SHOW_INFO_ABOUT_SELECTED_FILES,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   exit;
  end;

  //len:=Length(FFilesInfo.ItemFileNames_)+WorkQuery.RecordCount;
  //aSetLength(len);
  //len:=len-WorkQuery.RecordCount;

  WorkQuery.First;
  for I := 0 to WorkQuery.RecordCount-1 do
  begin
   MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
   MenuRecord.Selected := True;
   FFilesInfo.Add(MenuRecord);

   Size := Size + WorkQuery.FieldByName('FileSize').AsInteger;
   ArWidth[i+len]:=WorkQuery.FieldByName('Width').AsInteger;
   ArHeight[i+len]:=WorkQuery.FieldByName('Height').AsInteger;
   ArDir[i+len]:=GetDirectory(MenuRecord.FileName);

   WorkQuery.Next;
  end;

 end;
  if FFilesInfo.Count = 0 then
  begin
    MessageBoxDB(Handle, TEXT_MES_UNABLE_TO_SHOW_INFO_ABOUT_SELECTED_FILES,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    Exit;
  end;
  if FFilesInfo.Count = 1 then
  begin
    Execute(WorkQuery.FieldByName('ID').AsInteger);
    Exit;
  end;

  Caption:=TEXT_MES_PROPERTY+' - '+ExtractFileName(FFilesInfo[0].FileName)+TEXT_MES_AND_OTHERS;
  SizeLAbel.Text:=SizeInTextA(Size);
  OwnerMemo.Text:=TEXT_MES_NOT_AVALIABLE;
  CollectionMemo.Text:=TEXT_MES_NOT_AVALIABLE;
  CurrentItemInfo.ItemOwner:=TEXT_MES_NOT_AVALIABLE;
  CurrentItemInfo.ItemCollections:=TEXT_MES_NOT_AVALIABLE;
  OwnerMemo.ReadOnly:=True;
  CommentMemo.PopupMenu:=nil;
  CollectionMemo.ReadOnly:=True;

 if FFilesInfo.IsVariousInclude then
 begin
  CheckBox1.State:=cbGrayed;
  SelectedInfo.IsVaruousInclude:=true;
 end else
 begin
  SelectedInfo.IsVaruousInclude:=false;
  SelectedInfo.Include:=FFilesInfo[0].Include;
  if FFilesInfo[0].Include then
  CheckBox1.State:=cbChecked else
  CheckBox1.State:=cbUnChecked;
 end;

 If IsVariousArInteger(ArWidth) then
 WidthMemo.Text:=TEXT_MES_VAR_WIDTH else
 WidthMemo.Text:=format(TEXT_MES_ALL_PX,[IntToStr(ArWidth[0])]);
 If IsVariousArInteger(ArHeight) then
 HeightMemo.Text:=TEXT_MES_VAR_HEIGHT else
 HeightMemo.Text:=format(TEXT_MES_ALL_PX,[IntToStr(ArHeight[0])]);

 LabelName.Text:=TEXT_MES_VAR_FILES;
 if IsVariousArStrings(ArDir) then
 begin
  LabelPath.Text:=TEXT_MES_VAR_LOCATION;
 end else
 begin
  s:=ArDir[0];
  UnFormatDir(s);
  LabelPath.Text:=format(TEXT_MES_ALL_IN,[LongFileName(s)]);
 end;

 CurrentItemInfo.ItemRating := FFilesInfo.StatRating;
 Rating1.Rating := CurrentItemInfo.ItemRating;
 Rating1.Islayered := True;
 Rating1.layered := 100;
 CurrentItemInfo.ItemDate := FFilesInfo.StatDate;
 CurrentItemInfo.ItemTime := FFilesInfo.StatTime;
 TimeEdit.Time := CurrentItemInfo.ItemTime;
 CurrentItemInfo.ItemIsDate := FFilesInfo.StatIsDate;
 CurrentItemInfo.ItemIsTime := FFilesInfo.StatIsTime;
 SelectedInfo.IsDate:=CurrentItemInfo.ItemIsDate;
 SelectedInfo.IsTime:=CurrentItemInfo.ItemIsTime;
 SelectedInfo.Date:=CurrentItemInfo.ItemDate;
 DateEdit.DateTime:=CurrentItemInfo.ItemDate;
 IsDatePanel.Visible:=not SelectedInfo.IsDate;
 IsTimePanel.Visible:=not SelectedInfo.IsTime;

 DateSets.Visible := FFilesInfo.StatIsDate or FFilesInfo.IsVariousDate;
 TimeSets.Visible := FFilesInfo.StatIsTime or FFilesInfo.IsVariousDate;

 SelectedInfo.IsVariousDates:=DateSets.Visible;
 SelectedInfo.IsVariousTimes:=TimeSets.Visible;

 CommonKeyWords:=FFilesInfo.CommonKeyWords;
 SelectedInfo.CommonKeyWords:=CommonKeyWords;
 KeyWordsMemo.Text:=CommonKeyWords;
 CurrentItemInfo.ItemKeyWords:=CommonKeyWords;
 IDLabel.Text:=format(TEXT_MES_SELECTED_ITEMS,[IntToStr(FFilesInfo.Count)]);
 CommentMemo.Cursor:=CrDefault;
 SelectedInfo.IsVariousComments:=FFilesInfo.IsVariousComments;
 if SelectedInfo.IsVariousComments then
 begin
  SelectedInfo.CommonComment:=TEXT_MES_VAR_COM;
  CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
  CommentMemo.ReadOnly:=True;
  CommentMemo.Cursor:=CrHandPoint;
  CommentMemo.PopupMenu:=PopupMenu6;
 end else
 begin
  SelectedInfo.CommonComment:=FFilesInfo[0].Comment;
  CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
 end;
 CommentMemo.Text:=SelectedInfo.CommonComment;

 CurrentItemInfo.ItemGroups:=FFilesInfo.CommonGroups;

 FNowGroups:=UnitGroupsWork.EncodeGroups(CurrentItemInfo.ItemGroups);
 FOldGroups:=CopyGroups(FNowGroups);

 ItemLinks:=FFilesInfo.CommonLinks;
 FPropertyLinks:=CopyLinksInfo(ItemLinks);

 ReloadGroups;
 DBItem1.Visible:=True;
 FFilesInfo.IsListItem:=False;
 CommentMemoChange(nil);
 Button2.Visible:=false;
 ImageLoadingFile.Visible:=false;
 Show;
 SID:=GetGUID;
end;

procedure TPropertiesForm.FormShow(Sender: TObject);
begin
  BtDone.SetFocus;
end;

procedure TPropertiesForm.GroupsManager1Click(Sender: TObject);
begin
 ExecuteGroupManager;
end;

procedure TPropertiesForm.Rating1MouseDown(Sender: TObject);
begin
  if Rating1.islayered then Rating1.islayered:=false;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 SaveWindowPos1.SavePosition;
 if EditLinkForm<>nil then
 EditLinkForm.Close;

 Hide;
 if FSaving then
 begin
  DestroyTimer.Interval:=100;
  DestroyCounter:=1;
 end;
 DestroyTimer.Enabled:=true;

 PropertyManager.RemoveProperty(self);
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataGroups);
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
 DBKernel.UnRegisterChangesIDbyID(Self,ChangedDBDataByID,CurrentItemInfo.ItemId);
end;

procedure TPropertiesForm.SetValue1Click(Sender: TObject);
begin
  DateSets.Visible:=false;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.Ratingnotsets1Click(Sender: TObject);
begin
 Rating1.Islayered:=True;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PopupMenu5Popup(Sender: TObject);
begin
 if FShowInfoType=SHOW_INFO_FILE_NAME then
 begin
  Ratingnotsets1.Visible:=false;
  Exit;
 end;
 Ratingnotsets1.Visible:=not Rating1.Islayered;
 if FShowInfoType<>SHOW_INFO_IDS then
 Ratingnotsets1.Visible:=false;
 Ratingnotsets1.Visible:=Ratingnotsets1.Visible and not fSaving;;
end;

procedure TPropertiesForm.CommentMemoDblClick(Sender: TObject);
begin
 if FShowInfoType=SHOW_INFO_FILE_NAME then exit;
 if not CommentMemo.ReadOnly then exit;
 CommentMemo.ReadOnly:=False;
 CommentMemo.Cursor:=CrDefault;
 CommentMemo.Text:='';
 SelectedInfo.CommonComment:='';
 CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PopupMenu6Popup(Sender: TObject);
begin
 SetComent1.Visible:=CommentMemo.ReadOnly and (FShowInfoType=SHOW_INFO_FILE_NAME);
 Comentnotsets1.Visible:=not CommentMemo.ReadOnly;
 SelectAll1.Visible:=not CommentMemo.ReadOnly;
 Cut1.Visible:=not CommentMemo.ReadOnly;
 Copy2.Visible:=not CommentMemo.ReadOnly;
 Paste1.Visible:=not CommentMemo.ReadOnly;
 Undo1.Visible:=not CommentMemo.ReadOnly;
end;

procedure TPropertiesForm.Comentnotsets1Click(Sender: TObject);
begin
 CommentMemo.ReadOnly:=True;
 CommentMemo.Cursor:=CrHandPoint;
 CommentMemo.Text:=TEXT_MES_VAR_COM;
 SelectedInfo.CommonComment:=TEXT_MES_VAR_COM;
 CurrentItemInfo.ItemComment:= SelectedInfo.CommonComment;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.SelectAll1Click(Sender: TObject);
begin
 CommentMemo.SelectAll;
end;

procedure TPropertiesForm.Cut1Click(Sender: TObject);
begin
 CommentMemo.CutToClipboard;
end;

procedure TPropertiesForm.Copy2Click(Sender: TObject);
begin
 CommentMemo.CopyToClipboard;
end;

procedure TPropertiesForm.Paste1Click(Sender: TObject);
begin
 CommentMemo.PasteFromClipboard;
end;

procedure TPropertiesForm.Undo1Click(Sender: TObject);
begin
 CommentMemo.Undo;
end;

procedure TPropertiesForm.DateExists1Click(Sender: TObject);
begin
 IsDatePanel.Visible:=False;
 if FShowInfoType=SHOW_INFO_IDS then
 DateSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PopupMenu2Popup(Sender: TObject);
begin
 Datenotexists1.Visible:=(not IsDatePanel.Visible or (DateSets.Visible)) and (FShowInfoType<>SHOW_INFO_FILE_NAME);
 DateExists1.Visible:=(IsDatePanel.Visible or (DateSets.Visible)) and (FShowInfoType<>SHOW_INFO_FILE_NAME);
 Datenotsets1.Visible:=not DateSets.Visible and (FShowInfoType=SHOW_INFO_IDS);
 //rights section
 Datenotexists1.Visible:=Datenotexists1.Visible and not fSaving;
 DateExists1.Visible:=DateExists1.Visible and not fSaving;
 Datenotsets1.Visible:=Datenotsets1.Visible and not fSaving;
end;

procedure TPropertiesForm.Datenotsets1Click(Sender: TObject);
begin
 DateSets.Visible:=true;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.LoadLanguage;
begin
 Caption:=TEXT_MES_PROPERTY;
 Label3.Caption:=TEXT_MES_COMMENT+':';
 LabelName1.Caption:=TEXT_MES_NAME+':';
 Label4.Caption:=TEXT_MES_FULL_PATH+':';
 OwnerLabel.Caption:=TEXT_MES_OWNER;
 CollectionLabel.Caption:=TEXT_MES_COLLECTION;
 RatingLabel1.Caption:=TEXT_MES_RATING;
 DateLabel1.Caption:=TEXT_MES_DATE;
// GroupsLabel.Caption:= TEXT_MES_GROUPS;
 SizeLabel1.Caption:= TEXT_MES_SIZE;
 WidthLabel.Caption:= TEXT_MES_WIDTH;
 Heightlabel.Caption:= TEXT_MES_HEIGHT;
 IDLabel1.Caption:= TEXT_MES_ID;
 Label1.Caption:= TEXT_MES_KEYWORDS;
 Button2.Caption:= TEXT_MES_FIND_TARGET;
 BtSave.Caption:= TEXT_MES_SAVE;
 BtDone.Caption:= TEXT_MES_CANCEL;
 Shell1.Caption:= TEXT_MES_SHELL;
 Show1.Caption:= TEXT_MES_SHOW;
 Copy1.Caption:= TEXT_MES_COPY;
 DBItem1.Caption:= TEXT_MES_DBITEM;
 Searchforit1.Caption:= TEXT_MES_SEARCH_FOR_IT;

// EditGroups1.Caption:=TEXT_MES_EDIT_GROUPS;
// GroupsManager1.Caption:=TEXT_MES_GROUPS_MANAGER;
 Ratingnotsets1.Caption:=TEXT_MES_RATING_NOT_SETS;
 SetComent1.Caption:=TEXT_MES_SET_COM;
 Comentnotsets1.Caption:=TEXT_MES_SET_COM_NOT;
 SelectAll1.Caption:=TEXT_MES_SELECT_ALL;
 Cut1.Caption:=TEXT_MES_CUT;
 Copy2.Caption:=TEXT_MES_COPY;
 Paste1.Caption:=TEXT_MES_PASTE;
 Undo1.Caption:=TEXT_MES_UNDO;
 Setvalue1.Caption:=TEXT_MES_SET_VALUE;
 TabbedNotebook1.Pages[0]:=TEXT_MES_GENERAL;
 TabbedNotebook1.Pages[1]:=TEXT_MES_GROUPS;
 TabbedNotebook1.Pages[2]:=TEXT_MES_EXIF;
 TabbedNotebook1.Pages[3]:=TEXT_MES_GISTOGRAMM;
 TabbedNotebook1.Pages[4]:=TEXT_MES_ADDITIONAL_PROPERTY;

 Label2.Caption:=TEXT_MES_GISTOGRAMM_IMAGE+':';
 Label5.Caption:=Format(TEXT_MES_EFFECTIVE_RANGE_F,[0,0]);
 RgGistogrammChannel.Caption:=TEXT_MES_CHANEL;
 RgGistogrammChannel.Items[0]:=TEXT_MES_CHANEL_GRAY;
 RgGistogrammChannel.Items[1]:=TEXT_MES_CHANEL_R;
 RgGistogrammChannel.Items[2]:=TEXT_MES_CHANEL_G;
 RgGistogrammChannel.Items[3]:=TEXT_MES_CHANEL_B;
 CopyCurrent1.Caption:=TEXT_MES_COPY_CURRENT_ROW;
 CopyAll1.Caption:=TEXT_MES_COPY_ALL_INFO;
 CheckBox1.Caption:=TEXT_MES_INCLUDE_IN_BASE_SEARCH;
 Label6.Caption:=TEXT_MES_LINKS_FOR_PHOTOS+':';
 Addnewlink1.Caption:=TEXT_MES_ADD_LINK;

 Open1.Caption:=TEXT_MES_OPEN;
 OpenFolder1.Caption:=TEXT_MES_OPEN_FOLDER;
 Up1.Caption:=TEXT_MES_ITEM_UP;
 Down1.Caption:=TEXT_MES_ITEM_DOWN;
 Change1.Caption:=TEXT_MES_CHANGE_LINK;
 Delete1.Caption:=TEXT_MES_DELETE;
 Button5.Caption := TEXT_MES_GROUP_MANAGER_BUTTON;
 Button4.Caption := TEXT_MES_NEW_GROUP_BUTTON;
 Label8.Caption := TEXT_MES_AVALIABLE_GROUPS;
 Label9.Caption := TEXT_MES_CURRENT_GROUPS;
 Clear1.Caption := TEXT_MES_CLEAR;
 MenuItem1.Caption := TEXT_MES_DELETE_ITEM;
 CreateGroup1.Caption := TEXT_MES_GREATE_GROUP;
 ChangeGroup1.Caption := TEXT_MES_CHANGE_GROUP;
 GroupManeger1.Caption := TEXT_MES_GROUPS_MANAGER;
 QuickInfo1.Caption :=  TEXT_MES_QUICK_INFO;
 SearchForGroup1.Caption:=TEXT_MES_SEARCH_FOR_GROUP;
 CheckBox3.Caption:=TEXT_MES_SHOW_ALL_GROUPS;
 CheckBox2.Caption:=TEXT_MES_DELETE_UNUSED_KEY_WORDS;
 MoveToGroup1.Caption:=TEXT_MES_MOVE_TO_GROUP;


 Timenotsets1.Caption:=TEXT_MES_TIME_NOT_SETS;
 TimeExists1.Caption:=TEXT_MES_TIME_EXISTS;
 TimenotExists1.Caption:=TEXT_MES_TIME_NOT_EXISTS;
 DateSets.Caption:=TEXT_MES_VAR_VALUES;
 TimeSets.Caption:=TEXT_MES_VAR_VALUES;
 IsDatePanel.Caption:=TEXT_MES_NO_DATE_1;
 IsTimePanel.Caption:=TEXT_MES_TIME_NOT_EXISTS;
 TimeLabel.Caption:=TEXT_MES_TIME;
 Datenotexists1.Caption:=TEXT_MES_NO_DATE_1;
 DateExists1.Caption:=TEXT_MES_DATE_EX;
 Datenotsets1.Caption:=TEXT_MES_DATE_NOT_SETS;


 label7.Caption:=TEXT_MES_GROUPS_EDIT_INFO;

 Cancel1.Caption:=TEXT_MES_CANCEL;
 AddImThProcessingImageAndAddOriginalToProcessingPhoto1.Caption:=TEXT_MES_ADD_PROC_IMTH_AND_ADD_ORIG_TO_PROC_PHOTO;
 AddImThLink1.Caption:=TEXT_MES_ADD_PROC_IMTH;
 AddOriginalImThAndAddProcessngToOriginalImTh1.Caption:=TEXT_MES_ADD_ORIG_IMTH_AND_ADD_PROC_TO_ORIG_PHOTO;
 AddOriginalImTh1.Caption:=TEXT_MES_ADD_ORIG_IMTH;
end;



procedure TPropertiesForm.PopupMenu4Popup(Sender: TObject);
begin
 SetValue1.Visible:= (FShowInfoType=SHOW_INFO_FILE_NAME) and not fSaving;
end;

procedure TPropertiesForm.TabbedNotebook1Change(Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
var
  Options : TPropertyLoadGistogrammThreadOptions;
begin
 Case NewTab of
 0 :
 begin

 end;
 1 :
 begin
  if FReadingInfo then
  begin
   AllowChange:=false;
   exit;
  end;
  if FShowInfoType=SHOW_INFO_FILE_NAME then
  begin
   AllowChange:=false;
   exit;
  end;
  RecreateGroupsList;
 end;
 2 :
 begin
  if FReadingInfo then
  begin
   AllowChange:=false;
   exit;
  end;
  if FShowInfoType=SHOW_INFO_IDS then
  begin
   AllowChange:=false;
   exit;
  end;
  if not FileExists(CurrentItemInfo.ItemFileName) then
  begin
   AllowChange:=false;
   exit;
  end;
  ReadExifData;
 end;
 3 :
 begin
  if FReadingInfo then
  begin
   AllowChange:=false;
   exit;
  end;
  if FShowInfoType=SHOW_INFO_IDS then
  begin
   AllowChange:=false;
   exit;
  end;
  if not FileExists(CurrentItemInfo.ItemFileName) then
  begin
   AllowChange:=false;
   exit;
  end;
  RgGistogrammChannel.ItemIndex:=0;
  //ReadHistogrammData;

  if not GistogrammData.Loaded then
  begin
   Options.FileName:=CurrentItemInfo.ItemFileName;
   Options.Owner:=self;
   Options.SID:=SID;
   Options.OnDone:=OnDoneLoadGistogrammData;
   TPropertyLoadGistogrammThread.Create(Options);
   OnDoneLoadGistogrammData(self);
  end;
 end;
 4:
 begin
  if FReadingInfo then
  begin
   AllowChange:=false;
   exit;
  end;
  if FShowInfoType=SHOW_INFO_FILE_NAME then
  begin
   AllowChange:=false;
   exit;
  end;
  ReadLinks;
 end;
 end;
end;

procedure TPropertiesForm.ReadExifData;
var
  ex : TExif;
  I : Integer;
  RAWExif : TRAWExif;

  procedure xInsert(Key,Value : String);
  begin
   if Value<>'' then
   ValueListEditor1.InsertRow(Key,Value,true);
  end;

  procedure xInsertInt(Key : String; Value : integer);
  begin
   if Value<>0 then
   ValueListEditor1.InsertRow(Key,IntToStr(Value),true);
  end;

  procedure xInsertFloat(Key : String; Value : Single);
  begin
   if Value<>0 then
   ValueListEditor1.InsertRow(Key,FloatToStr(Value),true);
  end;

begin
  ValueListEditor1.Strings.Clear;

  if RAWImage.IsRAWSupport and RAWImage.IsRAWImageFile(CurrentItemInfo.ItemFileName) then
  begin
    RAWExif:=ReadRAWExif(CurrentItemInfo.ItemFileName);
    if RAWExif.isEXIF then
    begin
      ValueListEditor1.InsertRow('RAW Info:','',true);
      for I := 0 to RAWExif.Count - 1 do
        xInsert(Format('%s: ', [RAWExif[i].Description]), RAWExif[i].Value);
    end else
      ValueListEditor1.InsertRow('Info:',TEXT_MES_NO_EXIF_HEADER,true);
    RAWExif.Free;
  end else
  begin
    ex := TExif.Create;
    try
      try
        ex.ReadFromFile(CurrentItemInfo.ItemFileName);
        if ex.Valid then
        begin
          xInsert('Make: ',ex.Make);
          xInsert('Model: ',ex.Model);
          xInsert('Image Desk: ',ex.ImageDesc);
          xInsert('Copyright: ',ex.Copyright);
          xInsert('DateTime: ',ex.DateTime);
          xInsert('Original DateTime: ',ex.DateTimeOriginal);
          xInsert('Created DateTime: ',ex.DateTimeDigitized);
          xInsert('UserComments: ',ex.UserComments);
          xInsert('Software: ',ex.Software);
          xInsert('Artist: ',ex.Artist);
          if Byte(ex.Orientation) <> 0 then
            ValueListEditor1.InsertRow('Orientation: ',Format('%d (%s)', [Byte(ex.Orientation), ex.OrientationDesc]), True);
          xInsert('Exposure: ',ex.Exposure);
          if ex.ExposureProgram<>0 then
            ValueListEditor1.InsertRow('Exposure Program: ',Format('%d (%s)',[ex.ExposureProgram, ex.ExposureProgramDesc]), True);
          xInsert('Fstops: ',ex.FStops);
          xInsert('ShutterSpeed: ',ex.ShutterSpeed);
          xInsert('Aperture: ',ex.Aperture);
          xInsert('MaxAperture: ',ex.MaxAperture);
          xInsert('Compressed BPP: ',ex.CompressedBPP);
          xInsertInt('ISO speed: ',ex.ISO);
          xInsertInt('PixelXDimension: ',ex.PixelXDimension);
          xInsertInt('PixelYDimension: ',ex.PixelYDimension);
          xInsertInt('XResolution: ',ex.XResolution);
          xInsertInt('YResolution: ',ex.YResolution);
          xInsertInt('MeteringMode: ',ex.MeteringMode);
          xInsert('MeteringMethod: ',ex.MeteringMethod);
          xInsert('Orientation: ',ex.OrientationDesc);
          if ex.LightSource <> 0 then
            ValueListEditor1.InsertRow('LightSource: ',Format('%d (%s)',[ex.LightSource, ex.LightSourceDesc]),true);
          if ex.Flash <> 0 then
            ValueListEditor1.InsertRow('Flash: ',Format('%d (%s)',[ex.Flash, ex.FlashDesc]),true);
        end else
          ValueListEditor1.InsertRow('Info:',TEXT_MES_NO_EXIF_HEADER, True);
      except
      end;
    finally
      ex.free;
    end;
  end;
end;

procedure TPropertiesForm.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TPropertiesForm.RgGistogrammChannelClick(Sender: TObject);
begin
 Case RgGistogrammChannel.ItemIndex of
  0: DmGradient1.ColorTo:=$FFFFFF;
  1: DmGradient1.ColorTo:=$0000FF;
  2: DmGradient1.ColorTo:=$00FF00;
  3: DmGradient1.ColorTo:=$FF0000;
 end;
 OnDoneLoadGistogrammData(self);
end;

procedure TPropertiesForm.ResetBold;
begin
 Label3.Font.Style:=Label3.Font.Style-[fsBold];
 OwnerLabel.Font.Style:=OwnerLabel.Font.Style-[fsBold];
 CollectionLabel.Font.Style:=CollectionLabel.Font.Style-[fsBold];
 RatingLabel1.Font.Style:=RatingLabel1.Font.Style-[fsBold];
 DateLabel1.Font.Style:=DateLabel1.Font.Style-[fsBold];
 TimeLabel.Font.Style:=TimeLabel.Font.Style-[fsBold];
 Label1.Font.Style:=Label1.Font.Style-[fsBold];
 CheckBox1.Font.Style:=CheckBox1.Font.Style-[fsBold];
 Label6.Font.Style:=Label6.Font.Style-[fsBold];
end;

procedure TPropertiesForm.ValueListEditor1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ACol,ARow : integer;
begin
 ValueListEditor1.MouseToCell(MousePos.X,MousePos.Y,ACol,ARow);
 if (ACol<0) or (ARow<0) then
 begin
  Exit;
 end;
 MousePos:=ValueListEditor1.ClientToScreen(MousePos);
 CopyEXIFPopupMenu.Tag:=ARow;
 CopyEXIFPopupMenu.Popup(MousePos.X,MousePos.Y);
end;

procedure TPropertiesForm.CopyCurrent1Click(Sender: TObject);
begin
 Clipboard.AsText:=ValueListEditor1.Cells[0,CopyEXIFPopupMenu.Tag]+' '+ValueListEditor1.Cells[1,CopyEXIFPopupMenu.Tag];
end;

procedure TPropertiesForm.CopyAll1Click(Sender: TObject);
begin
  Clipboard.AsText:=ValueListEditor1.Strings.Text;
end;

procedure TPropertiesForm.ReadLinks;
var
  LI : TLinksInfo;
  i : integer;
  Icon : TIcon;
begin
 for i:=0 to Length(Links)-1 do
 Links[i].Free;
 LI:=CopyLinksInfo(FPropertyLinks);
 SetLength(Links,Length(LI));
 for i:=0 to Length(LI)-1 do
 begin
  Links[i]:=TWebLink.Create(LinksScrollBox);
  Links[i].Width:=0;
  Links[i].Left:=10;
  Links[i].Height:=19;
  Links[i].Top:=i*(19+5)+10;
  Links[i].Parent:=LinksScrollBox;
  if LI[i].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT<>0 then
  Links[i].Font.Color:=ColorDiv2(Theme_MainColor,Theme_MainFontColor) else
  Links[i].Font.Color:=Theme_MainFontColor;

  Links[i].BkColor:=LinksScrollBox.Color;
  Links[i].Width:=LinksScrollBox.Width-10;
  Links[i].Text:=LI[i].LinkName;
  Links[i].Tag:= i;
  Links[i].OnClick:=LinkClick;
  Links[i].OnContextPopup:=LinkOnPopup;
  Links[i].ImageCanRegenerate:=true;
   //
  Icon := TIcon.Create;

  case LI[i].LinkType of
  LINK_TYPE_ID : Icon.Handle:=UnitDBKernel.Icons[DB_IC_SLIDE_SHOW+1];
  LINK_TYPE_ID_EXT : Icon.Handle:=UnitDBKernel.Icons[DB_IC_NOTES+1];
  LINK_TYPE_IMAGE : Icon.Handle:=UnitDBKernel.Icons[DB_IC_DESKTOP+1];
  LINK_TYPE_FILE : Icon.Handle:=UnitDBKernel.Icons[DB_IC_SHELL+1];
  LINK_TYPE_FOLDER : Icon.Handle:=UnitDBKernel.Icons[DB_IC_DIRECTORY+1];
  LINK_TYPE_TXT : Icon.Handle:=UnitDBKernel.Icons[DB_IC_TEXT_FILE+1];
  LINK_TYPE_HTML : Icon.Handle:=UnitDBKernel.Icons[DB_IC_SLIDE_SHOW+1];
  end;
  Links[i].Icon := Icon;
  Icon.Free;
  Links[i].Visible:=true;
 end;
 CommentMemoChange(self);
end;

procedure TPropertiesForm.Addnewlink1Click(Sender: TObject);
var
  LI : TLinksInfo;
begin
 LI:=CopyLinksInfo(FPropertyLinks);
 EditLinkForm:=AddNewLink(true,FPropertyLinks, SetLinkInfo, CloseEditLinkForm);
end;

procedure TPropertiesForm.LinkOnPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
 Handled:=true;
 PopupMenu7.Tag:=TWebLink(Sender).Tag;
 MousePos:=TWebLink(Sender).ClientToScreen(MousePos);
 PopupMenu7.Popup(MousePos.X,MousePos.Y);
end;

procedure TPropertiesForm.Delete1Click(Sender: TObject);
begin
 DeleteLinkAtPos(FPropertyLinks,PopupMenu7.Tag);
 ReadLinks;
end;

procedure TPropertiesForm.LinkClick(Sender: TObject);
var
  n : integer;
//  Info : TRecordsInfo;
  LI : TLinksInfo;
  TIRA : TImageDBRecordA;
  p : TPoint;
  s, DN : string;

 procedure ViewFile(FileName : String);
 begin
  If Viewer=nil then
  Application.CreateForm(TViewer,Viewer);
  Viewer.ShowFile(FileName);
 end;

begin
 GetCursorPos(p);
 n:=TWebLink(Sender).Tag;
 LI:=CopyLinksInfo(FPropertyLinks);
 Case LI[n].LinkType of
  LINK_TYPE_ID : ViewFile(GetFileNameById(StrToIntDef(LI[n].LinkValue,0)));
  LINK_TYPE_ID_EXT :
  begin
   TIRA:=getimageIDTh(DeCodeExtID(LI[n].LinkValue));
   if TIRA.count>0 then
   ViewFile(TIRA.FileNames[0]);
  end;
  LINK_TYPE_IMAGE : ViewFile(LI[n].LinkValue);
  LINK_TYPE_FILE : begin s:=GetDirectory(LI[n].LinkValue); ShellExecute(Handle, nil, PWideChar(LI[n].LinkValue), nil, PWideChar(S), SW_NORMAL); end;
  LINK_TYPE_FOLDER :
  begin
   DN:=LI[n].LinkValue;
   UnFormatDir(DN);
   if (DN<>'') and not DirectoryExists(DN) then
   begin
    MessageBoxDB(Handle,Format(TEXT_MES_DIRECTORY_NOT_EXISTS_F,[DN]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
    Exit;
   end;
   With ExplorerManager.NewExplorer(False) do
   begin
    SetPath(LI[n].LinkValue);
    Show;
    SetFocus;
   end;
  end;
  LINK_TYPE_TXT : DoHelpHint(LI[n].LinkName,LI[n].LinkValue,p,Links[n]);
  LINK_TYPE_HTML : ;
  end;
end;

procedure TPropertiesForm.PopupMenu7Popup(Sender: TObject);
var
  MenuInfo : TDBPopupMenuInfo;
  n, ID : integer;
  LI : TLinksInfo;

  Procedure DoExit;
  begin
   if LI[n].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT<>0 then
   begin
    Open1.Visible:=false; OpenFolder1.Visible:=false; IDMenu1.Visible:=false; Up1.Visible:=false; Down1.Visible:=false;
   end;
   Change1.Visible:=Change1.Visible and not fSaving;
   Delete1.Visible:=Delete1.Visible and  not fSaving;

   Up1.Visible:=Up1.Visible and not fSaving;
   Down1.Visible:=Down1.Visible and not fSaving;

  end;

begin

 Change1.Visible:=EditLinkForm=nil;
 Delete1.Visible:=EditLinkForm=nil;
 n:=PopupMenu7.Tag;
 Up1.Visible:=n<>0;
 Down1.Visible:=n<>Length(FPropertyLinks)-1;
 LI:=CopyLinksInfo(FPropertyLinks);

 case LI[n].LinkType of
  LINK_TYPE_ID : begin Open1.Visible:=true; OpenFolder1.Visible:=true; end;
  LINK_TYPE_ID_EXT : begin Open1.Visible:=true; OpenFolder1.Visible:=true; end;
  LINK_TYPE_IMAGE : begin Open1.Visible:=true; OpenFolder1.Visible:=true; end;
  LINK_TYPE_FILE : begin Open1.Visible:=true; OpenFolder1.Visible:=true; end;
  LINK_TYPE_FOLDER : begin Open1.Visible:=false; OpenFolder1.Visible:=true; end;
  LINK_TYPE_TXT : begin Open1.Visible:=true; OpenFolder1.Visible:=false; end;
  LINK_TYPE_HTML : begin Open1.Visible:=false; OpenFolder1.Visible:=false; end;
 end;

 if LI[n].LinkType=LINK_TYPE_ID then
 if LI[n].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT=0 then
 begin
  IDMenu1.Visible:=true;
  ID:=StrToIntDef(LI[n].LinkValue,0);
  MenuInfo:=GetMenuInfoByID(ID);
  MenuInfo.IsPlusMenu:=False;
  MenuInfo.IsListItem:=False;
  MenuInfo.AttrExists:=false;
  IDMenu1.Caption:=Format(TEXT_MES_DBITEM_FORMAT,[inttostr(ID)]);
  TDBPopupMenu.Instance.AddDBContMenu(IDMenu1,MenuInfo);
  DoExit;
  exit;
 end;
 if LI[n].LinkType=LINK_TYPE_ID_EXT then
 if LI[n].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT=0 then
 begin
  IDMenu1.Visible:=true;
  MenuInfo:=GetMenuInfoByStrTh(DeCodeExtID(LI[n].LinkValue));
  MenuInfo.IsPlusMenu:=False;
  MenuInfo.IsListItem:=False;
  MenuInfo.AttrExists:=false;
  if MenuInfo.Count > 0 then
  IDMenu1.Caption:=Format(TEXT_MES_DBITEM_FORMAT,[inttostr(MenuInfo[0].ID)]) else
  IDMenu1.Caption:=Format(TEXT_MES_DBITEM_FORMAT,[inttostr(0)]);
  TDBPopupMenu.Instance.AddDBContMenu(IDMenu1,MenuInfo);
  DoExit;
  exit;
 end;
 IDMenu1.Visible:=false;
 DoExit;
end;

procedure TPropertiesForm.Change1Click(Sender: TObject);
var
  LI : TLinksInfo;
  i, n : integer;
begin
 n:=PopupMenu7.Tag;
 LI:=CopyLinksInfo(FPropertyLinks);
 for i:=0 to Length(LI)-1 do
 begin
  LI[i].Tag:=LI[i].Tag or LINK_TAG_NONE;
 end;
 LI[n].Tag:=LI[n].Tag or LINK_TAG_SELECTED;
 EditLinkForm:=AddNewLink(false,LI, SetLinkInfo, CloseEditLinkForm);
end;

procedure TPropertiesForm.CloseEditLinkForm(Form: TForm; ID: String);
begin
 EditLinkForm:=nil;
end;

procedure TPropertiesForm.PopupMenu8Popup(Sender: TObject);
begin
 AddNewlink1.Visible:=EditLinkForm=nil;
 AddNewlink1.Visible:=AddNewlink1.Visible and not fSaving;
end;

procedure TPropertiesForm.SetLinkInfo(Sender: TObject; ID: String;
  Info: TLinkInfo; N: integer; Action : Integer);
begin
 Case Action of
  LINK_PROC_ACTION_ADD :
   begin
    SetLength(FPropertyLinks,Length(FPropertyLinks)+1);
    FPropertyLinks[Length(FPropertyLinks)-1]:=Info;
   end;
  LINK_PROC_ACTION_MODIFY :
   begin
    FPropertyLinks[N]:=Info;
   end;
 end;
 ReadLinks;
 SetFocus;
end;

procedure TPropertiesForm.Open1Click(Sender: TObject);
var
  n : integer;
begin
 n:=PopupMenu7.Tag;
 Links[n].OnClick(Links[n]);
end;

procedure TPropertiesForm.OpenFolder1Click(Sender: TObject);
var
  n : integer;
  FN, DN : String;
  TIRA : TImageDBRecordA;
begin
 n:=PopupMenu7.Tag;
 DN:='';
 FN:='';
 Case FPropertyLinks[n].LinkType of
  LINK_TYPE_ID : FN:=GetFileNameById(StrToIntDef(FPropertyLinks[n].LinkValue,0));
  LINK_TYPE_ID_EXT :
  begin
   TIRA:=GetImageIDTh(DeCodeExtID(FPropertyLinks[n].LinkValue));
   if TIRA.count>0 then
   FN:=TIRA.FileNames[0];
  end;
  LINK_TYPE_IMAGE : FN:=FPropertyLinks[n].LinkValue;
  LINK_TYPE_FILE : FN:=FPropertyLinks[n].LinkValue;
  LINK_TYPE_FOLDER : DN:=FPropertyLinks[n].LinkValue;
  LINK_TYPE_TXT : exit;
  LINK_TYPE_HTML : exit;
  else exit;
 end;
 if DN='' then DN:=GetDirectory(FN);
 UnFormatDir(DN);
 if (DN<>'') and not DirectoryExists(DN) then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_DIRECTORY_NOT_EXISTS_F,[DN]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Exit;
 end;
 With ExplorerManager.NewExplorer(False) do
 begin
  if FN<>'' then
  SetOldPath(FN);
  SetPath(DN);
  Show;
  SetFocus;
 end;
end;

procedure TPropertiesForm.Up1Click(Sender: TObject);
var
  temp : TLinkInfo;
  n : integer;
begin
 n:=PopupMenu7.Tag;
 temp:=FPropertyLinks[n-1];
 FPropertyLinks[n-1]:=FPropertyLinks[n];
 FPropertyLinks[n]:=temp;
 ReadLinks;
end;

procedure TPropertiesForm.Down1Click(Sender: TObject);
var
  temp : TLinkInfo;
  n : integer;
begin
 n:=PopupMenu7.Tag;
 temp:=FPropertyLinks[n+1];
 FPropertyLinks[n+1]:=FPropertyLinks[n];
 FPropertyLinks[n]:=temp;
 ReadLinks;
end;

procedure TPropertiesForm.Button5Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TPropertiesForm.Button4Click(Sender: TObject);
begin
  CreateNewGroupDialog;
end;

procedure TPropertiesForm.RecreateGroupsList;
var
  i, size : integer;
  SmallB, B : TBitmap;
//  GroupImageValud : Boolean;
begin
 FreeGroups(RegGroups);
 FreeGroups(FShowenRegGroups);
 RegGroups:=GetRegisterGroupList(True);
 RegGroupsImageList.Clear;
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 SmallB.Width:=16;
 SmallB.Height:=18;
 SmallB.Canvas.Pen.Color:=Theme_MainColor;
 SmallB.Canvas.Brush.Color:=Theme_MainColor;
 SmallB.Canvas.Rectangle(0,0,16,18);
 DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
 RegGroupsImageList.Add(SmallB,nil);
 SmallB.Free;
 ListBox2.Clear;
 for i:=0 to Length(RegGroups)-1 do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Canvas.Brush.Color:=Theme_MainColor;
  if RegGroups[i].GroupImage<>nil then
  if not RegGroups[i].GroupImage.Empty then
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   size:=Max(RegGroups[i].GroupImage.Width,RegGroups[i].GroupImage.Height);
   B.Canvas.Brush.Color:=Theme_MainColor;
   B.Canvas.Pen.Color:=Theme_MainColor;
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - RegGroups[i].GroupImage.Width div 2, B.Height div 2 - RegGroups[i].GroupImage.Height div 2,RegGroups[i].GroupImage);
   DoResize(16,16,B,SmallB);
   B.Free;
   SmallB.Height:=18;
  end;
  RegGroupsImageList.Add(SmallB,nil);
  if RegGroups[i].IncludeInQuickList or CheckBox3.Checked then
  begin
   UnitGroupsWork.AddGroupToGroups(FShowenRegGroups,RegGroups[i]);
   ListBox2.Items.Add(RegGroups[i].GroupName);

  end;
  SmallB.Free;
 end;
 ListBox1.Refresh;
end;

procedure TPropertiesForm.ListBox2DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  n, i : Integer;
  xNewGroups : TGroups;

  function NewGroup(GroupCode : String) : Boolean;
  var
    j : integer;
  begin
   Result:=false;
   for j:=0 to Length(xNewGroups)-1 do
   if xNewGroups[j].GroupCode=GroupCode then
   begin
    Result:=true;
    Break;
   end;
  end;

  function GroupExists(GroupCode : String) : Boolean;
  var
    j : integer;
  begin
   Result:=false;
   for j:=0 to Length(FNowGroups)-1 do
   if FNowGroups[j].GroupCode=GroupCode then
   begin
    Result:=true;
    Break;
   end;
  end;

begin
 if FShowInfoType=SHOW_INFO_FILE_NAME then exit;
 if Control=ListBox1 then
 begin
  xNewGroups:=CopyGroups(FNowGroups);
  RemoveGroupsFromGroups(xNewGroups,FOldGroups);
 end else
 begin
  xNewGroups:=CopyGroups(FOldGroups);
  RemoveGroupsFromGroups(xNewGroups,FNowGroups);
 end;
 try
  if Index=-1 then exit;
  with (Control as TListBox).Canvas do
  begin
   FillRect(Rect);
   n:=-1;
   if Control=ListBox1 then
   begin
    for i:=0 to Length(RegGroups)-1 do
    begin
     if RegGroups[i].GroupCode=FNowGroups[Index].GroupCode then
     begin
      n:=i+1;
      break;
     end;
    end
   end else
   begin
    for i:=0 to Length(RegGroups)-1 do
    begin
     if RegGroups[i].GroupName=(Control as TListBox).Items[Index] then
     begin
      n:=i+1;
      break;
     end;
    end
   end;

   RegGroupsImageList.Draw((Control as TListBox).Canvas,Rect.Left+2,Rect.Top+2,max(0,n));
   if n=-1 then
   begin
    DrawIconEx((Control as TListBox).Canvas.Handle,Rect.Left+10,Rect.Top+8,UnitDBKernel.icons[DB_IC_DELETE_INFO+1],8,8,0,0,DI_NORMAL);
   end;
   if Control=ListBox1 then
   if NewGroup(FNowGroups[Index].GroupCode) then
   (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style+[fsBold] else (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style-[fsBold];

   if Control=ListBox2 then
   if n>-1 then
   if NewGroup(RegGroups[n-1].GroupCode) then
    (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style+[fsBold] else
    begin
     if GroupExists(FShowenRegGroups[Index].GroupCode) then
     begin
      (Control as TListBox).Canvas.Font.Color:=ColorDiv2(Theme_ListFontColor,Theme_MemoEditColor);
     end else
     begin
      (Control as TListBox).Canvas.Font.Color:=Theme_ListFontColor;
     end;
    (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style-[fsBold];
   end;

   TextOut(Rect.Left+21, Rect.Top+3, (Control as TListBox).Items[Index]);
  end;
 except
   on e : Exception do EventLog(':TPropertiesForm.ListBox2DrawItem() throw exception: '+e.Message);
 end;
end;

procedure TPropertiesForm.ListBox1DblClick(Sender: TObject);
var
  i : integer;
  Group : TGroup;
begin
 if fSaving then Exit;
 for i:=0 to (Sender as TListBox).Items.Count-1 do
 if (Sender as TListBox).Selected[i] then
 begin
  Group:=GetGroupByGroupCode(FNowGroups[i].GroupCode,false);
  ShowGroupInfo(Group,false,nil);
  Break;
 end;
end;

procedure TPropertiesForm.Button6Click(Sender: TObject);
var
  i : integer;

  Procedure AddGroup(Group : TGroup);
  var
    FRelatedGroups : TGroups;
    OldGroups, Groups : TGroups;
    TempGroup : TGroup;
    i : integer;
    KeyWords : String;
  begin
   FRelatedGroups:=EncodeGroups(Group.RelatedGroups);
   OldGroups:=CopyGroups(FNowGroups);
   Groups:=CopyGroups(OldGroups);
   AddGroupToGroups(Groups,Group);
   AddGroupsToGroups(Groups,FRelatedGroups);
   FNowGroups:=CopyGroups(Groups);
   RemoveGroupsFromGroups(Groups,OldGroups);
   for i:=0 to Length(Groups)-1 do
   begin
    ListBox1.Items.Add(Groups[i].GroupName);
    TempGroup:=GetGroupByGroupCode(Groups[i].GroupCode,false);
    KeyWords:=KeyWordsMemo.Text;
    AddWordsA(TempGroup.GroupKeyWords,KeyWords);
    KeyWordsMemo.Text:=KeyWords;
   end;
  end;

begin
 for i:=0 to ListBox2.Items.Count-1 do
 if ListBox2.Selected[i] then
 begin
  AddGroup(FShowenRegGroups[i]);
 end;
 ListBox1.Invalidate;
 ListBox2.Invalidate;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.Button7Click(Sender: TObject);
var
  i, j : integer;
  KeyWords, AllGroupsKeyWords, GroupKeyWords : String;
begin
 for i:=ListBox1.Items.Count-1 downto 0 do
 if ListBox1.Selected[i] then
 begin
  if CheckBox2.Checked then
  begin
   AllGroupsKeyWords:='';
   for j:=ListBox1.Items.Count-1 downto 0 do
   if i<>j then
   begin
    AddWordsA(RegGroups[aGetGroupByCode(FNowGroups[j].GroupCode)].GroupKeyWords,AllGroupsKeyWords);
   end;
   KeyWords:=KeyWordsMemo.Text;
   GroupKeyWords:=RegGroups[aGetGroupByCode(FNowGroups[i].GroupCode)].GroupKeyWords;
   DeleteWords(GroupKeyWords,AllGroupsKeyWords);
   DeleteWords(KeyWords,GroupKeyWords);
   KeyWordsMemo.Text:=KeyWords;
  end;
  //удаляем группу изтекущих
  RemoveGroupFromGroups(FNowGroups,FNowGroups[i]);
  ListBox1.Items.Delete(i);
 end;
 ListBox1.Invalidate;
 ListBox2.Invalidate;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.ListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ItemNo : Integer;
  i : integer;
begin
 if fSaving then Exit;
 ItemNo:=ListBox1.ItemAtPos(MousePos,True);
 If ItemNo<>-1 then
 begin
  if not ListBox1.Selected[ItemNo] then
  begin
   ListBox1.Selected[ItemNo]:=True;
   for i:=0 to ListBox1.Items.Count-1 do
   if i<>ItemNo then
   ListBox1.Selected[i]:=false;
  end;
  PopupMenu9.Tag:=ItemNo;
  PopupMenu9.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
 end else
 begin
  for i:=0 to ListBox1.Items.Count-1 do
  ListBox1.Selected[i]:=false;
  PopupMenu10.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
 end;
end;

procedure TPropertiesForm.Clear1Click(Sender: TObject);
begin
 ListBox1.Clear;
 FreeGroups(FNowGroups);
 CommentMemoChange(Sender);
 ListBox1.Invalidate;
 ListBox2.Invalidate;
end;

procedure TPropertiesForm.CheckBox3Click(Sender: TObject);
begin
 RecreateGroupsList;
 DBKernel.WriteBool('Propetry','ShowAllGroups',CheckBox3.Checked);
end;

procedure TPropertiesForm.ListBox2DblClick(Sender: TObject);
begin
 if fSaving then Exit;
 Button6Click(Sender);
end;

function TPropertiesForm.aGetGroupByCode(GroupCode: String): integer;
var
  i : integer;
begin
 Result:=0;
 for i:=0 to Length(RegGroups)-1 do
 if RegGroups[i].GroupCode=GroupCode then
 begin
  Result:=i;
  break;
 end;
end;

procedure TPropertiesForm.CreateGroup1Click(Sender: TObject);
begin
 CreateNewGroupDialogA(FNowGroups[PopupMenu9.Tag].GroupName,FNowGroups[PopupMenu9.Tag].GroupCode);
end;

procedure TPropertiesForm.ChangeGroup1Click(Sender: TObject);
var
  Group : TGroup;
begin
 Group := GetGroupByGroupCode(FNowGroups[PopupMenu9.Tag].GroupCode,false);
 DBChangeGroup(Group);
end;

procedure TPropertiesForm.GroupManeger1Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TPropertiesForm.SearchForGroup1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.NewSearch;
 NewSearch.SearchEdit.Text:=':Group('+FNowGroups[PopupMenu9.Tag].GroupName+'):';
 NewSearch.WlStartStop.OnClick(Sender);
 NewSearch.Show;
end;

procedure TPropertiesForm.QuickInfo1Click(Sender: TObject);
begin
 ShowGroupInfo(FNowGroups[PopupMenu9.Tag],false,nil);
end;

procedure TPropertiesForm.PopupMenu9Popup(Sender: TObject);
begin
 if GroupWithCodeExists(FNowGroups[PopupMenu9.Tag].GroupCode) then
 begin
  CreateGroup1.Visible:=False;
  MoveToGroup1.Visible:=False;
  ChangeGroup1.Visible:=True;
 end else
 begin
  CreateGroup1.Visible:=True;
  MoveToGroup1.Visible:=True;
  ChangeGroup1.Visible:=False;
 end;
end;

procedure TPropertiesForm.CheckBox2Click(Sender: TObject);
begin
 DBkernel.WriteBool('Propetry','DeleteKeyWords',CheckBox2.Checked);
end;

procedure TPropertiesForm.MoveToGroup1Click(Sender: TObject);
var
  ToGroup : TGroup;
begin
 if SelectGroup(ToGroup) then
 begin
  MoveGroup(FNowGroups[PopupMenu9.Tag],ToGroup);
  MessageBoxDB(Handle,TEXT_MES_RELOAD_INFO,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
 end;
end;

procedure TPropertiesForm.PanelValueIsTimeSetsDblClick(Sender: TObject);
begin
 IsDatePanel.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PopupMenu11Popup(Sender: TObject);
begin
 TimeNotExists1.Visible:=(not IsTimePanel.Visible or TimeSets.Visible) and (FShowInfoType<>SHOW_INFO_FILE_NAME);
 TimeExists1.Visible:=(IsTimePanel.Visible or TimeSets.Visible) and (FShowInfoType<>SHOW_INFO_FILE_NAME);
 Timenotsets1.Visible:=not TimeSets.Visible and (FShowInfoType=SHOW_INFO_IDS);
 //rights section
 Timenotexists1.Visible:=Timenotexists1.Visible and not fSaving;
 TimeExists1.Visible:=TimeExists1.Visible and not fSaving;
 Timenotsets1.Visible:=Timenotsets1.Visible and not fSaving;
end;

procedure TPropertiesForm.DateEditChange(Sender: TObject);
begin
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.TimeEditChange(Sender: TObject);
begin
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.TimenotExists1Click(Sender: TObject);
begin
 IsTimePanel.Visible:=True;
 if FShowInfoType=SHOW_INFO_IDS then
 TimeSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.TimeExists1Click(Sender: TObject);
begin
 IsTimePanel.Visible:=False;
 if FShowInfoType=SHOW_INFO_IDS then
 TimeSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.Timenotsets1Click(Sender: TObject);
begin
 TimeSets.Visible:=true;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.IsTimePanelDblClick(Sender: TObject);
begin
 if fSaving then Exit;
 if FShowInfoType=SHOW_INFO_FILE_NAME then Exit;
 IsTimePanel.Visible:=False;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.DestroyTimerTimer(Sender: TObject);
begin
 if FSaving then Exit;
 if DestroyCounter>0 then
 begin
  inc(DestroyCounter);
 end;
 if (DestroyCounter<3) and (DestroyCounter<>0) then exit;
 DestroyTimer.Enabled:=false;
 Release;
end;

procedure TPropertiesForm.ChangedDBDataGroups(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
begin
 if EventID_Param_GroupsChanged in params then
 begin
  RecreateGroupsList;
  Exit;
 end;
end;

procedure TPropertiesForm.DateSetsDblClick(Sender: TObject);
begin
 if fSaving then Exit;
 DateSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.TimeSetsDblClick(Sender: TObject);
begin
 if fSaving then Exit;
 TimeSets.Visible:=false;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.LockImput;
begin
 fSaving := true;
 if EditLinkForm<>nil then
 EditLinkForm.Close;
 CommentMemo.Enabled:=False;
 OwnerMemo.Enabled:=False;
 CollectionMemo.Enabled:=False;
 Rating1.Enabled:=False;
 KeyWordsMemo.Enabled:=False;
 DateEdit.Enabled:=False;
 TimeEdit.Enabled:=False;
 CheckBox1.Enabled:=False;
 ListBox2.Enabled:=False;
 ListBox1.Enabled:=False;
 Button6.Enabled:=False;
 Button7.Enabled:=False;
end;

procedure TPropertiesForm.UnLockImput;
begin
 fSaving := False;
 OwnerMemo.Enabled := True;
 CollectionMemo.Enabled := True;
 Rating1.Enabled := True;
 KeyWordsMemo.Enabled := True;
 DateEdit.Enabled := True;
 TimeEdit.Enabled := True;
 CheckBox1.Enabled := True;
 ListBox2.Enabled := True;
 ListBox1.Enabled := True;
 Button6.Enabled := True;
 Button7.Enabled := True;
end;

procedure TPropertiesForm.PopupMenu10Popup(Sender: TObject);
begin
 Clear1.Visible:=(ListBox1.Items.Count<>0) and not fSaving;
end;

procedure TPropertiesForm.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if FShowInfoType<>SHOW_INFO_FILE_NAME then
 if DropFileTarget2.Files.Count=1 then
 begin
  SetFocus;
  Point:=LinksScrollBox.ClientToScreen(Point);
  LinkDropFiles.Assign(DropFileTarget2.Files);
  PopupMenu3.Popup(Point.X,Point.Y);
 end;
end;

procedure TPropertiesForm.AddImThLink1Click(Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo : TLinkInfo;
  i : integer;
  b : boolean;
begin
 GetInfoByFileNameA(LinkDropFiles[0], False, Info);
 if Info.ItemImTh='' then Info.ItemImTh:=GetImageIDW(LinkDropFiles[0],False).ImTh;
 LinkInfo.LinkType:=LINK_TYPE_ID_EXT;
 LinkInfo.LinkName:=TEXT_MES_PROCESSING;
 LinkInfo.LinkValue:=CodeExtID(Info.ItemImTh);
 b:=true;
 for i:=0 to Length(FPropertyLinks)-1 do
 if FPropertyLinks[i].LinkName=TEXT_MES_PROCESSING then
 begin
  b:=False;
  break;
 end;
 if b then
 begin
  SetLength(FPropertyLinks,Length(FPropertyLinks)+1);
  FPropertyLinks[Length(FPropertyLinks)-1]:=LinkInfo;
 end;
 ReadLinks;
 SetFocus;
end;


procedure TPropertiesForm.AddOriginalImTh1Click(Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo : TLinkInfo;
  i : integer;
  b : boolean;
begin
 GetInfoByFileNameA(LinkDropFiles[0],False, Info);
 if Info.ItemImTh='' then Info.ItemImTh:=GetImageIDW(LinkDropFiles[0],False).ImTh;
 LinkInfo.LinkType:=LINK_TYPE_ID_EXT;
 LinkInfo.LinkName:=TEXT_MES_ORIGINAL;
 LinkInfo.LinkValue:=CodeExtID(Info.ItemImTh);
 b:=true;
 for i:=0 to Length(FPropertyLinks)-1 do
 if FPropertyLinks[i].LinkName=TEXT_MES_PROCESSING then
 begin
  b:=False;
  break;
 end;
 if b then
 begin
  SetLength(FPropertyLinks,Length(FPropertyLinks)+1);
  FPropertyLinks[Length(FPropertyLinks)-1]:=LinkInfo;
 end;
 ReadLinks;
 SetFocus;
end;

procedure TPropertiesForm.AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(
  Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo : TLinkInfo;
  LinksInfo : TLinksInfo;
  Query : TDataSet;
  i : integer;
  b : boolean;
begin
 GetInfoByFileNameA(LinkDropFiles[0],False, Info);
 if Info.ItemImTh='' then Info.ItemImTh:=GetImageIDW(LinkDropFiles[0],False).ImTh;
 LinkInfo.LinkType:=LINK_TYPE_ID_EXT;
 LinkInfo.LinkName:=TEXT_MES_PROCESSING;
 LinkInfo.LinkValue:=CodeExtID(Info.ItemImTh);
 b:=true;
 for i:=0 to Length(FPropertyLinks)-1 do
 if FPropertyLinks[i].LinkName=TEXT_MES_PROCESSING then
 begin
  b:=False;
  break;
 end;
 if b then
 begin
  SetLength(FPropertyLinks,Length(FPropertyLinks)+1);
  FPropertyLinks[Length(FPropertyLinks)-1]:=LinkInfo;
 end;
 SetLength(LinksInfo,1);
 LinksInfo[0].LinkType:=LINK_TYPE_ID_EXT;
 LinksInfo[0].LinkName:=TEXT_MES_ORIGINAL;
 LinksInfo[0].LinkValue:=CodeExtID(CurrentItemInfo.ItemImTh);
 ReplaceLinks('',CodeLinksInfo(LinksInfo),Info.ItemLinks);
 Query := GetQuery;
 SetSQL(Query,Format('UPDATE $DB$ Set Links = :Links where ID = %d',[Info.ItemId]));
 SetStrParam(Query,0,Info.ItemLinks);
 ExecSQL(Query);
 FreeDS(Query);
 ReadLinks;
 SetFocus;
end;

procedure TPropertiesForm.AddOriginalImThAndAddProcessngToOriginalImTh1Click(
  Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo : TLinkInfo;
  LinksInfo : TLinksInfo;
  Query : TDataSet;
  i : integer;
  b : boolean;
begin
 GetInfoByFileNameA(LinkDropFiles[0],False,Info);
 if Info.ItemImTh='' then Info.ItemImTh:=GetImageIDW(LinkDropFiles[0],False).ImTh;
 LinkInfo.LinkType:=LINK_TYPE_ID_EXT;
 LinkInfo.LinkName:=TEXT_MES_ORIGINAL;
 LinkInfo.LinkValue:=CodeExtID(Info.ItemImTh);
 b:=true;
 for i:=0 to Length(FPropertyLinks)-1 do
 if FPropertyLinks[i].LinkName=TEXT_MES_PROCESSING then
 begin
  b:=False;
  break;
 end;
 if b then
 begin
  SetLength(FPropertyLinks,Length(FPropertyLinks)+1);
  FPropertyLinks[Length(FPropertyLinks)-1]:=LinkInfo;
 end;
 SetLength(LinksInfo,1);
 LinksInfo[0].LinkType:=LINK_TYPE_ID_EXT;
 LinksInfo[0].LinkName:=TEXT_MES_PROCESSING;
 LinksInfo[0].LinkValue:=CodeExtID(CurrentItemInfo.ItemImTh);
 ReplaceLinks('',CodeLinksInfo(LinksInfo),Info.ItemLinks);
 Query := GetQuery;
 SetSQL(Query,Format('UPDATE $DB$ Set Links = :Links where ID = %d',[Info.ItemId]));
 SetStrParam(Query,0,Info.ItemLinks);
 ExecSQL(Query);
 FreeDS(Query);
 ReadLinks;
 SetFocus;
end;

procedure TPropertiesForm.PopupMenu3Popup(Sender: TObject);
begin
 AddImThProcessingImageAndAddOriginalToProcessingPhoto1.Visible:=(FShowInfoType=SHOW_INFO_ID);
 AddOriginalImThAndAddProcessngToOriginalImTh1.Visible:=(FShowInfoType=SHOW_INFO_ID);
end;

procedure TPropertiesForm.OnDoneLoadingImage(Sender: TObject);
begin

end;

procedure TPropertiesForm.OnDoneLoadGistogrammData(Sender: TObject);
var
  Bitmap : TBitmap;
  MinC, MaxC: Integer;
begin
  if Sender is TPropertyLoadGistogrammThread then
    GistogrammData.Loaded := True;

  Bitmap := TBitmap.Create;
  try
    case RgGistogrammChannel.ItemIndex of
      0:
        GetGistogrammBitmapW(130, GistogrammData.Gray, MinC, MaxC, Bitmap);
      1:
        GetGistogrammBitmapW(130, GistogrammData.Red, MinC, MaxC, Bitmap);
      2:
        GetGistogrammBitmapW(130, GistogrammData.Green, MinC, MaxC, Bitmap);
      3:
        GetGistogrammBitmapW(130, GistogrammData.Blue, MinC, MaxC, Bitmap);
    end;

    Label5.Caption := Format(TEXT_MES_EFFECTIVE_RANGE_F, [MinC, MaxC]);
    GistogrammImage.Picture.Bitmap := Bitmap;
  finally
    Bitmap.Free;
  end;
end;

procedure TPropertiesForm.WMActivate(var Message: TWMActivate);
begin
  if (Message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) and IsWindowsVista then
  begin
    SetActiveWindow(Application.Handle);
    Message.Result := 0;
  end else
    inherited;
end;

procedure TPropertiesForm.WMSyscommand(var Message: TWmSysCommand);
begin
  case (Message.CmdType and $FFF0) of
    SC_MINIMIZE:
    begin
      ShowWindow(Handle, SW_MINIMIZE);
      Message.Result := 0;
    end;
    SC_RESTORE:
    begin
      ShowWindow(Handle, SW_RESTORE);
      Message.Result := 0;
    end;
  else
    inherited;
  end;
end;

initialization

PropertyManager := TPropertyManager.Create;

finalization

FreeAndNil(PropertyManager);

end.
