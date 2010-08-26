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
  UnitCDMappingSupport, uConstants, uFileUtils, uDBDrawing, adodb,
  DBLoading, LoadingSign;

type
  TManagerDB = class(TForm)
    Panel2: TPanel;
    PnTop: TPanel;
    PopupMenu1: TPopupMenu;
    Label7: TLabel;
    CbSetField: TComboBox;
    Label9: TLabel;
    Edit2: TEdit;
    Label10: TLabel;
    CbWhereField1: TComboBox;
    Edit3: TEdit;
    BtnExecSQL: TButton;
    CbWhereCombinator: TComboBox;
    Edit4: TEdit;
    CbWhereField2: TComboBox;
    CbOperatorWhere1: TComboBox;
    CbOperatorWhere2: TComboBox;
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
    LbBackups: TListBox;
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
    ElvMain: TListView;
    ApplicationEvents1: TApplicationEvents;
    ImlMain: TImageList;
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
    LbDatabases: TListBox;
    BtnAddDB: TButton;
    DBImageList: TImageList;
    PopupMenu8: TPopupMenu;
    DeleteDB1: TMenuItem;
    RenameDB1: TMenuItem;
    N1: TMenuItem;
    SelectDB1: TMenuItem;
    EditDB1: TMenuItem;
    DublicatesLink: TWebLink;
    ConvertLink: TWebLink;
    ChangePathLink: TWebLink;
    N2: TMenuItem;
    Showfileinexplorer1: TMenuItem;
    dblData: TDBLoading;
    LsLoadingDB: TLoadingSign;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure CbWhereCombinatorChange(Sender: TObject);
    procedure CbWhereField1Change(Sender: TObject);
    procedure BtnExecSQLClick(Sender: TObject);
    procedure CheckSQL;
    procedure CbOperatorWhere1Change(Sender: TObject);
    procedure Lock;
    procedure UnLock;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GroupsManager1Click(Sender: TObject);
    procedure ReadBackUps;
    procedure LbBackupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LbBackupsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure InitializeQueryList;
    procedure ElvMainAdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure GetData(Index: integer);
    procedure ElvMainSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure N51Click(Sender: TObject);
    procedure R04Click(Sender: TObject);
    procedure ElvMainWindowProc(var Message: TMessage);
    procedure EditGroupsMenuClick(Sender: TObject);
    procedure ElvMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PackTabelLinkClick(Sender: TObject);
    procedure ExportTableLinkClick(Sender: TObject);
    procedure ImportTableLinkClick(Sender: TObject);
    procedure RecreateIDExLinkClick(Sender: TObject);
    procedure ScanforBadLinksLinkClick(Sender: TObject);
    procedure BackUpDBLinkClick(Sender: TObject);
    procedure CleaningLinkClick(Sender: TObject);
    procedure ElvMainContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure DeleteItemWithID(ID : integer);
    procedure LbDatabasesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BtnAddDBClick(Sender: TObject);
    procedure RefreshDBList;
    procedure LbDatabasesContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure RenameDB1Click(Sender: TObject);
    procedure SelectDB1Click(Sender: TObject);
    procedure DeleteDB1Click(Sender: TObject);
    procedure LbDatabasesDblClick(Sender: TObject);
    procedure DBOpened(Sender : TObject);
    procedure DBLoadDataPacket(DataList : TList);
    procedure EditDB1Click(Sender: TObject);
    procedure RecordNumberEditChange(Sender: TObject);
    procedure DublicatesLinkClick(Sender: TObject);
    procedure ConvertLinkClick(Sender: TObject);
    procedure ChangePathLinkClick(Sender: TObject);
    procedure Showfileinexplorer1Click(Sender: TObject);
    procedure ElvMainData(Sender: TObject; Item: TListItem);
    procedure dblDataDrawBackground(Sender: TObject; Buffer: TBitmap);
    procedure ElvMainResize(Sender: TObject);
  private
    OldWNDProc : TWndMethod;
    LastSelected : TListItem;
    LastSelectedIndex : Integer;
    LockDraw :Boolean;
    aGroups : TGroups;
    GroupBitmaps : array of TBitmap;
    FormManagerHint : TFormManagerHint;
    WorkQuery : TDataSet;
    IsLock : Boolean;
    FBackUpFiles : TStrings;
    DBCanDrag : Boolean;
    SI : Integer;
    FData : TList;
    FLoadingDataThread : TThread;
    procedure OnMove(var Msg: TWMMove); message WM_MOVE;
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMOUSEEnter(var Message: TWMNoParams); message CM_MOUSEenter;
    function GetListViewItemAt(y : integer): TListItem;
  protected
    { protected declarations }
    procedure CreateParams(VAR Params: TCreateParams); override;
    procedure ReleaseLoadingThread;
  public
    { public declarations }
    procedure LoadLanguage;
  end;

var
  ManagerDB: TManagerDB;

const FieldCount = 19;
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
     UnitMenuDateForm, UnitChangeDBPath, UnitSelectDB, uThreadLoadingManagerDB,
     UnitDBOptions, uListViewUtils;

{$R *.dfm}

function TManagerDB.GetListViewItemAt(Y : integer): TListItem;
var
  R : TRect;
  I, Index : integer;
begin
  Result := nil;
  Index := Max(0, (Y - GetListViewHeaderHeight(ElvMain)) div ImlMain.Height - 1);
  for I := Index to elvMain.Items.Count - 1 do
  begin
    R := elvMain.Items[I].DisplayRect(drBounds);
    if PtInRect(R, Point(0, Y)) then
    begin
      Result := elvMain.Items[I];
      Exit;
    end;
  end;
end;

procedure TManagerDB.FormCreate(Sender: TObject);
var
  I : integer;
begin
  FLoadingDataThread := nil;
  FData := TList.Create;
  FormManagerHint := nil;
  PopupMenuRating.Images := DBkernel.ImageList;
  PopupMenuRotate.Images := DBkernel.ImageList;
  N01.ImageIndex := DB_IC_DELETE_INFO;
  N11.ImageIndex := DB_IC_RATING_1;
  N21.ImageIndex := DB_IC_RATING_2;
  N31.ImageIndex := DB_IC_RATING_3;
  N41.ImageIndex := DB_IC_RATING_4;
  N51.ImageIndex := DB_IC_RATING_5;

  R01.ImageIndex := DB_IC_ROTETED_0;
  R02.ImageIndex := DB_IC_ROTETED_90;
  R03.ImageIndex := DB_IC_ROTETED_180;
  R04.ImageIndex := DB_IC_ROTETED_270;

  SI:=-1;
  PackTabelLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SHELL + 1]);
  ExportTableLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SAVE_AS_TABLE + 1]);
  ImportTableLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_LOADFROMFILE + 1]);
  RecreateIDExLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_REFRESH_ID + 1]);
  ScanforBadLinksLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_SEARCH + 1]);
  BackUpDBLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_CANCEL_ACTION + 1]);
  CleaningLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_COMMON + 1]);
  DublicatesLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_DUBLICAT + 1]);
  ConvertLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_CONVERT + 1]);
  ChangePathLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_DIRECTORY + 1]);

  OldWNDProc := elvMain.WindowProc;
  elvMain.WindowProc := ElvMainWindowProc;

  WorkQuery := GetQuery;
  DBCanDrag := False;
  PopupMenu5.Images := DBKernel.ImageList;
  Delete1.ImageIndex  := DB_IC_DELETE_INFO;
  Restore1.ImageIndex := DB_IC_LOADFROMFILE;
  Refresh1.ImageIndex := DB_IC_RELOAD;
  Rename1.ImageIndex  := DB_IC_RENAME;

  PopupMenu8.Images := DBKernel.ImageList;
  SelectDB1.ImageIndex := DB_IC_SHELL;
  RenameDB1.ImageIndex := DB_IC_RENAME;
  DeleteDB1.ImageIndex := DB_IC_DELETE_INFO;
  EditDB1.ImageIndex   := DB_IC_NOTES;

  FBackUpFiles := TStringList.Create;
  LbBackups.DoubleBuffered := True;
  UnLock;
  DropFileTarget1.Register(Self);
  DBCanDrag := False;
  DBkernel.RegisterChangesID(self,ChangedDBDataByID);
  DBkernel.RegisterForm(Self);
  DBkernel.RecreateThemeToForm(Self);

  Showfileinexplorer1.ImageIndex := DB_IC_FOLDER;

  CbSetField.Items.Clear;
  CbWhereField1.Items.Clear;
  CbWhereField2.Items.Clear;
  CbWhereField1.Items.Add(ChFields[1]);
  CbWhereField2.Items.Add(ChFields[1]);
  for I := 2 to FieldCount do
  begin
    CbSetField.Items.Add(ChFields[i]);
    CbWhereField1.Items.Add(ChFields[i]);
    CbWhereField2.Items.Add(ChFields[i]);
  end;
  CheckSQL;
  SaveWindowPos1.Key := RegRoot + 'Manager';
  SaveWindowPos1.SetPosition;
  LoadLanguage;
  ReadBackUps;
  RefreshDBList;

  InitializeQueryList;
end;

procedure TManagerDB.ComboBox1Change(Sender: TObject);
begin
  CheckSQL;
end;

procedure TManagerDB.ChangedDBDataByID(Sender: TObject; ID: integer;
  Params: TEventFields; Value: TEventValues);
var
  I : Integer;
  ItemData : TDBPopupMenuInfoRecord;
begin
  if SetNewIDFileData in Params then
  if Value.ID > 0 then
  begin
    ItemData := TDBPopupMenuInfoRecord.Create;
    ItemData.ID := Value.ID;
    ItemData.InfoLoaded := False;
    FData.Add(ItemData);
    elvMain.Items.Add;
    Exit;
  end;

  if EventID_Param_DB_Changed in params then
  begin
    elvMain.Clear;
    FreeDS(WorkQuery);
    InitializeQueryList;
    WorkQuery:=GetQuery;
  //  Edit1.text:=Value.Name;
    Exit;
  end;

  if EventID_Param_Delete in params then
  begin
    DeleteItemWithID(ID);
    Exit;
  end;

  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ItemData := TDBPopupMenuInfoRecord(ElvMain.Items[i].Data);
    if ItemData.ID = ID then
    begin
      if EventID_Param_Date in params then ItemData.Date := Value.Date;
      if EventID_Param_Time in params then ItemData.Time := Value.Time;
      if EventID_Param_IsDate in params then ItemData.IsDate := Value.IsDate;
      if EventID_Param_IsTime in params then ItemData.IsTime := Value.IsTime;
      if EventID_Param_Groups in params then ItemData.Groups := Value.Groups;
      if EventID_Param_Comment in params then ItemData.Comment := Value.Comment;
      if EventID_Param_KeyWords in params then ItemData.KeyWords := Value.KeyWords;
      if EventID_Param_Links in params then ItemData.Links := Value.Links;
      if EventID_Param_Include in params then ItemData.Include := Value.Include;
      if EventID_Param_Rotate in params then ItemData.Rotation := Value.Rotate;
      if EventID_Param_Rating in params then ItemData.Rating := Value.Rating;
      if EventID_Param_Private in params then ItemData.Access := Value.Access;
      ElvMain.Repaint;
    end;
  end;
end;

procedure TManagerDB.FormDestroy(Sender: TObject);
var
  I : integer;
begin
  ReleaseLoadingThread;
  FreeGroups(aGroups);
  for I := 0 to Length(GroupBitmaps) - 1 do
    GroupBitmaps[I].Free;
  SetLength(GroupBitmaps, 0);

  FreeDS(WorkQuery);
  FBackUpFiles.Free;
  if FormManagerHint<>nil then
  begin
    FormManagerHint.Release;
    FormManagerHint := nil;
  end;
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;
  DBkernel.UnRegisterForm(Self);
  DBkernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  FData.Free;
end;

procedure TManagerDB.RadioButton1Click(Sender: TObject);
begin
  CbSetField.Enabled:=RadioButton1.Checked;
  Edit2.Enabled:=RadioButton1.Checked;
  CheckSQL;
end;

procedure TManagerDB.CbWhereCombinatorChange(Sender: TObject);
begin
  if CbWhereCombinator.Text = ' ' then
  begin
    CbWhereField2.Enabled := False;
    CbOperatorWhere2.Enabled := False;
    Edit4.Enabled := False;
  end else
  begin
    CbWhereField2.Enabled := True;
    CbOperatorWhere2.Enabled := True;
    Edit4.Enabled := True;
  end;
  CheckSQL;
end;

function GetFieldTupe(FieldName : String) : Integer;
var
  I : integer;
begin
  Result := 0;
  for I := 1 to FieldCount do
  if AnsiUpperCase(ChFields[I]) = AnsiUpperCase(FieldName) then
  begin
    Result := ChFieldsTypes[I];
    Break;
  end;
end;

procedure TManagerDB.CbWhereField1Change(Sender: TObject);
var
  NewField : String;
  CbOperatorWhere : TComboBox;
begin
  NewField := TComboBox(Sender).Text;
  if Sender = CbWhereField1 then
    CbOperatorWhere := CbOperatorWhere1
  else
    CbOperatorWhere := CbOperatorWhere2;

  case GetFieldTupe(NewField) of
    FieldTypeInt,
    FieldTypeDate:
    begin
      CbOperatorWhere.Items.Clear;
      CbOperatorWhere.Items.Add('=');
      CbOperatorWhere.Items.Add('>');
      CbOperatorWhere.Items.Add('<');
      CbOperatorWhere.Items.Add('<>');
    end;
    FieldTypeStr:
    begin
      CbOperatorWhere.Items.Clear;
      CbOperatorWhere.Items.Add('=');
      CbOperatorWhere.Items.Add('<>');
      CbOperatorWhere.Items.Add('like');
    end;
    FieldTypeBool:
    begin
      CbOperatorWhere.Items.Clear;
      CbOperatorWhere.Items.Add('=');
      CbOperatorWhere.Items.Add('<>');
    end;
  end;
  CheckSQL;
end;

function ValueToDBValue(FieldName, Value : String) : String;
var
  FieldType : integer;
begin
  FieldType := GetFieldTupe(FieldName);
  if FieldType = FieldTypeInt then Result := IntToStr(StrToIntDef(Value,0))
  else if FieldType = FieldTypeStr then Result := '"'+normalizeDBString(Value) + '"'
  else if FieldType = FieldTypeBool then
  begin
    if Value='0' then
      Result:='TRUE'
    else
      Result:='FALSE';
  end else if FieldType = FieldTypeDate then
    Result := FloatToStr(StrToDateTimeDef(Value, 0));
end;

procedure TManagerDB.BtnExecSQLClick(Sender: TObject);
var
  SQL : string;
  Query : TDataSet;
begin
  Query := GetQuery;
  try
    if RadioButton1.Checked then
    begin
      SQL:='Update $DB$ Set '+CbSetField.Text+' = '+ValueToDBValue(CbSetField.Text,Edit2.Text);
    end else
    begin
      SQL:='Delete from $DB$';
    end;
    SQL:=SQL+' Where ';
    SQL:=SQL+'('+CbWhereField1.Text+' '+CbOperatorWhere1.Text+' '+ValueToDBValue(CbWhereField1.Text,Edit3.Text)+')';
    if (Trim(CbWhereCombinator.Text)<>'') then
    begin
      SQL:=SQL+' '+CbWhereCombinator.Text+' ('+CbWhereField2.Text+' '+CbOperatorWhere2.Text+' '+ValueToDBValue(CbWhereField2.Text,Edit4.Text)+')';
    end;
    SetSQL(Query,SQL);
    try
      ExecSQL(Query);
    except
      on e : Exception do
        MessageBoxDB(Handle,Format(TEXT_MES_ERROR_EXESQSL_BY_REASON_F,[e.Message,SQL]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    end;
  finally
    FreeDS(Query);
  end;
end;

procedure TManagerDB.CheckSQL;
begin
  if (((CbSetField.Text <> '') and RadioButton1.Checked) or RadioButton2.Checked) and (CbWhereField1.Text<>'') and (CbOperatorWhere1.Text<>'') then
  begin
    if (Trim(CbWhereCombinator.Text) = '') then
      BtnExecSQL.Enabled := True
    else
      BtnExecSQL.Enabled := (CbWhereField2.Text<>'') and (CbOperatorWhere2.Text<>'');

  end else
    BtnExecSQL.Enabled := False;
end;

procedure TManagerDB.CbOperatorWhere1Change(Sender: TObject);
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
  ManagerDB := nil;
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
  BtnExecSQL.Caption:=TEXT_MES_EXES_SQL;
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
  BtnAddDB.Caption:=TEXT_MES_DO_ADD_DB;
  EditDB1.Caption:=TEXT_MES_EDIT;
  SelectDB1.Caption:=TEXT_MES_SELECT_DB;
  DeleteDB1.Caption:=TEXT_MES_DELETE;
  RenameDB1.Caption:=TEXT_MES_RENAME;
  ConvertLink.Text:=TEXT_MES_CONVERT_DB;
  ChangePathLink.Text:=TEXT_MES_THANGE_FILES_PATH_IN_DB;

  elvMain.Columns[0].Caption:=TEXT_MES_ID;
  elvMain.Columns[1].Caption:=TEXT_MES_FILE_NAME;
  elvMain.Columns[2].Caption:=TEXT_MES_KEYWORDS;
  elvMain.Columns[3].Caption:=TEXT_MES_COMMENT;
  elvMain.Columns[4].Caption:=TEXT_MES_RATING;
  elvMain.Columns[5].Caption:=TEXT_MES_ROTATE;
  elvMain.Columns[6].Caption:=TEXT_MES_ACCESS;
  elvMain.Columns[7].Caption:=TEXT_MES_GROUPS;
  elvMain.Columns[8].Caption:=TEXT_MES_DATE;
  elvMain.Columns[9].Caption:=TEXT_MES_TIME;
  elvMain.Columns[10].Caption:=TEXT_MES_SIZE;

  Showfileinexplorer1.Caption:=TEXT_MES_SHOW_FILE_IN_EXPLORER;
end;

procedure TManagerDB.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
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
 LbBackups.Clear;
 for i:=0 to FBackUpFiles.Count-1 do
 LbBackups.Items.Add(ExtractFileName(FBackUpFiles[i]));

end;

procedure TManagerDB.LbBackupsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB : TListBox;
begin
 LB:=(Control as TListBox);
 LB.Canvas.FillRect(Rect);
 LB.Canvas.TextOut(Rect.Left+21, Rect.Top+3,LB.Items[Index]);
 DrawIconEx(LB.Canvas.Handle,Rect.Left+2,Rect.Top+2,UnitDBKernel.icons[DB_IC_LOADFROMFILE+1],16,16,0,0,DI_NORMAL);
end;

procedure TManagerDB.LbBackupsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  index, i  : integer;
begin
 index:=LbBackups.ItemAtPos(MousePos,true);
 if index=-1 then
 begin
  for i:=0 to LbBackups.Items.Count-1 do
  LbBackups.Selected[i]:=false;
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
 LbBackups.Selected[index]:=true else PopupMenu5.Tag:=0;
 PopupMenu5.Tag:=index;
 PopupMenu5.Popup(LbBackups.ClientToScreen(MousePos).X,LbBackups.ClientToScreen(MousePos).Y);
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
  I, W, H : integer;
  B : TBitmap;
  C : integer;
  ItemData : TDBPopupMenuInfoRecord;
begin
  LbDatabases.Enabled:=false;
  aGroups:=GetRegisterGroupList(True);
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
  LastSelected := nil;
  elvMain.DoubleBuffered:=true;
  elvMain.ControlStyle := elvMain.ControlStyle-[csDoubleClicks];

  ReleaseLoadingThread;
  FLoadingDataThread := TThreadLoadingManagerDB.Create(Self);
  dblData.Hide;
  dblData.Active := False;
  LsLoadingDB.Active := True;
  LsLoadingDB.Top := ElvMain.Top + 4 + GetListViewHeaderHeight(ElvMain);
  LsLoadingDB.Show;
end;

procedure TManagerDB.DBLoadDataPacket(DataList : TList);
var
  I : Integer;
begin
  elvMain.Items.BeginUpdate;
  try
    for I := 0 to DataList.Count - 1 do
    begin
      FData.Add(DataList[I]);
      ElvMain.Items.Add;
    end;
    if (LastSelected = nil) and (elvMain.Items.Count > 0) then
    begin
      LastSelected := elvMain.Items[0];
      LastSelected.Selected := True;
      elvMain.ItemFocused := elvMain.Items[0];
      LastSelectedIndex := 0;
    end;
  finally
    elvMain.Items.EndUpdate;
  end;
end;

procedure TManagerDB.DBOpened(Sender : TObject);
begin
   FLoadingDataThread.FreeOnTerminate := True;
   FLoadingDataThread := nil;
   LsLoadingDB.Active := False;
   LsLoadingDB.Hide;
   LbDatabases.Enabled := True;
end;

procedure TManagerDB.ElvMainAdvancedCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
var
  r2 : TRect;
  Caption : string;
  aRect : TRect;
  j, i : integer;
  G : TGroups;
  ItemData : TDBPopupMenuInfoRecord;
Const
  DrawTextOpt = DT_NOPREFIX+DT_CENTER+DT_WORDBREAK+DT_EDITCONTROL;
begin
  SetLength(G, 0);
  if SubItem < 0 then
    SubItem := -SubItem;
  if LockDraw then
    Exit;

  ItemData := TDBPopupMenuInfoRecord(Item.Data);
  if SubItem=1 then
  begin
    r2 := Item.DisplayRect(drLabel);
    Sender.Canvas.Brush.Style:=bsSolid;
    if Item.Selected and DefaultDraw then
    begin
      Sender.Canvas.Brush.Color := Theme_ListSelectColor;
      Sender.Canvas.Pen.Color := Theme_ListSelectColor;
      ListView_GetSubItemRect(elvMain.Handle, Item.Index, 10, 0, @aRect);
      elvMain.Canvas.Rectangle(0, r2.Top, aRect.Right, r2.Bottom);
    end else
    begin
      if Odd(Item.Index) then
      begin
        Sender.Canvas.Brush.Color := ColorDarken(Theme_ListColor);
        Sender.Canvas.Pen.Color := ColorDarken(Theme_ListColor);
        Sender.Canvas.Rectangle(0, r2.Top, Sender.Width, r2.Bottom);
      end else
      begin
        Sender.Canvas.Brush.Color := Theme_ListColor;
        Sender.Canvas.Pen.Color := Theme_ListColor;
        Sender.Canvas.Rectangle(0, r2.Top, Sender.Width, r2.Bottom);
      end;
    end;
    Caption := IntToStr(ItemData.ID);
    ListView_GetSubItemRect(elvMain.Handle, Item.Index, SubItem, 0, @aRect);
    r2 := Item.DisplayRect(drBounds);
    r2 := Rect(r2.Left, r2.Top, aRect.Left, aRect.Bottom);
    r2.Top := r2.Top + 2;
    DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), r2, DrawTextOpt);
  end;
  Sender.Canvas.Brush.Style := bsClear;
  ListView_GetSubItemRect(elvMain.Handle, Item.Index, SubItem, 0, @aRect);
  Sender.Canvas.Pen.Color := ColorDarken(Theme_MemoEditFontColor);
  Sender.Canvas.MoveTo(aRect.Left, aRect.Top);
  Sender.Canvas.LineTo(aRect.Left, aRect.Bottom);
  if not ItemData.InfoLoaded then
    GetData(Item.Index);

  if not ItemData.InfoLoaded then
    Exit;

  Case SubItem of
    1:
    begin
    end;
    2:
    begin
      elvMain.Canvas.Font.Color := $808080;
      aRect.Top := aRect.Top + 2;
      DrawText(Sender.Canvas.Handle, PWideChar(ItemData.KeyWords), Length(ItemData.KeyWords), aRect, DrawTextOpt);
      elvMain.Canvas.Font.Color:=$0;
    end;
    3:
    begin
      elvMain.Canvas.Font.Color := $FF8080;
      aRect.Top := aRect.Top + 2;
      DrawText(Sender.Canvas.Handle, PWideChar(ItemData.Comment), Length(ItemData.Comment), aRect, DrawTextOpt);
      elvMain.Canvas.Font.Color := $0;
    end;
    7:
    begin
      G := EncodeGroups(ItemData.Groups);
      aRect.Top := aRect.Top + 2;
      for I := 0 to Min(6, Length(G)) - 1 do
        for J := 0 to Length(aGroups) - 1 do
        begin
          if aGroups[J].GroupCode = G[I].GroupCode then
          begin
            Sender.Canvas.Draw(aRect.Left + 2 + I * 18, aRect.Top + (aRect.Bottom-aRect.Top) div 2 - GroupBitmaps[J].Height div 2, GroupBitmaps[J]);
            Break;
          end;
        end;
    end;
    8:
    begin
      aRect.Top := aRect.Top + 2;
      if ItemData.IsDate then
      begin
        Caption := FormatDateTime('yyyy.mm.dd', ItemData.Date);
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
      end else
      begin
        elvMain.Canvas.Font.Color := $808080;
        Caption := TEXT_MES_NO_DATE_1;
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color := $0;
      end;
    end;
    9:
    begin
      aRect.Top:=aRect.Top+2;
      if ItemData.IsTime then
      begin
        Caption:=FormatDateTime('hh.mm.ss', ItemData.Time);
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
      end else
      begin
        elvMain.Canvas.Font.Color:=$808080;
        Caption:=TEXT_MES_TIME_NOT_EXISTS;
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color:=$0;
      end;
    end;
    10:
    begin
      Caption := IntToStr(ItemData.FileSize);
      aRect.Top := aRect.Top + 2;
      DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
    end;
    4:
    begin
      aRect.Top := aRect.Top + 1;
      if ItemData.Rating > 0 then
        DrawIconEx(Sender.Canvas.Handle, aRect.Left + (aRect.Right - aRect.Left) div 2 - 8, aRect.Top, UnitDBKernel.Icons[ItemData.Rating + DB_IC_RATING_1], 16, 16, 0, 0, DI_NORMAL);

      ListView_GetSubItemRect(elvMain.Handle, Item.Index, 1, 0, @aRect);
      Caption := ItemData.FileName;
      aRect.Top := aRect.Top + 2;
      if ItemData.Include then
      begin
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
      end else
      begin
        elvMain.Canvas.Font.Color := $808080;
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color := $0;
      end;
    end;
    5:
    begin
      if ItemData.Rotation > 0 then
      begin
        aRect.Top := aRect.Top + 1;
        DrawIconEx(Sender.Canvas.Handle, aRect.Left + (aRect.Right - aRect.Left) div 2 - 8, aRect.Top, UnitDBKernel.Icons[ItemData.Rotation + DB_IC_ROTETED_0 + 1], 16, 16, 0, 0, DI_NORMAL);
      end;
    end;
    6:
    begin
      if ItemData.Access = 1 then
      begin
        aRect.Top := aRect.Top + 1;
        DrawIconEx(Sender.Canvas.Handle, aRect.Left + (aRect.Right - aRect.Left) div 2 - 8,aRect.Top, UnitDBKernel.Icons[DB_IC_PRIVATE + 1], 16, 16, 0, 0, DI_NORMAL);
      end;
    end;
  end;
  DefaultDraw := False;
end;

procedure TManagerDB.GetData(Index: integer);
var
  I, J, N, L : Integer;
  WorkQuery : TDataSet;
  _sqlexectext, s : string;
  B : Boolean;
  ItemData : TDBPopupMenuInfoRecord;
begin
  _sqlexectext := 'Select ID, FFileName, Rating, Comment, Rotated, Access, KeyWords, Groups, Links, DateToAdd, aTime, IsDate, IsTime, FileSize, Include from $DB$';
  _sqlexectext := _sqlexectext+' where ID in (';

  B := True;
  for I := -30 to 40 do
  begin
    if Index + i < 0 then
      Continue;
    if elvMain.Items.Count <= Index + I then Break;
    ItemData := TDBPopupMenuInfoRecord(elvMain.Items[Index + I].Data);
    if not ItemData.InfoLoaded then
    begin
      if B then
        _sqlexectext := _sqlexectext + IntToStr(ItemData.ID)
      else
        _sqlexectext := _sqlexectext + ',' + IntToStr(ItemData.ID);
      B := False;
    end;
  end;
  if B then
    Exit;

  WorkQuery := GetQuery;
  try
    _sqlexectext := _sqlexectext+')';
    SetSQL(WorkQuery, _sqlexectext);
    WorkQuery.Open;
    WorkQuery.First;
    while not WorkQuery.Eof do
    begin
      try
        L := WorkQuery.FieldByName('ID').AsInteger;
        N := MaxInt;
        for J := -30 to 40 do
        if Index + J >= 0 then
        if Index + J <= elvMain.Items.Count then
        begin
          ItemData := TDBPopupMenuInfoRecord(elvMain.Items[Index + J].Data);
          if ItemData.ID = L then
          begin
            N := Index + J;
            Break;
          end;
        end;

        if N = MaxInt then
          Continue;

        ItemData := TDBPopupMenuInfoRecord(elvMain.Items[N].Data);
        //TODO: ???aListData^.Exists:=0;
        ItemData.FileName   := Mince(WorkQuery.FieldByName('FFileName').AsString, 50);
        ItemData.KeyWords   := WorkQuery.FieldByName('KeyWords').AsString;
        ItemData.Comment    := WorkQuery.FieldByName('Comment').AsString;
        ItemData.Rating     := WorkQuery.FieldByName('Rating').AsInteger;
        ItemData.Rotation   := WorkQuery.FieldByName('Rotated').AsInteger;
        ItemData.Access     := WorkQuery.FieldByName('Access').AsInteger;
        ItemData.Time       := TimeOf(WorkQuery.FieldByName('aTime').AsDateTime);
        ItemData.Date       := DateOf(WorkQuery.FieldByName('DateToAdd').AsDateTime);
        ItemData.IsTime     := WorkQuery.FieldByName('IsTime').AsBoolean;
        ItemData.IsDate     := WorkQuery.FieldByName('IsDate').AsBoolean;
        ItemData.Include    := WorkQuery.FieldByName('Include').AsBoolean;
        ItemData.Groups     := WorkQuery.FieldByName('Groups').AsString;
        ItemData.FileSize   := WorkQuery.FieldByName('FileSize').AsInteger;
        ItemData.InfoLoaded := True;
      finally
        WorkQuery.Next;
      end;
    end;
  finally
    FreeDS(WorkQuery);
  end;
end;

procedure TManagerDB.ElvMainSelectItem(Sender: TObject; Item: TListItem;
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
  ElvMainAdvancedCustomDrawSubItem(ElvMain,item,i,[],cdPrePaint,DD);
  LastSelectedIndex:=Item.Index;
 end else
 begin
  DD:=false;
  if LastSelectedIndex<>-1 then
  for i:=1 to 10 do
  ElvMainAdvancedCustomDrawSubItem(ElvMain,ElvMain.Items[LastSelectedIndex],i,[],cdPrePaint,DD);
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
  Date, Time  : TDateTime;
  IsDate, IsTime, Changed : boolean;
  FQuery : TDataSet;
  ItemData : TDBPopupMenuInfoRecord;
begin
  Words := nil;
  if Msg.hwnd = ElvMain.Handle then
  begin
    if (Msg.Message = WM_LBUTTONDBLCLK) or (Msg.Message = WM_RBUTTONDBLCLK) then
    begin
      ElvMain.SetFocus;
      if (Msg.Message = WM_RBUTTONDBLCLK) then
      begin
        msg.Message := 0;
        Handled := True;
        Exit;
      end;
      Msg.Message := 0;
      Handled := True;
      GetCursorPos(P);
      P := ElvMain.ScreenToClient(P);
      Item := GetListViewItemAt(P.Y);
      if Item = nil then
        Exit;
      ItemData := TDBPopupMenuInfoRecord(Item.Data);
      SetLength(G, 0);
      if ShiftKeyDown then
        CopyFullRecordInfo(ItemData.ID);
      if GetSubItemIndexByPoint(ElvMain, Item, P) = 2 then
      begin
        Words:=SpilitWords(ItemData.KeyWords);
        PopupMenuKeyWords.Items.Clear;
        for i:=0 to Length(Words) - 1 do
        begin
          MenuItem := TMenuItem.Create(PopupMenuKeyWords);
          MenuItem.Caption := Words[I];
          PopupMenuKeyWords.Items.Add(MenuItem);
        end;
        P := ElvMain.ClientToScreen(P);
        PopupMenuKeyWords.Popup(P.X, P.Y);
      end else if GetSubItemIndexByPoint(ElvMain, Item, P)=4 then
      begin
        PopupMenuRating.Tag := Item.Index;
        P := ElvMain.ClientToScreen(P);
        for I := 0 to 5 do
          (FindComponent('N' + IntToStr(I) + '1') as TMenuItem).Default := ItemData.Rating = I;
        PopupMenuRating.Popup(P.X, P. Y);
      end else if GetSubItemIndexByPoint(ElvMain, Item, P) = 5 then
      begin
        PopupMenuRotate.Tag:=Item.Index;
        p := ElvMain.ClientToScreen(p);
        for I := 0 to 3 do
          (FindComponent('R0' + IntToStr(I + 1)) as TMenuItem).Default := ItemData.Rotation = I;
        PopupMenuRotate.Popup(P.X, P. Y);
      end else if (GetSubItemIndexByPoint(ElvMain,Item, P) = 8) or (GetSubItemIndexByPoint(ElvMain,Item, P) = 9) then
      begin
        Date := ItemData.Date;
        Time := ItemData.Time;
        IsTime := ItemData.IsTime;
        IsDate := ItemData.IsDate;
        ChangeDate(Date, IsDate, Changed, Time, IsTime);
        if Changed then
        begin
          ItemData.Date := Date;
          ItemData.Time := Time;
          ItemData.IsTime := IsTime;
          ItemData.IsDate := IsDate;
          FQuery := GetQuery;
          try
            SetSQL(FQuery,Format('Update $DB$ Set DateToAdd = :Date, aTime = :Time, IsTime = :IsTime, IsDate = :IsDate Where ID = %d', [ItemData.ID]));
            SetDateParam(FQuery, 'Date', Date);
            SetDateParam(FQuery, 'Time', Time);
            SetBoolParam(FQuery, 2, IsTime);
            SetBoolParam(FQuery, 3, IsDate);
            ExecSQL(FQuery);
          finally
            FreeDS(FQuery);
          end;
          ElvMain.Repaint;
        end;
      end else if GetSubItemIndexByPoint(ElvMain, Item, P) = 7 then
      begin
        PopupMenuGroups.Tag := Item.Index;
        P := ElvMain.ClientToScreen(P);
        G := EncodeGroups(ItemData.Groups);
        ImageListPopupGroups.Clear;
        PopupMenuGroups.Items.Clear;
        for I := 0 to Length(G) - 1 do
        begin
          for J := 0 to Length(aGroups) - 1 do
          begin
            if aGroups[J].GroupCode = G[I].GroupCode then
            begin
              b := TBitmap.Create;
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
      ElvMain.SetFocus;
      msg.message:=0;
      Handled:=true;
      GetCursorPos(p);
      p:=ElvMain.ScreenToClient(p);
      Item:=ElvMain.GetItemAt(10,p.y);
      if Item=nil then
      if LastSelected<>nil then
      begin
        LastSelected.Selected:=true;
        ElvMain.ItemFocused:=LastSelected;
        exit;
      end;
      LockDraw:=true;
      if Item<>nil then
      Item.Selected:=true;
      LastSelected:=Item;
      LockDraw:=false;
      ElvMain.ItemFocused:=Item;
    end;
  end;
end;

procedure TManagerDB.N51Click(Sender: TObject);
var
  Index, I, NewRating : integer;
  S : string;
  FQuery : TDataSet;
  ItemData : TDBPopupMenuInfoRecord;
begin
  Index := PopupMenuRating.Tag;
  S := (Sender as TMenuItem).Caption;
  for I := Length(S) downto 1 do
    if s[I] = '&' then
      Delete(S, I, 1);
  NewRating := StrToIntDef(S, 0);
  ItemData := TDBPopupMenuInfoRecord(ElvMain.Items[Index].Data);
  ItemData.Rating := NewRating;
  FQuery := GetQuery;
  try
    SetSQL(FQuery,Format('Update $DB$ Set Rating = %d Where ID = %d', [NewRating, ItemData.ID]));
    ExecSQL(FQuery);
  finally
    FreeDS(FQuery);
  end;
  ElvMain.Repaint;
end;

procedure TManagerDB.R04Click(Sender: TObject);
var
  Index, NewRotate : integer;
  FQuery : TDataSet;
  ItemData : TDBPopupMenuInfoRecord;
begin
  Index := PopupMenuRotate.Tag;
  NewRotate := (Sender as TMenuItem).Tag;
  ItemData := TDBPopupMenuInfoRecord(ElvMain.Items[Index].Data);
  ItemData.Rotation := NewRotate;
  FQuery := GetQuery;
  try
    SetSQL(FQuery,Format('Update $DB$ Set Rotated = %d Where ID = %d', [NewRotate, ItemData.ID]));
    ExecSQL(FQuery);
  finally
    FreeDS(FQuery);
  end;
  ElvMain.Repaint;
end;

procedure TManagerDB.ElvMainWindowProc(var Message: TMessage);
begin
  //ITS A BIG HACK!!!
  if Message.msg = 78 then
  begin
    if TWMNotify(Message).NMHdr.code = -530 then
    begin
      Message.msg := 0;
      Exit;
    end;
  end;
  OldWNDProc(Message);
end;

procedure TManagerDB.EditGroupsMenuClick(Sender: TObject);
var
  EventInfo : TEventValues;
  G, KeyWords : String;
  Groups : TGroups;
  Query : TDataSet;
  ItemData : TDBPopupMenuInfoRecord;
begin
  if ElvMain.Selected = nil then
    Exit;

  ItemData := TDBPopupMenuInfoRecord(ElvMain.Selected.Data);
  KeyWords := ItemData.KeyWords;
  G := ItemData.Groups;
  Groups := EnCodeGroups(G);
  DBChangeGroups(Groups, KeyWords);
  if (G = ItemData.Groups) and (KeyWords = ItemData.KeyWords) then
    Exit;
  G := CodeGroups(Groups);
  ItemData.KeyWords := KeyWords;
  ItemData.Groups := G;
  ElvMain.Repaint;

  Query := GetQuery;
  try
    SetSQL(Query,'Update $DB$ SET KeyWords = :KeyWords, Groups = :KeyWords WHERE ID = :ID');
    SetStrParam(Query, 0, KeyWords);
    SetStrParam(Query, 1, G);
    SetIntParam(Query, 2, ItemData.ID);
    ExecSQL(Query);
  finally
    FreeDS(Query);
  end;

  EventInfo.Groups := G;
  EventInfo.KeyWords := KeyWords;
  DBKernel.DoIDEvent(Self, ItemData.ID, [EventID_Param_Groups, EventID_Param_KeyWords], EventInfo);
end;

procedure TManagerDB.CMMOUSEEnter(var Message: TWMNoParams);
begin
  if FormManagerHint <> nil then
    if Active then
      if not FormManagerHint.Visible then
        ShowWindow(FormManagerHint.Handle, SW_SHOWNOACTIVATE);
end;

procedure TManagerDB.CMMOUSELEAVE(var Message: TWMNoParams);
begin
  if FormManagerHint <> nil then
    ShowWindow(FormManagerHint.Handle, SW_HIDE);
end;

procedure TManagerDB.OnMove(var Msg: TWMMove);
begin
  CMMOUSEEnter(TWMNoParams(Msg));
end;

procedure TManagerDB.ElvMainMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  P : TPoint;
  Item : TListItem;
  DS : TDataSet;
  JPG : TJpegImage;
  B : TBitmap;
  Pass : string;
  ItemData : TDBPopupMenuInfoRecord;
begin
  if FormManagerHint = nil then
    Application.CreateForm(TFormManagerHint, FormManagerHint);

  if FormManagerHint <> nil then
  begin
    Item := GetListViewItemAt(y);
    if Item = nil then
    begin
      ShowWindow(FormManagerHint.Handle, SW_HIDE);
      Exit;
    end;
    if Item.Index = SI then
      Exit;

    ItemData := TDBPopupMenuInfoRecord(Item.Data);
    SI := Item.Index;
    P.X := 0;
    P.Y := Y + 18;
    P := ElvMain.ClientToScreen(P);
    FormManagerHint.Left := P.X;
    if Top+Height - 15 < P.Y + FormManagerHint.Height then
      FormManagerHint.Top := P.Y - FormManagerHint.Height - 18
    else
      FormManagerHint.Top := P.Y;
    if ElvMain.Items.Count <= Item.Index then
      Exit;

    DS:=GetQuery;
    try
      if not ItemData.InfoLoaded then
      begin
        ShowWindow(FormManagerHint.Handle, SW_HIDE);
        Exit;
      end;
      try
        SetSQL(DS,'Select FFileName, Thum from $DB$ WHERE ID = '+IntToStr(ItemData.ID));
        DS.Open;
      except
        ShowWindow(FormManagerHint.Handle, SW_HIDE);
        Exit;
      end;
      if DS.RecordCount = 0 then
      begin
        ShowWindow(FormManagerHint.Handle, SW_HIDE);
        Exit;
      end;
      if FormManagerHint.Image1.Picture.Bitmap=nil then
      begin
        FormManagerHint.Image1.Picture.Bitmap := TBitmap.Create;
        FormManagerHint.Image1.Picture.Bitmap.PixelFormat := pf24bit;
      end;
      JPG := TJpegImage.Create;
      try
        if ValidCryptBlobStreamJPG(DS.FieldByName('Thum')) then
        begin
          pass := DBKernel.FindPasswordForCryptBlobStream(DS.FieldByName('Thum'));
          if pass = '' then
          begin
            ShowWindow(FormManagerHint.Handle, SW_HIDE);
            Exit;
          end else
            DeCryptBlobStreamJPG(DS.FieldByName('Thum'), pass, JPG);
        end else
          JPG.Assign(DS.FieldByName('Thum'));

        B:= FormManagerHint.image1.Picture.Graphic as TBitmap;
        B.Width:=ThSize;
        B.Height:=ThSize;
        B.Canvas.Pen.Color:=Theme_MainColor;
        B.Canvas.Brush.Color:=Theme_MainColor;
        B.Canvas.Rectangle(0,0,B.Width,B.Height);
        B.Canvas.Pen.Color:=Theme_ListColor;
        B.canvas.Draw(ThSize div 2 - JPG.Width div 2,ThSize div 2 - JPG.Height div 2,JPG);
      finally
        JPG.Free;
      end;
      ApplyRotate(B, ItemData.Rotation);
      DrawAttributes(B, ThSize, ItemData.Rating, ItemData.Rotation, ItemData.Access, DS.FieldByName('FFileName').AsString, ValidCryptBlobStreamJPG(DS.FieldByName('Thum')), ItemData.Exists, ItemData.ID);
    finally
      FreeDS(DS);
    end;
    if Active and (FormManagerHint <> nil) then
    begin
      FormManagerHint.DoubleBuffered := True;
      Application.ProcessMessages;
      ShowWindow(FormManagerHint.Handle, SW_SHOWNOACTIVATE);
    end;
  end;
end;

procedure TManagerDB.PackTabelLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle,TEXT_MES_PACKING_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
   DBkernel.WriteBool('StartUp', 'Pack', True);
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

procedure TManagerDB.ElvMainContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  MenuInfo : TDBPopupMenuInfo;
  Item : TListItem;
  ItemData : TDBPopupMenuInfoRecord;
begin
  Item := GetListViewItemAt(MousePos.Y);
  if Item = nil then
    Exit;

  ItemData := TDBPopupMenuInfoRecord(Item.Data);
  MenuInfo := GetMenuInfoByID(ItemData.ID);
  if MenuInfo.Count = 1 then
    DoProcessPath(MenuInfo[0].FileName);

  MenuInfo.IsPlusMenu:=False;
  MenuInfo.IsListItem:=False;
  MenuInfo.AttrExists:=false;
  TDBPopupMenu.Instance.Execute(ElvMain.ClientToScreen(MousePos).x,ElvMain.ClientToScreen(MousePos).y,MenuInfo);
end;

procedure TManagerDB.DeleteItemWithID(ID: integer);
var
  I : integer;
  SI : integer;
  ItemData : TDBPopupMenuInfoRecord;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ItemData := TDBPopupMenuInfoRecord(ElvMain.Items[I].Data);
    if ItemData.ID = ID then
    begin
      if ElvMain.Selected <> nil then
        SI := ElvMain.Selected.Index
      else
        SI := 0;

      if SI >= 0 then
      begin
        ElvMain.Selected := nil;
        ElvMain.Items.BeginUpdate;
        try
          ElvMain.Items.Delete(I);
          ItemData.Free;
        finally
          ElvMain.Items.EndUpdate;
        end;

        if SI >= ElvMain.Items.Count then
          SI := ElvMain.Items.Count - 1;
        if SI >= 0 then
        begin
          ElvMain.Items[SI].Selected := True;
          ElvMain.ItemFocused := ElvMain.Items[SI];
        end;
      end
    end;
  end;
  ElvMain.Repaint;
end;

procedure TManagerDB.LbDatabasesDrawItem(Control: TWinControl; Index: Integer;
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

procedure TManagerDB.BtnAddDBClick(Sender: TObject);
var
  DBFile : TPhotoDBFile;
begin
 DBFile:=DoChooseDBFile();
 if DBKernel.TestDB(DBFile.FileName) then
 DBKernel.AddDB(DBFile.Name,DBFile.FileName,DBFile.Icon);
 RefreshDBList;
end;

procedure TManagerDB.RefreshDBList;
var
  i : integer;
  ico : TIcon;
begin
 DBImageList.Clear;
 LbDatabases.Clear;
 DBImageList.BkColor:=Theme_ListColor;
 for i:=0 to DBKernel.DBs.Count-1 do
 begin
  LbDatabases.Items.Add(DBKernel.DBs[i].Name);
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

procedure TManagerDB.LbDatabasesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  index, i  : integer;
begin
 index:=LbDatabases.ItemAtPos(MousePos,true);
 if index=-1 then
 begin
  for i:=0 to LbDatabases.Items.Count-1 do
  LbDatabases.Selected[i]:=false;
  exit;
 end;
 DeleteDB1.Visible:=LbDatabases.Items.Count>1;
 if index<>-1 then
 LbDatabases.Selected[index]:=true else PopupMenu8.Tag:=0;
 PopupMenu8.Tag:=index;
 PopupMenu8.Popup(LbDatabases.ClientToScreen(MousePos).X,LbDatabases.ClientToScreen(MousePos).Y);
end;

procedure TManagerDB.RenameDB1Click(Sender: TObject);
var
  NewDBName : string;
  i : integer;
begin
 NewDBName:=LbDatabases.Items[PopupMenu8.Tag];
 if PromtString(TEXT_MES_NEW_NAME,TEXT_MES_ENTER_NEW_NAME_FOR_DB,NewDBName) then
 begin
  if Length(NewDBName)=0 then exit;
  for i:=1 to Length(NewDBName) do
  if NewDBName[i] in ['\','/','|'] then NewDBName[i]:=' ';
  DBKernel.RenameDB(LbDatabases.Items[PopupMenu8.Tag],NewDBName);
  LbDatabases.Items[PopupMenu8.Tag]:=NewDBName;
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
 LbDatabases.Refresh;
end;

procedure TManagerDB.DeleteDB1Click(Sender: TObject);
begin
 if MessageBoxDB(Handle,Format(TEXT_MES_DO_YOU_REALLY_WANT_TO_DENELE_DB_F,[LbDatabases.Items[PopupMenu8.Tag]]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)=ID_OK then
 begin
  DBKernel.DeleteDB(LbDatabases.Items[PopupMenu8.Tag]);
  RefreshDBList;
 end;
end;

procedure TManagerDB.LbDatabasesDblClick(Sender: TObject);
var
  Index: Integer;
  MousePos: TPoint;
begin
  GetCursorPos(MousePos);
  MousePos := LbDatabases.ScreenToClient(MousePos);
  Index := LbDatabases.ItemAtPos(MousePos, True);
  if Index >= 0 then
    ChangeDBOptions(DBkernel.DBs[index]);

  RefreshDBList;
end;

procedure TManagerDB.EditDB1Click(Sender: TObject);
var
  index : integer;
begin
  Index := PopupMenu8.Tag;
  ChangeDBOptions(DBKernel.DBs[index]);
  RefreshDBList;
end;

procedure TManagerDB.RecordNumberEditChange(Sender: TObject);
var
  I, N : integer;
  ItemData : TDBPopupMenuInfoRecord;
begin
  N := StrToIntDef(RecordNumberEdit.Text, 1);
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ItemData := TDBPopupMenuInfoRecord(ElvMain.Items[I].Data);
    if ItemData.ID >= N then
    begin
      LastSelected := ElvMain.Items[I];
      LastSelectedIndex := I;
      ElvMain.Selected := ElvMain.Items[I];
      ElvMain.ItemFocused := ElvMain.Items[I];
      ElvMain.Selected.Focused := True;
      ElvMain.ItemIndex := I;
      SendMessage(ElvMain.Handle, LVM_ENSUREVISIBLE, i, MakeLong(Integer(False), 0));
      Break;
    end;
  end;
  ElvMain.Refresh;
end;

procedure TManagerDB.DublicatesLinkClick(Sender: TObject);
begin
  if ID_OK=MessageBoxDB(Handle,TEXT_MES_OPTIMIZING_DUBLICATES_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
    DBkernel.WriteBool('StartUp','OptimizeDublicates',True);
end;

procedure TManagerDB.ConvertLinkClick(Sender: TObject);
begin
  if ID_OK=MessageBoxDB(Handle,TEXT_MES_CONVERTING_DB_QUESTION,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
    DBkernel.WriteBool('StartUp', 'ConvertDB', True);
end;

procedure TManagerDB.ChangePathLinkClick(Sender: TObject);
begin
  DoChangeDBPath;
end;

procedure TManagerDB.Showfileinexplorer1Click(Sender: TObject);
var
  Path : string;
begin
  Path := FBackUpFiles[PopupMenu5.Tag];
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(Path);
    SetPath(GetDirectory(Path));
    Show;
  end;
end;

procedure TManagerDB.ElvMainData(Sender: TObject; Item: TListItem);
begin
  Item.Data := FData[Item.Index];
end;

procedure TManagerDB.dblDataDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := Theme_ListColor;
  Buffer.Canvas.Brush.Color := Theme_ListColor;
  Buffer.Canvas.Rectangle(0, 0, Buffer.Width, Buffer.Height);
end;

procedure TManagerDB.ElvMainResize(Sender: TObject);
begin
  dblData.Left := ElvMain.Left + (ElvMain.Left + ElvMain.Width) div 2 - dblData.Width div 2;
  dblData.Top := ElvMain.Top + (ElvMain.Height) div 2 - dblData.Height div 2;
end;

procedure TManagerDB.ReleaseLoadingThread;
begin
  if FLoadingDataThread <> nil then
  begin
    FLoadingDataThread.Suspend;
    FLoadingDataThread.FreeOnTerminate := True;
    FLoadingDataThread.Terminate;
    FLoadingDataThread.Resume;
  end;
end;

end.
