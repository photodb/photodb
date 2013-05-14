unit PropertyForm;

interface

uses
  Generics.Collections,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.DateUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  Vcl.AppEvnts,
  Vcl.Clipbrd,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.ValEdit,
  Vcl.ActnPopup,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.Imaging.JPEG,
  Vcl.Imaging.pngimage,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.Rating,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.DBLoading,
  Dmitry.Controls.SaveWindowPos,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.DmGradient,

  DBCMenu,
  Effects,
  GraphicCrypt,
  UnitLinksSupport,

  DropTarget,
  DropSource,
  DragDropFile,
  DragDrop,

  CCR.Exif,

  UnitPropertyLoadImageThread,
  UnitINI,
  UnitPropertyLoadGistogrammThread,
  UnitDBDeclare,

  uTranslateUtils,
  uGUIDUtils,
  uRAWImage,
  uRawExif,
  uLogger,
  uBitmapUtils,
  uCDMappingTypes,
  uDBDrawing,
  uMemory,
  uListViewUtils,
  uDBForm,
  uInterfaces,
  uConstants,
  uTranslate,
  uShellIntegration,
  uGraphicUtils,
  uDBBaseTypes,
  uDBGraphicTypes,
  uRuntime,
  uDBUtils,
  uMediaInfo,
  uDBTypes,
  uDBConnection,
  uDBContext,
  uDBEntities,
  uDBManager,
  uActivationUtils,
  uSettings,
  uAssociations,
  uDBAdapter,
  uMemoryEx,
  uExifUtils,
  uStringUtils,
  uVCLHelpers,
  uThemesUtils,
  uColorUtils,
  uMachMask,
  uExifInfo,
  uDBIcons,
  uDBInfoEditorUtils,
  uEXIFDisplayControl,
  uProgramStatInfo,
  uDatabaseDirectoriesUpdater,
  uCollectionEvents,
  uFormInterfaces,
  uSessionPasswords;

type
  TValueListEditor = class(TEXIFDisplayControl);

type
  TShowInfoType = (SHOW_INFO_FILE_NAME, SHOW_INFO_ID, SHOW_INFO_IDS);

const
  ThSizePropertyPreview = 100;

type
  TPropertiesForm = class(TDBForm, ICurrentImageSource)
    ImMain: TImage;
    CommentMemo: TMemo;
    LabelComment: TLabel;
    PmItem: TPopupActionBar;
    Shell1: TMenuItem;
    Show1: TMenuItem;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Searchforit1: TMenuItem;
    DBItem1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    SaveWindowPos1: TSaveWindowPos;
    PmRatingNotAvaliable: TPopupActionBar;
    Ratingnotsets1: TMenuItem;
    PmComment: TPopupActionBar;
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
    ImgReloadInfo: TImage;
    DropFileSource1: TDropFileSource;
    DropFileTarget1: TDropFileTarget;
    DragImageList: TImageList;
    BtDone: TButton;
    BtSave: TButton;
    BtnFind: TButton;
    CopyEXIFPopupMenu: TPopupActionBar;
    CopyCurrent1: TMenuItem;
    CopyAll1: TMenuItem;
    PmLinks: TPopupActionBar;
    PmAddLink: TPopupActionBar;
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
    PopupMenuGroups: TPopupActionBar;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    CreateGroup1: TMenuItem;
    ChangeGroup1: TMenuItem;
    SearchForGroup1: TMenuItem;
    QuickInfo1: TMenuItem;
    PmClear: TPopupActionBar;
    Clear1: TMenuItem;
    MoveToGroup1: TMenuItem;
    DropFileTarget2: TDropFileTarget;
    PmImageConnect: TPopupActionBar;
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
    LabelPath: TMemo;
    Label4: TLabel;
    LabelName1: TLabel;
    LabelName: TMemo;
    Image3: TImage;
    LbGroupsEditInfo: TLabel;
    LbAvaliableGroups: TLabel;
    LstAvaliableGroups: TListBox;
    BtnRemoveGroup: TButton;
    BtnAddGroup: TButton;
    lstCurrentGroups: TListBox;
    LbCurrentGroups: TLabel;
    CbShowAllGroups: TCheckBox;
    CbRemoveKeywordsForGroups: TCheckBox;
    BtnNewGroup: TButton;
    RgGistogrammChannel: TRadioGroup;
    DgGistogramm: TDmGradient;
    GistogrammImage: TImage;
    Label2: TLabel;
    CbInclude: TCheckBox;
    LbLinks: TLabel;
    LinksScrollBox: TScrollBox;
    VleExif: TValueListEditor;
    LbEffectiveRange: TStaticText;
    WlAddLink: TWebLink;
    ImSearch: TImage;
    WedGroupsFilter: TWatermarkedEdit;
    TmrFilter: TTimer;
    LbColors: TLabel;
    LbViewCount: TLabel;
    procedure BtDoneClick(Sender: TObject);
    procedure BtnFindClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CommentMemoChange(Sender: TObject);
    procedure ImMainDblClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Searchforit1Click(Sender: TObject);
    procedure BeginAdding(Sender: TObject);
    procedure EndAdding(Sender: TObject);
    procedure PmItemPopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure ComboBox1_KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
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
    procedure RgGistogrammChannelClick(Sender: TObject);
    procedure VleExifContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure CopyCurrent1Click(Sender: TObject);
    procedure CopyAll1Click(Sender: TObject);
    procedure Addnewlink1Click(Sender: TObject);
    procedure LinkOnPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure LinkClick(Sender: TObject);
    procedure PmLinksPopup(Sender: TObject);
    procedure Change1Click(Sender: TObject);
    procedure PmAddLinkPopup(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure OpenFolder1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure BtnNewGroupClick(Sender: TObject);
    procedure LstAvaliableGroupsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstCurrentGroupsDblClick(Sender: TObject);
    procedure BtnAddGroupClick(Sender: TObject);
    procedure BtnRemoveGroupClick(Sender: TObject);
    procedure lstCurrentGroupsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Clear1Click(Sender: TObject);
    procedure CbShowAllGroupsClick(Sender: TObject);
    procedure LstAvaliableGroupsDblClick(Sender: TObject);
    function aGetGroupByCode(GroupCode: String) : integer;
    procedure CreateGroup1Click(Sender: TObject);
    procedure ChangeGroup1Click(Sender: TObject);
    procedure SearchForGroup1Click(Sender: TObject);
    procedure QuickInfo1Click(Sender: TObject);
    procedure PopupMenuGroupsPopup(Sender: TObject);
    procedure CbRemoveKeywordsForGroupsClick(Sender: TObject);
    procedure MoveToGroup1Click(Sender: TObject);
    procedure PmClearPopup(Sender: TObject);
    procedure DropFileTarget2Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure AddImThLink1Click(Sender: TObject);
    procedure AddOriginalImTh1Click(Sender: TObject);
    procedure AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(Sender: TObject);
    procedure AddOriginalImThAndAddProcessngToOriginalImTh1Click(Sender: TObject);
    procedure PmImageConnectPopup(Sender: TObject);
    procedure PcMainChange(Sender: TObject);
    procedure ImageLoadingFileDrawBackground(Sender: TObject; Buffer: TBitmap);
    procedure TsGroupsResize(Sender: TObject);
    procedure WedGroupsFilterChange(Sender: TObject);
    procedure TmrFilterTimer(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    FGroupsRepository: IGroupsRepository;
    FMediaRepository: IMediaRepository;

    FShowInfoType: TShowInfoType;
    LinkDropFiles: TStrings;
    EditLinkForm: TForm;
    Links: array of TWebLink;
    FReadingInfo: Boolean;
    FSaving: Boolean;
    FOldGroups, FNowGroups: TGroups;
    FShowenRegGroups: TGroups;
    FPropertyLinks, ItemLinks: TLinksInfo;
    FFilesInfo: TMediaItemCollection;
    FMenuRecord: TMediaItem;
    RegGroups: TGroups;
    Adding_now, Editing_info, No_file: Boolean;
    FDateTimeInFileExists: Boolean;
    FFileDate, FFileTime: TDateTime;
    DestroyCounter: Integer;
    function GetImageID: Integer;
    function GetFileName: string;
    procedure EnableEditing(Value: Boolean);
    procedure SetLinkInfo(Sender: TObject; ID: string; Info: TLinkInfo; N: Integer; Action: Integer);
    procedure CloseEditLinkForm(Form: TForm; ID: string);
    procedure ReloadGroups;
    procedure ReadExifData;
    procedure ResetBold;
    procedure ReadLinks;
    procedure RecreateGroupsList;
    procedure FillGroupList;
    procedure LockImput;
    procedure UnLockImput;
    procedure LoadLanguage;
    procedure DrawColors(Colors: string);
    function ReadCHInclude: Boolean;
    function ReadCHLinks: Boolean;
    function ReadCHDate: Boolean;
    function ReadCHTime: Boolean;
    procedure OnDoneLoadingImage(Sender: TObject);
    procedure OnDoneLoadGistogrammData(Sender: TObject);
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure ChangedDBDataGroups(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    SID: TGUID;
    FCurrentPass: string;
    GistogrammData: THistogrammData;

    //Begin: ICurrentImageSource
    function GetCurrentImageFileName: string;
    //End of: ICurrentImageSource

    procedure ExecuteFileNoEx(FileName: string);
    procedure Execute(ID: Integer);
    procedure ExecuteEx(IDs: TArInteger); overload;
    procedure ExecuteEx(Data: TMediaItemCollection; Image: TBitmap = nil); overload;
    property ImageID: Integer read GetImageID;
    property FileName: string read GetFileName;
  end;

  TPropertyManager = class(TObject)
  private
    FPropertys: TList<TPropertiesForm>;
  public
    constructor Create;
    destructor Destroy; override;
    function NewSimpleProperty: TPropertiesForm;
    function NewIDProperty(ID: Integer): TPropertiesForm;
    function NewFileProperty(FileName: string): TPropertiesForm;
    procedure AddProperty(aProperty: TPropertiesForm);
    procedure RemoveProperty(aProperty: TPropertiesForm);
    function IsPropertyForm(aProperty: TForm): Boolean;
    function PropertyCount: Integer;
    function GetAnySimpleProperty: TPropertiesForm;
    function GetPropertyByID(ID: Integer): TPropertiesForm;
    function GetPropertyByFileName(FileName: string): TPropertiesForm;
  end;

var
  PropertyManager: TPropertyManager;

implementation

uses
  CmpUnit,
  UnitEditLinkForm,
  UnitHelp,
  uManagerExplorer,
  UnitFormChangeGroup,
  SelectGroupForm,
  UnitGroupsTools;

{$R *.dfm}

{ TPropertyManager }

procedure TPropertyManager.AddProperty(aProperty: TPropertiesForm);
begin
  if FPropertys.IndexOf(aProperty) = -1 then
    FPropertys.Add(aProperty);
end;

constructor TPropertyManager.Create;
begin
  FPropertys := TList<TPropertiesForm>.Create;
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

function TPropertyManager.GetPropertyByID(ID: Integer): TPropertiesForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if FPropertys[I].FShowInfoType = SHOW_INFO_ID then
      if FPropertys[I].ImageID = ID then
  begin
    Result := FPropertys[I];
    Exit;
  end;
end;

function TPropertyManager.GetPropertyByFileName(FileName: string): TPropertiesForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPropertys.Count - 1 do
    if FPropertys[I].FShowInfoType = SHOW_INFO_FILE_NAME then
      if AnsiLowerCase(FPropertys[I].FileName) = AnsiLowerCase(FileName) then
      begin
        Result := FPropertys[I];
        Exit;
      end;
end;

function TPropertyManager.IsPropertyForm(aProperty: TForm): Boolean;
begin
  Result := False;
  if aProperty is TPropertiesForm then
    Result := FPropertys.IndexOf(TPropertiesForm(aProperty)) > -1;
end;

function TPropertyManager.NewFileProperty(FileName: string): TPropertiesForm;
begin
  Result := GetPropertyByFileName(FileName);
  if Result <> nil then
    Exit
  else
    Result := NewSimpleProperty;
end;

function TPropertyManager.NewIDProperty(ID: Integer): TPropertiesForm;
begin
  Result := GetPropertyByID(ID);
  if Result <> nil then
    Exit
  else
    Result := NewSimpleProperty;
end;

function TPropertyManager.NewSimpleProperty: TPropertiesForm;
begin
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

{ TPropertiesForm }

function TPropertiesForm.ReadCHInclude: Boolean;
begin
  Result := False;
  if FShowInfoType = SHOW_INFO_FILE_NAME then
    Result := not CbInclude.Checked;
  if FShowInfoType = SHOW_INFO_ID then
    Result := (FFilesInfo[0].Include <> CbInclude.Checked);
  if FShowInfoType = SHOW_INFO_IDS then
  begin
    if (FFilesInfo.IsVariousInclude) then
    begin
      if (CbInclude.State <> cbGrayed) then
      begin
        Result := True;
        Exit;
      end;
    end else
    begin
      if (FFilesInfo.StatInclude) and (CbInclude.State = cbUnchecked) or (not FFilesInfo.StatInclude) and
        (CbInclude.State = cbChecked) then
      begin
        Result := True;
        Exit;
      end
    end;
  end;
end;

function TPropertiesForm.ReadCHLinks: Boolean;
begin
  Result := not CompareLinks(FPropertyLinks, ItemLinks, True);
end;

function TPropertiesForm.ReadCHDate: Boolean;
begin
  Result := False;
  if (FShowInfoType = SHOW_INFO_ID) or (FShowInfoType = SHOW_INFO_FILE_NAME) then
    Result := (((FFilesInfo[0].IsDate <> DateEdit.Checked) or
          (FFilesInfo[0].Date <> DateEdit.DateTime)) and DateEdit.Enabled);

  if FShowInfoType = SHOW_INFO_IDS then
    Result := DateEdit.Checked and
      ((FFilesInfo.StatDate <> DateEdit.DateTime) or FFilesInfo.IsVariousDate);
end;

function TPropertiesForm.ReadCHTime: Boolean;
var
  VarTime: Boolean;
begin
  Result := False;
  if (FShowInfoType = SHOW_INFO_ID) or (FShowInfoType = SHOW_INFO_FILE_NAME) then
  begin
    VarTime := Abs(FFilesInfo[0].Time - TimeOf(TimeEdit.Time)) > 1 / (24 * 60 * 60 * 3);
    Result := (((FFilesInfo[0].IsTime <> TimeEdit.Checked) or VarTime) and TimeEdit.Enabled);
  end;
  if FShowInfoType = SHOW_INFO_IDS then
  begin
    VarTime := Abs(TimeOf(FFilesInfo.StatTime) - TimeOf(TimeEdit.Time)) > 1 / (24 * 60 * 60 * 3);
    Result := TimeEdit.Checked and (VarTime or FFilesInfo.IsVariousTime);
  end;
end;

procedure TPropertiesForm.Execute(ID: Integer);
var
  FBS: TStream;
  FBit, B1, TempBitmap,
  FShadowImage: TBitmap;
  JPEG: TJpegImage;
  PassWord: string;
  W, H: Integer;
  DataRecord: TMediaItem;
  WorkQuery: TDataSet;
  DA: TImageTableAdapter;
begin
  try
    if FSaving then
    begin
      SetFocus;
      Exit;
    end;
    TsGeneral.HandleNeeded;
    GistogrammData.Loading := False;
    R(EditLinkForm);
    PcMain.Pages[2].TabVisible := True;
    PcMain.Pages[3].TabVisible := True;

    Editing_info := False;
    FCurrentPass := '';
    CbInclude.AllowGrayed := False;
    ResetBold;
    if ImageID <> Id then
      PcMain.ActivePageIndex := 0;
    ImgReloadInfo.Visible := False;
    FShowInfoType := SHOW_INFO_ID;

    CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
    CollectionEvents.UnRegisterChangesIDbyID(Self, ChangedDBDataByID, ID);
    CollectionEvents.RegisterChangesIDbyID(Self, ChangedDBDataByID, ID);
    DBitem1.Visible := True;
    CommentMemo.Cursor := crDefault;
    CommentMemo.PopupMenu := nil;
    WorkQuery := FContext.CreateQuery;
    DA := TImageTableAdapter.Create(WorkQuery);
    try
      ReadOnlyQuery(WorkQuery);
      SetSQL(WorkQuery, 'SELECT * FROM $DB$ WHERE ID=' + IntToStr(ID));
      OpenDS(WorkQuery);
      if WorkQuery.RecordCount = 0 then
        No_file := True;
      if not No_file then
        BtSave.Enabled := False;

      WorkQuery.First;
      DataRecord := TMediaItem.CreateFromDS(WorkQuery);
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
            PassWord := '';
            if DA.Thumb = nil then
              Exit;

            JPEG := nil;
            try
              DataRecord.Encrypted :=  ValidCryptBlobStreamJPG(DA.Thumb);
              if DataRecord.Encrypted then
              begin
                PassWord := SessionPasswords.FindForBlobStream(WorkQuery.FieldByName('thum'));
                if PassWord = '' then
                  PassWord := RequestPasswordForm.ForBlob(DA.Thumb, DA.FileName);

                if PassWord = '' then
                  Exit;

                JPEG := TJpegImage.Create;
                DeCryptBlobStreamJPG(DA.Thumb, PassWord, JPEG);
                FCurrentPass := PassWord;
              end else
              begin
                FBS := GetBlobStream(DA.Thumb, BmRead);
                try
                  JPEG := TJpegImage.Create;
                  JPEG.LoadFromStream(FBS);
                finally
                  F(FBS);
                end;
              end;

              TempBitmap := TBitmap.Create;
              try
                TempBitmap.Assign(JPEG);
                F(JPEG);
                W := TempBitmap.Width;
                H := TempBitmap.Height;
                ProportionalSize(ThSizePropertyPreview, ThSizePropertyPreview, W, H);
                DoResize(W, H, TempBitmap, Fbit);
              finally
                F(TempBitmap);
              end;

              B1.Width := ThSizePropertyPreview + 4;
              B1.Height := ThSizePropertyPreview + 4;
              B1.Canvas.Brush.Color := Theme.WindowColor;
              B1.Canvas.Pen.Color := Theme.WindowColor;
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
              DrawAttributes(B1, 100, DataRecord);

              ImMain.Picture.Bitmap := B1;
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

      PcMain.Pages[2].TabVisible := FileExistsSafe(DataRecord.FileName);
      PcMain.Pages[3].TabVisible := PcMain.Pages[2].TabVisible;
      Idlabel.Text := Inttostr(Id);
      Caption := L('Properties') + ' - ' + DA.Name;
      KeyWordsMemo.Text := DataRecord.KeyWords;
      LabelName.Text := ExtractFileName(DataRecord.FileName);
      LabelPath.Text := DataRecord.FileName;
      SizeLabel.Text := SizeInText(DataRecord.FileSize);
      Widthmemo.Text := IntToStr(DA.Width) + L('px.');
      Heightmemo.Text := IntToStr(DA.Height) + L('px.');
      LbViewCount.Caption := FormatEx(L('Views: {0}'), [DA.ViewCount]);
      DrawColors(DataRecord.Colors);
      LbColors.Caption := L('Colors') + ':';

      RatingEdit.Rating := DataRecord.Rating;
      RatingEdit.Islayered := False;
      DateEdit.Enabled := True;
      TimeEdit.Enabled := True;

      if YearOf(DataRecord.Date) > cMinEXIFYear then
        DateEdit.DateTime := DataRecord.Date
      else
        DateEdit.DateTime := DateOf(Now);
      TimeEdit.Time := DataRecord.Time;
      DateEdit.Checked := DataRecord.IsDate;
      TimeEdit.Checked := DataRecord.IsTime;
      CbInclude.Checked := DataRecord.Include;

      CommentMemo.Show;
      CommentMemo.Text := DataRecord.Comment;
	    CommentMemo.PopupMenu := nil;

      LabelComment.Show;

      ItemLinks := ParseLinksInfo(DataRecord.Links);
      FPropertyLinks := CopyLinksInfo(ItemLinks);

      F(FNowGroups);
      FNowGroups := TGroups.CreateFromString(DataRecord.Groups);
      F(FOldGroups);
      FOldGroups := FNowGroups.Clone;

      FMenuRecord := TMediaItem.CreateFromDS(WorkQuery);
      FFilesInfo.Clear;
      FFilesInfo.Add(FMenuRecord);
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
      F(DA);
      FreeDS(WorkQuery);
    end;
    EnableEditing(True);
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
  if No_file then
    Exit;

  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(LabelPath.text);
    SetPath(ExtractFileDir(LabelPath.text));
    Show;
  end;
end;

procedure TPropertiesForm.FormCreate(Sender: TObject);
begin
  EditLinkForm := nil;
  FContext := DBManager.DBContext;
  FGroupsRepository := FContext.Groups;
  FMediaRepository := FContext.Media;

  FFilesInfo := TMediaItemCollection.Create;
  DestroyCounter := 0;
  GistogrammData.Loaded := False;
  GistogrammData.Loading := False;

  LinkDropFiles := TStringList.Create;
  PropertyManager.AddProperty(Self);
  LstCurrentGroups.DoubleBuffered := True;
  LstAvaliableGroups.DoubleBuffered := True;
  RegGroups := TGroups.Create;
  FShowenRegGroups := TGroups.Create;
  FNowGroups := TGroups.Create;
  FOldGroups := TGroups.Create;

  SetLength(Links, 0);
  FReadingInfo := False;
  FSaving := False;
  DropFileTarget1.Register(Self);
  DropFileTarget2.Register(LinksScrollBox);
  No_file := False;
  Editing_info := True;
  Adding_now := False;
  CollectionEvents.RegisterChangesID(Self, ChangedDBDataGroups);
  TimeEdit.ParentColor := True;

  PmItem.Images := Icons.ImageList;
  PmLinks.Images := Icons.ImageList;
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

  lstCurrentGroups.Font.Color := Theme.ListFontColor;
  lstCurrentGroups.Color := Theme.ListColor;

  LstAvaliableGroups.Font.Color := Theme.ListFontColor;
  LstAvaliableGroups.Color := Theme.ListColor;

  SaveWindowPos1.Key := GetRegRootKey + 'Properties';
  SaveWindowPos1.SetPosition;
  FixFormPosition;

  WlAddLink.LoadFromResource('SERIES_EXPAND');
  WlAddLink.Color := Theme.WindowColor;

  LoadLanguage;

  CbRemoveKeywordsForGroups.Checked := AppSettings.ReadBool('Propetry', 'DeleteKeyWords', True);
  CbShowAllGroups.Checked := AppSettings.ReadBool('Propetry', 'ShowAllGroups', False);

  //statistics
  ProgramStatistics.PropertiesUsed;
end;

procedure TPropertiesForm.ImMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if (Button = mbLeft) then
  begin
    DragImageList.Clear;
    DragImageList.Masked := False;

    DropFileSource1.Files.Clear;
    if FShowInfoType = SHOW_INFO_IDS then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FileExistsSafe(ProcessPath(FFilesInfo[I].FileName)) then
         DropFileSource1.Files.Add(ProcessPath(FFilesInfo[I].FileName));
    end else
    begin
      if FileExistsSafe(ProcessPath(LabelPath.Text)) then
        DropFileSource1.Files.Add(ProcessPath(LabelPath.Text));
    end;
    if DropFileSource1.Files.Count > 0 then
    begin
      CreateDragImage(ImMain.Picture.Graphic, DragImageList, Font, DropFileSource1.Files[0]);

      DropFileSource1.ImageIndex := 0;
      DropFileSource1.Execute;
    end;
  end;
end;

procedure TPropertiesForm.ImageLoadingFileDrawBackground(Sender: TObject;
  Buffer: TBitmap);
begin
  Buffer.Canvas.Pen.Color := Theme.WindowColor;
  Buffer.Canvas.Brush.Color := Theme.WindowColor;
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
    CHComment := (not CommentMemo.ReadOnly and FFilesInfo.IsVariousComments) or
      (not FFilesInfo.IsVariousComments and (CommentMemo.Text <> FFilesInfo.CommonComments));
  end else
    CHComment := FFilesInfo.CommonComments <> CommentMemo.Text;

  if (FShowInfoType = SHOW_INFO_IDS) then
    CHRating := (not RatingEdit.Islayered)
  else
    CHRating := FFilesInfo.StatRating <> RatingEdit.Rating;

  CHKeyWords := VariousKeyWords(FFilesInfo.CommonKeyWords, KeyWordsMemo.Text);
  CHGroups := not FOldGroups.CompareTo(FNowGroups);

  UpdateControlFont(LabelComment, CHComment);
  UpdateControlFont(LabelKeywords, ChKeywords);
  UpdateControlFont(RatingLabel1, CHRating);
  UpdateControlFont(DateLabel1, ReadCHDate);
  UpdateControlFont(TimeLabel, ReadCHTime);
  UpdateControlFont(LbLinks, CHLinks);
  UpdateControlFont(CbInclude, CHInclude);

  BtSave.Enabled := CHDate or CHTime or CHRating or CHComment or ChKeywords or CHGroups or CHInclude or CHLinks;
end;

procedure TPropertiesForm.ImMainDblClick(Sender: TObject);
begin
  if No_file or not CommentMemo.Enabled then
    Exit;

  CommentMemo.Show;
  LabelComment.Show;
end;

procedure TPropertiesForm.BtSaveClick(Sender: TObject);
var
  I: Integer;
  IDArray: TArInteger;
  FileInfo: TMediaItem;
  UserInput: TUserDBInfoInput;
begin
  BtSave.SetEnabledEx(False);
  LockImput;
  try

    UserInput := TUserDBInfoInput.Create;
    try
      UserInput.Keywords := KeywordsMemo.Text;
      UserInput.Groups := FNowGroups.ToString;
      UserInput.IsCommentChanged := not CommentMemo.ReadOnly;
      UserInput.Comment := CommentMemo.Text;
      UserInput.IsLinksChanged := ReadCHLinks;
      UserInput.Links := CodeLinksInfo(FPropertyLinks);
      UserInput.IsIncludeChanged := ReadCHInclude;
      UserInput.Include := CbInclude.Checked;
      UserInput.IsRatingChanged := not RatingEdit.IsLayered;
      UserInput.Rating := RatingEdit.Rating;

      UserInput.IsDateChanged := ReadCHDate;
      UserInput.IsDateChecked := DateEdit.Checked;
      UserInput.Date := DateOf(DateEdit.Date);

      UserInput.IsTimeChanged := ReadCHTime;
      UserInput.IsTimeChecked := TimeEdit.Checked;
      UserInput.Time := TimeOf(TimeEdit.Date);

      if FShowInfoType = SHOW_INFO_IDS then
      begin

        BatchUpdateDBInfo(Self, FFilesInfo, UserInput);

        if Visible then
        begin
          SetLength(IDArray, FFilesInfo.Count);
          for I := 0 to FFilesInfo.Count - 1 do
            IDArray[I] := FFilesInfo[I].ID;

          FSaving := False;

          ExecuteEx(IDArray);
        end;
        Exit;
      end;

      if FShowInfoType = SHOW_INFO_ID then
      begin
        FSaving := False;

        UpdateDBRecordWithUserInfo(Self, FFilesInfo[0], UserInput);

      end else
      begin
        FSaving := False;

        FileInfo := TMediaItem.CreateFromFile(FileName);
        try
          FillDataRecordWithUserInfo(FileInfo, UserInput);

          UpdaterStorage.AddFile(FileInfo);
        finally
          F(FileInfo);
        end;
      end;

    finally
      F(UserInput);
    end;
  finally
    UnLockImput;
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
        if FileExistsSafe(FFilesInfo[I].FileName) then
          FileList.Add(FFilesInfo[I].FileName);
    end;
    Copy_Move(Application.Handle, True, FileList);
  finally
    FileList.Free;
  end;
end;

procedure TPropertiesForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(LabelPath.Text), nil, nil, SW_NORMAL);
end;

procedure TPropertiesForm.Show1Click(Sender: TObject);
begin
  Viewer.ShowImages(Sender, FFilesInfo);
  Viewer.Show;
  Viewer.Restore;
end;

procedure TPropertiesForm.TmrFilterTimer(Sender: TObject);
begin
  TmrFilter.Enabled := False;
  FillGroupList;
end;

procedure TPropertiesForm.TsGroupsResize(Sender: TObject);
var
  AvaliableWidth: Integer;
begin
  AvaliableWidth := TsGroups.Width - 3 * 4 - BtnAddGroup.Width;
  LstAvaliableGroups.Width := AvaliableWidth div 2;
  WedGroupsFilter.Width := LstAvaliableGroups.Width - (WedGroupsFilter.Left - ImSearch.Left);
  BtnAddGroup.Left := LstAvaliableGroups.Width + LstAvaliableGroups.Left + 3;
  BtnRemoveGroup.Left := BtnAddGroup.Left;
  lstCurrentGroups.Left := BtnAddGroup.Left + BtnAddGroup.Width + 3;
  LbCurrentGroups.Left := lstCurrentGroups.Left;
  lstCurrentGroups.Width := AvaliableWidth - LstAvaliableGroups.Width;
end;

procedure TPropertiesForm.Searchforit1Click(Sender: TObject);
var
  PR: TMediaInfo;
begin
  if FShowInfoType = SHOW_INFO_FILE_NAME then
  begin
    Pr := GetImageIDW(DBManager.DBContext, FileName, True);
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
  Rec: TMediaItem;
begin
  if FSaving then
  begin
    SetFocus;
    Exit;
  end;

  if not IsGraphicFile(FileName) or not FileExistsSafe(FileName) then
    Exit;

  TsGeneral.HandleNeeded;
  GistogrammData.Loading := False;
  PcMain.Pages[2].TabVisible := True;
  PcMain.Pages[3].TabVisible := True;

  DoProcessPath(FileName);
  SetLength(FPropertyLinks, 0);
  FreeList(FNowGroups, False);

  ExifData := TExifData.Create;
  try
    FFileDate := 0;
    try
      ExifData.LoadFromFileEx(FileName, False);
      if not ExifData.Empty and (ExifData.DateTimeOriginal > 0) then
      begin
        FFileDate := DateOf(ExifData.DateTimeOriginal);
        FFileTime := TimeOf(ExifData.DateTimeOriginal);
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
    if IsRAWSupport and IsRAWImageFile(FileName) then
    begin
      RAWExif := TRAWExif.Create;
      try
        RAWExif.LoadFromFile(FileName);
        if RAWExif.IsEXIF then
        begin
          //FDateTimeInFileExists := True;
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
  CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);
  Editing_info := False;

  Rec := TMediaItem.Create;
  Rec.FileName := FileName;
  FFilesInfo.Clear;
  FFilesInfo.Add(Rec);

  CommentMemo.Text := '';
  CommentMemo.PopupMenu := nil;

  RatingEdit.Islayered := False;

  ResetBold;
  ReloadGroups;

  LabelName.Text := ExtractFileName(FileName);
  LabelPath.Text := LongFileName(FileName);

  RatingEdit.Rating := 0;
  ImgReloadInfo.Visible := False;
  IDLabel.Text := L('Not available');

  if (FFileDate > 0) and (YearOf(FFileDate) > cMinEXIFYear) then
  begin
    DateEdit.DateTime := FFileDate;
    TimeEdit.Time := FFileTime;
  end else
  begin
    DateEdit.DateTime := DateOf(Now);
    TimeEdit.Time := TimeOf(Now);
  end;

  CbInclude.Checked := True;
  DateEdit.Checked := FDateTimeInFileExists;
  TimeEdit.Checked := FDateTimeInFileExists;

  LbViewCount.Caption := L('View counter unavailable');
  LbColors.Caption := L('Colors are unavailable');

  Rec.Date := DateEdit.DateTime;
  Rec.Time := TimeOf(TimeEdit.Time);
  Rec.IsTime := FDateTimeInFileExists;
  Rec.IsDate := FDateTimeInFileExists;

  SID := GetGUID;
  Options.FileName := FileName;
  Options.OnDone := OnDoneLoadingImage;
  Options.SID := SID;
  Options.Owner := Self;

  ImageLoadingFile.Visible := True;
  TPropertyLoadImageThread.Create(Options);

  WidthMemo.Text := L('Loading...');
  HeightMemo.Text := L('Loading...');

  SizeLabel.Text := SizeInText(GetFileSize(FileName));
  BtnFind.Visible := True;

  Editing_info := True;

  EnableEditing(not FolderView);

  Show;
end;

procedure TPropertiesForm.BeginAdding(Sender: TObject);
begin
  ImMainDblClick(Sender);
  BtSave.Enabled := False;
  Adding_now := True;
end;

procedure TPropertiesForm.EnableEditing(Value: Boolean);
begin
  if DBReadOnly then
    Value := False;

  CommentMemo.Enabled := Value;
  RatingEdit.Enabled := Value;
  DateEdit.Enabled := Value;
  TimeEdit.Enabled := Value;
  KeyWordsMemo.Enabled := Value;
  BtnAddGroup.Enabled := Value;
  BtnRemoveGroup.Enabled := Value;
  BtnNewGroup.Enabled := Value;
  LstAvaliableGroups.Enabled := Value;
  CbInclude.Enabled := Value;
  LinksScrollBox.Enabled := Value;
end;

procedure TPropertiesForm.EndAdding(Sender: TObject);
var
  PR : TMediaInfo;
begin
  Adding_now := False;
  Pr := GetimageIDW(FContext, FileName, True);
  if Pr.Count <> 0 then
    Execute(Pr.Ids[0])
  else
    MessageBoxDB(Handle, L('Unable to add this image!'), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TPropertiesForm.ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
var
  I, NewFileID: Integer;
  EventFileName: string;
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
          if FFilesInfo.HasNonDBInfo and (SetNewIDFileData in Params) then
          begin
            for I := 0 to FFilesInfo.Count - 1 do
              if AnsiLowerCase(FFilesInfo[I].FileName) = Value.FileName then
                FFilesInfo[I].ID := ID;
            Exit;
          end;
          if FFilesInfo.HasNonDBInfo and (EventID_CancelAddingImage in Params) then
          begin
            for I := 0 to FFilesInfo.Count - 1 do
              if AnsiLowerCase(FFilesInfo[I].FileName) = Value.FileName then
                FFilesInfo[I].ID := -1;
            Exit;
          end;
          if ID = 0 then
            Exit;

          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID = ID then
              ImgReloadInfo.Visible := True;
        end;
      SHOW_INFO_FILE_NAME:
        begin
          EventFileName := Value.NewName;
          if Trim(EventFileName) = '' then
            EventFileName := Value.FileName;

          if (AnsiLowerCase(EventFileName) = AnsiLowerCase(FileName)) and FileExistsSafe(EventFileName) then
          begin
            NewFileID := FMediaRepository.GetIdByFileName(FileName);
            if NewFileID = 0 then
              ExecuteFileNoEx(Value.NewName)
            else
              Execute(NewFileID);
            Exit;
          end;
        end;
    end;
  end;
end;

procedure TPropertiesForm.PmItemPopup(Sender: TObject);
var
  FE: Boolean;
begin
  SearchForIt1.Visible := FShowInfoType = SHOW_INFO_FILE_NAME ;
  FE := FileExistsSafe(FileName);
  Shell1.Visible := FE;
  if FShowInfoType <> SHOW_INFO_IDS then
    Show1.Visible := FE;
  if FShowInfoType <> SHOW_INFO_IDS then
    Show1.Visible := True;
  Copy1.Visible := FE;
  if FShowInfoType = SHOW_INFO_IDS then
    Copy1.Visible := True;
  DBItem1.Clear;
  FFilesInfo.ListItem := nil;
  FFilesInfo.IsListItem := False;
  TDBPopupMenu.Instance.AddDBContMenu(Self, DBItem1, FFilesInfo);
end;

procedure TPropertiesForm.FormDestroy(Sender: TObject);
begin
  F(LinkDropFiles);
  DropFileTarget1.Unregister;
  SaveWindowPos1.SavePosition;
  F(FFilesInfo);
  F(RegGroups);
  F(FNowGroups);
  F(FOldGroups);
  F(FShowenRegGroups);
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
  for I := 0 to FNowGroups.Count - 1 do
    LstCurrentGroups.Items.Add(FNowGroups[I].GroupName);
end;

procedure TPropertiesForm.ComboBox1_KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TPropertiesForm.ExecuteEx(IDs: TArInteger);
const
  AllocBy = 300;
var
  SQL: string;
  FirstID: Boolean;
  I, N, M, ALeft, Num, K: Integer;
  FInfo: TMediaItemCollection;
  MenuRecord: TMediaItem;
  WorkQuery: TDataSet;
begin
  if Length(IDs) = 0 then
    Exit;

  if FSaving then
  begin
    SetFocus;
    Exit;
  end;

  FInfo := TMediaItemCollection.Create;
  try
    WorkQuery := FContext.CreateQuery;
    try
      N := Trunc(Length(IDs) / AllocBy);
      if Length(IDs) / AllocBy - N > 0 then
        Inc(N);
      ALeft := Length(IDs);
      for K := 1 to N do
      begin
        M := Min(ALeft, Min(ALeft, AllocBy));

        FirstID := True;
        SQL := 'Select ID, Name, FFileName, Comment, Owner, Collection, Rotated, Access, Rating, DateToAdd, aTime, IsDate, IsTime, Groups, FileSize, KeyWords, Width, Height, Thum, Include, Links, Attr, StrTh FROM $DB$ Where ID in (';
        for I := 1 to M do
        begin
          Dec(ALeft);
          Num := I - 1 + AllocBy * (K - 1);

          if FirstID then
          begin
            SQL := SQL + ' ' + Inttostr(IDs[Num]) + ' ';
            FirstID := False;
          end else
            SQL := SQL + ' , ' + Inttostr(IDs[Num]) + ' ';
        end;
        SQL := SQL + ')';

        SetSQL(WorkQuery, SQL);
        try
          OpenDS(WorkQuery);
        except
          on e: Exception do
          begin
            MessageBoxDB(Handle, L('Unable to load info: ') +  e.Message, L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
            Exit;
          end;
        end;

        WorkQuery.First;
        FInfo.Clear;
        for I := 0 to WorkQuery.RecordCount - 1 do
        begin
          MenuRecord := TMediaItem.CreateFromDS(WorkQuery);
          MenuRecord.Selected := True;
          FInfo.Add(MenuRecord);
          WorkQuery.Next;
        end;
      end;
    finally
      FreeDS(WorkQuery);
    end;

    ExecuteEx(FInfo);
  finally
    F(FInfo);
  end;
end;

procedure TPropertiesForm.ExecuteEx(Data: TMediaItemCollection; Image: TBitmap = nil);
var
  I: Integer;
  B: TBitmap;
  Ico: TIcon;
  S: string;
begin
  if Data.Count = 0 then
  begin
    MessageBoxDB(Handle, L('Unable to load info: item not found!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;
  if Data.Count = 1 then
  begin
    if Data[0].ID = 0 then
      ExecuteFileNoEx(Data[0].FileName)
    else
      Execute(Data[0].ID);
    Exit;
  end;
  FFilesInfo.Assign(Data);

  FMediaRepository.UpdateMediaInfosFromDB(Data);

  for I := 0 to FFilesInfo.Count - 1 do
    if FFilesInfo[I].ID = 0 then
       FFilesInfo[I].Include := True;

  TsGeneral.HandleNeeded;
  GistogrammData.Loading := False;
  R(EditLinkForm);
  ResetBold;

  PcMain.Pages[2].TabVisible := False;
  PcMain.Pages[3].TabVisible := False;

  Editing_info := False;
  try
    CbInclude.AllowGrayed := True;
    PcMain.ActivePageIndex := 0;
    ImgReloadInfo.Visible := False;
    DateEdit.Enabled := True;
    TimeEdit.Enabled := True;
    CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);

    FShowInfoType := SHOW_INFO_IDS;

    if Image <> nil then
      ImMain.Picture.Graphic := Image
    else
    begin
      B := TBitmap.Create;
      try
        B.PixelFormat := pf24bit;
        B.SetSize(100, 100);
        B.Canvas.Brush.Color := Theme.WindowColor;
        B.Canvas.Pen.Color := RGB(Round(GetRValue(ColorToRGB(Theme.WindowColor)) * 0.8),
          Round(GetGValue(ColorToRGB(Theme.WindowColor)) * 0.8), Round(GetBValue(ColorToRGB(Theme.WindowColor)) * 0.8));
        B.Canvas.Rectangle(0, 0, 100, 100);
        Ico := TIcon.Create;
        try
          Ico.Handle := CopyIcon(Icons[DB_IC_MANY_FILES]);
          B.Canvas.Draw(100 div 2 - Ico.Width div 2, 100 div 2 - Ico.Height div 2, Ico);
        finally
          F(Ico);
        end;
        ImMain.Picture.Graphic := B;
      finally
        F(B);
      end;
    end;

    Caption := L('Properties') + ' - ' + ExtractFileName(FFilesInfo[0].FileName) + L('...');
    SizeLAbel.Text := SizeInText(FFilesInfo.FilesSize);

    if FFilesInfo.IsVariousInclude then
      CbInclude.State := cbGrayed
    else
    begin
      if FFilesInfo[0].Include then
        CbInclude.State := cbChecked
      else
        CbInclude.State := cbUnchecked;
    end;

    if FFilesInfo.IsVariousWidth then
      WidthMemo.Text := L('Different width')
    else
      WidthMemo.Text := Format(L('All - %spx.'), [IntToStr(FFilesInfo[0].Width)]);

    if FFilesInfo.IsVariousHeight then
      HeightMemo.Text := L('Different height')
    else
      HeightMemo.Text := Format(L('All - %spx.'), [IntToStr(FFilesInfo[0].Height)]);

    LabelName.Text := L('Different files');
    if FFilesInfo.IsVariousLocation then
      LabelPath.Text := L('Different directories')
    else
    begin
      S := ExcludeTrailingBackslash(ExtractFileDir(FFilesInfo[0].FileName));
      LabelPath.Text := Format(L('All in %s'), [LongFileName(S)]);
    end;

    RatingEdit.Rating := FFilesInfo.StatRating;
    RatingEdit.Islayered := True;
    RatingEdit.Layered := 100;
    TimeEdit.Time := FFilesInfo.StatTime;
    DateEdit.DateTime := FFilesInfo.StatDate;

    DateEdit.Checked := FFilesInfo.StatIsDate and not FFilesInfo.IsVariousDate;
    TimeEdit.Checked := FFilesInfo.StatIsTime and not FFilesInfo.IsVariousTime;

    KeyWordsMemo.Text := FFilesInfo.CommonKeyWords;
    IDLabel.Text := Format(L('%d files are selected'), [FFilesInfo.Count]);

    if FFilesInfo.IsVariousComments then
    begin
      CommentMemo.ReadOnly := True;
      CommentMemo.PopupMenu := PmComment;
      CommentMemo.Cursor := crHandPoint;
      CommentMemo.Text := L('Different comments');
    end else
    begin
      CommentMemo.ReadOnly := False;
      CommentMemo.PopupMenu := nil;
      CommentMemo.Cursor := crDefault;
      CommentMemo.Text := FFilesInfo.CommonComments;
    end;

    F(FNowGroups);
    FNowGroups := TGroups.CreateFromString(FFilesInfo.CommonGroups);
    F(FOldGroups);
    FOldGroups := FNowGroups.Clone;

    ItemLinks := FFilesInfo.CommonLinks;
    FPropertyLinks := CopyLinksInfo(ItemLinks);

    ReloadGroups;
    DBItem1.Visible := True;
    FFilesInfo.IsListItem := False;
    CommentMemoChange(Self);
    BtnFind.Visible := False;
    ImageLoadingFile.Visible := False;

    LbViewCount.Caption := FormatEx(L('Total views: {0}'), [FFilesInfo.TotalViews]);
    LbColors.Caption := L('Colors are unavailable');

    Show;
    SID := GetGUID;
    EnableEditing(True);
  finally
    Editing_info := True;
  end;
end;

procedure TPropertiesForm.FormShow(Sender: TObject);
begin
  BtDone.SetFocus;
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
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataGroups);
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
  CollectionEvents.UnRegisterChangesIDbyID(Self, ChangedDBDataByID, ImageId);
  Release;
end;

procedure TPropertiesForm.Ratingnotsets1Click(Sender: TObject);
begin
  RatingEdit.Islayered := True;
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PmRatingNotAvaliablePopup(Sender: TObject);
begin
  Ratingnotsets1.Visible := not RatingEdit.Islayered;
  if FShowInfoType <> SHOW_INFO_IDS then
    Ratingnotsets1.Visible := False;
  Ratingnotsets1.Visible := Ratingnotsets1.Visible and not FSaving;
end;

procedure TPropertiesForm.CommentMemoDblClick(Sender: TObject);
begin
  if not CommentMemo.Readonly then
    Exit;
  CommentMemo.readonly := False;
  CommentMemo.Cursor := CrDefault;
  CommentMemo.Text := '';
  CommentMemoChange(Sender);
end;

procedure TPropertiesForm.PmCommentPopup(Sender: TObject);
begin
  SetComent1.Visible := CommentMemo.Readonly;
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
  CommentMemoDblClick(Sender);
  CommentMemo.PasteFromClipboard;
end;

procedure TPropertiesForm.Undo1Click(Sender: TObject);
begin
  CommentMemo.Undo;
end;

procedure TPropertiesForm.LoadLanguage;
begin
  Caption := L('Properties');
  LabelComment.Caption := L('Comment') + ':';
  LabelName1.Caption := L('Name') + ':';
  Label4.Caption := L('Full path') + ':';
  RatingLabel1.Caption := L('Rating') + ':';
  DateLabel1.Caption := L('Date') + ':';
  TimeLabel.Caption := L('Time') + ':';
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
  DBItem1.Caption := L('Collection Item');
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
  PcMain.Pages[3].Caption := L('Histogram');
  PcMain.Pages[4].Caption := L('Additional');

  Label2.Caption := L('Histogram image') + ':';
  RgGistogrammChannel.Caption := L('Channel');
  RgGistogrammChannel.Items[0] := L('All channels');
  RgGistogrammChannel.Items[1] := L('Gray');
  RgGistogrammChannel.Items[2] := L('Red channel');
  RgGistogrammChannel.Items[3] := L('Green channel');
  RgGistogrammChannel.Items[4] := L('Blue channel');
  CopyCurrent1.Caption := L('Copy line');
  CopyAll1.Caption := L('Copy all information');
  CbInclude.Caption := L('Include in base search');
  LbLinks.Caption := L('Links for photo(s)') + ':';
  Addnewlink1.Caption := L('Add link');
  WlAddLink.Text := L('Add link');

  Open1.Caption := L('Open');
  OpenFolder1.Caption := L('Open folder');
  Up1.Caption := L('Move up');
  Down1.Caption := L('Move down');
  Change1.Caption := L('Change');
  Delete1.Caption := L('Delete');
  BtnNewGroup.Caption := L('Create group');
  LbAvaliableGroups.Caption := L('Available groups') + ':';
  LbCurrentGroups.Caption := L('Selected groups') + ':';
  Clear1.Caption := L('Clear');
  MenuItem1.Caption := L('Delete');
  CreateGroup1.Caption := L('Create group');
  ChangeGroup1.Caption := L('Change group');
  QuickInfo1.Caption := L('Info');
  SearchForGroup1.Caption := L('Search group photos');
  CbShowAllGroups.Caption := L('Show all groups');
  CbRemoveKeywordsForGroups.Caption := L('Remove unused keywords');
  MoveToGroup1.Caption := L('Move to group');

  LbGroupsEditInfo.Caption := L('Use button "-->" to add new groups or button "<--" to remove them');
  Cancel1.Caption := L('Cancel');
  AddImThProcessingImageAndAddOriginalToProcessingPhoto1.Caption := L('Connect this photo with processed (Add link to this photo to processed)');
  AddImThLink1.Caption := L('Connect this photo with processed');
  AddOriginalImThAndAddProcessngToOriginalImTh1.Caption := L('Connect this photo with original (Add link to this photo to original)');
  AddOriginalImTh1.Caption := L('Connect this photo with original');

  VleExif.TitleCaptions[0] := L('Key');
  VleExif.TitleCaptions[1] := L('Value');

  WedGroupsFilter.WatermarkText := L('Filter groups');
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

        if not GistogrammData.Loaded and not GistogrammData.Loading then
        begin
          GistogrammData.Loaded := True;
          Options.FileName := FileName;
          Options.Owner := Self;
          Options.SID := SID;
          Options.OnDone := OnDoneLoadGistogrammData;
          Options.Password := FCurrentPass;
          TPropertyLoadGistogrammThread.Create(Options);
          OnDoneLoadGistogrammData(Self);
        end;
      end;
    4:
      begin
        ReadLinks;
        WlAddLink.Top := LinksScrollBox.Top + LinksScrollBox.Height + 3;
      end;
  end;

  //TODO: Sometimes tabs doesn't redraw after change
  //SendMessage(PcMain.Handle, WM_SETREDRAW, 1, 0);
  //RedrawWindow(PcMain.Handle, nil, 0, RDW_ERASENOW + RDW_FRAME + RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_INTERNALPAINT );
  //InvalidateRect(PcMain.Handle, nil, True);
end;

procedure TPropertiesForm.ReadExifData;
begin
  LoadExifInfo(VleExif, FileName);
  TEXIFDisplayControl(VleExif).UpdateRowsHeight;
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
      DgGistogramm.ColorTo := $FFFFFF;
    2:
      DgGistogramm.ColorTo := $0000FF;
    3:
      DgGistogramm.ColorTo := $00FF00;
    4:
      DgGistogramm.ColorTo := $FF0000;
  end;
  OnDoneLoadGistogrammData(Sender);
end;

procedure TPropertiesForm.ResetBold;
begin
  UpdateControlFont(LabelComment, False);
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

procedure TPropertiesForm.WedGroupsFilterChange(Sender: TObject);
begin
  TmrFilter.Restart;
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
      Links[I].Font.Color := ColorDiv2(Theme.PanelColor, Theme.PanelFontColor)
    else
      Links[I].Font.Color := Theme.PanelColor;

    Links[I].Color := LinksScrollBox.Color;
    Links[I].Width := LinksScrollBox.Width - 10;
    Links[I].Text := LI[I].LinkName;
    Links[I].Tag := I;
    Links[I].OnClick := LinkClick;
    Links[I].OnContextPopup := LinkOnPopup;
    //
    Icon := TIcon.Create;
    try
      case LI[I].LinkType of
        LINK_TYPE_ID:
          Icon.Handle := CopyIcon(Icons[DB_IC_SLIDE_SHOW]);
        LINK_TYPE_ID_EXT:
          Icon.Handle := CopyIcon(Icons[DB_IC_NOTES]);
        LINK_TYPE_IMAGE:
          Icon.Handle := CopyIcon(Icons[DB_IC_DESKTOP]);
        LINK_TYPE_FILE:
          Icon.Handle := CopyIcon(Icons[DB_IC_SHELL]);
        LINK_TYPE_FOLDER:
          Icon.Handle := CopyIcon(Icons[DB_IC_DIRECTORY]);
        LINK_TYPE_TXT:
          Icon.Handle := CopyIcon(Icons[DB_IC_TEXT_FILE]);
        LINK_TYPE_HTML:
          Icon.Handle := CopyIcon(Icons[DB_IC_SLIDE_SHOW]);
      end;
      Links[I].Icon := Icon;
      Links[I].Refresh;
    finally
      F(Icon);
    end;
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
  TIRA: TMediaInfo;
  P: TPoint;
  S, DN: string;

  procedure ViewFile(FileName: string);
  begin
    Viewer.ShowImage(Self, FileName);
    Viewer.Show;
    Viewer.Restore;
  end;

begin
  GetCursorPos(P);
  N := TWebLink(Sender).Tag;
  LI := CopyLinksInfo(FPropertyLinks);
  case LI[N].LinkType of
    LINK_TYPE_ID:
      ViewFile(FMediaRepository.GetFileNameById(StrToIntDef(LI[N].LinkValue, 0)));
    LINK_TYPE_ID_EXT:
      begin
        TIRA := GetImageDuplicates(FContext, DeCodeExtID(LI[N].LinkValue));
        if TIRA.Count > 0 then
          ViewFile(TIRA.FileNames[0]);
      end;
    LINK_TYPE_IMAGE:
      ViewFile(LI[N].LinkValue);
    LINK_TYPE_FILE:
      begin
        S := ExcludeTrailingBackslash(LI[N].LinkValue);
        ShellExecute(Handle, 'open', PWideChar(LI[N].LinkValue), nil, PWideChar(S), SW_NORMAL);
      end;
    LINK_TYPE_FOLDER:
      begin
        DN := ExcludeTrailingBackslash(LI[N].LinkValue);
        if (DN <> '') and not DirectoryExists(DN) then
        begin
          MessageBoxDB(Handle, Format(L('Directory "%s" not found!'), [DN]), L('Warning'), TD_BUTTON_OK,
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
  MenuInfo: TMediaItemCollection;
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
      MenuInfo := FMediaRepository.GetMenuItemsByID(ID);
      try
        MenuInfo.IsPlusMenu := False;
        MenuInfo.IsListItem := False;
        IDMenu1.Caption := Format(L('Collection Item [%d]'), [ID]);
        TDBPopupMenu.Instance.AddDBContMenu(Self, IDMenu1, MenuInfo);
      finally
        F(MenuInfo);
      end;
      DoExit;
      Exit;
    end;
  if LI[N].LinkType = LINK_TYPE_ID_EXT then
    if LI[N].Tag and LINK_TAG_VALUE_VAR_NOT_SELECT = 0 then
    begin
      IDMenu1.Visible := True;
      MenuInfo := FMediaRepository.GetMenuInfosByUniqId(DeCodeExtID(LI[N].LinkValue));
      try
        MenuInfo.IsPlusMenu := False;
        MenuInfo.IsListItem := False;

        if MenuInfo.Count > 0 then
          IDMenu1.Caption := Format(L('Collection Item [%d]'), [MenuInfo[0].ID])
        else
          IDMenu1.Caption := Format(L('Collection Item [%d]'), [0]);

        TDBPopupMenu.Instance.AddDBContMenu(Self, IDMenu1, MenuInfo);
      finally
        F(MenuInfo);
      end;
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
  TIRA: TMediaInfo;
begin
  N := PmLinks.Tag;
  DN := '';
  FN := '';
  case FPropertyLinks[N].LinkType of
    LINK_TYPE_ID:
      FN := FMediaRepository.GetFileNameById(StrToIntDef(FPropertyLinks[N].LinkValue, 0));
    LINK_TYPE_ID_EXT:
      begin
        TIRA := GetImageDuplicates(FContext, DeCodeExtID(FPropertyLinks[N].LinkValue));
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
  if FN <> '' then
    DN := ExtractFileDir(FN);

  if (DN <> '') and not DirectoryExists(DN) then
  begin
    MessageBoxDB(Handle, Format(L('Directory "%s" not found!'), [DN]), L('Warning'), TD_BUTTON_OK,
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

procedure TPropertiesForm.BtnNewGroupClick(Sender: TObject);
begin
  GroupCreateForm.CreateGroup;
end;

procedure TPropertiesForm.RecreateGroupsList;
var
  I: Integer;
  B: TBitmap;

  procedure CreateDefaultImage(B: TBitmap);
  begin
    B.PixelFormat := pf24bit;
    B.SetSize(16, 16);
    FillColorEx(B, Theme.PanelColor);
    DrawIconEx(B.Canvas.Handle, 0, 0, Icons[DB_IC_GROUPS], 16, 16, 0, 0, DI_NORMAL);
  end;

begin
  F(RegGroups);
  RegGroups := FGroupsRepository.GetAll(True, True);
  RegGroupsImageList.Clear;
  B := TBitmap.Create;
  try
    CreateDefaultImage(B);
    RegGroupsImageList.Add(B, nil);
  finally
    F(B);
  end;

  for I := 0 to RegGroups.Count - 1 do
  begin
    B := TBitmap.Create;
    try
      if (RegGroups[I].GroupImage <> nil) and not RegGroups[I].GroupImage.Empty then
      begin
        B.PixelFormat := pf24bit;
        AssignGraphic(B, RegGroups[I].GroupImage);
        CenterBitmap24To32ImageList(B, 16);
      end else
        CreateDefaultImage(B);

      RegGroupsImageList.Add(B, nil);
    finally
      F(B);
    end;
  end;
  FillGroupList;
end;

procedure TPropertiesForm.FillGroupList;
var
  I: Integer;
  Filter, Key: string;
begin
  FreeList(FShowenRegGroups, False);

  LstAvaliableGroups.Items.BeginUpdate;
  try
    LstAvaliableGroups.Clear;
    Filter := AnsiLowerCase(WedGroupsFilter.Text);

    if Pos('*', Filter) = 0 then
      Filter := '*' + Filter + '*';

    for I := 0 to RegGroups.Count - 1 do
    begin
      Key := AnsiLowerCase(RegGroups[I].GroupName + ' ' + RegGroups[I].GroupComment + ' ' + RegGroups[I].GroupKeyWords);
      if (RegGroups[I].IncludeInQuickList or CbShowAllGroups.Checked) and IsMatchMask(Key, Filter) then
      begin
        FShowenRegGroups.AddGroup(RegGroups[I]);
        LstAvaliableGroups.Items.AddObject(RegGroups[I].GroupName, TObject(I));
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
  FC, C: TColor;
  IsChoosed: Boolean;
  ACanvas: TCanvas;
  LB: TListBox;

  function NewGroup(GroupCode: string): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to XNewGroups.Count - 1 do
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
    for J := 0 to FNowGroups.Count - 1 do
      if FNowGroups[J].GroupCode = GroupCode then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if Control = LstCurrentGroups then
  begin
    XNewGroups := FNowGroups.Clone;
    XNewGroups.RemoveGroups(FOldGroups);
  end else
  begin
    XNewGroups := FOldGroups.Clone;
    XNewGroups.RemoveGroups(FNowGroups);
  end;
  try
    LB := TListBox(Control);
    ACanvas := LB.Canvas;

    ACanvas.FillRect(Rect);

    if Index = -1 then
      Exit;

    N := -1;
    if Control = LstCurrentGroups then
    begin
      for I := 0 to RegGroups.Count - 1 do
      begin
        if RegGroups[I].GroupCode = FNowGroups[index].GroupCode then
        begin
          N := I + 1;
          Break;
        end;
      end
    end else
    begin
      for I := 0 to RegGroups.Count - 1 do
      begin
        if RegGroups[I].GroupName = (Control as TListBox).Items[index] then
        begin
          N := I + 1;
          Break;
        end;
      end
    end;

    RegGroupsImageList.Draw(ACanvas, Rect.Left + 2, Rect.Top + 2, Max(0, N));
    if N = -1 then
      DrawIconEx(ACanvas.Handle, Rect.Left + 10, Rect.Top + 8, Icons[DB_IC_DELETE_INFO], 8, 8, 0, 0, DI_NORMAL);

    IsChoosed := False;
    if Control = LstCurrentGroups then
      IsChoosed := NewGroup(FNowGroups[Index].GroupCode)
    else if (N > -1) and (N < RegGroups.Count) then
      IsChoosed := NewGroup(RegGroups[N - 1].GroupCode);

    if IsChoosed then
      ACanvas.Font.Style := ACanvas.Font.Style + [FsBold]
    else
      ACanvas.Font.Style := ACanvas.Font.Style - [FsBold];

    if (Control = LstAvaliableGroups) then
    begin
      if odSelected in State then
      begin
        FC := Theme.ListFontSelectedColor;
        C := Theme.ListSelectedColor;
      end else
      begin
        FC := Theme.ListFontColor;
        C := Theme.ListColor;
      end;

      if (Index < FShowenRegGroups.Count) and GroupExists(FShowenRegGroups[Index].GroupCode) then
        ACanvas.Font.Color := ColorDiv2(FC, C)
      else
        ACanvas.Font.Color := FC;
    end;

    ACanvas.TextOut(Rect.Left + 21, Rect.Top + 3, LB.Items[index]);
  except
    on E: Exception do
      EventLog(':TPropertiesForm.ListBox2DrawItem() throw exception: ' + E.message);
  end;
  F(XNewGroups);
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
      Group := FGroupsRepository.GetByCode(FNowGroups[I].GroupCode, False);
      try
        GroupInfoForm.Execute(nil, Group, False);
      finally
        F(Group);
      end;
      Break;
    end;
end;

procedure TPropertiesForm.BtnAddGroupClick(Sender: TObject);
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
    FRelatedGroups := TGroups.CreateFromString(Group.RelatedGroups);
    OldGroups := FNowGroups.Clone;
    Groups := OldGroups.Clone;
    try
      Groups.AddGroup(Group);
      Groups.AddGroups(FRelatedGroups);
      F(FNowGroups);
      FNowGroups := Groups.Clone;
      Groups.RemoveGroups(OldGroups);
      for I := 0 to Groups.Count - 1 do
      begin
        LstCurrentGroups.Items.Add(Groups[I].GroupName);
        TempGroup := FGroupsRepository.GetByCode(Groups[I].GroupCode, False);
        try
          KeyWords := KeyWordsMemo.Text;
          AddWordsA(TempGroup.GroupKeyWords, KeyWords);
          KeyWordsMemo.Text := KeyWords;
        finally
          F(TempGroup);
        end;
      end;
    finally
      F(OldGroups);
      F(Groups);
      F(FRelatedGroups);
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

procedure TPropertiesForm.BtnRemoveGroupClick(Sender: TObject);
var
  I, J: Integer;
  KeyWords, AllGroupsKeyWords, GroupKeyWords: string;
begin
  for I := LstCurrentGroups.Items.Count - 1 downto 0 do
    if LstCurrentGroups.Selected[I] then
    begin
      if CbRemoveKeywordsForGroups.Checked then
      begin
        AllGroupsKeyWords := '';
        for J := LstCurrentGroups.Items.Count - 1 downto 0 do
          if I <> J then
            AddWordsA(RegGroups[AGetGroupByCode(FNowGroups[J].GroupCode)].GroupKeyWords, AllGroupsKeyWords);

        KeyWords := KeyWordsMemo.Text;
        GroupKeyWords := RegGroups[AGetGroupByCode(FNowGroups[I].GroupCode)].GroupKeyWords;
        DeleteWords(GroupKeyWords, AllGroupsKeyWords);
        DeleteWords(KeyWords, GroupKeyWords);
        KeyWordsMemo.Text := KeyWords;
      end;
      // remove from current groups
      FNowGroups.RemoveGroup(FNowGroups[I]);
      LstCurrentGroups.Items.Delete(I);
    end;
  LstCurrentGroups.Invalidate;
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
  end else
  begin
    for I := 0 to LstCurrentGroups.Items.Count - 1 do
      LstCurrentGroups.Selected[I] := False;
    PmClear.Popup(LstCurrentGroups.ClientToScreen(MousePos).X, LstCurrentGroups.ClientToScreen(MousePos).Y);
  end;
end;

procedure TPropertiesForm.Clear1Click(Sender: TObject);
begin
  LstCurrentGroups.Clear;
  F(FNowGroups);
  CommentMemoChange(Sender);
  LstCurrentGroups.Invalidate;
  LstAvaliableGroups.Invalidate;
end;

procedure TPropertiesForm.CbShowAllGroupsClick(Sender: TObject);
begin
  RecreateGroupsList;
  AppSettings.WriteBool('Propetry', 'ShowAllGroups', CbShowAllGroups.Checked);
end;

procedure TPropertiesForm.LstAvaliableGroupsDblClick(Sender: TObject);
begin
  if FSaving then
    Exit;
  BtnAddGroupClick(Sender);
end;

function TPropertiesForm.AGetGroupByCode(GroupCode: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to RegGroups.Count - 1 do
    if RegGroups[I].GroupCode = GroupCode then
    begin
      Result := I;
      Break;
    end;
end;

procedure TPropertiesForm.CreateGroup1Click(Sender: TObject);
begin
  GroupCreateForm.CreateFixedGroup(FNowGroups[PopupMenuGroups.Tag].GroupName, FNowGroups[PopupMenuGroups.Tag].GroupCode);
end;

procedure TPropertiesForm.ChangeGroup1Click(Sender: TObject);
var
  Group: TGroup;
begin
  Group := FGroupsRepository.GetByCode(FNowGroups[PopupMenuGroups.Tag].GroupCode, False);
  try
    DBChangeGroup(Group);
  finally
    F(Group);
  end;
end;

function TPropertiesForm.GetCurrentImageFileName: string;
begin
  Result := GetFileName;
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

procedure TPropertiesForm.SearchForGroup1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cGroupsPath + '\' + FNowGroups[PopupMenuGroups.Tag].GroupName);
    Show;
  end;
end;

procedure TPropertiesForm.QuickInfo1Click(Sender: TObject);
begin
  GroupInfoForm.Execute(nil, FNowGroups[PopupMenuGroups.Tag], False);
end;

procedure TPropertiesForm.PopupMenuGroupsPopup(Sender: TObject);
begin
  if FGroupsRepository.HasGroupWithCode(FNowGroups[PopupMenuGroups.Tag].GroupCode) then
  begin
    CreateGroup1.Visible := False;
    MoveToGroup1.Visible := False;
    ChangeGroup1.Visible := True;
  end else
  begin
    CreateGroup1.Visible := True;
    MoveToGroup1.Visible := True;
    ChangeGroup1.Visible := False;
  end;
end;

procedure TPropertiesForm.CbRemoveKeywordsForGroupsClick(Sender: TObject);
begin
  AppSettings.WriteBool('Propetry', 'DeleteKeyWords', CbRemoveKeywordsForGroups.Checked);
end;

procedure TPropertiesForm.MoveToGroup1Click(Sender: TObject);
var
  ToGroup: TGroup;
begin
  if SelectGroup(ToGroup) then
  begin
    MoveGroup(FContext, FNowGroups[PopupMenuGroups.Tag], ToGroup);
    MessageBoxDB(Handle, L('Reload info'), L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
  end;
end;

procedure TPropertiesForm.ChangedDBDataGroups(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
begin
  if EventID_Param_DB_Changed in Params then
  begin
    Close;
    Exit;
  end;
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
  RatingEdit.Enabled := False;
  KeyWordsMemo.Enabled := False;
  DateEdit.Enabled := False;
  TimeEdit.Enabled := False;
  CbInclude.Enabled := False;
  LstAvaliableGroups.Enabled := False;
  LstCurrentGroups.Enabled := False;
  BtnAddGroup.Enabled := False;
  BtnRemoveGroup.Enabled := False;
end;

procedure TPropertiesForm.UnLockImput;
begin
  FSaving := False;
  RatingEdit.Enabled := True;
  KeyWordsMemo.Enabled := True;
  DateEdit.Enabled := True;
  TimeEdit.Enabled := True;
  CbInclude.Enabled := True;
  LstAvaliableGroups.Enabled := True;
  LstCurrentGroups.Enabled := True;
  BtnAddGroup.Enabled := True;
  BtnRemoveGroup.Enabled := True;
end;

procedure TPropertiesForm.PmClearPopup(Sender: TObject);
begin
  Clear1.Visible := (lstCurrentGroups.Items.Count <> 0) and not FSaving;
end;

procedure TPropertiesForm.DrawColors(Colors: string);
var
  I, J, Left, C: Integer;
  S: string;
  Items: TStrings;
  Palette: TPaletteArray;
  PaletteHLS: TPaletteHLSArray;
  Shape: TShape;
begin
  for I := TsGeneral.ControlCount - 1 downto 0 do
    if TsGeneral.Controls[I] is TShape then
      TsGeneral.Controls[I].Free;

  Items := TStringList.Create;
  try
    Items.Delimiter := '#';
    Items.StrictDelimiter := True;
    Items.DelimitedText := Colors;

    FillColors(Palette, PaletteHLS);

    Left := IDLabel.Left;
    for I := 0 to Items.Count - 1 do
    begin
      C := HexToIntDef(Items[I], 0);
      S := '#' + Items[I];
      if S = '#BW' then
        Continue;

      for J := 0 to ColorCount - 1 do
        if Palette[J] = C then
          S := TA(PaletteColorNames[J], 'Colors');

      Shape := TShape.Create(TsGeneral);
      Shape.Parent := TsGeneral;
      Shape.Top := IDLabel.Top + IDLabel.Height + 5;
      Shape.Left := Left;
      Shape.Width := 12;
      Shape.Height := 12;
      Shape.Brush.Color := C;
      Shape.Pen.Color := C;
      Shape.Hint := S;
      Shape.ShowHint := True;

      Inc(Left, Shape.Width + 3);
    end;
  finally
    F(Items);
  end;
end;

procedure TPropertiesForm.DropFileTarget2Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 if FShowInfoType <> SHOW_INFO_FILE_NAME then
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
  Info: TMediaItem;
  LinkInfo: TLinkInfo;
  I: Integer;
  B: Boolean;
begin
  Info := TMediaItem.Create;
  try
    Info.FileName := LinkDropFiles[0];
    FMediaRepository.UpdateMediaFromDB(Info, False);

    if Info.LongImageID = '' then
      Info.LongImageID := GetImageIDW(FContext, LinkDropFiles[0], True).ImTh;
    LinkInfo.LinkType := LINK_TYPE_ID_EXT;
    LinkInfo.LinkName := L('Processing');
    LinkInfo.LinkValue := CodeExtID(Info.LongImageID);
    B := True;
    for I := 0 to Length(FPropertyLinks) - 1 do
      if FPropertyLinks[I].LinkName = L('Processing') then
      begin
        B := False;
        Break;
      end;
    if B then
    begin
      SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
      FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
    end;
  finally
    F(Info);
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddOriginalImTh1Click(Sender: TObject);
var
  Info: TMediaItem;
  LinkInfo: TLinkInfo;
  I: Integer;
  B: Boolean;
begin
  Info := TMediaItem.Create;
  try
    Info.FileName := LinkDropFiles[0];
    FMediaRepository.UpdateMediaFromDB(Info, False);

    if Info.LongImageID = '' then
      Info.LongImageID := GetImageIDW(FContext, LinkDropFiles[0], True).ImTh;
    LinkInfo.LinkType := LINK_TYPE_ID_EXT;
    LinkInfo.LinkName := L('Original');
    LinkInfo.LinkValue := CodeExtID(Info.LongImageID);
    B := True;
    for I := 0 to Length(FPropertyLinks) - 1 do
      if FPropertyLinks[I].LinkName = L('Original') then
      begin
        B := False;
        Break;
      end;
    if B then
    begin
      SetLength(FPropertyLinks, Length(FPropertyLinks) + 1);
      FPropertyLinks[Length(FPropertyLinks) - 1] := LinkInfo;
    end;
  finally
    F(Info);
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddImThProcessingImageAndAddOriginalToProcessingPhoto1Click(
  Sender: TObject);
var
  Info: TMediaItem;
  LinkInfo: TLinkInfo;
  LinksInfo: TLinksInfo;
  Query: TDataSet;
  I: Integer;
  B: Boolean;
begin
  Info := TMediaItem.Create;
  try
    Info.FileName := LinkDropFiles[0];
    FMediaRepository.UpdateMediaFromDB(Info, False);

    if Info.LongImageID = '' then
      Info.LongImageID := GetImageIDW(FContext, LinkDropFiles[0], True).ImTh;
    LinkInfo.LinkType := LINK_TYPE_ID_EXT;
    LinkInfo.LinkName := L('Processing');
    LinkInfo.LinkValue := CodeExtID(Info.LongImageID);
    B := True;
    for I := 0 to Length(FPropertyLinks) - 1 do
      if FPropertyLinks[I].LinkName = L('Processing') then
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
    LinksInfo[0].LinkName := L('Original');
    LinksInfo[0].LinkValue := CodeExtID(FFilesInfo[0].LongImageID);
    ReplaceLinks('', CodeLinksInfo(LinksInfo), Info.Links);
    Query := FContext.CreateQuery;
    try
      SetSQL(Query, Format('UPDATE $DB$ Set Links = :Links where ID = %d', [Info.ID]));
      SetStrParam(Query, 0, Info.Links);
      ExecSQL(Query);
    finally
      FreeDS(Query);
    end;
  finally
    F(Info);
  end;
  ReadLinks;
  SetFocus;
end;

procedure TPropertiesForm.AddOriginalImThAndAddProcessngToOriginalImTh1Click(
  Sender: TObject);
var
  Info: TMediaItem;
  LinkInfo: TLinkInfo;
  LinksInfo: TLinksInfo;
  Query: TDataSet;
  I: Integer;
  B: Boolean;
begin
  Info := TMediaItem.Create;
  try
    Info.FileName := LinkDropFiles[0];
    FMediaRepository.UpdateMediaFromDB(Info, False);

    if Info.LongImageID = '' then
      Info.LongImageID := GetImageIDW(FContext, LinkDropFiles[0], True).ImTh;
    LinkInfo.LinkType := LINK_TYPE_ID_EXT;
    LinkInfo.LinkName := L('Original');
    LinkInfo.LinkValue := CodeExtID(Info.LongImageID);
    B := True;
    for I := 0 to Length(FPropertyLinks) - 1 do
      if FPropertyLinks[I].LinkName = L('Original') then
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
    LinksInfo[0].LinkName := L('Processing');
    LinksInfo[0].LinkValue := CodeExtID(FFilesInfo[0].LongImageID);
    ReplaceLinks('', CodeLinksInfo(LinksInfo), Info.Links);
    Query := FContext.CreateQuery;
    try
      SetSQL(Query, Format('UPDATE $DB$ Set Links = :Links where ID = %d', [Info.ID]));
      SetStrParam(Query, 0, Info.Links);
      ExecSQL(Query);
    finally
      FreeDS(Query);
    end;
  finally
    F(Info);
  end;
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
  Bitmap: TBitmap;
  MinC, MaxC: Integer;
begin
  if Sender is TPropertyLoadGistogrammThread then
  begin
    GistogrammData.Loaded := True;
    GistogrammData.Loading := True;
  end
  else if not GistogrammData.Loaded then
    FillChar(GistogrammData, SizeOf(GistogrammData), #0);

  Bitmap := TBitmap.Create;
  try
    case RgGistogrammChannel.ItemIndex of
      0:
        GetGistogrammBitmapWRGB(130, GistogrammData.Gray, GistogrammData.Red, GistogrammData.Green, GistogrammData.Blue, MinC, MaxC, Bitmap, clGray);
      1:
        GetGistogrammBitmapW(130, GistogrammData.Gray, MinC, MaxC, Bitmap, $000000);
      2:
        GetGistogrammBitmapW(130, GistogrammData.Red, MinC, MaxC, Bitmap, $0000FF);
      3:
        GetGistogrammBitmapW(130, GistogrammData.Green, MinC, MaxC, Bitmap, $00FF00);
      4:
        GetGistogrammBitmapW(130, GistogrammData.Blue, MinC, MaxC, Bitmap, $FF0000);
    end;

    LbEffectiveRange.Caption := Format(L('Effective range: %d..%d'), [MinC, MaxC]);
    GistogrammImage.Picture.Bitmap := Bitmap;
  finally
    F(Bitmap);
  end;
end;

initialization
  PropertyManager := TPropertyManager.Create;

finalization
  F(PropertyManager);

end.
