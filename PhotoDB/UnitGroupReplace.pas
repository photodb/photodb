unit UnitGroupReplace;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,

  Dmitry.Controls.WatermarkedEdit,

  UnitDBKernel,

  uMemory,
  uRuntime,
  uMemoryEx,
  uConstants,
  uGroupTypes,
  uDBForm,
  uDBContext,
  uDBEntities,
  uSettings,
  uShellIntegration,
  uFormInterfaces;

type
  GroupReplaceOptions = record
    AllowAdd: Boolean;
    MaxAuto: Boolean;
  end;

type
  TFormGroupReplace = class(TDBForm)
    ActionPanel: TPanel;
    CbExistedGroups: TComboBox;
    RbMergeWith: TRadioButton;
    RbAddWithAnotherName: TRadioButton;
    RbSkipGroup: TRadioButton;
    OutGroupPanel: TPanel;
    GroupNameBox: TEdit;
    Label1: TLabel;
    TmGroupImage: TImage;
    Panel2: TPanel;
    CbReplaceImage: TCheckBox;
    Panel3: TPanel;
    WarningLabelText: TLabel;
    ImMain: TImage;
    CbAllUnknownGroups: TCheckBox;
    BtnOk: TButton;
    NewGroupNameBox: TWatermarkedEdit;
    CbAllKnownGroups: TCheckBox;
    RbAddGroup: TRadioButton;
    PmDummy: TPopupMenu;
    procedure RbAddWithAnotherNameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure RbMergeWithClick(Sender: TObject);
    procedure RbSkipGroupClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CbExistedGroupsKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FGroup: TGroup;
    Working: Boolean;
    FAction: TGroupAction;
    RegGroups: TGroups;
    FDBContext: IDBContext;
    FGroupsRepository: IGroupsRepository;
    procedure LoadLanguage;
    procedure SetText(GroupName : string);
    procedure RecreateGroupsList;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure ExecuteNoDBGroupsIn(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
    procedure ExecuteWithDBGroupsIn(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
  end;

Const
  GROUP_ACTION_UNCNOWN       = 0;
  GROUP_ACTION_ADD_IN_EXISTS = 1;
  GROUP_ACTION_ADD_IN_NEW    = 2;
  GROUP_ACTION_NO_ADD        = 3;
  GROUP_ACTION_ADD           = 4;

procedure GroupReplaceExists(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
procedure GroupReplaceNotExists(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);

implementation

{$R *.dfm}

procedure GroupReplaceExists(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
var
  FormGroupReplace: TFormGroupReplace;
begin
  Application.CreateForm(TFormGroupReplace, FormGroupReplace);
  try
    FormGroupReplace.ExecuteWithDBGroupsIn(DBContext, Group, Action, Options);
  finally
    R(FormGroupReplace);
  end;
end;

procedure GroupReplaceNotExists(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
var
  FormGroupReplace: TFormGroupReplace;
begin
  Application.CreateForm(TFormGroupReplace, FormGroupReplace);
  try
    FormGroupReplace.ExecuteNoDBGroupsIn(DBContext, Group, Action, Options);
  finally
    R(FormGroupReplace);
  end;
end;

procedure TFormGroupReplace.RbAddWithAnotherNameClick(Sender: TObject);
var
  GroupCreated: Boolean;
  NewGroupName : String;
begin
 if ID_OK <> MessageBoxDB(Handle, L('Do you really want to create a new group and use it to import?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    RbAddWithAnotherName.Checked := False;
    RbSkipGroup.Checked := True;
    Exit;
  end;
  CbExistedGroups.Enabled := False;
  if RbAddWithAnotherName.Checked then
  begin
    GroupCreateForm.CreateGroupByCodeAndImage(FGroup.GroupCode, FGroup.GroupImage, GroupCreated, NewGroupName);
    if not GroupCreated then
    begin
      RbAddWithAnotherName.Checked := False;
      RbSkipGroup.Checked := True;
    end
    else
    begin
      NewGroupNameBox.Text := NewGroupName;
      BtnOkClick(Sender);
    end;
  end;
end;

procedure TFormGroupReplace.FormCreate(Sender: TObject);
begin
  RegGroups := TGroups.Create;
  FDBContext := DBKernel.DBContext;
  FGroupsRepository := FDBContext.Groups;

  RecreateGroupsList;
  LoadLanguage;
end;

procedure TFormGroupReplace.FormDestroy(Sender: TObject);
begin
  F(RegGroups);
  FGroupsRepository := nil;
  FDBContext := nil;
end;

function TFormGroupReplace.GetFormID: string;
begin
  Result := 'ReplaceGroup';
end;

procedure TFormGroupReplace.BtnOkClick(Sender: TObject);
begin
  Working := False;
  FAction.Action := GROUP_ACTION_UNCNOWN;
  if RbMergeWith.Checked then
  begin
    FAction.Action := GROUP_ACTION_ADD_IN_EXISTS;
    FAction.InGroup := FGroupsRepository.GetByName(CbExistedGroups.Text, True);
  end;
  if RbAddWithAnotherName.Checked then
  begin
    FAction.Action := GROUP_ACTION_ADD_IN_NEW;
    FAction.InGroup := FGroupsRepository.GetByName(NewGroupNameBox.Text, True);
  end;
  if RbSkipGroup.Checked then
    FAction.Action := GROUP_ACTION_NO_ADD;
  if RbAddGroup.Checked then
    FAction.Action := GROUP_ACTION_ADD;
  FAction.ReplaceImageOnNew := CbReplaceImage.Checked;
  FAction.ActionForAll := CbAllUnknownGroups.Checked;
  Close;
end;

procedure TFormGroupReplace.RecreateGroupsList;
var
  I: Integer;
  SortGroupsByName: Boolean;
begin
  F(RegGroups);

  SortGroupsByName := AppSettings.Readbool('Options', 'SortGroupsByName', True);
  RegGroups := FGroupsRepository.GetAll(False, SortGroupsByName);
  CbExistedGroups.Clear;
  for I := 0 to RegGroups.Count - 1 do
    CbExistedGroups.Items.Add(RegGroups[I].GroupName);
end;

procedure TFormGroupReplace.SetText(GroupName: string);
begin
  WarningLabelText.Caption := Format(L('The database found a group named "%s". What to do with this group when you import an existing database?'), [GroupName]);
end;

procedure TFormGroupReplace.RbMergeWithClick(Sender: TObject);
begin
  CbExistedGroups.Enabled := True;
  if CbExistedGroups.Text = '' then
    CbExistedGroups.Text := CbExistedGroups.Items[0];
end;

procedure TFormGroupReplace.RbSkipGroupClick(Sender: TObject);
begin
  CbExistedGroups.Enabled := False;
end;

procedure TFormGroupReplace.ExecuteNoDBGroupsIn(DBContext: IDBContext; Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions);
begin
  FDBContext := DBContext;

  RecreateGroupsList;
  if CbExistedGroups.Items.Count = 0 then
    RbMergeWith.Enabled := False;

  Working := True;
  OutGroupPanel.Visible := False;
  FGroup := Group;
  GroupNameBox.Text := FGroup.GroupName;
  CbReplaceImage.Enabled := False;
  CbAllUnknownGroups.Enabled := False;
  CbAllKnownGroups.Enabled := False;
  RbSkipGroup.Checked := True;
  if Options.AllowAdd then
  begin
    RbAddGroup.Enabled := True;
    RbAddGroup.Checked := True;
  end;
  if not Options.AllowAdd then
  begin
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := True;
  end;

  if FGroupsRepository.HasGroupWithName(Group.GroupName) then
  begin
    RbMergeWith.Checked := True;
    CbExistedGroups.Text := Group.GroupName;
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := False;
  end;

  FAction.OutGroup := Group.Clone;
  SetText(Group.GroupName);
  if Options.MaxAuto then
    BtnOkClick(Self)
  else
    ShowModal;
  Action := Faction;
end;

procedure TFormGroupReplace.ExecuteWithDBGroupsIn(DBContext: IDBContext; Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions);
begin
  FDBContext := DBContext;
  RecreateGroupsList;
  if CbExistedGroups.Items.Count = 0 then
    RbMergeWith.Enabled := False;
  Working := True;
  OutGroupPanel.Visible := True;
  FGroup := Group;
  RbSkipGroup.Checked := True;
  if Options.AllowAdd then
  begin
    RbAddGroup.Enabled := True;
    RbAddGroup.Checked := True;
  end;
  if not Options.AllowAdd then
  begin
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := True;
  end;

  if FGroupsRepository.HasGroupWithName(Group.GroupName) then
  begin
    RbMergeWith.Checked := True;
    CbExistedGroups.Text := Group.GroupName;
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := False;
  end;

  TmGroupImage.Picture.Graphic := FGroup.GroupImage;
  GroupNameBox.Text := FGroup.GroupName;
  FAction.OutGroup := Group.Clone;
  CbReplaceImage.Enabled := False;
  CbAllUnknownGroups.Enabled := False;
  CbAllKnownGroups.Enabled := False;
  SetText(Group.GroupName);

  if Options.MaxAuto then
    BtnOkClick(Self)
  else
    ShowModal;
  Action := Faction;
end;

procedure TFormGroupReplace.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Working then
    CanClose := False;
end;

procedure TFormGroupReplace.LoadLanguage;
begin
  BeginTranslate;
  try
    WarningLabelText.Caption := '';
    BtnOk.Caption := L('Ok');
    Label1.Caption := L('Group') + ':';
    Caption := L('Replace group');
    RbAddGroup.Caption := L('Add group');
    RbMergeWith.Caption := L('Merge with');
    RbAddWithAnotherName.Caption := L('Add with another name');
    RbSkipGroup.Caption := L('Skip this group');
    NewGroupNameBox.WatermarkText := L('Group');
  finally
    EndTranslate;
  end;
end;

procedure TFormGroupReplace.CbExistedGroupsKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

end.
