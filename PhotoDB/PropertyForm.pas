unit PropertyForm;

interface

uses
  Windows, ExplorerTypes, UnitGroupsWork, UnitUpdateDB, dolphin_db, UnitDBKernel,
  Forms, DBCMenu, Menus, DB, StdCtrls, Controls, Graphics, Classes,
  ExtCtrls, ActiveX, ShellAPI, Messages, SysUtils, Variants, UnitPasswordForm,
  Dialogs, JPEG, Rating, ComCtrls, AppEvnts, Effects, ImgList, DropTarget,
  DropSource, SaveWindowPos, Grids, ValEdit, TabNotBk, GraphicCrypt, DateUtils,
  ProgressActionUnit, DmGradient, Clipbrd, WebLink, UnitLinksSupport,
  UnitSQLOptimizing, Math, CommonDBSupport, UnitUpdateDBObject, RAWImage,
  DragDropFile, DragDrop, UnitPropertyLoadImageThread, UnitINI, uLogger,
  UnitPropertyLoadGistogrammThread, uVistaFuncs, UnitDBDeclare, UnitDBCommonGraphics,
  UnitCDMappingSupport, uDBDrawing, uFileUtils, DBLoading, UnitDBCommon, uMemory,
  UnitBitmapImageList, uListViewUtils, uList64, uDBForm, uDBPopupMenuInfo,
  CCR.Exif, uConstants;

type
  TShowInfoType = (SHOW_INFO_FILE_NAME, SHOW_INFO_ID, SHOW_INFO_IDS);

type
  TPropertiesForm = class(TDBForm)
    Image1: TImage;
    CommentMemo: TMemo;
    LabelComment: TLabel;
    PmItem: TPopupMenu;
    Shell1: TMenuItem;
    Show1: TMenuItem;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Searchforit1: TMenuItem;
    DBItem1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    SaveWindowPos1: TSaveWindowPos;
    PmRatingNotAvaliable: TPopupMenu;
    Ratingnotsets1: TMenuItem;
    PmComment: TPopupMenu;
    SetComent1: TMenuItem;
    Comentnotsets1: TMenuItem;
    N2: TMenuItem;
    Copy2: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N3: TMenuItem;
    Undo1: TMenuItem;
    N4: TMenuItem;
    SelectAll1: TMenuItem;
    Image2: TImage;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    BtDone: TButton;
    BtSave: TButton;
    BtnFind: TButton;
    CopyEXIFPopupMenu: TPopupMenu;
    CopyCurrent1: TMenuItem;
    CopyAll1: TMenuItem;
    ImageList1: TImageList;
    PmLinks: TPopupMenu;
    PmAddLink: TPopupMenu;
    Open1: TMenuItem;
    OpenFolder1: TMenuItem;
    Change1: TMenuItem;
    Delete1: TMenuItem;
    Addnewlink1: TMenuItem;
    IDMenu1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    RegGroupsImageList: TImageList;
    PopupMenuGroups: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    CreateGroup1: TMenuItem;
    ChangeGroup1: TMenuItem;
    GroupManeger1: TMenuItem;
    SearchForGroup1: TMenuItem;
    QuickInfo1: TMenuItem;
    PmClear: TPopupMenu;
    Clear1: TMenuItem;
    MoveToGroup1: TMenuItem;
    DropFileTarget2: TDropFileTarget;
    PmImageConnect: TPopupMenu;
    AddImThLink1: TMenuItem;
    N7: TMenuItem;
    Cancel1: TMenuItem;
    AddImThProcessingImageAndAddOriginalToProcessingPhoto1: TMenuItem;
    N8: TMenuItem;
    AddOriginalImTh1: TMenuItem;
    AddOriginalImThAndAddProcessngToOriginalImTh1: TMenuItem;
    ImageLoadingFile: TDBLoading;
    PcMain: TPageControl;
    TsGeneral: TTabSheet;
    TsGroups: TTabSheet;
    TsEXIF: TTabSheet;
    TsGistogramm: TTabSheet;
    TsAdditional: TTabSheet;
    LabelKeywords: TLabel;
    KeyWordsMemo: TMemo;
    IDLabel1: TLabel;
    WidthLabel: TLabel;
    IDLabel: TMemo;
    heightmemo: TMemo;
    widthmemo: TMemo;
    Heightlabel: TLabel;
    SizeLabel1: TLabel;
    SizeLabel: TMemo;
    TimeEdit: TDateTimePicker;
    DateEdit: TDateTimePicker;
    DateLabel1: TLabel;
    TimeLabel: TLabel;
    RatingLabel1: TLabel;
    RatingEdit: TRating;
    CollectionMemo: TMemo;
    CollectionLabel: TLabel;
    OwnerLabel: TLabel;
    OwnerMemo: TMemo;
    LabelPath: TMemo;
    Label4: TLabel;
    LabelName1: TLabel;
    LabelName: TMemo;
    Image3: TImage;
    LbGroupsEditInfo: TLabel;
    LbAvaliableGroups: TLabel;
    LstAvaliableGroups: TListBox;
    Button7: TButton;
    Button6: TButton;
    lstCurrentGroups: TListBox;
    LbCurrentGroups: TLabel;
    CbShowAllGroups: TCheckBox;
    CbRemoveKeywordsForGroups: TCheckBox;
    BtnNewGroup: TButton;
    BtnManageGroups: TButton;
    Label5: TLabel;
    RgGistogrammChannel: TRadioGroup;
    DgGistogramm: TDmGradient;
    GistogrammImage: TImage;
    Label2: TLabel;
    CbInclude: TCheckBox;
    LbLinks: TLabel;
    LinksScrollBox: TScrollBox;
    VleExif: TValueListEditor;
    procedure Execute(ID : integer);
    procedure BtDoneClick(Sender: TObject);
    procedure BtnFindClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CommentMemoChange(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Searchforit1Click(Sender: TObject);
    procedure ExecuteFileNoEx(FileName : string);
    procedure BeginAdding(Sender: TObject);
    procedure EndAdding(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);

    procedure ChangedDBDataGroups(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);

    procedure PmItemPopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure ReloadGroups;
    procedure ComboBox1_KeyPress(Sender: TObject; var Key: Char);
    procedure ExecuteEx(IDs : TArInteger);
    procedure FormShow(Sender: TObject);
    procedure GroupsManager1Click(Sender: TObject);
    procedure RatingEditMouseDown(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Ratingnotsets1Click(Sender: TObject);
    procedure PmRatingNotAvaliablePopup(Sender: TObject);
    procedure CommentMemoDblClick(Sender: TObject);
    procedure PmCommentPopup(Sender: TObject);
    procedure Comentnotsets1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure ReadExifData;
    procedure RgGistogrammChannelClick(Sender: TObject);
    procedure ResetBold;
    procedure VleExifContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure CopyCurrent1Click(Sender: TObject);
    procedure CopyAll1Click(Sender: TObject);
    procedure ReadLinks;
    procedure Addnewlink1Click(Sender: TObject);
    procedure LinkOnPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure LinkClick(Sender: TObject);
    procedure PmLinksPopup(Sender: TObject);
    procedure Change1Click(Sender: TObject);
    procedure SetLinkInfo(Sender : TObject; ID : String; Info : TLinkInfo; N : integer; Action : Integer);
    procedure CloseEditLinkForm(Form : TForm; ID : String);
    procedure PmAddLinkPopup(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure OpenFolder1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure BtnManageGroupsClick(Sender: TObject);
    procedure BtnNewGroupClick(Sender: TObject);
    Procedure RecreateGroupsList;
    procedure LstAvaliableGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstCurrentGroupsDblClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure lstCurrentGroupsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Clear1Click(Sender: TObject);
    procedure CbShowAllGroupsClick(Sender: TObject);
    procedure LstAvaliableGroupsDblClick(Sender: TObject);
    function aGetGroupByCode(GroupCode : String) : integer;
    procedure CreateGroup1Click(Sender: TObject);
    procedure ChangeGroup1Click(Sender: TObject);
    procedure GroupManeger1Click(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure QuickInfo1Click(Sender: TObject);
    procedure PopupMenuGroupsPopup(Sender: TObject);
    procedure CbRemoveKeywordsForGroupsClick(Sender: TObject);
    procedure MoveToGroup1Click(Sender: TObject);
    procedure LockImput;
    procedure UnLockImput;
    procedure PmClearPopup(Sender: TObject);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure AddImThLink1Click(Sender: TObject);
    procedure AddOriginalImTh1Click(Sender: TObject);
    procedure AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(
      Sender: TObject);
    procedure AddOriginalImThAndAddProcessngToOriginalImTh1Click(
      Sender: TObject);
    procedure PmImageConnectPopup(Sender: TObject);
    procedure PcMainChange(Sender: TObject);
    procedure ImageLoadingFileDrawBackground(Sender: TObject; Buffer: TBitmap);
  private
    { Private declarations }
    LinkDropFiles: TStrings;
    EditLinkForm: TForm;
    Links: array of TWebLink;
    FReadingInfo: Boolean;
    FSaving: Boolean;
    FOldGroups, FNowGroups: TGroups;
    FShowenRegGroups: TGroups;
    FPropertyLinks, ItemLinks: TLinksInfo;
    FFilesInfo: TDBPopupMenuInfo;
    FMenuRecord: TDBPopupMenuInfoRecord;
    RegGroups: TGroups;
    Adding_now, Editing_info, No_file: Boolean;
    FDateTimeInFileExists: Boolean;
    FFileDate, FFileTime: TDateTime;
    DestroyCounter: Integer;
    function GetImageID: Integer;
    function GetFileName: string;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    SID: TGUID;
    FShowInfoType: TShowInfoType;
    FCurrentPass: string;
    GistogrammData: TGistogrammData;
    procedure LoadLanguage;
    function ReadCHInclude: Boolean;
    function ReadCHLinks: Boolean;
    function ReadCHDate: Boolean;
    function ReadCHTime: Boolean;
    procedure OnDoneLoadingImage(Sender: TObject);
    procedure OnDoneLoadGistogrammData(Sender: TObject);
    property ImageID : Integer read GetImageID;
    property FileName : string read GetFileName;
  end;

  TPropertyManager = class(TObject)
  private
    FPropertys : TList;
  public
    constructor Create;
    destructor Destroy; override;
    function NewSimpleProperty : TPropertiesForm;
    function NewIDProperty(ID : Integer) : TPropertiesForm;
    function NewFileProperty(FileName : string) : TPropertiesForm;
    procedure AddProperty(aProperty : TPropertiesForm);
    procedure RemoveProperty(aProperty : TPropertiesForm);
    function IsPropertyForm(aProperty: TForm): Boolean;
    function PropertyCount : Integer;
    function GetAnySimpleProperty : TPropertiesForm;
    function GetPropertyByID(ID : integer) : TPropertiesForm;
    function GetPropertyByFileName(FileName : string): TPropertiesForm;
  end;

var
  PropertyManager: TPropertyManager;

implementation

uses Language, UnitQuickGroupInfo, Searching, SlideShow, UnitHintCeator,
     UnitEditGroupsForm, UnitManageGroups, CmpUnit,
     UnitEditLinkForm, UnitHelp, ExplorerUnit, UnitNewGroupForm,
     UnitFormChangeGroup, SelectGroupForm, UnitGroupsTools;

{$R *.dfm}

{ TPropertyManager }

procedure TPropertyManager.AddProperty(aProperty: TPropertiesForm);
begin
  if FPropertys.IndexOf(aProperty) = -1 then
    FPropertys.Add(aProperty);
end;

constructor TPropertyManager.Create;
begin
  FPropertys := TList.Create;
end;

destructor TPropertyManager.Destroy;
begin
  FreeAndNil(FPropertys);
end;

function TPropertyManager.GetAnySimpleProperty: TPropertiesForm;
begin
  if PropertyCount = 0 then
    Result := NewSimpleProperty
  else
    Result := FPropertys[0];
end;

function TPropertyManager.GetPropertyByID(ID : Integer): TPropertiesForm;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if TPropertiesForm(FPropertys[I]).FShowInfoType = SHOW_INFO_ID then
      if TPropertiesForm(FPropertys[I]).ImageID = ID then
  begin
    Result := FPropertys[i];
    Exit;
  end;
end;

function TPropertyManager.GetPropertyByFileName(FileName : string): TPropertiesForm;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if TPropertiesForm(FPropertys[i]).FShowInfoType = SHOW_INFO_FILE_NAME then
      if AnsiLowerCase(TPropertiesForm(FPropertys[i]).FileName) = AnsiLowerCase(FileName) then
      begin
        Result := FPropertys[i];
        Exit;
      end;
end;

function TPropertyManager.IsPropertyForm(aProperty: TForm): Boolean;
begin
  Result := FPropertys.IndexOf(aProperty) > -1;
end;

function TPropertyManager.NewFileProperty(FileName: string): TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount > 0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
  begin
    Result := GetPropertyByFileName(FileName);
    if Result <> nil then
      Exit
    else
      Result := NewSimpleProperty;
  end;
end;

function TPropertyManager.NewIDProperty(ID: Integer): TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount>0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
  begin
    Result := GetPropertyByID(ID);
    if Result <> nil then
      Exit
    else
      Result := NewSimpleProperty;
  end;
end;

function TPropertyManager.NewSimpleProperty: TPropertiesForm;
begin
  if not DBKernel.Readbool('Options', 'AllowManyInstancesOfProperty', True) then
  begin
    if PropertyCount > 0 then
      Result := FPropertys[0]
    else
      Application.CreateForm(TPropertiesForm, Result);
  end else
    Application.CreateForm(TPropertiesForm, Result);
end;

function TPropertyManager.PropertyCount: Integer;
begin
  Result := FPropertys.Count;
end;

procedure TPropertyManager.RemoveProperty(aProperty: TPropertiesForm);
begin
  FPropertys.Remove(aProperty);
end;

function TPropertiesForm.ReadCHInclude: Boolean;
begin
  Result := False;
  if FShowInfoType = SHOW_INFO_ID then
    Result := (FFilesInfo[0].Include <> CbInclude.Checked);
  if FShowInfoType = SHOW_INFO_IDS then
  begin
    if (FFilesInfo.IsVariousInclude) then
    begin
      if (CbInclude.State <> CbGrayed) then
      begin
        Result := True;
        Exit;
      end;
    end else
    begin
      if (FFilesInfo.StatInclude) and (CbInclude.State = CbUnChecked) or (not FFilesInfo.StatInclude) and
        (CbInclude.State = CbChecked) then
      begin
        Result := True;
        Exit;
      end
    end;
  end;
end;

function TPropertiesForm.ReadCHLinks : Boolean;
begin
  Result := not CompareLinks(FPropertyLinks, ItemLinks, True);
end;

function TPropertiesForm.ReadCHDate : Boolean;
begin
  Result := False;
  if FShowInfoType = SHOW_INFO_ID then
    Result := (((FFilesInfo[0].IsDate <> DateEdit.Checked) or
          (FFilesInfo[0].Date <> DateEdit.DateTime)) and DateEdit.Enabled);

  if FShowInfoType = SHOW_INFO_IDS then
    Result := ((FFilesInfo.StatIsDate <> not DateEdit.Checked) or
        (FFilesInfo.StatDate <> DateEdit.DateTime) or (FFilesInfo.IsVariousDate))
      and DateEdit.Enabled;

end;

function TPropertiesForm.ReadCHTime : Boolean;
var
  VarTime : Boolean;
begin
  Result := False;
  if FShowInfoType = SHOW_INFO_ID then
  begin
    VarTime := Abs(FFilesInfo[0].Time - TimeOf(TimeEdit.Time)) > 1 / (24 * 60 * 60 * 3);
    Result := (((FFilesInfo[0].IsTime <> TimeEdit.Checked) or VarTime) and TimeEdit.Enabled);
  end;
  if FShowInfoType = SHOW_INFO_IDS then
  begin
    VarTime := Abs(FFilesInfo.StatTime - TimeOf(TimeEdit.Time)) > 1 / (24 * 60 * 60 * 3);
    Result := ((FFilesInfo.StatIsTime <> not TimeEdit.Checked) or VarTime or (FFilesInfo.IsVariousTime))
      and TimeEdit.Enabled;
  end;
end;

procedure TPropertiesForm.Execute(ID: Integer);
var
  FBS: TStream;
  FBit, B1, TempBitmap,
  FShadowImage: TBitmap;
  JPEG: TJpegImage;
  PassWord: string;
  Exists, W, H: Integer;
  DataRecord : TDBPopupMenuInfoRecord;
  WorkQuery : TDataSet;
begin
  try
    if FSaving then
    begin
      SetFocus;
      Exit;
    end;

    R(EditLinkForm);

    Editing_info := False;
    FCurrentPass := '';
    CbInclude.AllowGrayed := False;
    ResetBold;
    if ImageID <> Id then
      PcMain.ActivePageIndex := 0;
    DateEdit.Enabled := True;
    TimeEdit.Enabled := True;
    Image2.Visible := False;
    FShowInfoType := SHOW_INFO_ID;

    DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
    DBKernel.UnRegisterChangesIDbyID(Self, ChangedDBDataByID, ID);
    DBKernel.RegisterChangesIDbyID(Self, ChangedDBDataByID, ID);
    DBitem1.Visible := True;
    BtSave.Caption := L('Save');
    CommentMemo.Cursor := CrDefault;
    CommentMemo.PopupMenu := nil;
    WorkQuery := GetQuery;
    try
      SetSQL(WorkQuery, 'SELECT * FROM $DB$ WHERE ID=' + Inttostr(ID));
      WorkQuery.Active := True;
      if WorkQuery.RecordCount = 0 then
        No_file := True;
      if not No_file then
        BtSave.Enabled := False;

      WorkQuery.First;
      DataRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
      FFilesInfo.Clear;
      FFilesInfo.Add(DataRecord);

      FReadingInfo := True;
      try
        FBit := TBitmap.Create;
        try
          FBit.PixelFormat := pf24bit;
          B1 := TBitmap.Create;
          try
            B1.PixelFormat := pf24bit;
            B1.Width := ThImageSize;
            B1.Height := ThImageSize;
            PassWord := '';
            if TBlobField(WorkQuery.FieldByName('thum')) = nil then
              Exit;

            JPEG := nil;
            try
              if ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')) then
              begin
                PassWord := DBkernel.FindPasswordForCryptBlobStream(WorkQuery.FieldByName('thum'));
                if PassWord = '' then
                  PassWord := GetImagePasswordFromUserBlob(WorkQuery.FieldByName('thum'),
                    WorkQuery.FieldByName('FFileName').AsString);

                if PassWord = '' then
                  Exit;

                JPEG := TJpegImage.Create;
                DeCryptBlobStreamJPG(WorkQuery.FieldByName('thum'), PassWord, JPEG);
                FCurrentPass := PassWord;
              end else
              begin
                FBS := GetBlobStream(WorkQuery.FieldByName('thum'), BmRead);
                try
                  JPEG := TJpegImage.Create;
                  JPEG.LoadFromStream(FBS);
                finally
                  FBS.Free;
                end;
              end;

              TempBitmap := TBitmap.Create;
              try
                TempBitmap.Assign(JPEG);
                F(JPEG);
                W := TempBitmap.Width;
                H := TempBitmap.Height;
                ProportionalSize(ThSizeExplorerPreview, ThSizeExplorerPreview, W, H);
                DoResize(W, H, TempBitmap, Fbit);
              finally
                F(TempBitmap);
              end;

              B1.Width := ThSizePropertyPreview + 4;
              B1.Height := ThSizePropertyPreview + 4;
              B1.Canvas.Brush.Color := clBtnFace;
              B1.Canvas.Pen.Color := clBtnFace;
              B1.Canvas.Rectangle(0, 0, B1.Width, B1.Height);

              FShadowImage := TBitmap.Create;
              try
                DrawShadowToImage(FShadowImage, Fbit);
                DrawImageEx32To24(B1, FShadowImage, B1.Width div 2 - FShadowImage.Width div 2,
                  B1.Height div 2 - FShadowImage.Height div 2);
              finally
                F(FShadowImage);
              end;
              F(FBit);
              ApplyRotate(B1, DataRecord.Rotation);
              Exists := 0;
              DrawAttributes(B1, 100, DataRecord.Rating, DataRecord.Rotation, DataRecord.Access, DataRecord.FileName,
                ValidCryptBlobStreamJPG(WorkQuery.FieldByName('thum')), Exists, DataRecord.ID);

              Image1.Picture.Bitmap := B1;
            finally
              F(JPEG);
            end;
          finally
            F(B1);
          end;
        finally
          F(FBit);
        end;
      finally
        FReadingInfo := False;
      end;

      Idlabel.Text := Inttostr(Id);
      Caption := L('Properties') + ' - ' + Trim(WorkQuery.FieldByName('Name').AsString);
      KeyWordsMemo.Text := DataRecord.KeyWords;
      LabelName.Text := ExtractFileName(DataRecord.FileName);
      LabelPath.Text := DataRecord.FileName;
      SizeLabel.Text := SizeInTextA(DataRecord.FileSize);
      Widthmemo.Text := IntToStr(WorkQuery.FieldByName('Width').AsInteger) + L('px.');
      Heightmemo.Text := IntToStr(WorkQuery.FieldByName('Height').AsInteger) + L('px.');
      RatingEdit.Rating := DataRecord.Rating;
      RatingEdit.Islayered := False;
      DateEdit.Enabled := True;
      TimeEdit.Enabled := True;

      CollectionMemo.Text := DBkernel.GetDataBaseName;
      OwnerMemo.Text := DBkernel.ReadRegName;

      DateEdit.DateTime := DataRecord.Date;
      TimeEdit.Time := DataRecord.Time;
      DateEdit.Checked := DataRecord.IsDate;
      TimeEdit.Checked := DataRecord.IsTime;
      CbInclude.Checked := DataRecord.Include;
      if Length(DataRecord.Comment) > 0 then
      begin
        CommentMemo.Show;
        CommentMemo.Text := DataRecord.Comment;
        LabelComment.Show;
      end else
      begin
        CommentMemo.Hide;
        CommentMemo.Text := '';
        LabelComment.Hide;
      end;
      ItemLinks := ParseLinksInfo(DataRecord.Links);
      FPropertyLinks := CopyLinksInfo(ItemLinks);

      FNowGroups := UnitGroupsWork.EncodeGroups(DataRecord.Groups);
      FOldGroups := CopyGroups(FNowGroups);

      FFilesInfo := TDBPopupMenuInfo.Create;
      FMenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
      FFilesInfo.Clear;
      FFilesInfo.Add(FMenuRecord);
      FFilesInfo.AttrExists := False;
      CommentMemoChange(nil);
      BtnFind.Visible := True;
      ReloadGroups;
      Editing_info := True;
      FReadingInfo := False;
      if Visible then
      begin
        LstCurrentGroups.Refresh;
        LstAvaliableGroups.Refresh;
      end;
      ImageLoadingFile.Visible := False;
      Show;
    finally
      FreeDS(WorkQuery);
    end;
  except
    on E: Exception do
    begin
      MessageBoxDB(Handle, L('Error getting info:') + #13 + E.message, L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      Close;
    end;
  end;
  SID := GetGUID;
end;

procedure TPropertiesForm.BtDoneClick(Sender: TObject);
begin
  R(EditLinkForm);
  Close;
end;

procedure TPropertiesForm.BtnFindClick(Sender: TObject);
begin
  if no_file then exit;
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(LabelPath.text);
    SetPath(GetDirectory(LabelPath.text));
    Show;
  end;
end;

procedure TPropertiesForm.FormCreate(Sender: TObject);
begin
  EditLinkForm := nil;
  FFilesInfo := TDBPopupMenuInfo.Create;
  DestroyCounter := 0;
  GistogrammData.Loaded := False;

  LinkDropFiles := TStringList.Create;
  PropertyManager.AddProperty(Self);
  LstCurrentGroups.DoubleBuffered := True;
  LstAvaliableGroups.DoubleBuffered := True;
  FreeGroups(RegGroups);
  FreeGroups(FShowenRegGroups);

  SetLength(Links, 0);
  FReadingInfo := False;
  FSaving := False;
  DropFileTarget1.Register(Self);
  DropFileTarget2.Register(LinksScrollBox);
  No_file := False;
  Editing_info := True;
  Adding_now := False;
  DBKernel.RegisterChangesID(Self, ChangedDBDataGroups);
  DBkernel.RegisterForm(Self);
  TimeEdit.ParentColor := True;
  PmItem.Images := DBKernel.ImageList;
  PmLinks.Images := DBKernel.ImageList;
  Shell1.ImageIndex := DB_IC_SHELL;
  Show1.ImageIndex := DB_IC_SLIDE_SHOW;
  Copy1.ImageIndex := DB_IC_COPY_ITEM;
  Searchforit1.ImageIndex := DB_IC_SEARCH;
  Open1.ImageIndex := DB_IC_SHELL;
  OpenFolder1.ImageIndex := DB_IC_EXPLORER;
  IDMenu1.ImageIndex := DB_IC_NOTES;
  Change1.ImageIndex := DB_IC_PROPERTIES;
  Delete1.ImageIndex := DB_IC_DELETE_INFO;
  DBItem1.ImageIndex := DB_IC_NOTES;

  Up1.ImageIndex := DB_IC_UP;
  Down1.ImageIndex := DB_IC_DOWN;
  DBKernel.RegisterForm(Self);
  SaveWindowPos1.Key := GetRegRootKey + 'Properties';
  SaveWindowPos1.SetPosition;
  LoadLanguage;

  CbRemoveKeywordsForGroups.Checked := DBKernel.ReadBool('Propetry', 'DeleteKeyWords', True);
  CbShowAllGroups.Checked := DBKernel.ReadBool('Propetry', 'ShowAllGroups', False);
end;

procedure TPropertiesForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
  I : Integer;
  BitmapImageList : TBitmapImageList;
begin
  if (Button = mbLeft) then
  begin
    DragImageList.Clear;
    DragImageList.Masked := False;

    DropFileSource1.Files.Clear;
    if FShowInfoType = SHOW_INFO_IDS then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FileExists(ProcessPath(FFilesInfo[I].FileName)) then
         DropFileSource1.Files.Add(ProcessPath(FFilesInfo[I].FileName));
    end else
    begin
      if FileExists(ProcessPath(LabelPath.Text)) then
        DropFileSource1.Files.Add(ProcessPath(LabelPath.Text));
    end;
    if DropFileSource1.Files.Count > 0 then
    begin

      BitmapImageList := TBitmapImageList.Create;
      try
        DragImage := TBitmap.Create;
        try
          DragImage.Assign(Image1.Picture.Graphic);
          BitmapImageList.AddBitmap(DragImage, False);
          CreateDragImageEx(nil, DragImageList, BitmapImageList, clGradientActiveCaption,
            clGradientInactiveCaption, clHighlight, Font, ExtractFileName(DropFileSource1.Files[0]));
        finally
          F(DragImage);
        end;
      finally
        F(BitmapImageList);
      end;

      DropFileSource1.ImageIndex := 0;
      DropFileSource1.Execute;
    end;
  end;
end;

procedure TPropertiesForm.ImageLoadingFileDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := clBtnFace;
  Buffer.Canvas.Brush.Color := clBtnFace;
  Buffer.Canvas.Rectangle(0, 0, Buffer.Width, Buffer.Height);
end;

procedure UpdateControlFont(Control: TControl; IsBold: Boolean);
begin
  if Control is TLabel then
  begin
    if IsBold then
      TLabel(Control).Font.Style := TLabel(Control).Font.Style + [fsBold]
    else
      TLabel(Control).Font.Style := TLabel(Control).Font.Style - [fsBold];
  end else if Control is TCheckBox then
  begin
    if IsBold then
      TCheckBox(Control).Font.Style := TCheckBox(Control).Font.Style + [fsBold]
    else
      TCheckBox(Control).Font.Style := TCheckBox(Control).Font.Style - [fsBold];
  end;
end;

procedure TPropertiesForm.CommentMemoChange(Sender: TObject);
var
  CHInclude,
  CHLinks,
  CHTime,
  CHDate,
  CHRating,
  CHKeyWords,
  CHGroups,
  CHComment : Boolean;
begin
  if not Editing_info then
    Exit;

  CHLinks := ReadCHLinks;
  CHTime := ReadCHTime;
  CHDate := ReadCHDate;
  CHInclude := ReadCHInclude;
  if (FShowInfoType = SHOW_INFO_IDS) then
  begin
    CHComment := (not CommentMemo.readonly and FFilesInfo.IsVariousComments) or
      (not FFilesInfo.IsVariousComments and (CommentMemo.Text <> FFilesInfo.CommonComments));
  end else
    CHComment := FFilesInfo.CommonComments <> CommentMemo.Text;

  if (FShowInfoType = SHOW_INFO_IDS) then
    CHRating := (not RatingEdit.Islayered)
  else
    CHRating := FFilesInfo.StatRating <> RatingEdit.Rating;

  CHKeyWords := VariousKeyWords(FFilesInfo.CommonKeyWords, KeyWordsMemo.Text);
  CHGroups := not CompareGroups(FOldGroups, FNowGroups);

  UpdateControlFont(LabelComment, CHComment);
  UpdateControlFont(LabelKeywords, ChKeywords);
  UpdateControlFont(RatingLabel1, CHRating);
  UpdateControlFont(DateLabel1, ReadCHDate);
  UpdateControlFont(TimeLabel, ReadCHTime);
  UpdateControlFont(LbLinks, CHLinks);
  UpdateControlFont(CbInclude, CHInclude);

  if FShowInfoType = SHOW_INFO_FILE_NAME then
    BtSave.Enabled := False
  else
    BtSave.Enabled := CHDate or CHTime or CHRating or CHComment or ChKeywords or CHGroups or CHInclude or CHLinks;

end;

procedure TPropertiesForm.Image1DblClick(Sender: TObject);
begin
  if No_file then
    Exit;

  if (FShowInfoType = SHOW_INFO_ID) or (FShowInfoType = SHOW_INFO_IDS) then
  begin
    CommentMemo.Show;
    LabelComment.Show;
  end;
end;

procedure TPropertiesForm.BtSaveClick(Sender: TObject);
var
  _sqlexectext, CommonGroups, KeyWords, SGroups, SLinks: string;
  SLinkInfo: TLinksInfo;
  I, J: Integer;
  EventInfo: TEventValues;
  XCount: Integer;
  ProgressForm: TProgressActionForm;
  List: TSQLList;
  IDs: string;
  FQuery: TDataSet;
  IDArray: TArInteger;
  WorkQuery: TDataSet;

  function GenerateIDList : string;
  var
    K : Integer;
  begin
    Result := '';
    for K := 0 to FFilesInfo.Count - 1 do
    begin
      if K <> 0 then
        Result := Result + ',';
      Result := Result + IntToStr(FFilesInfo[K].ID);
    end;
  end;

begin
  if not DBKernel.ProgramInDemoMode then
  begin
    if CharToInt(DBkernel.GetCodeChar(14)) <> CharToInt(DBkernel.GetCodeChar(7)) * CharToInt(DBkernel.GetCodeChar(9)) mod 15 then
      Exit;
  end;

  WorkQuery := GetQuery;
  try
    if FShowInfoType = SHOW_INFO_IDS then
    begin
      XCount := 0;
      LockImput;
      BtSave.Enabled := False;

      ProgressForm := nil;
      if VariousKeyWords(KeywordsMemo.Text, FFilesInfo.CommonKeyWords) then
        Inc(XCount);
      if not CompareGroups(FNowGroups, FOldGroups) then
        Inc(XCount);
      if not CommentMemo.readonly then
        Inc(XCount);
      if ReadCHLinks then
        Inc(XCount);

      if XCount > 0 then
      begin
        ProgressForm := GetProgressWindow;
        ProgressForm.OperationCount := XCount;
        ProgressForm.OperationPosition := 0;
        ProgressForm.OneOperation := False;
        ProgressForm.MaxPosCurrentOperation := FFilesInfo.Count;
        ProgressForm.XPosition := 0;
        ProgressForm.DoShow;
      end;

      // [BEGIN] Include Support
      if ReadCHInclude then
      begin
        _sqlexectext := Format('Update $DB$ Set Include = :Include Where ID in (%s)', [GenerateIDList]);
        SetSQL(WorkQuery, _sqlexectext);
        SetBoolParam(WorkQuery, 0, CbInclude.Checked);
        ExecSQL(WorkQuery);
        EventInfo.Include := CbInclude.Checked;
        for I := 0 to FFilesInfo.Count - 1 do
          DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_Include], EventInfo);
      end;// [END] Include Support

      // [BEGIN] Rating Support
      if not RatingEdit.Islayered then
      begin
        _sqlexectext := Format('Update $DB$ Set Rating = :Rating Where ID in (%s)', [GenerateIDList]);
        SetSQL(WorkQuery, _sqlexectext);
        SetIntParam(WorkQuery, 0, RatingEdit.Rating);
        ExecSQL(WorkQuery);
        EventInfo.Rating := RatingEdit.Rating;
        for I := 0 to FFilesInfo.Count - 1 do
          DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_Rating], EventInfo);
      end; // [END] Rating Support

      // [BEGIN] KeyWords Support
      if VariousKeyWords(KeywordsMemo.Text, FFilesInfo.CommonKeyWords) then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          KeyWords := FFilesInfo[I].KeyWords;
          ReplaceWords(FFilesInfo.CommonKeyWords, KeywordsMemo.Text, KeyWords);
          if VariousKeyWords(KeyWords, FFilesInfo[I].KeyWords) then
            AddQuery(List, KeyWords, FFilesInfo[I].ID);
        end;
        PackSQLList(List, VALUE_TYPE_KEYWORDS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          _sqlexectext := 'Update $DB$ Set KeyWords = ' + NormalizeDBString(List[I].Value)
            + ' Where ID in (' + IDs + ')';
          SetSQL(WorkQuery, _sqlexectext);
          ExecSQL(WorkQuery);
          EventInfo.KeyWords := List[I].Value;
          for J := 0 to Length(List[I].IDs) - 1 do
            DBKernel.DoIDEvent(Sender, List[I].IDs[J], [EventID_Param_KeyWords], EventInfo);
        end;
      end;// [END] KeyWords Support

      // [BEGIN] Groups Support
      CommonGroups := CodeGroups(FOldGroups);
      if not CompareGroups(FNowGroups, FOldGroups) then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          SGroups := FFilesInfo[I].Groups;
          ReplaceGroups(CommonGroups, CodeGroups(FNowGroups), SGroups);
          if not CompareGroups(SGroups, FFilesInfo[I].Groups) then
            AddQuery(List, SGroups, FFilesInfo[I].ID);
        end;

        PackSQLList(List, VALUE_TYPE_GROUPS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          _sqlexectext := 'Update $DB$ Set Groups = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
          WorkQuery.Close;
          SetSQL(WorkQuery, _sqlexectext);
          ExecSQL(WorkQuery);
          EventInfo.Groups := List[I].Value;
          for J := 0 to Length(List[I].IDs) - 1 do
            DBKernel.DoIDEvent(Sender, List[I].IDs[J], [EventID_Param_Groups], EventInfo);
        end;
      end; // [END] Groups Support

      // [BEGIN] Links Support
      if ReadCHLinks then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          SLinks := FFilesInfo[I].Links;
          SLinkInfo := ParseLinksInfo(SLinks);
          ReplaceLinks(ItemLinks, FPropertyLinks, SLinkInfo);
          SLinks := CodeLinksInfo(SLinkInfo);
          if not CompareLinks(SLinks, FFilesInfo[I].Links) then
            AddQuery(List, SLinks, FFilesInfo[I].ID);

        end;
        PackSQLList(List, VALUE_TYPE_LINKS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          _sqlexectext := 'Update $DB$ Set Links = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
          SetSQL(WorkQuery, _sqlexectext);
          ExecSQL(WorkQuery);
        end;
      end;
      // [END] Links Support

      // [BEGIN] Commnet Support
      if not CommentMemo.ReadOnly and (CommentMemo.Text <> FFilesInfo.CommonComments) then
      begin
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        _sqlexectext := 'Update $DB$ Set Comment = ' + NormalizeDBString(CommentMemo.Text) + ' Where ID in (';
        for I := 0 to FFilesInfo.Count - 1 do
          if I = 0 then
            _sqlexectext := _sqlexectext + IntToStr(FFilesInfo[I].ID)
          else
            _sqlexectext := _sqlexectext + ',' + IntToStr(FFilesInfo[I].ID);
        _sqlexectext := _sqlexectext + ')';
        SetSQL(WorkQuery, _sqlexectext);
        ExecSQL(WorkQuery);
        EventInfo.Comment := CommentMemo.Text;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_Comment], EventInfo);
        end;
      end;// [END] Commnet Support

      // [BEGIN] Date Support
      if DateEdit.Enabled then
      begin
        FQuery := GetQuery;
        try
          if not DateEdit.Checked then
          begin
            _sqlexectext := 'Update $DB$ Set IsDate = :IsDate Where ';
            for I := 0 to FFilesInfo.Count - 1 do
              if I = 0 then
                _sqlexectext := _sqlexectext + IntToStr(FFilesInfo[I].ID)
              else
                _sqlexectext := _sqlexectext + ',' + IntToStr(FFilesInfo[I].ID);
            _sqlexectext := _sqlexectext + ')';
            FQuery.Active := False;
            SetSQL(WorkQuery, _sqlexectext);
            SetBoolParam(FQuery, 0, False);
            ExecSQL(FQuery);
            EventInfo.IsDate := False;
            for I := 0 to FFilesInfo.Count - 1 do
              DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_IsDate], EventInfo);
          end else
          begin
            _sqlexectext := Format('Update $DB$ Set DateToAdd=:DateToAdd, IsDate=TRUE Where ID in (%s)', [GenerateIDList]);
            FQuery.Active := False;
            SetSQL(FQuery, _sqlexectext);
            SetDateParam(FQuery, 'DateToAdd', DateEdit.DateTime);
            ExecSQL(FQuery);
            EventInfo.Date := DateEdit.DateTime;
            EventInfo.IsDate := True;
            for I := 0 to FFilesInfo.Count - 1 do
              DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_Date, EventID_Param_IsDate], EventInfo);
          end;
        finally
          FreeDS(FQuery);
        end;
      end; // [END] Date Support

      // [BEGIN] Time Support
      if TimeEdit.Enabled then
      begin
        if not TimeEdit.Checked then
        begin
          _sqlexectext := Format('Update $DB$ Set IsTime = :IsTime Where ID in (%s)', [GenerateIDList]);
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetBoolParam(WorkQuery, 0, False);
          ExecSQL(FQuery);
          EventInfo.IsTime := False;
          for I := 0 to FFilesInfo.Count - 1 do
            DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_IsTime], EventInfo);
        end
        else
        begin
          _sqlexectext := Format('Update $DB$ Set aTime = :aTime, IsTime = True Where ID in (%s)', [GenerateIDList]);
          WorkQuery.Active := False;
          SetSQL(WorkQuery, _sqlexectext);
          SetDateParam(WorkQuery, 'aTime', TimeOf(TimeEdit.Time));
          ExecSQL(FQuery);
          EventInfo.Time := TimeEdit.Time;
          EventInfo.IsTime := True;
          for I := 0 to FFilesInfo.Count - 1 do
            DBKernel.DoIDEvent(Sender, FFilesInfo[I].ID, [EventID_Param_Time, EventID_Param_IsTime], EventInfo);
        end;
      end;// [END] Time Support

      R(ProgressForm);

      UnLockImput;
      BtSave.Enabled := True;
      if Visible then
      begin
        SetLength(IDArray, FFilesInfo.Count);
        for I := 0 to FFilesInfo.Count - 1 do
          IDArray[I] := FFilesInfo[I].ID;

        ExecuteEx(IDArray);
      end;
      Exit;
    end;

    if FShowInfoType = SHOW_INFO_ID then
    begin
      _sqlexectext := 'Update $DB$';
      _sqlexectext := _sqlexectext + ' set Comment=' + NormalizeDBString(CommentMemo.Text)
        + ' , KeyWords=' + NormalizeDBString(KeyWordsMemo.Text)
        + ' , Rating = ' + Inttostr(RatingEdit.Rating)
        + ' , Owner = ' + NormalizeDBString(OwnerMemo.Text)
        + ' , Collection = ' + NormalizeDBString(CollectionMemo.Text)
        + ', DateToAdd = :Date, IsDate = :IsDate, Groups = ' + NormalizeDBString(CodeGroups(FNowGroups))
        + ', Include = :Include, Links = ' + NormalizeDBString(CodeLinksInfo(FPropertyLinks))
        + ', aTime = :aTime , IsTime = :IsTime';
      _sqlexectext := _sqlexectext + ' Where ID=:ID';
      WorkQuery.Active := False;
      SetSQL(WorkQuery, _sqlexectext);
      SetDateParam(WorkQuery, 'Date', DateEdit.DateTime);
      SetBoolParam(WorkQuery, 1, DateEdit.Checked);
      SetBoolParam(WorkQuery, 2, CbInclude.Checked);
      SetDateParam(WorkQuery, 'aTime', TimeOf(TimeEdit.Time));
      SetBoolParam(WorkQuery, 4, TimeEdit.Checked);
      SetIntParam(WorkQuery, 5, ImageId); // Must be LAST PARAM!

      ExecSQL(WorkQuery);
      EventInfo.Comment := CommentMemo.Text;
      EventInfo.KeyWords := KeyWordsMemo.Text;
      EventInfo.Rating := RatingEdit.Rating;
      EventInfo.Owner := OwnerMemo.Text;
      EventInfo.Collection := CollectionMemo.Text;
      EventInfo.Groups := CodeGroups(FNowGroups);
      EventInfo.Include := CbInclude.Checked;
      EventInfo.Date := DateEdit.DateTime;
      EventInfo.Time := TimeOf(TimeEdit.Time);
      EventInfo.IsDate := not DateEdit.Checked;
      EventInfo.IsTime := not TimeEdit.Checked;
      DBKernel.DoIDEvent(Sender, ImageId, [EventID_Param_Comment, EventID_Param_KeyWords, EventID_Param_Rating,
        EventID_Param_Owner, EventID_Param_Collection, EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate,
        EventID_Param_IsTime, EventID_Param_Groups, EventID_Param_Include], EventInfo);
    end else
    begin
      if UpdaterDB = nil then
        UpdaterDB := TUpdaterDB.Create;
      UpdaterDB.AddFile(FileName);
    end;
  finally
    FreeDS(WorkQuery);
  end;
end;

procedure TPropertiesForm.Copy1Click(Sender: TObject);
var
  I: Integer;
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
    if FShowInfoType <> SHOW_INFO_IDS then
      FileList.Add(FileName)
    else begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FileExists(FFilesInfo[I].FileName) then
          FileList.Add(FFilesInfo[I].FileName);
    end;
    Copy_Move(True, FileList);
  finally
    FileList.Free;
  end;
end;

procedure TPropertiesForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PWideChar(LabelPath.Text), nil, nil, SW_NORMAL);
end;

procedure TPropertiesForm.Show1Click(Sender: TObject);
var
  Info: TRecordsInfo;
begin
  DBPopupMenuInfoToRecordsInfo(FFilesInfo, Info);
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.Execute(Sender, Info);
  Viewer.Show;
end;

procedure TPropertiesForm.Searchforit1Click(Sender: TObject);
var
  PR : TImageDBRecordA;
  NewSearch : TSearchForm;
begin
  if FShowInfoType = SHOW_INFO_ID then
  begin
    if FileExists(FileName) then
    begin
      NewSearch := SearchManager.NewSearch;
      NewSearch.Show;
      NewSearch.SearchEdit.Text := Inttostr(ImageId) + '$';
      NewSearch.DoSearchNow(nil);
    end else
    begin
      Pr := GetImageIDW(FileName, True);
      if Pr.Count <> 0 then
        Execute(Pr.Ids[0])
      else
        MessageBoxDB(Handle, L('Unable to find this image!'), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
    end;
  end
  else begin
    Pr := GetImageIDW(FileName, True);
    if Pr.Count <> 0 then
      Execute(Pr.Ids[0])
    else
      MessageBoxDB(Handle, L('Unable to find this image!'), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
end;

procedure TPropertiesForm.ExecuteFileNoEx(FileName: string);
var
  ExifData: TExifData;
  RAWExif: TRAWExif;
  Options: TPropertyLoadImageThreadOptions;
  Rec: TDBPopupMenuInfoRecord;
begin
  if not Fileexists(FileName) then
    Exit;
  if not ExtInMask(SupportedExt, Getext(FileName)) then
    Exit;
  if FSaving then
  begin
    SetFocus;
    Exit;
  end;
  DoProcessPath(FileName);
  SetLength(FPropertyLinks, 0);
  SetLength(FNowGroups, 0);

  ExifData := TExifData.Create;
  try
    FFileDate := 0;
    try
      ExifData.LoadFromJPEG(FileName);
      if not ExifData.Empty then
      begin
        FFileDate := DateOf(ExifData.DateTime);
        FFileTime := TimeOf(ExifData.DateTime);
      end;
    except
      EventLog('Error reading EXIF in file "' + FileName + '"');
    end;
  finally
    F(ExifData);
  end;

  FDateTimeInFileExists := FFileDate <> 0;
  if not FDateTimeInFileExists then
  begin
    if RAWImage.IsRAWSupport and RAWImage.IsRAWImageFile(FileName) then
    begin
      RAWExif := ReadRAWExif(FileName);
      try
        if RAWExif.IsEXIF then
        begin
          FDateTimeInFileExists := True;
          FFileDate := DateOf(RAWExif.TimeStamp);
          FFileTime := TimeOf(RAWExif.TimeStamp);
        end;
      finally
        F(RAWExif);
      end;
    end;
  end;
  R(EditLinkForm);
  ResetBold;
  FCurrentPass := '';
  PcMain.ActivePageIndex := 0;
  Caption := L('Properties') + ' - ' + ExtractFileName(FileName);
  No_file := False;

  FShowInfoType := SHOW_INFO_FILE_NAME;
  DBitem1.Visible := False;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  Editing_info := False;

  Rec := TDBPopupMenuInfoRecord.Create;
  Rec.FileName := FileName;
  FFilesInfo.Clear;
  FFilesInfo.Add(Rec);
  OwnerMemo.readonly := True;

  RatingEdit.Enabled := False;
  RatingEdit.Islayered := False;
  CommentMemo.PopupMenu := nil;

  ResetBold;

  LabelName.Text := ExtractFileName(FileName);
  LabelPath.Text := LongFileName(FileName);
  LabelComment.Hide;
  CommentMemo.Hide;
  CommentMemo.readonly := True;
  CommentMemo.Cursor := CrDefault;
  RatingEdit.Rating := 0;
  Image2.Visible := False;
  CollectionMemo.Text := L('Not avaliable');
  CollectionMemo.readonly := True;
  IDLabel.Text := L('Not avaliable');
  KeyWordsMemo.Text := L('Not avaliable');
  OwnerMemo.Text := L('Not avaliable');
  KeyWordsMemo.readonly := True;

  DateEdit.Enabled := False;
  if FFileDate <> 0 then
    DateEdit.DateTime := FFileDate
  else
    DateEdit.DateTime := Now;
  TimeEdit.Enabled := False;
  TimeEdit.Time := FFileTime;

  DateEdit.Checked := FDateTimeInFileExists;
  TimeEdit.Checked := FDateTimeInFileExists;

  SID := GetGUID;
  Options.FileName := FileName;
  Options.OnDone := OnDoneLoadingImage;
  Options.SID := SID;
  Options.Owner := Self;

  ImageLoadingFile.Visible := True;
  TPropertyLoadImageThread.Create(Options);

  WidthMemo.Text := L('Loading...');
  HeightMemo.Text := L('Loading...');

  SizeLabel.Text := SizeInTextA(GetFileSize(FileName));
  BtSave.Caption := L('Add file');
  BtnFind.Visible := True;

  Show;
end;

procedure TPropertiesForm.BeginAdding(Sender: TObject);
begin
  Image1DblClick(Sender);
  BtSave.Enabled := False;
  Adding_now := True;
end;

procedure TPropertiesForm.EndAdding(Sender: TObject);
var
  PR : TImageDBRecordA;
begin
  Adding_now := False;
  Pr := GetimageIDW(FileName, False);
  if Pr.Count <> 0 then
    Execute(Pr.Ids[0])
  else
    MessageBoxDB(Handle, L('Unable to add this image!'), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TPropertiesForm.ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
var
  I, ID_: Integer;
begin
  if ID = -2 then
    Exit;
  if Visible then
  begin
    case FShowInfoType of
      SHOW_INFO_ID:
        begin
          if EventID_Param_Delete in Params then
          begin
            Close;
            Exit;
          end;
          if EventID_Param_GroupsChanged in Params then
            Exit;

          if Id = ImageId then
            Execute(ID);
        end;
      SHOW_INFO_IDS:
        begin
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID = ID then
              Image2.Visible := True;
        end;
      SHOW_INFO_FILE_NAME:
        begin
          if (AnsiLowerCase(Value.NewName) = AnsiLowerCase(FileName)) and FileExists(Value.NewName) then
          begin
            ID_ := GetIdByFileName(FileName);
            if ID_ = 0 then
              ExecuteFileNoEx(Value.NewName)
            else
              Execute(ID_);
          end;
          if (AnsiLowerCase(Value.name) = AnsiLowerCase(FileName)) then
            if FileExists(Value.NewName) and not FileExists(Value.name) then
              ExecuteFileNoEx(Value.NewName)
        end;
    end;
  end;
end;

procedure TPropertiesForm.PmItemPopup(Sender: TObject);
begin
  Shell1.Visible := FileExists(FileName);
  if FShowInfoType <> SHOW_INFO_IDS then
    Show1.Visible := FileExists(FileName);
  if FShowInfoType <> SHOW_INFO_IDS then
    Show1.Visible := True;
  Copy1.Visible := FileExists(FileName);
  if FShowInfoType = SHOW_INFO_IDS then
    Copy1.Visible := True;
  DBItem1.Clear;
  FFilesInfo.AttrExists := False;
  TDBPopupMenu.Instance.AddDBContMenu(DBItem1, FFilesInfo);
end;

procedure TPropertiesForm.FormDestroy(Sender: TObject);
begin
  LinkDropFiles.Free;
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;
  DBKernel.UnRegisterForm(Self);
  F(FFilesInfo);
  FreeGroups(RegGroups);
  FreeGroups(FShowenRegGroups);
end;

procedure TPropertiesForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if not Active then
    Exit;

  if Msg.Message = WM_KEYDOWN then
  begin
    if Msg.WParam = VK_ESCAPE then
      Close;
  end;

  if (Msg.Hwnd = DateEdit.Handle) or (Msg.Hwnd = TimeEdit.Handle) then
  begin
    if Msg.Message = WM_LBUTTONDOWN then
      CommentMemoChange(Self);

  end;
end;

procedure TPropertiesForm.ReloadGroups;
var
  I: Integer;
begin
  LstCurrentGroups.Clear;
  for I := 0 to Length(FNowGroups) - 1 do
    LstCurrentGroups.Items.Add(FNowGroups[I].GroupName);
end;

procedure TPropertiesForm.ComboBox1_KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TPropertiesForm.ExecuteEx(IDs: TArInteger);
var
  B: Graphics.TBitmap;
  S, SQL: string;
  FirstID: Boolean;
  I, N, M, ALeft, Num, Len, K: Integer;
  Size: Int64;
  Ico: TIcon;
  Width, Height: Integer;
  DirectoryList: TStringList;
  WidthList, HeightList: TList64;
  MenuRecord: TDBPopupMenuInfoRecord;
  WorkQuery: TDataSet;
const
  AllocBy = 300;

begin
  if FSaving then
  begin
    SetFocus;
    Exit;
  end;
  R(EditLinkForm);
  ResetBold;

  DirectoryList := TStringList.Create;
  WidthList := TList64.Create;
  HeightList := TList64.Create;
  try

  CbInclude.AllowGrayed := True;
  PcMain.ActivePageIndex := 0;
  if Length(IDs) = 0 then
    Exit;
  BtSave.Caption := L('Save');
  Image2.Visible := False;
  DateEdit.Enabled := True;
  TimeEdit.Enabled := True;
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  Editing_info := True;

  FShowInfoType := SHOW_INFO_IDS;

  B := TBitmap.Create;
  try
    B.Width := 100;
    B.Height := 100;
    B.PixelFormat := Pf24bit;
    B.Canvas.Brush.Color := ClBtnFace;
    B.Canvas.Pen.Color := RGB(Round(GetRValue(ColorToRGB(ClBtnFace)) * 0.8),
      Round(GetGValue(ColorToRGB(ClBtnFace)) * 0.8), Round(GetBValue(ColorToRGB(ClBtnFace)) * 0.8));
    B.Canvas.Rectangle(0, 0, 100, 100);
    Ico := TIcon.Create;
    try
      Ico.Handle := UnitDBKernel.Icons[DB_IC_MANY_FILES + 1];
      B.Canvas.Draw(100 div 2 - Ico.Width div 2, 100 div 2 - Ico.Height div 2, Ico);
    finally
      Ico.Free;
    end;
    Image1.Picture.Graphic := B;
  finally
    B.Free;
  end;

  WorkQuery := GetQuery;
  try
    Size := 0;
    N := Trunc(Length(IDs) / AllocBy);
    if Length(IDs) / AllocBy - N > 0 then
      Inc(N);
    ALeft := Length(IDs);
    for K := 1 to N do
    begin
      M := Min(ALeft, Min(ALeft, AllocBy));

      FirstID := True;
      SQL := 'Select ID, FFileName, Comment, Owner, Collection, Rotated, Access, Rating, DateToAdd, aTime, IsDate, IsTime, Groups, FileSize, KeyWords, Width, Height, Thum, Include, Links, Attr, StrTh FROM $DB$ Where ID in (';
      for I := 1 to M do
      begin
        Dec(ALeft);
        Num := I - 1 + AllocBy * (K - 1);

        if FirstID then
        begin
          SQL := SQL + ' ' + Inttostr(IDs[Num]) + ' ';
          FirstID := False;
        end
        else
          SQL := SQL + ' , ' + Inttostr(IDs[Num]) + ' ';
      end;
      SQL := SQL + ')';

      SetSQL(WorkQuery, SQL);
      try
        WorkQuery.Active := True;
      except
        on e : Exception do
        begin
          MessageBoxDB(Handle, L('Unable to load info: ') +  e.Message, L('Error'), TD_BUTTON_OK,
            TD_ICON_ERROR);
          Exit;
        end;
      end;

      WorkQuery.First;
      FFilesInfo.Clear;
      for I := 0 to WorkQuery.RecordCount - 1 do
      begin
        MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(WorkQuery);
        MenuRecord.Selected := True;
        FFilesInfo.Add(MenuRecord);

        Size := Size + MenuRecord.FileSize;
        Width := WorkQuery.FieldByName('Width').AsInteger;
        Height := WorkQuery.FieldByName('Height').AsInteger;
        WidthList.Add(Width);
        HeightList.Add(Height);
        DirectoryList.Add(ExtractFileDir(MenuRecord.FileName));

        WorkQuery.Next;
      end;

    end;
  if FFilesInfo.Count = 0 then
  begin
    MessageBoxDB(Handle, L('Unable to load info: ') + L('No DB records found!'), L('Error'), TD_BUTTON_OK,
      TD_ICON_ERROR);
    Exit;
  end;
  if FFilesInfo.Count = 1 then
  begin
    Execute(ImageID);
    Exit;
  end;
  Editing_info := False;
  try
    Caption := L('Properties') + ' - ' + ExtractFileName(FFilesInfo[0].FileName) + L('...');
    SizeLAbel.Text := SizeInTextA(Size);
    OwnerMemo.Text := L('Not avaliable');
    CollectionMemo.Text := L('Not avaliable');
    OwnerMemo.readonly := True;
    CommentMemo.PopupMenu := nil;
    CollectionMemo.readonly := True;

    if FFilesInfo.IsVariousInclude then
      CbInclude.State := CbGrayed
    else
    begin
      if FFilesInfo[0].Include then
        CbInclude.State := CbChecked
      else
        CbInclude.State := CbUnChecked;
    end;

    if WidthList.HasVarValues then
      WidthMemo.Text := L('Width differens')
    else
      WidthMemo.Text := Format(L('All - %spx.'), [IntToStr(WidthList[0])]);

    if HeightList.HasVarValues then
      HeightMemo.Text := L('Height differens')
    else
      HeightMemo.Text := Format(L('All - %spx.'), [IntToStr(HeightList[0])]);

    LabelName.Text := L('Diffrent files');
    if IsVariousArStrings(DirectoryList) then
      LabelPath.Text := L('Different directories')
    else
    begin
      S := DirectoryList[0];
      UnFormatDir(S);
      LabelPath.Text := Format(L('All in %s'), [LongFileName(S)]);
    end;

    RatingEdit.Rating := FFilesInfo.StatRating;
    RatingEdit.Islayered := True;
    RatingEdit.Layered := 100;
    TimeEdit.Time := FFilesInfo.StatTime;
    DateEdit.DateTime := FFilesInfo.StatDate;

    DateEdit.Checked := FFilesInfo.StatIsDate or FFilesInfo.IsVariousDate;
    TimeEdit.Checked := FFilesInfo.StatIsTime or FFilesInfo.IsVariousDate;

    KeyWordsMemo.Text := FFilesInfo.CommonKeyWords;
    IDLabel.Text := Format(L('Selected %d items'), [FFilesInfo.Count]);
    CommentMemo.Cursor := CrDefault;

    if FFilesInfo.IsVariousComments then
    begin
      CommentMemo.readonly := True;
      CommentMemo.Cursor := CrHandPoint;
      CommentMemo.PopupMenu := PmComment;
    end;
    CommentMemo.Text := FFilesInfo.CommonComments;

    FNowGroups := UnitGroupsWork.EncodeGroups(FFilesInfo.CommonGroups);
    FOldGroups := CopyGroups(FNowGroups);

    ItemLinks := FFilesInfo.CommonLinks;
    FPropertyLinks := CopyLinksInfo(ItemLinks);

    ReloadGroups;
    DBItem1.Visible := True;
    FFilesInfo.IsListItem := False;
    CommentMemoChange(Self);
    BtnFind.Visible := False;
    ImageLoadingFile.Visible := False;
    finally
      F(DirectoryList);
      F(WidthList);
      F(HeightList);
    end;
    Show;
    SID := GetGUID;
  finally
    FreeDS(WorkQuery);
  end;
  finally
    Editing_info := True;
  end;
end;

procedure TPropertiesForm.FormShow(Sender: TObject);
begin
  BtDone.SetFocus;
end;

procedure TPropertiesForm.GroupsManager1Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TPropertiesForm.RatingEditMouseDown(Sender: TObject);
begin
  if RatingEdit.Islayered then
    RatingEdit.Islayered := False;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveWindowPos1.SavePosition;
  R(EditLinkForm);
  Hide;
  PropertyManager.RemoveProperty(Self);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataGroups);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  DBKernel.UnRegisterChangesIDbyID(Self,ChangedDBDataByID,ImageId);
  Release;
end;

procedure TPropertiesForm.Ratingnotsets1Click(Sender: TObject);
begin
  RatingEdit.Islayered := True;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PmRatingNotAvaliablePopup(Sender: TObject);
begin
  if FShowInfoType = SHOW_INFO_FILE_NAME then
  begin
    Ratingnotsets1.Visible := False;
    Exit;
  end;
  Ratingnotsets1.Visible := not RatingEdit.Islayered;
  if FShowInfoType <> SHOW_INFO_IDS then
    Ratingnotsets1.Visible := False;
  Ratingnotsets1.Visible := Ratingnotsets1.Visible and not FSaving;
end;

procedure TPropertiesForm.CommentMemoDblClick(Sender: TObject);
begin
  if FShowInfoType = SHOW_INFO_FILE_NAME then
    Exit;
  if not CommentMemo.readonly then
    Exit;
  CommentMemo.readonly := False;
  CommentMemo.Cursor := CrDefault;
  CommentMemo.Text := '';
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PmCommentPopup(Sender: TObject);
begin
  SetComent1.Visible := CommentMemo.readonly and (FShowInfoType = SHOW_INFO_FILE_NAME);
  Comentnotsets1.Visible := not CommentMemo.ReadOnly;
  SelectAll1.Visible := not CommentMemo.ReadOnly;
  Cut1.Visible := not CommentMemo.ReadOnly;
  Copy2.Visible := not CommentMemo.ReadOnly;
  Paste1.Visible := not CommentMemo.ReadOnly;
  Undo1.Visible := not CommentMemo.ReadOnly;
end;

procedure TPropertiesForm.Comentnotsets1Click(Sender: TObject);
begin
  CommentMemo.readonly := True;
  CommentMemo.Cursor := CrHandPoint;
  CommentMemo.Text := L('Different comments');
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.SelectAll1Click(Sender: TObject);
begin
  CommentMemo.SelectAll;
end;

procedure TPropertiesForm.Cut1Click(Sender: TObject);
begin
  CommentMemo.CutToClipboard;
end;

procedure TPropertiesForm.Copy2Click(Sender: TObject);
begin
  CommentMemo.CopyToClipboard;
end;

procedure TPropertiesForm.Paste1Click(Sender: TObject);
begin
  CommentMemo.PasteFromClipboard;
end;

procedure TPropertiesForm.Undo1Click(Sender: TObject);
begin
  CommentMemo.Undo;
end;

procedure TPropertiesForm.LoadLanguage;
begin
  Caption := L('Properties');
  LabelComment.Caption := L('Comments') + ':';
  LabelName1.Caption := L('Name') + ':';
  Label4.Caption := L('Full path') + ':';
  OwnerLabel.Caption := L('Owner') + ':';
  CollectionLabel.Caption := L('Collection') + ':';
  RatingLabel1.Caption := L('Rating') + ':';
  DateLabel1.Caption := L('Date') + ':';
  SizeLabel1.Caption := L('Size') + ':';
  WidthLabel.Caption := L('Width') + ':';
  Heightlabel.Caption := L('Height') + ':';
  IDLabel1.Caption := L('ID') + ':';
  LabelKeywords.Caption := L('Keywords') + ':';
  BtnFind.Caption := L('Find');
  BtSave.Caption := L('Save');
  BtDone.Caption := L('Cancel');
  Shell1.Caption := L('Execute');
  Show1.Caption := L('Show');
  Copy1.Caption := L('Copy');
  DBItem1.Caption := L('DB Item');
  Searchforit1.Caption := L('Find item');

  Ratingnotsets1.Caption := L('Rating not sets');
  SetComent1.Caption := L('Set comment');
  Comentnotsets1.Caption := L('Comment not exists');
  SelectAll1.Caption := L('Select all');
  Cut1.Caption := L('Cut');
  Copy2.Caption := L('Copy');
  Paste1.Caption := L('Paste');
  Undo1.Caption := L('Undo');
  PcMain.Pages[0].Caption := L('General');
  PcMain.Pages[1].Caption := L('Groups');
  PcMain.Pages[2].Caption := L('EXIF');
  PcMain.Pages[3].Caption := L('Gistogramm');
  PcMain.Pages[4].Caption := L('Additional');

  Label2.Caption := L('Gistogramm image') + ':';
  Label5.Caption := Format(L('Effective range: %d..%d'), [0, 0]);
  RgGistogrammChannel.Caption := L('Channel');
  RgGistogrammChannel.Items[0] := L('Gray');
  RgGistogrammChannel.Items[1] := L('Red channel');
  RgGistogrammChannel.Items[2] := L('Green channel');
  RgGistogrammChannel.Items[3] := L('Blue channel');
  CopyCurrent1.Caption := L('Copy line');
  CopyAll1.Caption := L('Copy all information');
  CbInclude.Caption := L('Include in base search');
  LbLinks.Caption := L('Links for photo(s)') + ':';
  Addnewlink1.Caption := L('Add link');

  Open1.Caption := L('Open');
  OpenFolder1.Caption := L('Open folder');
  Up1.Caption := L('Move up');
  Down1.Caption := L('Move down');
  Change1.Caption := L('Change');
  Delete1.Caption := L('Delete');
  BtnManageGroups.Caption := L('Manage');
  BtnNewGroup.Caption := L('New group');
  LbAvaliableGroups.Caption := L('Avaliable groups') + ':';
  LbCurrentGroups.Caption := L('Current groups') + ':';
  Clear1.Caption := L('Clear');
  MenuItem1.Caption := L('Delete');
  CreateGroup1.Caption := L('Create group');
  ChangeGroup1.Caption := L('Change group');
  GroupManeger1.Caption := L('Group manager');
  QuickInfo1.Caption := L('Info');
  SearchForGroup1.Caption := L('Search group photos');
  CbShowAllGroups.Caption := L('Show all groups');
  CbRemoveKeywordsForGroups.Caption := L('Remove unused keywords');
  MoveToGroup1.Caption := L('Move to group');

  LbGroupsEditInfo.Caption := L('Use button "-->" to add new groups or button "<--" to remove them');
  Cancel1.Caption := L('Cancel');
  AddImThProcessingImageAndAddOriginalToProcessingPhoto1.Caption := TEXT_MES_ADD_PROC_IMTH_AND_ADD_ORIG_TO_PROC_PHOTO;
  AddImThLink1.Caption := TEXT_MES_ADD_PROC_IMTH;
  AddOriginalImThAndAddProcessngToOriginalImTh1.Caption := TEXT_MES_ADD_ORIG_IMTH_AND_ADD_PROC_TO_ORIG_PHOTO;
  AddOriginalImTh1.Caption := TEXT_MES_ADD_ORIG_IMTH;
end;

procedure TPropertiesForm.PcMainChange(Sender: TObject);
var
  Options: TPropertyLoadGistogrammThreadOptions;
  NewTab: Integer;
begin
  NewTab := PcMain.ActivePageIndex;
  case NewTab of
    1:
      begin
        RecreateGroupsList;
      end;
    2:
      begin
        ReadExifData;
      end;
    3:
      begin
        RgGistogrammChannel.ItemIndex := 0;

        if not GistogrammData.Loaded then
        begin
          Options.FileName := FileName;
          Options.Owner := Self;
          Options.SID := SID;
          Options.OnDone := OnDoneLoadGistogrammData;
          TPropertyLoadGistogrammThread.Create(Options);
          OnDoneLoadGistogrammData(Self);
        end;
      end;
    4:
      begin
        ReadLinks;
      end;
  end;
end;

procedure TPropertiesForm.ReadExifData;
var
  ExifData: TExifData;
  I: Integer;
  RAWExif: TRAWExif;
  Orientation : Integer;

  procedure XInsert(Key, Value: string);
  begin
    if Value <> '' then
      VleEXIF.InsertRow(Key, Value, True);
  end;

  procedure XInsertInt(Key: string; Value: Integer);
  begin
    if Value <> 0 then
      VleEXIF.InsertRow(Key, IntToStr(Value), True);
  end;

  procedure XInsertFloat(Key: string; Value: Single);
  begin
    if Value <> 0 then
      VleEXIF.InsertRow(Key, FloatToStr(Value), True);
  end;

begin
  VleEXIF.Strings.Clear;

  if RAWImage.IsRAWSupport and RAWImage.IsRAWImageFile(FileName) then
  begin
    RAWExif := ReadRAWExif(FileName);
    try
      if RAWExif.IsEXIF then
      begin
        VleEXIF.InsertRow('RAW Info:', '', True);
        for I := 0 to RAWExif.Count - 1 do
          xInsert(Format('%s: ', [RAWExif[i].Description]), RAWExif[i].Value);
      end else
        VleEXIF.InsertRow('Info:', L('Exif header not found'), True);
    finally
      RAWExif.Free;
    end;
  end else
  begin
    ExifData := TExifData.Create;
    try
      try
        ExifData.LoadFromJPEG(FileName);
        if not ExifData.Empty then
        begin

          XInsert('Make: ', ExifData.CameraMake);
          XInsert('Model: ', ExifData.CameraModel);
          XInsert('Copyright: ', ExifData.Copyright);
          XInsert('Date and time: ', FormatDateTime('yyyy/mm/dd', ExifData.DateTime));
          XInsert('Description: ', ExifData.ImageDescription);
          XInsert('Software: ', ExifData.Software);
          Orientation := ExifOrientationToRatation(Ord(ExifData.Orientation));
          case Orientation of
            DB_IMAGE_ROTATE_0:
              XInsert('Orientation: ', L('Normal'));
            DB_IMAGE_ROTATE_90:
              XInsert('Orientation: ', L('Right'));
            DB_IMAGE_ROTATE_270:
              XInsert('Orientation: ', L('Left'));
            DB_IMAGE_ROTATE_180:
              XInsert('Orientation: ', L('180 grad.'));
          end;

          XInsert('Exposure: ', ExifData.ExposureTime.AsString);
          XInsert('ISO: ', ExifData.ISOSpeedRatings.AsString);
          XInsert('Focal length: ', ExifData.FocalLength.AsString);
          XInsert('F number: ', ExifData.FNumber.AsString);
          if ExifData.Flash.Fired then
            XInsert('Flash: ', L('On'))
          else
            XInsert('Flash: ', L('Off'));

          XInsert('Width: ', ExifData.ExifImageWidth.AsString + '.px');
          XInsert('Height: ', ExifData.ExifImageheight.AsString + '.px');
        end
        else
          VleEXIF.InsertRow('Info:', L('Exif header not found.'), True);
      except
        on e : Exception do
          Eventlog(e.Message);
      end;
    finally
      F(ExifData);
    end;
  end;
end;

procedure TPropertiesForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TPropertiesForm.RgGistogrammChannelClick(Sender: TObject);
begin
  case RgGistogrammChannel.ItemIndex of
    0:
      DgGistogramm.ColorTo := $FFFFFF;
    1:
      DgGistogramm.ColorTo := $0000FF;
    2:
      DgGistogramm.ColorTo := $00FF00;
    3:
      DgGistogramm.ColorTo := $FF0000;
  end;
  OnDoneLoadGistogrammData(Self);
end;

procedure TPropertiesForm.ResetBold;
begin
  UpdateControlFont(LabelComment, False);
  UpdateControlFont(OwnerLabel, False);
  UpdateControlFont(CollectionLabel, False);
  UpdateControlFont(RatingLabel1, False);
  UpdateControlFont(DateLabel1, False);
  UpdateControlFont(TimeLabel, False);
  UpdateControlFont(LabelKeywords, False);
  UpdateControlFont(CbInclude, False);
  UpdateControlFont(LbLinks, False);
end;

procedure TPropertiesForm.VleExifContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ACol, ARow: Integer;
begin
  VleExif.MouseToCell(MousePos.X, MousePos.Y, ACol, ARow);
  if (ACol < 0) or (ARow < 0) then
    Exit;

  MousePos := VleExif.ClientToScreen(MousePos);
  CopyEXIFPopupMenu.Tag := ARow;
  CopyEXIFPopupMenu.Popup(MousePos.X, MousePos.Y);
end;

procedure TPropertiesForm.CopyCurrent1Click(Sender: TObject);
begin
  Clipboard.AsText := VleExif.Cells[0, CopyEXIFPopupMenu.Tag] + ' ' + VleExif.Cells[1, CopyEXIFPopupMenu.Tag];
end;

procedure TPropertiesForm.CopyAll1Click(Sender: TObject);
begin
  Clipboard.AsText := VleExif.Strings.Text;
end;

procedure TPropertiesForm.ReadLinks;
var
  LI: TLinksInfo;
  I: Integer;
  Icon: TIcon;
begin
  for I := 0 to Length(Links) - 1 do
    Links[I].Free;
  LI := CopyLinksInfo(FPropertyLinks);
  SetLength(Links, Length(LI));
  for I := 0 to Length(LI) - 1 do
  begin
    Links[I] := TWebLink.Create(LinksScrollBox);
    Links[I].Width := 0;
    Links[I].Left := 10;
    Links[I].Height := 19;
    Links[I].Top := I * (19 + 5) + 10;
    Links[I].Parent := LinksScrollBox;
    if LI[I].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT <> 0 then
      Links[I].Font.Color := ColorDiv2(ClBtnFace, ClWindowText)
    else
      Links[I].Font.Color := ClWindowText;

    Links[I].Color := LinksScrollBox.Color;
    Links[I].Width := LinksScrollBox.Width - 10;
    Links[I].Text := LI[I].LinkName;
    Links[I].Tag := I;
    Links[I].OnClick := LinkClick;
    Links[I].OnContextPopup := LinkOnPopup;
    Links[I].ImageCanRegenerate := True;
    //
    Icon := TIcon.Create;

    case LI[I].LinkType of
      LINK_TYPE_ID:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_SLIDE_SHOW + 1];
      LINK_TYPE_ID_EXT:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_NOTES + 1];
      LINK_TYPE_IMAGE:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_DESKTOP + 1];
      LINK_TYPE_FILE:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_SHELL + 1];
      LINK_TYPE_FOLDER:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_DIRECTORY + 1];
      LINK_TYPE_TXT:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_TEXT_FILE + 1];
      LINK_TYPE_HTML:
        Icon.Handle := UnitDBKernel.Icons[DB_IC_SLIDE_SHOW + 1];
    end;
    Links[I].Icon := Icon;
    Icon.Free;
    Links[I].Visible := True;
  end;
  CommentMemoChange(Self);
end;

procedure TPropertiesForm.Addnewlink1Click(Sender: TObject);
var
  LI: TLinksInfo;
begin
  LI := CopyLinksInfo(FPropertyLinks);
  EditLinkForm := AddNewLink(True, FPropertyLinks, SetLinkInfo, CloseEditLinkForm);
end;

procedure TPropertiesForm.LinkOnPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  Handled := True;
  PmLinks.Tag := TWebLink(Sender).Tag;
  MousePos := TWebLink(Sender).ClientToScreen(MousePos);
  PmLinks.Popup(MousePos.X, MousePos.Y);
end;

procedure TPropertiesForm.Delete1Click(Sender: TObject);
begin
  DeleteLinkAtPos(FPropertyLinks, PmLinks.Tag);
  ReadLinks;
end;

procedure TPropertiesForm.LinkClick(Sender: TObject);
var
  N: Integer;
  LI: TLinksInfo;
  TIRA: TImageDBRecordA;
  P: TPoint;
  S, DN: string;

  procedure ViewFile(FileName: string);
  begin
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    Viewer.ShowFile(FileName);
  end;

begin
  GetCursorPos(P);
  N := TWebLink(Sender).Tag;
  LI := CopyLinksInfo(FPropertyLinks);
  case LI[N].LinkType of
    LINK_TYPE_ID:
      ViewFile(GetFileNameById(StrToIntDef(LI[N].LinkValue, 0)));
    LINK_TYPE_ID_EXT:
      begin
        TIRA := GetimageIDTh(DeCodeExtID(LI[N].LinkValue));
        if TIRA.Count > 0 then
          ViewFile(TIRA.FileNames[0]);
      end;
    LINK_TYPE_IMAGE:
      ViewFile(LI[N].LinkValue);
    LINK_TYPE_FILE:
      begin
        S := GetDirectory(LI[N].LinkValue);
        ShellExecute(Handle, nil, PWideChar(LI[N].LinkValue), nil, PWideChar(S), SW_NORMAL);
      end;
    LINK_TYPE_FOLDER:
      begin
        DN := LI[N].LinkValue;
        UnFormatDir(DN);
        if (DN <> '') and not DirectoryExists(DN) then
        begin
          MessageBoxDB(Handle, Format(TEXT_MES_DIRECTORY_NOT_EXISTS_F, [DN]), TEXT_MES_WARNING, TD_BUTTON_OK,
            TD_ICON_WARNING);
          Exit;
        end;
        with ExplorerManager.NewExplorer(False) do
        begin
          SetPath(LI[N].LinkValue);
          Show;
          SetFocus;
        end;
      end;
    LINK_TYPE_TXT:
      DoHelpHint(LI[N].LinkName, LI[N].LinkValue, P, Links[N]);
    LINK_TYPE_HTML:
      ;
  end;
end;

procedure TPropertiesForm.PmLinksPopup(Sender: TObject);
var
  MenuInfo: TDBPopupMenuInfo;
  N, ID: Integer;
  LI: TLinksInfo;

  procedure DoExit;
  begin
    if LI[N].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT <> 0 then
    begin
      Open1.Visible := False;
      OpenFolder1.Visible := False;
      IDMenu1.Visible := False;
      Up1.Visible := False;
      Down1.Visible := False;
    end;
    Change1.Visible := Change1.Visible and not FSaving;
    Delete1.Visible := Delete1.Visible and not FSaving;
    Up1.Visible := Up1.Visible and not FSaving;
    Down1.Visible := Down1.Visible and not FSaving;

  end;

begin

  Change1.Visible := EditLinkForm = nil;
  Delete1.Visible := EditLinkForm = nil;
  N := PmLinks.Tag;
  Up1.Visible := N <> 0;
  Down1.Visible := N <> Length(FPropertyLinks) - 1;
  LI := CopyLinksInfo(FPropertyLinks);

  case LI[N].LinkType of
    LINK_TYPE_ID:
      begin
        Open1.Visible := True;
        OpenFolder1.Visible := True;
      end;
    LINK_TYPE_ID_EXT:
      begin
        Open1.Visible := True;
        OpenFolder1.Visible := True;
      end;
    LINK_TYPE_IMAGE:
      begin
        Open1.Visible := True;
        OpenFolder1.Visible := True;
      end;
    LINK_TYPE_FILE:
      begin
        Open1.Visible := True;
        OpenFolder1.Visible := True;
      end;
    LINK_TYPE_FOLDER:
      begin
        Open1.Visible := False;
        OpenFolder1.Visible := True;
      end;
    LINK_TYPE_TXT:
      begin
        Open1.Visible := True;
        OpenFolder1.Visible := False;
      end;
    LINK_TYPE_HTML:
      begin
        Open1.Visible := False;
        OpenFolder1.Visible := False;
      end;
  end;

  if LI[N].LinkType = LINK_TYPE_ID then
    if LI[N].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
    begin
      IDMenu1.Visible := True;
      ID := StrToIntDef(LI[N].LinkValue, 0);
      MenuInfo := GetMenuInfoByID(ID);
      MenuInfo.IsPlusMenu := False;
      MenuInfo.IsListItem := False;
      MenuInfo.AttrExists := False;
      IDMenu1.Caption := Format(TEXT_MES_DBITEM_FORMAT, [Inttostr(ID)]);
      TDBPopupMenu.Instance.AddDBContMenu(IDMenu1, MenuInfo);
      DoExit;
      Exit;
    end;
  if LI[N].LinkType = LINK_TYPE_ID_EXT then
    if LI[N].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
    begin
      IDMenu1.Visible := True;
      MenuInfo := GetMenuInfoByStrTh(DeCodeExtID(LI[N].LinkValue));
      MenuInfo.IsPlusMenu := False;
      MenuInfo.IsListItem := False;
      MenuInfo.AttrExists := False;
      if MenuInfo.Count > 0 then
        IDMenu1.Caption := Format(TEXT_MES_DBITEM_FORMAT, [Inttostr(MenuInfo[0].ID)])
      else
        IDMenu1.Caption := Format(TEXT_MES_DBITEM_FORMAT, [Inttostr(0)]);
      TDBPopupMenu.Instance.AddDBContMenu(IDMenu1, MenuInfo);
      DoExit;
      Exit;
    end;
  IDMenu1.Visible := False;
  DoExit;
end;

procedure TPropertiesForm.Change1Click(Sender: TObject);
var
  LI: TLinksInfo;
  I, N: Integer;
begin
  N := PmLinks.Tag;
  LI := CopyLinksInfo(FPropertyLinks);
  for I := 0 to Length(LI) - 1 do
    LI[I].Tag := LI[I].Tag or LINK_TAG_NONE;

  LI[N].Tag := LI[N].Tag or LINK_TAG_SELECTED;
  EditLinkForm := AddNewLink(False, LI, SetLinkInfo, CloseEditLinkForm);
end;

procedure TPropertiesForm.CloseEditLinkForm(Form: TForm; ID: String);
begin
  R(EditLinkForm);
end;

procedure TPropertiesForm.PmAddLinkPopup(Sender: TObject);
begin
  AddNewlink1.Visible := (EditLinkForm = nil) and not FSaving;
end;

procedure TPropertiesForm.SetLinkInfo(Sender: TObject; ID: String;
  Info: TLinkInfo; N: integer; Action : Integer);
begin
  case Action of
    LINK_PROC_ACTION_ADD:
      begin
        SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
        FPropertyLinks[Length(FPropertyLinks) - 1] := Info;
      end;
    LINK_PROC_ACTION_MODIFY:
      begin
        FPropertyLinks[N] := Info;
      end;
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.Open1Click(Sender: TObject);
var
  N: Integer;
begin
  N := PmLinks.Tag;
  Links[N].OnClick(Links[N]);
end;

procedure TPropertiesForm.OpenFolder1Click(Sender: TObject);
var
  N: Integer;
  FN, DN: string;
  TIRA: TImageDBRecordA;
begin
  N := PmLinks.Tag;
  DN := '';
  FN := '';
  case FPropertyLinks[N].LinkType of
    LINK_TYPE_ID:
      FN := GetFileNameById(StrToIntDef(FPropertyLinks[N].LinkValue, 0));
    LINK_TYPE_ID_EXT:
      begin
        TIRA := GetImageIDTh(DeCodeExtID(FPropertyLinks[N].LinkValue));
        if TIRA.Count > 0 then
          FN := TIRA.FileNames[0];
      end;
    LINK_TYPE_IMAGE:
      FN := FPropertyLinks[N].LinkValue;
    LINK_TYPE_FILE:
      FN := FPropertyLinks[N].LinkValue;
    LINK_TYPE_FOLDER:
      DN := FPropertyLinks[N].LinkValue;
    LINK_TYPE_TXT:
      Exit;
    LINK_TYPE_HTML:
      Exit;
  else
    Exit;
  end;
  if DN = '' then
    DN := GetDirectory(FN);
  UnFormatDir(DN);
  if (DN <> '') and not DirectoryExists(DN) then
  begin
    MessageBoxDB(Handle, Format(TEXT_MES_DIRECTORY_NOT_EXISTS_F, [DN]), L('Warning'), TD_BUTTON_OK,
      TD_ICON_WARNING);
    Exit;
  end;
  with ExplorerManager.NewExplorer(False) do
  begin
    if FN <> '' then
      SetOldPath(FN);
    SetPath(DN);
    Show;
    SetFocus;
  end;
end;

procedure TPropertiesForm.Up1Click(Sender: TObject);
var
  Temp: TLinkInfo;
  N: Integer;
begin
  N := PmLinks.Tag;
  Temp := FPropertyLinks[N - 1];
  FPropertyLinks[N - 1] := FPropertyLinks[N];
  FPropertyLinks[N] := Temp;
  ReadLinks;
end;

procedure TPropertiesForm.Down1Click(Sender: TObject);
var
  Temp: TLinkInfo;
  N: Integer;
begin
  N := PmLinks.Tag;
  Temp := FPropertyLinks[N + 1];
  FPropertyLinks[N + 1] := FPropertyLinks[N];
  FPropertyLinks[N] := Temp;
  ReadLinks;
end;

procedure TPropertiesForm.BtnManageGroupsClick(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TPropertiesForm.BtnNewGroupClick(Sender: TObject);
begin
  CreateNewGroupDialog;
end;

procedure TPropertiesForm.RecreateGroupsList;
var
  I, Size: Integer;
  SmallB, B: TBitmap;
begin
  FreeGroups(RegGroups);
  FreeGroups(FShowenRegGroups);
  RegGroups := GetRegisterGroupList(True);
  RegGroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    SmallB.Width := 16;
    SmallB.Height := 18;
    SmallB.Canvas.Pen.Color := ClBtnFace;
    SmallB.Canvas.Brush.Color := ClBtnFace;
    SmallB.Canvas.Rectangle(0, 0, 16, 18);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
    RegGroupsImageList.Add(SmallB, nil);
  finally
    SmallB.Free;
  end;

  LstAvaliableGroups.Items.BeginUpdate;
  try
    LstAvaliableGroups.Clear;
    for I := 0 to Length(RegGroups) - 1 do
    begin
      SmallB := TBitmap.Create;
      try
        SmallB.PixelFormat := pf24bit;
        SmallB.Canvas.Brush.Color := ClBtnFace;
        if RegGroups[I].GroupImage <> nil then
          if not RegGroups[I].GroupImage.Empty then
          begin
            B := TBitmap.Create;
            try
              B.PixelFormat := Pf24bit;
              Size := Max(RegGroups[I].GroupImage.Width, RegGroups[I].GroupImage.Height);
              B.Canvas.Brush.Color := ClBtnFace;
              B.Canvas.Pen.Color := ClBtnFace;
              B.Width := Size;
              B.Height := Size;
              B.Canvas.Rectangle(0, 0, Size, Size);
              B.Canvas.Draw(B.Width div 2 - RegGroups[I].GroupImage.Width div 2,
                B.Height div 2 - RegGroups[I].GroupImage.Height div 2, RegGroups[I].GroupImage);
              DoResize(16, 16, B, SmallB);
            finally
              B.Free;
            end;
            SmallB.Height := 18;
          end;
        RegGroupsImageList.Add(SmallB, nil);
        if RegGroups[I].IncludeInQuickList or CbShowAllGroups.Checked then
        begin
          UnitGroupsWork.AddGroupToGroups(FShowenRegGroups, RegGroups[I]);
          LstAvaliableGroups.Items.Add(RegGroups[I].GroupName);
        end;
      finally
        SmallB.Free;
      end;
    end;
  finally
    LstAvaliableGroups.Items.EndUpdate;
  end;
  LstCurrentGroups.Refresh;
end;

procedure TPropertiesForm.LstAvaliableGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  N, I: Integer;
  XNewGroups: TGroups;

  function NewGroup(GroupCode: string): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to Length(XNewGroups) - 1 do
      if XNewGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

  function GroupExists(GroupCode: string): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to Length(FNowGroups) - 1 do
      if FNowGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if FShowInfoType = SHOW_INFO_FILE_NAME then
    Exit;
  if Control = LstCurrentGroups then
  begin
    XNewGroups := CopyGroups(FNowGroups);
    RemoveGroupsFromGroups(XNewGroups, FOldGroups);
  end else
  begin
    XNewGroups := CopyGroups(FOldGroups);
    RemoveGroupsFromGroups(XNewGroups, FNowGroups);
  end;
  try
    if index = -1 then
      Exit;
    with (Control as TListBox).Canvas do
    begin
      FillRect(Rect);
      N := -1;
      if Control = LstCurrentGroups then
      begin
        for I := 0 to Length(RegGroups) - 1 do
        begin
          if RegGroups[I].GroupCode = FNowGroups[index].GroupCode then
          begin
            N := I + 1;
            Break;
          end;
        end
      end else
      begin
        for I := 0 to Length(RegGroups) - 1 do
        begin
          if RegGroups[I].GroupName = (Control as TListBox).Items[index] then
          begin
            N := I + 1;
            Break;
          end;
        end
      end;

      RegGroupsImageList.Draw((Control as TListBox).Canvas, Rect.Left + 2, Rect.Top + 2, Max(0, N));
      if N = -1 then
      begin
        DrawIconEx((Control as TListBox).Canvas.Handle, Rect.Left + 10, Rect.Top + 8,
          UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 8, 8, 0, 0, DI_NORMAL);
      end;
      if Control = LstCurrentGroups then
        if NewGroup(FNowGroups[index].GroupCode) then
          (Control as TListBox).Canvas.Font.Style := (Control as TListBox).Canvas.Font.Style + [FsBold]
        else
          (Control as TListBox).Canvas.Font.Style := (Control as TListBox).Canvas.Font.Style - [FsBold];

      if Control = LstAvaliableGroups then
        if N > -1 then
          if NewGroup(RegGroups[N - 1].GroupCode) then
            (Control as TListBox).Canvas.Font.Style := (Control as TListBox).Canvas.Font.Style + [FsBold]
          else
          begin
            if GroupExists(FShowenRegGroups[index].GroupCode) then
              (Control as TListBox).Canvas.Font.Color := ColorDiv2(clWindowText, clWindow)
            else
              (Control as TListBox).Canvas.Font.Color := clWindowText;

            (Control as TListBox).Canvas.Font.Style := (Control as TListBox).Canvas.Font.Style - [FsBold];
          end;

      TextOut(Rect.Left + 21, Rect.Top + 3, (Control as TListBox).Items[index]);
    end;
  except
    on E: Exception do
      EventLog(':TPropertiesForm.ListBox2DrawItem() throw exception: ' + E.message);
  end;
end;

procedure TPropertiesForm.lstCurrentGroupsDblClick(Sender: TObject);
var
  I: Integer;
  Group: TGroup;
begin
  if FSaving then
    Exit;
  for I := 0 to (Sender as TListBox).Items.Count - 1 do
    if (Sender as TListBox).Selected[I] then
    begin
      Group := GetGroupByGroupCode(FNowGroups[I].GroupCode, False);
      ShowGroupInfo(Group, False, nil);
      Break;
    end;
end;

procedure TPropertiesForm.Button6Click(Sender: TObject);
var
  I: Integer;

  procedure AddGroup(Group: TGroup);
  var
    FRelatedGroups: TGroups;
    OldGroups, Groups: TGroups;
    TempGroup: TGroup;
    I: Integer;
    KeyWords: string;
  begin
    FRelatedGroups := EncodeGroups(Group.RelatedGroups);
    OldGroups := CopyGroups(FNowGroups);
    Groups := CopyGroups(OldGroups);
    AddGroupToGroups(Groups, Group);
    AddGroupsToGroups(Groups, FRelatedGroups);
    FNowGroups := CopyGroups(Groups);
    RemoveGroupsFromGroups(Groups, OldGroups);
    for I := 0 to Length(Groups) - 1 do
    begin
      LstCurrentGroups.Items.Add(Groups[I].GroupName);
      TempGroup := GetGroupByGroupCode(Groups[I].GroupCode, False);
      KeyWords := KeyWordsMemo.Text;
      AddWordsA(TempGroup.GroupKeyWords, KeyWords);
      KeyWordsMemo.Text := KeyWords;
    end;
  end;

begin
  for I := 0 to LstAvaliableGroups.Items.Count - 1 do
    if LstAvaliableGroups.Selected[I] then
      AddGroup(FShowenRegGroups[I]);

  LstCurrentGroups.Invalidate;
  LstAvaliableGroups.Invalidate;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.Button7Click(Sender: TObject);
var
  i, j : integer;
  KeyWords, AllGroupsKeyWords, GroupKeyWords : String;
begin
 for i:=lstCurrentGroups.Items.Count-1 downto 0 do
 if lstCurrentGroups.Selected[i] then
 begin
  if CbRemoveKeywordsForGroups.Checked then
  begin
   AllGroupsKeyWords:='';
   for j:=lstCurrentGroups.Items.Count-1 downto 0 do
   if i<>j then
   begin
    AddWordsA(RegGroups[aGetGroupByCode(FNowGroups[j].GroupCode)].GroupKeyWords,AllGroupsKeyWords);
   end;
   KeyWords:=KeyWordsMemo.Text;
   GroupKeyWords:=RegGroups[aGetGroupByCode(FNowGroups[i].GroupCode)].GroupKeyWords;
   DeleteWords(GroupKeyWords,AllGroupsKeyWords);
   DeleteWords(KeyWords,GroupKeyWords);
   KeyWordsMemo.Text:=KeyWords;
  end;
  //удаляем группу изтекущих
  RemoveGroupFromGroups(FNowGroups,FNowGroups[i]);
  lstCurrentGroups.Items.Delete(i);
 end;
 lstCurrentGroups.Invalidate;
 LstAvaliableGroups.Invalidate;
 CommentMemoChange(Sender);
end;

procedure TPropertiesForm.lstCurrentGroupsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  ItemNo : Integer;
  I: Integer;
begin
  if FSaving then
    Exit;
  ItemNo := LstCurrentGroups.ItemAtPos(MousePos, True);
  if ItemNo <> -1 then
  begin
    if not LstCurrentGroups.Selected[ItemNo] then
    begin
      LstCurrentGroups.Selected[ItemNo] := True;
      for I := 0 to LstCurrentGroups.Items.Count - 1 do
        if I <> ItemNo then
          LstCurrentGroups.Selected[I] := False;
    end;
    PopupMenuGroups.Tag := ItemNo;
    PopupMenuGroups.Popup(LstCurrentGroups.ClientToScreen(MousePos).X, LstCurrentGroups.ClientToScreen(MousePos).Y);
  end
  else
  begin
    for I := 0 to LstCurrentGroups.Items.Count - 1 do
      LstCurrentGroups.Selected[I] := False;
    PmClear.Popup(LstCurrentGroups.ClientToScreen(MousePos).X, LstCurrentGroups.ClientToScreen(MousePos).Y);
  end;
end;

procedure TPropertiesForm.Clear1Click(Sender: TObject);
begin
  lstCurrentGroups.Clear;
  FreeGroups(FNowGroups);
  CommentMemoChange(Sender);
  LstCurrentGroups.Invalidate;
  LstAvaliableGroups.Invalidate;
end;

procedure TPropertiesForm.CbShowAllGroupsClick(Sender: TObject);
begin
  RecreateGroupsList;
  DBKernel.WriteBool('Propetry', 'ShowAllGroups', CbShowAllGroups.Checked);
end;

procedure TPropertiesForm.LstAvaliableGroupsDblClick(Sender: TObject);
begin
 if fSaving then Exit;
 Button6Click(Sender);
end;

function TPropertiesForm.aGetGroupByCode(GroupCode: String): integer;
var
  i : integer;
begin
 Result:=0;
 for i:=0 to Length(RegGroups)-1 do
 if RegGroups[i].GroupCode=GroupCode then
 begin
  Result:=i;
  break;
 end;
end;

procedure TPropertiesForm.CreateGroup1Click(Sender: TObject);
begin
  CreateNewGroupDialogA(FNowGroups[PopupMenuGroups.Tag].GroupName, FNowGroups[PopupMenuGroups.Tag].GroupCode);
end;

procedure TPropertiesForm.ChangeGroup1Click(Sender: TObject);
var
  Group : TGroup;
begin
  Group := GetGroupByGroupCode(FNowGroups[PopupMenuGroups.Tag].GroupCode, False);
  DBChangeGroup(Group);
end;

function TPropertiesForm.GetFileName: string;
begin
  Result := '';
  if FFilesInfo.Count > 0 then
    Result := FFilesInfo[0].FileName;
end;

function TPropertiesForm.GetFormID: string;
begin
  Result := 'PropertiesForm';
end;

function TPropertiesForm.GetImageID: Integer;
begin
  Result := 0;
  if FFilesInfo.Count > 0 then
    Result := FFilesInfo[0].ID;
end;

procedure TPropertiesForm.GroupManeger1Click(Sender: TObject);
begin
  ExecuteGroupManager;
end;

procedure TPropertiesForm.SearchForGroup1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
  NewSearch := SearchManager.NewSearch;
  NewSearch.SearchEdit.Text := ':Group(' + FNowGroups[PopupMenuGroups.Tag].GroupName + '):';
  NewSearch.WlStartStop.OnClick(Sender);
  NewSearch.Show;
end;

procedure TPropertiesForm.QuickInfo1Click(Sender: TObject);
begin
  ShowGroupInfo(FNowGroups[PopupMenuGroups.Tag], False, nil);
end;

procedure TPropertiesForm.PopupMenuGroupsPopup(Sender: TObject);
begin
 if GroupWithCodeExists(FNowGroups[PopupMenuGroups.Tag].GroupCode) then
  begin
    CreateGroup1.Visible := False;
    MoveToGroup1.Visible := False;
    ChangeGroup1.Visible := True;
  end
  else
  begin
    CreateGroup1.Visible := True;
    MoveToGroup1.Visible := True;
    ChangeGroup1.Visible := False;
  end;
end;

procedure TPropertiesForm.CbRemoveKeywordsForGroupsClick(Sender: TObject);
begin
  DBKernel.WriteBool('Propetry','DeleteKeyWords', CbRemoveKeywordsForGroups.Checked);
end;

procedure TPropertiesForm.MoveToGroup1Click(Sender: TObject);
var
  ToGroup : TGroup;
begin
  if SelectGroup(ToGroup) then
  begin
    MoveGroup(FNowGroups[PopupMenuGroups.Tag], ToGroup);
    MessageBoxDB(Handle, TEXT_MES_RELOAD_INFO, L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
  end;
end;

procedure TPropertiesForm.ChangedDBDataGroups(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
begin
  if EventID_Param_GroupsChanged in Params then
  begin
    RecreateGroupsList;
    Exit;
  end;
end;

procedure TPropertiesForm.LockImput;
begin
  FSaving := True;
  R(EditLinkForm);
  CommentMemo.Enabled := False;
  OwnerMemo.Enabled := False;
  CollectionMemo.Enabled := False;
  RatingEdit.Enabled := False;
  KeyWordsMemo.Enabled := False;
  DateEdit.Enabled := False;
  TimeEdit.Enabled := False;
  CbInclude.Enabled := False;
  LstAvaliableGroups.Enabled := False;
  LstCurrentGroups.Enabled := False;
  Button6.Enabled := False;
  Button7.Enabled := False;
end;

procedure TPropertiesForm.UnLockImput;
begin
  FSaving := False;
  OwnerMemo.Enabled := True;
  CollectionMemo.Enabled := True;
  RatingEdit.Enabled := True;
  KeyWordsMemo.Enabled := True;
  DateEdit.Enabled := True;
  TimeEdit.Enabled := True;
  CbInclude.Enabled := True;
  LstAvaliableGroups.Enabled := True;
  LstCurrentGroups.Enabled := True;
  Button6.Enabled := True;
  Button7.Enabled := True;
end;

procedure TPropertiesForm.PmClearPopup(Sender: TObject);
begin
 Clear1.Visible:=(lstCurrentGroups.Items.Count<>0) and not fSaving;
end;

procedure TPropertiesForm.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if FShowInfoType<>SHOW_INFO_FILE_NAME then
    if DropFileTarget2.Files.Count = 1 then
    begin
      SetFocus;
      Point := LinksScrollBox.ClientToScreen(Point);
      LinkDropFiles.Assign(DropFileTarget2.Files);
      PmImageConnect.Popup(Point.X, Point.Y);
    end;
end;

procedure TPropertiesForm.AddImThLink1Click(Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo: TLinkInfo;
  I: Integer;
  B: Boolean;
begin
  GetInfoByFileNameA(LinkDropFiles[0], False, Info);
  if Info.ItemImTh = '' then
    Info.ItemImTh := GetImageIDW(LinkDropFiles[0], False).ImTh;
  LinkInfo.LinkType := LINK_TYPE_ID_EXT;
  LinkInfo.LinkName := TEXT_MES_PROCESSING;
  LinkInfo.LinkValue := CodeExtID(Info.ItemImTh);
  B := True;
  for I := 0 to Length(FPropertyLinks) - 1 do
    if FPropertyLinks[I].LinkName = TEXT_MES_PROCESSING then
    begin
      B := False;
      Break;
    end;
  if B then
  begin
    SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
    FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddOriginalImTh1Click(Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo: TLinkInfo;
  I: Integer;
  B: Boolean;
begin
  GetInfoByFileNameA(LinkDropFiles[0], False, Info);
  if Info.ItemImTh = '' then
    Info.ItemImTh := GetImageIDW(LinkDropFiles[0], False).ImTh;
  LinkInfo.LinkType := LINK_TYPE_ID_EXT;
  LinkInfo.LinkName := TEXT_MES_ORIGINAL;
  LinkInfo.LinkValue := CodeExtID(Info.ItemImTh);
  B := True;
  for I := 0 to Length(FPropertyLinks) - 1 do
    if FPropertyLinks[I].LinkName = TEXT_MES_PROCESSING then
    begin
      B := False;
      Break;
    end;
  if B then
  begin
    SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
    FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(
  Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo: TLinkInfo;
  LinksInfo: TLinksInfo;
  Query: TDataSet;
  I: Integer;
  B: Boolean;
begin
  GetInfoByFileNameA(LinkDropFiles[0], False, Info);
  if Info.ItemImTh = '' then
    Info.ItemImTh := GetImageIDW(LinkDropFiles[0], False).ImTh;
  LinkInfo.LinkType := LINK_TYPE_ID_EXT;
  LinkInfo.LinkName := TEXT_MES_PROCESSING;
  LinkInfo.LinkValue := CodeExtID(Info.ItemImTh);
  B := True;
  for I := 0 to Length(FPropertyLinks) - 1 do
    if FPropertyLinks[I].LinkName = TEXT_MES_PROCESSING then
    begin
      B := False;
      Break;
    end;
  if B then
  begin
    SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
    FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
  end;
  SetLength(LinksInfo, 1);
  LinksInfo[0].LinkType := LINK_TYPE_ID_EXT;
  LinksInfo[0].LinkName := TEXT_MES_ORIGINAL;
  // TODO:[0]
  LinksInfo[0].LinkValue := CodeExtID(FFilesInfo[0].LongImageID);
  ReplaceLinks('', CodeLinksInfo(LinksInfo), Info.ItemLinks);
  Query := GetQuery;
  SetSQL(Query, Format('UPDATE $DB$ Set Links = :Links where ID = %d', [Info.ItemId]));
  SetStrParam(Query, 0, Info.ItemLinks);
  ExecSQL(Query);
  FreeDS(Query);
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddOriginalImThAndAddProcessngToOriginalImTh1Click(
  Sender: TObject);
var
  Info : TOneRecordInfo;
  LinkInfo: TLinkInfo;
  LinksInfo: TLinksInfo;
  Query: TDataSet;
  I: Integer;
  B: Boolean;
begin
  GetInfoByFileNameA(LinkDropFiles[0], False, Info);
  if Info.ItemImTh = '' then
    Info.ItemImTh := GetImageIDW(LinkDropFiles[0], False).ImTh;
  LinkInfo.LinkType := LINK_TYPE_ID_EXT;
  LinkInfo.LinkName := TEXT_MES_ORIGINAL;
  LinkInfo.LinkValue := CodeExtID(Info.ItemImTh);
  B := True;
  for I := 0 to Length(FPropertyLinks) - 1 do
    if FPropertyLinks[I].LinkName = TEXT_MES_PROCESSING then
    begin
      B := False;
      Break;
    end;
  if B then
  begin
    SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
    FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
  end;
  SetLength(LinksInfo, 1);
  LinksInfo[0].LinkType := LINK_TYPE_ID_EXT;
  LinksInfo[0].LinkName := TEXT_MES_PROCESSING;
  // TODO:[0]
  LinksInfo[0].LinkValue := CodeExtID(FFilesInfo[0].LongImageID);
  ReplaceLinks('', CodeLinksInfo(LinksInfo), Info.ItemLinks);
  Query := GetQuery;
  SetSQL(Query, Format('UPDATE $DB$ Set Links = :Links where ID = %d', [Info.ItemId]));
  SetStrParam(Query, 0, Info.ItemLinks);
  ExecSQL(Query);
  FreeDS(Query);
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.PmImageConnectPopup(Sender: TObject);
begin
  AddImThProcessingImageAndAddOriginalToProcessingPhoto1.Visible := (FShowInfoType = SHOW_INFO_ID);
  AddOriginalImThAndAddProcessngToOriginalImTh1.Visible := (FShowInfoType = SHOW_INFO_ID);
end;

procedure TPropertiesForm.OnDoneLoadingImage(Sender: TObject);
begin

end;

procedure TPropertiesForm.OnDoneLoadGistogrammData(Sender: TObject);
var
  Bitmap : TBitmap;
  MinC, MaxC: Integer;
begin
  if Sender is TPropertyLoadGistogrammThread then
    GistogrammData.Loaded := True;

  Bitmap := TBitmap.Create;
  try
    case RgGistogrammChannel.ItemIndex of
      0:
        GetGistogrammBitmapW(130, GistogrammData.Gray, MinC, MaxC, Bitmap);
      1:
        GetGistogrammBitmapW(130, GistogrammData.Red, MinC, MaxC, Bitmap);
      2:
        GetGistogrammBitmapW(130, GistogrammData.Green, MinC, MaxC, Bitmap);
      3:
        GetGistogrammBitmapW(130, GistogrammData.Blue, MinC, MaxC, Bitmap);
    end;

    Label5.Caption := Format(L('Effective range: %d..%d'), [MinC, MaxC]);
    GistogrammImage.Picture.Bitmap := Bitmap;
  finally
    Bitmap.Free;
  end;
end;

initialization

  PropertyManager := TPropertyManager.Create;

finalization

  F(PropertyManager);

end.
