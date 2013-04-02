unit uFormImportImages;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.CommCtrl,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.Themes,
  Vcl.ImgList,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.PathEditor,
  Dmitry.Controls.LoadingSign,
  Dmitry.PathProviders,
  Dmitry.PathProviders.FileSystem,
  Dmitry.PathProviders.MyComputer,

  MPCommonUtilities,
  MPCommonObjects,
  EasyListview,

  UnitDBFileDialogs,
  UnitDBDeclare,
  UnitBitmapImageList,

  uConstants,
  uMemory,
  uMemoryEx,
  uShellUtils,
  uRuntime,
  uResources,
  uSettings,
  uDBForm,
  uThreadForm,
  uGraphicUtils,
  uTranslate,
  uTranslateUtils,
  uVCLHelpers,
  uListViewUtils,
  uDBPopupMenuInfo,
  uAssociations,
  uDateUtils,
  uPathUtils,
  uList64,
  uImportPicturesUtils,
  uBox,
  uProgramStatInfo,
  uFormInterfaces;

const
  TAG_LABEL           = 1;
  TAG_DATE            = 2;
  TAG_ITEMS_COUNT     = 3;
  TAG_ITEMS_SIZE      = 4;
  TAG_SETTINGS        = 5;
  TAG_EDIT_LABEL      = 6;
  TAG_EDIT_LABEL_OK   = 7;
  TAG_EDIT_DATE       = 8;
  TAG_EDIT_DATE_OK    = 9;
  TAG_LOADING         = 10;

  POPUP_IMAGE_INDEX_SHOW        = 0;
  POPUP_IMAGE_INDEX_MERGE_LEFT  = 1;
  POPUP_IMAGE_INDEX_MERGE_RIGHT = 2;
  POPUP_IMAGE_INDEX_SPLIT       = 3;
  POPUP_IMAGE_INDEX_DONT_IMPORT = 4;
  POPUP_IMAGE_INDEX_IMPORT      = 5;

type
  TImportPicturesMode = (piModeSimple, piModeExtended);

  TBaseSelectItem = class
  private
    FItemLabel: string;
    FIsSelected: Boolean;
    FIsDisabled: Boolean;
    FOriginalDate: TDateTime;
  protected
    function GetItemsCount: Integer; virtual; abstract;
    function GetItemsSize: Int64; virtual; abstract;
    function GetDate: TDateTime; virtual; abstract;
    procedure SetDate(Value: TDateTime); virtual; abstract;
  public
    constructor Create(Date: TDateTime); virtual;
    procedure FillItems(List: TList<TPathItem>); virtual; abstract;
    property ItemLabel: string read FItemLabel write FItemLabel;
    property ItemsSize: Int64 read GetItemsSize;
    property ItemsCount: Integer read GetItemsCount;
    property IsSelected: Boolean read FIsSelected write FIsSelected;
    property IsDisabled: Boolean read FIsDisabled write FIsDisabled;
    property Date: TDateTIme read GetDate write SetDate;
    property OriginalDate: TDateTime read FOriginalDate;
  end;

  TSelectDateItem = class(TBaseSelectItem)
  private
    FDate: TDateTime;
    FItemsCount: Integer;
    FItemsSize: Int64;
    FItems: TList<TPathItem>;
  protected
    function GetItemsCount: Integer; override;
    function GetItemsSize: Int64; override;
    function GetDate: TDateTime; override;
    procedure SetDate(Value: TDateTime); override;
  public
    constructor Create(Date: TDateTime); override;
    destructor Destroy; override;
    procedure FillItems(List: TList<TPathItem>); override;
    procedure AddItem(Item: TPathItem; Size: Int64);
    property Date: TDateTime read GetDate write SetDate;
    property Items: TList<TPathItem> read FItems;
  end;

  TSelectDateItems = class(TBaseSelectItem)
  private
    FItems: TList<TSelectDateItem>;
    FCustomDate: TDateTime;
  protected
    function GetItemsCount: Integer; override;
    function GetItemsSize: Int64; override;
    function GetDate: TDateTime; override;
    procedure SetDate(Value: TDateTime); override;
  public
    constructor Create(Date: TDateTime);  override;
    destructor Destroy; override;
    procedure AddSerie(Serie: TBaseSelectItem);
    procedure FillItems(List: TList<TPathItem>); override;
    property Date: TDateTime read GetDate;
    property Items: TList<TSelectDateItem> read FItems;
  end;

  TSelectDateCollection = class
  private
    FItems: TList<TBaseSelectItem>;
    FContainer: TScrollBox;
    FMenuOptions: TPopupActionBar;
    FImageList: TImageList;
    function GetScrollBoxByItem(Index: TBaseSelectItem): TBox;
    function GetItemByIndex(Index: Integer): TBaseSelectItem;
    function GetCont: Integer;
    function GetStatDate: TDateTime;
    property DisplayItems[Index: TBaseSelectItem]: TBox read GetScrollBoxByItem;
    procedure OnItemEditClick(Sender: TObject);
    procedure OnDateEditClick(Sender: TObject);
    function FindMenuItemByImageIndex(Parent: TPopupActionBar; Index: NativeInt): TMenuItem;

    procedure SplitItem(SDI: TSelectDateItems);
  protected
    procedure OnEditLabelEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditLabelOkClick(Sender: TObject);
    procedure EndEditLabel(Item: TBaseSelectItem);

    procedure OnEditDateEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditDateOkClick(Sender: TObject);
    procedure EndEditDate(Item: TBaseSelectItem);

    procedure OnBoxMouseLeave(Sender: TObject);
    procedure OnBoxMouseEnter(Sender: TObject);
    procedure OnBoxClick(Sender: TObject);
    procedure ShowSettings(Sender: TObject);

    //popup menu
    procedure MenuOptionsPopup(Sender: TObject);

    procedure MIShowPictures(Sender: TObject);
    procedure MIMergeLeft(Sender: TObject);
    procedure MISplitSeries(Sender: TObject);
    procedure MIMergeRight(Sender: TObject);
    procedure MIDontImport(Sender: TObject);
    procedure MIImport(Sender: TObject);

  public
    constructor Create(Container: TScrollBox);
    destructor Destroy; override;
    procedure Clear;
    procedure UpdateModel;
    procedure ClearSelection;
    procedure AddDateInfo(Item: TPathItem; Date: TDateTime; Size: Int64);
    property Items[Index: Integer]: TBaseSelectItem read GetItemByIndex; default;
    property InnerItems: TList<TBaseSelectItem> read FItems;
    property Count: Integer read GetCont;
    property StatDate: TDateTime read GetStatDate;
  end;

  TScanItem = class(TObject)
  public
    Item: TPathItem;
    Date: TDateTime;
    Size: Int64;
    constructor Create(AItem: TPathItem; ADate: TDateTime; ASize: Int64);
  end;

type
  TFormImportImages = class(TThreadForm, IImportForm)
    LbImportFrom: TLabel;
    LbImportTo: TLabel;
    PeImportFromPath: TPathEditor;
    BtnSelectPathFrom: TButton;
    PeImportToPath: TPathEditor;
    BtnSelectPathTo: TButton;
    BtnOk: TButton;
    BtnCancel: TButton;
    GbSeries: TGroupBox;
    SbSeries: TScrollBox;
    WlMode: TWebLink;
    ElvPreview: TEasyListview;
    LsMain: TLoadingSign;
    WlHideShowPictures: TWebLink;
    PnSimpleOptions: TPanel;
    WlLabel: TWebLink;
    WlDate: TWebLink;
    WlResetDate: TWebLink;
    WedLabel: TWatermarkedEdit;
    WlSetLabel: TWebLink;
    DtpDate: TDateTimePicker;
    WlSetDate: TWebLink;
    BtnSettings: TButton;
    ImInfo: TImage;
    LbSeriesInfo: TLabel;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSelectPathToClick(Sender: TObject);
    procedure BtnSelectPathFromClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure PeImportFromPathChange(Sender: TObject);
    procedure ElvPreviewItemThumbnailDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
      AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure ElvPreviewItemDblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem);
    procedure WlModeClick(Sender: TObject);
    procedure WlHideShowPicturesClick(Sender: TObject);
    procedure WlLabelClick(Sender: TObject);
    procedure WlDateClick(Sender: TObject);
    procedure WedLabelExit(Sender: TObject);
    procedure DtpDateExit(Sender: TObject);
    procedure WlSetLabelClick(Sender: TObject);
    procedure WlSetDateClick(Sender: TObject);
    procedure WlResetDateClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
    procedure WedLabelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DtpDateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SbSeriesResize(Sender: TObject);
  private
    { Private declarations }
    FOriginalPath: string;
    FItemUpdateTimer: TTimer;
    FItemUpdateLastTime: Cardinal;
    FSeries: TSelectDateCollection;
    FBitmapImageList: TBitmapImageList;
    FPreviewData: TList<TPathItem>;
    FMode: TImportPicturesMode;
    FIsDisplayingPreviews: Boolean;
    FSimpleDate: TDateTime;
    FSimpleLabel: string;
    FIsSimpleLabelEditing: Boolean;
    FIsSimpleDateEditing: Boolean;
    FIsReady: Boolean;
    procedure LoadLanguage;
    procedure ReadOptions;
    procedure SwitchMode(NewMode: Boolean = True);
    procedure ItemUpdateTimer(Sender: TObject);
    procedure ClearItems;
    procedure UpdateItemsCount;
    function GetImagesCount: Integer;
    procedure LockHeight;
    procedure UnlockHeight;
    function GetImagesSize: Int64;
    procedure AllignSimpleOptions;
    procedure SetSeriesCount(Count: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
    procedure SetPath(Path: string);
    property ImagesCount: Integer read GetImagesCount;
    property ImagesSize: Int64 read GetImagesSize;
    property IsDisplayingPreviews: Boolean read FIsDisplayingPreviews write FIsDisplayingPreviews;
    property OriginalPath: string read FOriginalPath;
  public
    { Public declarations }
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure FinishScan;
    procedure AddItems(Items: TList<TScanItem>);
    procedure AddPreviews(FPacketInfos: TList<TPathItem>; FPacketImages: TBitmapImageList);
    procedure UpdatePreview(Item: TPathItem; Bitmap: TBitmap);

    //IImportForm
    procedure FromDevice(DeviceName: string);
    procedure FromDrive(DriveLetter: Char);
    procedure FromFolder(Folder: string);
  end;

{$R PicturesImport.res}

implementation

uses
  uThreadImportPictures,
  uImportScanThread,
  uImportSeriesPreview,
  FormManegerUnit,
  uFormImportPicturesSettings;

{ TBaseSelectItem }

procedure TFormImportImages.FromDevice(DeviceName: string);
begin
  FromFolder(cDevicesPath + '\' + DeviceName);
end;

procedure TFormImportImages.FromDrive(DriveLetter: Char);
begin
  FromFolder(DriveLetter + ':\');
end;

procedure TFormImportImages.FromFolder(Folder: string);
var
  Imports: TList<TFormImportImages>;
  Form: TFormImportImages;
begin
  Imports := TList<TFormImportImages>.Create;
  try
    TFormCollection.Instance.GetForms<TFormImportImages>(Imports);
    for Form in Imports do
      if (Form <> Self) and (Form.OriginalPath = Folder) then
      begin
        Form.Show;
        Close;
        Exit;
      end;
  finally
    F(Imports);
  end;
  Show;
  SetPath(Folder);
end;

constructor TBaseSelectItem.Create(Date: TDateTime);
begin
  FOriginalDate := Date;
  FIsSelected := False;
  FIsDisabled := False;
end;

{ TScanItem }

constructor TScanItem.Create(AItem: TPathItem; ADate: TDateTime; ASize: Int64);
begin
  Item := AItem;
  Date := ADate;
  Size := ASize;
end;

{ TSelectDateItem }

procedure TSelectDateItem.AddItem(Item: TPathItem; Size: Int64);
begin
  FItems.Add(Item.Copy);
  FItemsSize := FItemsSize + Size;
  Inc(FItemsCount);
end;

constructor TSelectDateItem.Create(Date: TDateTime);
begin
  inherited Create(Date);
  FItemsSize := 0;
  FItems := TList<TPathItem>.Create;
end;

destructor TSelectDateItem.Destroy;
begin
  FreeList(FItems);
  inherited;
end;

procedure TSelectDateItem.FillItems(List: TList<TPathItem>);
var
  PI: TPathItem;
begin
  for PI in FItems do
    List.Add(PI.Copy);
end;

function TSelectDateItem.GetDate: TDateTime;
begin
  Result := FDate;
end;

function TSelectDateItem.GetItemsCount: Integer;
begin
  Result := FItemsCount;
end;

function TSelectDateItem.GetItemsSize: Int64;
begin
  Result := FItemsSize;
end;

procedure TSelectDateItem.SetDate(Value: TDateTime);
begin
  FDate := Value;
end;

{ TSelectDateItems }

procedure TSelectDateItems.AddSerie(Serie: TBaseSelectItem);
begin
  if Serie is TSelectDateItem then
    FItems.Add(TSelectDateItem(Serie))
  else
  begin
    FItems.AddRange(TSelectDateItems(Serie).FItems);
    TSelectDateItems(Serie).FItems.Clear;
    Serie.Free;
  end;
end;

constructor TSelectDateItems.Create(Date: TDateTime);
begin
  inherited Create(Date);
  FItems := TList<TSelectDateItem>.Create;
  FCustomDate := MinDateTime;
end;

destructor TSelectDateItems.Destroy;
begin
  FreeList(FItems);
  inherited;
end;

procedure TSelectDateItems.FillItems(List: TList<TPathItem>);
var
  SDI: TSelectDateItem;
begin
  for SDI in FItems do
    SDI.FillItems(List);
end;

function TSelectDateItems.GetDate: TDateTime;
var
  List: TList64;
  DI: TSelectDateItem;
begin
  if FCustomDate > MinDateTime then
    Exit(FCustomDate);

  List := TList64.Create;
  try
    for DI in FItems do
      List.Add(DI.Date);

    Result := List.MaxStatDateTime;
  finally
    F(List);
  end;
end;

function TSelectDateItems.GetItemsCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FItems.Count - 1 do
    Result := Result + FItems[I].ItemsCount;
end;

function TSelectDateItems.GetItemsSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FItems.Count - 1 do
    Result := Result + FItems[I].ItemsSize;
end;

procedure TSelectDateItems.SetDate(Value: TDateTime);
begin
  FCustomDate := Value;
end;

{ TSelectDateCollection }

procedure TSelectDateCollection.AddDateInfo(Item: TPathItem; Date: TDateTime; Size: Int64);
var
  SI: TBaseSelectItem;
  SDI: TSelectDateItem;
  Index: Integer;
begin
  Date := DateOf(Date);

  for SI in FItems do
  begin
    if SI is TSelectDateItem then
    begin
      if TSelectDateItem(SI).Date = Date then
      begin
        TSelectDateItem(SI).AddItem(Item, Size);
        Exit;
      end;
    end;
  end;

  SDI := TSelectDateItem.Create(Date);
  TSelectDateItem(SDI).Date := Date;
  TSelectDateItem(SDI).FItemsCount := 1;
  TSelectDateItem(SDI).FItemsSize := Size;
  TSelectDateItem(SDI).Items.Add(Item.Copy);
  SDI.ItemLabel := Settings.ReadString('ImportPicturesSeries', FormatDateTimeShortDate(Date), '');

  Index := -1;

  for SI in FItems do
    if SI is TSelectDateItem then
      if TSelectDateItem(SI).Date < SDI.Date then
        Index := -1;

  if Index < 0 then
    FItems.Add(SDI)
  else
    FItems.Insert(Index, SDI);
end;

procedure TSelectDateCollection.Clear;
var
  SI: TBaseSelectItem;
  B: TBox;
begin
  for SI in FItems do
  begin
    B := DisplayItems[SI];
    if B <> nil then
      B.Free;
  end;
  FreeList(FItems, False);
end;

procedure TSelectDateCollection.ClearSelection;
var
  I: Integer;
  SI: TBaseSelectItem;
begin
  for SI in FItems do
    SI.IsSelected := False;

  for I := 0 to FItems.Count - 1 do
    DisplayItems[FItems[I]].OnMouseLeave(DisplayItems[FItems[I]]);
end;

constructor TSelectDateCollection.Create(Container: TScrollBox);
const
  Icons: array[0..5] of string = ('SLIDE_SHOW', 'SERIES_LEFT', 'SERIES_RIGHT', 'SERIES_SPLIT', 'SERIES_CANCEL', 'SERIES_OK');
var
  MI: TMenuItem;
  IconName: string;

  procedure AddIcon(Name: string);
  var
    Icon: HIcon;
  begin
    Icon := LoadImage(HInstance, PChar(Name), IMAGE_ICON, 16, 16, 0);
    ImageList_ReplaceIcon(FImageList.Handle, -1, Icon);
    DestroyIcon(Icon);
  end;

begin
  FContainer := Container;
  FItems := TList<TBaseSelectItem>.Create;
  FMenuOptions := TPopupActionBar.Create(nil);
  FMenuOptions.OnPopup := MenuOptionsPopup;

  FImageList := TImageList.Create(nil);
  FImageList.ColorDepth := cd32Bit;

  FMenuOptions.Images := FImageList;
  for IconName in Icons do
    AddIcon(IconName);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Show objects', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_SHOW;
  MI.OnClick := MIShowPictures;
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := '-';
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Merge left', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_MERGE_LEFT;
  MI.OnClick := MIMergeLeft;
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Split series', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_SPLIT;
  MI.OnClick := MISplitSeries;
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Merge right', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_MERGE_RIGHT;
  MI.OnClick := MIMergeRight;
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := '-';
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Don''t import', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_DONT_IMPORT;
  MI.OnClick := MIDontImport;
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Import pictures', 'ImportPictures');
  MI.ImageIndex := POPUP_IMAGE_INDEX_IMPORT;
  MI.OnClick := MIImport;
  FMenuOptions.Items.Add(MI);
end;

destructor TSelectDateCollection.Destroy;
begin
  F(FMenuOptions);
  F(FImageList);
  FreeList(FItems);
  inherited;
end;

function TSelectDateCollection.GetCont: Integer;
begin
  Result := FItems.Count;
end;

function TSelectDateCollection.GetItemByIndex(Index: Integer): TBaseSelectItem;
begin
  Result := FItems[Index];
end;

function TSelectDateCollection.GetScrollBoxByItem(
  Index: TBaseSelectItem): TBox;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FContainer.ControlCount - 1 do
    if FContainer.Controls[I] is TBox then
      if FContainer.Controls[I].Tag = NativeInt(Index) then
      begin
        Result := TBox(FContainer.Controls[I]);
        Exit;
      end;
end;

function TSelectDateCollection.GetStatDate: TDateTime;
var
  L64: TList64;
  I: Integer;
  ItemsList: TList<TPathItem>;
  SI, SI2: TBaseSelectItem;
begin
  ItemsList := TList<TPathItem>.Create;
  L64 := TList64.Create;
  try
    for SI in FItems do
    begin
      if SI is TSelectDateItem then
      begin
        for I := 0 to SI.ItemsCount do
          L64.Add(SI.Date);
      end else
      begin
        for SI2 in TSelectDateItems(SI).Items do
          for I := 0 to SI2.ItemsCount do
            L64.Add(SI2.Date);
      end;
    end;

    Result := L64.MaxStatDateTime;
  finally
    FreeList(ItemsList);
    F(L64);
  end;
end;

procedure TSelectDateCollection.MenuOptionsPopup(Sender: TObject);
var
  SI: TBaseSelectItem;
begin
  SI := TBaseSelectItem(TPopupActionBar(Sender).Tag);
  FindMenuItemByImageIndex(FMenuOptions, POPUP_IMAGE_INDEX_DONT_IMPORT).Visible := not SI.IsDisabled;
  FindMenuItemByImageIndex(FMenuOptions, POPUP_IMAGE_INDEX_IMPORT).Visible := SI.IsDisabled;
  FindMenuItemByImageIndex(FMenuOptions, POPUP_IMAGE_INDEX_SPLIT).Visible := SI is TSelectDateItems;
  FindMenuItemByImageIndex(FMenuOptions, POPUP_IMAGE_INDEX_MERGE_LEFT).Visible := FItems.IndexOf(SI) > 0;
  FindMenuItemByImageIndex(FMenuOptions, POPUP_IMAGE_INDEX_MERGE_RIGHT).Visible := FItems.IndexOf(SI) < FItems.Count - 1;
end;

procedure TSelectDateCollection.MIDontImport(Sender: TObject);
var
  SI: TBaseSelectItem;
  WlLabel, WlDate: TWebLink;
  SB: TBox;
begin
  SI := TBaseSelectItem(TMenuItem(Sender).GetParentMenu.Tag);
  SI.IsDisabled := True;
  SB := DisplayItems[SI];

  WlLabel := SB.FindChildByTag<TWebLink>(TAG_LABEL);
  WlDate := SB.FindChildByTag<TWebLink>(TAG_DATE);

  WlLabel.LoadFromResource('SERIES_CANCEL');
  WlLabel.Enabled := False;
  WlDate.LoadFromResource('SERIES_CANCEL');
  WlDate.Enabled := False;
end;

procedure TSelectDateCollection.MIImport(Sender: TObject);
var
  SI: TBaseSelectItem;
  WlLabel, WlDate: TWebLink;
  SB: TBox;
begin
  SI := TBaseSelectItem(TMenuItem(Sender).GetParentMenu.Tag);
  SI.IsDisabled := False;
  SB := DisplayItems[SI];

  WlLabel := SB.FindChildByTag<TWebLink>(TAG_LABEL);
  WlDate := SB.FindChildByTag<TWebLink>(TAG_DATE);

  WlLabel.LoadFromResource('SERIES_EDIT');
  WlLabel.Enabled := True;
  WlDate.LoadFromResource('SERIES_DATE');
  WlDate.Enabled := True;
end;

procedure TSelectDateCollection.MIMergeLeft(Sender: TObject);
var
  BI, SI: TBaseSelectItem;
  Index: Integer;
  SDI: TSelectDateItems;
begin
  SI := TBaseSelectItem(TMenuItem(Sender).GetParentMenu.Tag);
  Index := FItems.IndexOf(SI);

  if Index > 0 then
  begin
    BI := FItems[Index - 1];
    DisplayItems[SI].Free;
    if BI is TSelectDateItem then
    begin
      DisplayItems[BI].Free;
      SDI := TSelectDateItems.Create(MinDateTime);
      SDI.ItemLabel := SI.ItemLabel;
      FItems.Remove(BI);
      FItems.Remove(SI);
      SDI.AddSerie(BI);
      SDI.AddSerie(SI);
      FItems.Insert(Index - 1, SDI);
    end else
    begin
      TSelectDateItems(BI).AddSerie(SI);
      FItems.Remove(SI);
    end;
    UpdateModel;
  end;
end;

procedure TSelectDateCollection.MIMergeRight(Sender: TObject);
var
  BI, SI: TBaseSelectItem;
  Index: Integer;
  SDI: TSelectDateItems;
begin
  SI := TBaseSelectItem(TMenuItem(Sender).GetParentMenu.Tag);
  Index := FItems.IndexOf(SI);

  if Index < FItems.Count - 1 then
  begin
    BI := FItems[Index + 1];
    DisplayItems[SI].Free;
    if BI is TSelectDateItem then
    begin
      DisplayItems[BI].Free;
      SDI := TSelectDateItems.Create(MinDateTime);
      SDI.ItemLabel := SI.ItemLabel;
      FItems.Remove(BI);
      FItems.Remove(SI);
      SDI.AddSerie(BI);
      SDI.AddSerie(SI);
      FItems.Insert(Index, SDI);
    end else
    begin
      TSelectDateItems(BI).AddSerie(SI);
      FItems.Remove(SI);
    end;
    UpdateModel;
  end;
end;

procedure TSelectDateCollection.MIShowPictures(Sender: TObject);
var
  SI: TBaseSelectItem;
begin
  SI := TBaseSelectItem(TMenuItem(Sender).GetParentMenu.Tag);
  DisplayItems[SI].OnClick(DisplayItems[SI]);
end;

procedure TSelectDateCollection.MISplitSeries(Sender: TObject);
var
  SDI: TSelectDateItems;
begin
  SDI := TSelectDateItems(TMenuItem(Sender).GetParentMenu.Tag);

  SplitItem(SDI);

  UpdateModel;
end;

function TSelectDateCollection.FindMenuItemByImageIndex(Parent: TPopupActionBar;
  Index: NativeInt): TMenuItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Parent.Items.Count - 1 do
  begin
    if Parent.Items[I].ImageIndex = Index then
    begin
      Result := Parent.Items[I];
      Exit;
    end;
  end;
end;

procedure TSelectDateCollection.OnEditLabelEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  Ed: TWatermarkedEdit;
  SI: TBaseSelectItem;
begin
  Ed := TWatermarkedEdit(Sender);
  if Key = VK_RETURN then
  begin
    Key := 0;
    SI := TBaseSelectItem(Ed.Parent.Tag);
    EndEditLabel(SI);
  end;
end;

procedure TSelectDateCollection.OnEditLabelOkClick(Sender: TObject);
var
  SI: TBaseSelectItem;
begin
  SI := TBaseSelectItem(TWinControl(Sender).Parent.Tag);
  EndEditLabel(SI);
end;

procedure TSelectDateCollection.OnEditDateEditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  Dp: TDateTimePicker;
  SI: TSelectDateItem;
begin
  Dp := TDateTimePicker(Sender);
  if Key = VK_RETURN then
  begin
    Key := 0;
    SI := TSelectDateItem(Dp.Parent.Tag);
    EndEditDate(SI);
  end;
end;

procedure TSelectDateCollection.OnEditDateOkClick(Sender: TObject);
var
  BSI: TBaseSelectItem;
begin
  BSI := TBaseSelectItem(TWinControl(Sender).Parent.Tag);
  EndEditDate(BSI);
end;

procedure TSelectDateCollection.EndEditDate(Item: TBaseSelectItem);
var
  Sb: TBox;
  Dp: TDateTimePicker;
  LnkOk, LnkDate: TWebLink;
begin
  Sb := DisplayItems[Item];
  if (Sb <> nil) then
  begin
    LnkDate := Sb.FindChildByTag<TWebLink>(TAG_DATE);
    Dp := Sb.FindChildByTag<TDateTimePicker>(TAG_EDIT_DATE);
    LnkOk := Sb.FindChildByTag<TWebLink>(TAG_EDIT_DATE_OK);
    Item.Date := Dp.Date;

    LnkDate.Text := FormatDateTimeShortDate(Dp.Date);

    LnkOk.Hide;
    Dp.Hide;
    LnkDate.Show;
  end;
end;

procedure TSelectDateCollection.EndEditLabel(Item: TBaseSelectItem);
var
  Sb: TBox;
  SI: TBaseSelectItem;
  Edit: TWatermarkedEdit;
  LnkOk, LnkLabel: TWebLink;
  I, TextSize, Left: Integer;
begin
  Sb := DisplayItems[Item];
  if (Sb <> nil) then
  begin
    LnkLabel := Sb.FindChildByTag<TWebLink>(TAG_LABEL);
    Edit := Sb.FindChildByTag<TWatermarkedEdit>(TAG_EDIT_LABEL);
    LnkOk := Sb.FindChildByTag<TWebLink>(TAG_EDIT_LABEL_OK);

    Item.ItemLabel := Edit.Text;
    if Edit.Text = '' then
      LnkLabel.Text := TA('Enter label', 'ImportPictures')
    else
      LnkLabel.Text := TPath.CleanUp(Edit.Text);

    Settings.WriteString('ImportPicturesSeries', FormatDateTimeShortDate(Item.Date), Item.ItemLabel);

    LnkOk.Hide;
    Edit.Hide;
    LnkLabel.Show;

    Left := 5;
    for I := 0 to FItems.Count - 1 do
    begin
      SI := FItems[I];
      Sb := DisplayItems[SI];

      LnkLabel := Sb.FindChildByTag<TWebLink>(TAG_LABEL);
      TextSize := Min(Max(LnkLabel.Width - LnkLabel.Left - 5, 175 - 22), 450);
      Sb.Width := TextSize + 22;
      Sb.Left := Left - FContainer.HorzScrollBar.Position;
      Left := Left + Sb.Width + 5;
    end;
  end;
end;

procedure TSelectDateCollection.OnBoxClick(Sender: TObject);
var
  Sb: TBox;
  SI: TBaseSelectItem;
  I: Integer;
  Data: TList<TPathItem>;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Data := TList<TPathItem>.Create;

  SI := TBaseSelectItem(Sb.Tag);

  for I := 0 to FItems.Count - 1 do
  begin
    FItems[I].IsSelected := False;
    DisplayItems[FItems[I]].IsSelected := False;
  end;
  SI.IsSelected := True;
  Sb.IsSelected := True;

  for I := 0 to FItems.Count - 1 do
  begin
    if FItems[I] <> SI then
      DisplayItems[FItems[I]].OnMouseLeave(DisplayItems[FItems[I]]);
  end;

  SI.FillItems(Data);

  TFormImportImages(Sb.Owner).NewFormSubState;
  TFormImportImages(Sb.Owner).ClearItems;
  TFormImportImages(Sb.Owner).IsDisplayingPreviews := True;
  TFormImportImages(Sb.Owner).SwitchMode(False);
  TImportSeriesPreview.Create(TThreadForm(Sb.Owner), Data, 125);
end;

procedure TSelectDateCollection.OnBoxMouseEnter(Sender: TObject);
var
  Sb: TBox;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Sb.IsHovered := True;
end;

procedure TSelectDateCollection.OnBoxMouseLeave(Sender: TObject);
var
  Sb: TBox;
begin
  if Sender is TBox then
    Sb := TBox(Sender)
  else
    Sb := TBox(TWinControl(Sender).Parent);

  Sb.IsHovered := False;
end;

procedure TSelectDateCollection.OnDateEditClick(Sender: TObject);
var
  DtpEditDate: TDateTimePicker;
  LnkLabel, LnkOk: TWebLink;
  SI: TBaseSelectItem;
  Parent: TBox;
begin
  LnkLabel := TWebLink(Sender);
  LnkLabel.Hide;

  Parent := TBox(LnkLabel.Parent);
  SI := TBaseSelectItem(Parent.Tag);

  DtpEditDate := Parent.FindChildByTag<TDateTimePicker>(TAG_EDIT_DATE);
  if DtpEditDate = nil then
  begin
    DtpEditDate := TDateTimePicker.Create(FContainer.Owner);
    DtpEditDate.Anchors := [akTop, akLeft, akRight];
    DtpEditDate.Parent := Parent;
    DtpEditDate.Left := 4;
    DtpEditDate.Top := 27;
    DtpEditDate.Width := 121;
    DtpEditDate.Height := 21;
    DtpEditDate.Date := SI.Date;
    DtpEditDate.Tag := TAG_EDIT_DATE;
    DtpEditDate.OnKeyDown := OnEditDateEditKeyDown;
    DtpEditDate.OnExit := OnEditDateOkClick;
    DtpEditDate.OnMouseEnter := OnBoxMouseEnter;
    DtpEditDate.OnMouseLeave := OnBoxMouseLeave;
  end;

  LnkOk := Parent.FindChildByTag<TWebLink>(TAG_EDIT_DATE_OK);
  if LnkOk = nil then
  begin
    LnkOk := TWebLink.Create(FContainer.Owner);
    LnkOk.Anchors := [akTop, akRight];
    LnkOk.Parent := Parent;
    LnkOk.Left := 130;
    LnkOk.Top := 29;
    LnkOk.Text := TA('Ok');
    LnkOk.HightliteImage := True;
    LnkOk.Tag := TAG_EDIT_DATE_OK;
    LnkOk.LoadFromResource('SERIES_OK');
    LnkOk.Color := Parent.Color;
    LnkOk.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
    LnkOk.DisableStyles := True;
    LnkOk.OnClick := OnEditDateOkClick;
    LnkOk.Refresh;
    LnkOk.OnMouseEnter := OnBoxMouseEnter;
    LnkOk.OnMouseLeave := OnBoxMouseLeave;
  end;

  DtpEditDate.Show;
  DtpEditDate.SetFocus;
  LnkOk.Show;
end;

procedure TSelectDateCollection.OnItemEditClick(Sender: TObject);
var
  WebEditLabel: TWatermarkedEdit;
  LnkLabel, LnkOk: TWebLink;
  SI: TBaseSelectItem;
  Parent: TBox;
begin
  LnkLabel := TWebLink(Sender);
  LnkLabel.Hide;

  Parent := TBox(LnkLabel.Parent);
  SI := TBaseSelectItem(Parent.Tag);

  WebEditLabel := Parent.FindChildByTag<TWatermarkedEdit>(TAG_EDIT_LABEL);
  if WebEditLabel = nil then
  begin
    WebEditLabel := TWatermarkedEdit.Create(FContainer.Owner);
    WebEditLabel.Anchors := [akTop, akLeft, akRight];
    WebEditLabel.Parent := Parent;
    WebEditLabel.Left := 3;
    WebEditLabel.Top := 4;
    WebEditLabel.Width := 121;
    WebEditLabel.Height := 21;
    WebEditLabel.Text := SI.ItemLabel;
    WebEditLabel.WatermarkText := TA('Enter label', 'ImportPictures');
    WebEditLabel.Tag := TAG_EDIT_LABEL;
    WebEditLabel.OnKeyDown := OnEditLabelEditKeyDown;
    WebEditLabel.OnExit := OnEditLabelOkClick;
    WebEditLabel.OnMouseEnter := OnBoxMouseEnter;
    WebEditLabel.OnMouseLeave := OnBoxMouseLeave;
  end;

  LnkOk := Parent.FindChildByTag<TWebLink>(TAG_EDIT_LABEL_OK);
  if LnkOk = nil then
  begin
    LnkOk := TWebLink.Create(FContainer.Owner);
    LnkOk.Anchors := [akTop, akRight];
    LnkOk.Parent := Parent;
    LnkOk.Left := 130;
    LnkOk.Top := 6;
    LnkOk.Text := TA('Ok');
    LnkOk.HightliteImage := True;
    LnkOk.Tag := TAG_EDIT_LABEL_OK;
    LnkOk.LoadFromResource('SERIES_OK');
    LnkOk.OnClick := OnEditLabelOkClick;
    LnkOk.Color := Parent.Color;
    LnkOk.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
    LnkOk.DisableStyles := True;
    LnkOk.Refresh;
    LnkOk.OnMouseEnter := OnBoxMouseEnter;
    LnkOk.OnMouseLeave := OnBoxMouseLeave;
  end;

  WebEditLabel.Show;
  WebEditLabel.SetFocus;
  LnkOk.Show;
end;

procedure TSelectDateCollection.ShowSettings(Sender: TObject);
var
  P: TPoint;
  SI: TBaseSelectItem;
begin
  SI := TBaseSelectItem(TWebLink(Sender).Parent.Tag);
  FMenuOptions.Tag := NativeInt(SI);

  GetCursorPos(P);
  FMenuOptions.Popup(P.X, P.Y);
end;

procedure TSelectDateCollection.SplitItem(SDI: TSelectDateItems);
var
  Index: Integer;
  SI: TSelectDateItem;
begin
  Index := FItems.IndexOf(SDI);
  DisplayItems[SDI].Free;
  FItems.Remove(SDI);
  for SI in SDI.Items do
    FItems.Insert(Index, SI);

  SDI.FItems.Clear;
  SDI.Free;
end;

procedure TSelectDateCollection.UpdateModel;
var
  I, Left: Integer;
  Sb: TBox;
  WlLabel, WlDate, WlItemsCount, WlSize, WlSettings: TWebLink;
  SI: TBaseSelectItem;

begin
  BeginScreenUpdate(TForm(FContainer.Owner).Handle);
  Left := 5;
  try
    for I := 0 to FItems.Count - 1 do
    begin
      SI := FItems[I];
      Sb := DisplayItems[SI];
      if Sb = nil then
      begin
        Sb := TBox.Create(FContainer.Owner);
        Sb.Visible := False;
        Sb.Parent := FContainer;
        Sb.Width := 175;
        Sb.Height := 75;
        Sb.BevelKind := bkTile;
        Sb.BorderStyle := bsNone;
        Sb.Top := 3;
        Sb.Tag := NativeInt(FItems[I]);
        Sb.Color := StyleServices.GetStyleColor(scPanel);
        Sb.OnMouseEnter := OnBoxMouseEnter;
        Sb.OnMouseLeave := OnBoxMouseLeave;
        Sb.OnClick := OnBoxClick;

        WlLabel := TWebLink.Create(FContainer.Owner);
        WlLabel.Parent := Sb;
        WlLabel.Left := 4;
        WlLabel.Top := 6;
        WlLabel.LoadFromResource('SERIES_EDIT');
        WlLabel.DisableStyles := True;
        WlLabel.Color := SB.Color;
        WlLabel.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
        WlLabel.Refresh;
        WlLabel.Tag := TAG_LABEL;
        WlLabel.OnClick := OnItemEditClick;
        WlLabel.OnMouseEnter := OnBoxMouseEnter;
        WlLabel.OnMouseLeave := OnBoxMouseLeave;

        WlDate := TWebLink.Create(FContainer.Owner);
        WlDate.Parent := Sb;
        WlDate.Left := 4;
        WlDate.Top := 28;
        WlDate.LoadFromResource('SERIES_DATE');
        WlDate.DisableStyles := True;
        WlDate.Color := SB.Color;
        WlDate.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
        WlDate.Refresh;
        WlDate.Tag := TAG_DATE;
        WlDate.OnClick := OnDateEditClick;
        WlDate.OnMouseEnter := OnBoxMouseEnter;
        WlDate.OnMouseLeave := OnBoxMouseLeave;

        WlItemsCount := TWebLink.Create(FContainer.Owner);
        WlItemsCount.IconWidth := 0;
        WlItemsCount.IconHeight := 0;
        WlItemsCount.Parent := Sb;
        WlItemsCount.Left := 4;
        WlItemsCount.Top := 50;
        WlItemsCount.Tag := TAG_ITEMS_COUNT;
        WlItemsCount.DisableStyles := True;
        WlItemsCount.Color := SB.Color;
        WlItemsCount.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
        WlItemsCount.Refresh;
        WlItemsCount.OnMouseEnter := OnBoxMouseEnter;
        WlItemsCount.OnMouseLeave := OnBoxMouseLeave;
        WlItemsCount.OnClick := OnBoxClick;

        WlSize := TWebLink.Create(FContainer.Owner);
        WlSize.IconWidth := 0;
        WlSize.IconHeight := 0;
        WlSize.Parent := Sb;
        WlSize.Left := 62;
        WlSize.Top := 50;
        WlSize.Tag := TAG_ITEMS_SIZE;
        WlSize.DisableStyles := True;
        WlSize.Color := SB.Color;
        WlSize.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
        WlSize.Refresh;
        WlSize.OnMouseEnter := OnBoxMouseEnter;
        WlSize.OnMouseLeave := OnBoxMouseLeave;
        WlSize.OnClick := OnBoxClick;

        WlSettings := TWebLink.Create(FContainer.Owner);
        WlSettings.Anchors := [akTop, akRight];
        WlSettings.Parent := Sb;
        WlSettings.Left := 152;
        WlSettings.Top := 52;
        WlSettings.TopIconIncrement := 0;
        WlSettings.LoadFromResource('SERIES_SETTINGS');
        WlSettings.Color := SB.Color;
        WlSettings.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
        WlSettings.DisableStyles := True;
        WlSettings.Refresh;
        WlSettings.Tag := TAG_SETTINGS;
        WlSettings.OnMouseEnter := OnBoxMouseEnter;
        WlSettings.OnMouseLeave := OnBoxMouseLeave;
        WlSettings.OnClick := ShowSettings;

        TFormImportImages(FContainer.Owner).SetSeriesCount(FItems.Count);
      end;

      WlLabel := Sb.FindChildByTag<TWebLink>(TAG_LABEL);
      if SI.ItemLabel = '' then
        WlLabel.Text := TA('Enter label', 'ImportPictures')
      else
        WlLabel.Text := SI.ItemLabel;
      WlLabel.LoadImage;

      Sb.Width := Min(Max(WlLabel.Width - WlLabel.Left - 5, 175 - 22), 450) + 22;

      WlDate := Sb.FindChildByTag<TWebLink>(TAG_DATE);

      WlDate.Text := FormatDateTimeShortDate(SI.Date);
      WlDate.LoadImage;

      WlItemsCount := Sb.FindChildByTag<TWebLink>(TAG_ITEMS_COUNT);
      WlItemsCount.Text := FormatEx(TA('{0} Files', 'ImportPictures'), [SI.ItemsCount]);
      WlItemsCount.LoadImage;
      WlItemsCount.Left := 6;

      WlSize := Sb.FindChildByTag<TWebLink>(TAG_ITEMS_SIZE);
      WlSize.Left := WlItemsCount.Left + WlItemsCount.Width + 5;
      WlSize.Text := SizeInText(SI.ItemsSize);
      WlSize.LoadImage;

      Sb.Left := Left - FContainer.HorzScrollBar.Position;
      Left := Left + Sb.Width + 5;
      Sb.Show;
    end;
  finally
    EndScreenUpdate(TForm(FContainer.Owner).Handle, True);
  end;
end;

{$R *.dfm}

{ TFormImportImages }

procedure TFormImportImages.AddItems(Items: TList<TScanItem>);
var
  Item: TScanItem;
begin
  for Item in Items do
    FSeries.AddDateInfo(Item.Item, Item.Date, Item.Size);

  if GetTickCount - FItemUpdateLastTime < 100 then
  begin
    FItemUpdateTimer.Enabled := True;
  end else
  begin
    FItemUpdateTimer.Enabled := False;
    FSeries.UpdateModel;
  end;

  UpdateItemsCount;
end;

procedure TFormImportImages.AddPreviews(FPacketInfos: TList<TPathItem>; FPacketImages: TBitmapImageList);
var
  I: Integer;
  EI: TEasyItem;
begin
  ElvPreview.Groups.BeginUpdate(True);
  try
    for I := 0 to FPacketInfos.Count - 1 do
    begin
      EI := ElvPreview.Items.Add(FPacketInfos[I].Copy);
      EI.ImageIndex := FBitmapImageList.AddIcon(FPacketImages[I].Icon, True);
      FPacketImages[I].DetachImage;
      EI.Caption := ExtractFileName(FPacketInfos[I].Path);
    end;
  finally
    ElvPreview.Groups.EndUpdate(True);
  end;
end;

procedure TFormImportImages.AllignSimpleOptions;
var
  X: Integer;
begin
  X := WlLabel.Left;

  WlLabel.Left := X;
  WedLabel.Left := X;

  if not FIsSimpleLabelEditing then
  begin
    WlLabel.Text := IIF(FSimpleLabel = '', L('Set label'), FSimpleLabel);
    WlLabel.LoadImage;
    X := WlLabel.Left + WlLabel.Width + 10;
    WlLabel.Show;
    WlSetLabel.Hide;
    WedLabel.Hide;
  end else
  begin
    WedLabel.Width := Max(150, WlLabel.Width);
    WlSetLabel.Left := WedLabel.Left + WedLabel.Width + 5;
    WlSetLabel.LoadImage;
    X := WlSetLabel.Left + WlSetLabel.Width + 10;
    if not WedLabel.Visible then
    begin
      WedLabel.Show;
      WedLabel.SetFocus;
      WlSetLabel.Show;
    end;
    WlLabel.Hide;
  end;

  WlDate.Left := X;
  DtpDate.Left := X;
  if not FIsSimpleDateEditing then
  begin
    WlDate.Text := IIF(FSimpleDate = MinDateTime, L('Set date'), FormatDateTimeShortDate(FSimpleDate));
    X := WlDate.Left + WlDate.Width + 10;
    WlDate.Show;
    WlSetDate.Hide;
    DtpDate.Hide;
  end else
  begin
    WlSetDate.Left := DtpDate.Left + DtpDate.Width + 5;
    X := WlSetDate.Left + WlSetDate.Width + 10;
    WlDate.Hide;
    if not DtpDate.Visible then
    begin
      DtpDate.Show;
      WlSetDate.Show;
      DtpDate.SetFocus;
    end;
  end;

  if not FIsSimpleDateEditing and (FSimpleDate > MinDateTime) then
  begin
    WlResetDate.Left := X - 5;
    WlResetDate.Visible := True;
  end else
  begin
    WlResetDate.Left := X - 5;
    WlResetDate.Visible := False;
  end;
end;

procedure TFormImportImages.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportImages.BtnOkClick(Sender: TObject);
var
  Options: TImportPicturesOptions;
  Task: TImportPicturesTask;
  Operation: TFileOperationTask;
  I, J: Integer;
  B: Boolean;
  PD, PS: TPathItem;
  SI: TBaseSelectItem;
  Pattern: string;

  procedure AddToList(Serie: TSelectDateItem; Date: TDateTime; Caption: string);
  var
    I: Integer;
    DestPath, Path: string;
    D: TPathItem;
  begin
    Path := PD.Path + '\' + TPath.TrimPathDirectories(FormatPath(Pattern, Date, Caption));
    for I := 0 to Serie.ItemsCount - 1 do
    begin
      DestPath := TPath.Combine(Path, ExtractFileName(Serie.Items[I].Path));
      D := TFileItem.CreateFromPath(DestPath, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
      try
        Operation := TFileOperationTask.Create(Serie.Items[I], D);
        Task.AddOperation(Operation);
      finally
        F(D);
      end;
    end;
  end;

begin
  Pattern := Settings.ReadString('ImportPictures', 'Pattern', DefaultImportPattern);

  Options := TImportPicturesOptions.Create;
  Options.NamePattern := Pattern;
  Options.OnlySupportedImages := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  Options.DeleteFilesAfterImport := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  Options.AddToCollection := Settings.ReadBool('ImportPictures', 'AddToCollection', True);
  Options.Source := PeImportFromPath.PathEx;
  Options.Destination := PeImportToPath.PathEx;
  Task := TImportPicturesTask.Create;
  Options.AddTask(Task);

  PS := PeImportFromPath.PathEx;
  PD := PeImportToPath.PathEx;
  if FMode = piModeSimple then
  begin
    Options.AutoSplit := not FIsReady;

    if Options.AutoSplit then
    begin
      Operation := TFileOperationTask.Create(PS, PD);
      Task.AddOperation(Operation);
    end else
    begin

      //split all series
      while True do
      begin
        B := False;
        for I := 0 to FSeries.Count - 1 do
          if FSeries[I] is TSelectDateItems then
          begin
            FSeries.SplitItem(TSelectDateItems(FSeries[I]));
            B := True;
            Break;
          end;

        if B then
          Continue;

        Break;
      end;

      for I := 0 to FSeries.Count - 1 do
      begin
        SI := FSeries[I];

        if SI is TSelectDateItem then
          AddToList(TSelectDateItem(SI),
            IIF(FSimpleDate = MinDateTime, SI.OriginalDate, FSimpleDate), FSimpleLabel);
      end;
    end;
  end else
  begin
    for I := 0 to FSeries.Count - 1 do
    begin
      SI := FSeries[I];

      if SI.IsDisabled then
        Continue;

      if SI is TSelectDateItem then
        AddToList(TSelectDateItem(SI), SI.Date, SI.ItemLabel)
      else
        for J := 0 to TSelectDateItems(SI).Items.Count - 1 do
          AddToList(TSelectDateItems(SI).Items[J], SI.Date, SI.ItemLabel);
    end;
  end;

  TThreadImportPictures.Create(Options);

  Settings.WriteString('ImportPictures', 'Source', PeImportFromPath.Path);
  Settings.WriteString('ImportPictures', 'Destination', PeImportToPath.Path);

  Close;

  //statictics
  ProgramStatistics.ImportUsed;
end;

procedure TFormImportImages.BtnSelectPathFromClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select a folder or device with images'), '');

  if Dir <> '' then
     PeImportFromPath.Path := Dir;
end;

procedure TFormImportImages.BtnSelectPathToClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select destination directory'), GetMyPicturesPath);

  if Dir <> '' then
     PeImportToPath.Path := Dir;
end;

procedure TFormImportImages.BtnSettingsClick(Sender: TObject);
var
  FormImportPicturesSettings: TFormImportPicturesSettings;
begin
  FormImportPicturesSettings := TFormImportPicturesSettings.Create(Self);
  try
    FormImportPicturesSettings.ShowModal;
    if FormImportPicturesSettings.ModalResult = mrOk then
      PeImportFromPathChange(Sender);
  finally
    R(FormImportPicturesSettings);
  end;
end;

procedure TFormImportImages.ClearItems;
var
  I: Integer;
begin
  for I := 0 to ElvPreview.Items.Count - 1 do
    ElvPreview.Items[I].Data.Free;

  ElvPreview.Items.Clear;
  FBitmapImageList.Clear;
end;

procedure TFormImportImages.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormImportImages.ElvPreviewItemDblClick(Sender: TCustomEasyListview;
  Button: TCommonMouseButton; MousePos: TPoint; HitInfo: TEasyHitInfoItem);
var
  MenuInfo: TDBPopupMenuInfo;
  Rec: TDBPopupMenuInfoRecord;
  I: Integer;
  PI: TPathItem;
begin
  MenuInfo := TDBPopupMenuInfo.Create;
  try

    for I := 0 to ElvPreview.Items.Count - 1 do
    begin
      PI := TPathItem(ElvPreview.Items[I].Data);
      if IsGraphicFile(PI.Path) then
      begin
        Rec := TDBPopupMenuInfoRecord.CreateFromFile(PI.Path);
        MenuInfo.Add(Rec);
        if ElvPreview.Items[I].Selected then
          MenuInfo.Position := MenuInfo.Count - 1;
      end;
    end;

    if MenuInfo.Count > 0 then
    begin
      Viewer.ShowImages(Sender, MenuInfo);
      Viewer.Show;
      Viewer.Restore;
    end;
  finally
    F(MenuInfo);
  end;
end;

procedure TFormImportImages.ElvPreviewItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Y: Integer;
begin
  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y, False, nil, False);
end;

procedure TFormImportImages.FinishScan;
var
  SI: TBaseSelectItem;
  Data: TList<TPathItem>;

begin
  HideLoadingSign;
  FIsReady := True;
  if FMode = piModeSimple then
  begin
    Data := TList<TPathItem>.Create;
    for SI in FSeries.InnerItems do
      SI.FillItems(Data);

    NewFormState;
    ClearItems;
    TImportSeriesPreview.Create(Self, Data, 125);
  end else if FMode = piModeExtended then
    BtnOk.Enabled := FSeries.Count > 0;
end;

procedure TFormImportImages.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFormImportImages.FormCreate(Sender: TObject);
var
  PathImage: TBitmap;
begin
  RegisterMainForm(Self);
  FBitmapImageList := TBitmapImageList.Create;
  FPreviewData := TList<TPathItem>.Create;

  FItemUpdateLastTime := GetTickCount;
  FItemUpdateTimer := TTimer.Create(nil);
  FItemUpdateTimer.Enabled := False;
  FItemUpdateTimer.Interval := 100;
  FItemUpdateTimer.OnTimer := ItemUpdateTimer;

  FSeries := TSelectDateCollection.Create(SbSeries);

  WlLabel.LoadFromResource('SERIES_EDIT');
  WlDate.LoadFromResource('SERIES_DATE');
  WlSetLabel.LoadFromResource('SERIES_OK');
  WlSetDate.LoadFromResource('SERIES_OK');

  LoadLanguage;
  AllignSimpleOptions;

  PathImage := GetPathSeparatorImage;
  try
    PeImportFromPath.SeparatorImage := PathImage;
    PeImportToPath.SeparatorImage := PathImage;
  finally
    F(PathImage);
  end;

  FIsSimpleLabelEditing := False;
  FIsSimpleDateEditing := False;
  FIsDisplayingPreviews := False;
  FixFormPosition;
  ReadOptions;

  FSimpleDate := MinDateTime;
  FSimpleLabel := '';

  if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
    ElvPreview.ShowThemedBorder := False;

  SetListViewColors(ElvPreview);

  SwitchMode;
end;

procedure TFormImportImages.FormDestroy(Sender: TObject);
begin
  ClearItems;

  F(FBitmapImageList);
  FreeList(FPreviewData);

  F(FSeries);
  F(FItemUpdateTimer);
  UnRegisterMainForm(Self);
end;

function TFormImportImages.GetFormID: string;
begin
  Result := 'ImportPictures';
end;

function TFormImportImages.GetImagesCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FSeries.Count - 1 do
    Inc(Result, FSeries[I].ItemsCount);
end;

function TFormImportImages.GetImagesSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FSeries.Count - 1 do
    Inc(Result, FSeries[I].ItemsSize);
end;

procedure TFormImportImages.HideLoadingSign;
begin
  LsMain.Hide;
end;

procedure TFormImportImages.ShowLoadingSign;
begin
  LsMain.Show;
end;

procedure TFormImportImages.UpdateItemsCount;
begin
  ImInfo.Visible := ImagesCount = 0;
  LbSeriesInfo.Visible := ImagesCount = 0;
  if FIsDisplayingPreviews then
    WlHideShowPictures.Text := FormatEx(L('Hide photos ({0}, {1})'), [ImagesCount, SizeInText(ImagesSize)])
  else
  begin
    WlHideShowPictures.Enabled := ImagesCount > 0;
    if WlHideShowPictures.Enabled then
      WlHideShowPictures.Text := FormatEx(L('Show photos ({0}, {1})'), [ImagesCount, SizeInText(ImagesSize)])
    else
      WlHideShowPictures.Text := L('Show photos');
  end;
end;

procedure TFormImportImages.SwitchMode(NewMode: Boolean = True);
begin
  if FMode = piModeSimple then
  begin
    GbSeries.Caption := '';
    BtnOk.Enabled := True;
    FSeries.ClearSelection;
    SbSeries.HorzScrollBar.Visible := False;
    UpdateItemsCount;

    UnlockHeight;
    if FIsDisplayingPreviews then
    begin
      WlHideShowPictures.LoadFromResource('SERIES_COLLAPSE');
      ElvPreview.Show;
      if NewMode or (Height < 396) then
        Height := 396;
      GbSeries.Height := 180;
      GbSeries.Visible := True;
      GbSeries.Caption := '';
    end else
    begin
      WlHideShowPictures.LoadFromResource('SERIES_EXPAND');
      Height := 220;
      ElvPreview.Hide;
      LockHeight;
      GbSeries.Visible := False;
    end;
    GbSeries.Top := 138;
    WlHideShowPictures.Refresh;

    WlMode.Text := L('Extended mode');
    SbSeries.Hide;
    ElvPreview.Top := 20;
    WlHideShowPictures.Show;

    AllignSimpleOptions;
    PnSimpleOptions.Visible := True;
    ElvPreview.Width := GbSeries.Width - 20;
    ElvPreview.Height := GbSeries.Height - 30;
  end else
  begin
    BtnOk.Enabled := FIsReady and (FSeries.Count > 0);
    UnlockHeight;
    GbSeries.Top := 110;
    SbSeries.HorzScrollBar.Visible := True;
    if FIsDisplayingPreviews then
    begin
      if NewMode or (Height < 470) then
        Height := 470;

      if NewMode or (GbSeries.Height < 280) then
      GbSeries.Height := 280;
      ElvPreview.Show;
    end else
    begin
      Height := 310;
      GbSeries.Height := 122;
      ElvPreview.Hide;
      LockHeight;
    end;

    PnSimpleOptions.Visible := False;
    if ImagesCount > 0 then
      GbSeries.Caption := FormatEx(L('Series of photos ({0})'), [FSeries.Count])
    else
      GbSeries.Caption := L('Series of photos');
    SbSeries.Show;
    SbSeries.Width := GbSeries.Width - 17;
    ElvPreview.Top := SbSeries.Top + SbSeries.Height + 5;
    ElvPreview.Height := GbSeries.Height - ElvPreview.Top - 10;
    WlMode.Text := L('Simple mode');
    WlHideShowPictures.Hide;

    GbSeries.Visible := True;
  end;
end;

procedure TFormImportImages.ItemUpdateTimer(Sender: TObject);
begin
  FItemUpdateTimer.Enabled := False;
  FSeries.UpdateModel;
end;

procedure TFormImportImages.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import pictures');
    LbImportFrom.Caption := L('Import from') + ':';
    LbImportTo.Caption := L('Import to') + ':';
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    BtnSettings.Caption := L('Settings');
    PeImportFromPath.LoadingText := L('Loading...');
    PeImportToPath.LoadingText := L('Loading...');

    WlSetDate.Text := L('Ok');
    WlSetLabel.Text := L('Ok');
    WlResetDate.Text := L('(Reset)');
    WedLabel.WatermarkText := L('Enter label');

    LbSeriesInfo.Caption := L('Photos in selected location were not found! Please select another location to see series of photos.');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportImages.LockHeight;
begin
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

procedure TFormImportImages.UnlockHeight;
begin
  Constraints.MaxHeight := 0;
  Constraints.MinHeight := 0;
end;

procedure TFormImportImages.PeImportFromPathChange(Sender: TObject);
begin
  if not (PeImportFromPath.PathEx is THomeItem) then
  begin
    NewFormState;
    FSeries.Clear;
    FSeries.UpdateModel;
    FIsDisplayingPreviews := False;
    FIsReady := False;
    SwitchMode;
    TImportScanThread.Create(Self, PeImportFromPath.PathEx, Settings.ReadBool('ImportPictures', 'OnlyImages', False));
  end;
end;

procedure TFormImportImages.ReadOptions;
begin
  PeImportToPath.Path := Settings.ReadString('ImportPictures', 'Destination', GetMyPicturesPath);
  PeImportFromPath.Path := Settings.ReadString('ImportPictures', 'Source', '');

  FMode := TImportPicturesMode(Settings.ReadInteger('ImportPictures', 'Source', Integer(piModeSimple)));
end;

procedure TFormImportImages.SbSeriesResize(Sender: TObject);
var
  W: Integer;
begin
  W := SbSeries.Width div 2 - (ImInfo.Width + 10 + LbSeriesInfo.Width) div 2;
  ImInfo.Left := W;
  LbSeriesInfo.Left := ImInfo.Left + ImInfo.Width + 10;
end;

procedure TFormImportImages.SetPath(Path: string);
begin
  PeImportFromPath.Path := Path;
  FOriginalPath := Path;
end;

procedure TFormImportImages.SetSeriesCount(Count: Integer);
begin
  if FMode = piModeExtended then
    GbSeries.Caption := FormatEx(L('Series of photos ({0})'), [Count]);
end;

procedure TFormImportImages.UpdatePreview(Item: TPathItem; Bitmap: TBitmap);
var
  I: Integer;
  PI: TPathItem;
begin
  for I := 0 to ElvPreview.Items.Count - 1 do
  begin
    PI := TPathItem(ElvPreview.Items[I].Data);
    if PI.Path = Item.Path then
    begin
      FBitmapImageList[ElvPreview.Items[I].ImageIndex].Graphic := Bitmap;
      ElvPreview.Refresh;
      Break;
    end;
  end;
end;

procedure TFormImportImages.DtpDateExit(Sender: TObject);
begin
  FIsSimpleDateEditing := False;
  AllignSimpleOptions;
end;

procedure TFormImportImages.DtpDateKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    WlSetDateClick(Sender);
  end;
  if Key = VK_ESCAPE then
    DtpDateExit(Sender);
end;

procedure TFormImportImages.WedLabelExit(Sender: TObject);
begin
  FIsSimpleLabelEditing := False;
  AllignSimpleOptions;
end;

procedure TFormImportImages.WedLabelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    WlSetLabelClick(Sender);
  end;
  if Key = VK_ESCAPE then
    WedLabelExit(Sender);
end;

procedure TFormImportImages.WlDateClick(Sender: TObject);
begin
  FIsSimpleLabelEditing := False;
  FIsSimpleDateEditing := True;

  if FSimpleDate = MinDateTime then
  begin
    DtpDate.Date := DateOf(Now);
    if ImagesCount > 0 then
      DtpDate.Date := FSeries.StatDate;
  end;

  AllignSimpleOptions;
end;

procedure TFormImportImages.WlHideShowPicturesClick(Sender: TObject);
begin
  FIsDisplayingPreviews := not FIsDisplayingPreviews;
  SwitchMode;
end;

procedure TFormImportImages.WlLabelClick(Sender: TObject);
begin
  FIsSimpleDateEditing := False;
  FIsSimpleLabelEditing := True;
  AllignSimpleOptions;
end;

procedure TFormImportImages.WlModeClick(Sender: TObject);
begin
  if FMode = piModeExtended then
    FMode := piModeSimple
  else
    FMode := piModeExtended;

  FIsDisplayingPreviews := False;
  Settings.WriteInteger('ImportPictures', 'Mode', Integer(FMode));
  SwitchMode;
  FinishScan;
end;

procedure TFormImportImages.WlResetDateClick(Sender: TObject);
begin
  FSimpleDate := MinDateTime;
  AllignSimpleOptions;
end;

procedure TFormImportImages.WlSetDateClick(Sender: TObject);
begin
  FSimpleDate := DtpDate.Date;
  DtpDateExit(Sender);
end;

procedure TFormImportImages.WlSetLabelClick(Sender: TObject);
begin
  FSimpleLabel := WedLabel.Text;
  WedLabelExit(Sender);
end;

initialization
  FormInterfaces.RegisterFormInterface(IImportForm, TFormImportImages);

end.


