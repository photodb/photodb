unit UnitGroupReplace;

interface

uses
  UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Menus, UnitDBKernel, jpeg,
  uVistaFuncs, uMemory, uDBForm, uShellIntegration, Dolphin_DB,
  CommonDBSupport;

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
    Image1: TImage;
    Image2: TImage;
    CbAllUnknownGroups: TCheckBox;
    BtnOk: TButton;
    NewGroupNameBox: TEdit;
    CbAllKnownGroups: TCheckBox;
    RbAddGroup: TRadioButton;
    PopupMenu1: TPopupMenu;
    procedure RbAddWithAnotherNameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure RbMergeWithClick(Sender: TObject);
    procedure RbSkipGroupClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CbExistedGroupsKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FGroup: TGroup;
    Working: Boolean;
    FAction: TGroupAction;
    RegGroups: TGroups;
    FGroupFileName: string;
    procedure LoadLanguage;
    procedure SetText(GroupName : string);
    procedure RecreateGroupsList;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure ExecuteNoDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
      FileName: string);
    procedure ExecuteWithDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
      FileName: string);
  end;

Const
  GROUP_ACTION_UNCNOWN       = 0;
  GROUP_ACTION_ADD_IN_EXISTS = 1;
  GROUP_ACTION_ADD_IN_NEW    = 2;
  GROUP_ACTION_NO_ADD        = 3;
  GROUP_ACTION_ADD           = 4;

procedure GroupReplaceExists(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
procedure GroupReplaceNotExists(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);

implementation

uses UnitNewGroupForm;

{$R *.dfm}

procedure GroupReplaceExists(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions; FileName: string);
var
  FormGroupReplace: TFormGroupReplace;
begin
  Application.CreateForm(TFormGroupReplace, FormGroupReplace);
  try
    FormGroupReplace.ExecuteWithDBGroupsIn(Group, Action, Options, FileName);
  finally
    R(FormGroupReplace);
  end;
end;

procedure GroupReplaceNotExists(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
  FileName: string);
var
  FormGroupReplace: TFormGroupReplace;
begin
  Application.CreateForm(TFormGroupReplace, FormGroupReplace);
  try
    FormGroupReplace.ExecuteNoDBGroupsIn(Group, Action, Options, FileName);
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
    CreateNewGroupDialogB(FGroup.GroupCode, FGroup.GroupImage, GroupCreated, NewGroupName);
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
  FGroupFileName := Dbname;
  RecreateGroupsList;
  LoadLanguage;
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
    FAction.InGroup := GetGroupByGroupNameW(CbExistedGroups.Text, True, FGroupFileName);
  end;
  if RbAddWithAnotherName.Checked then
  begin
    FAction.Action := GROUP_ACTION_ADD_IN_NEW;
    FAction.InGroup := GetGroupByGroupNameW(NewGroupNameBox.Text, True, FGroupFileName);
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
begin
  RegGroups := GetRegisterGroupListW(FGroupFileName, False, DBKernel.SortGroupsByName);
  CbExistedGroups.Clear;
  for I := 0 to Length(RegGroups) - 1 do
    CbExistedGroups.Items.Add(RegGroups[I].GroupName);
end;

procedure TFormGroupReplace.SetText(GroupName: string);
begin
  WarningLabelText.Caption := Format(L('The database found a group named "%s". What to do with this group when you import an existing database?"'), [GroupName]);
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

procedure TFormGroupReplace.ExecuteNoDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
  FileName: string);
begin
  FGroupFileName := FileName;
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

  if GroupNameExistsW(Group.GroupName, FileName) then
  begin
    RbMergeWith.Checked := True;
    CbExistedGroups.Text := Group.GroupName;
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := False;
  end;

  FAction.OutGroup := CopyGroup(Group);
  SetText(Group.GroupName);
  if Options.MaxAuto then
    BtnOkClick(Self)
  else
    ShowModal;
  Action := Faction;
end;

procedure TFormGroupReplace.ExecuteWithDBGroupsIn(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
begin
  FGroupFileName := FileName;
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

  if GroupNameExistsW(Group.GroupName, FileName) then
  begin
    RbMergeWith.Checked := True;
    CbExistedGroups.Text := Group.GroupName;
    RbAddGroup.Enabled := False;
    RbSkipGroup.Checked := False;
  end;

  TmGroupImage.Picture.Graphic := FGroup.GroupImage;
  GroupNameBox.Text := FGroup.GroupName;
  FAction.OutGroup := CopyGroup(Group);
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

procedure TFormGroupReplace.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeGroups(RegGroups);
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
    RbMergeWith.Caption := L('Megre with');
    RbAddWithAnotherName.Caption := L('Add with another name');
    RbSkipGroup.Caption := L('Skip this group');
    NewGroupNameBox.Text := L('<Group>');
  finally
    EndTranslate;
  end;
end;

procedure TFormGroupReplace.CbExistedGroupsKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

end.
