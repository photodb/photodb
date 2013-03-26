unit ManagerDBUnit;

interface

uses
  Windows,
  Messages,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  DropTarget,
  DragDropFile,
  DragDrop,
  DropSource,
  Menus,
  DB,
  ComCtrls,
  StdCtrls,
  Dialogs,
  Grids,
  DBGrids,
  jpeg,
  Mask,
  uMemoryEx,
  GraphicCrypt,
  CommonDBSupport,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Graphics.Utils,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.SaveWindowPos,
  Dmitry.Controls.Rating,
  Dmitry.Controls.DBLoading,
  Dmitry.Controls.LoadingSign,

  CommCtrl,
  DateUtils,

  DBCMenu,
  UnitDBkernel,
  uGroupTypes,
  UnitGroupsWork,
  UnitFormManagerHint,
  UnitDBDeclare,

  uBitmapUtils,
  uCDMappingTypes,
  uConstants,
  uDBDrawing,
  adodb,
  Themes,
  uDBForm,
  uMemory,
  uDBPopupMenuInfo,
  uGOM,
  uShellIntegration,
  uGraphicUtils,
  uDBUtils,
  uRuntime,
  uSettings,
  uThreadForm,
  uDBAdapter,

  uVCLHelpers,
  uThemesUtils,
  uConfiguration,
  uFormInterfaces;

type
  TManagerDB = class(TThreadForm, ICollectionManagerForm)
    Panel2: TPanel;
    PnTop: TPanel;
    PopupMenu1: TPopupActionBar;
    Label7: TLabel;
    RecordNumberEdit: TEdit;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu2: TPopupActionBar;
    Dateexists1: TMenuItem;
    PmEdiGroups: TPopupActionBar;
    EditGroups1: TMenuItem;
    GroupsManager1: TMenuItem;
    PopupMenu4: TPopupActionBar;
    DateExists2: TMenuItem;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    GroupsImageList: TImageList;
    LbBackups: TListBox;
    Label11: TLabel;
    PmRestoreDB: TPopupActionBar;
    Delete1: TMenuItem;
    Restore1: TMenuItem;
    Refresh1: TMenuItem;
    PopupMenu6: TPopupActionBar;
    Timenotexists1: TMenuItem;
    PopupMenu7: TPopupActionBar;
    TimeExists1: TMenuItem;
    Rename1: TMenuItem;
    ElvMain: TListView;
    ApplicationEvents1: TApplicationEvents;
    ImlMain: TImageList;
    PopupMenuRating: TPopupActionBar;
    N01: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    PopupMenuKeyWords: TPopupActionBar;
    PopupMenuRotate: TPopupActionBar;
    R01: TMenuItem;
    R02: TMenuItem;
    R03: TMenuItem;
    R04: TMenuItem;
    PopupMenuGroups: TPopupActionBar;
    ImageListPopupGroups: TImageList;
    PopupMenuDate: TPopupActionBar;
    PopupMenuFile: TPopupActionBar;
    PackTabelLink: TWebLink;
    RecreateIDExLink: TWebLink;
    ScanforBadLinksLink: TWebLink;
    BackUpDBLink: TWebLink;
    DuplicatesLink: TWebLink;
    ConvertLink: TWebLink;
    ChangePathLink: TWebLink;
    N2: TMenuItem;
    Showfileinexplorer1: TMenuItem;
    dblData: TDBLoading;
    LsLoadingDB: TLoadingSign;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GroupsManager1Click(Sender: TObject);
    procedure LbBackupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LbBackupsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure ElvMainAdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure ElvMainSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG;  var Handled: Boolean);
    procedure N51Click(Sender: TObject);
    procedure R04Click(Sender: TObject);
    procedure EditGroupsMenuClick(Sender: TObject);
    procedure ElvMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PackTabelLinkClick(Sender: TObject);
    procedure RecreateIDExLinkClick(Sender: TObject);
    procedure ScanforBadLinksLinkClick(Sender: TObject);
    procedure BackUpDBLinkClick(Sender: TObject);
    procedure ElvMainContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure RecordNumberEditChange(Sender: TObject);
    procedure DuplicatesLinkClick(Sender: TObject);
    procedure ConvertLinkClick(Sender: TObject);
    procedure ChangePathLinkClick(Sender: TObject);
    procedure Showfileinexplorer1Click(Sender: TObject);
    procedure ElvMainData(Sender: TObject; Item: TListItem);
    procedure dblDataDrawBackground(Sender: TObject; Buffer: TBitmap);
    procedure ElvMainResize(Sender: TObject);
  private
    OldWNDProc: TWndMethod;
    LastSelected: TListItem;
    LastSelectedIndex: integer;
    LockDraw: Boolean;
    aGroups: TGroups;
    GroupBitmaps: array of TBitmap;
    FormManagerHint: TFormManagerHint;
    WorkQuery: TDataSet;
    FBackUpFiles: TStrings;
    DBCanDrag: Boolean;
    SI: integer;
    FData: TList;
    FLoadingDataThread: TThread;
    procedure LoadLanguage;
    procedure ElvMainWindowProc(var Message: TMessage);
    procedure ReadBackUps;
    procedure InitializeQueryList;
    procedure GetData(Index: integer);
    procedure DeleteItemWithID(ID: Integer);
    procedure RefreshDBList;
    procedure ChangedDBDataByID(Sender: TObject; ID: integer; params: TEventFields; Value: TEventValues);
    function GetListViewItemAt(Y: Integer): TListItem;
    procedure ShowGroupQuickInfo(Sender: TObject);
    procedure ReleaseLoadingThread;
  protected
    { protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure OnMove(var Msg: TWMMove); message WM_MOVE;
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure CMMOUSEEnter(var Message: TWMNoParams); message CM_MOUSEenter;
    function GetFormID: string; override;
  public
    { public declarations }
    procedure DBOpened(Sender: TObject);
    procedure DBLoadDataPacket(DataList: TList);
  end;

implementation

uses
  uManagerExplorer,
  UnitPasswordForm,
  ProgressActionUnit,
  UnitMenuDateForm,
  UnitChangeDBPath,

  uThreadLoadingManagerDB,
  uListViewUtils;

{$R *.dfm}

function TManagerDB.GetListViewItemAt(Y : Integer): TListItem;
var
  R: TRect;
  I, Index: Integer;
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
begin
  FLoadingDataThread := nil;
  FData := TList.Create;
  LsLoadingDB.Color := Theme.WindowColor;
  LbBackups.Color := Theme.ListColor;
  FormManagerHint := nil;
  PopupMenuRating.Images := DBkernel.ImageList;
  PopupMenuRotate.Images := DBkernel.ImageList;
  N01.ImageIndex := DB_IC_DELETE_INFO;
  N11.ImageIndex := DB_IC_RATING_1;
  N21.ImageIndex := DB_IC_RATING_2;
  N31.ImageIndex := DB_IC_RATING_3;
  N41.ImageIndex := DB_IC_RATING_4;
  N51.ImageIndex := DB_IC_RATING_5;

  R01.ImageIndex := DB_IC_ROTATED_0;
  R02.ImageIndex := DB_IC_ROTATED_90;
  R03.ImageIndex := DB_IC_ROTATED_180;
  R04.ImageIndex := DB_IC_ROTATED_270;

  SI := -1;
  PackTabelLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SHELL + 1]);
  RecreateIDExLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_REFRESH_ID + 1]);
  ScanforBadLinksLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SEARCH + 1]);
  BackUpDBLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_BACKUP + 1]);
  DuplicatesLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DUPLICATE + 1]);
  ConvertLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CONVERT + 1]);
  ChangePathLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DIRECTORY + 1]);

  ElvMain.Font.Color := Theme.ListViewFontColor;

  OldWNDProc := elvMain.WindowProc;
  elvMain.WindowProc := ElvMainWindowProc;

  WorkQuery := GetQuery;
  DBCanDrag := False;
  PmRestoreDB.Images := DBKernel.ImageList;
  Delete1.ImageIndex  := DB_IC_DELETE_INFO;
  Restore1.ImageIndex := DB_IC_LOADFROMFILE;
  Refresh1.ImageIndex := DB_IC_RELOAD;
  Rename1.ImageIndex  := DB_IC_RENAME;

  FBackUpFiles := TStringList.Create;
  LbBackups.DoubleBuffered := True;
  DropFileTarget1.Register(Self);
  DBCanDrag := False;
  DBkernel.RegisterChangesID(self, ChangedDBDataByID);

  Showfileinexplorer1.ImageIndex := DB_IC_FOLDER;

  SaveWindowPos1.Key := RegRoot + 'Manager';
  SaveWindowPos1.SetPosition;
  LoadLanguage;
  ReadBackUps;
  RefreshDBList;

  InitializeQueryList;
end;

procedure TManagerDB.ChangedDBDataByID(Sender: TObject; ID: integer;
  Params: TEventFields; Value: TEventValues);
var
  I: Integer;
  ItemData: TDBPopupMenuInfoRecord;
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
      if EventID_Param_Rotate in params then ItemData.Rotation := Value.Rotation;
      if EventID_Param_Rating in params then ItemData.Rating := Value.Rating;
      if EventID_Param_Private in params then ItemData.Access := Value.Access;
      ElvMain.Repaint;
    end;
  end;
end;

procedure TManagerDB.FormDestroy(Sender: TObject);
var
  I: Integer;
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


procedure TManagerDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TManagerDB.GroupsManager1Click(Sender: TObject);
begin
  GroupsManagerForm.Execute;
end;

procedure TManagerDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption:= L('Collection Manager');
    PackTabelLink.Text:= L('Pack table');
    BackUpDBLink.Text:= L('Backup collection');
    DuplicatesLink.Text:= L('Optimize duplicates');
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
  if StringPromtForm.Query(L('New name'), L('Please, enter a new name'), NewFileName) then
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
      GroupBitmaps[I].PixelFormat := pf24bit;
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
  ElvMain.Items.BeginUpdate;
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
    ElvMain.Items.EndUpdate;
  end;
end;

procedure TManagerDB.DBOpened(Sender : TObject);
begin
   FLoadingDataThread.FreeOnTerminate := True;
   FLoadingDataThread := nil;
   LsLoadingDB.Active := False;
   LsLoadingDB.Hide;
end;

procedure TManagerDB.ElvMainAdvancedCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
var
  R2: TRect;
  Caption: string;
  ARect: TRect;
  J, I: integer;
  G: TGroups;
  ItemData: TDBPopupMenuInfoRecord;

const
  DrawTextOpt = DT_NOPREFIX + DT_CENTER + DT_WORDBREAK + DT_EDITCONTROL;

function GetStyleTextColor(RequestedColor: TColor): TColor;
begin
  if TStyleManager.IsCustomStyleActive then
  begin
    if Item.Selected then
      Result := Theme.ListViewSelectedFontColor
    else
      Result := Theme.ListViewFontColor
  end else
    Result := RequestedColor;
end;

begin
  SetLength(G, 0);
  if SubItem < 0 then
    SubItem := -SubItem;
  if LockDraw then
    Exit;

  elvMain.Canvas.Font.Color := GetStyleTextColor(0);
  ItemData := FData[Item.Index];
  if SubItem = 1 then
  begin
    r2 := Item.DisplayRect(drLabel);
    Sender.Canvas.Brush.Style := bsSolid;
    if Item.Selected and DefaultDraw then
    begin
      Sender.Canvas.Brush.Color := Theme.HighlightColor;
      Sender.Canvas.Pen.Color := Theme.HighlightColor;
      ListView_GetSubItemRect(elvMain.Handle, Item.Index, 10, 0, @aRect);
        elvMain.Canvas.Rectangle(0, r2.Top, aRect.Right, r2.Bottom);
    end else
    begin
      if Odd(Item.Index) then
      begin
        Sender.Canvas.Brush.Color := ColorDarken(Theme.ListViewColor);
        Sender.Canvas.Pen.Color := ColorDarken(Theme.ListViewColor);
        Sender.Canvas.Rectangle(0, r2.Top, Sender.Width, r2.Bottom);
      end else
      begin
        Sender.Canvas.Brush.Color := Theme.ListViewColor;
        Sender.Canvas.Pen.Color := Theme.ListViewColor;
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
  Sender.Canvas.Pen.Color := ColorDarken(Theme.WindowTextColor);
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
      elvMain.Canvas.Font.Color := GetStyleTextColor($808080);
      aRect.Top := aRect.Top + 2;
      DrawText(Sender.Canvas.Handle, PWideChar(ItemData.KeyWords), Length(ItemData.KeyWords), aRect, DrawTextOpt);
      elvMain.Canvas.Font.Color := GetStyleTextColor($0);
    end;
    3:
    begin
      elvMain.Canvas.Font.Color := GetStyleTextColor($FF8080);
      aRect.Top := aRect.Top + 2;
      DrawText(Sender.Canvas.Handle, PWideChar(ItemData.Comment), Length(ItemData.Comment), aRect, DrawTextOpt);
      elvMain.Canvas.Font.Color := GetStyleTextColor($0);
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
        elvMain.Canvas.Font.Color := GetStyleTextColor($808080);
        Caption := L('No date');
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color := GetStyleTextColor($0);
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
          ElvMain.Canvas.Font.Color := GetStyleTextColor($808080);
          Caption := L('No time');
          DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), ARect, DrawTextOpt);
          ElvMain.Canvas.Font.Color := GetStyleTextColor($0);
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
        elvMain.Canvas.Font.Color := GetStyleTextColor($808080);
        DrawText(Sender.Canvas.Handle, PWideChar(Caption), Length(Caption), aRect, DrawTextOpt);
        elvMain.Canvas.Font.Color := GetStyleTextColor($0);
      end;
    end;
    5:
    begin
      if ItemData.Rotation > 0 then
      begin
        aRect.Top := aRect.Top + 1;
        DrawIconEx(Sender.Canvas.Handle, aRect.Left + (aRect.Right - aRect.Left) div 2 - 8, aRect.Top, UnitDBKernel.Icons[ItemData.Rotation + DB_IC_ROTATED_0 + 1], 16, 16, 0, 0, DI_NORMAL);
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
  I, J, N, L: integer;
  WorkQuery: TDataSet;
  DA: TDBAdapter;
  _sqlexectext: string;
  B: Boolean;
  ItemData: TDBPopupMenuInfoRecord;
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

function SpilitWords(S: string): TArray<string>;
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
  Words: TArray<string>;
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
          (FindComponent('N' + IntToStr(I) + '1') as TMenuItem).ExSetDefault(ItemData.Rating = I);
        PopupMenuRating.Popup(P.X, P. Y);
      end else if GetSubItemIndexByPoint(ElvMain, Item, P) = 5 then
      begin
        PopupMenuRotate.Tag := Item.Index;
        p := ElvMain.ClientToScreen(p);
        for I := 0 to 3 do
          (FindComponent('R0' + IntToStr(I + 1)) as TMenuItem).ExSetDefault(ItemData.Rotation = I);
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
                  Bit.Canvas.Brush.Color := clMenu;
                  Bit.Canvas.Pen.Color := clMenu;
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
          Bit.Canvas.Brush.Color := clMenu;
          Bit.Canvas.Pen.Color := clMenu;
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
  GroupsSelectForm.Execute(Groups, KeyWords);
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
          B.Canvas.Pen.Color := Theme.PanelColor;
          B.Canvas.Brush.Color := Theme.PanelColor;
          B.Canvas.Rectangle(0, 0, B.Width, B.Height);
          B.Canvas.Pen.Color := Theme.WindowColor;
          B.Canvas.Draw(ThSize div 2 - JPG.Width div 2, ThSize div 2 - JPG.Height div 2, JPG);
        finally
          F(JPG);
        end;
        ApplyRotate(B, ItemData.Rotation);
        DrawAttributes(B, ThSize, ItemData);
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
    TDBPopupMenu.Instance.Execute(Self, ElvMain.ClientToScreen(MousePos).X, ElvMain.ClientToScreen(MousePos).Y, MenuInfo);
  finally
    F(MenuInfo);
  end;
end;

procedure TManagerDB.DeleteItemWithID(ID: integer);
var
  I: Integer;
  SI: Integer;
  ItemData: TDBPopupMenuInfoRecord;
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

procedure TManagerDB.RefreshDBList;

begin

end;

procedure TManagerDB.RecordNumberEditChange(Sender: TObject);
var
  I, N: Integer;
  ItemData: TDBPopupMenuInfoRecord;
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

procedure TManagerDB.DuplicatesLinkClick(Sender: TObject);
begin
  if ID_OK = MessageBoxDB(Handle, L('Do you really want to optimize the duplicates in a table? Optimization starts at the next startup...'), L('Warning'), TD_BUTTON_OKCANCEL,
    TD_ICON_QUESTION) then
    Settings.WriteBool('StartUp', 'OptimizeDuplicates', True);
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
  GroupInfoForm.Execute(Self, StringReplace(TMenuItem(Sender).Caption, '&', '', []), False);
end;

procedure TManagerDB.ElvMainData(Sender: TObject; Item: TListItem);
begin
  Item.Data := FData[Item.Index];
end;

procedure TManagerDB.dblDataDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := Theme.WindowColor;
  Buffer.Canvas.Brush.Color := Theme.WindowColor;
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

initialization
  FormInterfaces.RegisterFormInterface(ICollectionManagerForm, TManagerDB);

end.
