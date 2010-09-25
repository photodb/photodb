unit UnitManageGroups;

interface

uses
  Dolphin_DB, UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, UnitGroupsTools, UnitDBkernel, UnitBitmapImageList,
  ComCtrls, AppEvnts, jpeg, ExtCtrls, StdCtrls, DB, Menus, Math,
  ImgList, NoVSBListView, uVistaFuncs, ToolWin, UnitDBCommonGraphics,
  UnitDBDeclare, uDBDrawing, uMemory, uDBForm;

type
  TFormManageGroups = class(TDBForm)
    ListView1: TNoVSBListView1;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    Actions1: TMenuItem;
    AddGroup1: TMenuItem;
    ShowAll1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    SelectFont1: TMenuItem;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    TbAdd: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    TbExit: TToolButton;
    ToolButton6: TToolButton;
    ToolBarImageList: TImageList;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure ImageContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    Procedure ChangeGroup(Sender : TObject);
    Procedure DeleteGroup(Sender : TObject);
    Procedure MenuActionQuickInfoGroup(Sender : TObject);
    Procedure MenuActionAddGroup(Sender : TObject);
    Procedure MenuActionSearchForGroup(Sender : TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadGroups;
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure ShowAll1Click(Sender: TObject);
    procedure SelectFont1Click(Sender: TObject);
    procedure TbExitClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FSaving: Boolean;
    FBitmapImageList: TBitmapImageList;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    Groups: TGroups;
    ImagePopupMenu: TPopupMenu;
    MenuChangeGroup: TMenuItem;
    MenuDeleteGroup: TMenuItem;
    MenuAddGroup: TMenuItem;
    MenuQuickInfoGroup: TMenuItem;
    MenuSearchForGroup: TMenuItem;
    procedure LoadLanguage;
    procedure Execute;
    procedure LoadToolBarIcons;
  end;

var
  FormManageGroups: TFormManageGroups;

Procedure ExecuteGroupManager;

implementation

uses UnitFormChangeGroup, UnitNewGroupForm, UnitQuickGroupInfo, Language,
  Searching, UnitSelectFontForm;

{$R *.dfm}

{ TFormManageGroups }

procedure ExecuteGroupManager;
begin
  Application.CreateForm(TFormManageGroups, FormManageGroups);
  try
    FormManageGroups.Execute;
  finally
    R(FormManageGroups);
  end;
end;

procedure TFormManageGroups.ChangeGroup(Sender: TObject);
begin
  DBChangeGroup(Groups[(Sender as TmenuItem).Owner.Tag]);
end;

procedure TFormManageGroups.Execute;
begin
  DBkernel.RecreateThemeToForm(Self);
  LoadGroups;
  if Length(Groups) > 0 then
    ShowModal
  else
  begin
    if ID_OK = MessageBoxDB(Handle, TEXT_MES_NO_GROUPS, TEXT_MES_WARNING, TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      CreateNewGroupDialog;
  end;
end;

procedure TFormManageGroups.FormCreate(Sender: TObject);
begin
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  DBKernel.RecreateThemeToForm(Self);
  FSaving := False;
  Caption := TEXT_MES_MANAGE_GROUPS;
  ListView1.DoubleBuffered := True;
  Width := Min(650, Round(Screen.Width / 1.3));
  ListView1.Columns[0].Caption := TEXT_MES_GROUPS_LIST;
  FBitmapImageList := TBitmapImageList.Create;
  MainMenu1.Images := DBKernel.ImageList;
  Exit1.ImageIndex := DB_IC_EXIT;
  Contents1.ImageIndex := DB_IC_HELP;
  AddGroup1.ImageIndex := DB_IC_NEW_SHELL;
  ShowAll1.ImageIndex := DB_IC_EXPLORER_PANEL;
  SelectFont1.ImageIndex := DB_IC_OPTIONS;
  LoadLanguage;
  ShowAll1.Checked := DBKernel.ReadBool('GroupsManager', 'ShowAllGroups', True);
  if ShowAll1.Checked then
    ShowAll1.ImageIndex := -1;
  LoadToolBarIcons;
end;

procedure TFormManageGroups.ImageContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if FSaving then
    Exit;
  if (Sender as TListView).GetItemAt(MousePos.X, MousePos.Y) = nil then
    Exit;
  ImagePopupMenu := TPopupMenu.Create(nil);
  ImagePopupMenu.Images := DBKernel.ImageList;
  ImagePopupMenu.Tag := (Sender as TListView).GetItemAt(MousePos.X, MousePos.Y).ImageIndex;

  MenuChangeGroup := TMenuItem.Create(ImagePopupMenu);
  MenuChangeGroup.Caption := TEXT_MES_CHANGE_GROUP;
  MenuChangeGroup.OnClick := ChangeGroup;
  MenuChangeGroup.ImageIndex := DB_IC_RENAME;
  MenuDeleteGroup := TMenuItem.Create(ImagePopupMenu);
  MenuDeleteGroup.Caption := TEXT_MES_DELETE_GROUP;
  MenuDeleteGroup.OnClick := DeleteGroup;
  MenuDeleteGroup.ImageIndex := DB_IC_DELETE_INFO;
  MenuAddGroup := TMenuItem.Create(ImagePopupMenu);
  MenuAddGroup.Caption := TEXT_MES_ADD_GROUP;
  MenuAddGroup.OnClick := MenuActionAddGroup;
  MenuAddGroup.ImageIndex := DB_IC_NEW_SHELL;

  MenuSearchForGroup := TmenuItem.Create(ImagePopupMenu);
  MenuSearchForGroup.Caption := TEXT_MES_SEARCH_FOR_GROUP;
  MenuSearchForGroup.ImageIndex := DB_IC_SEARCH;
  MenuSearchForGroup.OnClick := MenuActionSearchForGroup;
  MenuQuickInfoGroup := TmenuItem.Create(ImagePopupMenu);
  MenuQuickInfoGroup.Caption := TEXT_MES_QUICK_GROUP_INFO;
  MenuQuickInfoGroup.OnClick := MenuActionQuickInfoGroup;
  MenuQuickInfoGroup.ImageIndex := DB_IC_PROPERTIES;

  ImagePopupMenu.Items.Add(MenuChangeGroup);
  ImagePopupMenu.Items.Add(MenuDeleteGroup);
  ImagePopupMenu.Items.Add(MenuAddGroup);

  ImagePopupMenu.Items.Add(MenuSearchForGroup);
  ImagePopupMenu.Items.Add(MenuQuickInfoGroup);
  ImagePopupMenu.Popup((Sender as TControl).ClientToScreen(MousePos).X,
    (Sender as TControl).ClientToScreen(MousePos).Y);
  ImagePopupMenu.FreeOnRelease;
  ImagePopupMenu := nil;
end;

procedure TFormManageGroups.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  FreeGroups(Groups);
  FBitmapImageList.Free;
end;

procedure TFormManageGroups.LoadGroups;
var
  i : Integer;
  b : TBitmap;
begin
  ListView1.Items.BeginUpdate;
  try
    FreeGroups(Groups);
    Groups := GetRegisterGroupList(True, not DBKernel.ReadBool('GroupsManager', 'ShowAllGroups', True));
    FBitmapImageList.Clear;
    for I := 0 to Length(Groups) - 1 do
    begin
      B := TBitmap.Create;
      try
        B.PixelFormat := Pf24bit;
        B.Assign(Groups[I].GroupImage);
        FBitmapImageList.AddBitmap(B);
      finally
        B.Free;
      end;
    end;
    ListView1.Clear;
    for I := 0 to Length(Groups) - 1 do
      with ListView1.Items.Add do
        ImageIndex := I;

  finally
    ListView1.Items.EndUpdate;
  end;
end;

procedure TFormManageGroups.DeleteGroup(Sender: TObject);
var
  EventInfo : TEventValues;
  Index : integer;
begin
  if (Sender is TmenuItem) then
    Index := (Sender as TMenuItem).Owner.Tag
  else
    Index := (Sender as TComponent).Tag;

  if ID_OK = MessageBoxDB(Handle, Format(TEXT_MES_DELETE_GROUP_CONFIRM, [Groups[index].GroupName]), TEXT_MES_WARNING,
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
    if UnitGroupsWork.DeleteGroup(Groups[index]) then
    begin
      if ID_OK = MessageBoxDB(Handle, Format(TEXT_MES_DELETE_GROUP_IN_TABLE_CONFIRM, [Groups[index].GroupName]),
        TEXT_MES_WARNING, TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      begin
        FSaving := True;
        UnitGroupsTools.DeleteGroup(Groups[index]);
        MessageBoxDB(Handle, TEXT_MES_RELOAD_INFO, TEXT_MES_WARNING, TD_BUTTON_OKCANCEL, TD_ICON_WARNING);
        FSaving := False;
        DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged], EventInfo);
        Exit;
      end;
      DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged], EventInfo);
    end;
end;

procedure TFormManageGroups.MenuActionAddGroup(Sender: TObject);
begin
  CreateNewGroupDialog;
end;

procedure TFormManageGroups.MenuActionQuickInfoGroup(Sender: TObject);
begin
  ShowGroupInfo(Groups[(Sender as TmenuItem).Owner.Tag], True, Self);
end;

procedure TFormManageGroups.MenuActionSearchForGroup(Sender: TObject);
begin
  with SearchManager.NewSearch do
  begin
    SearchEdit.Text := ':Group(' + Groups[(Sender as TmenuItem).Owner.Tag].GroupName + '):';
    WlStartStop.OnClick(Sender);
    Show;
  end;
  Close;
end;

procedure TFormManageGroups.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
begin
  if EventID_Param_GroupsChanged in params then
    LoadGroups;
end;

procedure TFormManageGroups.ListView1CustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  r, r1, r2 : TRect;
  b, btext : TBitmap;
  textrect : TRect;
  size, i : integer;
  acaption, atext, akeyWords, aGroups, fn : string;
  axGroups : TGroups;
Const DrawTextOpt = DT_EDITCONTROL;
  DrawTextOpt1 = DT_NOPREFIX+DT_WORDBREAK+DT_EDITCONTROL;

  ThSize : integer = 48;

  function Darken(Color : TColor) : TColor;
  begin
   Result:=RGB(Round(0.75*GetRValue(Color)),Round(0.75*GetGValue(Color)),Round(0.75*GetBValue(Color)));
  end;

  function BothPercent(Color1,Color2 : TColor; percent : integer) : TColor;
  var
    r, g, b : byte;
    p : extended;
  begin
   p := (percent/100);
   r:=Round(p*GetRValue(Color1)+(p-1)*GetRValue(Color2));
   g:=Round(p*GetGValue(Color1)+(p-1)*GetGValue(Color2));
   b:=Round(p*GetBValue(Color1)+(p-1)*GetBValue(Color2));
   Result:=RGB(r,g,b);
  end;

begin
 r := Item.DisplayRect(drBounds);
 if not RectInRect(Sender.ClientRect,r) then exit;
 r1 := Item.DisplayRect(drIcon);
 r2 := Item.DisplayRect(drLabel);
 b := TBitmap.create;
 b.PixelFormat:=pf24bit;
 b.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);

 if item.ImageIndex>Length(Groups)-1 then exit;
 acaption:=Groups[item.ImageIndex].GroupName;
 atext:=Groups[item.ImageIndex].GroupComment;
 akeyWords:=Groups[item.ImageIndex].GroupKeyWords;

 SetLength(axGroups,0);
 axGroups:=UnitGroupsWork.EncodeGroups(Groups[item.ImageIndex].RelatedGroups);
 aGroups:='';
 for i:=0 to Length(axGroups)-1 do
 begin
  aGroups:=aGroups+axGroups[i].GroupName;
  if i<>Length(axGroups)-1 then
  aGroups:=aGroups+', '
 end;

 if not (Sender.IsEditing and (Sender.ItemFocused=Item)) then
 begin
 if Item.Selected then
 begin
  SelectedColor(b,RGB(Round(GetRValue(Theme_ListColor)*0.5),Round(GetGValue(Theme_ListColor)*0.5),Round(GetBValue(Theme_ListColor)*0.5)));
  Sender.Canvas.Pen.Color:=RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9));//$aa8888;
  Sender.Canvas.Brush.Color:=RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9));//$aa8888;
  Sender.Canvas.FillRect(r2);
 end else
 begin
  Sender.Canvas.Pen.Color:=Theme_ListColor;
  Sender.Canvas.Brush.Color:=Theme_ListColor;
  Sender.Canvas.FillRect(r2);
 end;

 if cdsHot in State then
 begin
  Sender.Canvas.Font.Style:=[fsUnderline];
 end else
 begin
  Sender.Canvas.Font.Style:=[];

  btext := TBitmap.Create;
  btext.PixelFormat:=pf24bit;
  btext.Width:=Max(0,r2.Right-r2.Left);
  btext.Height:=Max(0,r2.Bottom-r2.Top);
  btext.Canvas.Brush.Color:=Sender.Canvas.Brush.Color;
  btext.Canvas.pen.Color:=Sender.Canvas.Brush.Color;
  btext.Canvas.FillRect(Rect(0,0,btext.Width,btext.Height));

  fn:=DBKernel.ReadString('GroupsManager','FontName');
  if fn<>'' then
  btext.Canvas.Font.Name:=fn else btext.Canvas.Font.Name:='MS Sans Serif';
  if Groups[item.index].IncludeInQuickList then
  btext.Canvas.Font.Style:=[fsbold]+[fsUnderline] else
  btext.Canvas.Font.Style:=[fsbold];
  btext.Canvas.Font.Color:={ $0}Theme_ListFontColor;
  btext.Canvas.Font.Size:=10;
  textrect := Rect(5,0,(btext.Width div 4)*2-3,r2.Bottom);
  DrawText(btext.Canvas.Handle, PWideChar(acaption), Length(acaption), textrect, DrawTextOpt+DT_LEFT);
  size:=btext.Canvas.TextHeight(acaption);
  btext.Canvas.Font.Size:=8;

  if Length(aKeyWords)>0 then
  begin
   if Groups[item.index].AutoAddKeyWords then
   btext.Canvas.Font.Style:=[fsbold]+[fsUnderline] else
   btext.Canvas.Font.Style:=[fsbold];
   btext.Canvas.Font.Color:={ $FF4040} Theme_ListFontColor xor $FF0000;
   textrect := Rect((btext.Width div 4)*2+5,0,(btext.Width div 4)*3,btext.height);
   DrawText(btext.Canvas.Handle, PWideChar(TEXT_MES_KEYWORDS+':'), Length(TEXT_MES_KEYWORDS+':'), textrect, DrawTextOpt+DT_LEFT);
  end;
  if Length(axGroups)>0 then
  begin
   btext.Canvas.Font.Style:=[fsbold];
   btext.Canvas.Font.Color:=Theme_ListFontColor xor $008000;
   textrect := Rect((btext.Width div 4)*3+5,0,btext.Width,btext.height);
   DrawText(btext.Canvas.Handle, PWideChar(TEXT_MES_GROUPS+':'), Length(TEXT_MES_GROUPS+':'), textrect, DrawTextOpt+DT_LEFT);
  end;
  btext.Canvas.Font.Style:=[];
  btext.Canvas.Font.Color:= BothPercent(Theme_ListColor,Theme_ListFontColor,40);
  textrect:=rect(8,size,(btext.Width  div 4)*2-8,btext.Height);
  DrawText(btext.Canvas.Handle, PWideChar(atext), Length(atext), textrect, DrawTextOpt1+DT_LEFT);

  if Length(aKeyWords)>0 then
  begin
   textrect:=rect((btext.Width  div 4)*2+8,size,(btext.Width div 4)*3-8,btext.Height);
   DrawText(btext.Canvas.Handle, PWideChar(akeyWords), Length(akeyWords), textrect, DrawTextOpt1+DT_LEFT);
  end;

  if Length(axGroups)>0 then
  begin
   textrect:=rect((btext.Width div 4)*3+8,size,btext.Width-3,btext.Height);
   DrawText(btext.Canvas.Handle, PWideChar(aGroups), Length(aGroups), textrect, DrawTextOpt1+DT_LEFT);
  end;
  Sender.Canvas.Draw(r2.Left,r2.Top,btext);
  btext.free;
 end;
 end;
 Sender.Canvas.Draw(r1.Left+((r1.Right-r1.Left) div 2 - ThSize div 2),r1.Top  +(r1.Bottom-r1.Top) div 2 - b.Height div 2   ,b);
 b.free;
 DefaultDraw := false;
end;

procedure TFormManageGroups.FormShow(Sender: TObject);
begin
  Width := Width - 1;
end;

function TFormManageGroups.GetFormID: string;
begin
  Result := 'ManageGroups';
end;

procedure TFormManageGroups.ListView1DblClick(Sender: TObject);
var
  P: TPoint;
  Item: TListItem;
begin
  GetCursorPos(P);
  P := ListView1.ScreenToClient(P);
  Item := ListView1.GetItemAt(P.X, P.Y);
  if Item <> nil then
    ShowGroupInfo(Groups[Item.ImageIndex], True, Self);
end;

procedure TFormManageGroups.LoadLanguage;
begin
  TbExit.Caption := TEXT_MES_EXIT;
  TbAdd.Caption := TEXT_MES_ADD_GROUP;
  ToolButton2.Caption := TEXT_MES_EDIT;
  ToolButton3.Caption := TEXT_MES_DELETE;
  ToolButton8.Caption := TEXT_MES_OPTIONS;
  Help1.Caption := TEXT_MES_HELP;
  Contents1.Caption := TEXT_MES_CONTENTS;
  Actions1.Caption := TEXT_MES_ACTIONS;
  File1.Caption := TEXT_MES_FILE;
  Exit1.Caption := TEXT_MES_EXIT;
  ShowAll1.Caption := TEXT_MES_SHOW_ALL_GROUPS;
  SelectFont1.Caption := TEXT_MES_SELECT_FONT;
  AddGroup1.Caption := TEXT_MES_ADD_GROUP;
end;

procedure TFormManageGroups.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormManageGroups.Contents1Click(Sender: TObject);
begin
  DoHelp;
end;

procedure TFormManageGroups.ShowAll1Click(Sender: TObject);
begin
  ShowAll1.Checked := not ShowAll1.Checked;
  if ShowAll1.Checked then
    ShowAll1.ImageIndex := -1
  else
    ShowAll1.ImageIndex := DB_IC_EXPLORER_PANEL;
  DBKernel.WriteBool('GroupsManager', 'ShowAllGroups', ShowAll1.Checked);
  LoadGroups;
end;

procedure TFormManageGroups.SelectFont1Click(Sender: TObject);
var
  Fn, NewFont: string;
begin
  Fn := DBKernel.ReadString('GroupsManager', 'FontName');
  if Fn = '' then
    Fn := 'MS Sans Serif';
  if SelectFont(Fn, NewFont) then
    DBKernel.WriteString('GroupsManager', 'FontName', NewFont);
  ListView1.Refresh;
end;

procedure TFormManageGroups.LoadToolBarIcons;
var
  Ico: TIcon;

  procedure AddIcon(name: string);
  begin
    if DBKernel.Readbool('Options', 'UseSmallToolBarButtons', False) then
      name := name + '_SMALL';

    Ico := TIcon.Create;
    Ico.Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar(name));
    ToolBarImageList.AddIcon(Ico);
  end;

begin

  ConvertTo32BitImageList(ToolBarImageList);

  if DBKernel.Readbool('Options', 'UseSmallToolBarButtons', False) then
  begin
    ToolBarImageList.Width := 16;
    ToolBarImageList.Height := 16;
  end;

  AddIcon('GROUP_EXIT');
  AddIcon('GROUP_ADD');
  AddIcon('GROUP_EDIT');
  AddIcon('GROUP_DELETE');
  AddIcon('GROUP_OPTIONS');

  TbExit.ImageIndex := 0;
  TbAdd.ImageIndex := 1;
  ToolButton2.ImageIndex := 2;
  ToolButton3.ImageIndex := 3;
  ToolButton8.ImageIndex := 4;
end;

procedure TFormManageGroups.TbExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormManageGroups.ToolButton2Click(Sender: TObject);
begin
  if ListView1.Selected = nil then
    Exit;
  DBChangeGroup(Groups[ListView1.Selected.index]);
end;

procedure TFormManageGroups.ToolButton3Click(Sender: TObject);
begin
  if ListView1.Selected = nil then
    Exit;
  MainMenu1.Tag := ListView1.Selected.index;
  DeleteGroup(MainMenu1);
end;

procedure TFormManageGroups.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

end.
