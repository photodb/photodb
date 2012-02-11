unit uFormImportImages;

interface

uses
  Generics.Collections,
  uConstants,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  WebLink,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  WatermarkedEdit,
  PathEditor,
  UnitDBFileDialogs,
  uMemory,
  uShellUtils,
  DateUtils,
  uRuntime,
  uResources,
  uSettings,
  uThreadForm,
  uPathProviders,
  uGraphicUtils,
  LoadingSign,
  uSysUtils,
  uTranslate,
  Dolphin_db,
  Vcl.ExtCtrls,
  MPCommonObjects,
  EasyListview,
  uVCLHelpers,
  uListViewUtils,
  MPCommonUtilities,
  uDBPopupMenuInfo,
  UnitDBDeclare,
  uAssociations,
  UnitBitmapImageList,
  uExplorerFSProviders,
  uExplorerMyComputerProvider,
  uStringUtils,
  Menus,
  Math,
  uPathUtils;

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

type
  TImportPicturesMode = (piModeSimple, piModeExtended);

type
  TBaseSelectItem = class
  private
    FItemLabel: string;
    FIsSelected: Boolean;
  protected
    function GetItemsCount: Integer; virtual; abstract;
    function GetItemsSize: Int64; virtual; abstract;
  public
    constructor Create;
    property ItemLabel: string read FItemLabel write FItemLabel;
    property ItemsSize: Int64 read GetItemsSize;
    property ItemsCount: Integer read GetItemsCount;
    property IsSelected: Boolean read FIsSelected write FIsSelected;
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
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddItem(Item: TPathItem; Size: Int64);
    property Date: TDateTime read FDate write FDate;
    property Items: TList<TPathItem> read FItems;
  end;

  TSelectDateItems = class(TBaseSelectItem)
  private
    FItems: TList<TSelectDateItem>;
    function GetEndDate: TDateTime;
    function GetStartDate: TDateTime;
  protected
    function GetItemsCount: Integer; override;
    function GetItemsSize: Int64; override;
  public
    constructor Create;
    destructor Destroy; override;
    property StartDate: TDateTime read GetStartDate;
    property EndDate: TDateTime read GetEndDate;
    property Items: TList<TSelectDateItem> read FItems;
  end;

  TSelectDateCollection = class
  private
    FItems: TList<TBaseSelectItem>;
    FContainer: TScrollBox;
    FMenuOptions: TPopupMenu;
    function GetScrollBoxByItem(Index: TBaseSelectItem): TScrollBox;
    function GetItemByIndex(Index: Integer): TBaseSelectItem;
    function GetCont: Integer;
    property DisplayItems[Index: TBaseSelectItem]: TScrollBox read GetScrollBoxByItem;
    procedure OnItemEditClick(Sender: TObject);
    procedure OnDateEditClick(Sender: TObject);
    function FindChildByTag<T: TWinControl>(Parent: TWinControl; Tag: NativeInt): T;
  protected
    procedure OnEditLabelEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditLabelOkClick(Sender: TObject);
    procedure EndEditLabel(Item: TBaseSelectItem);

    procedure OnEditDateEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditDateOkClick(Sender: TObject);
    procedure EndEditDate(Item: TSelectDateItem);

    procedure OnBoxMouseLeave(Sender: TObject);
    procedure OnBoxMouseEnter(Sender: TObject);
    procedure OnBoxClick(Sender: TObject);
    procedure ShowSettings(Sender: TObject);
  public
    constructor Create(Container: TScrollBox);
    destructor Destroy; override;
    procedure Clear;
    procedure UpdateModel;
    procedure ClearSelection;
    procedure AddDateInfo(Item: TPathItem; Date: TDateTime; Size: Int64);
    property Items[Index: Integer]: TBaseSelectItem read GetItemByIndex; default;
    property Count: Integer read GetCont;
  end;

  TScanItem = class(TObject)
  public
    Item: TPathItem;
    Date: TDateTime;
    Size: Int64;
    constructor Create(AItem: TPathItem; ADate: TDateTime; ASize: Int64);
  end;

type
  TFormImportImages = class(TThreadForm)
    LbImportFrom: TLabel;
    LbDirectoryFormat: TLabel;
    LbImportTo: TLabel;
    PeImportFromPath: TPathEditor;
    CbFormatCombo: TComboBox;
    BtnSelectPathFrom: TButton;
    PeImportToPath: TPathEditor;
    BtnSelectPathTo: TButton;
    CbOnlyImages: TCheckBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    CbDeleteAfterImport: TCheckBox;
    CbAddToCollection: TCheckBox;
    GbSeries: TGroupBox;
    SbSeries: TScrollBox;
    WlMode: TWebLink;
    ElvPreview: TEasyListview;
    LsMain: TLoadingSign;
    WlHideShowPictures: TWebLink;
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
  private
    { Private declarations }
    FItemUpdateTimer: TTimer;
    FItemUpdateLastTime: Cardinal;
    FSeries: TSelectDateCollection;
    FBitmapImageList: TBitmapImageList;
    FPreviewData: TList<TPathItem>;
    FMode: TImportPicturesMode;
    FIsDisplayingPreviews: Boolean;
    procedure LoadLanguage;
    procedure ReadOptions;
    procedure SwitchMode;
    procedure ItemUpdateTimer(Sender: TObject);
    procedure ClearItems;
    procedure UpdateItemsCount;
    function GetImagesCount: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure SetPath(Path: string);
    procedure AddItems(Items: TList<TScanItem>);
    procedure AddPreviews(FPacketInfos: TList<TPathItem>; FPacketImages: TBitmapImageList);
    procedure UpdatePreview(Item: TPathItem; Bitmap: TBitmap);
    property ImagesCount: Integer read GetImagesCount;
  end;

var
  FormImportImages: TFormImportImages;

procedure GetPhotosFromDevice(DeviceName: string);

{$R PicturesImport.res}

implementation

uses
  uThreadImportPictures,
  uImportScanThread,
  uImportSeriesPreview,
  SlideShow,
  FormManegerUnit;

procedure GetPhotosFromDevice(DeviceName: string);
var
  FormImportImages: TFormImportImages;
begin
  Application.CreateForm(TFormImportImages, FormImportImages);
  FormImportImages.SetPath(cDevicesPath + '\' + DeviceName);
  FormImportImages.Show;
end;

{ TBaseSelectItem }

constructor TBaseSelectItem.Create;
begin
  FIsSelected := False;
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

constructor TSelectDateItem.Create;
begin
  FItems := TList<TPathItem>.Create;
end;

destructor TSelectDateItem.Destroy;
begin
  FreeList(FItems);
  inherited;
end;

function TSelectDateItem.GetItemsCount: Integer;
begin
  Result := FItemsCount;
end;

function TSelectDateItem.GetItemsSize: Int64;
begin
  Result := FItemsSize;
end;

{ TSelectDateItems }

constructor TSelectDateItems.Create;
begin
  FItems := TList<TSelectDateItem>.Create;
end;

destructor TSelectDateItems.Destroy;
begin
  FreeList(FItems);
  inherited;
end;

function TSelectDateItems.GetEndDate: TDateTime;
var
  I: Integer;
begin
  Result := MinDateTime;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Date > Result then
      Result := FItems[I].Date;
end;

function TSelectDateItems.GetStartDate: TDateTime;
var
  I: Integer;
begin
  Result := MinDateTime;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Date < Result then
      Result := FItems[I].Date;
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

{ TSelectDateCollection }

procedure TSelectDateCollection.AddDateInfo(Item: TPathItem; Date: TDateTime; Size: Int64);
var
  SI: TBaseSelectItem;
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

  SI := TSelectDateItem.Create;
  TSelectDateItem(SI).Date := Date;
  TSelectDateItem(SI).FItemsCount := 1;
  TSelectDateItem(SI).FItemsSize := Size;
  TSelectDateItem(SI).Items.Add(Item.Copy);
  FItems.Add(SI);
  SI.ItemLabel := 'Some label';
end;

procedure TSelectDateCollection.Clear;
var
  SI: TBaseSelectItem;
  Sb: TScrollBox;
begin
  for SI in FItems do
  begin
    Sb := DisplayItems[SI];
    if Sb <> nil then
      Sb.Free;
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
var
  MI: TMenuItem;
begin
  FContainer := Container;
  FItems := TList<TBaseSelectItem>.Create;
  FMenuOptions := TPopupMenu.Create(nil);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Show objects', 'ImportPictures');
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Don''t import', 'ImportPictures');
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Merge left', 'ImportPictures');
  FMenuOptions.Items.Add(MI);

  MI := TMenuItem.Create(FMenuOptions);
  MI.Caption := TA('Merge right', 'ImportPictures');
  FMenuOptions.Items.Add(MI);
end;

destructor TSelectDateCollection.Destroy;
begin
  F(FMenuOptions);
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
  Index: TBaseSelectItem): TScrollBox;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FContainer.ControlCount - 1 do
    if FContainer.Controls[I] is TScrollBox then
      if FContainer.Controls[I].Tag = NativeInt(Index) then
      begin
        Result := TScrollBox(FContainer.Controls[I]);
        Exit;
      end;
end;

function TSelectDateCollection.FindChildByTag<T>(Parent: TWinControl; Tag: NativeInt): T;
var
  I: Integer;
begin
  Result := default(T);
  for I := 0 to Parent.ControlCount - 1 do
  begin
    if Parent.Controls[I].Tag = Tag then
    begin
      Result := Parent.Controls[I] as T;
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
  SI: TSelectDateItem;
begin
  SI := TSelectDateItem(TWinControl(Sender).Parent.Tag);
  EndEditDate(SI);
end;

procedure TSelectDateCollection.EndEditDate(Item: TSelectDateItem);
var
  Sb: TScrollBox;
  Dp: TDateTimePicker;
  LnkOk, LnkDate: TWebLink;
begin
  Sb := DisplayItems[Item];
  if (Sb <> nil) then
  begin
    LnkDate := FindChildByTag<TWebLink>(Sb, TAG_DATE);
    Dp := FindChildByTag<TDateTimePicker>(Sb, TAG_EDIT_DATE);
    LnkOk := FindChildByTag<TWebLink>(Sb, TAG_EDIT_DATE_OK);
    Item.Date := Dp.Date;

    LnkDate.Text := FormatDateTime('yyyy-mm-dd', Dp.Date);

    LnkOk.Hide;
    Dp.Hide;
    LnkDate.Show;
  end;
end;

procedure TSelectDateCollection.EndEditLabel(Item: TBaseSelectItem);
var
  Sb: TScrollBox;
  SI: TBaseSelectItem;
  Edit: TWatermarkedEdit;
  LnkOk, LnkLabel: TWebLink;
  I, TextSize, Left: Integer;
begin
  Sb := DisplayItems[Item];
  if (Sb <> nil) then
  begin
    LnkLabel := FindChildByTag<TWebLink>(Sb, TAG_LABEL);
    Edit := FindChildByTag<TWatermarkedEdit>(Sb, TAG_EDIT_LABEL);
    LnkOk := FindChildByTag<TWebLink>(Sb, TAG_EDIT_LABEL_OK);

    Item.ItemLabel := Edit.Text;
    LnkLabel.Text := Edit.Text;

    LnkOk.Hide;
    Edit.Hide;
    LnkLabel.Show;

    Left := 5;
    for I := 0 to FItems.Count - 1 do
    begin
      SI := FItems[I];
      Sb := DisplayItems[SI];

      LnkLabel := FindChildByTag<TWebLink>(Sb, TAG_LABEL);
      TextSize := Math.Min(Math.Max(LnkLabel.Width - LnkLabel.Left - 5, 175 - 18), 450);
      Sb.Width := TextSize + 18;
      Sb.Left := Left - FContainer.HorzScrollBar.Position;
      Left := Left + Sb.Width + 5;
    end;
  end;
end;

procedure TSelectDateCollection.OnBoxClick(Sender: TObject);
var
  Sb: TScrollBox;
  SI: TBaseSelectItem;
  I: Integer;
  Data: TList<TPathItem>;

  procedure AddToList(Item: TSelectDateItem);
  var
    J: Integer;
  begin
    for J := 0 to Item.Items.Count - 1 do
      Data.Add(Item.Items[J].Copy);
  end;

begin

  if Sender is TScrollBox then
    Sb := TScrollBox(Sender)
  else
    Sb := TScrollBox(TWinControl(Sender).Parent);

  Data := TList<TPathItem>.Create;

  SI := TBaseSelectItem(Sb.Tag);

  for I := 0 to FItems.Count - 1 do
    FItems[I].IsSelected := False;
  SI.IsSelected := True;

  for I := 0 to FItems.Count - 1 do
  begin
    if FItems[I] <> SI then
      DisplayItems[FItems[I]].OnMouseLeave(DisplayItems[FItems[I]]);
  end;

  if SI is TSelectDateItem then
    AddToList(TSelectDateItem(SI))
  else
    for I := 0 to TSelectDateItems(SI).ItemsCount - 1 do
      AddToList(TSelectDateItems(SI).Items[I]);

  TFormImportImages(Sb.Owner).NewFormState;
  TFormImportImages(Sb.Owner).ClearItems;
  TImportSeriesPreview.Create(TThreadForm(Sb.Owner), Data, 125);
end;

procedure TSelectDateCollection.OnBoxMouseEnter(Sender: TObject);
var
  Sb: TScrollBox;
  SI: TBaseSelectItem;
begin
  if Sender is TScrollBox then
    Sb := TScrollBox(Sender)
  else
    Sb := TScrollBox(TWinControl(Sender).Parent);

  SI := TBaseSelectItem(Sb.Tag);
  if SI.IsSelected then
    Sb.Color := $FFFFAF
  else
    Sb.Color := $FFFFAF;
end;

procedure TSelectDateCollection.OnBoxMouseLeave(Sender: TObject);
var
  Sb: TScrollBox;
  SI: TBaseSelectItem;
begin
  if Sender is TScrollBox then
    Sb := TScrollBox(Sender)
  else
    Sb := TScrollBox(TWinControl(Sender).Parent);

  SI := TBaseSelectItem(Sb.Tag);
  if SI.IsSelected then
    Sb.Color := $CFCFCF
  else
    Sb.Color := $FFFFFF
end;

procedure TSelectDateCollection.OnDateEditClick(Sender: TObject);
var
  DtpEditDate: TDateTimePicker;
  LnkLabel, LnkOk: TWebLink;
  SI: TBaseSelectItem;
  Parent: TScrollBox;
begin
  LnkLabel := TWebLink(Sender);
  LnkLabel.Hide;

  Parent := TScrollBox(LnkLabel.Parent);
  SI := TBaseSelectItem(Parent.Tag);
  if SI is TSelectDateItem then
  begin

    DtpEditDate := FindChildByTag<TDateTimePicker>(Parent, TAG_EDIT_DATE);
    if DtpEditDate = nil then
    begin
      DtpEditDate := TDateTimePicker.Create(FContainer.Owner);
      DtpEditDate.Anchors := [akTop, akLeft, akRight];
      DtpEditDate.Parent := Parent;
      DtpEditDate.Left := 3;
      DtpEditDate.Top := 27;
      DtpEditDate.Width := 121;
      DtpEditDate.Height := 21;
      DtpEditDate.Date := TSelectDateItem(SI).Date;
      DtpEditDate.Tag := TAG_EDIT_DATE;
      DtpEditDate.OnKeyDown := OnEditDateEditKeyDown;
      DtpEditDate.OnExit := OnEditDateOkClick;
      DtpEditDate.OnMouseEnter := OnBoxMouseEnter;
      DtpEditDate.OnMouseLeave := OnBoxMouseLeave;
    end;

    LnkOk := FindChildByTag<TWebLink>(Parent, TAG_EDIT_DATE_OK);
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
      LnkOk.ImageCanRegenerate := True;
      LnkOk.OnClick := OnEditDateOkClick;
      LnkOk.Refresh;
      LnkOk.OnMouseEnter := OnBoxMouseEnter;
      LnkOk.OnMouseLeave := OnBoxMouseLeave;
    end;

    DtpEditDate.Show;
    DtpEditDate.SetFocus;
    LnkOk.Show;
  end;
end;

procedure TSelectDateCollection.OnItemEditClick(Sender: TObject);
var
  WebEditLabel: TWatermarkedEdit;
  LnkLabel, LnkOk: TWebLink;
  SI: TBaseSelectItem;
  Parent: TScrollBox;
begin
  LnkLabel := TWebLink(Sender);
  LnkLabel.Hide;

  Parent := TScrollBox(LnkLabel.Parent);
  SI := TBaseSelectItem(Parent.Tag);

  WebEditLabel := FindChildByTag<TWatermarkedEdit>(Parent, TAG_EDIT_LABEL);
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
    WebEditLabel.WatermarkText := TA('ImportPictures', 'Label');
    WebEditLabel.Tag := TAG_EDIT_LABEL;
    WebEditLabel.OnKeyDown := OnEditLabelEditKeyDown;
    WebEditLabel.OnExit := OnEditLabelOkClick;
    WebEditLabel.OnMouseEnter := OnBoxMouseEnter;
    WebEditLabel.OnMouseLeave := OnBoxMouseLeave;
  end;

  LnkOk := FindChildByTag<TWebLink>(Parent, TAG_EDIT_LABEL_OK);
  if LnkOk = nil then
  begin
    LnkOk := TWebLink.Create(FContainer.Owner);
    LnkOk.Anchors := [akTop, akRight];
    LnkOk.Parent := Parent;
    LnkOk.Left := 130;
    LnkOk.Top := 6;
    LnkOk.Text := TA('Ok');
    LnkOk.ImageCanRegenerate := True;
    LnkOk.HightliteImage := True;
    LnkOk.Tag := TAG_EDIT_LABEL_OK;
    LnkOk.LoadFromResource('SERIES_OK');
    LnkOk.OnClick := OnEditLabelOkClick;
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
begin
  GetCursorPos(P);
  FMenuOptions.Popup(P.X, P.Y);
end;

procedure TSelectDateCollection.UpdateModel;
var
  I, Left: Integer;
  Sb: TScrollBox;
  WlLabel, WlDate, WlItemsCount, WlSize, WlSettings: TWebLink;
  SI: TBaseSelectItem;

begin
  //BeginScreenUpdate(FContainer.Handle);
  Left := 5;
  try
    for I := 0 to FItems.Count - 1 do
    begin
      SI := FItems[I];
      Sb := DisplayItems[SI];
      if Sb = nil then
      begin
        Sb := TScrollBox.Create(FContainer.Owner);
        Sb.Color := clWhite;
        Sb.Visible := False;
        Sb.Parent := FContainer;
        Sb.Width := 175;
        Sb.Height := 75;
        Sb.HorzScrollBar.Visible := False;
        Sb.VertScrollBar.Visible := False;
        Sb.BevelKind := bkTile;
        Sb.BorderStyle := bsNone;
        Sb.Top := 3;
        Sb.Tag := NativeInt(FItems[I]);
        Sb.OnMouseEnter := OnBoxMouseEnter;
        Sb.OnMouseLeave := OnBoxMouseLeave;
        Sb.OnClick := OnBoxClick;

        WlLabel := TWebLink.Create(FContainer.Owner);
        WlLabel.Parent := Sb;
        WlLabel.Left := 2;
        WlLabel.Top := 6;
        WlLabel.LoadFromResource('SERIES_EDIT');
        WlLabel.ImageCanRegenerate := True;
        WlLabel.Refresh;
        WlLabel.Tag := TAG_LABEL;
        WlLabel.OnClick := OnItemEditClick;
        WlLabel.OnMouseEnter := OnBoxMouseEnter;
        WlLabel.OnMouseLeave := OnBoxMouseLeave;

        WlDate := TWebLink.Create(FContainer.Owner);
        WlDate.Parent := Sb;
        WlDate.Left := 2;
        WlDate.Top := 28;
        WlDate.LoadFromResource('SERIES_DATE');
        WlDate.ImageCanRegenerate := True;
        WlDate.Refresh;
        WlDate.Tag := TAG_DATE;
        WlDate.OnClick := OnDateEditClick;
        WlDate.OnMouseEnter := OnBoxMouseEnter;
        WlDate.OnMouseLeave := OnBoxMouseLeave;

        WlItemsCount := TWebLink.Create(FContainer.Owner);
        WlItemsCount.IconWidth := 0;
        WlItemsCount.IconHeight := 0;
        WlItemsCount.Parent := Sb;
        WlItemsCount.Left := 2;
        WlItemsCount.Top := 50;
        WlItemsCount.ImageCanRegenerate := True;
        WlItemsCount.Tag := TAG_ITEMS_COUNT;
        WlItemsCount.OnMouseEnter := OnBoxMouseEnter;
        WlItemsCount.OnMouseLeave := OnBoxMouseLeave;
        WlItemsCount.OnClick := OnBoxClick;

        WlSize := TWebLink.Create(FContainer.Owner);
        WlSize.IconWidth := 0;
        WlSize.IconHeight := 0;
        WlSize.Parent := Sb;
        WlSize.Left := 60;
        WlSize.Top := 50;
        WlSize.ImageCanRegenerate := True;
        WlSize.Tag := TAG_ITEMS_SIZE;
        WlSize.OnMouseEnter := OnBoxMouseEnter;
        WlSize.OnMouseLeave := OnBoxMouseLeave;
        WlSize.OnClick := OnBoxClick;

        WlSettings := TWebLink.Create(FContainer.Owner);
        WlSettings.Anchors := [akTop, akRight];
        WlSettings.Parent := Sb;
        WlSettings.Left := 150;
        WlSettings.Top := 52;
        WlSettings.TopIconIncrement := 0;
        WlSettings.LoadFromResource('SERIES_SETTINGS');
        WlSettings.ImageCanRegenerate := True;
        WlSettings.Refresh;
        WlSettings.Tag := TAG_SETTINGS;
        WlSettings.OnMouseEnter := OnBoxMouseEnter;
        WlSettings.OnMouseLeave := OnBoxMouseLeave;
        WlSettings.OnClick := ShowSettings;

        TGroupBox(Sb.Parent.Parent).Caption := FormatEx(TA('Series of photos ({0})'), [FItems.Count]);
      end;
      Sb.Left := Left - FContainer.HorzScrollBar.Position;
      Left := Left + 180;
      Sb.Show;

      WlLabel := FindChildByTag<TWebLink>(Sb, TAG_LABEL);
      WlLabel.Text := SI.ItemLabel;

      WlDate := FindChildByTag<TWebLink>(Sb, TAG_DATE);
      if SI is TSelectDateItem then
        WlDate.Text := FormatDateTime('yyyy-mm-dd', TSelectDateItem(SI).Date)
      else
        WlDate.Text := FormatDateTime('yyyy-mm-dd', TSelectDateItems(SI).StartDate) + ' - ' + FormatDateTime('yyyy-mm-dd', TSelectDateItems(SI).EndDate);

      WlItemsCount := FindChildByTag<TWebLink>(Sb, TAG_ITEMS_COUNT);
      WlItemsCount.Text := FormatEx(TA('{0} Files', 'ImportPictures'), [SI.ItemsCount]);

      WlSize := FindChildByTag<TWebLink>(Sb, TAG_ITEMS_SIZE);
      WlSize.Left := WlItemsCount.Left + WlItemsCount.Width + 5;
      WlSize.Text := SizeInText(SI.ItemsSize);
    end;
  finally
    //EndScreenUpdate(FContainer.Handle, True);
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
  PD, PS: TPathItem;
  SI: TBaseSelectItem;
  Pattern: string;

  function MonthToString(Date: TDate; Scope: string): string;
  const
    MonthList: array[1..12] of string = ('january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december');
  begin
    Result := L(MonthList[MonthOf(Date)], Scope);
  end;

  function WeekDayToString(Date: TDate): string;
  const
    MonthList: array[1..7] of string = ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
  begin
    Result := L(MonthList[DayOfTheWeek(Date)], 'Date');
  end;

  function FormatPath(Date: TDate; Patern, ItemsLabel: string): string;
  var
    SR: TStringReplacer;
  begin
    SR := TStringReplacer.Create(Patern);
    try
      SR.AddPattern('''LABEL''', '''' + ItemsLabel + '''');
      SR.AddPattern('[LABEL]', '[' + ItemsLabel + ']');
      SR.AddPattern('(LABEL)', '(' + ItemsLabel + ')');
      SR.AddPattern('LABEL', ItemsLabel);
      SR.AddPattern('YYYY', FormatDateTime('yyyy', Date));
      SR.AddPattern('YY', FormatDateTime('yy', Date));
      SR.AddPattern('MMMM', MonthToString(Date, 'Date'));
      SR.AddPattern('MMM', MonthToString(Date, 'Month'));
      SR.AddPattern('MM', FormatDateTime('mm', Date));
      SR.AddPattern('M', FormatDateTime('M', Date));
      SR.AddPattern('DDD', WeekDayToString(Date));
      SR.AddPattern('DD', FormatDateTime('dd', Date));
      SR.AddPattern('d', FormatDateTime('d', Date));

      Result := SR.Result;
    finally
      F(SR);
    end;
  end;

  procedure AddToList(Serie: TSelectDateItem);
  var
    I: Integer;
    DestPath, Path: string;
    D: TPathItem;
  begin
    Path := PD.Path + '\' + FormatPath(Serie.Date, Pattern, Serie.ItemLabel);
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
  Pattern := CbFormatCombo.Text;

  Options := TImportPicturesOptions.Create;
  Options.OnlySupportedImages := CbOnlyImages.Checked;
  Options.DeleteFilesAfterImport := CbDeleteAfterImport.Checked;
  Options.AddToCollection := CbAddToCollection.Checked;
  Options.Source := PeImportFromPath.PathEx;
  Options.Destination := PeImportToPath.PathEx;

  PS := PeImportFromPath.PathEx;
  PD := PeImportToPath.PathEx;
  if FMode = piModeSimple then
  begin
    Task := TImportPicturesTask.Create;
    Options.AddTask(Task);

    //create path using datetime and label
    Operation := TFileOperationTask.Create(PS, PD);
    Task.AddOperation(Operation);
  end else
  begin
    Task := TImportPicturesTask.Create;
    Options.AddTask(Task);

    for I := 0 to FSeries.Count - 1 do
    begin
      SI := FSeries[I];

      if SI is TSelectDateItem then
        AddToList(TSelectDateItem(SI))
      else
        for J := 0 to TSelectDateItems(SI).ItemsCount - 1 do
          AddToList(TSelectDateItems(SI).Items[J]);
    end;
  end;

  TThreadImportPictures.Create(Options);

  Settings.WriteBool('ImportPictures', 'OnlyImages', CbOnlyImages.Checked);
  Settings.WriteBool('ImportPictures', 'DeleteFiles', CbDeleteAfterImport.Checked);
  Settings.WriteBool('ImportPictures', 'AddToCollection', CbAddToCollection.Checked);
  Settings.WriteString('ImportPictures', 'Source', PeImportFromPath.Path);
  Settings.WriteString('ImportPictures', 'Destination', PeImportToPath.Path);

  Close;
end;

procedure TFormImportImages.BtnSelectPathFromClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select a folder or device with images'), '', UseSimpleSelectFolderDialog);

  if Dir <> '' then
     PeImportFromPath.Path := Dir;
end;

procedure TFormImportImages.BtnSelectPathToClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select destination directory'), GetMyPicturesPath, UseSimpleSelectFolderDialog);

  if Dir <> '' then
     PeImportToPath.Path := Dir;
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
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      Viewer.Execute(Sender, MenuInfo);
      Viewer.Show;
    end;
  finally
    F(MenuInfo);
  end;
end;

procedure TFormImportImages.ElvPreviewItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Exists: Integer;
  Y: Integer;
begin
  Exists := 1;
  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y,
    False, 0, Item.Caption, 0, 0, 0, False, True, Exists, True);
end;

procedure TFormImportImages.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
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

  LoadLanguage;

  PathImage := GetPathSeparatorImage;
  try
    PeImportFromPath.SeparatorImage := PathImage;
    PeImportToPath.SeparatorImage := PathImage;
  finally
    F(PathImage);
  end;

  FIsDisplayingPreviews := False;
  FixFormPosition;
  ReadOptions;

  SwitchMode;
end;

procedure TFormImportImages.FormDestroy(Sender: TObject);
begin
  UnRegisterMainForm(Self);
  ClearItems;

  F(FBitmapImageList);
  FreeList(FPreviewData);

  F(FSeries);
  F(FItemUpdateTimer);
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
  if FIsDisplayingPreviews then
  begin
    WlHideShowPictures.Text := FormatEx(L('Hide photos ({0})'), [ImagesCount]);
    GbSeries.Visible := True;
  end else
  begin
    WlHideShowPictures.Text := FormatEx(L('Show photos ({0})'), [ImagesCount]);
    GbSeries.Visible := False;
  end;
end;

procedure TFormImportImages.SwitchMode;
begin
  if FMode = piModeSimple then
  begin
    UpdateItemsCount;

    GbSeries.Caption := '';
    WlMode.Text := L('Extended mode');
    SbSeries.Hide;
    ElvPreview.Top := 20;
    ElvPreview.Height := GbSeries.Height - 30;
    WlHideShowPictures.Show;

    Height := 484;
  end else
  begin
    FSeries.ClearSelection;
    GbSeries.Caption := L('Series of photos');
    SbSeries.Show;
    ElvPreview.Top := SbSeries.Height + 5;
    ElvPreview.Height := GbSeries.Height - ElvPreview.Top - 10;
    WlMode.Text := L('Simple mode');
    WlHideShowPictures.Hide;

    Height := 567;
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
    LbDirectoryFormat.Caption := L('Directory format') + ':';
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    CbOnlyImages.Caption := L('Import only supported images');
    CbDeleteAfterImport.Caption := L('Delete files after import');
    CbAddToCollection.Caption := L('Add files to collection after copying files');
    PeImportFromPath.LoadingText := L('Loading...');
    PeImportToPath.LoadingText := L('Loading...');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportImages.PeImportFromPathChange(Sender: TObject);
begin
  if not (PeImportFromPath.PathEx is THomeItem) then
  begin
    NewFormState;
    FSeries.Clear;
    TImportScanThread.Create(Self, PeImportFromPath.PathEx, CbOnlyImages.Checked);
  end;
end;

procedure TFormImportImages.ReadOptions;
begin
  CbOnlyImages.Checked := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := Settings.ReadBool('ImportPictures', 'AddToCollection', True);

  PeImportToPath.Path := Settings.ReadString('ImportPictures', 'Destination', GetMyPicturesPath);
  PeImportFromPath.Path := Settings.ReadString('ImportPictures', 'Source', '');

  FMode := TImportPicturesMode(Settings.ReadInteger('ImportPictures', 'Source', Integer(piModeSimple)));
end;

procedure TFormImportImages.SetPath(Path: string);
begin
  PeImportFromPath.Path := Path;
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

procedure TFormImportImages.WlHideShowPicturesClick(Sender: TObject);
begin
  FIsDisplayingPreviews := not FIsDisplayingPreviews;
  SwitchMode;
end;

procedure TFormImportImages.WlModeClick(Sender: TObject);
begin
  if FMode = piModeExtended then
    FMode := piModeSimple
  else
    FMode := piModeExtended;

  Settings.WriteInteger('ImportPictures', 'Mode', Integer(FMode));
  SwitchMode;
end;

end.


