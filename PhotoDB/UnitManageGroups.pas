unit UnitManageGroups;

interface

uses
  System.UITypes,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  jpeg,
  Winapi.CommCtrl,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ToolWin,
  Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.PathProviders,

  NoVSBListView,
  UnitDBkernel,
  UnitBitmapImageList,
  uBitmapUtils,
  ExplorerTypes,
  UnitDBDeclare,
  uDBDrawing,
  uConstants,
  uRuntime,
  uMemory,
  uMemoryEx,
  uDBForm,
  uGraphicUtils,
  uShellIntegration,
  Dolphin_DB,
  uGroupTypes,
  CommonDBSupport,
  UnitGroupsWork,
  uSettings,
  uThemesUtils,
  uExplorerGroupsProvider,
  uFormInterfaces;

type
  TFormManageGroups = class(TDBForm, IGroupsManagerForm)
    LvMain: TNoVSBListView1;
    ImlGroups: TImageList;
    MmMain: TMainMenu;
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
    TbEdit: TToolButton;
    TbDelete: TToolButton;
    ToolButton4: TToolButton;
    TbExit: TToolButton;
    ToolButton6: TToolButton;
    ToolBarImageList: TImageList;
    ToolButton7: TToolButton;
    TbOptions: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure ImageContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    Procedure ChangeGroup(Sender: TObject);
    Procedure DeleteGroup(Sender: TObject);
    Procedure MenuActionQuickInfoGroup(Sender : TObject);
    Procedure MenuActionAddGroup(Sender: TObject);
    Procedure MenuActionSearchForGroup(Sender : TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LvMainCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormShow(Sender: TObject);
    procedure LvMainDblClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure ShowAll1Click(Sender: TObject);
    procedure SelectFont1Click(Sender: TObject);
    procedure TbExitClick(Sender: TObject);
    procedure TbEditClick(Sender: TObject);
    procedure TbDeleteClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FSaving: Boolean;
    FBitmapImageList: TBitmapImageList;
    Groups: TGroups;
    ImagePopupMenu: TPopupActionBar;
    MenuChangeGroup: TMenuItem;
    MenuDeleteGroup: TMenuItem;
    MenuAddGroup: TMenuItem;
    MenuQuickInfoGroup: TMenuItem;
    MenuSearchForGroup: TMenuItem;
    procedure LoadLanguage;
    procedure LoadGroups;
    procedure LoadToolBarIcons;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure Execute;
  end;

implementation

uses
  UnitFormChangeGroup,
  uManagerExplorer,
  UnitSelectFontForm;

{$R *.dfm}

{ TFormManageGroups }

procedure TFormManageGroups.ChangeGroup(Sender: TObject);
begin
  DBChangeGroup(Groups[(Sender as TmenuItem).Owner.Tag]);
end;

procedure TFormManageGroups.Execute;
begin
  LoadGroups;
  if Length(Groups) > 0 then
    ShowModal
  else begin
    if not DBReadOnly then
      if ID_OK = MessageBoxDB(Handle, L('Groups in collection aren''t found! Do you want to create new group?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        GroupCreateForm.CreateGroup;
  end;
end;

procedure TFormManageGroups.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormManageGroups.FormCreate(Sender: TObject);
begin
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  FSaving := False;
  LvMain.DoubleBuffered := True;
  Width := Min(650, Round(Screen.Width / 1.3));
  FBitmapImageList := TBitmapImageList.Create;
  MmMain.Images := DBKernel.ImageList;
  Exit1.ImageIndex := DB_IC_EXIT;
  Contents1.ImageIndex := DB_IC_HELP;
  AddGroup1.ImageIndex := DB_IC_NEW_SHELL;
  ShowAll1.ImageIndex := DB_IC_EXPLORER_PANEL;
  SelectFont1.ImageIndex := DB_IC_OPTIONS;
  LoadLanguage;
  ShowAll1.Checked := Settings.ReadBool('GroupsManager', 'ShowAllGroups', True);
  if ShowAll1.Checked then
    ShowAll1.ImageIndex := -1;
  LoadToolBarIcons;
  ImagePopupMenu := nil;
  if DBReadOnly then
  begin
    AddGroup1.Enabled := False;
    TbAdd.Enabled := False;
    TbEdit.Enabled := False;
    TbDelete.Enabled := False;
  end;
end;

procedure TFormManageGroups.ImageContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if FSaving then
    Exit;
  if (Sender as TListView).GetItemAt(MousePos.X, MousePos.Y) = nil then
    Exit;
  F(ImagePopupMenu);
  ImagePopupMenu := TPopupActionBar.Create(Self);
  ImagePopupMenu.Images := DBKernel.ImageList;
  ImagePopupMenu.Tag := (Sender as TListView).GetItemAt(MousePos.X, MousePos.Y).ImageIndex;

  MenuChangeGroup := TMenuItem.Create(ImagePopupMenu);
  MenuChangeGroup.Caption := L('Edit group');
  MenuChangeGroup.OnClick := ChangeGroup;
  MenuChangeGroup.ImageIndex := DB_IC_RENAME;
  MenuDeleteGroup := TMenuItem.Create(ImagePopupMenu);
  MenuDeleteGroup.Caption := L('Delete group');
  MenuDeleteGroup.OnClick := DeleteGroup;
  MenuDeleteGroup.ImageIndex := DB_IC_DELETE_INFO;
  MenuAddGroup := TMenuItem.Create(ImagePopupMenu);
  MenuAddGroup.Caption := L('Create group');
  MenuAddGroup.OnClick := MenuActionAddGroup;
  MenuAddGroup.ImageIndex := DB_IC_NEW_SHELL;

  MenuSearchForGroup := TmenuItem.Create(ImagePopupMenu);
  MenuSearchForGroup.Caption := L('Search images of group');
  MenuSearchForGroup.ImageIndex := DB_IC_SEARCH;
  MenuSearchForGroup.OnClick := MenuActionSearchForGroup;
  MenuQuickInfoGroup := TmenuItem.Create(ImagePopupMenu);
  MenuQuickInfoGroup.Caption := L('Group info');
  MenuQuickInfoGroup.OnClick := MenuActionQuickInfoGroup;
  MenuQuickInfoGroup.ImageIndex := DB_IC_PROPERTIES;

  ImagePopupMenu.Items.Add(MenuChangeGroup);
  ImagePopupMenu.Items.Add(MenuDeleteGroup);
  ImagePopupMenu.Items.Add(MenuAddGroup);

  ImagePopupMenu.Items.Add(MenuSearchForGroup);
  ImagePopupMenu.Items.Add(MenuQuickInfoGroup);
  ImagePopupMenu.Popup((Sender as TControl).ClientToScreen(MousePos).X,
    (Sender as TControl).ClientToScreen(MousePos).Y);
end;

procedure TFormManageGroups.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormManageGroups.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  FreeGroups(Groups);
  F(FBitmapImageList);
  F(ImagePopupMenu);
end;

procedure TFormManageGroups.LoadGroups;
var
  I: Integer;
  B: TBitmap;
begin
  LvMain.Items.BeginUpdate;
  try
    FreeGroups(Groups);
    Groups := GetRegisterGroupList(True, not Settings.ReadBool('GroupsManager', 'ShowAllGroups', True));
    FBitmapImageList.Clear;
    for I := 0 to Length(Groups) - 1 do
    begin
      B := TBitmap.Create;
      try
        B.PixelFormat := pf24bit;
        B.Assign(Groups[I].GroupImage);
        FBitmapImageList.AddBitmap(B, False);
      finally
        F(B);
      end;
    end;
    LvMain.Clear;
    for I := 0 to Length(Groups) - 1 do
      with LvMain.Items.Add do
        ImageIndex := I;

  finally
    LvMain.Items.EndUpdate;
  end;
end;

procedure TFormManageGroups.DeleteGroup(Sender: TObject);
var
  Index: Integer;
  GI: TGroupItem;
  Items: TPathItemCollection;
begin
  if (Sender is TmenuItem) then
    Index := (Sender as TMenuItem).Owner.Tag
  else
    Index := (Sender as TComponent).Tag;

  FSaving := True;
  try
    GI := TGroupItem.Create;
    try
      GI.ReadFromGroup(Groups[Index], PATH_LOAD_NO_IMAGE, 0);

      Items := TPathItemCollection.Create;
      try
        Items.Add(GI);
        GI.Provider.ExecuteFeature(Self, Items, PATH_FEATURE_DELETE, nil);
      finally
        F(Items);
      end;
    finally
      F(GI);
    end;
  finally
    FSaving := False;
  end;
end;

procedure TFormManageGroups.MenuActionAddGroup(Sender: TObject);
begin
  GroupCreateForm.CreateGroup;
end;

procedure TFormManageGroups.MenuActionQuickInfoGroup(Sender: TObject);
begin
  GroupInfoForm.Execute(Self, Groups[(Sender as TmenuItem).Owner.Tag], True);
end;

procedure TFormManageGroups.MenuActionSearchForGroup(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cGroupsPath + '\' + Groups[(Sender as TmenuItem).Owner.Tag].GroupName);
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

procedure TFormManageGroups.LvMainCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  R, R1, R2: TRect;
  B, Btext: TBitmap;
  Textrect: TRect;
  Size, I: Integer;
  Acaption, Atext, AkeyWords, AGroups, Fn: string;
  AxGroups: TGroups;

const
  DrawTextOpt = DT_EDITCONTROL;
  DrawTextOpt1 = DT_NOPREFIX + DT_WORDBREAK + DT_EDITCONTROL;
  ThSize: Integer = 48;

begin
  R := Item.DisplayRect(DrBounds);
  if not RectInRect(Sender.ClientRect, R) then
    Exit;
  R1 := Item.DisplayRect(DrIcon);
  R2 := Item.DisplayRect(DrLabel);
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    B.Assign(FBitmapImageList[Item.ImageIndex].Bitmap);

    if Item.ImageIndex > Length(Groups) - 1 then
      Exit;
    Acaption := Groups[Item.ImageIndex].GroupName;
    Atext := Groups[Item.ImageIndex].GroupComment;
    AkeyWords := Groups[Item.ImageIndex].GroupKeyWords;

    SetLength(AxGroups, 0);
    AxGroups := uGroupTypes.EncodeGroups(Groups[Item.ImageIndex].RelatedGroups);
    AGroups := '';
    for I := 0 to Length(AxGroups) - 1 do
    begin
      AGroups := AGroups + AxGroups[I].GroupName;
      if I <> Length(AxGroups) - 1 then
        AGroups := AGroups + ', '
    end;

    if not(Sender.IsEditing and (Sender.ItemFocused = Item)) then
    begin
      if Item.Selected then
      begin
        SelectedColor(B, MakeDarken(Theme.WindowColor, 0.5));
        Sender.Canvas.Pen.Color := MakeDarken(Theme.WindowColor,  0.9);
        Sender.Canvas.Brush.Color := MakeDarken(Theme.WindowColor,  0.9);
        Sender.Canvas.FillRect(R2);
      end else
      begin
        Sender.Canvas.Pen.Color := Theme.WindowColor;
        Sender.Canvas.Brush.Color := Theme.WindowColor;
        Sender.Canvas.FillRect(R2);
      end;

      if CdsHot in State then
      begin
        Sender.Canvas.Font.Style := [FsUnderline];
      end else
      begin
        Sender.Canvas.Font.Style := [];

        Btext := TBitmap.Create;
        try
          Btext.PixelFormat := pf24bit;
          Btext.Width := Max(0, R2.Right - R2.Left);
          Btext.Height := Max(0, R2.Bottom - R2.Top);
          Btext.Canvas.Brush.Color := Sender.Canvas.Brush.Color;
          Btext.Canvas.Pen.Color := Sender.Canvas.Brush.Color;
          Btext.Canvas.FillRect(Rect(0, 0, Btext.Width, Btext.Height));

          Fn := Settings.ReadString('GroupsManager', 'FontName');
          if Fn <> '' then
            Btext.Canvas.Font.name := Fn
          else
            Btext.Canvas.Font.name := 'Tahoma';
          if Groups[Item.index].IncludeInQuickList then
            Btext.Canvas.Font.Style := [Fsbold] + [FsUnderline]
          else
            Btext.Canvas.Font.Style := [Fsbold];
          Btext.Canvas.Font.Color := Theme.WindowTextColor;
          Btext.Canvas.Font.Size := 10;
          Textrect := Rect(5, 0, (Btext.Width div 4) * 2 - 3, R2.Bottom);
          DrawText(Btext.Canvas.Handle, PWideChar(Acaption), Length(Acaption), Textrect, DrawTextOpt + DT_LEFT);
          Size := Btext.Canvas.TextHeight(Acaption);
          Btext.Canvas.Font.Size := 8;

          if Length(AKeyWords) > 0 then
          begin
            if Groups[Item.index].AutoAddKeyWords then
              Btext.Canvas.Font.Style := [Fsbold] + [FsUnderline]
            else
              Btext.Canvas.Font.Style := [Fsbold];
            Btext.Canvas.Font.Color := ColorToRGB(Theme.WindowTextColor) xor $FF0000;
            Textrect := Rect((Btext.Width div 4) * 2 + 5, 0, (Btext.Width div 4) * 3, Btext.Height);
            DrawText(Btext.Canvas.Handle, PWideChar(L('Keywords') + ':'), Length(L('Keywords') + ':'), Textrect,
              DrawTextOpt + DT_LEFT);
          end;
          if Length(AxGroups) > 0 then
          begin
            Btext.Canvas.Font.Style := [Fsbold];
            Btext.Canvas.Font.Color := ColorToRGB(Theme.WindowTextColor) xor $008000;
            Textrect := Rect((Btext.Width div 4) * 3 + 5, 0, Btext.Width, Btext.Height);
            DrawText(Btext.Canvas.Handle, PWideChar(L('Groups') + ':'), Length(L('Groups') + ':'), Textrect,
              DrawTextOpt + DT_LEFT);
          end;
          Btext.Canvas.Font.Style := [];
          Btext.Canvas.Font.Color := MixColors(Theme.WindowColor, Theme.WindowTextColor, 40);
          Textrect := Rect(8, Size, (Btext.Width div 4) * 2 - 8, Btext.Height);
          DrawText(Btext.Canvas.Handle, PWideChar(Atext), Length(Atext), Textrect, DrawTextOpt1 + DT_LEFT);

          if Length(AKeyWords) > 0 then
          begin
            Textrect := Rect((Btext.Width div 4) * 2 + 8, Size, (Btext.Width div 4) * 3 - 8, Btext.Height);
            DrawText(Btext.Canvas.Handle, PWideChar(AkeyWords), Length(AkeyWords), Textrect, DrawTextOpt1 + DT_LEFT);
          end;

          if Length(AxGroups) > 0 then
          begin
            Textrect := Rect((Btext.Width div 4) * 3 + 8, Size, Btext.Width - 3, Btext.Height);
            DrawText(Btext.Canvas.Handle, PWideChar(AGroups), Length(AGroups), Textrect, DrawTextOpt1 + DT_LEFT);
          end;
          Sender.Canvas.Draw(R2.Left, R2.Top, Btext);
        finally
          Btext.Free;
        end;
      end;
    end;
    Sender.Canvas.Draw(R1.Left + ((R1.Right - R1.Left) div 2 - ThSize div 2),
      R1.Top + (R1.Bottom - R1.Top) div 2 - B.Height div 2, B);

  finally
    F(B);
  end;
  DefaultDraw := False;
end;

procedure TFormManageGroups.FormShow(Sender: TObject);
begin
  Width := Width - 1;
end;

function TFormManageGroups.GetFormID: string;
begin
  Result := 'ManageGroups';
end;

procedure TFormManageGroups.LvMainDblClick(Sender: TObject);
var
  P: TPoint;
  Item: TListItem;
begin
  GetCursorPos(P);
  P := LvMain.ScreenToClient(P);
  Item := LvMain.GetItemAt(P.X, P.Y);
  if Item <> nil then
    GroupInfoForm.Execute(Self, Groups[Item.ImageIndex], True);
end;

procedure TFormManageGroups.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Manage groups');
    LvMain.Columns[0].Caption := L('List of groups');
    TbExit.Caption := L('Exit');
    TbAdd.Caption := L('Create group');
    TbEdit.Caption := L('Edit');
    TbDelete.Caption := L('Delete');
    TbOptions.Caption := L('Options');
    Help1.Caption := L('Help');
    Contents1.Caption := L('Content');
    Actions1.Caption := L('Actions');
    File1.Caption := L('File');
    Exit1.Caption := L('Exit');
    ShowAll1.Caption := L('All groups');
    SelectFont1.Caption := L('Select font');
    AddGroup1.Caption := L('Create group');
  finally
    EndTranslate;
  end;
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
  Settings.WriteBool('GroupsManager', 'ShowAllGroups', ShowAll1.Checked);
  LoadGroups;
end;

procedure TFormManageGroups.SelectFont1Click(Sender: TObject);
var
  Fn, NewFont: string;
begin
  Fn := Settings.ReadString('GroupsManager', 'FontName');
  if Fn = '' then
    Fn := 'Tahoma';
  if SelectFont(Fn, NewFont) then
    Settings.WriteString('GroupsManager', 'FontName', NewFont);
  LvMain.Refresh;
end;

procedure TFormManageGroups.LoadToolBarIcons;
var
  Ico: HIcon;

  procedure AddIcon(name: string);
  begin
    if Settings.Readbool('Options', 'UseSmallToolBarButtons', False) then
      name := name + '_SMALL';

    Ico := LoadIcon(HInstance, PWideChar(name));
    ImageList_ReplaceIcon(ToolBarImageList.Handle, -1, Ico);
    DestroyIcon(Ico);
  end;

begin
  if Settings.Readbool('Options', 'UseSmallToolBarButtons', False) then
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
  TbEdit.ImageIndex := 2;
  TbDelete.ImageIndex := 3;
  TbOptions.ImageIndex := 4;
end;

procedure TFormManageGroups.TbExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormManageGroups.TbEditClick(Sender: TObject);
begin
  if LvMain.Selected = nil then
    Exit;
  DBChangeGroup(Groups[LvMain.Selected.index]);
end;

procedure TFormManageGroups.TbDeleteClick(Sender: TObject);
begin
  if LvMain.Selected = nil then
    Exit;
  MmMain.Tag := LvMain.Selected.index;
  DeleteGroup(Sender);
end;

procedure TFormManageGroups.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(IGroupsManagerForm, TFormManageGroups);

end.
