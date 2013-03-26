unit UnitEditGroupsForm;

interface

uses
  System.UITypes,
  System.SysUtils,
  System.Math,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Imaging.JPEG,
  Vcl.Imaging.pngimage,

  Dmitry.Controls.WatermarkedEdit,

  UnitDBKernel,
  CmpUnit,
  UnitGroupsWork,
  UnitGroupsTools,
  UnitDBDeclare,

  uMemory,
  uGroupTypes,
  uBitmapUtils,
  uDBForm,
  uShellIntegration,
  uVCLHelpers,
  uGraphicUtils,
  uConstants,
  uSettings,
  uThemesUtils,
  uMachMask,
  uProgramStatInfo,
  uFormInterfaces;

type
  TEditGroupsForm = class(TDBForm, IGroupsSelectForm)
    BtnCancel: TButton;
    BtnOk: TButton;
    BtnCreateGroup: TButton;
    PmGroup: TPopupActionBar;
    Delete1: TMenuItem;
    N1: TMenuItem;
    CreateGroup1: TMenuItem;
    ChangeGroup1: TMenuItem;
    GroupManeger1: TMenuItem;
    PmGroupsManager: TPopupActionBar;
    GroupManeger2: TMenuItem;
    QuickInfo1: TMenuItem;
    PmClear: TPopupActionBar;
    Clear1: TMenuItem;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    ApplicationEvents1: TApplicationEvents;
    SearchForGroup1: TMenuItem;
    GroupsImageList: TImageList;
    LstSelectedGroups: TListBox;
    LstAvaliableGroups: TListBox;
    BtnRemoveGroup: TButton;
    BtnAddGroup: TButton;
    CbRemoveKeywords: TCheckBox;
    CbShowAllGroups: TCheckBox;
    MoveToGroup1: TMenuItem;
    LbInfo: TLabel;
    WedGroupsFilter: TWatermarkedEdit;
    ImSearch: TImage;
    TmrFilter: TTimer;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnCreateGroupClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnAddGroupClick(Sender: TObject);
    procedure LstSelectedGroupsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ChangeGroup1Click(Sender: TObject);
    procedure CreateGroup1Click(Sender: TObject);
    procedure RecreateGroupsList;
    procedure PmGroupPopup(Sender: TObject);
    procedure QuickInfo1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure ComboBoxEx1_KeyPress(Sender: TObject; var Key: Char);
    procedure LstSelectedGroupsDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure CbShowAllGroupsClick(Sender: TObject);
    procedure CbRemoveKeywordsClick(Sender: TObject);
    procedure LstAvaliableGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BtnRemoveGroupClick(Sender: TObject);
    procedure MoveToGroup1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure WedGroupsFilterChange(Sender: TObject);
    procedure TmrFilterTimer(Sender: TObject);
  private
    { Private declarations }
    FGroups: TGroups;
    FRegGroups: TGroups;
    FShowenRegGroups: TGroups;
    FSetGroups: TGroups;
    FNewKeyWords: string;
    FResult: Boolean;
    FOldGroups: TGroups;
    FOldKeyWords: string;
    function AGetGroupByCode(GroupCode: string): Integer;
    procedure FillGroupList;
    procedure ChangedDBDataGroups(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure Execute(var Groups: TGroups; var KeyWords: string; CanNew: Boolean = True); overload;
    procedure Execute(var Groups: string; var KeyWords: string; CanNew: Boolean = True); overload;
  end;

implementation

uses
  UnitFormChangeGroup,
  SelectGroupForm,
  uManagerExplorer;

{$R *.dfm}

{ TEditGroupsForm }

procedure TEditGroupsForm.Execute(var Groups, KeyWords: string; CanNew: Boolean);
var
  FGroups: TGroups;
begin
  FGroups := EncodeGroups(Groups);
  Execute(FGroups, KeyWords, CanNew);
  Groups := CodeGroups(FGroups);
end;

procedure TEditGroupsForm.Execute(var Groups: TGroups; var KeyWords: String; CanNew: Boolean = True);
var
  I: Integer;
begin
  if not CanNew then
    BtnCreateGroup.Enabled := False;

  FResult := False;
  FNewKeyWords := KeyWords;
  FOldGroups := CopyGroups(Groups);
  FOldKeyWords := KeyWords;
  FGroups := CopyGroups(Groups);
  FSetGroups := CopyGroups(Groups);
  LstSelectedGroups.Clear;
  for I := 0 to Length(Groups) - 1 do
    LstSelectedGroups.Items.Add(Groups[I].GroupName);

  ShowModal;
  FreeGroups(Groups);
  if FResult then
  begin
    Groups := CopyGroups(FSetGroups);
    KeyWords := FNewKeyWords;
  end else
  begin
    Groups := CopyGroups(FOldGroups);
    KeyWords := FOldKeyWords;
  end;
  FreeGroups(FSetGroups);
  Close;
end;

procedure TEditGroupsForm.BtnCancelClick(Sender: TObject);
begin
  FResult := False;
  Close;
end;

procedure TEditGroupsForm.FormCreate(Sender: TObject);
begin
  SetLength(FGroups, 0);
  SetLength(FRegGroups, 0);
  SetLength(FShowenRegGroups, 0);

  LstAvaliableGroups.Color := Theme.ListColor;
  LstSelectedGroups.Color := Theme.ListColor;

  RecreateGroupsList;
  DBKernel.RegisterChangesID(Self, ChangedDBDataGroups);
  LoadLanguage;
  CbRemoveKeywords.Checked := Settings.ReadBool('Propetry', 'DeleteKeyWords', True);
  CbShowAllGroups.Checked := Settings.ReadBool('Propetry', 'ShowAllGroups', False);

  FixFormPosition;
end;

procedure TEditGroupsForm.FormDestroy(Sender: TObject);
begin
  FreeGroups(FRegGroups);
  FreeGroups(FShowenRegGroups);
  FreeGroups(FOldGroups);
  FreeGroups(FSetGroups);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataGroups);
end;

procedure TEditGroupsForm.BtnCreateGroupClick(Sender: TObject);
begin
  GroupCreateForm.CreateGroup;
end;

procedure TEditGroupsForm.BtnOkClick(Sender: TObject);
var
  I: Integer;
  FGroup: TGroup;
begin
  FResult := True;

  //statistics
  ProgramStatistics.GroupUsed;

  FreeGroups(FGroups);
  for I := 1 to LstSelectedGroups.Items.Count do
  begin
    SetLength(FGroups, Length(FGroups) + 1);
    FGroups[Length(FGroups) - 1].GroupName := LstSelectedGroups.Items[I - 1];
    FGroup := GetGroupByGroupName(LstSelectedGroups.Items[I - 1], False);
    FGroups[Length(FGroups) - 1].GroupCode := FGroup.GroupCode;
    if FGroup.AutoAddKeyWords then
      AddWordsA(FGroup.GroupKeyWords, FNewKeyWords);
  end;
  FreeGroups(FSetGroups);
  FSetGroups := CopyGroups(FGroups);
  Close;
end;

procedure TEditGroupsForm.BtnAddGroupClick(Sender: TObject);
var
  I: Integer;

  procedure AddGroup(Group: TGroup);
  var
    FRelatedGroups: TGroups;
    OldGroups, Groups: TGroups;
    TempGroup: TGroup;
    I: Integer;
  begin
    // добавляем связанные группы
    FRelatedGroups := EncodeGroups(Group.RelatedGroups);
    // сохраняем что имели
    OldGroups := CopyGroups(FSetGroups);
    try
      // копируем?
      Groups := CopyGroups(OldGroups);
      try

        // добавили группу и связанные с ней группы
        AddGroupToGroups(Groups, Group);
        AddGroupsToGroups(Groups, FRelatedGroups);

        // занесли это всё в FSetGroups - результат
        FreeGroups(FSetGroups);
        FSetGroups := CopyGroups(Groups);

        // получили все новые группы путём вычитания со старым
        RemoveGroupsFromGroups(Groups, OldGroups);
        for I := 0 to Length(Groups) - 1 do
        begin
          // добавляем группу и ключевые слова к ней
          LstSelectedGroups.Items.Add(Groups[I].GroupName);
          TempGroup := GetGroupByGroupCode(Groups[I].GroupCode, False);
          AddWordsA(TempGroup.GroupKeyWords, FNewKeyWords);
        end;
      finally
        FreeGroups(Groups);
      end;
    finally
      FreeGroups(OldGroups);
    end;
  end;

begin
  // добавляем выделенные групы в ListBox2
  for I := 0 to LstAvaliableGroups.Items.Count - 1 do
    if LstAvaliableGroups.Selected[I] then
      AddGroup(FShowenRegGroups[I]);

  BeginScreenUpdate(LstSelectedGroups.Handle);
  BeginScreenUpdate(LstSelectedGroups.Handle);
  try
    LstSelectedGroups.Invalidate;
    LstAvaliableGroups.Invalidate;
  finally
    EndScreenUpdate(LstSelectedGroups.Handle, False);
    EndScreenUpdate(LstSelectedGroups.Handle, False);
  end;
end;

procedure TEditGroupsForm.LstSelectedGroupsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ItemNo: Integer;
  I: integer;
begin
  ItemNo := LstSelectedGroups.ItemAtPos(MousePos, True);
  if ItemNo<>-1 then
  begin
    if not LstSelectedGroups.Selected[ItemNo] then
    begin
      LstSelectedGroups.Selected[ItemNo] := True;
      for I := 0 to LstSelectedGroups.Items.Count - 1 do
        if I <> ItemNo then
          LstSelectedGroups.Selected[I] := False;
    end;
    PmGroup.Tag := ItemNo;
    PmGroup.Popup(LstSelectedGroups.ClientToScreen(MousePos).X, LstSelectedGroups.ClientToScreen(MousePos).Y);
  end else
  begin
    PmClear.Popup(LstSelectedGroups.ClientToScreen(MousePos).X, LstSelectedGroups.ClientToScreen(MousePos).Y);
  end;
end;

procedure TEditGroupsForm.ChangeGroup1Click(Sender: TObject);
var
  Group: TGroup;
begin
  Group := GetGroupByGroupCode(FindGroupCodeByGroupName(LstSelectedGroups.Items[PmGroup.Tag]), False);
  DBChangeGroup(Group);
end;

function TEditGroupsForm.GetFormID: string;
begin
  Result := 'EditGroupsList';
end;

procedure TEditGroupsForm.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TEditGroupsForm.CreateGroup1Click(Sender: TObject);
begin
  GroupCreateForm.CreateFixedGroup(FGroups[PmGroup.Tag].GroupName, FGroups[PmGroup.Tag].GroupCode);
end;

procedure TEditGroupsForm.CustomFormAfterDisplay;
begin
  inherited;
  if WedGroupsFilter <> nil then
    WedGroupsFilter.Refresh;
end;

procedure TEditGroupsForm.FillGroupList;
var
  I: Integer;
  Filter, Key: string;
begin
  FreeGroups(FShowenRegGroups);
  LstAvaliableGroups.Clear;
  Filter := AnsiLowerCase(WedGroupsFilter.Text);

  if Pos('*', Filter) = 0 then
    Filter := '*' + Filter + '*';

  for I := 0 to Length(FRegGroups) - 1 do
  begin
    Key := AnsiLowerCase(FRegGroups[I].GroupName + ' ' + FRegGroups[I].GroupComment + ' ' + FRegGroups[I].GroupKeyWords);
    if (FRegGroups[I].IncludeInQuickList or CbShowAllGroups.Checked) and IsMatchMask(Key, Filter) then
    begin
      uGroupTypes.AddGroupToGroups(FShowenRegGroups, FRegGroups[I]);
      LstAvaliableGroups.Items.AddObject(FRegGroups[I].GroupName, TObject(I));
    end;
  end;
end;

procedure TEditGroupsForm.RecreateGroupsList;
var
  I, Size: Integer;
  SmallB, B: TBitmap;
begin
  FreeGroups(FRegGroups);
  FRegGroups := GetRegisterGroupList(True);

  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    SmallB.Width := 32;
    SmallB.Height := 32 + 2;
    SmallB.Canvas.Pen.Color := Theme.ListColor;
    SmallB.Canvas.Brush.Color := Theme.ListColor;
    SmallB.Canvas.Rectangle(0, 0, SmallB.Width, SmallB.Height);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], SmallB.Width div 2 - 8,
      SmallB.Height div 2 - 8, 0, 0, DI_NORMAL);
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;
  for I := 0 to Length(FRegGroups) - 1 do
  begin
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf24bit;
      SmallB.Canvas.Brush.Color := Theme.ListColor;
      if FRegGroups[I].GroupImage <> nil then
        if not FRegGroups[I].GroupImage.Empty then
        begin
          B := TBitmap.Create;
          try
            B.PixelFormat := pf24bit;
            B.Canvas.Brush.Color := Theme.ListColor;
            B.Canvas.Pen.Color := Theme.ListColor;
            Size := Max(FRegGroups[I].GroupImage.Width, FRegGroups[I].GroupImage.Height);
            B.Width := Size;
            B.Height := Size;
            B.Canvas.Rectangle(0, 0, Size, Size);
            B.Canvas.Draw(B.Width div 2 - FRegGroups[I].GroupImage.Width div 2,
              B.Height div 2 - FRegGroups[I].GroupImage.Height div 2, FRegGroups[I].GroupImage);
            DoResize(32, 34, B, SmallB);
          finally
            F(B);
          end;
        end;
      GroupsImageList.Add(SmallB, nil);
    finally
      F(SmallB);
    end;
  end;

  FillGroupList;
end;

procedure TEditGroupsForm.PmGroupPopup(Sender: TObject);
begin
  if GroupWithCodeExists(FSetGroups[PmGroup.Tag].GroupCode) then
  begin
    CreateGroup1.Visible := False;
    MoveToGroup1.Visible := False;
    ChangeGroup1.Visible := True;
  end else
  begin
    CreateGroup1.Visible := True;
    MoveToGroup1.Visible := True;
    ChangeGroup1.Visible := False;
  end;
end;

procedure TEditGroupsForm.QuickInfo1Click(Sender: TObject);
begin
  GroupInfoForm.Execute(nil, FSetGroups[PmGroup.Tag], False);
end;

procedure TEditGroupsForm.Clear1Click(Sender: TObject);
begin
  LstSelectedGroups.Clear;
  FreeGroups(FSetGroups);
  LstSelectedGroups.Invalidate;
  LstAvaliableGroups.Invalidate;
end;

procedure TEditGroupsForm.ComboBoxEx1_KeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TEditGroupsForm.LstSelectedGroupsDblClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to LstSelectedGroups.Items.Count - 1 do
  if LstSelectedGroups.Selected[I] then
    begin
      GroupInfoForm.Execute(nil, FSetGroups[I], False);
      Break;
    end;
end;

procedure TEditGroupsForm.FormShow(Sender: TObject);
begin
  BtnOk.SetFocus;
end;

procedure TEditGroupsForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Edit groups');
    BtnCreateGroup.Caption := L('Create group');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    Label2.Caption := L('Available groups') + ':';
    Label1.Caption := L('Selected groups') + ':';
    Clear1.Caption := L('Clear');
    GroupManeger2.Caption := L('Groups manager');
    Delete1.Caption := L('Delete');
    CreateGroup1.Caption := L('Create group');
    ChangeGroup1.Caption := L('Change group');
    GroupManeger1.Caption := L('Groups manager');
    QuickInfo1.Caption := L('Group info');
    SearchForGroup1.Caption := L('Search group photos');
    CbShowAllGroups.Caption := L('Show all groups');
    CbRemoveKeywords.Caption := L('Delete group comments');
    MoveToGroup1.Caption := L('Move to group');
    LbInfo.Caption := L('Use button "-->" to add new groups or button "<--" to remove them');
    WedGroupsFilter.WatermarkText := L('Filter groups');
  finally
    EndTranslate;
  end;
end;

procedure TEditGroupsForm.ApplicationEvents1Message(var Msg: TagMSG; var Handled: Boolean);
begin
  if (Msg.Hwnd = LstSelectedGroups.Handle)
    and (Msg.message = WM_KEYDOWN)
    and (Msg.wParam = VK_DELETE) then
  BtnRemoveGroupClick(Self);
end;

procedure TEditGroupsForm.SearchForGroup1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cGroupsPath + '\' + FSetGroups[PmGroup.Tag].GroupName);
    Show;
  end;
end;

procedure TEditGroupsForm.TmrFilterTimer(Sender: TObject);
begin
  TmrFilter.Enabled := False;
  FillGroupList;
end;

procedure TEditGroupsForm.WedGroupsFilterChange(Sender: TObject);
begin
  TmrFilter.Restart;
end;

procedure TEditGroupsForm.CbShowAllGroupsClick(Sender: TObject);
begin
  RecreateGroupsList;
  Settings.WriteBool('Propetry','ShowAllGroups', CbShowAllGroups.Checked);
end;

procedure TEditGroupsForm.CbRemoveKeywordsClick(Sender: TObject);
begin
  Settings.WriteBool('Propetry','DeleteKeyWords', CbRemoveKeywords.Checked);
end;

procedure TEditGroupsForm.LstAvaliableGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  N, I: Integer;
  xNewGroups: TGroups;
  FC, C: TColor;
  IsChoosed: Boolean;
  ACanvas: TCanvas;
  LB: TListBox;

  function NewGroup(GroupCode : String) : Boolean;
  var
    J: Integer;
  begin
   Result:=false;
   for J := 0 to Length(xNewGroups) - 1 do
      if XNewGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

  function GroupExists(GroupCode: string): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to Length(FSetGroups) - 1 do
      if FSetGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

begin

  if Control = LstSelectedGroups then
  begin
    XNewGroups := CopyGroups(FSetGroups);
    RemoveGroupsFromGroups(XNewGroups, FOldGroups);
  end else
  begin
    XNewGroups := CopyGroups(FOldGroups);
    RemoveGroupsFromGroups(xNewGroups,FSetGroups);
  end;
  try
    LB := TListBox(Control);
    ACanvas := LB.Canvas;

    ACanvas.FillRect(Rect);
    if Index = -1 then
      Exit;

      N := -1;
      if Control = LstSelectedGroups then
      begin
        for I := 0 to Length(FRegGroups)-1 do
        begin
          if FRegGroups[I].GroupCode = FSetGroups[Index].GroupCode then
          begin
            N := I + 1;
            Break;
          end;
        end
      end else
      begin
        for I := 0 to Length(FRegGroups) - 1 do
        begin
          if FRegGroups[I].GroupName = (Control as TListBox).Items[Index] then
          begin
            N := I + 1;
            Break;
          end;
        end
      end;

      GroupsImageList.Draw(ACanvas, Rect.Left + 1, Rect.Top + 1, Max(0, N));
      if N = -1 then
        DrawIconEx(Canvas.Handle, Rect.Left + 10, Rect.Top + 8, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 8, 8, 0, 0, DI_NORMAL);

      IsChoosed := False;
      if Control = LstSelectedGroups then
        IsChoosed := NewGroup(FSetGroups[Index].GroupCode)
      else if (N > -1) and (N < Length(FRegGroups)) then
        IsChoosed := NewGroup(FRegGroups[N - 1].GroupCode);

      if IsChoosed then
        ACanvas.Font.Style := ACanvas.Font.Style + [FsBold]
      else
        ACanvas.Font.Style := ACanvas.Font.Style - [FsBold];

      if (Control = LstAvaliableGroups) then
      begin
        if odSelected in State then
        begin
          FC := Theme.ListFontSelectedColor;
          C := Theme.ListSelectedColor;
        end else
        begin
          FC := Theme.ListFontColor;
          C := Theme.ListColor;
        end;

        if GroupExists(FShowenRegGroups[Index].GroupCode) then
          ACanvas.Font.Color := ColorDiv2(FC, C)
        else
          ACanvas.Font.Color := FC;
      end;

      ACanvas.TextOut(Rect.Left + 32 + 5, Rect.Top + 3, LB.Items[index]);

  finally
    FreeGroups(XNewGroups);
  end;
end;

function TEditGroupsForm.AGetGroupByCode(GroupCode: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(FRegGroups) - 1 do
    if FRegGroups[I].GroupCode = GroupCode then
    begin
    Result := I;
    break;
  end;
end;

procedure TEditGroupsForm.BtnRemoveGroupClick(Sender: TObject);
var
  I, J: Integer;
  KeyWords, AllGroupsKeyWords, GroupKeyWords: string;
begin
  for I := LstSelectedGroups.Items.Count - 1 downto 0 do
  if LstSelectedGroups.Selected[I] then
  // смотрим выделенный группы для удаления
  begin
  // если удаление ключевых слов ненужных то удаляем их
      if CbRemoveKeywords.Checked then
      begin
        AllGroupsKeyWords := '';
        for J := LstSelectedGroups.Items.Count - 1 downto 0 do
          if I <> J then
          begin
            if AGetGroupByCode(FSetGroups[J].GroupCode) > -1 then
              AddWordsA(FRegGroups[AGetGroupByCode(FSetGroups[J].GroupCode)].GroupKeyWords, AllGroupsKeyWords);
          end;
        KeyWords := FNewKeyWords;
        if AGetGroupByCode(FSetGroups[I].GroupCode) > -1 then
          GroupKeyWords := FRegGroups[AGetGroupByCode(FSetGroups[I].GroupCode)].GroupKeyWords;
        DeleteWords(GroupKeyWords, AllGroupsKeyWords);
        DeleteWords(KeyWords, GroupKeyWords);
        FNewKeyWords := KeyWords;
      end;

      // удаляем группу изтекущих
      RemoveGroupFromGroups(FSetGroups, FSetGroups[I]);
      LstSelectedGroups.Items.Delete(I);
    end;
  LstSelectedGroups.Invalidate;
  LstAvaliableGroups.Invalidate;
end;

procedure TEditGroupsForm.MoveToGroup1Click(Sender: TObject);
var
  ToGroup: TGroup;
begin
  if SelectGroup(ToGroup) then
  begin
    MoveGroup(FSetGroups[PmGroup.Tag], ToGroup);
    MessageBoxDB(Handle, L('Update the data in the windows to apply changes!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

procedure TEditGroupsForm.ChangedDBDataGroups(Sender: TObject; ID: integer;
  Params: TEventFields; Value: TEventValues);
begin
  if EventID_Param_GroupsChanged in Params then
  begin
    RecreateGroupsList;
    Exit;
  end;
end;

procedure TEditGroupsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TEditGroupsForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(IGroupsSelectForm, TEditGroupsForm);

end.
