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
  Vcl.ExtCtrls;

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
  protected
    function GetItemsCount: Integer; override;
    function GetItemsSize: Int64; override;
  public
    procedure AddItem(Size: Int64);
    property Date: TDateTime read FDate write FDate;
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
  end;

  TSelectDateCollection = class
  private
    FItems: TList<TBaseSelectItem>;
    FContainer: TScrollBox;
    function GetScrollBoxByItem(Index: TBaseSelectItem): TScrollBox;
    property DisplayItems[Index: TBaseSelectItem]: TScrollBox read GetScrollBoxByItem;
  public
    constructor Create(Container: TScrollBox);
    destructor Destroy; override;
    procedure Clear;
    procedure UpdateModel;
    procedure AddDateInfo(Date: TDateTime; Size: Int64);
  end;

type
  TFormImportImages = class(TThreadForm)
    LbImportFrom: TLabel;
    LbDirectoryFormat: TLabel;
    LbImportTo: TLabel;
    LbLabel: TLabel;
    PeImportFromPath: TPathEditor;
    CbFormatCombo: TComboBox;
    BtnSelectPathFrom: TButton;
    PeImportToPath: TPathEditor;
    BtnSelectPathTo: TButton;
    WedLabel: TWatermarkedEdit;
    DtpDate: TDateTimePicker;
    LbDate: TLabel;
    CbOnlyImages: TCheckBox;
    BtnOk: TButton;
    BtnCancel: TButton;
    CbDeleteAfterImport: TCheckBox;
    WlExtendedMode: TWebLink;
    CbAddToCollection: TCheckBox;
    GroupBox1: TGroupBox;
    SbSeries: TScrollBox;
    SbDate1: TScrollBox;
    WebLink2: TWebLink;
    WebLink3: TWebLink;
    WebLink4: TWebLink;
    WebLink5: TWebLink;
    LoadingSign1: TLoadingSign;
    WebLink1: TWebLink;
    ScrollBox4: TScrollBox;
    WebLink18: TWebLink;
    WatermarkedEdit8: TWatermarkedEdit;
    DateTimePicker8: TDateTimePicker;
    WebLink19: TWebLink;
    WebLink16: TWebLink;
    ScrollBox1: TScrollBox;
    WebLink17: TWebLink;
    WebLink20: TWebLink;
    WebLink21: TWebLink;
    WebLink22: TWebLink;
    LoadingSign2: TLoadingSign;
    WebLink23: TWebLink;
    ListView1: TListView;
    WebLink6: TWebLink;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSelectPathToClick(Sender: TObject);
    procedure BtnSelectPathFromClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure PeImportFromPathChange(Sender: TObject);
  private
    { Private declarations }
    FSeries: TSelectDateCollection;
    procedure LoadLanguage;
    procedure ReadOptions;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure SetPath(Path: string);
    procedure AddItem(Item: TPathItem; Date: TDateTime; Size: Int64);
  end;

var
  FormImportImages: TFormImportImages;

procedure GetPhotosFromDevice(DeviceName: string);

{$R PicturesImport.res}

implementation

uses
  uThreadImportPictures,
  uImportScanThread;

procedure GetPhotosFromDevice(DeviceName: string);
var
  FormImportImages: TFormImportImages;
begin
  Application.CreateForm(TFormImportImages, FormImportImages);
  FormImportImages.SetPath(cDevicesPath + '\' + DeviceName);
  FormImportImages.Show;
end;

{ TSelectDateItem }

procedure TSelectDateItem.AddItem(Size: Int64);
begin
  FItemsSize := FItemsSize + Size;
  Inc(FItemsCount);
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

procedure TSelectDateCollection.AddDateInfo(Date: TDateTime; Size: Int64);
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
        TSelectDateItem(SI).AddItem(Size);
        Exit;
      end;
    end;
  end;

  SI := TSelectDateItem.Create;
  TSelectDateItem(SI).Date := Date;
  TSelectDateItem(SI).FItemsCount := 1;
  TSelectDateItem(SI).FItemsSize := Size;
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
  F(FItems);
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

procedure TSelectDateCollection.UpdateModel;
var
  I: Integer;
  Sb: TScrollBox;
  WlLabel, WlDate, WlItemsCount, WlSize: TWebLink;
  SI: TBaseSelectItem;

  function FindChildByTag(Parent: TWinControl; Tag: NativeInt): TControl;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to Parent.ControlCount - 1 do
    begin
      if Parent.Controls[I].Tag = Tag then
      begin
        Result := Parent.Controls[I];
        Exit;
      end;
    end;
  end;

begin
  BeginScreenUpdate(FContainer.Handle);
  try
    for I := 0 to FItems.Count - 1 do
    begin
      SI := FItems[I];
      Sb := DisplayItems[SI];
      if Sb = nil then
      begin
        Sb := TScrollBox.Create(FContainer.Owner);
        Sb.Parent := FContainer;
        Sb.Width := 175;
        Sb.Height := 75;
        Sb.HorzScrollBar.Visible := False;
        Sb.VertScrollBar.Visible := False;
        Sb.BevelKind := bkTile;
        Sb.BorderStyle := bsNone;
        Sb.Top := 3;
        Sb.Tag := NativeInt(FItems[I]);

        WlLabel := TWebLink.Create(FContainer.Owner);
        WlLabel.Parent := Sb;
        WlLabel.Left := 2;
        WlLabel.Top := 6;
        WlLabel.ImageCanRegenerate := True;
        WlLabel.LoadFromResource('SERIES_EDIT');
        WlLabel.Refresh;
        WlLabel.Tag := 1;

        WlDate := TWebLink.Create(FContainer.Owner);
        WlDate.Parent := Sb;
        WlDate.Left := 2;
        WlDate.Top := 28;
        WlDate.ImageCanRegenerate := True;
        WlDate.LoadFromResource('SERIES_DATE');
        WlDate.Refresh;
        WlDate.Tag := 2;

        WlItemsCount := TWebLink.Create(FContainer.Owner);
        WlItemsCount.IconWidth := 0;
        WlItemsCount.IconHeight := 0;
        WlItemsCount.Parent := Sb;
        WlItemsCount.Left := 2;
        WlItemsCount.Top := 50;
        WlItemsCount.ImageCanRegenerate := True;
        WlItemsCount.Tag := 3;

        WlSize := TWebLink.Create(FContainer.Owner);
        WlSize.IconWidth := 0;
        WlSize.IconHeight := 0;
        WlSize.Parent := Sb;
        WlSize.Left := 60;
        WlSize.Top := 50;
        WlSize.ImageCanRegenerate := True;
        WlSize.Tag := 4;
      end;
      Sb.Left := 5 + I * (175 + 5);

      WlLabel := FindChildByTag(Sb, 1) as TWebLink;
      WlLabel.Text := SI.ItemLabel;

      WlDate := FindChildByTag(Sb, 2) as TWebLink;
      if SI is TSelectDateItem then
        WlDate.Text := FormatDateTime('yyyy-mm-dd', TSelectDateItem(SI).Date)
      else
        WlDate.Text := FormatDateTime('yyyy-mm-dd', TSelectDateItems(SI).StartDate) + ' - ' + FormatDateTime('yyyy-mm-dd', TSelectDateItems(SI).EndDate);

      WlItemsCount := FindChildByTag(Sb, 3) as TWebLink;
      WlItemsCount.Text := FormatEx(TA('{0} Files', 'ImportPictures'), [SI.ItemsCount]);

      WlSize := FindChildByTag(Sb, 4) as TWebLink;
      WlSize.Text := SizeInText(SI.ItemsSize);
    end;
  finally
    EndScreenUpdate(FContainer.Handle, True);
  end;
end;

{$R *.dfm}

{ TFormImportImages }

procedure TFormImportImages.AddItem(Item: TPathItem; Date: TDateTime; Size: Int64);
begin
  FSeries.AddDateInfo(Date, Size);
  FSeries.UpdateModel;
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

procedure TFormImportImages.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
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
  F(FSeries);
end;

function TFormImportImages.GetFormID: string;
begin
  Result := 'ImportPictures';
end;

procedure TFormImportImages.LoadLanguage;
begin
  BeginTranslate;
  try
    LbImportFrom.Caption := L('Import from') + ':';
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

end.
