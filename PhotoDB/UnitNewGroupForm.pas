unit UnitNewGroupForm;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.ImgList,
  Jpeg,

  Dmitry.Utils.Files,
  Dmitry.PathProviders,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WebLinkList,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WatermarkedMemo,

  GraphicSelectEx,
  UnitDBDeclare,

  uEditorTypes,
  uRuntime,
  uInterfaces,
  uMemory,
  uMemoryEx,
  uConstants,
  uBitmapUtils,
  uDBIcons,
  uExplorerGroupsProvider,
  uIDBForm,
  uDBForm,
  uDBContext,
  uDBEntities,
  uDBManager,
  uVCLHelpers,
  uShellIntegration,
  uDialogUtils,
  uThemesUtils,
  uProgramStatInfo,
  uFormInterfaces,
  uCollectionEvents;

type
  TNewGroupForm = class(TDBForm, IGroupCreateForm)
    ImGroup: TImage;
    EdName: TWatermarkedEdit;
    MemComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    PmAvatar: TPopupActionBar;
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
    MiUseCurrentImage: TMenuItem;
    MiLoadFromMiniGallery: TMenuItem;
    procedure ImGroupClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure RelodDllNames;
    procedure GraphicSelect1ImageSelect(Sender: TObject; Bitmap: TBitmap);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure ReloadGroups;
    procedure FillImageList;
    procedure WllGroupsDblClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MiUseCurrentImageClick(Sender: TObject);
    procedure MiLoadFromMiniGalleryClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    FGroupsRepository: IGroupsRepository;
    FSettings: TSettings;
    FCreateFixedGroup: Boolean;
    FCreateGroupWithCode: Boolean;
    FNewGroupName, FGroupCode: string;
    FCreated: Boolean;
    FNewRelatedGroups: string;
    FReloadGroupsMessage: Cardinal;
    procedure LoadLanguage;
    procedure GroupClick(Sender: TObject);
  protected
    function GetFormID: string; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure CreateGroup;
    procedure CreateFixedGroup(GroupName, GroupCode: string);
    procedure CreateGroupByCodeAndImage(GroupCode: string; Image: TJpegImage; out Created: Boolean; out GroupName: string);
  end;

implementation

uses
  ImEditor;

{$R *.dfm}

procedure TNewGroupForm.CreateGroup;
begin
  FCreateFixedGroup := False;
  FNewRelatedGroups := '';
  ReloadGroups;
  ShowModal;
end;


procedure TNewGroupForm.CreateFixedGroup(GroupName, GroupCode: string);
begin
  EdName.Text := GroupName;
  EdName.ReadOnly := True;
  FCreateFixedGroup := True;
  FCreateGroupWithCode := False;
  FGroupCode := GroupCode;
  FNewRelatedGroups := '';
  ReloadGroups;
  ShowModal;
end;

procedure TNewGroupForm.CreateGroupByCodeAndImage(GroupCode: string;
  Image: TJpegImage; out Created: Boolean; out GroupName: string);
begin
  EdName.ReadOnly := False;
  if Image <> nil then
    ImGroup.Picture.Graphic := Image;

  FCreateFixedGroup := False;
  FCreated := False;
  FCreateGroupWithCode := True;
  FGroupCode := GroupCode;
  ReloadGroups;
  ShowModal;
  GroupName := FNewGroupName;
  Created := FCreated;
end;

procedure TNewGroupForm.ImGroupClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  GraphicSelect1.RequestPicture(P.X, P.Y);
end;

procedure TNewGroupForm.InterfaceDestroyed;
begin
  inherited;
  Release;
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

procedure TNewGroupForm.BtnOkClick(Sender: TObject);
var
  Group: TGroup;
  EventInfo: TEventValues;
  GroupItem: TGroupItem;
begin
  if FGroupsRepository.HasGroupWithName(EdName.Text) then
  begin
    MessageBoxDB(Handle, L('Group with this name already exists!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  //statistics
  ProgramStatistics.GroupUsed;

  Group := TGroup.Create;
  try
    Group.GroupName := EdName.Text;
    Group.GroupImage := TJpegImage.Create;
    if not FCreateFixedGroup then
      Group.GroupCode := TGroup.CreateNewGroupCode
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

    if FGroupsRepository.Add(Group) then
    begin
      FCreated := True;
      FNewGroupName := EdName.Text;

      GroupItem := TGroupItem.Create;
      try
        GroupItem.ReadFromGroup(Group, PATH_LOAD_NORMAL, 48);
        EventInfo.Data := GroupItem;
        CollectionEvents.DoIDEvent(Self, 0, [EventID_Param_GroupsChanged, EventID_GroupAdded], EventInfo);
      finally
        F(GroupItem);
      end;
    end;
  finally
    F(Group);
  end;
  Close;
end;

procedure TNewGroupForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TNewGroupForm.FormCreate(Sender: TObject);
var
  SettingsRepository: ISettingsRepository;
begin
  FContext := DBManager.DBContext;
  FGroupsRepository := FContext.Groups;
  SettingsRepository := FContext.Settings;

  FSettings := SettingsRepository.Get;

  FReloadGroupsMessage := RegisterWindowMessage('CREATE_GROUP_RELOAD_GROUPS');
  LoadLanguage;
  RelodDllNames;
end;

procedure TNewGroupForm.FormDestroy(Sender: TObject);
begin
  FContext := nil;
  F(FSettings);
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

procedure TNewGroupForm.MiLoadFromMiniGalleryClick(Sender: TObject);
var
  P: TPoint;
begin
  P := ImGroup.ClientToScreen(ImGroup.ClientRect.CenterPoint);
  GraphicSelect1.RequestPicture(P.X, P.Y);
end;

procedure TNewGroupForm.MiUseCurrentImageClick(Sender: TObject);
var
  FileName: string;
  Editor: TImageEditorForm;
  Bitmap: TBitmap;
  FJPG: TJpegImage;
begin
  FileName := Screen.CurrentImageFileName;

  if FileName <> '' then
  begin
    Editor := TImageEditor.Create(nil);
    try
      Bitmap := TBitmap.Create;
      try
        if Editor.EditFile(FileName, Bitmap) then
        begin
          KeepProportions(Bitmap, 48, 48);
          FJPG := TJpegImage.Create;
          try
            FJPG.CompressionQuality := FSettings.DBJpegCompressionQuality;
            FJPG.Assign(Bitmap);
            FJPG.JPEGNeeded;
            ImGroup.Picture.Graphic := FJPG;
          finally
            F(FJPG);
          end;

        end;
      finally
        F(Bitmap);
      end;
    finally
      R(Editor);
    end;
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
        Found := System.SysUtils.FindNext(SearchRec);
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
  KeyWords: string;
begin
  GroupsSelectForm.Execute(FNewRelatedGroups, KeyWords);
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
  LoadNickJpegImage(ImGroup.Picture, FSettings.DBJpegCompressionQuality);
end;

procedure TNewGroupForm.FillImageList;
var
  I: Integer;
  Group: TGroup;
  SmallB: TBitmap;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    SmallB.Width := 16;
    SmallB.Height := 16;
    SmallB.Canvas.Pen.Color := Theme.PanelColor;
    SmallB.Canvas.Brush.Color := Theme.PanelColor;
    SmallB.Canvas.Rectangle(0, 0, 16, 16);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, Icons[DB_IC_GROUPS], 16, 16, 0, 0, DI_NORMAL);
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;
  FCurrentGroups := TGroups.CreateFromString(FNewRelatedGroups);
  try
    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      SmallB := TBitmap.Create;
      try
        SmallB.PixelFormat := pf24bit;
        SmallB.Canvas.Brush.Color := Theme.PanelColor;

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

procedure TNewGroupForm.GroupClick(Sender: TObject);
var
  KeyWords: string;
  WL: TWebLink;
begin
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    GroupInfoForm.Execute(nil, WL.Text, False);
  end else
  begin
    GroupsSelectForm.Execute(FNewRelatedGroups, KeyWords, False);
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
  FillImageList;
  WllGroups.Clear;

  FCurrentGroups := TGroups.CreateFromString(FNewRelatedGroups);
  try
    if FCurrentGroups.Count = 0 then
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
    WL.Tag := -1;
    WL.OnClick := GroupClick;

    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      WL := WllGroups.AddLink;
      WL.Text := FCurrentGroups[I].GroupName;
      WL.ImageList := GroupsImageList;
      WL.ImageIndex := I + 1;
      WL.Tag := I;
      WL.OnClick := GroupClick;
    end;
  finally
    F(FCurrentGroups);
  end;
  WllGroups.ReallignList;
end;

initialization
  FormInterfaces.RegisterFormInterface(IGroupCreateForm, TNewGroupForm);

end.
