unit UnitQuickGroupInfo;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, uVistaFuncs, ImgList, Menus, StdCtrls, Math,
  ComCtrls, jpeg, ExtCtrls, Dialogs, UnitDBCommonGraphics;

type
  TFormQuickGroupInfo = class(TForm)
    GroupImage: TImage;
    GroupNameEdit: TEdit;
    CommentMemo: TMemo;
    Button1: TButton;
    DateEdit: TEdit;
    AccessEdit: TEdit;
    PopupMenu1: TPopupMenu;
    Manager1: TMenuItem;
    EditGroup1: TMenuItem;
    CommentLabel: TLabel;
    DateLabel: TLabel;
    AccessLabel: TLabel;
    Label1: TLabel;
    SearchForGroup1: TMenuItem;
    KeyWordsMemo: TMemo;
    CheckBox1: TCheckBox;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    ComboBoxEx1: TComboBoxEx;
    CheckBox2: TCheckBox;
    GroupsImageList: TImageList;
    PopupMenu2: TPopupMenu;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditGroup1Click(Sender: TObject);
    procedure Manager1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure ComboBoxEx1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxEx1Select(Sender: TObject);
    procedure ComboBoxEx1DropDown(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  FGroup : TGroup;
  FCloseOwner : Boolean;
  fOwner : TForm;
  FNewRelatedGroups : String;
    { Private declarations }
  public
  procedure Execute(Group : TGroup; CloseOwner : Boolean; Owner_ : TForm);
  procedure LoadLanguage;
  procedure ReloadGroups;
    { Public declarations }
  end;

Procedure ShowGroupInfo(Group : TGroup; CloseOwner : Boolean; Owner : TForm); overload;
Procedure ShowGroupInfo(GrouName : String; CloseOwner : Boolean; Owner : TForm); overload;

implementation

{$R *.dfm}

uses UnitDBKernel, UnitFormChangeGroup, UnitManageGroups, Language, Searching;

Procedure ShowGroupInfo(GrouName : String; CloseOwner : Boolean; Owner : TForm);
var
  FormQuickGroupInfo: TFormQuickGroupInfo;
  Group : TGroup;
begin
 Group.GroupCode:=FindGroupCodeByGroupName(GrouName);
 Application.CreateForm(TFormQuickGroupInfo, FormQuickGroupInfo);
 FormQuickGroupInfo.Execute(Group,CloseOwner,Owner);
 FormQuickGroupInfo.Release;
end;

Procedure ShowGroupInfo(Group : TGroup; CloseOwner : Boolean; Owner : TForm);
var
  FormQuickGroupInfo: TFormQuickGroupInfo;
begin
 Application.CreateForm(TFormQuickGroupInfo, FormQuickGroupInfo);
 FormQuickGroupInfo.Execute(Group,CloseOwner,Owner);
 FormQuickGroupInfo.Release;
end;

procedure TFormQuickGroupInfo.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TFormQuickGroupInfo.Execute(Group: TGroup; CloseOwner : Boolean; Owner_ : TForm);
const
   otstup = 3;
   otstupa = 2;
var
  FPrGroup : TGroup;
  FineDate: array[0..255] of Char;
  TempSysTime: TSystemTime;
begin
 fCloseOwner:=CloseOwner;
 fOwner:=Owner_;
 FGroup:=GetGroupByGroupCode(Group.GroupCode,True);
 if FGroup.GroupName='' then
 begin
  MessageBoxDB(Handle,TEXT_MES_GROUP_NOT_FOUND,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Exit;
 end;
 FPrGroup:=CopyGroup(FGroup);
 GroupNameEdit.Text:=FGroup.GroupName;
 FNewRelatedGroups:=FGroup.RelatedGroups;
 CheckBox2.Checked:=FGroup.IncludeInQuickList;
 If FPrGroup.GroupImage<>nil then
 begin
  GroupImage.Picture.Graphic.Assign(FPrGroup.GroupImage As TJpegImage);
 end;
 CommentLabel.Top:=Max(GroupImage.Top+GroupImage.Height,GroupNameEdit.Top+GroupNameEdit.Height)+3;
 CommentMemo.Top:=CommentLabel.Top+CommentLabel.Height+3;
 CommentMemo.Text:=FPrGroup.GroupComment;
 CommentMemo.Height:=(CommentMemo.Lines.Count+1)*(Abs(CommentMemo.Font.Height)+2)+otstup;
 KeyWordsLabel.Top:=CommentMemo.Top+CommentMemo.Height+otstup;
 KeyWordsMemo.Top:=KeyWordsLabel.Top+KeyWordsLabel.Height+otstup;
 KeyWordsMemo.Text:=FPrGroup.GroupKeyWords;
 CheckBox1.Top:=KeyWordsMemo.Top+KeyWordsMemo.Height+otstup;
 CheckBox1.Checked:=FPrGroup.AutoAddKeyWords;

 Label3.Top:=CheckBox1.Top+CheckBox1.Height+otstup;
 ComboBoxEx1.Top:=Label3.Top+Label3.Height+otstup;
 CheckBox2.Top:=ComboBoxEx1.Top+ComboBoxEx1.Height+otstup;

 DateLabel.Top:=CheckBox2.Top+CheckBox2.Height+otstup;
 DateEdit.Top:=DateLabel.Top+DateLabel.Height+otstupa;
 AccessLabel.Top:=DateEdit.Top+DateEdit.Height+otstupa;
 AccessEdit.Top:=AccessLabel.Top+AccessLabel.Height+otstup;
 Button1.Top:=AccessEdit.Top+AccessEdit.Height+otstup;
 ClientHeight:=Button1.Top+Button1.Height+otstup;
 DateTimeToSystemTime(FPrGroup.GroupDate,TempSysTime);
 GetDateFormat(LOCALE_USER_DEFAULT,  DATE_USE_ALT_CALENDAR,  @TempSysTime,  'd MMMM yyyy ', @FineDate,  255);

 DateEdit.Text:=Format(TEXT_MES_GROUP_CREATED_AT,[{DateTimeToStr(FPrGroup.GroupDate)}FineDate]);
 if FPrGroup.GroupAccess=GROUP_ACCESS_COMMON then
 AccessEdit.Text:=TEXT_MES_COMMON_GROUP;
 if FPrGroup.GroupAccess=GROUP_ACCESS_PRIVATE then
 AccessEdit.Text:=TEXT_MES_PRIVATE_GROUP;
 ReloadGroups;
 ShowModal;
 FreeGroup(FGroup);
 FreeGroup(FPrGroup);
end;

procedure TFormQuickGroupInfo.FormCreate(Sender: TObject);
begin
 DBKernel.RecreateThemeToForm(Self);
 Loadlanguage;
end;

procedure TFormQuickGroupInfo.EditGroup1Click(Sender: TObject);
begin
 Hide;
 Application.ProcessMessages;
 DBChangeGroup(FGroup);
 Close;
end;

procedure TFormQuickGroupInfo.Manager1Click(Sender: TObject);
begin
 Hide;
 if FormManageGroups<>nil then
 begin
  Close;
  exit;
 end;
 Application.ProcessMessages;
 ExecuteGroupManager;
 Close;
end;

procedure TFormQuickGroupInfo.FormShow(Sender: TObject);
begin
 Button1.SetFocus;
end;

procedure TFormQuickGroupInfo.LoadLanguage;
begin
 Caption:=TEXT_MES_QUICK_INFO_CAPTION;
 Label1.Caption:= TEXT_MES_GROUP;
 DateLabel.Caption:=TEXT_MES_GROUP_DATE_CREATED;
 AccessLabel.Caption:=TEXT_MES_GROUP_ATTRIBUTES;
 Button1.Caption:= TEXT_MES_OK;
 EditGroup1.Caption:=TEXT_MES_CHANGE_GROUP;
 Manager1.Caption:=TEXT_MES_GROUP_MANAGER_BUTTON;
 SearchForGroup1.Caption:=TEXT_MES_SEARCH_FOR_GROUP;
 CheckBox1.Caption:=TEXT_MES_AUTO_ADD_KEYWORDS;
 KeyWordsLabel.Caption:=TEXT_MES_KEYWORDS_FOR_GROUP;
 CommentLabel.Caption:=TEXT_MES_GROUP_COMMENT;
 CheckBox2.Caption:=TEXT_MES_INCLUDE_IN_QUICK_LISTS;
 Label3.Caption:=TEXT_MES_RELATED_GROUPS+':';
end;

procedure TFormQuickGroupInfo.SearchForGroup1Click(Sender: TObject);
begin
 With SearchManager.NewSearch do
 begin
  SearchEdit.Text:=':Group('+FGroup.GroupName+'):';
  Button1.OnClick(Sender);
  Show;
 end;
 Close;
 if FCloseOwner then FOwner.Close;
end;

procedure TFormQuickGroupInfo.ComboBoxEx1KeyPress(Sender: TObject;
  var Key: Char);
begin
 Key:=#0;
end;

procedure TFormQuickGroupInfo.ComboBoxEx1Select(Sender: TObject);
{var
  KeyWords : string;  }
begin
 if ComboBoxEx1.ItemsEx.Count=0 then exit;
 ShowGroupInfo(ComboBoxEx1.Text,false,nil);
 ComboBoxEx1.ItemIndex:=-1;
 ComboBoxEx1.Text:=TEXT_MES_GROUPSA;
end;

procedure TFormQuickGroupInfo.ReloadGroups;
var
  i : integer;
  FCurrentGroups : TGroups;
begin
 FCurrentGroups:=EncodeGroups(FNewRelatedGroups);
 ComboBoxEx1.Items.Clear;
 For i:=0 to Length(FCurrentGroups)-1 do
 begin
  ComboBoxEx1.Items.Add(FCurrentGroups[i].GroupName);
 end;
 ComboBoxEx1.Text:=TEXT_MES_GROUPSA;
end;

procedure TFormQuickGroupInfo.ComboBoxEx1DropDown(Sender: TObject);
var
  i : integer;
  Group : TGroup;
  SmallB, B : TBitmap;
  GroupImageValud : Boolean;
  FCurrentGroups : TGroups;
begin
 GroupsImageList.Clear;
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 SmallB.Width:=16;
 SmallB.Height:=16;
 SmallB.Canvas.Pen.Color:=Theme_MainColor;
 SmallB.Canvas.Brush.Color:=Theme_MainColor;
 SmallB.Canvas.Rectangle(0,0,16,16);
 DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],16,16,0,0,DI_NORMAL);
 GroupsImageList.Add(SmallB,nil);
 SmallB.Free;
 FCurrentGroups:=EncodeGroups(FNewRelatedGroups);
 for i:=0 to Length(FCurrentGroups)-1 do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Canvas.Brush.Color:=Theme_MainColor;
  Group:=GetGroupByGroupName(FCurrentGroups[i].GroupName,true);
  GroupImageValud:=false;
  if Group.GroupImage<>nil then
  if not Group.GroupImage.Empty then
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   GroupImageValud:=true;
   B.Assign(Group.GroupImage);
   FreeGroup(Group);
   DoResize(15,15,B,SmallB);
   SmallB.Height:=16;
   SmallB.Width:=16;
   B.Free;
  end;
  GroupsImageList.Add(SmallB,nil);
  SmallB.Free;
  With ComboBoxEx1.ItemsEx[i] do
  begin
   if GroupImageValud then
   ImageIndex:=i+1 else ImageIndex:=0;
  end;
 end;
end;

procedure TFormQuickGroupInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.
