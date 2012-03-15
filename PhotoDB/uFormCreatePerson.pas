unit uFormCreatePerson;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  WatermarkedEdit,
  ExtCtrls,
  WatermarkedMemo,
  ComCtrls,
  WebLinkList,
  uFaceDetection,
  uPeopleSupport,
  uMemory,
  uMemoryEx,
  jpeg,
  uBitmapUtils,
  uThreadEx,
  uDBThread,
  uThreadForm,
  LoadingSign,
  u2DUtils,
  UnitDBDeclare,
  UnitDBKernel,
  AppEvnts,
  WebLink,
  UnitGroupsWork,
  ImgList,
  uConstants,
  uEditorTypes,
  Dolphin_db,
  uLogger,
  RAWImage,
  uJpegUtils,
  uFastLoad,
  uVCLHelpers,
  ActiveX,
  uDBClasses,
  uPathProviders,
  uDBForm,
  Types,
  uSettings,
  Menus,
  uExplorerPersonsProvider,
  uSysUtils,
  uThemesUtils,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  CommonDBSupport;

type
  TFormCreatePerson = class(TThreadForm)
    PbPhoto: TPaintBox;
    LbName: TLabel;
    BvSeparator: TBevel;
    WedName: TWatermarkedEdit;
    LbComments: TLabel;
    WmComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    WllGroups: TWebLinkList;
    LbGroups: TLabel;
    LbBirthDate: TLabel;
    DtpBirthDay: TDateTimePicker;
    LsExtracting: TLoadingSign;
    PmImageOptions: TPopupActionBar;
    MiLoadOtherImage: TMenuItem;
    LsAdding: TLoadingSign;
    AeMain: TApplicationEvents;
    GroupsImageList: TImageList;
    MiEditImage: TMenuItem;
    LsNameCheck: TLoadingSign;
    WlPersonNameStatus: TWebLink;
    TmrCkeckName: TTimer;
    ImOK: TImage;
    ImInvalid: TImage;
    ImWarning: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PbPhotoPaint(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnOkClick(Sender: TObject);
    procedure WedNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WllGroupsDblClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure MiEditImageClick(Sender: TObject);
    procedure MiLoadOtherImageClick(Sender: TObject);
    procedure WedNameChange(Sender: TObject);
    procedure TmrCkeckNameTimer(Sender: TObject);
    procedure WedNameExit(Sender: TObject);
    procedure WlPersonNameStatusClick(Sender: TObject);
  private
    { Private declarations }
    FPicture: TBitmap;
    FDisplayImage: TBitmap;
    FOriginalFace: TFaceDetectionResultItem;
    FPerson: TPerson;
    FInfo: TDBPopupMenuInfoRecord;
    FRelatedGroups: string;
    FReloadGroupsMessage: Cardinal;
    FIsImageChanged: Boolean;
    FIsEditMode: Boolean;
    FFormPersonSuggest: TDBForm;
    procedure CreatePerson(Info: TDBPopupMenuInfoRecord; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap);
    function DoEditPerson(PersonID: Integer): Boolean;
    procedure RecreateImage;
    procedure UpdateFaceArea(Face: TFaceDetectionResultItem);
    procedure LoadLanguage;
    procedure ReloadGroups;
    procedure FillImageList;
    procedure MarkPersonOnPhoto;
    procedure GroupClick(Sender: TObject);
    procedure CloseSuggestForm;
  protected
    function GetFormID: string; override;
    procedure EnableControls(IsEnabled: Boolean);
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; params: TEventFields; Value: TEventValues);
    procedure AddPhoto;
    procedure OnMoving(var Msg: TWMMoving); message WM_MOVING;
    procedure WMActivateApp(var Msg: TMessage); message WM_ACTIVATEAPP;
  public
    { Public declarations }
    procedure UpdateNameStatus(PersonList: TPathItemCollection);
    procedure SelectOtherPerson(PersonID: Integer);
    property Person: TPerson read FPerson;
  end;

  TPersonExtractor = class(TDBThread)
  private
    FBitmap: TBitmap;
    FFaces: TFaceDetectionResult;
    FOwner: TFormCreatePerson;
    FFace: TFaceDetectionResultItem;
    procedure UpdatePicture;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
    destructor Destroy; override;
  end;

  TCheckNameThread = class(TThreadEx)
  private
    FName: string;
    FNewName: string;
    FPersons: TPathItemCollection;
    FEditPerson: Boolean;
  protected
    procedure Execute; override;
    procedure UpdateNameData;
  public
    constructor Create(AOwner: TFormCreatePerson; State: TGuid; Name, NewName: string; EditPerson: Boolean);
    destructor Destroy; override;
  end;

procedure CreatePerson(Info: TDBPopupMenuInfoRecord; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);
function EditPerson(PersonID: Integer): Boolean;

implementation

uses
  UnitUpdateDBObject,
  UnitEditGroupsForm,
  UnitQuickGroupInfo,
  ImEditor,
  uFormPersonSuggest;

{$R *.dfm}

procedure CreatePerson(Info: TDBPopupMenuInfoRecord; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);
var
  FormCreatePerson: TFormCreatePerson;
begin
  Application.CreateForm(TFormCreatePerson, FormCreatePerson);
  try
    FormCreatePerson.CreatePerson(Info, OriginalFace, FaceInImage, Bitmap);
    Person := FormCreatePerson.Person;
  finally
    R(FormCreatePerson);
  end;
end;

function EditPerson(PersonID: Integer): Boolean;
var
  FormCreatePerson: TFormCreatePerson;
begin
  Application.CreateForm(TFormCreatePerson, FormCreatePerson);
  try
    Result := FormCreatePerson.DoEditPerson(PersonID);
  finally
    R(FormCreatePerson);
  end;
end;

{ TFormCreatePerson }

procedure TFormCreatePerson.AeMainMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if msg.message = FReloadGroupsMessage then
    ReloadGroups;

  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);
end;

procedure TFormCreatePerson.BtnCancelClick(Sender: TObject);
begin
  ModalResult := MB_OKCANCEL;
  Close;
end;

procedure TFormCreatePerson.AddPhoto;
var
  PersonArea: TPersonArea;
begin
  if Person <> nil then
  begin
    PersonArea := TPersonArea.Create(FInfo.ID, Person.ID, FOriginalFace);
    try
      PersonManager.AddPersonForPhoto(Self, PersonArea);
      FOriginalFace.Data := PersonArea.Clone;
    finally
      F(PersonArea);
    end;
    Close;
  end;
end;

procedure TFormCreatePerson.BtnOkClick(Sender: TObject);
var
  EventValues: TEventValues;
  PersonID: Integer;

  procedure UpdateImage;
  var
    J: TJpegImage;
    B: TBitmap;
    W, H: Integer;
  begin
    J := TJPEGImage.Create;
    try
      B := TBitmap.Create;
      try
        W := FPicture.Width;
        H := FPicture.Height;
        ProportionalSize(250, 300, W, H);
        DoResize(W, H, FPicture, B);
        J.Assign(B);
        Person.Image := J;
      finally
        F(B);
      end;
    finally
      F(J);
    end;
  end;

  procedure UpdatePersonFields;
  begin
    FPerson.Name := WedName.Text;
    FPerson.Birthday := DtpBirthDay.Date;
    FPerson.Groups := FRelatedGroups;
    FPerson.Comment := WmComments.Text;
  end;

begin
  if not BtnOk.Enabled then
    Exit;

  EnableControls(False);

  if FIsEditMode then
  begin
    UpdatePersonFields;
    if FIsImageChanged then
      UpdateImage;
    PersonManager.UpdatePerson(FPerson, FIsImageChanged);

    EventValues.ID := FPerson.ID;
    EventValues.Name := FPerson.Name;
    EventValues.NewName := FPerson.Name;
    DBKernel.DoIDEvent(Self, FPerson.ID, [EventID_PersonChanged], EventValues);

    ModalResult := MB_OK;
    Close;
  end else
  begin
    F(FPerson);

    FPerson := TPerson.Create;
    UpdatePersonFields;
    UpdateImage;
    PersonID := PersonManager.CreateNewPerson(Person);
    F(FPerson);
    FPerson := TPerson.Create;
    PersonManager.FindPerson(PersonID, FPerson);

    if not FPerson.Empty then
    begin
      MarkPersonOnPhoto;

      EventValues.ID := FPerson.ID;
      EventValues.Name := FPerson.Name;
      EventValues.NewName := FPerson.Name;
      DBKernel.DoIDEvent(Self, FPerson.ID, [EventID_PersonAdded], EventValues);
    end;
  end;
end;

procedure TFormCreatePerson.MarkPersonOnPhoto;
var
  FileInfo: TDBPopupMenuInfoRecord;
begin
  if Person.ID > 0 then
  begin
    if FInfo.ID > 0 then
    begin
      AddPhoto;
    end else
    begin
      FileInfo := TDBPopupMenuInfoRecord.Create;
      try
        FileInfo.FileName := FInfo.FileName;
        FileInfo.Include := True;
        FileInfo.Groups := FRelatedGroups;
        UpdaterDB.AddFileEx(FileInfo, True, True);
        Exit;
      finally
        F(FileInfo);
      end;
    end;
  end;
end;

procedure TFormCreatePerson.SelectOtherPerson(PersonID: Integer);
begin
  if not FIsEditMode then
  begin
    EnableControls(False);
    FPerson := PersonManager.GetPerson(PersonID);
    MarkPersonOnPhoto;
  end else
  begin
    EditPerson(PersonID);
  end;
end;

procedure TFormCreatePerson.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
    begin
      FInfo.ID := Value.ID;
      AddPhoto;
    end;

  end;
  if EventID_CancelAddingImage in Params then
  begin
    if (AnsiLowerCase(Value.NewName) = AnsiLowerCase(FInfo.FileName)) and (Value.ID > 0) then
    begin
      FInfo.ID := Value.ID;
      AddPhoto;
      Exit;
    end;

    if AnsiLowerCase(Value.name) = AnsiLowerCase(FInfo.FileName) then
      EnableControls(True);

  end;
end;

procedure TFormCreatePerson.CloseSuggestForm;
begin
  if FFormPersonSuggest <> nil then
    FFormPersonSuggest.Close;
end;

procedure TFormCreatePerson.MiEditImageClick(Sender: TObject);
var
  Editor: TImageEditorForm;
begin
  Editor := TImageEditor.Create(nil);
  try
    if Editor.EditImage(FPicture) then
    begin
      FIsImageChanged := True;
      RecreateImage;
      Invalidate;
    end;
  finally
    R(Editor);
  end;
end;

function TFormCreatePerson.DoEditPerson(PersonID: Integer): Boolean;
begin
  Result := False;
  FPerson := TPerson.Create;
  try
    PersonManager.FindPerson(PersonID, FPerson);

    if FPerson.Empty then
      Exit;

    FRelatedGroups := Person.Groups;
    WedName.Text := Person.Name;
    DtpBirthDay.Date := Person.BirthDay;
    WmComments.Text := Person.Comment;
    FIsImageChanged := False;
    FIsEditMode := True;

    FPicture.Assign(Person.Image);
    RecreateImage;
    ReloadGroups;
    Caption := LF('Edit person: {0}', [FPerson.Name]);
    ShowModal;
  finally
    F(FPerson);
  end;
  Result := ModalResult = MB_OK;
end;

procedure TFormCreatePerson.EnableControls(IsEnabled: Boolean);
begin
  BtnOk.Enabled := IsEnabled;
  BtnCancel.Enabled := IsEnabled;
  WedName.Enabled := IsEnabled;
  DtpBirthDay.Enabled := IsEnabled;
  WmComments.Enabled := IsEnabled;
  LsAdding.Visible := not IsEnabled;
  WlPersonNameStatus.Enabled := IsEnabled;
end;

procedure TFormCreatePerson.CreatePerson(Info: TDBPopupMenuInfoRecord; OriginalFace, FaceInImage: TFaceDetectionResultItem;
  Bitmap: TBitmap);
begin
  FIsEditMode := False;
  FPicture.Assign(Bitmap);
  FOriginalFace := OriginalFace;
  FInfo := Info.Copy;
  TPersonExtractor.Create(Self, FaceInImage, FPicture);
  RecreateImage;
  ReloadGroups;
  LsExtracting.Show;
  Caption := L('Create new person');
  ShowModal;
end;

procedure TFormCreatePerson.FormCreate(Sender: TObject);
begin
  FInfo := nil;
  FPerson := nil;
  FFormPersonSuggest := nil;
  FIsImageChanged := False;
  FIsEditMode := False;
  FPicture := TBitmap.Create;
  FDisplayImage := TBitmap.Create;
  LoadLanguage;
  PersonManager.InitDB;
  TLoad.Instance.RequaredDBSettings;
  PmImageOptions.Images := DBKernel.ImageList;
  MiLoadotherimage.ImageIndex := DB_IC_LOADFROMFILE;
  MiEditImage.ImageIndex := DB_IC_IMEDITOR;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  FReloadGroupsMessage := RegisterWindowMessage('CREATE_PERSON_RELOAD_GROUPS');
  FixFormPosition;

  WlPersonNameStatus.Left := LsNameCheck.Left;
end;

procedure TFormCreatePerson.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  F(FPicture);
  F(FFormPersonSuggest);
  F(FDisplayImage);
  F(FInfo);
end;

procedure TFormCreatePerson.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

function TFormCreatePerson.GetFormID: string;
begin
  Result := 'EditPerson';
end;

procedure TFormCreatePerson.LoadLanguage;
begin
  BeginTranslate;
  try
    LbName.Caption := L('Name') + ':';
    WedName.WatermarkText := L('Name of person');
    LbBirthDate.Caption := L('Birthday') + ':';
    LbGroups.Caption := L('Related groups') + ':';
    LbComments.Caption := L('Comment') + ':';
    WmComments.WatermarkText := L('Comment');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    MiLoadOtherImage.Caption := L('Load other image');
    MiEditImage.Caption := L('Edit image');
  finally
    EndTranslate;
  end;
end;

procedure TFormCreatePerson.MiLoadOtherImageClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    if GetImageFromUser(Bitmap, 250, 300) then
    begin
      FPicture.Assign(Bitmap);
      RecreateImage;
      Invalidate;
      FIsImageChanged := True;
    end;
  finally
    F(Bitmap);
  end;
end;

procedure TFormCreatePerson.OnMoving(var Msg: TWMMoving);
var
  P: TPoint;
begin
  P := Point(WedName.Left, WedName.Top + WedName.Height);
  P := ClientToScreen(P);
  if FFormPersonSuggest <> nil then
    TFormPersonSuggest(FFormPersonSuggest).UpdatePos(P);
end;

procedure TFormCreatePerson.PbPhotoPaint(Sender: TObject);
begin
  if FDisplayImage <> nil then
    PbPhoto.Canvas.Draw(PbPhoto.Width div 2 - FDisplayImage.Width div 2,
      PbPhoto.Height div 2 - FDisplayImage.Height div 2, FDisplayImage);
end;

procedure TFormCreatePerson.RecreateImage;
var
  B, SmallB: TBitmap;
  W, H: Integer;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf32bit;
    DrawShadowToImage(B, FPicture);
    W := B.Width;
    H := B.Height;
    ProportionalSize(PbPhoto.Width, PbPhoto.Height, W, H);
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf32Bit;
      DoResize(W, H, B, SmallB);
      F(FDisplayImage);
      FDisplayImage := TBitmap.Create;
      LoadBMPImage32bit(SmallB, FDisplayImage, Theme.WindowColor);
    finally
      F(SmallB);
    end;
  finally
    F(B);
  end;
end;

procedure TFormCreatePerson.UpdateFaceArea(Face: TFaceDetectionResultItem);
var
  B: TBitmap;
begin
  LsExtracting.Hide;

  if Face <> nil then
  begin
    B := TBitmap.Create;
    try
      B.SetSize(Face.Width, Face.Height);
      B.Canvas.CopyRect(Rect(0, 0, Face.Width, Face.Height), FPicture.Canvas, Face.Rect);
      Exchange(FPicture, B);
    finally
      F(B);
    end;
    RecreateImage;
    PbPhoto.Refresh;
  end;
end;

procedure TFormCreatePerson.UpdateNameStatus(PersonList: TPathItemCollection);
var
  P: TPoint;
begin
  LsNameCheck.Hide;
  WlPersonNameStatus.Left := LsNameCheck.Left;
  if PersonList.Count = 0 then
  begin
    WlPersonNameStatus.IconWidth := 16;
    WlPersonNameStatus.Icon := ImOK.Picture.Icon;
    WlPersonNameStatus.Text := FormatEx(L('Person name is valid!'), [PersonList.Count]);
    WlPersonNameStatus.CanClick := False;
    WlPersonNameStatus.Refresh;
  end else
  begin
    if AnsiUpperCase(TPersonItem(PersonList[0]).PersonName) = AnsiUpperCase(WedName.Text) then
    begin
      WlPersonNameStatus.CanClick := True;
      WlPersonNameStatus.IconWidth := 16;
      WlPersonNameStatus.Icon := ImInvalid.Picture.Icon;
      WlPersonNameStatus.Text := FormatEx(L('Person name already in use!'), [PersonList.Count]);
      WlPersonNameStatus.Refresh;
    end else
    begin
      WlPersonNameStatus.CanClick := True;
      WlPersonNameStatus.Text := FormatEx(L('{0} person(s) are found with similar name!'), [PersonList.Count]);
      WlPersonNameStatus.IconWidth := 16;
      WlPersonNameStatus.Icon := ImWarning.Picture.Icon;
      WlPersonNameStatus.Refresh;
    end;
  end;
  WlPersonNameStatus.Show;

  if FFormPersonSuggest = nil then
    FFormPersonSuggest := TFormPersonSuggest.Create(Self);
  FFormPersonSuggest.Width := WedName.Width;
  P := Point(WedName.Left, WedName.Top + WedName.Height);
  P := ClientToScreen(P);
  TFormPersonSuggest(FFormPersonSuggest).LoadPersons(Self, P, PersonList);

  BtnOk.Enabled := (PersonList.Count = 0) or ((PersonList.Count > 0) and (TPersonItem(PersonList[0]).PersonName <> WedName.Text));
end;

procedure TFormCreatePerson.WedNameChange(Sender: TObject);
begin
  TmrCkeckName.Restart;
  BtnOk.Enabled := False;
end;

procedure TFormCreatePerson.WedNameExit(Sender: TObject);
begin
  if FFormPersonSuggest <> nil then
    FFormPersonSuggest.Hide;
end;

procedure TFormCreatePerson.WedNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    BtnOkClick(Sender);
  end;
end;

procedure TFormCreatePerson.WllGroupsDblClick(Sender: TObject);
var
  KeyWords: string;
begin
  CloseSuggestForm;
  DBChangeGroups(FRelatedGroups, KeyWords, True);
end;

procedure TFormCreatePerson.WlPersonNameStatusClick(Sender: TObject);
begin
  TmrCkeckNameTimer(Sender);
end;

procedure TFormCreatePerson.WMActivateApp(var Msg: TMessage);
begin
  if Msg.wParam = 0 then
    CloseSuggestForm;
end;

procedure TFormCreatePerson.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
begin
  FCurrentGroups := EncodeGroups(FRelatedGroups);
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

procedure TFormCreatePerson.TmrCkeckNameTimer(Sender: TObject);
var
  PName: string;
begin
  TmrCkeckName.Enabled := False;
  NewFormState;
  if WedName.Text <> '' then
  begin
    PName := '';
    if FPerson <> nil then
      PName := FPerson.Name;
    TCheckNameThread.Create(Self, StateID, PName, Trim(WedName.Text), FIsEditMode);
    LsNameCheck.Show;
    WlPersonNameStatus.IconWidth := 0;
    WlPersonNameStatus.Left := LsNameCheck.Left + LsNameCheck.Width + 3;
  end else
  begin
    WlPersonNameStatus.IconWidth := 16;
    WlPersonNameStatus.Icon := ImWarning.Picture.Icon;
    WlPersonNameStatus.Text := L('Person name is required!');
    WlPersonNameStatus.CanClick := False;
    WlPersonNameStatus.Refresh;
    CloseSuggestForm;
  end;
end;

procedure TFormCreatePerson.GroupClick(Sender: TObject);
var
  KeyWords: string;
  WL: TWebLink;
begin
  CloseSuggestForm;
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    ShowGroupInfo(WL.Text, False, nil);
  end else
  begin
    DBChangeGroups(FRelatedGroups, KeyWords, False);
    PostMessage(Handle, FReloadGroupsMessage, 0, 0);
  end;
end;

procedure TFormCreatePerson.FillImageList;
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
    SmallB.Canvas.Pen.Color := Theme.PanelColor;
    SmallB.Canvas.Brush.Color := Theme.PanelColor;
    SmallB.Canvas.Rectangle(0, 0, 16, 16);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;
  FCurrentGroups := EncodeGroups(FRelatedGroups);
  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf24bit;
      SmallB.Canvas.Brush.Color := Theme.PanelColor;
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

{ TPersonExtractor }

constructor TPersonExtractor.Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
begin
  inherited Create(AOwner, False);
  FOwner := AOwner;
  FBitmap := TBitmap.Create;
  FBitmap.Assign(Src);
  FFace := AFace.Copy;
end;

destructor TPersonExtractor.Destroy;
begin
  F(FBitmap);
  F(FFace);
  inherited;
end;

procedure TPersonExtractor.Execute;
var
  W, H: Integer;
  RMp, AMp, RR: Double;
  SmallBitmap: TBitmap;
begin
  inherited;
  FreeOnTerminate := True;
  FFaces := TFaceDetectionResult.Create;
  try

    W := FBitmap.Width;
    H := FBitmap.Height;
    RMp := W * H;
    AMp := Settings.ReadInteger('Options', 'FaceDetectionSize', 3) * 100000;

    if RMp > AMp then
    begin
      RR := Sqrt(RMp / AMp);
      SmallBitmap := TBitmap.Create;
      try
        ProportionalSize(Round(W / RR), Round(H / RR), W, H);
        uBitmapUtils.QuickReduceWide(W, H, FBitmap, SmallBitmap);
        FaceDetectionManager.FacesDetection(SmallBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');
      finally
        F(SmallBitmap);
      end;
    end else
      FaceDetectionManager.FacesDetection(FBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');

    SynchronizeEx(UpdatePicture);
  finally
    F(FFaces);
  end;
end;

procedure TPersonExtractor.UpdatePicture;
var
  I: Integer;
begin
  for I := 0 to FFaces.Count - 1 do
    if RectIntersectWithRectPercent(FFaces[I].Rect, FFace.Rect) > 80 then
    begin
      FOwner.UpdateFaceArea(FFaces[I]);
      Exit;
    end;

  FOwner.UpdateFaceArea(nil);
end;

{ TCheckNameThread }

constructor TCheckNameThread.Create(AOwner: TFormCreatePerson; State: TGuid; Name, NewName: string; EditPerson: Boolean);
begin
  inherited Create(AOwner, State);
  FName := Name;
  FNewName := NewName;
  FPersons := TPathItemCollection.Create;
  FEditPerson := EditPerson;
end;

destructor TCheckNameThread.Destroy;
begin
  F(FPersons);
  inherited;
end;

procedure TCheckNameThread.Execute;
var
  I: Integer;
  SC: TSelectCommand;
  PC: TPersonCollection;
  PI: TPersonItem;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    SC := TSelectCommand.Create(FormatEx('(SELECT *, (UCase(ObjectName) = UCase(:ObjectNameCheck)) AS NameCheck FROM {0})', [ObjectTableName]));
    try
      SC.AddCustomeParameter(TStringParameter.Create('ObjectNameCheck', FNewName));
      SC.AddParameter(TAllParameter.Create);
      SC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('ObjectName like "%{0}%"', [NormalizeDBStringLike(FNewName)])));
      if FEditPerson then
        SC.AddWhereParameter(TStringParameter.Create('ObjectName', FName, paNotEquals));
      
      SC.Order.Add(TOrderParameter.Create('NameCheck', False));
      SC.Order.Add(TOrderParameter.Create('ObjectName', False));
      SC.TopRecords := 5;
      SC.Execute;

      PC := TPersonCollection.Create;
      try
        PC.ReadFromDS(SC.DS);
        for I := 0 to PC.Count - 1 do
        begin
          PI := TPersonItem.CreateFromPath(cPersonsPath + '\' + PC[I].Name, PATH_LOAD_NO_IMAGE, 0);
          FPersons.Add(PI);
          PI.ReadFromPerson(PC[I], 0, 16);
        end;
        SynchronizeEx(UpdateNameData);
      finally
        F(PC);
      end;
    finally
      F(SC);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TCheckNameThread.UpdateNameData;
begin
  TFormCreatePerson(OwnerForm).UpdateNameStatus(FPersons);
end;

end.
