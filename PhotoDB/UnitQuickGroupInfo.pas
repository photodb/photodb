unit UnitQuickGroupInfo;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Imaging.jpeg,

  Dmitry.Controls.WebLinkList,
  Dmitry.Controls.WebLink,

  uMemory,
  uConstants,
  uBitmapUtils,
  uDBForm,
  uDBContext,
  uDBEntities,
  uDBManager,
  uShellIntegration,
  uThemesUtils,
  uVCLHelpers,
  uFormInterfaces;

type
  TFormQuickGroupInfo = class(TDBForm, IGroupInfoForm)
    GroupImage: TImage;
    GroupNameEdit: TEdit;
    CommentMemo: TMemo;
    BtnOk: TButton;
    DateEdit: TEdit;
    AccessEdit: TEdit;
    PmGroupOptions: TPopupActionBar;
    EditGroup1: TMenuItem;
    CommentLabel: TLabel;
    DateLabel: TLabel;
    AccessLabel: TLabel;
    SearchForGroup1: TMenuItem;
    KeyWordsMemo: TMemo;
    CbAddKeywords: TCheckBox;
    KeyWordsLabel: TLabel;
    Label3: TLabel;
    CbInclude: TCheckBox;
    GroupsImageList: TImageList;
    WllGroups: TWebLinkList;
    AeMain: TApplicationEvents;
    BtnEdit: TButton;
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditGroup1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GroupImageClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    FGroupsRepository: IGroupsRepository;
    FGroup: TGroup;
    FCloseOwner: Boolean;
    FOwner: TForm;
    FNewRelatedGroups: string;
    procedure GroupClick(Sender: TObject);
    procedure FillImageList;
    procedure LoadLanguage;
    procedure ReloadGroups;
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure Execute(AOwner: TForm; Group: TGroup; CloseOwner: Boolean); overload;
    procedure Execute(AOwner: TForm; GroupName: string; CloseOwner: Boolean); overload;
  end;

implementation

{$R *.dfm}

uses
  UnitFormChangeGroup,
  uManagerExplorer;

procedure TFormQuickGroupInfo.Execute(AOwner: TForm; GroupName: string;
  CloseOwner: Boolean);
var
  Group: TGroup;
begin
  Group := FGroupsRepository.GetByName(GroupName, False);
  try
    Execute(AOwner, Group, CloseOwner);
  finally
    F(Group);
  end;
end;

procedure TFormQuickGroupInfo.Execute(AOwner: TForm; Group: TGroup; CloseOwner: Boolean);
const
  Otstup = 3;
  Otstupa = 2;
var
  FineDate: array [0 .. 255] of Char;
  TempSysTime: TSystemTime;
begin
  FCloseOwner := CloseOwner;
  FOwner := AOwner;

  FGroup := FGroupsRepository.GetByCode(Group.GroupCode, True);
  try
    if FGroup = nil then
    begin
      MessageBoxDB(Handle, L('Group not found!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
      Close;
      Exit;
    end;

    GroupNameEdit.Text := FGroup.GroupName;
    FNewRelatedGroups := FGroup.RelatedGroups;
    CbInclude.Checked := FGroup.IncludeInQuickList;
    if FGroup.GroupImage <> nil then
      GroupImage.Picture.Graphic := FGroup.GroupImage;

    CommentLabel.Top := Max(GroupImage.Top + GroupImage.Height, GroupNameEdit.Top + GroupNameEdit.Height) + 3;
    CommentMemo.Top := CommentLabel.Top + CommentLabel.Height + 3;
    CommentMemo.Text := FGroup.GroupComment;
    CommentMemo.Height := (CommentMemo.Lines.Count + 1) * (Abs(CommentMemo.Font.Height) + 2) + Otstup;
    KeyWordsLabel.Top := CommentMemo.Top + CommentMemo.Height + Otstup;
    KeyWordsMemo.Top := KeyWordsLabel.Top + KeyWordsLabel.Height + Otstup;
    KeyWordsMemo.Text := FGroup.GroupKeyWords;
    CbAddKeywords.Top := KeyWordsMemo.Top + KeyWordsMemo.Height + Otstup;
    CbAddKeywords.Checked := FGroup.AutoAddKeyWords;

    Label3.Top := CbAddKeywords.Top + CbAddKeywords.Height + Otstup;
    WllGroups.Top := Label3.Top + Label3.Height + Otstup;
    CbInclude.Top := WllGroups.Top + WllGroups.Height + Otstup;

    DateLabel.Top := CbInclude.Top + CbInclude.Height + Otstup;
    DateEdit.Top := DateLabel.Top + DateLabel.Height + Otstupa;
    AccessLabel.Top := DateEdit.Top + DateEdit.Height + Otstupa;
    AccessEdit.Top := AccessLabel.Top + AccessLabel.Height + Otstup;
    BtnOk.Top := AccessEdit.Top + AccessEdit.Height + Otstup;
    BtnEdit.Top := AccessEdit.Top + AccessEdit.Height + Otstup;
    ClientHeight := BtnOk.Top + BtnOk.Height + Otstup;
    DateTimeToSystemTime(FGroup.GroupDate, TempSysTime);
    GetDateFormat(LOCALE_USER_DEFAULT, DATE_USE_ALT_CALENDAR, @TempSysTime, 'd MMMM yyyy ', @FineDate, 255);

    DateEdit.Text := Format(L('Created %s'), [FineDate]);
    if FGroup.GroupAccess = GROUP_ACCESS_COMMON then
      AccessEdit.Text := L('Public group');
    if FGroup.GroupAccess = GROUP_ACCESS_PRIVATE then
      AccessEdit.Text := L('Private group');

    ReloadGroups;
    FixFormPosition;
    ShowModal;

  finally
    F(FGroup);
  end;
end;

procedure TFormQuickGroupInfo.AeMainMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);
end;

procedure TFormQuickGroupInfo.BtnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFormQuickGroupInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormQuickGroupInfo.FormCreate(Sender: TObject);
begin
  FContext := DBManager.DBContext;
  FGroupsRepository := FContext.Groups;
  Loadlanguage;
  BtnEdit.AdjustButtonWidth;
end;

procedure TFormQuickGroupInfo.FormDestroy(Sender: TObject);
begin
  FGroupsRepository := nil;
  FContext := nil;
end;

procedure TFormQuickGroupInfo.EditGroup1Click(Sender: TObject);
begin
  Hide;
  Application.ProcessMessages;
  DBChangeGroup(FGroup);
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
  GroupInfoForm.Execute(nil, TWebLink(Sender).Text, False);
end;

procedure TFormQuickGroupInfo.GroupImageClick(Sender: TObject);
var
  P: TPoint;
begin
  P := GroupImage.ClientToScreen(GroupImage.ClientRect.CenterPoint);
  PmGroupOptions.Popup(P.X, P.Y);
end;

procedure TFormQuickGroupInfo.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormQuickGroupInfo.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption:= L('Group info');
    DateLabel.Caption := L('Date created');
    AccessLabel.Caption := L('Attributes');
    BtnOk.Caption := L('Ok');
    EditGroup1.Caption := L('Edit group');
    SearchForGroup1.Caption := L('Search for group photos');
    CbAddKeywords.Caption := L('Auto add keywords');
    KeyWordsLabel.Caption := L('Keywords for group') + ':';
    CommentLabel.Caption := L('Comment for group') + ':';
    CbInclude.Caption := L('Include in quick access list');
    Label3.Caption := L('Related groups') + ':';
    BtnEdit.Caption := L('Edit group');
  finally
    EndTranslate;
  end;
end;

procedure TFormQuickGroupInfo.SearchForGroup1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cGroupsPath + '\' + FGroup.GroupName);
    Show;
  end;

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
  FillImageList;

  FCurrentGroups := TGroups.CreateFromString(FNewRelatedGroups);
  try
    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      WL := WllGroups.AddLink;
      WL.Text := FCurrentGroups[I].GroupName;
      WL.ImageList := GroupsImageList;
      WL.ImageIndex := I;
      WL.Tag := I;
      WL.OnClick := GroupClick;
    end;
    if FCurrentGroups.Count = 0 then
    begin
      LblInfo := TStaticText.Create(WllGroups);
      LblInfo.Parent := WllGroups;
      WllGroups.AddControl(LblInfo);
      LblInfo.Caption := L('There are no related groups');
    end;
  finally
    F(FCurrentGroups);
  end;
  WllGroups.ReallignList;
end;

procedure TFormQuickGroupInfo.FillImageList;
var
  I: Integer;
  Group: TGroup;
  SmallB: TBitmap;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;

  FCurrentGroups := TGroups.CreateFromString(FNewRelatedGroups);
  try
    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      SmallB := TBitmap.Create;
      try
        SmallB.PixelFormat := pf24bit;
        SmallB.Canvas.Brush.Color := Theme.PanelColor;
        SmallB.SetSize(16, 16);

        Group := FGroupsRepository.GetByName(FCurrentGroups[I].GroupName, True);
        try
          if (Group <> nil) and (Group.GroupImage <> nil) and not Group.GroupImage.Empty then
          begin
            SmallB.Assign(Group.GroupImage);
            CenterBitmap24To32ImageList(SmallB, 16);
          end;
        finally
          F(Group);
        end;

        GroupsImageList.Add(SmallB, nil);
      finally
        F(SmallB);
      end;
    end;
  finally
    F(FCurrentGroups);
  end;
end;

procedure TFormQuickGroupInfo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(IGroupInfoForm, TFormQuickGroupInfo);

end.
