unit UnitNewGroupForm;

interface

uses
  UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, ExtDlgs, Jpeg, Dolphin_DB,
  Menus, GraphicEx, Gifimage, Math, ComCtrls, ImgList, GraphicSelectEx,
  uVistaFuncs, UnitDBDeclare, UnitDBCommonGraphics, UnitDBCommon, uConstants,
  uFileUtils;

type
  TNewGroupForm = class(TForm)
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
    Label1: TLabel;
    Label2: TLabel;
    ComboBoxEx1: TComboBoxEx;
    Label3: TLabel;
    GroupsImageList: TImageList;
    CheckBox2: TCheckBox;
    GraphicSelect1: TGraphicSelectEx;
    procedure Image1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Execute;
    procedure ExecuteA(GroupName, GroupCode : String);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExecuteB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
    procedure RelodDllNames;
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure ComboBoxEx1DropDown(Sender: TObject);
    procedure ComboBoxEx1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxEx1DblClick(Sender: TObject);
    procedure ComboBoxEx1Select(Sender: TObject);
    procedure ReloadGroups;
  private
  FExecuteA : Boolean;
  FExecuteW : Boolean;
  FNewGroupName, FGroupCode : String;
  FCreated : Boolean;
  FNewRelatedGroups : String;
    { Private declarations }
  public
  Procedure LoadLanguage;
    { Public declarations }
  end;

Procedure CreateNewGroupDialog;
Procedure CreateNewGroupDialogA(GroupName,GroupCode : String);
Procedure CreateNewGroupDialogB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);

implementation

uses UnitDBKernel, Language, UnitEditGroupsForm, UnitQuickGroupInfo;

{$R *.dfm}

Procedure CreateNewGroupDialog;
var
  NewGroupForm: TNewGroupForm;
begin
 if not IsValidGroupsTable then
 if ThisFileInstalled or DBInDebug then
 CreateGroupsTable;
 Application.CreateForm(TNewGroupForm, NewGroupForm);
 NewGroupForm.Execute;
 NewGroupForm.Release;
 NewGroupForm:=nil;
end;

Procedure CreateNewGroupDialogA(GroupName,GroupCode : String);
var
  NewGroupForm: TNewGroupForm;
begin
 Application.CreateForm(TNewGroupForm, NewGroupForm);
 NewGroupForm.ExecuteA(GroupName,GroupCode);
 NewGroupForm.Release;
 NewGroupForm:=nil;
end;

Procedure CreateNewGroupDialogB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
var
  NewGroupForm: TNewGroupForm;
begin
 Application.CreateForm(TNewGroupForm, NewGroupForm);
 NewGroupForm.ExecuteB(GroupCode,Image,Created,GroupName);
 NewGroupForm.Release;
 NewGroupForm:=nil;
end;

procedure TNewGroupForm.Image1Click(Sender: TObject);
var
  p : Tpoint;
begin
  GetCursorPos(p);
  GraphicSelect1.RequestPicture(p.X,p.y);
end;

procedure TNewGroupForm.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TNewGroupForm.Execute;
begin
 FExecuteA:=false;
 FNewRelatedGroups:='';
 ReloadGroups;
 ShowModal;
end;

procedure TNewGroupForm.Button1Click(Sender: TObject);
var
  Group : TGroup;
  EventInfo : TEventValues;
begin
 if GroupNameExists(Edit1.text) then
 begin
  MessageBoxDB(Handle,TEXT_MES_GROUP_ALREADY_EXISTS,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  Exit;
 end;
 Group.GroupName:=Edit1.text;
 Group.GroupImage:=TJpegImage.Create;
 if not FExecuteA then Group.GroupCode:=CreateNewGroupCode else
 Group.GroupCode:=FGroupCode;
 Group.GroupImage.Assign(Image1.Picture.Graphic as TJpegImage);
 Group.GroupComment:=Memo1.Text;
 Group.GroupKeyWords:=Memo2.Text;
 Group.AutoAddKeyWords:=CheckBox1.Checked;
 If RadioButton1.Checked then
 Group.GroupAccess:=GROUP_ACCESS_COMMON;
 If RadioButton2.Checked then
 Group.GroupAccess:=GROUP_ACCESS_PRIVATE;
 Group.RelatedGroups:=FNewRelatedGroups;
 Group.IncludeInQuickList:=CheckBox2.Checked;
 Group.GroupDate:=0;
 AddGroup(Group);
 if GroupNameExists(Edit1.text) then
 begin
  FCreated:=true;
  FNewGroupName:=Edit1.text;
 end;
 FreeGroup(Group);
 DBKernel.DoIDEvent(Self,0,[EventID_Param_GroupsChanged],EventInfo);
 Close;
end;

procedure TNewGroupForm.FormCreate(Sender: TObject);
begin
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;
 RelodDllNames;
end;

procedure TNewGroupForm.ExecuteA(GroupName, GroupCode: String);
begin
 Edit1.Text:=GroupName;
 Edit1.ReadOnly:=True;
 FExecuteA:=True;
 FExecuteW:=False;
 FGroupCode:=GroupCode;
 FNewRelatedGroups:='';
 ReloadGroups;
 ShowModal;
end;

procedure TNewGroupForm.ExecuteB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
begin
 Edit1.Text:=TEXT_MES_NEW_GROUP;;
 Edit1.ReadOnly:=false;
 if image<>nil then
 begin
  Image1.Picture.Graphic:=TJpegImage.Create;
  Image1.Picture.Assign(Image);
 end;
 FExecuteA:=False;
 FCreated:=false;
 FExecuteW:=True;
 FGroupCode:=GroupCode;
 ShowModal;
 GroupName:=FNewGroupName;
 Created:=FCreated;
end;

procedure TNewGroupForm.LoadLanguage;
begin
 Caption := TEXT_MES_CREATE_GROUP_CAPTION;
 Button1.Caption:= TEXT_MES_OK;
 Button2.Caption:= TEXT_MES_CANCEL;
 RadioButton1.Caption:= TEXT_MES_COMMON_GROUP;
 RadioButton2.Caption:= TEXT_MES_PRIVATE_GROUP;
 Memo1.Text := TEXT_MES_GROUP_COMMENTA;
 Memo2.Text:='';
 Edit1.Text:=TEXT_MES_NEW_GROUP_NAME;
 LoadFromFile1.Caption:=TEXT_MES_LOAD_FROM_FILE;
 CheckBox1.Caption:=TEXT_MES_AUTO_ADD_KEYWORDS;
 Label2.Caption:=TEXT_MES_COMMENTS_FOR_GROUP;
 Label1.Caption:=TEXT_MES_KEYWORDS_FOR_GROUP;
 CheckBox2.Caption:=TEXT_MES_INCLUDE_IN_QUICK_LISTS;
 Label3.Caption:=TEXT_MES_RELATED_GROUPS+':';
end;

procedure TNewGroupForm.RelodDllNames;
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
 Directory:=Directory + PlugInImagesFolder;
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

procedure TNewGroupForm.GraphicSelect1ImageSelect(Sender: TObject;
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
  StretchCool(w,h,Bitmap,b);
 end;
 Image1.Picture.Graphic.Assign(b);
 b.free;
 Image1.Refresh;
end;

procedure TNewGroupForm.LoadFromFile1Click(Sender: TObject);
begin
 LoadNickJpegImage(Image1);
end;

procedure TNewGroupForm.ComboBoxEx1DropDown(Sender: TObject);
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
// ComboBoxEx1.ItemIndex:=ComboBoxEx1.ItemsEx.Count-1;
 if ComboBoxEx1.ItemsEx.Count<>0 then
 With ComboBoxEx1.ItemsEx[ComboBoxEx1.ItemsEx.Count-1] do ImageIndex:=0;
end;

procedure TNewGroupForm.ComboBoxEx1KeyPress(Sender: TObject;
  var Key: Char);
begin
 Key:=#0;
end;

procedure TNewGroupForm.ComboBoxEx1DblClick(Sender: TObject);
var
  KeyWords : string;
begin
 DBChangeGroups(FNewRelatedGroups, KeyWords);
end;

procedure TNewGroupForm.ComboBoxEx1Select(Sender: TObject);
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
 end;
 ComboBoxEx1.ItemIndex:=-1;
 ComboBoxEx1.Text:=TEXT_MES_GROUPSA;
end;

procedure TNewGroupForm.ReloadGroups;
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

end.
