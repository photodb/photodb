unit UnitFormChangeGroup;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Math, UnitGroupsTools,
  Dialogs, Menus, ExtDlgs, StdCtrls, jpeg, ExtCtrls, UnitDBDeclare,
  ImgList, GraphicSelectEx, uBitmapUtils, UnitDBCommon,
  uConstants, uFileUtils, uDBForm, WatermarkedEdit, WatermarkedMemo, uMemoryEx,
  uShellIntegration, AppEvnts, uMemory, WebLinkList, WebLink;

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
    CbInclude: TCheckBox;
    GroupsImageList: TImageList;
    GraphicSelect1: TGraphicSelectEx;
    EdName: TWatermarkedEdit;
    CbPrivateGroup: TCheckBox;
    ApplicationEvents1: TApplicationEvents;
    WllGroups: TWebLinkList;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure RelodDllNames;
    procedure ImgMainClick(Sender: TObject);
    procedure PmLoadFromFilePopup(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure WllGroupsDblClick(Sender: TObject);
  private
    { Private declarations }
    FGroup: TGroup;
    Saving: Boolean;
    FNewRelatedGroups: string;
    FGroupDate: TDateTime;
    FReloadGroupsMessage: Cardinal;
    procedure FillImageList;
    procedure GroupClick(Sender: TObject);
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

uses
  UnitDBKernel, UnitQuickGroupInfo, UnitEditGroupsForm;

{$R *.dfm}

procedure DBChangeGroup(Group: TGroup);
var
  FormChangeGroup: TFormChangeGroup;
begin
  Application.CreateForm(TFormChangeGroup, FormChangeGroup);
  try
    FormChangeGroup.Execute(Group.GroupCode);
  finally
    R(FormChangeGroup);
  end;
end;

procedure TFormChangeGroup.FormCreate(Sender: TObject);
begin
  Saving := False;
  LoadLanguage;
  RelodDllNames;
  FReloadGroupsMessage := RegisterWindowMessage('EDIT_GROUP_RELOAD_GROUPS');
end;

Procedure TFormChangeGroup.Execute(GroupCode : String);
var
  Group : TGroup;
begin
  Group := GetGroupByGroupCode(GroupCode, True);
  try
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
  finally
    FreeGroup(Group);
  end;
  ReloadGroups;
  ShowModal;
end;

procedure TFormChangeGroup.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if msg.message = FReloadGroupsMessage then
    ReloadGroups;

  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);
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
    MessageBoxDB(Handle, L('Group with this name already exists!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if FGroup.GroupName <> EdName.Text then
  begin
    if ID_OK <> MessageBoxDB(Handle, L('Do you really want to change name of this group?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      Exit;
  end;
  Saving := True;
  EdName.Enabled := False;
  MemComments.Enabled := False;
  MemKeywords.Enabled := False;
  CbAddkeywords.Enabled := False;
  WllGroups.Enabled := False;
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
    F(B);
  end;
end;

procedure TFormChangeGroup.GroupClick(Sender: TObject);
var
  KeyWords : string;
  WL: TWebLink;
begin
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    ShowGroupInfo(WL.Text, False, nil);
  end else
  begin
    DBChangeGroups(FNewRelatedGroups, KeyWords, False);
    PostMessage(Handle, FReloadGroupsMessage, 0, 0);
  end;
end;

procedure TFormChangeGroup.RelodDllNames;
var
  Found: Integer;
  SearchRec: TSearchRec;
  Directory: string;
  TS: TStrings;
begin
  TS := TStringList.Create;
  try
    Directory := IncludeTrailingBackslash(ProgramDir) + PlugInImagesFolder;
    Found := FindFirst(Directory + '*.jpgc', FaAnyFile, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          if FileExistsSafe(Directory + SearchRec.Name) then
            if ValidJPEGContainer(Directory + SearchRec.Name) then
              TS.Add(Directory + SearchRec.Name);
        end;
        Found := SysUtils.FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
    GraphicSelect1.Galeries := TS;
    GraphicSelect1.Showgaleries := True;
  finally
    F(TS);
  end;
end;

procedure TFormChangeGroup.WllGroupsDblClick(Sender: TObject);
var
  KeyWords: string;
begin
  DBChangeGroups(FNewRelatedGroups, KeyWords);
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

procedure TFormChangeGroup.FillImageList;
var
  I: Integer;
  Group: TGroup;
  SmallB, B: TBitmap;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    SmallB.Width := 16;
    SmallB.Height := 16;
    SmallB.Canvas.Pen.Color := clBtnFace;
    SmallB.Canvas.Brush.Color := clBtnFace;
    SmallB.Canvas.Rectangle(0, 0, 16, 16);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf24bit;
      SmallB.Canvas.Brush.Color := ClBtnFace;
      Group := GetGroupByGroupName(FCurrentGroups[I].GroupName, True);
      if Group.GroupImage <> nil then
        if not Group.GroupImage.Empty then
        begin
          B := TBitmap.Create;
          try
            B.PixelFormat := pf24bit;
            B.Assign(Group.GroupImage);
            FreeGroup(Group);
            DoResize(15, 15, B, SmallB);
            SmallB.Height := 16;
            SmallB.Width := 16;
          finally
            F(B);
          end;
        end;
      GroupsImageList.Add(SmallB, nil);
    finally
      F(SmallB);
    end;
  end;
end;

procedure TFormChangeGroup.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
begin
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  FillImageList;
  WllGroups.Clear;

  if Length(FCurrentGroups) = 0 then
  begin
    LblInfo := TStaticText.Create(WllGroups);
    LblInfo.Parent := WllGroups;
    WllGroups.AddControl(LblInfo, True);
    LblInfo.Caption := L('There are no related groups');
  end;

  WL := WllGroups.AddLink(True);
  WL.Text := L('Edit related groups');
  WL.ImageList := GroupsImageList;
  WL.ImageIndex := 0;
  WL.ImageCanRegenerate := True;
  WL.Tag := -1;
  WL.OnClick := GroupClick;

  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    WL := WllGroups.AddLink;
    WL.Text := FCurrentGroups[I].GroupName;
    WL.ImageList := GroupsImageList;
    WL.ImageIndex := I + 1;
    WL.ImageCanRegenerate := True;
    WL.Tag := I;
    WL.OnClick := GroupClick;
  end;
  WllGroups.ReallignList;
end;

procedure TFormChangeGroup.PmLoadFromFilePopup(Sender: TObject);
begin
  LoadFromFile1.Visible := not Saving;
end;

end.
