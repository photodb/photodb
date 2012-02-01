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
  UnitBitmapImageList;

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
  TBaseSelectItem = class
  private
    FItemLabel: string;
  protected
    function GetItemsCount: Integer; virtual; abstract;
    function GetItemsSize: Int64; virtual; abstract;
  public
    property ItemLabel: string read FItemLabel write FItemLabel;
    property ItemsSize: Int64 read GetItemsSize;
    property ItemsCount: Integer read GetItemsCount;
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
    function GetScrollBoxByItem(Index: TBaseSelectItem): TScrollBox;
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
  public
    constructor Create(Container: TScrollBox);
    destructor Destroy; override;
    procedure Clear;
    procedure UpdateModel;
    procedure AddDateInfo(Item: TPathItem; Date: TDateTime; Size: Int64);
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
    WebLink6: TWebLink;
    ElvPreview: TEasyListview;
    LsMain: TLoadingSign;
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
  private
    { Private declarations }
    FItemUpdateTimer: TTimer;
    FItemUpdateLastTime: Cardinal;
    FSeries: TSelectDateCollection;
    FBitmapImageList: TBitmapImageList;
    FPreviewData: TList<TPathItem>;
    procedure LoadLanguage;
    procedure ReadOptions;
    procedure ItemUpdateTimer(Sender: TObject);
    procedure ClearItems;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure SetPath(Path: string);
    procedure AddItems(Items: TList<TScanItem>);
    procedure AddPreviews(FPacketInfos: TList<TPathItem>; FPacketImages: TBitmapImageList);
    procedure UpdatePreview(Item: TPathItem; Bitmap: TBitmap);
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

constructor TSelectDateCollection.Create(Container: TScrollBox);
begin
  FContainer := Container;
  FItems := TList<TBaseSelectItem>.Create;
end;

destructor TSelectDateCollection.Destroy;
begin
  FreeList(FItems);
  inherited;
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
  Edit: TWatermarkedEdit;
  LnkOk, LnkLabel: TWebLink;
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
  if SI is TSelectDateItem then
    AddToList(TSelectDateItem(SI))
  else
    for I := 0 to TSelectDateItems(SI).ItemsCount - 1 do
      AddToList(TSelectDateItems(SI).Items[I]);

  TFormImportImages(Sb.Owner).ClearItems;
  TImportSeriesPreview.Create(TThreadForm(Sb.Owner), Data, 125);
end;

procedure TSelectDateCollection.OnBoxMouseEnter(Sender: TObject);
var
  Sb: TScrollBox;
begin
  if Sender is TScrollBox then
    Sb := TScrollBox(Sender)
  else
    Sb := TScrollBox(TWinControl(Sender).Parent);

  Sb.Color := $FFFFAF;
end;

procedure TSelectDateCollection.OnBoxMouseLeave(Sender: TObject);
var
  Sb: TScrollBox;
begin
  if Sender is TScrollBox then
    Sb := TScrollBox(Sender)
  else
    Sb := TScrollBox(TWinControl(Sender).Parent);

  Sb.Color := clWhite;
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

procedure TSelectDateCollection.UpdateModel;
var
  I: Integer;
  Sb: TScrollBox;
  WlLabel, WlDate, WlItemsCount, WlSize, WlSettings: TWebLink;
  SI: TBaseSelectItem;

begin
  //BeginScreenUpdate(FContainer.Handle);
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

        WlSettings := TWebLink.Create(FContainer.Owner);
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

        TGroupBox(Sb.Parent.Parent).Caption := FormatEx(TA('Series of photos ({0})'), [FItems.Count]);
      end;
      Sb.Left := 5 + I * (175 + 5) - FContainer.HorzScrollBar.Position;
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
      EI := ElvPreview.Items.Add(FPacketInfos[I]);
      EI.ImageIndex := FBitmapImageList.AddIcon(FPacketImages[I].Icon, True);
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
begin
  Options := TImportPicturesOptions.Create;
  Options.OnlySupportedImages := CbOnlyImages.Checked;
  Options.DeleteFilesAfterImport := CbDeleteAfterImport.Checked;
  Options.AddToCollection := CbAddToCollection.Checked;

  Task := TImportPicturesTask.Create;
  Options.AddTask(Task);

  Operation := TFileOperationTask.Create(PeImportFromPath.PathEx, PeImportToPath.PathEx);
  Task.AddOperation(Operation);
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
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);

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
    Viewer.Execute(Sender, MenuInfo);
    Viewer.Show;
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

  ReadOptions;
  FixFormPosition;
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
  finally
    EndTranslate;
  end;
end;

procedure TFormImportImages.PeImportFromPathChange(Sender: TObject);
begin
  NewFormState;
  FSeries.Clear;
  TImportScanThread.Create(Self, PeImportFromPath.PathEx);
end;

procedure TFormImportImages.ReadOptions;
begin
  CbOnlyImages.Checked := Settings.ReadBool('ImportPictures', 'OnlyImages', False);
  CbDeleteAfterImport.Checked := Settings.ReadBool('ImportPictures', 'DeleteFiles', True);
  CbAddToCollection.Checked := Settings.ReadBool('ImportPictures', 'AddToCollection', True);

  PeImportFromPath.Path := Settings.ReadString('ImportPictures', 'Source', '');
  PeImportToPath.Path := Settings.ReadString('ImportPictures', 'Destination', GetMyPicturesPath);
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

end.
