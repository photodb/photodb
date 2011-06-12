unit ManagerDBUnit;

interface

uses
  UnitGroupsWork, DBCMenu, Dolphin_DB, UnitDBkernel, Windows, Messages,
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Math, uVistaFuncs,
  ExtCtrls, AppEvnts, ImgList, DropTarget, DragDropFile, DragDrop,
  DropSource, Menus, SaveWindowPos, DB, ComCtrls, WebLink, StdCtrls,
  Dialogs, Grids, DBGrids, jpeg, TwButton, Rating, Mask, uMemoryEx,
  GraphicCrypt, UnitStringPromtForm, CommonDBSupport, GraphicsCool,
  CommCtrl, DateUtils, uScript, UnitScripts, CmpUnit, UnitFormManagerHint,
  UnitConvertDBForm, UnitDBDeclare, UnitDBCommon, UnitDBCommonGraphics,
  uCDMappingTypes, uConstants, uFileUtils, uDBDrawing, adodb,
  DBLoading, LoadingSign, uDBForm, uMemory, uDBPopupMenuInfo, uGOM,
  uShellIntegration, uGraphicUtils, uSysUtils, uDBUtils, uRuntime,
  uSettings, uThreadForm, uDBAdapter;

type
  TManagerDB = class(TThreadForm)
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
    RbSQLSet: TRadioButton;
    RbSQLDelete: TRadioButton;
    RecordNumberEdit: TEdit;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu2: TPopupMenu;
    Dateexists1: TMenuItem;
    PmEdiGroups: TPopupMenu;
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
    PmRestoreDB: TPopupMenu;
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
    PmRestore: TPopupMenu;
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
    procedure RbSQLSetClick(Sender: TObject);
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
    procedure ShowGroupQuickInfo(Sender: TObject);
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReleaseLoadingThread;
    function GetFormID : string; override;
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

uses UnitQuickGroupInfo, ExplorerUnit,
     Searching, SlideShow, ExportUnit, UnitManageGroups,
     UnitDBCleaning, UnitCompareDataBases, UnitEditGroupsForm,
     UnitPasswordForm, ProgressActionUnit,
     UnitMenuDateForm, UnitChangeDBPath, UnitSelectDB, uThreadLoadingManagerDB,
     UnitDBOptions, uListViewUtils;

{$R *.dfm}

function TManagerDB.GetListViewItemAt(Y : Integer): TListItem;
var
  R : TRect;
  I, Index : Integer;
begin
  Result := nil;
  if ElvMain.Items.Count > 0 then
    Index := ElvMain.TopItem.Index
  else
    Index := 0;
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
  LsLoadingDB.Color := clWindow;
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
  PmRestoreDB.Images := DBKernel.ImageList;
  Delete1.ImageIndex  := DB_IC_DELETE_INFO;
  Restore1.ImageIndex := DB_IC_LOADFROMFILE;
  Refresh1.ImageIndex := DB_IC_RELOAD;
  Rename1.ImageIndex  := DB_IC_RENAME;

  PmRestore.Images := DBKernel.ImageList;
  SelectDB1.ImageIndex := DB_IC_SHELL;
  RenameDB1.ImageIndex := DB_IC_RENAME;
  DeleteDB1.ImageIndex := DB_IC_DELETE_INFO;
  EditDB1.ImageIndex   := DB_IC_NOTES;

  FBackUpFiles := TStringList.Create;
  LbBackups.DoubleBuffered := True;
  UnLock;
  DropFileTarget1.Register(Self);
  DBCanDrag := False;
  DBkernel.RegisterChangesID(self, ChangedDBDataByID);

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
    for I := 0 to FData.Count - 1 do
      TObject(FData[I]).Free;
    FData.Clear;
    FreeDS(WorkQuery);
    WorkQuery := GetQuery;
    InitializeQueryList;
    Exit;
  end;

  if EventID_Param_Delete in params then
  begin
    DeleteItemWithID(ID);
    Exit;
  end;

  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ItemData := FData[I];
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
  I : Integer;
begin
  NewFormState;

  elvMain.WindowProc := OldWNDProc;

  ReleaseLoadingThread;
  FreeGroups(aGroups);
  for I := 0 to Length(GroupBitmaps) - 1 do
    GroupBitmaps[I].Free;
  SetLength(GroupBitmaps, 0);

  ElvMain.Items.Count := 0;
  FreeDS(WorkQuery);
  F(FBackUpFiles);
  if GOM.IsObj(FormManagerHint) then
    R(FormManagerHint);
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;

  DBkernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  FreeList(FData);
end;

procedure TManagerDB.RbSQLSetClick(Sender: TObject);
begin
  CbSetField.Enabled := RbSQLSet.Checked;
  Edit2.Enabled := RbSQLSet.Checked;
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
  else if FieldType = FieldTypeStr then Result := normalizeDBString(Value)
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
  SQL: string;
  Query: TDataSet;
begin
  Query := GetQuery;
  try
    if RbSQLSet.Checked then
      SQL := 'Update $DB$ Set ' + CbSetField.Text + ' = ' + ValueToDBValue(CbSetField.Text, Edit2.Text)
    else
      SQL := 'Delete from $DB$';

    SQL := SQL + ' Where ';
    SQL := SQL + '(' + CbWhereField1.Text + ' ' + CbOperatorWhere1.Text + ' ' + ValueToDBValue(CbWhereField1.Text,
      Edit3.Text) + ')';
    if (Trim(CbWhereCombinator.Text) <> '') then
    begin
      SQL := SQL + ' ' + CbWhereCombinator.Text + ' (' + CbWhereField2.Text + ' ' + CbOperatorWhere2.Text + ' ' +
        ValueToDBValue(CbWhereField2.Text, Edit4.Text) + ')';
    end;
    SetSQL(Query, SQL);
    try
      ExecSQL(Query);
    except
      on E: Exception do
        MessageBoxDB(Handle, Format(L('An error occurred during the query: %s (%s)'), [E.message, SQL]), L('Error'),
          TD_BUTTON_OK, TD_ICON_ERROR);
    end;
  finally
    FreeDS(Query);
  end;
end;

procedure TManagerDB.CheckSQL;
begin
  if (((CbSetField.Text <> '') and RbSQLSet.Checked) or RbSQLDelete.Checked) and (CbWhereField1.Text<>'') and (CbOperatorWhere1.Text<>'') then
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
  R(ManagerDB);
end;

procedure TManagerDB.GroupsManager1Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TManagerDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption:= L('Collection Manager');
    RbSQLSet.Caption:= L('Set');
    RbSQLDelete.Caption:=  L('Delete');
    Label10.Caption:= L('where');
    PackTabelLink.Text:= L('Pack table');
    ExportTableLink.Text:= L('Export collection');
    ImportTableLink.Text:= L('Import collection');
    BackUpDBLink.Text:= L('Backup collection');
    CleaningLink.Text:= L('Cleaning');
    DublicatesLink.Text:= L('Optimize duplicates');
    BtnExecSQL.Caption:= L('Exec sql');
    DateExists1.Caption:= L('No date');
    DateExists2.Caption:= L('Set date');
    EditGroups1.Caption:= L('Edit groups');
    GroupsManager1.Caption:= L('Groups manager');
    Label7.Caption:= L('Go to record ID');
    Label11.Caption:= L('Backups');
    Restore1.Caption:= L('Restore collection');
    Delete1.Caption:= L('Delete');
    Refresh1.Caption:= L('Refresh');
    TimenotExists1.Caption:= L('No time');
    TimeExists1.Caption:= L('Set time');
    Rename1.Caption:= L('Rename');
    RecreateIDExLink.Text:= L('Recreate cache');
    ScanforBadLinksLink.Text:= L('Scan for bad links');
    BtnAddDB.Caption:= L('Add collection file');
    EditDB1.Caption:= L('Edit');
    SelectDB1.Caption:= L('Select collection');
    DeleteDB1.Caption:= L('Delete');
    RenameDB1.Caption:= L('Rename');
    ConvertLink.Text:= L('Convert collection');
    ChangePathLink.Text:= L('Change path in collection');

    elvMain.Columns[0].Caption:= L('ID');
    elvMain.Columns[1].Caption:= L('File name');
    elvMain.Columns[2].Caption:= L('Keywords');
    elvMain.Columns[3].Caption:= L('Comment');
    elvMain.Columns[4].Caption:= L('Rating');
    elvMain.Columns[5].Caption:= L('Rotate');
    elvMain.Columns[6].Caption:= L('Access');
    elvMain.Columns[7].Caption:= L('Groups');
    elvMain.Columns[8].Caption:= L('Date');
    elvMain.Columns[9].Caption:= L('Time');
    elvMain.Columns[10].Caption:= L('Size');

    Showfileinexplorer1.Caption:= L('Show file in explorer');
  finally
    EndTranslate;
  end;
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
  I: Integer;
begin
  FBackUpFiles.Clear;
  GetValidMDBFilesInFolder(GetAppDataDirectory + BackUpFolder, True, FBackUpFiles);
  LbBackups.Clear;
  for I := 0 to FBackUpFiles.Count - 1 do
    LbBackups.Items.Add(ExtractFileName(FBackUpFiles[I]));
end;

procedure TManagerDB.LbBackupsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
begin
  LB := (Control as TListBox);
  LB.Canvas.FillRect(Rect);
  LB.Canvas.TextOut(Rect.Left + 21, Rect.Top + 3, LB.Items[index]);
  DrawIconEx(LB.Canvas.Handle, Rect.Left + 2, Rect.Top + 2, UnitDBKernel.Icons[DB_IC_LOADFROMFILE + 1], 16, 16, 0, 0,
    DI_NORMAL);
end;

procedure TManagerDB.LbBackupsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Index, I: Integer;
begin
  Index := LbBackups.ItemAtPos(MousePos, True);
  if Index = -1 then
  begin
    for I := 0 to LbBackups.Items.Count - 1 do
      LbBackups.Selected[I] := False;
    Refresh1.Visible := True;
    Restore1.Visible := False;
    Rename1.Visible := False;
    Delete1.Visible := False;
  end
  else
  begin
    Refresh1.Visible := False;
    Restore1.Visible := True;
    Rename1.Visible := True;
    Delete1.Visible := True;
  end;
  if Index <> -1 then
    LbBackups.Selected[Index] := True
  else
    PmRestoreDB.Tag := 0;
  PmRestoreDB.Tag := Index;
  PmRestoreDB.Popup(LbBackups.ClientToScreen(MousePos).X, LbBackups.ClientToScreen(MousePos).Y);
end;

procedure TManagerDB.Delete1Click(Sender: TObject);
var
  FileName, CurrentFile : String;
begin
  if MessageBoxDB(Handle, Format(L('Do you really want to delete this copy of database (%s)?'), [FBackUpFiles[PmRestoreDB.Tag]]), L('Warning'),
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) = ID_OK then
  begin
    FileName := FBackUpFiles[PmRestoreDB.Tag];
    CurrentFile := FileName;
    DeleteFile(CurrentFile);

    CurrentFile := ChangeFileExt(CurrentFile, '.mb');
    DeleteFile(CurrentFile);

    CurrentFile := GroupsTableFileNameW(FileName);
    DeleteFile(CurrentFile);

    CurrentFile := ChangeFileExt(CurrentFile, '.mb');
    DeleteFile(CurrentFile);

    ReadBackUps;
  end;
end;

procedure TManagerDB.Refresh1Click(Sender: TObject);
begin
  ReadBackUps;
end;

procedure TManagerDB.Rename1Click(Sender: TObject);
var
  FileName, Dir: string;
  NewFileName: string;
  FN1, FN2, FN3, FN4, NFN1, NFN2, NFN3, NFN4: string;
begin
  FileName := GetFileNameWithoutExt(FBackUpFiles[PmRestoreDB.Tag]);
  Dir := IncludeTrailingBackslash(ExtractFileDir(FBackUpFiles[PmRestoreDB.Tag]));
  NewFileName := FileName;
  if PromtString(L('New name'), L('Please, enter a new name'), NewFileName) then
  begin
    FN1 := Dir + FileName + '.db';
    FN2 := Dir + FileName + '.mb';
    FN3 := Dir + FileName + 'G.db';
    FN4 := Dir + FileName + 'G.mb';
    NFN1 := Dir + NewFileName + '.db';
    NFN2 := Dir + NewFileName + '.mb';
    NFN3 := Dir + NewFileName + 'G.db';
    NFN4 := Dir + NewFileName + 'G.mb';
    if FileExistsSafe(NFN1) or FileExistsSafe(NFN2) or FileExistsSafe(NFN3) or FileExistsSafe(NFN4) then
    begin
      MessageBoxDB(Handle, L('File with that name already exists! Select a different file name.'), L('Error'),
        TD_BUTTON_OK, TD_ICON_ERROR);
      Exit;
    end;
    RenameFile(FN1, NFN1);
    RenameFile(FN2, NFN2);
    RenameFile(FN3, NFN3);
    RenameFile(FN4, NFN4);
    ReadBackUps;
  end;
end;

procedure TManagerDB.Restore1Click(Sender: TObject);
var
  Mes : string;
begin
  Mes := L('Do you really want to restore this copy of the database (%s)? The current database will be moved to this store. Restart the application to begin the recovery process');
  if MessageBoxDB(Handle, Format(Mes, [FBackUpFiles[PmRestoreDB.Tag]]), L('Warning'),
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) = ID_OK then
  begin
    Settings.WriteBool('StartUp', 'Restore', True);
    Settings.WriteString('StartUp', 'RestoreFile', FBackUpFiles[PmRestoreDB.Tag]);
  end;
end;

procedure TManagerDB.InitializeQueryList;
var
  I, W, H: Integer;
  B: TBitmap;
begin
  LbDatabases.Enabled := False;
  FreeGroups(aGroups);
  AGroups := GetRegisterGroupList(True);
  for I := 0 to Length(GroupBitmaps) - 1 do
    GroupBitmaps[I].Free;
  SetLength(GroupBitmaps, Length(AGroups));
  for I := 0 to Length(AGroups) - 1 do
  begin
    B := TBitmap.Create;
    try
      B.Assign(AGroups[I].GroupImage);
      GroupBitmaps[I] := TBitmap.Create;
      W := B.Width;
      H := B.Height;
      ProportionalSize(16, 16, W, H);
      GroupBitmaps[I].Height := H;
      GroupBitmaps[I].Width := W;
      GroupBitmaps[I].PixelFormat := Pf24bit;
      StretchCoolWTransparent(0, 0, W, H, Rect(0, 0, B.Width, B.Height), B, GroupBitmaps[I], 128);
    finally
      F(B);
    end;
  end;
  LockDraw := False;
  LastSelectedIndex := -1;
  LastSelected := nil;
  ElvMain.DoubleBuffered := True;
  ElvMain.ControlStyle := ElvMain.ControlStyle - [CsDoubleClicks];

  ReleaseLoadingThread;
  NewFormState;
  FLoadingDataThread := TThreadLoadingManagerDB.Create(Self);
  DblData.Hide;
  DblData.Active := False;
  LsLoadingDB.Active := True;
  LsLoadingDB.Top := ElvMain.Top + 4 + GetListViewHeaderHeight(ElvMain);
  LsLoadingDB.Show;
end;

procedure TManagerDB.DBLoadDataPacket(DataList : TList);
var
  I: Integer;
begin
  elvMain.Items.BeginUpdate;
  try
    for I := 0 to DataList.Count - 1 do
      FData.Add(DataList[I]);

    ElvMain.Items.Count := ElvMain.Items.Count + DataList.Count;

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
   R2: TRect;
   Caption: string;
   ARect: TRect;
   J, I: Integer;
   G: TGroups;
   ItemData: TDBPopupMenuInfoRecord;

 const
   DrawTextOpt = DT_NOPREFIX + DT_CENTER + DT_WORDBREAK + DT_EDITCONTROL;

begin
  SetLength(G, 0);
  if SubItem < 0 then
    SubItem := -SubItem;
  if LockDraw then
    Exit;

  ItemData := FData[Item.Index];
  if SubItem=1 then
  begin
    r2 := Item.DisplayRect(drLabel);
    Sender.Canvas.Brush.Style:=bsSolid;
    if Item.Selected and DefaultDraw then
    begin
      Sender.Canvas.Brush.Color := clHighlight;
      Sender.Canvas.Pen.Color := clHighlight;
      ListView_GetSubItemRect(elvMain.Handle, Item.Index, 10, 0, @aRect);
      elvMain.Canvas.Rectangle(0, r2.Top, aRect.Right, r2.Bottom);
    end else
    begin
      if Odd(Item.Index) then
      begin
        Sender.Canvas.Brush.Color := ColorDarken(clWindow);
        Sender.Canvas.Pen.Color := ColorDarken(clWindow);
        Sender.Canvas.Rectangle(0, r2.Top, Sender.Width, r2.Bottom);
      end else
      begin
        Sender.Canvas.Brush.Color := clWindow;
        Sender.Canvas.Pen.Color := clWindow;
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
  Sender.Canvas.Pen.Color := ColorDarken(clWindowText);
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
        Caption := L('No date');
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color := $0;
      end;
    end;
    9:
      begin
        ARect.Top := ARect.Top + 2;
        if ItemData.IsTime then
        begin
          Caption := FormatDateTime('hh:mm:ss', ItemData.Time);
          DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), ARect, DrawTextOpt);
        end else
        begin
          ElvMain.Canvas.Font.Color := $808080;
          Caption := L('No time');
          DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), ARect, DrawTextOpt);
          ElvMain.Canvas.Font.Color := $0;
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
  DA: TDBAdapter;
  _sqlexectext: string;
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
    if ElvMain.Items.Count <= index + I then
      Break;
    ItemData := FData[Index + I];
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
  DA := TDBAdapter.Create(WorkQuery);
  try
    _sqlexectext := _sqlexectext+')';
    SetSQL(WorkQuery, _sqlexectext);
    WorkQuery.Open;
    WorkQuery.First;
    while not WorkQuery.Eof do
    begin
      try
        L := DA.ID;
        N := MaxInt;
        for J := -30 to 40 do
        if Index + J >= 0 then
        if Index + J <= elvMain.Items.Count then
        begin
          ItemData := FData[Index + J];
          if ItemData.ID = L then
          begin
            N := Index + J;
            Break;
          end;
        end;

        if N = MaxInt then
          Continue;

        ItemData := FData[N];
        ItemData.Exists     := 0;
        ItemData.FileName   := Mince(DA.FileName, 50);
        ItemData.KeyWords   := DA.KeyWords;
        ItemData.Comment    := DA.Comment;
        ItemData.Rating     := DA.Rating;
        ItemData.Rotation   := DA.Rotation;
        ItemData.Access     := DA.Access;
        ItemData.Time       := DA.Time;
        ItemData.Date       := DA.Date;
        ItemData.IsTime     := DA.IsTime;
        ItemData.IsDate     := DA.IsDate;
        ItemData.Include    := DA.Include;
        ItemData.Groups     := DA.Groups;
        ItemData.FileSize   := DA.FileSize;
        ItemData.InfoLoaded := True;
      finally
        WorkQuery.Next;
      end;
    end;
  finally
    F(DA);
    FreeDS(WorkQuery);
  end;
end;

function TManagerDB.GetFormID: string;
begin
  Result := 'DBManager';
end;

procedure TManagerDB.ElvMainSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  I: Integer;
  DD: Boolean;
  LastLock: Boolean;
begin
  LastLock := LockDraw;
  LockDraw := False;
  if Selected then
  begin
    DD := True;
    for I := 1 to 10 do
      ElvMainAdvancedCustomDrawSubItem(ElvMain, Item, I, [], CdPrePaint, DD);
    LastSelectedIndex := Item.index;
  end else
  begin
    DD := False;
    if LastSelectedIndex <> -1 then
      for I := 1 to 10 do
        ElvMainAdvancedCustomDrawSubItem(ElvMain, ElvMain.Items[LastSelectedIndex], I, [], CdPrePaint, DD);
  end;
  LockDraw := LastLock;
end;

function GetSubItemIndexByPoint(ListView : TListView;Item : TListItem; Point : TPoint) : integer;
var
  ARect: TRect;
  SubItem: Integer;
begin
  Result := 0;
  for SubItem := 1 to 10 do
  begin
    ListView_GetSubItemRect(ListView.Handle, Item.index, SubItem, 0, @ARect);
    if PtInRect(ARect, Point) then
    begin
      Result := SubItem;
      Break;
    end;
  end;
end;

function SpilitWords(S : string) : TArrayOfString;
var
  I, J: Integer;
  Pi_: PInteger;

begin
  SetLength(Result, 0);
  S := ' ' + S + ' ';
  Pi_ := @I;
  for I := 1 to Length(S) - 1 do
  begin
    if I + 1 > Length(S) - 1 then
      Break;
    if (S[I] = ' ') and (S[I + 1] <> ' ') then
      for J := I + 1 to Length(S) do
        if (S[J] = ' ') or (J = Length(S)) then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := Copy(S, I + 1, J - I - 1);
          Pi_^ := J - 1;
          Break;
        end;
  end;
  for I := 0 to Length(Result) - 1 do
    Result[I] := Trim(Result[I]);

end;

procedure TManagerDB.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  P: TPoint;
  Item: TListItem;
  I, J: Integer;
  Words: TArrayOfString;
  MenuItem: TMenuItem;
  G: TGroups;
  B, Bit, TempB: TBitmap;
  W, H: Integer;
  Date, Time: TDateTime;
  IsDate, IsTime, Changed: Boolean;
  FQuery: TDataSet;
  ItemData: TDBPopupMenuInfoRecord;
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
      ItemData := FData[Item.Index];
      SetLength(G, 0);
      if ShiftKeyDown then
        CopyFullRecordInfo(Handle, ItemData.ID);
      if GetSubItemIndexByPoint(ElvMain, Item, P) = 2 then
      begin
        Words := SpilitWords(ItemData.KeyWords);
        PopupMenuKeyWords.Items.Clear;
        for I := 0 to Length(Words) - 1 do
        begin
          MenuItem := TMenuItem.Create(PopupMenuKeyWords);
          MenuItem.Caption := Words[I];
          PopupMenuKeyWords.Items.Add(MenuItem);
        end;
        P := ElvMain.ClientToScreen(P);
        PopupMenuKeyWords.Popup(P.X, P.Y);
      end else if GetSubItemIndexByPoint(ElvMain, Item, P) = 4 then
      begin
        PopupMenuRating.Tag := Item.Index;
        P := ElvMain.ClientToScreen(P);
        for I := 0 to 5 do
          (FindComponent('N' + IntToStr(I) + '1') as TMenuItem).Default := ItemData.Rating = I;
        PopupMenuRating.Popup(P.X, P. Y);
      end else if GetSubItemIndexByPoint(ElvMain, Item, P) = 5 then
      begin
        PopupMenuRotate.Tag := Item.Index;
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
              B := TBitmap.Create;
              try
                B.PixelFormat := Pf24bit;
                B.Assign(AGroups[J].GroupImage);
                Bit := TBitmap.Create;
                try
                  Bit.PixelFormat := Pf24bit;
                  Bit.Width := 16;
                  Bit.Height := 16;
                  Bit.Canvas.Brush.Color := Graphics.ClMenu;
                  Bit.Canvas.Pen.Color := Graphics.ClMenu;
                  Bit.Canvas.Rectangle(0, 0, 16, 16);
                  W := B.Width;
                  H := B.Height;
                  ProportionalSize(16, 16, W, H);
                  TempB := TBitmap.Create;
                  try
                    TempB.PixelFormat := Pf24bit;
                    TempB.Height := H;
                    TempB.Width := W;
                    DoResize(W, H, B, TempB);
                    Bit.Canvas.Draw(8 - TempB.Width div 2, 8 - TempB.Height div 2, TempB);
                  finally
                    F(TempB);
                  end;
                  ImageListPopupGroups.Add(Bit, nil);
                finally
                  F(Bit);
                end;
              finally
                F(B);
              end;
              MenuItem := TMenuItem.Create(PopupMenuGroups);
              MenuItem.Caption := G[I].GroupName;
              MenuItem.ImageIndex := ImageListPopupGroups.Count - 1;
              MenuItem.OnClick := ShowGroupQuickInfo;
              PopupMenuGroups.Items.Add(MenuItem);
              Break;
            end;
          end;
        end;
        MenuItem := TMenuItem.Create(PopupMenuGroups);
        MenuItem.Caption := '-';
        PopupMenuGroups.Items.Add(MenuItem);

        MenuItem := TMenuItem.Create(PopupMenuGroups);
        MenuItem.Caption := L('Edit groups');
        Bit := TBitmap.Create;
        try
          Bit.PixelFormat := Pf24bit;
          Bit.Width := 16;
          Bit.Height := 16;
          Bit.Canvas.Brush.Color := Graphics.ClMenu;
          Bit.Canvas.Pen.Color := Graphics.ClMenu;
          Bit.Canvas.Rectangle(0, 0, 16, 16);
          DrawIconEx(Bit.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
          ImageListPopupGroups.Add(Bit, nil);
        finally
          F(Bit);
        end;

        MenuItem.ImageIndex:=ImageListPopupGroups.Count-1;

        MenuItem.OnClick := EditGroupsMenuClick;
        PopupMenuGroups.Items.Add(MenuItem);
        PopupMenuGroups.Popup(P.X, P.Y);
      end;
    end;
    if (Msg.message = WM_LBUTTONDOWN) or (Msg.message = WM_RBUTTONDOWN) then
    begin
      ElvMain.SetFocus;
      Msg.message := 0;
      Handled := True;
      GetCursorPos(P);
      P := ElvMain.ScreenToClient(P);
      Item := ElvMain.GetItemAt(10, P.Y);
      if Item = nil then
        if LastSelected <> nil then
        begin
          LastSelected.Selected := True;
          ElvMain.ItemFocused := LastSelected;
          Exit;
        end;
      LockDraw := True;
      if Item <> nil then
        Item.Selected := True;
      LastSelected := Item;
      LockDraw := False;
      ElvMain.ItemFocused := Item;
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
  ItemData := FData[Index];
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
  ItemData := FData[Index];
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

  ItemData := FData[ElvMain.Selected.Index];
  KeyWords := ItemData.KeyWords;
  G := ItemData.Groups;
  Groups := EnCodeGroups(G);
  DBChangeGroups(Groups, KeyWords);
  if (ItemData.Groups = CodeGroups(Groups)) and (KeyWords = ItemData.KeyWords) then
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
  DA: TDBAdapter;
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

    ItemData := FData[Item.Index];
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

    DS := GetQuery;
    DA := TDBAdapter.Create(DS);
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
      B:= TBitmap.Create;
      try
        JPG := TJpegImage.Create;
        try
          if ValidCryptBlobStreamJPG(DA.Thumb) then
          begin
            pass := DBKernel.FindPasswordForCryptBlobStream(DA.Thumb);
            if pass = '' then
            begin
              ShowWindow(FormManagerHint.Handle, SW_HIDE);
              Exit;
            end else
              DeCryptBlobStreamJPG(DA.Thumb, pass, JPG);
          end else
            JPG.Assign(DA.Thumb);

          B.Width := ThSize;
          B.Height := ThSize;
          B.Canvas.Pen.Color := ClBtnFace;
          B.Canvas.Brush.Color := ClBtnFace;
          B.Canvas.Rectangle(0, 0, B.Width, B.Height);
          B.Canvas.Pen.Color := clWindow;
          B.Canvas.Draw(ThSize div 2 - JPG.Width div 2, ThSize div 2 - JPG.Height div 2, JPG);
        finally
          F(JPG);
        end;
        ApplyRotate(B, ItemData.Rotation);
        DrawAttributes(B, ThSize, ItemData.Rating, ItemData.Rotation, ItemData.Access, DA.FileName, ValidCryptBlobStreamJPG(DA.Thumb), ItemData.Exists, ItemData.ID);
        FormManagerHint.Image1.Picture.Graphic := B;
      finally
        F(B);
      end;
    finally
      F(DA);
      FreeDS(DS);
    end;
    if Active and (FormManagerHint <> nil) then
    begin
      FormManagerHint.DoubleBuffered := True;
      Application.ProcessMessages;
      if FormManagerHint <> nil then
        ShowWindow(FormManagerHint.Handle, SW_SHOWNOACTIVATE);

    end;
  end;
end;

procedure TManagerDB.PackTabelLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to pack the table? Packing will begin the next startup...'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'Pack', True);
end;

procedure TManagerDB.ExportTableLinkClick(Sender: TObject);
var
  ExportForm: TExportForm;
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to export the table?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
  begin
    Application.CreateForm(TExportForm, ExportForm);
    try
      ExportForm.Execute;
    finally
      R(ExportForm);
    end;
  end;
end;

procedure TManagerDB.ImportTableLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to import a table?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
  begin
    if ImportDataBaseForm = nil then
      Application.CreateForm(TImportDataBaseForm, ImportDataBaseForm);
    ImportDataBaseForm.Execute;
  end;
end;

procedure TManagerDB.RecreateIDExLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to rebuild the IDEx in the table? Processing begins on the next startup.'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'RecreateIDEx', True);
end;

procedure TManagerDB.ScanforBadLinksLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to scan the table on the broken links? Processing will begin when the next launch.'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'ScanBadLinks', True);
end;

procedure TManagerDB.BackUpDBLinkClick(Sender: TObject);
begin
  if ID_OK <> MessageBoxDB(Handle, L('Do you really want to create a backup?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    Exit;

  Settings.WriteBool('StartUp', 'BackUp', True);
  MessageBoxDB(Handle, L('Restoring will begin when the next launch!'), L('Information'), TD_BUTTON_OK,
    TD_ICON_INFORMATION);
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
  MenuInfo: TDBPopupMenuInfo;
  Item: TListItem;
  ItemData: TDBPopupMenuInfoRecord;
begin
  Item := GetListViewItemAt(MousePos.Y);
  if Item = nil then
    Exit;

  ItemData := FData[Item.Index];
  MenuInfo := GetMenuInfoByID(ItemData.ID);
  try
    if MenuInfo.Count = 1 then
      DoProcessPath(MenuInfo[0].FileName);

    MenuInfo.IsPlusMenu := False;
    MenuInfo.IsListItem := False;
    MenuInfo.AttrExists := False;
    TDBPopupMenu.Instance.Execute(Self, ElvMain.ClientToScreen(MousePos).X, ElvMain.ClientToScreen(MousePos).Y, MenuInfo);
  finally
    F(MenuInfo);
  end;
end;

procedure TManagerDB.DeleteItemWithID(ID: integer);
var
  I : integer;
  SI : integer;
  ItemData : TDBPopupMenuInfoRecord;
begin
  for I := ElvMain.Items.Count - 1 downto 0 do
  begin
    ItemData := FData[I];
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
          FData.Delete(I);
          ElvMain.Items.Count := ElvMain.Items.Count - 1;
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
  LB: TListBox;
  ADBName: string;
begin
  LB := (Control as TListBox);
  LB.Canvas.FillRect(Rect);
  ADBname := ExtractFileName(DBKernel.DBs[index].FileName);
  if AnsiLowerCase(Dbname) = AnsiLowerCase(DBKernel.DBs[index].FileName) then
    LB.Canvas.Font.Style := [FsBold]
  else
    LB.Canvas.Font.Style := [];
  LB.Canvas.TextOut(Rect.Left + 21, Rect.Top + 3, LB.Items[index] + '  [' + ADBname + ']');
  DBImageList.Draw(LB.Canvas, Rect.Left + 2, Rect.Top + 2, index, True);
end;

procedure TManagerDB.BtnAddDBClick(Sender: TObject);
var
  DBFile: TPhotoDBFile;
begin
  DBFile := DoChooseDBFile;
  try
    if DBKernel.TestDB(DBFile.FileName) then
      DBKernel.AddDB(DBFile.Name, DBFile.FileName, DBFile.Icon);
  finally
    F(DBFile);
  end;
  RefreshDBList;
end;

procedure TManagerDB.RefreshDBList;
var
  I: Integer;
  Ico: TIcon;
begin
  DBImageList.Clear;
  LbDatabases.Clear;
  DBImageList.BkColor := clWindow;
  for I := 0 to DBKernel.DBs.Count - 1 do
  begin
    LbDatabases.Items.Add(DBKernel.DBs[I].name);
    Ico := TIcon.Create;
    try
      Ico.Handle := ExtractSmallIconByPath(DBKernel.DBs[I].Icon);
      if Ico.Empty then
        Ico.Handle := ExtractSmallIconByPath(Application.ExeName + ',0');
      DBImageList.AddIcon(Ico);
    finally
      F(Ico);
    end;
  end;
end;

procedure TManagerDB.LbDatabasesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  index, I: Integer;
begin
  index := LbDatabases.ItemAtPos(MousePos, True);
  if index = -1 then
  begin
    for I := 0 to LbDatabases.Items.Count - 1 do
      LbDatabases.Selected[I] := False;
    Exit;
  end;
  DeleteDB1.Visible := LbDatabases.Items.Count > 1;
  if index <> -1 then
    LbDatabases.Selected[index] := True
  else
    PmRestore.Tag := 0;

  PmRestore.Tag := index;
  PmRestore.Popup(LbDatabases.ClientToScreen(MousePos).X, LbDatabases.ClientToScreen(MousePos).Y);
end;

procedure TManagerDB.RenameDB1Click(Sender: TObject);
var
  NewDBName: string;
  I: Integer;
begin
  NewDBName := LbDatabases.Items[PmRestore.Tag];
  if PromtString(L('New name'), L('Please, enter a new name for collection'), NewDBName) then
  begin
    if Length(NewDBName) = 0 then
      Exit;
    for I := 1 to Length(NewDBName) do
      if CharInSet(NewDBName[I], ['\', '/', '|']) then
        NewDBName[I] := ' ';
    DBKernel.RenameDB(LbDatabases.Items[PmRestore.Tag], NewDBName);
    LbDatabases.Items[PmRestore.Tag] := NewDBName;
    RefreshDBList;
  end;
end;

procedure TManagerDB.SelectDB1Click(Sender: TObject);
var
  DBVersion: Integer;
  DialogResult: Integer;
  FileName: string;
begin
  FileName := DBKernel.DBs[PmRestore.Tag].FileName;
  if DBKernel.TestDB(FileName) then
  begin
    if not SelectDB(Self, FileName) then
      MessageBoxDB(Handle, Format(L('Invalid or missing file $nl$"%s"! $nl$Check for a file or try to add it through the database manager - perhaps the file was created in an earlier version of the program and must be converted to the current version'), [FileName]), L('Error'), TD_BUTTON_OK,
        TD_ICON_ERROR);
  end else
  begin
    if not FileExists(FileName) then
    begin
      MessageBoxDB(Handle, L('File not found!'), L('Error'), '', TD_BUTTON_OK, TD_ICON_ERROR);
    end else
    begin
      DBVersion := DBKernel.TestDBEx(FileName);
      if DBVersion > 0 then
        if not DBKernel.ValidDBVersion(FileName, DBVersion) then
        begin
          DialogResult := MessageBoxDB(Handle, L('This database may not be used without conversion, ie it is designed to work with older versions of the program. Run the wizard to convert database?'), L('Warning'),
            '', TD_BUTTON_YESNO, TD_ICON_WARNING);
          if ID_YES = DialogResult then
            ConvertDB(FileName);
        end;
    end;
  end;
  RefreshDBList;
  LbDatabases.Refresh;
end;

procedure TManagerDB.DeleteDB1Click(Sender: TObject);
begin
  if MessageBoxDB(Handle, Format(L('Do you really want to delete this database (%s)?'), [LbDatabases.Items[PmRestore.Tag]]),
    L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) = ID_OK then
  begin
    DBKernel.DeleteDB(LbDatabases.Items[PmRestore.Tag]);
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
  Index: Integer;
begin
  index := PmRestore.Tag;
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
    ItemData := FData[I];
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
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to optimize the duplicates in a table? Optimization starts at the next startup...'), L('Warning'), TD_BUTTON_OKCANCEL,
    TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'OptimizeDublicates', True);
end;

procedure TManagerDB.ConvertLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to convert your database? Conversion will start program restart.'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'ConvertDB', True);
end;

procedure TManagerDB.ChangePathLinkClick(Sender: TObject);
begin
  DoChangeDBPath;
end;

procedure TManagerDB.Showfileinexplorer1Click(Sender: TObject);
var
  Path: string;
begin
  Path := FBackUpFiles[PmRestoreDB.Tag];
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(Path);
    SetPath(ExtractFileDir(Path));
    Show;
  end;
end;

procedure TManagerDB.ShowGroupQuickInfo(Sender: TObject);
begin
  ShowGroupInfo(StringReplace(TMenuItem(Sender).Caption, '&', '', []), False, Self);
end;

procedure TManagerDB.ElvMainData(Sender: TObject; Item: TListItem);
begin
  Item.Data := FData[Item.Index];
end;

procedure TManagerDB.dblDataDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := clWindow;
  Buffer.Canvas.Brush.Color := clWindow;
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
    FLoadingDataThread.FreeOnTerminate := True;
    FLoadingDataThread.Terminate;
  end;
end;

end.
