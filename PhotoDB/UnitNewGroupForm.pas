unit UnitNewGroupForm;

interface

uses
  UnitGroupsWork,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Jpeg,
  Dolphin_DB,
  Menus,
  GraphicEx,
  Math, ComCtrls,
  ImgList,
  GraphicSelectEx,
  UnitDBDeclare,
  uBitmapUtils,
  uConstants,
  uExplorerGroupsProvider,
  uFileUtils,
  uMemory,
  uDBForm,
  WatermarkedEdit,
  WatermarkedMemo,
  uMemoryEx,
  uShellIntegration,
  uRuntime,
  WebLinkList,
  WebLink,
  AppEvnts,
  uPathProviders;

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
    Label3: TLabel;
    GroupsImageList: TImageList;
    CbInclude: TCheckBox;
    GraphicSelect1: TGraphicSelectEx;
    CbPrivateGroup: TCheckBox;
    WllGroups: TWebLinkList;
    ApplicationEvents1: TApplicationEvents;
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
    procedure ReloadGroups;
    procedure FillImageList;
    procedure WllGroupsDblClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
    FExecuteA: Boolean;
    FExecuteW: Boolean;
    FNewGroupName, FGroupCode: string;
    FCreated: Boolean;
    FNewRelatedGroups: string;
    FReloadGroupsMessage: Cardinal;
    procedure GroupClick(Sender: TObject);
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

uses
  UnitDBKernel, UnitEditGroupsForm, UnitQuickGroupInfo;

{$R *.dfm}

procedure CreateNewGroupDialog;
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

procedure CreateNewGroupDialogA(GroupName, GroupCode: string);
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

procedure CreateNewGroupDialogB(GroupCode: string; Image: TJpegImage; out Created: Boolean; out GroupName: string);
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

procedure TNewGroupForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if msg.message = FReloadGroupsMessage then
    ReloadGroups;

  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);
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
  GroupItem: TGroupItem;
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
  GroupItem := TGroupItem.Create;
  try
    GroupItem.ReadFromGroup(Group, PATH_LOAD_NORMAL, 48);
    EventInfo.Data := GroupItem;
    DBKernel.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged, EventID_GroupAdded], EventInfo);
  finally
    F(GroupItem);
  end;
  FreeGroup(Group);
  Close;
end;

procedure TNewGroupForm.FormCreate(Sender: TObject);
begin
  FReloadGroupsMessage := RegisterWindowMessage('CREATE_GROUP_RELOAD_GROUPS');
  LoadLanguage;
  RelodDllNames;
end;

procedure TNewGroupForm.ExecuteA(GroupName, GroupCode: string);
begin
  EdName.Text := GroupName;
  EdName.ReadOnly := True;
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
  ReloadGroups;
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

procedure TNewGroupForm.WllGroupsDblClick(Sender: TObject);
var
  KeyWords : string;
begin
  DBChangeGroups(FNewRelatedGroups, KeyWords);
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

procedure TNewGroupForm.FillImageList;
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
      SmallB.Canvas.Brush.Color := clBtnFace;
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

procedure TNewGroupForm.GroupClick(Sender: TObject);
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

procedure TNewGroupForm.ReloadGroups;
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

end.
