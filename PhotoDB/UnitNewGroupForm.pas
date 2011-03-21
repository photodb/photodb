unit UnitNewGroupForm;

interface

uses
  UnitGroupsWork, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, ExtDlgs, Jpeg, Dolphin_DB,
  Menus, GraphicEx, Gifimage, Math, ComCtrls, ImgList, GraphicSelectEx,
  uVistaFuncs, UnitDBDeclare, UnitDBCommonGraphics, UnitDBCommon, uConstants,
  uFileUtils, uMemory, uDBForm, WatermarkedEdit, WatermarkedMemo,
  uShellIntegration, uRuntime;

type
  TNewGroupForm = class(TDBForm)
    ImGroup: TImage;
    EdName: TWatermarkedEdit;
    MemComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    MemKeywords: TWatermarkedMemo;
    CbAddkeywords: TCheckBox;
    KeyWordsLabel: TLabel;
    CommentLabel: TLabel;
    CbeGroupList: TComboBoxEx;
    Label3: TLabel;
    GroupsImageList: TImageList;
    CbInclude: TCheckBox;
    GraphicSelect1: TGraphicSelectEx;
    CbPrivateGroup: TCheckBox;
    procedure ImGroupClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure Execute;
    procedure ExecuteA(GroupName, GroupCode : String);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExecuteB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
    procedure RelodDllNames;
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure CbeGroupListDropDown(Sender: TObject);
    procedure CbeGroupListKeyPress(Sender: TObject; var Key: Char);
    procedure CbeGroupListDblClick(Sender: TObject);
    procedure CbeGroupListSelect(Sender: TObject);
    procedure ReloadGroups;
  private
    { Private declarations }
    FExecuteA: Boolean;
    FExecuteW: Boolean;
    FNewGroupName, FGroupCode: string;
    FCreated: Boolean;
    FNewRelatedGroups: string;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
  end;

procedure CreateNewGroupDialog;
procedure CreateNewGroupDialogA(GroupName, GroupCode: string);
procedure CreateNewGroupDialogB(GroupCode: string; Image: TJpegImage; out Created: Boolean; out GroupName: string);

implementation

uses UnitDBKernel, UnitEditGroupsForm, UnitQuickGroupInfo;

{$R *.dfm}

Procedure CreateNewGroupDialog;
var
  NewGroupForm: TNewGroupForm;
begin
  if not IsValidGroupsTable then
    if DBInDebug then
      CreateGroupsTable;

  Application.CreateForm(TNewGroupForm, NewGroupForm);
  try
    NewGroupForm.Execute;
  finally
    R(NewGroupForm);
  end;
end;

Procedure CreateNewGroupDialogA(GroupName,GroupCode : String);
var
  NewGroupForm: TNewGroupForm;
begin
  Application.CreateForm(TNewGroupForm, NewGroupForm);
  try
    NewGroupForm.ExecuteA(GroupName,GroupCode);
  finally
    R(NewGroupForm);
  end;
end;

Procedure CreateNewGroupDialogB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
var
  NewGroupForm: TNewGroupForm;
begin
  Application.CreateForm(TNewGroupForm, NewGroupForm);
  try
    NewGroupForm.ExecuteB(GroupCode,Image,Created,GroupName);
  finally
    R(NewGroupForm);
  end;
end;

procedure TNewGroupForm.ImGroupClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  GraphicSelect1.RequestPicture(P.X, P.Y);
end;

procedure TNewGroupForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TNewGroupForm.Execute;
begin
  FExecuteA := False;
  FNewRelatedGroups := '';
  ReloadGroups;
  ShowModal;
end;

procedure TNewGroupForm.BtnOkClick(Sender: TObject);
var
  Group: TGroup;
  EventInfo: TEventValues;
begin
  if GroupNameExists(EdName.Text) then
  begin
    MessageBoxDB(Handle, L('Group with this name already exists!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  Group.GroupName := EdName.Text;
  Group.GroupImage := TJpegImage.Create;
  if not FExecuteA then
    Group.GroupCode := CreateNewGroupCode
  else
    Group.GroupCode := FGroupCode;
  Group.GroupImage.Assign(ImGroup.Picture.Graphic);
  Group.GroupComment := MemComments.Text;
  Group.GroupKeyWords := MemKeywords.Text;
  Group.AutoAddKeyWords := CbAddkeywords.Checked;
  if CbPrivateGroup.Checked then
    Group.GroupAccess := GROUP_ACCESS_PRIVATE
  else
    Group.GroupAccess := GROUP_ACCESS_COMMON;

  Group.RelatedGroups := FNewRelatedGroups;
  Group.IncludeInQuickList := CbInclude.Checked;
  Group.GroupDate := 0;
  AddGroup(Group);
  if GroupNameExists(EdName.Text) then
  begin
    FCreated := True;
    FNewGroupName := EdName.Text;
  end;
  FreeGroup(Group);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged], EventInfo);
  Close;
end;

procedure TNewGroupForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  RelodDllNames;
end;

procedure TNewGroupForm.ExecuteA(GroupName, GroupCode: string);
begin
  EdName.Text := GroupName;
  EdName.readonly := True;
  FExecuteA := True;
  FExecuteW := False;
  FGroupCode := GroupCode;
  FNewRelatedGroups := '';
  ReloadGroups;
  ShowModal;
end;

procedure TNewGroupForm.ExecuteB(GroupCode: String; Image : TJpegImage; out Created : Boolean; out GroupName : String);
begin
  EdName.ReadOnly := False;
  if Image <> nil then
    ImGroup.Picture.Graphic := Image;

  FExecuteA := False;
  FCreated := False;
  FExecuteW := True;
  FGroupCode := GroupCode;
  ShowModal;
  GroupName := FNewGroupName;
  Created := FCreated;
end;

procedure TNewGroupForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Create new group');
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

procedure TNewGroupForm.RelodDllNames;
var
  Found: Integer;
  SearchRec: TSearchRec;
  Directory: string;
  TS: Tstrings;
begin
  Ts := TStringList.Create;
  try
    Directory := IncludeTrailingBackslash(ProgramDir) + PlugInImagesFolder;
    Found := FindFirst(Directory + '*.jpgc', FaAnyFile, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          if FileExistsSafe(Directory + SearchRec.Name) then
            try
              if ValidJPEGContainer(Directory + SearchRec.Name) then
                TS.Add(Directory + SearchRec.Name);
            except
            end;
        end;
        Found := SysUtils.FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
    GraphicSelect1.Galeries := Ts;
    GraphicSelect1.Showgaleries := True;
  finally
    F(Ts);
  end;
end;

function TNewGroupForm.GetFormID: string;
begin
  Result := 'NewGroup';
end;

procedure TNewGroupForm.GraphicSelect1ImageSelect(Sender: TObject;
  Bitmap: TBitmap);
var
  B: TBitmap;
  H, W: Integer;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := Pf24bit;
    W := Bitmap.Width;
    H := Bitmap.Height;
    if Max(W, H) < 48 then
      B.Assign(Bitmap)
    else
    begin
      ProportionalSize(48, 48, W, H);
      StretchCool(W, H, Bitmap, B);
    end;
    ImGroup.Picture.Graphic := B;
  finally
    F(B);
  end;
end;

procedure TNewGroupForm.LoadFromFile1Click(Sender: TObject);
begin
  LoadNickJpegImage(ImGroup);
end;

procedure TNewGroupForm.CbeGroupListDropDown(Sender: TObject);
var
  I: Integer;
  Group: TGroup;
  SmallB, B: TBitmap;
  GroupImageValud: Boolean;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  SmallB.PixelFormat := pf24bit;
  SmallB.Width := 16;
  SmallB.Height := 16;
  SmallB.Canvas.Pen.Color := ClWindow;
  SmallB.Canvas.Brush.Color := clWindow;
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
    with CbeGroupList.ItemsEx[I] do
    begin
      if GroupImageValud then
        ImageIndex := I + 1
      else
        ImageIndex := 0;
    end;
  end;
  if CbeGroupList.ItemsEx.Count <> 0 then
    with CbeGroupList.ItemsEx[CbeGroupList.ItemsEx.Count - 1] do
      ImageIndex := 0;
end;

procedure TNewGroupForm.CbeGroupListKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := #0;
end;

procedure TNewGroupForm.CbeGroupListDblClick(Sender: TObject);
var
  KeyWords : string;
begin
  DBChangeGroups(FNewRelatedGroups, KeyWords);
end;

procedure TNewGroupForm.CbeGroupListSelect(Sender: TObject);
var
  KeyWords: string;
begin
  Application.ProcessMessages;
  if CbeGroupList.ItemsEx.Count = 0 then
    Exit;
  if (CbeGroupList.Text = CbeGroupList.Items[CbeGroupList.Items.Count - 1]) then
  begin
    DBChangeGroups(FNewRelatedGroups, KeyWords, False);
    Application.ProcessMessages;
    ReloadGroups;
  end else
  begin
    ShowGroupInfo(CbeGroupList.Text, False, nil);
  end;
  CbeGroupList.ItemIndex := -1;
  CbeGroupList.Text := L('<Groups>');
end;

procedure TNewGroupForm.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
begin
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  CbeGroupList.Items.Clear;
  for I := 0 to Length(FCurrentGroups) - 1 do
    CbeGroupList.Items.Add(FCurrentGroups[I].GroupName);

  CbeGroupList.Items.Add(L('<Manage>'));
  CbeGroupList.Text := L('<Groups>');
end;

end.
