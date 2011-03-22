unit UnitQuickGroupInfo;

interface

uses
  UnitGroupsWork, Dolphin_DB, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, uVistaFuncs, ImgList, Menus, StdCtrls, Math,
  ComCtrls, jpeg, ExtCtrls, Dialogs, UnitDBCommonGraphics, uDBForm, uMemory,
  uShellIntegration, uConstants, uSearchTypes, WebLinkList, WebLink;

type
  TFormQuickGroupInfo = class(TDBForm)
    GroupImage: TImage;
    GroupNameEdit: TEdit;
    CommentMemo: TMemo;
    BtnOk: TButton;
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
    CbAddKeywords: TCheckBox;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    CbInclude: TCheckBox;
    GroupsImageList: TImageList;
    PopupMenu2: TPopupMenu;
    WllGroups: TWebLinkList;
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditGroup1Click(Sender: TObject);
    procedure Manager1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FGroup: TGroup;
    FCloseOwner: Boolean;
    FOwner: TForm;
    FNewRelatedGroups: string;
    procedure GroupClick(Sender: TObject);
    procedure FillImageList;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute(Group: TGroup; CloseOwner: Boolean; Owner_: TForm);
    procedure LoadLanguage;
    procedure ReloadGroups;
  end;

procedure ShowGroupInfo(Group: TGroup; CloseOwner: Boolean; Owner: TForm); overload;
procedure ShowGroupInfo(GrouName: string; CloseOwner: Boolean; Owner: TForm); overload;

implementation

{$R *.dfm}

uses UnitDBKernel, UnitFormChangeGroup, UnitManageGroups;

procedure ShowGroupInfo(GrouName: string; CloseOwner: Boolean; Owner: TForm);
var
  FormQuickGroupInfo: TFormQuickGroupInfo;
  Group: TGroup;
begin
  Group.GroupCode := FindGroupCodeByGroupName(GrouName);
  Application.CreateForm(TFormQuickGroupInfo, FormQuickGroupInfo);
  try
    FormQuickGroupInfo.Execute(Group, CloseOwner, Owner);
  finally
    R(FormQuickGroupInfo);
  end;
end;

procedure ShowGroupInfo(Group: TGroup; CloseOwner: Boolean; Owner: TForm);
var
  FormQuickGroupInfo: TFormQuickGroupInfo;
begin
  Application.CreateForm(TFormQuickGroupInfo, FormQuickGroupInfo);
  try
    FormQuickGroupInfo.Execute(Group, CloseOwner, Owner);
  finally
    R(FormQuickGroupInfo);
  end;
end;

procedure TFormQuickGroupInfo.BtnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFormQuickGroupInfo.Execute(Group: TGroup; CloseOwner: Boolean; Owner_: TForm);
const
  Otstup = 3;
  Otstupa = 2;
var
  FPrGroup: TGroup;
  FineDate: array [0 .. 255] of Char;
  TempSysTime: TSystemTime;
begin
  FCloseOwner := CloseOwner;
  FOwner := Owner_;
  FGroup := GetGroupByGroupCode(Group.GroupCode, True);
  if FGroup.GroupName = '' then
  begin
    MessageBoxDB(Handle, L('Group not found!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  FPrGroup := CopyGroup(FGroup);
  GroupNameEdit.Text := FGroup.GroupName;
  FNewRelatedGroups := FGroup.RelatedGroups;
  CbInclude.Checked := FGroup.IncludeInQuickList;
  if FPrGroup.GroupImage <> nil then
    GroupImage.Picture.Graphic := FPrGroup.GroupImage;

  CommentLabel.Top := Max(GroupImage.Top + GroupImage.Height, GroupNameEdit.Top + GroupNameEdit.Height) + 3;
  CommentMemo.Top := CommentLabel.Top + CommentLabel.Height + 3;
  CommentMemo.Text := FPrGroup.GroupComment;
  CommentMemo.Height := (CommentMemo.Lines.Count + 1) * (Abs(CommentMemo.Font.Height) + 2) + Otstup;
  KeyWordsLabel.Top := CommentMemo.Top + CommentMemo.Height + Otstup;
  KeyWordsMemo.Top := KeyWordsLabel.Top + KeyWordsLabel.Height + Otstup;
  KeyWordsMemo.Text := FPrGroup.GroupKeyWords;
  CbAddKeywords.Top := KeyWordsMemo.Top + KeyWordsMemo.Height + Otstup;
  CbAddKeywords.Checked := FPrGroup.AutoAddKeyWords;

  Label3.Top := CbAddKeywords.Top + CbAddKeywords.Height + Otstup;
  WllGroups.Top := Label3.Top + Label3.Height + Otstup;
  CbInclude.Top := WllGroups.Top + WllGroups.Height + Otstup;

  DateLabel.Top := CbInclude.Top + CbInclude.Height + Otstup;
  DateEdit.Top := DateLabel.Top + DateLabel.Height + Otstupa;
  AccessLabel.Top := DateEdit.Top + DateEdit.Height + Otstupa;
  AccessEdit.Top := AccessLabel.Top + AccessLabel.Height + Otstup;
  BtnOk.Top := AccessEdit.Top + AccessEdit.Height + Otstup;
  ClientHeight := BtnOk.Top + BtnOk.Height + Otstup;
  DateTimeToSystemTime(FPrGroup.GroupDate, TempSysTime);
  GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'd MMMM yyyy ', @FineDate, 255);

  DateEdit.Text := Format(L('Created %s'), [FineDate]);
  if FPrGroup.GroupAccess = GROUP_ACCESS_COMMON then
    AccessEdit.Text := L('Public group');
  if FPrGroup.GroupAccess = GROUP_ACCESS_PRIVATE then
    AccessEdit.Text := L('Private group');

  ReloadGroups;
  ShowModal;
  FreeGroup(FGroup);
  FreeGroup(FPrGroup);
end;

procedure TFormQuickGroupInfo.FormCreate(Sender: TObject);
begin
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
  if FormManageGroups <> nil then
  begin
    Close;
    Exit;
  end;
  Application.ProcessMessages;
  ExecuteGroupManager;
  Close;
end;

procedure TFormQuickGroupInfo.FormShow(Sender: TObject);
begin
  BtnOk.SetFocus;
end;

function TFormQuickGroupInfo.GetFormID: string;
begin
  Result := 'GroupInfo';
end;

procedure TFormQuickGroupInfo.GroupClick(Sender: TObject);
begin
  ShowGroupInfo(TWebLink(Sender).Text, False, nil);
end;

procedure TFormQuickGroupInfo.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption:= L('Group info');
    Label1.Caption := L('Group');
    DateLabel.Caption := L('Date created');
    AccessLabel.Caption := L('Attributes');
    BtnOk.Caption := L('Ok');
    EditGroup1.Caption := L('Edit group');
    Manager1.Caption := L('Groups manager');
    SearchForGroup1.Caption := L('Search for group photos');
    CbAddKeywords.Caption := L('Auto add keywords');
    KeyWordsLabel.Caption := L('Keywords for group') + ':';
    CommentLabel.Caption := L('Comment for group') + ':';
    CbInclude.Caption := L('Include in quick access list');
    Label3.Caption := L('Related groups') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TFormQuickGroupInfo.SearchForGroup1Click(Sender: TObject);
begin
  SearchManager.NewSearch.StartSearch(':Group(' + FGroup.GroupName + '):');
  BtnOk.OnClick(Sender);
  Close;
  if FCloseOwner then
    FOwner.Close;
end;

procedure TFormQuickGroupInfo.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
begin
  FCurrentGroups := EncodeGroups(FNewRelatedGroups);
  FillImageList;
  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    WL := WllGroups.AddLink;
    WL.Text := FCurrentGroups[I].GroupName;
    WL.ImageList := GroupsImageList;
    WL.ImageIndex := I;
    WL.ImageCanRegenerate := True;
    WL.Tag := I;
    WL.OnClick := GroupClick;
  end;
  if Length(FCurrentGroups) = 0 then
  begin
    LblInfo := TStaticText.Create(WllGroups);
    LblInfo.Parent := WllGroups;
    WllGroups.AddControl(LblInfo);
    LblInfo.Caption := L('There are no related groups');
  end;
  WllGroups.ReallignList;
end;

procedure TFormQuickGroupInfo.FillImageList;
var
  I: Integer;
  Group: TGroup;
  SmallB, B: TBitmap;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;

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

procedure TFormQuickGroupInfo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

end.
