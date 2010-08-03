unit UnitFormChangeGroup;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Math, UnitGroupsTools, uVistaFuncs,
  Dialogs, Menus, ExtDlgs, StdCtrls, jpeg, ExtCtrls, UnitDBDeclare,
  ComCtrls, ImgList, GraphicSelectEx, UnitDBCommonGraphics, UnitDBCommon,
  uConstants, uFileUtils;

type
  TFormChangeGroup = class(TForm)
    Image1: TImage;
    Edit1: TEdit;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    CommentLabel: TLabel;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    ComboBoxEx1: TComboBoxEx;
    CheckBox2: TCheckBox;
    GroupsImageList: TImageList;
    GraphicSelect1: TGraphicSelectEx;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure RelodDllNames;
    procedure Image1Click(Sender: TObject);
    procedure ComboBoxEx1DblClick(Sender: TObject);
    procedure ComboBoxEx1DropDown(Sender: TObject);
    procedure ComboBoxEx1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxEx1Select(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
  FGroup : TGroup;
  Saving : Boolean;
  FNewRelatedGroups : String;
  FGroupDate : TDateTime;
    { Private declarations }
  public
  Procedure Execute(GroupCode : String);
  Procedure LoadLanguage;
  procedure ReloadGroups;
    { Public declarations }
  end;

Procedure DBChangeGroup(Group : TGroup);

implementation

uses UnitDBKernel, Language, UnitQuickGroupInfo, UnitEditGroupsForm;

{$R *.dfm}

Procedure DBChangeGroup(Group : TGroup);
var
  FormChangeGroup: TFormChangeGroup;
begin
 Application.CreateForm(TFormChangeGroup,FormChangeGroup);
 FormChangeGroup.Execute(Group.GroupCode);
 FormChangeGroup.Release;
 if UseFreeAfterRelease then FormChangeGroup.Free;
end;

procedure TFormChangeGroup.FormCreate(Sender: TObject);
begin
 Saving:=false;
 DBkernel.RecreateThemeToForm(Self);
 LoadLanguage;
 RelodDllNames;
end;

Procedure TFormChangeGroup.Execute(GroupCode : String);
var
  Group : TGroup;
begin
 Group:=GetGroupByGroupCode(GroupCode,True);
 if Group.GroupName='' then
 begin
  MessageBoxDB(Handle,TEXT_MES_GROUP_NOT_FOUND,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Exit;
 end;
 FGroup:=CopyGroup(Group);
 try
 if Group.GroupImage<>nil then
  Image1.Picture.Graphic.Assign(Group.GroupImage);
  Edit1.Text:=Group.GroupName;
 except
 end;
 FGroupDate:=Group.GroupDate;
 Memo1.Text:=Group.GroupComment;
 Memo2.Text:=Group.GroupKeyWords;
 CheckBox1.Checked:=Group.AutoAddKeyWords;
 If Group.GroupAccess=GROUP_ACCESS_COMMON then
 RadioButton1.Checked:=True;
 If Group.GroupAccess=GROUP_ACCESS_PRIVATE then
 RadioButton2.Checked:=True;
 CheckBox2.Checked:=Group.IncludeInQuickList;
 FNewRelatedGroups:=Group.RelatedGroups;
 ReloadGroups;
 ShowModal;
end;

procedure TFormChangeGroup.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TFormChangeGroup.Button1Click(Sender: TObject);
var
  Group : TGroup;
  EventInfo : TEventValues;
begin
 if GroupNameExists(Edit1.text) and (FGroup.GroupName<>Edit1.text) then
 begin
  MessageBoxDB(Handle,TEXT_MES_GROUP_ALREADY_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Exit;
 end;
 if FGroup.GroupName<>Edit1.text then
 begin
  if ID_OK <> MessageBoxDB(Handle,TEXT_MES_GROUP_RENAME_GROUP_CONFIRM,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
 end;
 Saving:=true;
 Edit1.Enabled:=false;
 Memo1.Enabled:=false;
 Memo2.Enabled:=false;
 CheckBox1.Enabled:=false;
 ComboBoxEx1.Enabled:=false;
 CheckBox2.Enabled:=false;
 RadioButton1.Enabled:=false;
 RadioButton2.Enabled:=false;
 Button1.Enabled:=false;
 Button2.Enabled:=false;

 Group.GroupName:=Edit1.text;
 Group.GroupImage:=TJpegImage.Create;
 Group.GroupCode:=FGroup.GroupCode;
 Group.GroupDate:=FGroupDate;
 Group.GroupImage.Assign(Image1.Picture.Graphic as TJpegImage);
 Group.GroupComment:=Memo1.Text;
 Group.GroupKeyWords:=Memo2.Text;
 Group.AutoAddKeyWords:=CheckBox1.Checked;
 Group.IncludeInQuickList:=CheckBox2.Checked;
 Group.RelatedGroups:=FNewRelatedGroups;
 If RadioButton1.Checked then
 Group.GroupAccess:=GROUP_ACCESS_COMMON;
 If RadioButton2.Checked then
 Group.GroupAccess:=GROUP_ACCESS_PRIVATE;
 if UpdateGroup(Group) then
 if FGroup.GroupName<>Edit1.text then
 begin
  RenameGroup(FGroup,Edit1.text);
  MessageBoxDB(Handle,TEXT_MES_RELOAD_INFO,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
 end;
 FreeGroup(Group);
 DBKernel.DoIDEvent(Self,0,[EventID_Param_GroupsChanged],EventInfo);
 Close;
end;

procedure TFormChangeGroup.LoadLanguage;
begin
 Caption := TEXT_MES_CHANGE_GROUP_CAPTION;
 Button1.Caption:= TEXT_MES_OK;
 Button2.Caption:= TEXT_MES_CANCEL;
 RadioButton1.Caption:= TEXT_MES_COMMON_GROUP;
 RadioButton2.Caption:= TEXT_MES_PRIVATE_GROUP;
 Memo1.Text := TEXT_MES_GROUP_COMMENTA;
 Edit1.Text:=TEXT_MES_NEW_GROUP_NAME;
 LoadFromFile1.Caption:=TEXT_MES_LOAD_FROM_FILE;
 CheckBox1.Caption:=TEXT_MES_AUTO_ADD_KEYWORDS;
 KeyWordsLabel.Caption:=TEXT_MES_KEYWORDS_FOR_GROUP;
 CommentLabel.Caption:=TEXT_MES_GROUP_COMMENT;
 CheckBox2.Caption:=TEXT_MES_INCLUDE_IN_QUICK_LISTS;
 Label3.Caption:=TEXT_MES_RELATED_GROUPS+':';
end;

procedure TFormChangeGroup.LoadFromFile1Click(Sender: TObject);
begin
 LoadNickJpegImage(Image1);
end;

procedure TFormChangeGroup.GraphicSelect1ImageSelect(Sender: TObject;
  Bitmap: TBitmap);
var
  b : TBitmap;
  h, w : integer;
begin
 b:=TBitmap.Create;
 b.PixelFormat:=pf24bit;
 w:=Bitmap.Width;
 h:=Bitmap.Height;
 If Max(w,h)<48 then B.Assign(Bitmap) else
 begin
  ProportionalSize(48,48,w,h);
  DoResize(w,h,Bitmap,b);
 end;
 Image1.Picture.Graphic.Assign(b);
 b.free;
 Image1.Refresh;
end;

procedure TFormChangeGroup.RelodDllNames;
var
  Found  : integer;
  SearchRec : TSearchRec;
  Directory : string;
  TS : tstrings;
begin
 Ts:= TStringList.Create;
 Ts.Clear;
 Directory:=ProgramDir;
 FormatDir(Directory);
 Directory:=Directory+PlugInImagesFolder;
 Found := FindFirst(Directory+'*.jpgc', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If fileexists(Directory+SearchRec.Name) then
   try
    if ValidJPEGContainer(Directory+SearchRec.Name) then
    TS.Add(Directory+SearchRec.Name);
   except
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);
 GraphicSelect1.Galeries:=Ts;
 GraphicSelect1.Showgaleries:=true;
end;

procedure TFormChangeGroup.Image1Click(Sender: TObject);
var
  p : Tpoint;
begin
  if Saving then exit;
  GetCursorPos(p);
  GraphicSelect1.RequestPicture(p.X,p.y);
end;

procedure TFormChangeGroup.ComboBoxEx1DblClick(Sender: TObject);
var
  KeyWords : string;
begin
 DBChangeGroups(FNewRelatedGroups,KeyWords);
end;

procedure TFormChangeGroup.ComboBoxEx1DropDown(Sender: TObject);
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
 SmallB.Canvas.Pen.Color:=Theme_ListColor;
 SmallB.Canvas.Brush.Color:=Theme_ListColor;
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
 if ComboBoxEx1.ItemsEx.Count<>0 then
 With ComboBoxEx1.ItemsEx[ComboBoxEx1.ItemsEx.Count-1] do ImageIndex:=0;
end;

procedure TFormChangeGroup.ComboBoxEx1KeyPress(Sender: TObject;
  var Key: Char);
begin
 Key:=#0;
end;

procedure TFormChangeGroup.ComboBoxEx1Select(Sender: TObject);
var
  KeyWords : string;
begin
 Application.ProcessMessages;
 if ComboBoxEx1.ItemsEx.Count=0 then exit;
 if (ComboBoxEx1.Text=ComboBoxEx1.Items[ComboBoxEx1.Items.Count-1]) then
 begin
  DBChangeGroups(FNewRelatedGroups,KeyWords,false);
  Application.ProcessMessages;
  ReloadGroups;
 end else
 begin
  ShowGroupInfo(ComboBoxEx1.Text,false,nil);
  ComboBoxEx1.Text:=TEXT_MES_GROUPSA;
 end;
 ComboBoxEx1.ItemIndex:=-1;
end;

procedure TFormChangeGroup.ReloadGroups;
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

 ComboBoxEx1.Items.Add(TEXT_MES_MANAGEA);
 ComboBoxEx1.Text:=TEXT_MES_GROUPSA;
end;

procedure TFormChangeGroup.PopupMenu1Popup(Sender: TObject);
begin
 LoadFromFile1.Visible:= not Saving;
end;

end.
