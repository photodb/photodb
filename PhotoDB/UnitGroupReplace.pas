unit UnitGroupReplace;

interface

uses
  UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Dolphin_DB, jpeg, Menus,
  uVistaFuncs, uMemory, uDBForm;

type
  GroupReplaceOptions = record
    AllowAdd: Boolean;
    MaxAuto: Boolean;
  end;

type
  TFormGroupReplace = class(TDBForm)
    ActionPanel: TPanel;
    ComboBox1: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    OutGroupPanel: TPanel;
    GroupNameBox: TEdit;
    Label1: TLabel;
    Image3: TImage;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    Panel3: TPanel;
    WarningLabelText: TLabel;
    Image1: TImage;
    Image2: TImage;
    CheckBox2: TCheckBox;
    Button1: TButton;
    NewGroupNameBox: TEdit;
    CheckBox3: TCheckBox;
    RadioButton4: TRadioButton;
    PopupMenu1: TPopupMenu;
    procedure RadioButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FGroup: TGroup;
    Working: Boolean;
    FAction: TGroupAction;
    RegGroups: TGroups;
    FGroupFileName: string;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure RecreateGroupsList;
    procedure ExecuteNoDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
      FileName: string);
    procedure ExecuteWithDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
      FileName: string);
    procedure LoadLanguage;
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

uses UnitNewGroupForm, Language;

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

procedure TFormGroupReplace.RadioButton2Click(Sender: TObject);
var
  b : boolean;
  NewGroupName : String;
begin
 if ID_OK <> MessageBoxDB(Handle, TEXT_MES_1, L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    RadioButton2.Checked := False;
    RadioButton3.Checked := True;
    Exit;
  end;
  ComboBox1.Enabled := False;
  if RadioButton2.Checked then
  begin
    CreateNewGroupDialogB(FGroup.GroupCode, FGroup.GroupImage, B, NewGroupName);
    if not B then
    begin
      RadioButton2.Checked := False;
      RadioButton3.Checked := True;
    end
    else
    begin
      NewGroupNameBox.Text := NewGroupName;
      Button1Click(Sender);
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

procedure TFormGroupReplace.Button1Click(Sender: TObject);
begin
  Working := False;
  FAction.Action := GROUP_ACTION_UNCNOWN;
  if RadioButton1.Checked then
  begin
    FAction.Action := GROUP_ACTION_ADD_IN_EXISTS;
    FAction.InGroup := GetGroupByGroupNameW(ComboBox1.Text, True, FGroupFileName);
  end;
  if RadioButton2.Checked then
  begin
    FAction.Action := GROUP_ACTION_ADD_IN_NEW;
    FAction.InGroup := GetGroupByGroupNameW(NewGroupNameBox.Text, True, FGroupFileName);
  end;
  if RadioButton3.Checked then
    FAction.Action := GROUP_ACTION_NO_ADD;
  if RadioButton4.Checked then
    FAction.Action := GROUP_ACTION_ADD;
  FAction.ReplaceImageOnNew := CheckBox1.Checked;
  FAction.ActionForAll := CheckBox2.Checked;
  Close;
end;

procedure TFormGroupReplace.RecreateGroupsList;
var
  I: Integer;
begin
  RegGroups := GetRegisterGroupListW(FGroupFileName, False, DBKernel.SortGroupsByName);
  ComboBox1.Clear;
  for I := 0 to Length(RegGroups) - 1 do
    ComboBox1.Items.Add(RegGroups[I].GroupName);
end;

procedure TFormGroupReplace.RadioButton1Click(Sender: TObject);
begin
  ComboBox1.Enabled := True;
  if ComboBox1.Text = '' then
    ComboBox1.Text := ComboBox1.Items[0];
end;

procedure TFormGroupReplace.RadioButton3Click(Sender: TObject);
begin
  ComboBox1.Enabled := False;
end;

procedure TFormGroupReplace.ExecuteNoDBGroupsIn(Group: TGroup; out Action: TGroupAction; Options: GroupReplaceOptions;
  FileName: string);
begin
  FGroupFileName := FileName;
  RecreateGroupsList;
  if ComboBox1.Items.Count = 0 then
    RadioButton1.Enabled := False;

  Working := True;
  OutGroupPanel.Visible := False;
  FGroup := Group;
  GroupNameBox.Text := FGroup.GroupName;
  CheckBox1.Enabled := False;
  CheckBox2.Enabled := False;
  CheckBox3.Enabled := False;
  RadioButton3.Checked := True;
  if Options.AllowAdd then
  begin
    RadioButton4.Enabled := True;
    RadioButton4.Checked := True;
  end;
  if not Options.AllowAdd then
  begin
    RadioButton4.Enabled := False;
    RadioButton3.Checked := True;
  end;

  if GroupNameExistsW(Group.GroupName, FileName) then
  begin
    RadioButton1.Checked := True;
    ComboBox1.Text := Group.GroupName;
    RadioButton4.Enabled := False;
    RadioButton3.Checked := False;
  end;

  FAction.OutGroup := CopyGroup(Group);
  WarningLabelText.Caption := Format(TEXT_MES_REPLACE_GROUP, [Group.GroupName]);
  if Options.MaxAuto then
    Button1Click(nil)
  else
    ShowModal;
  Action := Faction;
end;

procedure TFormGroupReplace.ExecuteWithDBGroupsIn(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
begin
  FGroupFileName := FileName;
  RecreateGroupsList;
  if ComboBox1.Items.Count = 0 then
    RadioButton1.Enabled := False;
  Working := True;
  OutGroupPanel.Visible := True;
  if Image3.Picture.Graphic = nil then
    Image3.Picture.Graphic := TJpegImage.Create;
  FGroup := Group;
  RadioButton3.Checked := True;
  if Options.AllowAdd then
  begin
    RadioButton4.Enabled := True;
    RadioButton4.Checked := True;
  end;
  if not Options.AllowAdd then
  begin
    RadioButton4.Enabled := False;
    RadioButton3.Checked := True;
  end;

  if GroupNameExistsW(Group.GroupName, FileName) then
  begin
    RadioButton1.Checked := True;
    ComboBox1.Text := Group.GroupName;
    RadioButton4.Enabled := False;
    RadioButton3.Checked := False;
  end;

  Image3.Picture.Graphic.Assign(FGroup.GroupImage);
  GroupNameBox.Text := FGroup.GroupName;
  FAction.OutGroup := CopyGroup(Group);
  CheckBox1.Enabled := False;
  CheckBox2.Enabled := False;
  CheckBox3.Enabled := False;
  WarningLabelText.Caption := Format(TEXT_MES_REPLACE_GROUP, [Group.GroupName]);
  if Options.MaxAuto then
    Button1Click(nil)
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
    Button1.Caption := L('Ok');
    Label1.Caption := L('Group') + ':';
    Caption := L('Replace group');
    RadioButton4.Caption := L('Add group');
    RadioButton1.Caption := L('Megre with');
    RadioButton2.Caption := L('Add with another name');
    RadioButton3.Caption := L('Skip this group');
    NewGroupNameBox.Text := L('<Group>');
  finally
    EndTranslate;
  end;
end;

procedure TFormGroupReplace.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

end.
