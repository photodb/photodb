unit ManagerDBUnit;

interface

uses
  UnitGroupsWork, DBCMenu, Dolphin_DB, UnitDBkernel, Windows, Messages,
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Math, uVistaFuncs,
  ExtCtrls, AppEvnts, ImgList, DropTarget, DragDropFile, DragDrop,
  DropSource, Menus, SaveWindowPos, DB, ComCtrls, WebLink, StdCtrls,
  Dialogs, Grids, DBGrids, jpeg, DBCtrls, TwButton, Rating, Mask,
  GraphicCrypt, UnitStringPromtForm, CommonDBSupport, GraphicsCool,
  CommCtrl, DateUtils, uScript, UnitScripts, CmpUnit, UnitFormManagerHint,
  UnitConvertDBForm, UnitDBDeclare, UnitDBCommon, UnitDBCommonGraphics,
  UnitCDMappingSupport, uConstants, uFileUtils;

type
  TManagerDB = class(TForm)
    DataSource1: TDataSource;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    Label7: TLabel;
    ComboBox2: TComboBox;
    Label9: TLabel;
    Edit2: TEdit;
    Label10: TLabel;
    ComboBox3: TComboBox;
    Edit3: TEdit;
    Button2: TButton;
    ComboBox4: TComboBox;
    Edit4: TEdit;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RecordNumberEdit: TEdit;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu2: TPopupMenu;
    Dateexists1: TMenuItem;
    PopupMenu3: TPopupMenu;
    EditGroups1: TMenuItem;
    GroupsManager1: TMenuItem;
    PopupMenu4: TPopupMenu;
    DateExists2: TMenuItem;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    GroupsImageList: TImageList;
    ListBox1: TListBox;
    Label11: TLabel;
    PopupMenu5: TPopupMenu;
    Delete1: TMenuItem;
    Restore1: TMenuItem;
    Refresh1: TMenuItem;
    PopupMenu6: TPopupMenu;
    Timenotexists1: TMenuItem;
    PopupMenu7: TPopupMenu;
    TimeExists1: TMenuItem;
    Rename1: TMenuItem;
    ListView1: TListView;
    ApplicationEvents1: TApplicationEvents;
    ImageList2: TImageList;
    PopupMenuRating: TPopupMenu;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    PopupMenuKeyWords: TPopupMenu;
    PopupMenuRotate: TPopupMenu;
    R01: TMenuItem;
    R02: TMenuItem;
    R03: TMenuItem;
    R04: TMenuItem;
    PopupMenuGroups: TPopupMenu;
    ImageListPopupGroups: TImageList;
    PopupMenuDate: TPopupMenu;
    PopupMenuFile: TPopupMenu;
    PackTabelLink: TWebLink;
    ExportTableLink: TWebLink;
    ImportTableLink: TWebLink;
    RecreateIDExLink: TWebLink;
    ScanforBadLinksLink: TWebLink;
    BackUpDBLink: TWebLink;
    CleaningLink: TWebLink;
    ListBox2: TListBox;
    Button3: TButton;
    DBImageList: TImageList;
    PopupMenu8: TPopupMenu;
    DeleteDB1: TMenuItem;
    RenameDB1: TMenuItem;
    N1: TMenuItem;
    SelectDB1: TMenuItem;
    EditDB1: TMenuItem;
    LoadDBTimer: TTimer;
    DublicatesLink: TWebLink;
    ConvertLink: TWebLink;
    ChangePathLink: TWebLink;
    N2: TMenuItem;
    Showfileinexplorer1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckSQL;
    procedure ComboBox6Change(Sender: TObject);
    procedure Lock;
    procedure UnLock;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GroupsManager1Click(Sender: TObject);
    procedure ReadBackUps;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure InitializeQueryList;
    procedure ListView1AdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure GetData(Index: integer);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure N51Click(Sender: TObject);
    procedure R04Click(Sender: TObject);
    procedure ListView1WindowProc(var Message: TMessage);
    procedure EditGroupsMenuClick(Sender: TObject);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PackTabelLinkClick(Sender: TObject);
    procedure ExportTableLinkClick(Sender: TObject);
    procedure ImportTableLinkClick(Sender: TObject);
    procedure RecreateIDExLinkClick(Sender: TObject);
    procedure ScanforBadLinksLinkClick(Sender: TObject);
    procedure BackUpDBLinkClick(Sender: TObject);
    procedure CleaningLinkClick(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure DeleteItemWithID(ID : integer);
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button3Click(Sender: TObject);
    procedure RefreshDBList;
    procedure ListBox2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure RenameDB1Click(Sender: TObject);
    procedure SelectDB1Click(Sender: TObject);
    procedure DeleteDB1Click(Sender: TObject);
    procedure ListBox2DblClick(Sender: TObject);
    procedure DBOpened(Sender: TObject);
    procedure EditDB1Click(Sender: TObject);
    procedure RecordNumberEditChange(Sender: TObject);
    procedure LoadDBTimerTimer(Sender: TObject);
    procedure DublicatesLinkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ConvertLinkClick(Sender: TObject);
    procedure ChangePathLinkClick(Sender: TObject);
    procedure Showfileinexplorer1Click(Sender: TObject);
  private
   DBInOpening : boolean;
   OldWNDProc : TWndMethod;
   IDs : array of integer;
   aData : array of Pointer;
   LastSelected : TListItem;
   LastSelectedIndex : integer;
   LockDraw : boolean;
   aGroups : TGroups;
   GroupBitmaps : array of TBitmap;
   FormManagerHint : TFormManagerHint;
   WorkQuery : TDataSet;
   IsLock : Boolean;
   FBackUpFiles : TStrings;
   DBCanDrag : Boolean;
   SI : integer;
   LoadingList : boolean;

  procedure OnMove(var Msg: TWMMove); message WM_MOVE;
  procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
  procedure CMMOUSEEnter(var Message: TWMNoParams); message CM_MOUSEenter;

  function GetListViewItemAt(y : integer): TListItem;

    { protected declarations }
  protected
  procedure CreateParams(VAR Params: TCreateParams); override;    
    { public declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

  type

  TListData = record
    ID : Integer;
    FileName : PChar;
    KeyWords : PChar;
    Comment : PChar;
    Rating : integer;
    Rotate : integer;
    Access : integer;
    Date : TDate;
    Time : TTime;
    Groups : PChar;
    FileSize : PChar;
    Links : PChar;
    IsDate : boolean;
    IsTime : boolean;
    Include : boolean;
    Exists : integer;
  end;

  PListData = ^TListData;


var
  ManagerDB: TManagerDB;

Const FieldCount = 19;
ChFields : array[1..FieldCount] of string = ('ID','Rating','Rotated','Access',
'Width','Height','Attr','Name','FFileName','Comment','KeyWords','Owner','Collection','DateToAdd','IsDate','Include','Links','aTime','IsTime');
      FieldTypeInt  = 0;
      FieldTypeStr  = 1;
      FieldTypeDate = 2;
      FieldTypeBool = 3;
      ChFieldsTypes : array[1..FieldCount] of integer = (FieldTypeInt,FieldTypeInt,FieldTypeInt,FieldTypeInt,
FieldTypeInt,FieldTypeInt,FieldTypeInt,FieldTypeStr,FieldTypeStr,FieldTypeStr,FieldTypeStr,FieldTypeStr,FieldTypeStr,FieldTypeDate,FieldTypeBool,FieldTypeBool,FieldTypeStr,FieldTypeDate,FieldTypeBool);

implementation

uses UnitQuickGroupInfo, UnitBackUpTableThread, DBSelectUnit, ExplorerUnit,
     Searching, SlideShow, ExportUnit, UnitManageGroups, Language,
     CleaningForm, UnitDBCleaning, UnitCompareDataBases, UnitEditGroupsForm,
     UnitPasswordForm, UnitOpenQueryThread, ProgressActionUnit,
     UnitMenuDateForm, UnitChangeDBPath, UnitSelectDB,
     UnitDBOptions;

{$R *.dfm}

  function TManagerDB.GetListViewItemAt(y : integer): TListItem;
  var
    r : TRect;
    i : integer;
  begin
   Result:=nil;
   for i:=0 to ListView1.Items.Count-1 do
   begin
    r:=ListView1.Items[i].DisplayRect(drBounds);
    if PtInRect(r,Point(0,y)) then
    begin
     Result:=ListView1.Items[i];
     exit;
    end;
   end;
  end;

procedure TManagerDB.FormCreate(Sender: TObject);
Var
  i : integer;
begin
 FormManagerHint:=nil;
// ImageList1.Clear;
 PopupMenuRating.Images:=DBkernel.ImageList;
 PopupMenuRotate.Images:=DBkernel.ImageList;
 N01.ImageIndex:=DB_IC_DELETE_INFO;
 N11.ImageIndex:=DB_IC_RATING_1;
 N21.ImageIndex:=DB_IC_RATING_2;
 N31.ImageIndex:=DB_IC_RATING_3;
 N41.ImageIndex:=DB_IC_RATING_4;
 N51.ImageIndex:=DB_IC_RATING_5;

 R01.ImageIndex:=DB_IC_ROTETED_0;
 R02.ImageIndex:=DB_IC_ROTETED_90;
 R03.ImageIndex:=DB_IC_ROTETED_180;
 R04.ImageIndex:=DB_IC_ROTETED_270;


 SI:=-1;
 DBInOpening:=true;
 PackTabelLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SHELL+1]);
 ExportTableLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SAVE_AS_TABLE+1]);
 ImportTableLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_LOADFROMFILE+1]);
 RecreateIDExLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_REFRESH_ID+1]);
 ScanforBadLinksLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SEARCH+1]);
 BackUpDBLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_CANCEL_ACTION+1]);
 CleaningLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_COMMON+1]);
 DublicatesLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_DUBLICAT+1]);
 ConvertLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_CONVERT+1]);
 ChangePathLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_DIRECTORY+1]);

 OldWNDProc:=ListView1.WindowProc;
 ListView1.WindowProc:=ListView1WindowProc;
// InitializeQueryList;

 WorkQuery:=GetQuery;
 DBCanDrag:=false;
 PopupMenu5.Images:=DBKernel.ImageList;
 Delete1.ImageIndex:=DB_IC_DELETE_INFO;
 Restore1.ImageIndex:=DB_IC_LOADFROMFILE;
 Refresh1.ImageIndex:=DB_IC_RELOAD;
 Rename1.ImageIndex:=DB_IC_RENAME;

 PopupMenu8.Images:=DBKernel.ImageList;
 SelectDB1.ImageIndex:=DB_IC_SHELL;
 RenameDB1.ImageIndex:=DB_IC_RENAME;
 DeleteDB1.ImageIndex:=DB_IC_DELETE_INFO;
 EditDB1.ImageIndex:=DB_IC_NOTES;

 FBackUpFiles:=TStringList.Create;
 ListBox1.DoubleBuffered:=true;
 UnLock;
 DropFileTarget1.Register(Self);
 DBCanDrag:=false;
 DBkernel.RegisterChangesID(self,ChangedDBDataByID);
 DBkernel.RegisterForm(self);
 DBkernel.RecreateThemeTOForm(self);

 Showfileinexplorer1.ImageIndex:=DB_IC_FOLDER;
 
 ComboBox2.Items.Clear;
 ComboBox3.Items.Clear;
 ComboBox5.Items.Clear;
 ComboBox3.Items.Add(ChFields[1]);
 ComboBox5.Items.Add(ChFields[1]);
 For i:=2 to FieldCount do
 begin
  ComboBox2.Items.Add(ChFields[i]);
  ComboBox3.Items.Add(ChFields[i]);
  ComboBox5.Items.Add(ChFields[i]);
 end;
 CheckSQL;
 SaveWindowPos1.Key:=RegRoot+'Manager';
 SaveWindowPos1.SetPosition;
 LoadLanguage;
 ReadBackUps;
 RefreshDBList;
end;

procedure TManagerDB.ComboBox1Change(Sender: TObject);
begin
 CheckSQL;
end;

Procedure SetPCharString(var p : PChar; S : String);
var
  L : integer;
begin
 l:=Length(s);
 if p<>nil then FreeMem(p);
 GetMem(p,Length(s)+1);
 p[L]:=#0;
 lstrcpyn(p,PChar(S),L+1);
end;

procedure TManagerDB.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  i : integer;
begin
 if SetNewIDFileData in params then
 if Value.ID>0 then
 begin
  SetLength(IDs,Length(IDs)+1);
  SetLength(aData,Length(aData)+1);
  with  ListView1.Items.Add do
  begin
   aData[Length(aData)-1]:=nil;
  end;
  IDs[Length(aData)-1]:=Value.ID;
  exit;
 end;
 
 if EventID_Param_DB_Changed in params then
 begin
  ListView1.Clear;
  FreeDS(WorkQuery);
  DBInOpening:=true;
  InitializeQueryList;
  WorkQuery:=GetQuery;
//  Edit1.text:=Value.Name;
  exit;
 end;
 if EventID_Param_Delete in params then
 begin
  DeleteItemWithID(ID);
  exit;
 end;
 for i:=0 to Length(aData)-1 do
 if aData[i]<>nil then
 if PListData(aData[i])^.ID=ID then
 begin
  if EventID_Param_Date in params then PListData(aData[i])^.Date:=Value.Date;
  if EventID_Param_Time in params then PListData(aData[i])^.Time:=Value.Time;
  if EventID_Param_IsDate in params then PListData(aData[i])^.IsDate:=Value.IsDate;
  if EventID_Param_IsTime in params then PListData(aData[i])^.IsTime:=Value.IsTime;
  if EventID_Param_Groups in params then SetPCharString(PListData(aData[i])^.Groups,Value.Groups);
  if EventID_Param_Comment in params then SetPCharString(PListData(aData[i])^.Comment,Value.Comment);
  if EventID_Param_KeyWords in params then SetPCharString(PListData(aData[i])^.KeyWords,Value.KeyWords);
  if EventID_Param_Links in params then SetPCharString(PListData(aData[i])^.Links,Value.Links);
  if EventID_Param_Include in params then PListData(aData[i])^.Include:=Value.Include;
  if EventID_Param_Rotate in params then PListData(aData[i])^.Rotate:=Value.Rotate;
  if EventID_Param_Rating in params then PListData(aData[i])^.Rating:=Value.Rating;
  if EventID_Param_Private in params then PListData(aData[i])^.Access:=Value.Access;
  ListView1.Repaint;
 end;
end;

procedure TManagerDB.FormDestroy(Sender: TObject);
var
  i : integer;
begin
 FreeGroups(aGroups);
 for i:=0 to Length(GroupBitmaps)-1 do
 GroupBitmaps[i].Free;
 SetLength(GroupBitmaps,0);

 FreeDS(WorkQuery);
 FBackUpFiles.Free;
 if FormManagerHint<>nil then
 begin
  FormManagerHint.Release;
  if UseFreeAfterRelease then
  FormManagerHint.Free;
  FormManagerHint:=nil;
 end;
 DropFileTarget1.Unregister;
 SaveWindowPos1.SavePosition;
 DBkernel.UnRegisterForm(self);
 DBkernel.UnRegisterChangesID(self,ChangedDBDataByID);
end;

procedure TManagerDB.RadioButton1Click(Sender: TObject);
begin
 ComboBox2.Enabled:=RadioButton1.Checked;
 Edit2.Enabled:=RadioButton1.Checked;
 CheckSQL;
end;

procedure TManagerDB.ComboBox4Change(Sender: TObject);
begin
 if ComboBox4.Text=' ' then
 begin
  ComboBox5.Enabled:=false;
  ComboBox7.Enabled:=false;
  Edit4.Enabled:=false;
 end else
 begin
  ComboBox5.Enabled:=true;
  ComboBox7.Enabled:=true;
  Edit4.Enabled:=true;
 end;
 CheckSQL;
end;

function GetFieldTupe(FieldName : String) : Integer;
var
  i : integer;
begin
 Result:=0;
 For i:=1 to FieldCount do
 if AnsiUpperCase(ChFields[i])=AnsiUpperCase(FieldName) then
 begin
  Result:=ChFieldsTypes[i];
  exit;
 end;
end;

procedure TManagerDB.ComboBox3Change(Sender: TObject);
var
  NewField : String;
begin
 NewField:=ComboBox3.Text;
 If (GetFieldTupe(NewField)=FieldTypeInt) or (GetFieldTupe(NewField)=FieldTypeDate) then
 begin
  ComboBox6.Items.Clear;
  ComboBox6.Items.Add('=');
  ComboBox6.Items.Add('>');
  ComboBox6.Items.Add('<');
  ComboBox6.Items.Add('<>');
 end;
 If GetFieldTupe(NewField)=FieldTypeStr then
 begin
  ComboBox6.Items.Clear;
  ComboBox6.Items.Add('=');
  ComboBox6.Items.Add('<>');
  ComboBox6.Items.Add('like');
 end;
 If GetFieldTupe(NewField)=FieldTypeBool then
 begin
  ComboBox6.Items.Clear;
  ComboBox6.Items.Add('=');
  ComboBox6.Items.Add('<>');
 end;
 CheckSQL;
end;

procedure TManagerDB.ComboBox5Change(Sender: TObject);
var
  NewField : String;
begin
 NewField:=ComboBox5.Text;
 If (GetFieldTupe(NewField)=FieldTypeInt) or (GetFieldTupe(NewField)=FieldTypeDate) then
 begin
  ComboBox7.Items.Clear;
  ComboBox7.Items.Add('=');
  ComboBox7.Items.Add('>');
  ComboBox7.Items.Add('<');
  ComboBox7.Items.Add('<>');
 end else
 begin
  ComboBox7.Items.Clear;
  ComboBox7.Items.Add('=');
  ComboBox7.Items.Add('<>');
  ComboBox7.Items.Add('like');
 end;
 If GetFieldTupe(NewField)=FieldTypeBool then
 begin
  ComboBox7.Items.Clear;
  ComboBox7.Items.Add('=');
  ComboBox7.Items.Add('<>');
 end;
 CheckSQL;
end;

function ValueToDBValue(FieldName, Value : String) : String;
var
  FieldType : integer;
begin
 FieldType:=GetFieldTupe(FieldName);
 If FieldType=FieldTypeInt then Result:=IntToStr(StrToIntDef(Value,0));
 If FieldType=FieldTypeStr then Result:='"'+normalizeDBString(Value)+'"';
 If FieldType=FieldTypeBool then
 begin
  if Value='0' then
  Result:='TRUE' else Result:='FALSE';
 end;
 If FieldType=FieldTypeDate then Result:=FloatToStr(StrToDateTimeDef(Value,0));
end;

procedure TManagerDB.Button2Click(Sender: TObject);
var
  SQL : String;
  q : TDataSet;
begin
 q:=GetQuery();
 If RadioButton1.Checked then
 begin
  SQL:='Update '+GetDefDBname+' Set '+ComboBox2.Text+' = '+ValueToDBValue(ComboBox2.Text,Edit2.Text);
 end else
 begin
  SQL:='Delete from '+GetDefDBName;
 end;
 SQL:=SQL+' Where ';
 SQL:=SQL+'('+ComboBox3.Text+' '+ComboBox6.Text+' '+ValueToDBValue(ComboBox3.Text,Edit3.Text)+')';
 If (ComboBox4.Text<>' ') and (ComboBox4.Text<>'') then
 begin
  SQL:=SQL+' '+ComboBox4.Text+' ('+ComboBox5.Text+' '+ComboBox7.Text+' '+ValueToDBValue(ComboBox5.Text,Edit4.Text)+')';
 end;
 SetSQL(q,SQL);
 try
  ExecSQL(q);
 except
  on e : Exception do
  MessageBoxDB(Handle,Format(TEXT_MES_ERROR_EXESQSL_BY_REASON_F,[e.Message,SQL]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
 FreeDS(q);
end;

procedure TManagerDB.CheckSQL;
begin
 If (((ComboBox2.Text<>'') and RadioButton1.Checked) or RadioButton2.Checked) and (ComboBox3.Text<>'') and (ComboBox6.Text<>'') then
 begin
  If (ComboBox4.Text=' ') or (ComboBox4.Text='') then
  begin
   Button2.Enabled:=true;
  end else
  begin
   If (ComboBox5.Text<>'') and (ComboBox7.Text<>'') then
   Button2.Enabled:=true else Button2.Enabled:=false;
  end;
 end else
 begin
  Button2.Enabled:=false;
 end;
end;

procedure TManagerDB.ComboBox6Change(Sender: TObject);
begin
 CheckSQL;
end;

procedure TManagerDB.Lock;
begin
 IsLock := True;
end;

procedure TManagerDB.UnLock;
begin
 IsLock := False;
end;

procedure TManagerDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 ManagerDB.Release;
 if UseFreeAfterRelease then ManagerDB.Free;
 ManagerDB:=nil;
end;

procedure TManagerDB.GroupsManager1Click(Sender: TObject);
begin
 ExecuteGroupManager;
end;

procedure TManagerDB.LoadLanguage;
begin
 RadioButton1.Caption:=TEXT_MES_SET;
 RadioButton2.Caption:=TEXT_MES_DELETE;
 Label10.Caption:=TEXT_MES_WHERE;
 PackTabelLink.Text:=TEXT_MES_PACK_TABLE;
 ExportTableLink.Text:=TEXT_MES_EXPORT_TABLE;
 ImportTableLink.Text:=TEXT_MES_IMPORT_TABLE;
 BackUpDBLink.Text:=TEXT_MES_BACK_UP_DB;
 CleaningLink.Text:=TEXT_MES_CLEANING;
 DublicatesLink.Text:=TEXT_MES_OPTIMIZING_DUBLICATES;
 Button2.Caption:=TEXT_MES_EXES_SQL;
 DateExists1.Caption:=TEXT_MES_DATE_NOT_EX;
 DateExists2.Caption:=TEXT_MES_DATE_EX;
 EditGroups1.Caption:=TEXT_MES_EDIT_GROUPS;
 GroupsManager1.Caption:=TEXT_MES_GROUPS_MANAGER;
 Label7.Caption:=TEXT_MES_GO_TO_REC_ID;
 Caption:=TEXT_MES_MANAGER_DB;
 Label11.Caption:=TEXT_MES_BACKUPS;
 Restore1.Caption:=TEXT_MES_RESTORE_DB;
 Delete1.Caption:=TEXT_MES_DELETE;
 Refresh1.Caption:=TEXT_MES_REFRESH;
 TimenotExists1.Caption:=TEXT_MES_TIME_NOT_SETS;
 TimeExists1.Caption:=TEXT_MES_TIME_EXISTS;
 Rename1.Caption:=TEXT_MES_RENAME;
 RecreateIDExLink.Text:=TEXT_MES_RECTEATE_IDEX_CAPTION;
 ScanforBadLinksLink.Text:=TEXT_MES_BAD_LINKS_CAPTION;
 Button3.Caption:=TEXT_MES_DO_ADD_DB;
 EditDB1.Caption:=TEXT_MES_EDIT;
 SelectDB1.Caption:=TEXT_MES_SELECT_DB; 
 DeleteDB1.Caption:=TEXT_MES_DELETE;
 RenameDB1.Caption:=TEXT_MES_RENAME;
 ConvertLink.Text:=TEXT_MES_CONVERT_DB;
 ChangePathLink.Text:=TEXT_MES_THANGE_FILES_PATH_IN_DB;

 ListView1.Columns[0].Caption:=TEXT_MES_ID;
 ListView1.Columns[1].Caption:=TEXT_MES_FILE_NAME;
 ListView1.Columns[2].Caption:=TEXT_MES_KEYWORDS;
 ListView1.Columns[3].Caption:=TEXT_MES_COMMENT;
 ListView1.Columns[4].Caption:=TEXT_MES_RATING;
 ListView1.Columns[5].Caption:=TEXT_MES_ROTATE;
 ListView1.Columns[6].Caption:=TEXT_MES_ACCESS;
 ListView1.Columns[7].Caption:=TEXT_MES_GROUPS;  
 ListView1.Columns[8].Caption:=TEXT_MES_DATE;
 ListView1.Columns[9].Caption:=TEXT_MES_TIME;  
 ListView1.Columns[10].Caption:=TEXT_MES_SIZE;

 Showfileinexplorer1.Caption:=TEXT_MES_SHOW_FILE_IN_EXPLORER;
end;

procedure TManagerDB.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 Params.WndParent := GetDesktopWindow;
 with params do
 ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TManagerDB.ReadBackUps;
var
  i : integer;
begin
 FBackUpFiles.Clear;
 GetValidMDBFilesInFolder(GetAppDataDirectory+BackUpFolder,true,FBackUpFiles);
 ListBox1.Clear;
 for i:=0 to FBackUpFiles.Count-1 do
 ListBox1.Items.Add(ExtractFileName(FBackUpFiles[i]));

end;

procedure TManagerDB.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB : TListBox;
begin
 LB:=(Control as TListBox);
 LB.Canvas.FillRect(Rect);
 LB.Canvas.TextOut(Rect.Left+21, Rect.Top+3,LB.Items[Index]);
 DrawIconEx(LB.Canvas.Handle,Rect.Left+2,Rect.Top+2,UnitDBKernel.icons[DB_IC_LOADFROMFILE+1],16,16,0,0,DI_NORMAL);
end;

procedure TManagerDB.ListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  index, i  : integer;
begin
 index:=ListBox1.ItemAtPos(MousePos,true);
 if index=-1 then
 begin
  for i:=0 to ListBox1.Items.Count-1 do
  ListBox1.Selected[i]:=false;
  Refresh1.Visible:=true;
  Restore1.Visible:=false;
  Rename1.Visible:=false;
  Delete1.Visible:=false;
 end else
 begin
  Refresh1.Visible:=false;
  Restore1.Visible:=true;
  Rename1.Visible:=true;
  Delete1.Visible:=true;
 end;
 if index<>-1 then
 ListBox1.Selected[index]:=true else PopupMenu5.Tag:=0;
 PopupMenu5.Tag:=index;
 PopupMenu5.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
end;

procedure TManagerDB.Delete1Click(Sender: TObject);
var
  FileName, CurrentFile : String;
begin
 if MessageBoxDB(Handle,Format(TEXT_MES_DELETE_DB_BACK_UP_CONFIRM_F,[FBackUpFiles[PopupMenu5.Tag]]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)=ID_OK then
 begin
  FileName:=FBackUpFiles[PopupMenu5.Tag];
  CurrentFile:=FileName;
  try
   DeleteFile(CurrentFile);
  except
  end;
  CurrentFile:=ChangeFileExt(CurrentFile,'.mb');
  try
   DeleteFile(CurrentFile);
  except
  end;
  CurrentFile:=GroupsTableFileNameW(FileName);
  try
   DeleteFile(CurrentFile);
  except
  end;
  CurrentFile:=ChangeFileExt(CurrentFile,'.mb');
  try
   DeleteFile(CurrentFile);
  except
  end;
  ReadBackUps;
 end;
end;

procedure TManagerDB.Refresh1Click(Sender: TObject);
begin
 ReadBackUps;
end;

procedure TManagerDB.Rename1Click(Sender: TObject);
var
  FileName, Dir : String;
  NewFileName : String;
  FN1, FN2, FN3, FN4, NFN1, NFN2, NFN3, NFN4 : string;
begin
 FileName:=GetFileNameWithoutExt(FBackUpFiles[PopupMenu5.Tag]);
 Dir:=GetDirectory(FBackUpFiles[PopupMenu5.Tag]);
 FormatDir(Dir);
 NewFileName:=FileName;
 if PromtString(TEXT_MES_NEW_NAME,TEXT_MES_ENTER_NEW_NAME,NewFileName) then
 begin
  if not ValidDBPath(Dir+NewFileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   exit;
  end;
  FN1:=Dir+FileName+'.db';
  FN2:=Dir+FileName+'.mb';
  FN3:=Dir+FileName+'G.db';
  FN4:=Dir+FileName+'G.mb';
  NFN1:=Dir+NewFileName+'.db';
  NFN2:=Dir+NewFileName+'.mb';
  NFN3:=Dir+NewFileName+'G.db';
  NFN4:=Dir+NewFileName+'G.mb';
  if FileExists(NFN1) or FileExists(NFN2) or FileExists(NFN3) or FileExists(NFN4) then
  begin
   MessageBoxDB(Handle,TEXT_MES_FILE_EXISTS_NO_ACTION,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   exit;
  end;
  RenameFile(FN1,NFN1);
  RenameFile(FN2,NFN2);
  RenameFile(FN3,NFN3);
  RenameFile(FN4,NFN4);
  ReadBackUps;
 end;
end;

procedure TManagerDB.Restore1Click(Sender: TObject);
begin
 if MessageBoxDB(Handle,Format(TEXT_MES_RESTORE_DB_CONFIRM_F,[FBackUpFiles[PopupMenu5.Tag]]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)=ID_OK then
 begin
  DBkernel.WriteBool('StartUp','Restore',True);
  DBkernel.WriteString('StartUp','RestoreFile',FBackUpFiles[PopupMenu5.Tag]);
 end;
end;

procedure TManagerDB.InitializeQueryList;
var
  i, w, h : integer;
  WorkQuery : TDataSet;
  _sqlexectext : string;
  b : TBitmap;
  FormProgress : TProgressActionForm;
  c: integer;
begin
 LoadingList:=true;
 ListBox2.Enabled:=false;
 aGroups:=GetRegisterGroupList(true);
 SetLength(GroupBitmaps,Length(aGroups));
 for i:=0 to Length(aGroups)-1 do
 begin
  b := TBitmap.Create;
  B.Assign(aGroups[i].GroupImage);
  GroupBitmaps[i] := TBitmap.Create;
  w:=B.Width;
  h:=B.Height;
  ProportionalSize(16,16,w,h);
  GroupBitmaps[i].Height:=h;
  GroupBitmaps[i].Width:=w;
  GroupBitmaps[i].PixelFormat:=pf24bit;
  StretchCoolWTransparent(0,0,w,h,Rect(0,0,B.Width,B.Height),B,GroupBitmaps[i],128);
 end;
 LockDraw:=false;
 LastSelectedIndex:=-1;
 ListView1.DoubleBuffered:=true;
 ListView1.ControlStyle:=ListView1.ControlStyle-[csDoubleClicks];
 WorkQuery:=GetQuery;
 _sqlexectext:='Select ID from '+GetDefDBName+' order by ID';
 SetSQL(WorkQuery,_sqlexectext);

 TOpenQueryThread.Create(false,WorkQuery,DBOpened);
 FormProgress:=GetProgressWindow;
 FormProgress.OneOperation:=true;
 FormProgress.OperationCounter.Inverse:=true;
 FormProgress.OperationCounter.Text:='';
 FormProgress.OperationProgress.Inverse:=true;
 FormProgress.OperationProgress.Text:='';
 FormProgress.SetAlternativeText(TEXT_MES_WAINT_DB_MANAGER);
 i:=0;
 FormProgress.Show;
 FormProgress.MaxPosCurrentOperation:=100;   
 Repeat
  Inc(i);
  if i=100 then
  begin
   i:=0;
  end;
  FormProgress.xPosition:=i;
  Delay(5);
 Until not DBInOpening;

 WorkQuery.First;
 SetLength(IDs,WorkQuery.RecordCount);
 SetLength(aData,WorkQuery.RecordCount);
 ListView1.Items.BeginUpdate;
 c:=0;
 for i:=1 to WorkQuery.RecordCount do
 with ListView1.Items.Add do
 begin
  aData[i-1]:=nil;
  if i mod 50=0 then
  begin
   Application.ProcessMessages;
   inc(c);
   if c>100 then c:=0;
   FormProgress.xPosition:=c;
  end;

  IDs[i-1]:=WorkQuery.FieldByName('ID').AsInteger;
  WorkQuery.Next;
 end;
 FreeDS(WorkQuery);   
 ListView1.Items.EndUpdate;
 
 FormProgress.Release;
 if UseFreeAfterRelease then
 FormProgress.Free;

 if ListView1.Items.Count>0 then
 begin
  LastSelected:=ListView1.Items[0];
  LastSelected.Selected:=true;
  ListView1.ItemFocused:=ListView1.Items[0];
  Self.LastSelectedIndex:=0;
 end;
 LoadingList:=false; 
 ListBox2.Enabled:=true;
end;

procedure TManagerDB.ListView1AdvancedCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
var
  r2 : TRect;
  Caption : string;
  aRect : TRect;
  j, i : integer;
  G : TGroups;
Const
  DrawTextOpt = DT_NOPREFIX+DT_CENTER+DT_WORDBREAK+DT_EDITCONTROL;
begin
 SetLength(G,0);
 if Item.Index>=Length(aData) then exit;
 if SubItem<0 then SubItem:=-SubItem;
 if LockDraw then exit;
 if SubItem=1 then
 begin
  r2 := Item.DisplayRect(drLabel);
  Sender.Canvas.Brush.Style:=bsSolid;
  if Item.Selected and DefaultDraw then
  begin
   Sender.Canvas.Brush.Color:=Theme_ListSelectColor;//ColorDarken(Theme_ListColor);//$AAAAFF;
   Sender.Canvas.Pen.Color:=Theme_ListSelectColor;//ColorDarken(Theme_ListColor);//$AAAAFF;
   ListView_GetSubItemRect(ListView1.Handle,Item.Index,10,0,@aRect);
   ListView1.Canvas.Rectangle(0,r2.Top,aRect.Right,r2.Bottom);
  end else
  begin
  if Odd(Item.Index) then
  begin
   Sender.Canvas.Brush.Color:=ColorDarken(Theme_ListColor);//$EEEEEE;
   Sender.Canvas.Pen.Color:=ColorDarken(Theme_ListColor);//$EEEEEE;
   Sender.Canvas.Rectangle(0,r2.Top,Sender.Width,r2.Bottom);
  end else
  begin
   Sender.Canvas.Brush.Color:=Theme_ListColor;//$FFFFFF;
   Sender.Canvas.Pen.Color:=Theme_ListColor;//$FFFFFF;
   Sender.Canvas.Rectangle(0,r2.Top,Sender.Width,r2.Bottom);
  end;
  end;
  Caption:=IntToStr(IDs[Item.Index]);
  ListView_GetSubItemRect(ListView1.Handle,Item.Index,SubItem,0,@aRect);
  r2 := Item.DisplayRect(drBounds);
  r2:=Rect(r2.Left,r2.Top,aRect.Left,aRect.Bottom);
  r2.Top:=r2.Top+2;
  DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), r2, DrawTextOpt);
//  DD:=true;
 end;
 Sender.Canvas.Brush.Style:=bsClear;
 ListView_GetSubItemRect(ListView1.Handle,Item.Index,SubItem,0,@aRect);
 Sender.Canvas.Pen.Color:=ColorDarken(Theme_MemoEditFontColor);//$DDDDDD;
 Sender.Canvas.MoveTo(aRect.Left,aRect.Top);
 Sender.Canvas.LineTo(aRect.Left,aRect.Bottom);
 if aData[Item.Index]=nil then
  GetData(Item.Index);
  
 if aData[Item.Index]=nil then exit;

 Case SubItem of
 1 :
 begin
 end;
 2 :
 begin
  ListView1.Canvas.Font.Color:=$808080;
  aRect.Top:=aRect.Top+2;
  DrawText(Sender.Canvas.Handle, PChar(PListData(aData[Item.Index])^.KeyWords), Length(PListData(aData[Item.Index])^.KeyWords), aRect, DrawTextOpt);
  ListView1.Canvas.Font.Color:=$0;
 end;
 3 :
 begin
  ListView1.Canvas.Font.Color:=$FF8080;
  aRect.Top:=aRect.Top+2;
  DrawText(Sender.Canvas.Handle, PChar(PListData(aData[Item.Index])^.Comment), Length(PListData(aData[Item.Index])^.Comment), aRect, DrawTextOpt);
  ListView1.Canvas.Font.Color:=$0;
 end;
 7 :
 begin
  G:=EncodeGroups(PListData(aData[Item.Index])^.Groups);
  aRect.Top:=aRect.Top+2;
  for i:=0 to Min(6,Length(G))-1 do
  for j:=0 to Length(aGroups)-1 do
  begin
   if aGroups[j].GroupCode=G[i].GroupCode then
   begin
    Sender.Canvas.Draw(aRect.Left+2+i*18,aRect.Top+(aRect.Bottom-aRect.Top) div 2 - GroupBitmaps[j].Height div 2,GroupBitmaps[j]);
    Break;
   end;
  end;
 end;
 8 :
 begin
  aRect.Top:=aRect.Top+2;
  if PListData(aData[Item.Index])^.IsDate then
  begin
   Caption:=FormatDateTime('yyyy.mm.dd',PListData(aData[Item.Index])^.Date);
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
  end else
  begin
   ListView1.Canvas.Font.Color:=$808080;
   Caption:='нет';
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
   ListView1.Canvas.Font.Color:=$0;
  end;
 end;
 9 :
 begin
  aRect.Top:=aRect.Top+2;
  if PListData(aData[Item.Index])^.IsTime then
  begin
   Caption:=FormatDateTime('hh.mm.ss',PListData(aData[Item.Index])^.Time);
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
  end else
  begin
   ListView1.Canvas.Font.Color:=$808080;
   Caption:='нет';
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
   ListView1.Canvas.Font.Color:=$0;
  end;
 end;
 10 :
 begin
  Caption:=PListData(aData[Item.Index])^.FileSize;
  aRect.Top:=aRect.Top+2;
  DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
 end;
 4 :
 begin
  aRect.Top:=aRect.Top+1;
  if PListData(aData[Item.Index])^.Rating>0 then
  begin
   DrawIconEx(Sender.Canvas.Handle,aRect.Left+(aRect.Right-aRect.Left) div 2-8,aRect.Top,UnitDBKernel.icons[PListData(aData[Item.Index])^.Rating+DB_IC_RATING_1],16,16,0,0,DI_NORMAL);
  end;
  ListView_GetSubItemRect(ListView1.Handle,Item.Index,1,0,@aRect);
  Caption:=PListData(aData[Item.Index])^.FileName;
  aRect.Top:=aRect.Top+2;
  if PListData(aData[Item.Index])^.Include then
  begin
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
  end else
  begin
   ListView1.Canvas.Font.Color:=$808080;
   DrawText(Sender.Canvas.Handle, PChar(Caption), Length(Caption), aRect, DrawTextOpt);
   ListView1.Canvas.Font.Color:=$0;
  end;

 end;
 5 :
  begin
   if PListData(aData[Item.Index])^.Rotate>0 then
   begin
    aRect.Top:=aRect.Top+1;
    DrawIconEx(Sender.Canvas.Handle,aRect.Left+(aRect.Right-aRect.Left) div 2-8,aRect.Top,UnitDBKernel.icons[PListData(aData[Item.Index])^.Rotate+DB_IC_ROTETED_0+1],16,16,0,0,DI_NORMAL);
   end;
  end;
 6 :
 begin
  if PListData(aData[Item.Index])^.Access=1 then
  begin
   aRect.Top:=aRect.Top+1;
   DrawIconEx(Sender.Canvas.Handle,aRect.Left+(aRect.Right-aRect.Left) div 2-8,aRect.Top,UnitDBKernel.icons[DB_IC_PRIVATE+1],16,16,0,0,DI_NORMAL);
  end;
 end;
 end;
 DefaultDraw:=false;
end;

procedure TManagerDB.GetData(Index: integer);
var
  aListData : PListData;
  i, j, n : integer;
  WorkQuery : TDataSet;
  _sqlexectext, s : string;
  b : boolean;
  l : integer;
begin
 _sqlexectext:='Select ID, FFileName, Rating, Comment, Rotated, Access, KeyWords, Groups, Links, DateToAdd, aTime, IsDate, IsTime, FileSize, Include from '+GetDefDBName;
 b:=true;
 _sqlexectext:=_sqlexectext+' where ID in (';
 for i:=-30 to 40 do
 begin
  if Index+i<0 then continue;
  if ListView1.Items.Count<=Index+i then break;
  if aData[Index+i]=nil then
  begin
   if b then _sqlexectext:=_sqlexectext+IntToStr(IDs[Index+i]) else
   _sqlexectext:=_sqlexectext+','+IntToStr(IDs[Index+i]);
   b:=false;
  end;
 end;
 if b then exit;
 WorkQuery:=GetQuery;
 _sqlexectext:=_sqlexectext+')';
 SetSQL(WorkQuery,_sqlexectext);
 WorkQuery.Open;
 WorkQuery.First;
 for i:=0 to WorkQuery.RecordCount-1 do
 begin
  try
   l:=WorkQuery.FieldByName('ID').AsInteger;
   n:=MaxInt;
   for j:=-30 to 40 do
   if Index+j>=0 then
   if Index+j<=ListView1.Items.Count then
   if IDs[Index+j]=l then
  begin
   n:=Index+j;
   break;
  end;
  if n=MaxInt then Continue;
  GetMem(aListData,SizeOf(TListData));
  aData[n]:=Pointer(aListData);
  aListData^.ID:=WorkQuery.FieldByName('ID').AsInteger;

  aListData^.Exists:=0;

  s:=Mince(WorkQuery.FieldByName('FFileName').AsString,30);
  l:=Length(s);
  GetMem(aListData^.FileName,Length(s)+1);
  aListData^.FileName[L]:=#0;
  lstrcpyn(aListData^.FileName,PChar(s),L+1);

  s:=WorkQuery.FieldByName('KeyWords').AsString;
  l:=Length(s);
  GetMem(aListData^.KeyWords,Length(s)+1);
  aListData^.KeyWords[L]:=#0;
  lstrcpyn(aListData^.KeyWords,PChar(s),L+1);

  s:=WorkQuery.FieldByName('Comment').AsString;
  l:=Length(s);
  GetMem(aListData^.Comment,Length(s)+1);
  aListData^.Comment[L]:=#0;
  lstrcpyn(aListData^.Comment,PChar(s),L+1);

  aListData^.Rating:=WorkQuery.FieldByName('Rating').AsInteger;
  aListData^.Rotate:=WorkQuery.FieldByName('Rotated').AsInteger;
  aListData^.Access:=WorkQuery.FieldByName('Access').AsInteger;

  aListData^.Time:=TimeOf(WorkQuery.FieldByName('aTime').AsDateTime);
  aListData^.Date:=DateOf(WorkQuery.FieldByName('DateToAdd').AsDateTime);

  aListData^.IsTime:=WorkQuery.FieldByName('IsTime').AsBoolean;
  aListData^.IsDate:=WorkQuery.FieldByName('IsDate').AsBoolean;

  aListData^.Include:=WorkQuery.FieldByName('Include').AsBoolean;

  s:=WorkQuery.FieldByName('Groups').AsString;
  l:=Length(s);
  GetMem(aListData^.Groups,Length(s)+1);
  aListData^.Groups[L]:=#0;
  lstrcpyn(aListData^.Groups,PChar(s),L+1);

  s:=SizeInTextA(WorkQuery.FieldByName('FileSize').AsInteger);
  l:=Length(s);
  GetMem(aListData^.FileSize,Length(s)+1);
  aListData^.FileSize[L]:=#0;
  lstrcpyn(aListData^.FileSize,PChar(s),L+1);

  WorkQuery.Next;
  except
  end;
 end;
 FreeDS(WorkQuery);
end;

procedure TManagerDB.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  i : integer;
  DD : boolean;
  LastLock : boolean;
begin
 LastLock:=LockDraw;
 LockDraw:=false;
 if Selected then
 begin
  DD:=true;
  for i:=1 to 10 do
  ListView1AdvancedCustomDrawSubItem(ListView1,item,i,[],cdPrePaint,DD);
  LastSelectedIndex:=Item.Index;
 end else
 begin
  DD:=false;
  if LastSelectedIndex<>-1 then
  for i:=1 to 10 do
  ListView1AdvancedCustomDrawSubItem(ListView1,ListView1.Items[LastSelectedIndex],i,[],cdPrePaint,DD);
 end;
 LockDraw:=LastLock;
end;

function GetSubItemIndexByPoint(ListView : TListView;Item : TListItem; Point : TPoint) : integer;
var
  aRect : TRect;
  SubItem : integer;
begin
 Result:=0;
 for SubItem:=1 to 10 do
 begin
  ListView_GetSubItemRect(ListView.Handle,Item.Index,SubItem,0,@aRect);
  if PtInRect(aRect,Point) then
  begin
   Result:=SubItem;
   Break;
  end;
 end;
end;

function SpilitWords(S : string) : TArrayOfString;
var
  i, j : integer;
  pi_ : PInteger;

 procedure DelSpacesA(var S : string);
 var
   i : integer;
 begin
  for i:=Length(s) downto 1 do
  if s[i]=' ' then Delete(s,i,1);
 end;


begin
 SetLength(Result,0);
 s:=' '+s+' ';
 pi_:=@i;
 for i:=1 to length(s)-1 do
 begin
  if i+1>length(s)-1 then break;
  if (s[i]=' ') and (s[i+1]<>' ') then
  for j:=i+1 to length(s) do
  if (s[j]=' ') or (j=length(s)) then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:=Copy(s,i+1,j-i-1);
   pi_^:=j-1;
   Break;
  end;
 end;
 for i:=0 to Length(Result)-1 do
 begin
  DelSpacesA(Result[i]);
 end;

end;

procedure TManagerDB.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  p : TPoint;
  Item : TListItem;
  i, j : integer;
  Words : TArrayOfString;
  MenuItem : TMenuItem;
  G : TGroups;
  B, Bit, TempB : TBitmap;
  w, h : integer;

  Date,Time  : TDateTime;
  IsDate,IsTime, Changed : boolean;

  FQuery : TDataSet;
begin
 Words:=nil;
 if Msg.hwnd=ListView1.Handle then
 begin
  if (msg.message=WM_LBUTTONDBLCLK) or (msg.message=WM_RBUTTONDBLCLK) then
  begin
   ListView1.SetFocus;
   if (msg.message=WM_RBUTTONDBLCLK) then
   begin
    msg.message:=0;
    Handled:=true;
    exit;
   end;
   msg.message:=0;
   Handled:=true;
   GetCursorPos(p);
   p:=ListView1.ScreenToClient(p);
   Item:=GetListViewItemAt(p.y);//ListView1.GetItemAt(10,p.y);
   if Item=nil then exit;
   SetLength(G,0);
   if ShiftKeyDown then
   CopyFullRecordInfo(PListData(aData[Item.Index])^.ID);
   if GetSubItemIndexByPoint(ListView1,Item,p)=2 then
   begin
    Words:=SpilitWords(PListData(aData[Item.Index])^.KeyWords);
    PopupMenuKeyWords.Items.Clear;
    for i:=0 to Length(Words)-1 do
    begin
     MenuItem := TMenuItem.Create(PopupMenuKeyWords);
     MenuItem.Caption:=Words[i];
     PopupMenuKeyWords.Items.Add(MenuItem);
    end;
    p:=ListView1.ClientToScreen(p);
    PopupMenuKeyWords.Popup(p.x,p.y);
   end;
   if GetSubItemIndexByPoint(ListView1,Item,p)=4 then
   begin
    PopupMenuRating.Tag:=Item.Index;
    p:=ListView1.ClientToScreen(p);
    for i:=0 to 5 do
    if PListData(aData[Item.Index])^.Rating=i then
    (FindComponent('N'+IntToStr(i)+'1') as TMenuItem).Default:=true else
    (FindComponent('N'+IntToStr(i)+'1') as TMenuItem).Default:=false;
    PopupMenuRating.Popup(p.x,p.y);
   end;
   if GetSubItemIndexByPoint(ListView1,Item,p)=5 then
   begin
    PopupMenuRotate.Tag:=Item.Index;
    p:=ListView1.ClientToScreen(p);
    for i:=0 to 3 do
    if PListData(aData[Item.Index])^.Rotate=i then
    (FindComponent('R0'+IntToStr(i+1)) as TMenuItem).Default:=true else
    (FindComponent('R0'+IntToStr(i+1)) as TMenuItem).Default:=false;
    PopupMenuRotate.Popup(p.x,p.y);
   end;

   if (GetSubItemIndexByPoint(ListView1,Item,p)=8) or (GetSubItemIndexByPoint(ListView1,Item,p)=9) then
   begin
    Date:=PListData(aData[Item.Index])^.Date;
    Time:=PListData(aData[Item.Index])^.Time;
    IsTime:=PListData(aData[Item.Index])^.IsTime;
    IsDate:=PListData(aData[Item.Index])^.IsDate;
    ChangeDate(Date,IsDate,Changed,Time,IsTime);
    if Changed then
    begin
     Item:=GetListViewItemAt(p.y);
     PListData(aData[Item.index])^.Date:=Date;
     PListData(aData[Item.index])^.Time:=Time;
     PListData(aData[Item.index])^.IsTime:=IsTime;
     PListData(aData[Item.index])^.IsDate:=IsDate;

     FQuery := GetQuery;
     SetSQL(FQuery,Format('Update '+GetDefDBname+' Set DateToAdd = :Date, aTime = :Time, IsTime = :IsTime, IsDate = :IsDate Where ID = %d',[PListData(aData[Item.index])^.ID]));
     SetDateParam(FQuery,0,Date);
     SetDateParam(FQuery,1,Time);  
     SetBoolParam(FQuery,2,IsTime);
     SetBoolParam(FQuery,3,IsDate);
     ExecSQL(FQuery);
     FreeDS(FQuery);
     ListView1.Repaint;

    end;
   end;

   if GetSubItemIndexByPoint(ListView1,Item,p)=7 then
   begin
    PopupMenuGroups.Tag:=Item.Index;
    p:=ListView1.ClientToScreen(p);
    G:=EncodeGroups(PListData(aData[Item.Index])^.Groups);
    ImageListPopupGroups.Clear;
    PopupMenuGroups.Items.Clear;
    for i:=0 to Length(G)-1 do
    begin
     for j:=0 to Length(aGroups)-1 do
     begin
      if aGroups[j].GroupCode=G[i].GroupCode then
      begin
       b:=TBitmap.Create;
       b.PixelFormat:=pf24bit;
       b.Assign(aGroups[j].GroupImage);
       Bit:=TBitmap.Create;
       Bit.PixelFormat:=pf24bit;
       Bit.Width:=16;
       Bit.Height:=16;
       Bit.Canvas.Brush.Color:=Graphics.clMenu;
       Bit.Canvas.Pen.Color:=Graphics.clMenu;
       Bit.Canvas.Rectangle(0,0,16,16);
       w:=B.Width;
       h:=B.Height;
       ProportionalSize(16,16,w,h);
       TempB:=TBitmap.Create;
       TempB.PixelFormat:=pf24bit;
       TempB.Height:=h;
       TempB.Width:=w;
       DoResize(w,h,b,TempB);
       Bit.Canvas.Draw(8-TempB.Width div 2,8-TempB.Height div 2,TempB);
       TempB.Free;
       b.Free;
       ImageListPopupGroups.Add(Bit,nil);
       Bit.Free;
       MenuItem:=TMenuItem.Create(PopupMenuGroups);
       MenuItem.Caption:=G[i].GroupName;
       MenuItem.ImageIndex:=ImageListPopupGroups.Count-1;
       PopupMenuGroups.Items.Add(MenuItem);
       Break;
      end;
     end;
    end;
    MenuItem:=TMenuItem.Create(PopupMenuGroups);
    MenuItem.Caption:='-';
    PopupMenuGroups.Items.Add(MenuItem);

    MenuItem:=TMenuItem.Create(PopupMenuGroups);
    MenuItem.Caption:=TEXT_MES_EDIT;
    Bit:=TBitmap.Create;
    Bit.PixelFormat:=pf24bit;
    Bit.Width:=16;
    Bit.Height:=16;
    Bit.Canvas.Brush.Color:=Graphics.clMenu;
    Bit.Canvas.Pen.Color:=Graphics.clMenu;
    Bit.Canvas.Rectangle(0,0,16,16);
    DrawIconEx(Bit.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
    ImageListPopupGroups.Add(Bit,nil);
    Bit.Free;

    MenuItem.ImageIndex:=ImageListPopupGroups.Count-1;


    MenuItem.OnClick:=EditGroupsMenuClick;
    PopupMenuGroups.Items.Add(MenuItem);
    PopupMenuGroups.Popup(p.x,p.y);
   end;
  end;

  if (msg.message=WM_LBUTTONDOWN) or (msg.message=WM_RBUTTONDOWN) then
  begin
   ListView1.SetFocus;
   msg.message:=0;
   Handled:=true;
   GetCursorPos(p);
   p:=ListView1.ScreenToClient(p);
   Item:=ListView1.GetItemAt(10,p.y);
   if Item=nil then
   if LastSelected<>nil then
   begin
    LastSelected.Selected:=true;
    ListView1.ItemFocused:=LastSelected;
    exit;
   end;
   LockDraw:=true;
   if Item<>nil then
   Item.Selected:=true;
   LastSelected:=Item;
   LockDraw:=false;
   ListView1.ItemFocused:=Item;
  end;
 end;
end;

procedure TManagerDB.N51Click(Sender: TObject);
var
  index, i, NewRating : integer;
  s : string;
  FQuery : TDataSet;
begin
 index:=PopupMenuRating.Tag;
 s:=(Sender as TMenuItem).Caption;
 for i:=Length(s) downto 1 do
 if s[i]='&' then Delete(s,i,1);
 NewRating:=StrToIntDef(s,0);
 PListData(aData[index])^.Rating:=NewRating;
 FQuery := GetQuery;
 SetSQL(FQuery,Format('Update '+GetDefDBname+' Set Rating = %d Where ID = %d',[NewRating,PListData(aData[index])^.ID]));
 ExecSQL(FQuery);
 FreeDS(FQuery);
 ListView1.Repaint;
end;

procedure TManagerDB.R04Click(Sender: TObject);
var
  index, NewRotate : integer;
  FQuery : TDataSet;
begin
 index:=PopupMenuRotate.Tag;
 NewRotate:=(Sender as TMenuItem).Tag;
 PListData(aData[index])^.Rotate:=NewRotate;
 FQuery := GetQuery;
 SetSQL(FQuery,Format('Update '+GetDefDBname+' Set Rotated = %d Where ID = %d',[NewRotate,PListData(aData[index])^.ID]));
 ExecSQL(FQuery);
 FreeDS(FQuery);
 ListView1.Repaint;
end;

procedure TManagerDB.ListView1WindowProc(var Message: TMessage);
begin

 if Message.msg=78 then
 begin
  if TWMNotify(Message).NMHdr.code=-530 then
  begin
   Message.msg:=0;
   exit;
  end;
 end;
 OldWNDProc(Message);
end;

procedure TManagerDB.EditGroupsMenuClick(Sender: TObject);
Var
  EventInfo : TEventValues;
  S, KeyWords : String;
  index : integer;
  Groups : TGroups;
  Query : TDataSet;
begin
 if ListView1.Selected=nil then exit;
 index:=ListView1.Selected.Index;
 KeyWords:=PListData(aData[index])^.KeyWords;
 S:=PListData(aData[index])^.Groups;
 Groups:=EnCodeGroups(S);
 DBChangeGroups(Groups,KeyWords);                
 if (S=PListData(aData[index])^.Groups) and (KeyWords=PListData(aData[index])^.KeyWords) then exit;
 S:=CodeGroups(Groups);
 SetPCharString(PListData(aData[index])^.KeyWords,KeyWords);
 SetPCharString(PListData(aData[index])^.Groups,S);
 ListView1.Repaint;

 Query:=GetQuery;
 SetSQL(Query,'Update '+GetDefDBName+' SET KeyWords = :KeyWords, Groups = :KeyWords WHERE ID = :ID');
 SetStrParam(Query,0,KeyWords);
 SetStrParam(Query,1,S);
 SetIntParam(Query,2,PListData(aData[index])^.ID);
 ExecSQL(Query);
 FreeDS(Query);

 EventInfo.Groups:=S;
 EventInfo.KeyWords:=KeyWords;
 DBKernel.DoIDEvent(Self,PListData(aData[index])^.ID,[EventID_Param_Groups,EventID_Param_KeyWords],EventInfo);
end;

procedure TManagerDB.CMMOUSEEnter(var Message: TWMNoParams);
begin
 if FormManagerHint<>nil then
 if Active then
 if not FormManagerHint.Visible then
 ShowWindow(FormManagerHint.Handle,SW_SHOWNOACTIVATE);
end;

procedure TManagerDB.CMMOUSELEAVE(var Message: TWMNoParams);
begin
 if FormManagerHint<>nil then
 ShowWindow(FormManagerHint.Handle,SW_HIDE);
end;

procedure TManagerDB.OnMove(var Msg: TWMMove);
begin
 if FormManagerHint<>nil then
 if Active then
 if not FormManagerHint.Visible then
 ShowWindow(FormManagerHint.Handle,SW_SHOWNOACTIVATE);
end;

procedure TManagerDB.ListView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  p :TPoint;
  item : TListItem;
  DS : TDataSet;
  JPG : TJpegImage;
  B : TBitmap;
  pass : string;
begin
 if FormManagerHint=nil then
 Application.CreateForm(TFormManagerHint, FormManagerHint);
 if FormManagerHint<>nil then
 begin
  item:=GetListViewItemAt(y);//ListView1.GetItemAt(10,y);
  if item=nil then begin ShowWindow(FormManagerHint.Handle,SW_HIDE); exit; end;
  if item.Index=SI then exit;
  SI:=item.Index;
  p.x:=0;
  p.y:=y+18;
  p:=ListView1.ClientToScreen(p);
  FormManagerHint.Left:=p.x;
  if Top+Height-15<p.y+FormManagerHint.Height then
  FormManagerHint.Top:=p.y-FormManagerHint.Height-18 else
  FormManagerHint.Top:=p.y;
  if ListView1.Items.Count<=Item.Index then exit;
  DS:=GetQuery;
  if aData[Item.Index]=nil then
  begin
   ShowWindow(FormManagerHint.Handle,SW_HIDE);
   FreeDS(DS);
   exit;
  end;
  try
   SetSQL(DS,'Select FFileName, Thum from '+GetDefDBName+' where id = '+IntToStr(PListData(aData[Item.Index])^.ID));
   DS.Open;
  except
   ShowWindow(FormManagerHint.Handle,SW_HIDE);
   FreeDS(DS);
   exit;
  end;
  if DS.RecordCount=0 then
  begin
   ShowWindow(FormManagerHint.Handle,SW_HIDE);
   FreeDS(DS);
   exit;
  end;
  if FormManagerHint.Image1.Picture.Bitmap=nil then
  begin
   FormManagerHint.Image1.Picture.Bitmap:=TBitmap.Create;
   FormManagerHint.Image1.Picture.Bitmap.PixelFormat:=pf24bit;
  end;
  if ValidCryptBlobStreamJPG(DS.FieldByName('Thum')) then
  begin
   pass:=DBKernel.FindPasswordForCryptBlobStream(DS.FieldByName('Thum'));
   if pass='' then
   begin
    showwindow(FormManagerHint.Handle,SW_HIDE);
    FreeDS(DS);
    exit;
   end else
   begin
    JPG := DeCryptBlobStreamJPG(DS.FieldByName('Thum'),pass) as TJPegImage;
   end;
  end else
  begin
   JPG := TJpegImage.Create;
   JPG.Assign(DS.FieldByName('Thum'));
  end;

   B:=FormManagerHint.image1.Picture.Graphic as TBitmap;
   B.Width:=ThSize;
   B.Height:=ThSize;
   B.Canvas.Pen.Color:=Theme_MainColor;
   B.Canvas.Brush.Color:=Theme_MainColor;
   B.Canvas.Rectangle(0,0,B.Width,B.Height);
   B.Canvas.Pen.Color:=Theme_ListColor;
   B.canvas.Draw(ThSize div 2 - JPG.Width div 2,ThSize div 2 - JPG.Height div 2,JPG);
   JPG.Free;
   ApplyRotate(B, PListData(aData[Item.Index])^.Rotate);
   DrawAttributes(B,ThSize,PListData(aData[Item.Index])^.Rating,PListData(aData[Item.Index])^.Rotate, PListData(aData[Item.Index])^.Access,DS.FieldByName('FFileName').AsString,ValidCryptBlobStreamJPG(DS.FieldByName('Thum')),PListData(aData[Item.Index])^.Exists,PListData(aData[Item.Index])^.ID);
   FreeDS(DS);
  if Active then
  begin
   FormManagerHint.DoubleBuffered:=true;
   Application.ProcessMessages;
   showwindow(FormManagerHint.Handle,SW_SHOWNOACTIVATE);
  end;
 end;
end;

procedure TManagerDB.PackTabelLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_PACKING_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 DBkernel.WriteBool('StartUp','Pack',True);
end;

procedure TManagerDB.ExportTableLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_EXPORT_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 begin
  if ExportForm=nil then
  begin
   Application.CreateForm(TExportForm, ExportForm);
   ExportForm.Execute;
   ExportForm.Release;
   ExportForm.Free;
   ExportForm:=nil;
  end else
  begin
   ExportForm.Show;
  end;
 end;
end;

procedure TManagerDB.ImportTableLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_IMPORT_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 begin
  if ImportDataBaseForm=nil then
  Application.CreateForm(TImportDataBaseForm, ImportDataBaseForm);
  ImportDataBaseForm.Execute;
 end;
end;

procedure TManagerDB.RecreateIDExLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_RECREATE_IDEX_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 DBkernel.WriteBool('StartUp','RecreateIDEx',True);
end;

procedure TManagerDB.ScanforBadLinksLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_SHOW_BAD_LINKS_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 DBkernel.WriteBool('StartUp','ScanBadLinks',True);
end;

procedure TManagerDB.BackUpDBLinkClick(Sender: TObject);
begin
 if ID_OK<>MessageBoxDB(Handle,TEXT_MES_BACK_UP_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then exit;
 begin
  if GetDBType=DB_TYPE_MDB then
  begin
   DBkernel.WriteBool('StartUp','BackUp',True);
   MessageBoxDB(Handle,TEXT_MES_BACK_UPING_WILL_BEGIN_AT_NEXT_STARTUP,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
  end;
 end;
end;

procedure TManagerDB.CleaningLinkClick(Sender: TObject);
begin
 if DBCleaningForm=nil then
 Application.CreateForm(TDBCleaningForm, DBCleaningForm);
 DBCleaningForm.Show;
end;

procedure TManagerDB.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
Var
  MenuInfo : TDBPopupMenuInfo;
  item : TListItem;

begin
// If Button=mbRight then
 begin
  //item:=ListView1.GetItemAt(10,MousePos.y);
  item:=GetListViewItemAt(MousePos.y);
  if item=nil then exit;
  MenuInfo:=GetMenuInfoByID(PListData(aData[item.Index])^.ID); //DBPopupMenuInfoOne(WorkTable.FieldByName('FFileName').AsString,WorkTable.FieldByName('Comment').AsString,WorkTable.FieldByName('Groups').AsString,WorkTable.FieldByName('ID').AsInteger,WorkTable.FieldByName('FileSize').AsInteger,WorkTable.FieldByName('Rotated').AsInteger,WorkTable.FieldByName('Rating').AsInteger,WorkTable.FieldByName('Access').AsInteger,WorkTable.FieldByName('DateToAdd').AsDateTime,WorkTable.FieldByName('IsDate').AsBoolean,WorkTable.FieldByName('IsTime').AsBoolean,WorkTable.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(WorkTable.FieldByName('thum')),WorkTable.FieldByName('keyWords').AsString,true,WorkTable.FieldByName('Include').AsBoolean,WorkTable.FieldByName('Links').AsString);
  if Length(MenuInfo.ItemFileNames_)=1 then
  DoProcessPath(MenuInfo.ItemFileNames_[0]);
  MenuInfo.IsPlusMenu:=False;
  MenuInfo.IsListItem:=False;
  MenuInfo.IsDateGroup:=True;
  MenuInfo.IsAttrExists:=false;
  TDBPopupMenu.Instance.Execute(ListView1.ClientToScreen(MousePos).x,ListView1.ClientToScreen(MousePos).y,MenuInfo);
 end;
end;

procedure TManagerDB.DeleteItemWithID(ID: integer);
var
  i : integer;
  j, l, si : integer;
begin
//PListData(aData[Item.Index])^.Access
 for i:=0 to Length(IDs)-1 do
 if IDs[i]=ID then
 begin
  l:=ListView1.Items.Count;

 si:=ListView1.Selected.Index;
 if si>=0 then
 begin
  ListView1.Selected:=nil;

  ListView1.Items.BeginUpdate;
  ListView1.Items.Delete(i);
//  ListView1.Items[i].Free;
  ListView1.Items.EndUpdate;

  if si>=ListView1.Items.Count then si:=ListView1.Items.Count-1;
  if si>=0 then
  begin
   ListView1.Items[si].Selected:=true;
   ListView1.ItemFocused:=ListView1.Items[si];
  end;
 end;

  l:=ListView1.Items.Count*0+l; 
  for j:=i to l-2 do
  begin
   IDs[j]:=IDs[j+1];
   aData[j]:=aData[j+1];
  end;
  SetLength(IDs,Length(IDs)-1);
  SetLength(aData,Length(aData)-1);
  Break;
 end;
 ListView1.Repaint;
end;

procedure TManagerDB.ListBox2DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB : TListBox;
  aDBName : string;
begin
 LB:=(Control as TListBox);
 LB.Canvas.FillRect(Rect);
 aDBname:=ExtractFileName(DBKernel.DBs[Index].FileName);
 if AnsiLowerCase(dbname)=AnsiLowerCase(DBKernel.DBs[Index].FileName) then
 LB.Canvas.Font.Style:=[fsBold] else LB.Canvas.Font.Style:=[];
 LB.Canvas.TextOut(Rect.Left+21, Rect.Top+3,LB.Items[Index]+'  ['+aDBname+']');
 DBImageList.Draw(LB.Canvas,Rect.Left+2,Rect.Top+2,Index,true);
end;

procedure TManagerDB.Button3Click(Sender: TObject);
var
  DBFile : TPhotoDBFile;
begin
 DBFile:=DoChooseDBFile();
 if DBKernel.TestDB(DBFile.FileName) then
 DBKernel.AddDB(DBFile._Name,DBFile.FileName,DBFile.Icon);
 RefreshDBList;
end;

procedure TManagerDB.RefreshDBList;
var
  i : integer;
  ico : TIcon;
begin
 DBImageList.Clear;
 ListBox2.Clear;
 DBImageList.BkColor:=Theme_ListColor;
 for i:=0 to Length(DBKernel.DBs)-1 do
 begin
  ListBox2.Items.Add(DBKernel.DBs[i]._Name);
  ico:=GetSmallIconByPath(DBKernel.DBs[i].Icon);
  if ico.Empty then
  begin
   ico.Free;
   ico:=GetSmallIconByPath(Application.ExeName+',0');
  end;
  DBImageList.AddIcon(ico);
  ico.Free;
 end;
end;

procedure TManagerDB.ListBox2ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  index, i  : integer;
begin
 index:=ListBox2.ItemAtPos(MousePos,true);
 if index=-1 then
 begin
  for i:=0 to ListBox2.Items.Count-1 do
  ListBox2.Selected[i]:=false;
  exit;
 { Refresh1.Visible:=true;
  Restore1.Visible:=false;
  Rename1.Visible:=false;
  Delete1.Visible:=false;     }
 end else
 begin
{  Refresh1.Visible:=false;
  Restore1.Visible:=true;
  Rename1.Visible:=true;
  Delete1.Visible:=true;   }
 end;
 DeleteDB1.Visible:=ListBox2.Items.Count>1;
 if index<>-1 then
 ListBox2.Selected[index]:=true else PopupMenu8.Tag:=0;
 PopupMenu8.Tag:=index;
 PopupMenu8.Popup(ListBox2.ClientToScreen(MousePos).X,ListBox2.ClientToScreen(MousePos).Y);
end;

procedure TManagerDB.RenameDB1Click(Sender: TObject);
var
  NewDBName : string;
  i : integer;
begin
 NewDBName:=ListBox2.Items[PopupMenu8.Tag];
 if PromtString(TEXT_MES_NEW_NAME,TEXT_MES_ENTER_NEW_NAME_FOR_DB,NewDBName) then
 begin
  if Length(NewDBName)=0 then exit;
  for i:=1 to Length(NewDBName) do
  if NewDBName[i] in ['\','/','|'] then NewDBName[i]:=' ';
  DBKernel.RenameDB(ListBox2.Items[PopupMenu8.Tag],NewDBName);
  ListBox2.Items[PopupMenu8.Tag]:=NewDBName;
  RefreshDBList;
 end;
end;

procedure TManagerDB.SelectDB1Click(Sender: TObject);
var
  DBVersion : integer;
  DialogResult : integer;
  FileName : string;
begin
 FileName:=DBKernel.DBs[PopupMenu8.Tag].FileName;
 if DBKernel.TestDB(FileName) then
 begin
  SelectDB(FileName);
 end else
 begin
  if not FileExists(FileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_FILE_NOT_FOUND,TEXT_MES_ERROR,'',TD_BUTTON_OK,TD_ICON_ERROR);
  end else
  begin
   DBVersion:=DBKernel.TestDBEx(FileName);
   if DBVersion>0 then
   if not DBKernel.ValidDBVersion(FileName,DBVersion) then
   begin
    DialogResult:=MessageBoxDB(Handle,TEXT_MES_DB_VERSION_INVALID_CONVERT_AVALIABLE,TEXT_MES_WARNING,TEXT_MES_INVALID_DB_VERSION_INFO,TD_BUTTON_YESNO,TD_ICON_WARNING);
    if ID_OK=DialogResult then
    begin
     ConvertDB(FileName);
    end;
   end;
  end;
 end;
 RefreshDBList;
 ListBox2.Refresh;
end;

procedure TManagerDB.DeleteDB1Click(Sender: TObject);
begin
 if MessageBoxDB(Handle,Format(TEXT_MES_DO_YOU_REALLY_WANT_TO_DENELE_DB_F,[ListBox2.Items[PopupMenu8.Tag]]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)=ID_OK then
 begin
  DBKernel.DeleteDB(ListBox2.Items[PopupMenu8.Tag]);
  RefreshDBList;
 end;
end;

procedure TManagerDB.ListBox2DblClick(Sender: TObject);
var
  index  : integer;
  MousePos : TPoint;
begin
 GetCursorPos(MousePos);
 MousePos:=ListBox2.ScreenToClient(MousePos);
 index:=ListBox2.ItemAtPos(MousePos,true);
 if index>=0 then
 begin
  ChangeDBOptions(DBKernel.DBs[index]);
 end;
 RefreshDBList;
end;

procedure TManagerDB.DBOpened(Sender: TObject);
begin
 DBInOpening:=false;
end;

procedure TManagerDB.EditDB1Click(Sender: TObject);
var
  index : integer;
begin
 index:=PopupMenu8.Tag;
 ChangeDBOptions(DBKernel.DBs[index]);
 RefreshDBList;
end;

procedure TManagerDB.RecordNumberEditChange(Sender: TObject);
var
  i, n : integer;
begin
  n:=StrToIntDef(RecordNumberEdit.Text,1);
  for i:=0 to Length(aData)-1 do
  begin
   if IDs[i]>=n then
   begin
    LastSelected :=ListView1.Items[i];
    LastSelectedIndex := i;
    ListView1.Selected:=ListView1.Items[i];
    ListView1.ItemFocused:=ListView1.Items[i];
    ListView1.Selected.Focused:=true;
    ListView1.ItemIndex:=i;
    SendMessage(ListView1.Handle, LVM_ENSUREVISIBLE, i,
    MakeLong(Integer(false), 0));
    break;
   end;
  end;
 ListView1.Refresh;
end;

procedure TManagerDB.LoadDBTimerTimer(Sender: TObject);
begin
 ListView1.Items.BeginUpdate;
 LoadDBTimer.Enabled:=false;
 InitializeQueryList;
 ListView1.Items.EndUpdate;
end;

procedure TManagerDB.DublicatesLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_OPTIMIZING_DUBLICATES_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 DBkernel.WriteBool('StartUp','OptimizeDublicates',True);
end;

procedure TManagerDB.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if LoadingList then
 begin
  MessageBoxDB(Handle,TEXT_MES_LIST_DB_ITEMS_LOADING,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
  CanClose:=false;
 end;
end;

procedure TManagerDB.ConvertLinkClick(Sender: TObject);
begin
 if ID_OK=MessageBoxDB(Handle,TEXT_MES_CONVERTING_DB_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
 DBkernel.WriteBool('StartUp','ConvertDB',True);
end;

procedure TManagerDB.ChangePathLinkClick(Sender: TObject);
begin
 DoChangeDBPath;
end;

procedure TManagerDB.Showfileinexplorer1Click(Sender: TObject);
var
  Path : string;
begin
 Path:=FBackUpFiles[PopupMenu5.Tag];
 With ExplorerManager.NewExplorer(False) do
 begin
  SetOldPath(Path);
  SetPath(GetDirectory(Path));
  Show;
 end;
end;

end.
