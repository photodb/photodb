unit UnitFormChangeGroup;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Math, UnitGroupsTools, uVistaFuncs,
  Dialogs, Menus, ExtDlgs, StdCtrls, jpeg, ExtCtrls, UnitDBDeclare,
  ComCtrls, ImgList, GraphicSelectEx, UnitDBCommonGraphics, UnitDBCommon,
  uConstants, uFileUtils, uDBForm, WatermarkedEdit;

type
  TFormChangeGroup = class(TDBForm)
    ImgMain: TImage;
    MemComments: TMemo;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PmLoadFromFile: TPopupMenu;
    LoadFromFile1: TMenuItem;
    MemKeywords: TMemo;
    CbAddkeywords: TCheckBox;
    CommentLabel: TLabel;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    ComboBoxEx1: TComboBoxEx;
    CbInclude: TCheckBox;
    GroupsImageList: TImageList;
    GraphicSelect1: TGraphicSelectEx;
    EdwName: TWatermarkedEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure RelodDllNames;
    procedure ImgMainClick(Sender: TObject);
    procedure ComboBoxEx1DblClick(Sender: TObject);
    procedure ComboBoxEx1DropDown(Sender: TObject);
    procedure ComboBoxEx1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxEx1Select(Sender: TObject);
    procedure PmLoadFromFilePopup(Sender: TObject);
  private
    { Private declarations }
    FGroup: TGroup;
    Saving: Boolean;
    FNewRelatedGroups: string;
    FGroupDate: TDateTime;
  public
    { Public declarations }
    procedure Execute(GroupCode: string);
    procedure LoadLanguage;
    procedure ReloadGroups;
  end;

procedure DBChangeGroup(Group: TGroup);

implementation

uses UnitDBKernel, Language, UnitQuickGroupInfo, UnitEditGroupsForm;

{$R *.dfm}

procedure DBChangeGroup(Group: TGroup);
var
  FormChangeGroup: TFormChangeGroup;
begin
  Application.CreateForm(TFormChangeGroup, FormChangeGroup);
  try
    FormChangeGroup.Execute(Group.GroupCode);
  finally
    FormChangeGroup.Release;
  end;
end;

procedure TFormChangeGroup.FormCreate(Sender: TObject);
begin
  Saving := False;
  LoadLanguage;
  RelodDllNames;
end;

Procedure TFormChangeGroup.Execute(GroupCode : String);
var
  Group : TGroup;
begin
  Group := GetGroupByGroupCode(GroupCode, True);
  if Group.GroupName = '' then
  begin
    MessageBoxDB(Handle, L('Group not found!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  FGroup := CopyGroup(Group);
  try
    if Group.GroupImage <> nil then
      ImgMain.Picture.Graphic := Group.GroupImage;
    EdwName.Text := Group.GroupName;

    FGroupDate := Group.GroupDate;
    MemComments.Text := Group.GroupComment;
    MemKeywords.Text := Group.GroupKeyWords;
    CbAddkeywords.Checked := Group.AutoAddKeyWords;
    if Group.GroupAccess = GROUP_ACCESS_COMMON then
      RadioButton1.Checked := True;
    if Group.GroupAccess = GROUP_ACCESS_PRIVATE then
      RadioButton2.Checked := True;
    CbInclude.Checked := Group.IncludeInQuickList;
    FNewRelatedGroups := Group.RelatedGroups;

  finally
    FreeGroup(FGroup);
  end;
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
  if GroupNameExists(EdwName.Text) and (FGroup.GroupName <> EdwName.Text) then
  begin
    MessageBoxDB(Handle, TEXT_MES_GROUP_ALREADY_EXISTS, L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if FGroup.GroupName <> EdwName.Text then
  begin
    if ID_OK <> MessageBoxDB(Handle, TEXT_MES_GROUP_RENAME_GROUP_CONFIRM, L('Warning'), TD_BUTTON_OKCANCEL,
      TD_ICON_WARNING) then
      Exit;
  end;
  Saving := True;
  EdwName.Enabled := False;
  MemComments.Enabled := False;
  MemKeywords.Enabled := False;
  CbAddkeywords.Enabled := False;
  ComboBoxEx1.Enabled := False;
  CbInclude.Enabled := False;
  RadioButton1.Enabled := False;
  RadioButton2.Enabled := False;
  Button1.Enabled := False;
  Button2.Enabled := False;

  Group.GroupName := EdwName.Text;
  Group.GroupImage := TJpegImage.Create;
  Group.GroupCode := FGroup.GroupCode;
  Group.GroupDate := FGroupDate;
  Group.GroupImage.Assign(ImgMain.Picture.Graphic);
  Group.GroupImage.JPEGNeeded;
  Group.GroupComment := MemComments.Text;
  Group.GroupKeyWords := MemKeywords.Text;
  Group.AutoAddKeyWords := CbAddkeywords.Checked;
  Group.IncludeInQuickList := CbInclude.Checked;
  Group.RelatedGroups := FNewRelatedGroups;
  if RadioButton1.Checked then
    Group.GroupAccess := GROUP_ACCESS_COMMON;
  if RadioButton2.Checked then
    Group.GroupAccess := GROUP_ACCESS_PRIVATE;
  if UpdateGroup(Group) then
    if FGroup.GroupName <> EdwName.Text then
    begin
      RenameGroup(FGroup, EdwName.Text);
      MessageBoxDB(Handle, TEXT_MES_RELOAD_INFO, L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
    end;
  FreeGroup(Group);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged], EventInfo);
  Close;
end;

procedure TFormChangeGroup.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := TEXT_MES_CHANGE_GROUP_CAPTION;
    Button1.Caption := TEXT_MES_OK;
    Button2.Caption := TEXT_MES_CANCEL;
    RadioButton1.Caption := TEXT_MES_COMMON_GROUP;
    RadioButton2.Caption := TEXT_MES_PRIVATE_GROUP;
    MemComments.Text := TEXT_MES_GROUP_COMMENTA;
    EdwName.WatermarkText := TEXT_MES_NEW_GROUP_NAME;
    LoadFromFile1.Caption := TEXT_MES_LOAD_FROM_FILE;
    CbAddkeywords.Caption := TEXT_MES_AUTO_ADD_KEYWORDS;
    KeyWordsLabel.Caption := TEXT_MES_KEYWORDS_FOR_GROUP;
    CommentLabel.Caption := TEXT_MES_GROUP_COMMENT;
    CbInclude.Caption := TEXT_MES_INCLUDE_IN_QUICK_LISTS;
    Label3.Caption := TEXT_MES_RELATED_GROUPS + ':';
  finally
    EndTranslate;
  end;
end;

procedure TFormChangeGroup.LoadFromFile1Click(Sender: TObject);
begin
  LoadNickJpegImage(ImgMain);
end;

procedure TFormChangeGroup.GraphicSelect1ImageSelect(Sender: TObject;
  Bitmap: TBitmap);
var
  B: TBitmap;
  H, W: Integer;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    W := Bitmap.Width;
    H := Bitmap.Height;
    if Max(W, H) < 48 then
      B.Assign(Bitmap)
    else
    begin
      ProportionalSize(48, 48, W, H);
      DoResize(W, H, Bitmap, B);
    end;
    ImgMain.Picture.Graphic := B;
  finally
    B.Free;
  end;
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

procedure TFormChangeGroup.ImgMainClick(Sender: TObject);
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

procedure TFormChangeGroup.PmLoadFromFilePopup(Sender: TObject);
begin
 LoadFromFile1.Visible:= not Saving;
end;

end.
