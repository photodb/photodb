unit UnitGroupReplace;

interface

uses
  UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Dolphin_DB, jpeg, Menus,
  uVistaFuncs;

Type GroupReplaceOptions = record
   AllowAdd : boolean;
   MaxAuto : Boolean;
  end;

type
  TFormGroupReplace = class(TForm)
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
  FGroup : TGroup;
  Working : Boolean;
  FAction: TGroupAction;
  RegGroups : TGroups;
  FGroupFileName : String;
    { Private declarations }
  public
  procedure RecreateGroupsList;
  Procedure ExecuteNoDBGroupsIn(Group : TGroup; out Action : TGroupAction; Options : GroupReplaceOptions; FileName : String);
  Procedure ExecuteWithDBGroupsIn(Group : TGroup; out Action : TGroupAction; Options : GroupReplaceOptions; FileName : String);
  Procedure LoadLanguage;
    { Public declarations }
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

procedure GroupReplaceExists(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
var
  FormGroupReplace: TFormGroupReplace;
begin
 Application.CreateForm(TFormGroupReplace, FormGroupReplace);
 FormGroupReplace.ExecuteWithDBGroupsIn(Group,Action,Options,FileName);
 FormGroupReplace.Release;
end;

procedure GroupReplaceNotExists(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
var
  FormGroupReplace: TFormGroupReplace;
begin
 Application.CreateForm(TFormGroupReplace, FormGroupReplace);
 FormGroupReplace.ExecuteNoDBGroupsIn(Group,Action,Options,FileName);
 FormGroupReplace.Release;
end;

procedure TFormGroupReplace.RadioButton2Click(Sender: TObject);
var
  b : boolean;
  NewGroupName : String;
begin
 if ID_OK<>MessageBoxDB(Handle,TEXT_MES_1,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  RadioButton2.Checked:=false;
  RadioButton3.Checked:=True;
  Exit;
 end;
 ComboBox1.Enabled:=False;
 if RadioButton2.Checked then
 begin
  CreateNewGroupDialogB(FGroup.GroupCode,FGroup.GroupImage,b,NewGroupName);
  if not b then
  begin
   RadioButton2.Checked:=false;
   RadioButton3.Checked:=True;
  end else
  begin
   NewGroupNameBox.Text:=NewGroupName;
   Button1Click(Sender);
  end;
 end;
end;

procedure TFormGroupReplace.FormCreate(Sender: TObject);
begin
 FGroupFileName:=dbname;//GroupsTableFileName;
 RecreateGroupsList;
 LoadLanguage;
end;

procedure TFormGroupReplace.Button1Click(Sender: TObject);
begin
 Working:=False;
 FAction.Action:=GROUP_ACTION_UNCNOWN;
 If RadioButton1.Checked then
 begin
  FAction.Action:=GROUP_ACTION_ADD_IN_EXISTS;
  FAction.InGroup:=GetGroupByGroupNameW(ComboBox1.Text,True,FGroupFileName);
 end;
 If RadioButton2.Checked then
 begin
  FAction.Action:=GROUP_ACTION_ADD_IN_NEW;
  FAction.InGroup:=GetGroupByGroupNameW(NewGroupNameBox.Text,True,FGroupFileName);
 end;
 If RadioButton3.Checked then FAction.Action:=GROUP_ACTION_NO_ADD;
 If RadioButton4.Checked then FAction.Action:=GROUP_ACTION_ADD;
 FAction.ReplaceImageOnNew:=CheckBox1.Checked;
 FAction.ActionForAll:=CheckBox2.Checked;
 Close;
end;

procedure TFormGroupReplace.RecreateGroupsList;
var
  i : integer;
begin
 RegGroups:=GetRegisterGroupListW(FGroupFileName,False);
 ComboBox1.Clear;
 For i:=0 to Length(RegGroups)-1 do
 ComboBox1.Items.Add(RegGroups[i].GroupName);
end;

procedure TFormGroupReplace.RadioButton1Click(Sender: TObject);
begin
 ComboBox1.Enabled:=True;
 if ComboBox1.Text='' then
 ComboBox1.Text:=ComboBox1.Items[0];
end;

procedure TFormGroupReplace.RadioButton3Click(Sender: TObject);
begin
  ComboBox1.Enabled:=False;
end;

procedure TFormGroupReplace.ExecuteNoDBGroupsIn(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
begin
 FGroupFileName:=FileName;
 RecreateGroupsList;
 If ComboBox1.Items.Count=0 then
 RadioButton1.Enabled:=false;

 Working:=True;
 OutGroupPanel.Visible:=False;
 FGroup:=Group;
 GroupNameBox.Text:=FGroup.GroupName;
 CheckBox1.Enabled:=false;
 CheckBox2.Enabled:=false;
 CheckBox3.Enabled:=false;
 RadioButton3.Checked:=True;
 if Options.AllowAdd then
 begin
  RadioButton4.Enabled:=True;
  RadioButton4.Checked:=True;
 end;
 if not Options.AllowAdd then
 begin
  RadioButton4.Enabled:=False;
  RadioButton3.Checked:=True;
 end;
// If not RadioButton4.Checked then
 begin
  if GroupNameExistsW(Group.GroupName,FileName) then
  begin
   RadioButton1.Checked:=True;
   ComboBox1.Text:=Group.GroupName;
   RadioButton4.Enabled:=False;
   RadioButton3.Checked:=False;
  end;
 end;
 FAction.OutGroup:=CopyGroup(Group);
 WarningLabelText.Caption:=Format(TEXT_MES_REPLACE_GROUP,[Group.GroupName]);
 if Options.MaxAuto then
 Button1Click(nil) else
 ShowModal;
 Action:=Faction; 
end;

procedure TFormGroupReplace.ExecuteWithDBGroupsIn(Group: TGroup;
  out Action: TGroupAction; Options : GroupReplaceOptions; FileName : String);
begin
 FGroupFileName:=FileName;
 RecreateGroupsList;
 If ComboBox1.Items.Count=0 then
 RadioButton1.Enabled:=false; 
 Working:=True;
 OutGroupPanel.Visible:=True;
 if Image3.Picture.Graphic=nil then
 Image3.Picture.Graphic:=TJpegImage.Create;
 FGroup:=Group;
 RadioButton3.Checked:=True;
 if Options.AllowAdd then
 begin
  RadioButton4.Enabled:=True;
  RadioButton4.Checked:=True;
 end;
 if not Options.AllowAdd then
 begin
  RadioButton4.Enabled:=False;
  RadioButton3.Checked:=True;
 end;
// If not RadioButton4.Checked then
 begin
  if GroupNameExistsW(Group.GroupName,FileName) then
  begin
   RadioButton1.Checked:=True;
   ComboBox1.Text:=Group.GroupName;
   RadioButton4.Enabled:=False;
   RadioButton3.Checked:=False;
  end;
 end;
 Image3.Picture.Graphic.Assign(FGroup.GroupImage);
 GroupNameBox.Text:=FGroup.GroupName;
 FAction.OutGroup:=CopyGroup(Group);
 CheckBox1.Enabled:=false;
 CheckBox2.Enabled:=false;
 CheckBox3.Enabled:=false;
 WarningLabelText.Caption:=Format(TEXT_MES_REPLACE_GROUP,[Group.GroupName]);
 if Options.MaxAuto then
 Button1Click(nil) else
 ShowModal;
 Action:=Faction;
end;

procedure TFormGroupReplace.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 If Working then CanClose:=false;
end;

procedure TFormGroupReplace.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 FreeGroups(RegGroups);
end;

procedure TFormGroupReplace.LoadLanguage;
begin
 WarningLabelText.Caption:=TEXT_MES_REPLACE_GROUP;
 Button1.Caption:=TEXT_MES_OK;
 Label1.Caption:=TEXT_MES_GROUP+':';
 Caption:=TEXT_MES_GROUPS_REPLACE_CAPTION;
 RadioButton4.Caption:=TEXT_MES_CHOOSE_GROUP_ACTION_ADD_GROUP;
 RadioButton1.Caption:=TEXT_MES_CHOOSE_GROUP_ACTION_IMPORT_IN_GROUP;
 RadioButton2.Caption:=TEXT_MES_CHOOSE_GROUP_ACTION_ADD_WITH_ANOTHER_NAME;
 RadioButton3.Caption:=TEXT_MES_CHOOSE_GROUP_ACTION_NO_NOT_ADD;
 NewGroupNameBox.Text:=TEXT_MES_GROUPA;
end;

procedure TFormGroupReplace.ComboBox1KeyPress(Sender: TObject;
  var Key: Char);
begin
 Key:=#0;
end;

end.
