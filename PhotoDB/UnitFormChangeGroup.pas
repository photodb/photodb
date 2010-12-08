unit UnitFormChangeGroup;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Math, UnitGroupsTools, uVistaFuncs,
  Dialogs, Menus, ExtDlgs, StdCtrls, jpeg, ExtCtrls, UnitDBDeclare,
  ComCtrls, ImgList, GraphicSelectEx, UnitDBCommonGraphics, UnitDBCommon,
  uConstants, uFileUtils, uDBForm, WatermarkedEdit, WatermarkedMemo;

type
  TFormChangeGroup = class(TDBForm)
    ImgMain: TImage;
    MemComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    PmLoadFromFile: TPopupMenu;
    LoadFromFile1: TMenuItem;
    MemKeywords: TWatermarkedMemo;
    CbAddkeywords: TCheckBox;
    CommentLabel: TLabel;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    ComboBoxEx1: TComboBoxEx;
    CbInclude: TCheckBox;
    GroupsImageList: TImageList;
    GraphicSelect1: TGraphicSelectEx;
    EdName: TWatermarkedEdit;
    CbPrivateGroup: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
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
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute(GroupCode: string);
    procedure LoadLanguage;
    procedure ReloadGroups;
  end;

procedure DBChangeGroup(Group: TGroup);

implementation

uses UnitDBKernel, UnitQuickGroupInfo, UnitEditGroupsForm;

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
    EdName.Text := Group.GroupName;

    FGroupDate := Group.GroupDate;
    MemComments.Text := Group.GroupComment;
    MemKeywords.Text := Group.GroupKeyWords;
    CbAddkeywords.Checked := Group.AutoAddKeyWords;
    CbPrivateGroup.Checked := Group.GroupAccess = GROUP_ACCESS_PRIVATE;
    CbInclude.Checked := Group.IncludeInQuickList;
    FNewRelatedGroups := Group.RelatedGroups;

  finally
    FreeGroup(FGroup);
  end;
  ReloadGroups;
  ShowModal;
end;

procedure TFormChangeGroup.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormChangeGroup.BtnOkClick(Sender: TObject);
var
  Group : TGroup;
  EventInfo : TEventValues;
begin
  if GroupNameExists(EdName.Text) and (FGroup.GroupName <> EdName.Text) then
  begin
    MessageBoxDB(Handle, L('Group with this name alreadt exists!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if FGroup.GroupName <> EdName.Text then
  begin
    if ID_OK <> MessageBoxDB(Handle, L('Do you really want ot change name of group?'), L('Warning'), TD_BUTTON_OKCANCEL,
      TD_ICON_WARNING) then
      Exit;
  end;
  Saving := True;
  EdName.Enabled := False;
  MemComments.Enabled := False;
  MemKeywords.Enabled := False;
  CbAddkeywords.Enabled := False;
  ComboBoxEx1.Enabled := False;
  CbInclude.Enabled := False;
  CbPrivateGroup.Enabled := False;
  BtnOk.Enabled := False;
  BtnCancel.Enabled := False;

  Group.GroupName := EdName.Text;
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
  if CbPrivateGroup.Checked then
    Group.GroupAccess := GROUP_ACCESS_PRIVATE
  else
    Group.GroupAccess := GROUP_ACCESS_COMMON;
  if UpdateGroup(Group) then
    if FGroup.GroupName <> EdName.Text then
    begin
      RenameGroup(FGroup, EdName.Text);
      MessageBoxDB(Handle, L('Update the data in the windows to apply changes!'), L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
    end;
  FreeGroup(Group);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged], EventInfo);
  Close;
end;

procedure TFormChangeGroup.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Edit group');
    EdName.WatermarkText := L('Enter group name');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    CbPrivateGroup.Caption := L('Group is private');
    MemComments.WatermarkText := L('Write here comment for this group');
    MemKeywords.WatermarkText := L('Write here keywords for this group');
    LoadFromFile1.Caption := L('Load from file');
    CbAddkeywords.Caption := L('Auto add keywords to photo');
    CommentLabel.Caption := L('Comment for group') + ':';
    KeyWordsLabel.Caption := L('Keywords for group') + ':';
    CbInclude.Caption := L('Include in quick group list');
    Label3.Caption := L('Related groups') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TFormChangeGroup.LoadFromFile1Click(Sender: TObject);
begin
  LoadNickJpegImage(ImgMain);
end;

function TFormChangeGroup.GetFormID: string;
begin
  Result := 'ChangeGroup';
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
  Found: Integer;
  SearchRec: TSearchRec;
  Directory: string;
  TS: Tstrings;
begin
  Ts := TStringList.Create;
  Ts.Clear;
  Directory := ProgramDir;
  FormatDir(Directory);
  Directory := Directory + PlugInImagesFolder;
  Found := FindFirst(Directory + '*.jpgc', FaAnyFile, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      if Fileexists(Directory + SearchRec.name) then
        try
          if ValidJPEGContainer(Directory + SearchRec.name) then
            TS.Add(Directory + SearchRec.name);
        except
        end;
    end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  GraphicSelect1.Galeries := Ts;
  GraphicSelect1.Showgaleries := True;
end;

procedure TFormChangeGroup.ImgMainClick(Sender: TObject);
var
  P: Tpoint;
begin
  if Saving then
    Exit;
  GetCursorPos(P);
  GraphicSelect1.RequestPicture(P.X, P.Y);
end;

procedure TFormChangeGroup.ComboBoxEx1DblClick(Sender: TObject);
var
  KeyWords: string;
begin
  DBChangeGroups(FNewRelatedGroups, KeyWords);
end;

procedure TFormChangeGroup.ComboBoxEx1DropDown(Sender: TObject);
var
  I: Integer;
  Group: TGroup;
  SmallB, B: TBitmap;
  GroupImageValud: Boolean;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  SmallB.PixelFormat := Pf24bit;
  SmallB.Width := 16;
  SmallB.Height := 16;
  SmallB.Canvas.Pen.Color := ClWindow;
  SmallB.Canvas.Brush.Color := ClWindow;
  SmallB.Canvas.Rectangle(0, 0, 16, 16);
  DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
  GroupsImageList.Add(SmallB, nil);
  SmallB.Free;
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    SmallB := TBitmap.Create;
    SmallB.PixelFormat := Pf24bit;
    SmallB.Canvas.Brush.Color := ClBtnFace;
    Group := GetGroupByGroupName(FCurrentGroups[I].GroupName, True);
    GroupImageValud := False;
    if Group.GroupImage <> nil then
      if not Group.GroupImage.Empty then
      begin
        B := TBitmap.Create;
        B.PixelFormat := Pf24bit;
        GroupImageValud := True;
        B.Assign(Group.GroupImage);
        FreeGroup(Group);
        DoResize(15, 15, B, SmallB);
        SmallB.Height := 16;
        SmallB.Width := 16;
        B.Free;
      end;
    GroupsImageList.Add(SmallB, nil);
    SmallB.Free;
    with ComboBoxEx1.ItemsEx[I] do
    begin
      if GroupImageValud then
        ImageIndex := I + 1
      else
        ImageIndex := 0;
    end;
  end;
  if ComboBoxEx1.ItemsEx.Count <> 0 then
    with ComboBoxEx1.ItemsEx[ComboBoxEx1.ItemsEx.Count - 1] do
      ImageIndex := 0;
end;

procedure TFormChangeGroup.ComboBoxEx1KeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TFormChangeGroup.ComboBoxEx1Select(Sender: TObject);
var
  KeyWords : string;
begin
  Application.ProcessMessages;
  if ComboBoxEx1.ItemsEx.Count = 0 then
    Exit;
  if (ComboBoxEx1.Text = ComboBoxEx1.Items[ComboBoxEx1.Items.Count - 1]) then
  begin
    DBChangeGroups(FNewRelatedGroups, KeyWords, False);
    Application.ProcessMessages;
    ReloadGroups;
  end else
  begin
    ShowGroupInfo(ComboBoxEx1.Text, False, nil);
    ComboBoxEx1.Text := L('<Groups>');
  end;
  ComboBoxEx1.ItemIndex := -1;
end;

procedure TFormChangeGroup.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
begin
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  ComboBoxEx1.Items.Clear;
  for I := 0 to Length(FCurrentGroups) - 1 do
    ComboBoxEx1.Items.Add(FCurrentGroups[I].GroupName);

  ComboBoxEx1.Items.Add(L('<Groups>'));
  ComboBoxEx1.Text := L('<Groups>');
end;

procedure TFormChangeGroup.PmLoadFromFilePopup(Sender: TObject);
begin
  LoadFromFile1.Visible := not Saving;
end;

end.
