unit UnitEditGroupsForm;

interface

uses
  Dolphin_DB, UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, JPEG, UnitDBKernel, Math, UnitGroupsTools,
  Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls, AppEvnts, CmpUnit, ImgList,
  uVistaFuncs, UnitDBDeclare, UnitDBCommonGraphics;

type
  TEditGroupsForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    N1: TMenuItem;
    CreateGroup1: TMenuItem;
    ChangeGroup1: TMenuItem;
    GroupManeger1: TMenuItem;
    Button5: TButton;
    PopupMenu2: TPopupMenu;
    GroupManeger2: TMenuItem;
    QuickInfo1: TMenuItem;
    PopupMenu3: TPopupMenu;
    Clear1: TMenuItem;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    ApplicationEvents1: TApplicationEvents;
    SearchForGroup1: TMenuItem;
    GroupsImageList: TImageList;
    DestroyTimer: TTimer;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Button7: TButton;
    Button6: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    MoveToGroup1: TMenuItem;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ChangeGroup1Click(Sender: TObject);
    procedure GroupManeger1Click(Sender: TObject);
    procedure CreateGroup1Click(Sender: TObject);
    procedure RecreateGroupsList;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure QuickInfo1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure ComboBoxEx1_KeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button7Click(Sender: TObject);
    procedure MoveToGroup1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
    procedure ChangedDBDataGroups(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);

  public
    procedure Execute(var Groups: TGroups; var KeyWords: string; CanNew: Boolean = True);
    procedure LoadLanguage;
    { Public declarations }
  end;

procedure DBChangeGroups(var Groups : TGroups; var KeyWords : String; CanNew : Boolean = true); overload;
procedure DBChangeGroups(var SGroups : String; var KeyWords : String; CanNew : Boolean = true); overload;

implementation

uses UnitNewGroupForm, UnitManageGroups, UnitFormChangeGroup,
     UnitQuickGroupInfo, Language, Searching, SelectGroupForm;

{$R *.dfm}

{ TEditGroupsForm }

Procedure DBChangeGroups(var Groups : TGroups; var KeyWords : String; CanNew : Boolean = true);
var
  EditGroupsForm: TEditGroupsForm;
begin
  Application.CreateForm(TEditGroupsForm, EditGroupsForm);
  try
    EditGroupsForm.Execute(Groups, KeyWords, CanNew);
  finally
    EditGroupsForm.Release;
  end;
end;

Procedure DBChangeGroups(var SGroups : String; var KeyWords : String; CanNew : Boolean = true);
var
  FEditGroupsForm: TEditGroupsForm;
  Groups: TGroups;
begin
  Groups := EncodeGroups(SGroups);
  Application.CreateForm(TEditGroupsForm, FEditGroupsForm);
  try
    FEditGroupsForm.Execute(Groups, KeyWords, CanNew);
  finally
    FEditGroupsForm.Release;
  end;
  SGroups := CodeGroups(Groups);
end;

procedure TEditGroupsForm.Execute(var Groups: TGroups; var KeyWords : String; CanNew : Boolean = true);
var
  i : integer;
begin
 if not CanNew then
 begin
  Button3.Enabled:=false;
  Button5.Enabled:=false;
 end;
 FResult:=false;
 FNewKeyWords:=KeyWords;
 FOldGroups := CopyGroups(Groups);
 FOldKeyWords := KeyWords;
 fGroups:=CopyGroups(Groups);
 FSetGroups :=CopyGroups(Groups);
 ListBox1.Clear;
 For i:=0 to Length(Groups)-1 do
 begin
  ListBox1.Items.Add(Groups[i].GroupName);
 end;
 ShowModal;
 FreeGroups(Groups);
 if FResult then
 begin
  Groups:=CopyGroups(FSetGroups);
  KeyWords:=FNewKeyWords;
 end else
 begin
  Groups:=CopyGroups(FOldGroups);
  KeyWords:=FOldKeyWords;
 end;
 FreeGroups(FSetGroups);
 DestroyTimer.Enabled:=true;
end;

procedure TEditGroupsForm.Button1Click(Sender: TObject);
begin
 FResult:=false;
 Close;
end;

procedure TEditGroupsForm.FormCreate(Sender: TObject);
begin
 SetLength(fGroups,0);
 SetLength(FRegGroups,0);
 SetLength(FShowenRegGroups,0);

 RecreateGroupsList;
 DBKernel.RecreateThemeToForm(Self);
 DBKernel.RegisterChangesID(Self,ChangedDBDataGroups);
 LoadLanguage;
 CheckBox2.Checked:=DBkernel.ReadBool('Propetry','DeleteKeyWords',True);
 CheckBox3.Checked:=DBkernel.ReadBool('Propetry','ShowAllGroups',false);
end;

procedure TEditGroupsForm.Button3Click(Sender: TObject);
begin
 CreateNewGroupDialog;
end;

procedure TEditGroupsForm.Button2Click(Sender: TObject);
var
  i : integer;
  FGroup : TGroup;
begin
 FResult:=true;
 FreeGroups(FGroups);
 For i:=1 to ListBox1.Items.Count do
 begin
  SetLength(FGroups,Length(FGroups)+1);
  FGroups[Length(FGroups)-1].GroupName:=ListBox1.Items[i-1];
  FGroup:=GetGroupByGroupName(ListBox1.Items[i-1],false);
  FGroups[Length(FGroups)-1].GroupCode:=FGroup.GroupCode;
  if FGroup.AutoAddKeyWords then
  AddWordsA(FGroup.GroupKeyWords,FNewKeyWords);
 end;
 FSetGroups:=CopyGroups(FGroups);
 Close;
end;

procedure TEditGroupsForm.Button6Click(Sender: TObject);
var
  i : integer;
//  Group : TGroup;

  Procedure AddGroup(Group : TGroup);
  var
    FRelatedGroups : TGroups;
    OldGroups, Groups : TGroups;
    TempGroup : TGroup;
    i: integer;
  begin
   //добавляем связанные группы
   FRelatedGroups:=EncodeGroups(Group.RelatedGroups);
   //сохраняем что имели
   OldGroups:=CopyGroups(FSetGroups);
   //копируем?
   Groups:=CopyGroups(OldGroups);

   //добавили группу и связанные с ней группы
   AddGroupToGroups(Groups,Group);
   AddGroupsToGroups(Groups,FRelatedGroups);

   //занесли это всё в FSetGroups - результат
   FSetGroups:=CopyGroups(Groups);

   //получили все новые группы путём вычитаниясо старым
   RemoveGroupsFromGroups(Groups,OldGroups);
   for i:=0 to Length(Groups)-1 do
   begin
    //добавляем группу и ключевые слова к ней
    ListBox1.Items.Add(Groups[i].GroupName);
    TempGroup:=GetGroupByGroupCode(Groups[i].GroupCode,false);
    AddWordsA(TempGroup.GroupKeyWords,FNewKeyWords);
   end;
  end;

begin
 //добавляем выделенные групы в ListBox2
 for i:=0 to ListBox2.Items.Count-1 do
 if ListBox2.Selected[i] then
 begin
  AddGroup(FShowenRegGroups[i]);
 end;
 ListBox1.Invalidate;
 ListBox2.Invalidate;
end;

procedure TEditGroupsForm.ListBox1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ItemNo : Integer;
  i : integer;
begin
 ItemNo:=ListBox1.ItemAtPos(MousePos,True);
 If ItemNo<>-1 then
 begin
  if not ListBox1.Selected[ItemNo] then
  begin
   ListBox1.Selected[ItemNo]:=True;
   for i:=0 to ListBox1.Items.Count-1 do
   if i<>ItemNo then
   ListBox1.Selected[i]:=false;
  end;
  PopupMenu1.Tag:=ItemNo;
  PopupMenu1.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
 end else
 begin
  PopupMenu3.Popup(ListBox1.ClientToScreen(MousePos).X,ListBox1.ClientToScreen(MousePos).Y);
 end;
end;

procedure TEditGroupsForm.ChangeGroup1Click(Sender: TObject);
var
  Group : TGroup;
begin
 Group := GetGroupByGroupCode(FindGroupCodeByGroupName(ListBox1.Items[PopupMenu1.Tag]),false);
 DBChangeGroup(Group);
end;

procedure TEditGroupsForm.GroupManeger1Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TEditGroupsForm.CreateGroup1Click(Sender: TObject);
begin
 CreateNewGroupDialogA(fGroups[PopupMenu1.Tag].GroupName,fGroups[PopupMenu1.Tag].GroupCode);
end;

procedure TEditGroupsForm.RecreateGroupsList;
var
  i, size : integer;
  SmallB, B : TBitmap;
begin
 FreeGroups(FRegGroups);
 FreeGroups(FShowenRegGroups);
 FRegGroups:=GetRegisterGroupList(True);
 GroupsImageList.Clear;
 SmallB := TBitmap.Create;
 SmallB.PixelFormat:=pf24bit;
 SmallB.Width:=32;
 SmallB.Height:=32+2;
 SmallB.Canvas.Pen.Color:=Theme_MainColor;
 SmallB.Canvas.Brush.Color:=Theme_MainColor;
 SmallB.Canvas.Rectangle(0,0,SmallB.Width,SmallB.Height);
 DrawIconEx(SmallB.Canvas.Handle,0,0,UnitDBKernel.icons[DB_IC_GROUPS+1],SmallB.Width div 2 - 8,SmallB.Height div 2 - 8,0,0,DI_NORMAL);
 GroupsImageList.Add(SmallB,nil);
 SmallB.Free;
 ListBox2.Clear;
 for i:=0 to Length(FRegGroups)-1 do
 begin
  SmallB := TBitmap.Create;
  SmallB.PixelFormat:=pf24bit;
  SmallB.Canvas.Brush.Color:=Theme_MainColor;
  if FRegGroups[i].GroupImage<>nil then
  if not FRegGroups[i].GroupImage.Empty then
  begin
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   B.Canvas.Brush.Color:=Theme_MainColor;
   B.Canvas.Pen.Color:=Theme_MainColor;
   size:=Max(FRegGroups[i].GroupImage.Width,FRegGroups[i].GroupImage.Height);
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - FRegGroups[i].GroupImage.Width div 2, B.Height div 2 - FRegGroups[i].GroupImage.Height div 2,FRegGroups[i].GroupImage);
   DoResize(32,34,B,SmallB);
   B.Free;
  end;
  GroupsImageList.Add(SmallB,nil);
  if FRegGroups[i].IncludeInQuickList or CheckBox3.Checked then
  begin
   UnitGroupsWork.AddGroupToGroups(FShowenRegGroups,FRegGroups[i]);
   ListBox2.Items.Add(FRegGroups[i].GroupName);
  end;
  SmallB.Free;
 end;
end;

procedure TEditGroupsForm.PopupMenu1Popup(Sender: TObject);
begin
 if GroupWithCodeExists(FSetGroups[PopupMenu1.Tag].GroupCode) then
 begin
  CreateGroup1.Visible:=False;
  MoveToGroup1.Visible:=False;
  ChangeGroup1.Visible:=True;
 end else
 begin
  CreateGroup1.Visible:=True;
  MoveToGroup1.Visible:=True;
  ChangeGroup1.Visible:=False;
 end;
end;

procedure TEditGroupsForm.QuickInfo1Click(Sender: TObject);
begin
 ShowGroupInfo(fGroups[PopupMenu1.Tag],false,nil);
end;

procedure TEditGroupsForm.Clear1Click(Sender: TObject);
begin
 ListBox1.Clear;
 FreeGroups(FSetGroups);
 ListBox1.Invalidate;
 ListBox2.Invalidate;
end;

procedure TEditGroupsForm.ComboBoxEx1_KeyPress(Sender: TObject;
  var Key: Char);
begin
 Key:=#0;
end;

procedure TEditGroupsForm.ListBox1DblClick(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to ListBox1.Items.Count-1 do
 if ListBox1.Selected[i] then
 begin
  ShowGroupInfo(FSetGroups[i],false,nil);
  Break;
 end;
end;

procedure TEditGroupsForm.FormShow(Sender: TObject);
begin
 Button1.SetFocus;
end;

procedure TEditGroupsForm.LoadLanguage;
begin
 Caption := TEXT_MES_EDIT_GROUPS_CAPTION;
 Button5.Caption := TEXT_MES_GROUP_MANAGER_BUTTON;
 Button3.Caption := TEXT_MES_NEW_GROUP_BUTTON;
 Button1.Caption := TEXT_MES_CANCEL;
 Button2.Caption := TEXT_MES_OK;
 Label2.Caption := TEXT_MES_AVALIABLE_GROUPS;
 Label1.Caption := TEXT_MES_CURRENT_GROUPS;
 Clear1.Caption := TEXT_MES_CLEAR;
 GroupManeger2.Caption := TEXT_MES_GROUPS_MANAGER;
 Delete1.Caption := TEXT_MES_DELETE_ITEM;
 CreateGroup1.Caption := TEXT_MES_GREATE_GROUP;
 ChangeGroup1.Caption := TEXT_MES_CHANGE_GROUP;
 GroupManeger1.Caption := TEXT_MES_GROUPS_MANAGER;
 QuickInfo1.Caption :=  TEXT_MES_QUICK_INFO;
 SearchForGroup1.Caption:=TEXT_MES_SEARCH_FOR_GROUP;
 CheckBox3.Caption:=TEXT_MES_SHOW_ALL_GROUPS;
 CheckBox2.Caption:=TEXT_MES_DELETE_UNUSED_KEY_WORDS;
 MoveToGroup1.Caption:=TEXT_MES_MOVE_TO_GROUP;
 Label3.Caption:=TEXT_MES_GROUPS_EDIT_INFO;
end;


procedure TEditGroupsForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
{var
  i : integer;  }
begin
 if Msg.hwnd=ListBox1.Handle then
 if Msg.message=256 then
 if Msg.wParam=46 then
 begin
  Button7Click(nil);
 end;
end;

procedure TEditGroupsForm.SearchForGroup1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.NewSearch;
 NewSearch.SearchEdit.Text:=':Group('+fGroups[PopupMenu1.Tag].GroupName+'):';
 NewSearch.WlStartStop.OnClick(Sender);
 NewSearch.Show;
end;

procedure TEditGroupsForm.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
end;

procedure TEditGroupsForm.CheckBox3Click(Sender: TObject);
begin
 RecreateGroupsList;
 DBkernel.WriteBool('Propetry','ShowAllGroups',CheckBox3.Checked);
end;

procedure TEditGroupsForm.CheckBox2Click(Sender: TObject);
begin
 DBkernel.WriteBool('Propetry','DeleteKeyWords',CheckBox2.Checked);
end;

procedure TEditGroupsForm.ListBox2DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  n, i, w : Integer;
  xNewGroups : TGroups;
  Text,Text1 : string;
  function NewGroup(GroupCode : String) : Boolean;
  var
    j : integer;
  begin
   Result:=false;
   for j:=0 to Length(xNewGroups)-1 do
   if xNewGroups[j].GroupCode=GroupCode then
   begin
    Result:=true;
    Break;
   end;
  end;

  function GroupExists(GroupCode : String) : Boolean;
  var
    j : integer;
  begin
   Result:=false;
   for j:=0 to Length(FSetGroups)-1 do
   if FSetGroups[j].GroupCode=GroupCode then
   begin
    Result:=true;
    Break;
   end;
  end;

begin
 if Control=ListBox1 then
 begin
  xNewGroups:=CopyGroups(FSetGroups);
  RemoveGroupsFromGroups(xNewGroups,FOldGroups);
 end else
 begin
  xNewGroups:=CopyGroups(FOldGroups);
  RemoveGroupsFromGroups(xNewGroups,FSetGroups);
 end;
 try
  if Index=-1 then exit;
  with (Control as TListBox).Canvas do
  begin
//   if Length(FRegGroups)-1<Index then exit;
//   if Length(FRegGroups)=0 then exit;
   FillRect(Rect);
   n:=-1;
   if Control=ListBox1 then
   begin
    for i:=0 to Length(FRegGroups)-1 do
    begin
     if FRegGroups[i].GroupCode=FSetGroups[Index].GroupCode then
     begin
      n:=i+1;
      break;
     end;
    end
   end else
   begin
    for i:=0 to Length(FRegGroups)-1 do
    begin
     if FRegGroups[i].GroupName=(Control as TListBox).Items[Index] then
     begin
      n:=i+1;
      break;
     end;
    end
   end;

   GroupsImageList.Draw((Control as TListBox).Canvas,Rect.Left+2,Rect.Top+2,Max(0,n));
   if n=-1 then
   begin
    DrawIconEx((Control as TListBox).Canvas.Handle,Rect.Left+10,Rect.Top+8,UnitDBKernel.icons[DB_IC_DELETE_INFO+1],8,8,0,0,DI_NORMAL);
   end;
   if Control=ListBox1 then
   if NewGroup(FSetGroups[Index].GroupCode) then
   (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style+[fsBold] else (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style-[fsBold];

   if Control=ListBox2 then
   if n>-1 then
   if NewGroup(FRegGroups[n-1].GroupCode) then
    (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style+[fsBold] else
    begin
     if GroupExists(FShowenRegGroups[Index].GroupCode) then
     begin
      (Control as TListBox).Canvas.Font.Color:=ColorDiv2(Theme_ListFontColor,Theme_MemoEditColor);
     end else
     begin
      (Control as TListBox).Canvas.Font.Color:=Theme_ListFontColor;
     end;
    (Control as TListBox).Canvas.Font.Style:=(Control as TListBox).Canvas.Font.Style-[fsBold];
   end;
   Text:=(Control as TListBox).Items[Index];
   w:=Control.Width div (Control as TListBox).Canvas.TextWidth('w');
   Text1:=Copy(Text,1,Min(Length(Text),w));
   Delete(Text,1,Length(Text1));
   if Text<>'' then
   if Text1[Length(Text1)] in ['a'..'z','A'..'Z','а'..'Я','а'..'Я'] then
   if Text[1] in ['a'..'z','A'..'Z','а'..'Я','а'..'Я'] then
   Text1:=Text1+'-';
   TextOut(Rect.Left+32+5, Rect.Top+3, Text1);
   TextOut(Rect.Left+32+5, Rect.Top+3+14, Text);
  end;
 except
 end;
end;

function TEditGroupsForm.aGetGroupByCode(GroupCode: String): integer;
var
  i : integer;
begin
 Result:=-1;
 for i:=0 to Length(FRegGroups)-1 do
 if FRegGroups[i].GroupCode=GroupCode then
 begin
  Result:=i;
  break;
 end;
end;

procedure TEditGroupsForm.Button7Click(Sender: TObject);
var
  i, j : integer;
  KeyWords, AllGroupsKeyWords, GroupKeyWords : String;
begin
 for i:=ListBox1.Items.Count-1 downto 0 do
 if ListBox1.Selected[i] then
 // смотрим выделенный группы для удаления
 begin

//  if aGetGroupByCode(fGroups[i].GroupCode)>-1 then
//  RemoveGroupFromGroups(FSetGroups,FRegGroups[aGetGroupByCode(fGroups[i].GroupCode)]);

  //если удаление ключевых слов ненужных то удаляем их
  if CheckBox2.Checked then
  begin
   AllGroupsKeyWords:='';
   for j:=ListBox1.Items.Count-1 downto 0 do
   if i<>j then
   begin
    if aGetGroupByCode(FSetGroups[j].GroupCode)>-1 then
    AddWordsA(FRegGroups[aGetGroupByCode(FSetGroups[j].GroupCode)].GroupKeyWords,AllGroupsKeyWords);
   end;
   KeyWords:=FNewKeyWords;
   if aGetGroupByCode(FSetGroups[i].GroupCode)>-1 then
   GroupKeyWords:=FRegGroups[aGetGroupByCode(FSetGroups[i].GroupCode)].GroupKeyWords;
   DeleteWords(GroupKeyWords,AllGroupsKeyWords);
   DeleteWords(KeyWords,GroupKeyWords);
   FNewKeyWords:=KeyWords;
  end;

  //удаляем группу изтекущих

  RemoveGroupFromGroups(FSetGroups,FSetGroups[i]);

  ListBox1.Items.Delete(i);

 end;
 ListBox1.Invalidate;
 ListBox2.Invalidate;
end;

procedure TEditGroupsForm.MoveToGroup1Click(Sender: TObject);
var
  ToGroup : TGroup;
begin
 if SelectGroup(ToGroup) then
 begin
  MoveGroup(FSetGroups[PopupMenu1.Tag],ToGroup);
  MessageBoxDB(Handle,TEXT_MES_RELOAD_INFO,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
 end;
end;

procedure TEditGroupsForm.ChangedDBDataGroups(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
begin
 if EventID_Param_GroupsChanged in params then
 begin
  RecreateGroupsList;
  Exit;
 end;
end;

procedure TEditGroupsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 DestroyTimer.Enabled:=true;
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataGroups);
end;

procedure TEditGroupsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.
