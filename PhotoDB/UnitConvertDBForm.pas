unit UnitConvertDBForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DmProgress, ComCtrls, Dolphin_DB,
  uConstants, jpeg, Spin, UnitRecreatingThInTable, CommonDBSupport, Menus,
  ExtDlgs, Graphics, UnitPasswordKeeper, UnitDBDeclare, AppEvnts,
  UnitDBCommonGraphics, UnitDBFileDialogs, UnitDBCommon,
  uSplashThread, uDBForm, uMemory, uShellIntegration,
  uDBBaseTypes, uDBTypes;

type
  TFormConvertingDB = class(TDBForm)
    Image1: TImage;
    Label1: TLabel;
    BtnNext: TButton;
    BtnPrev: TButton;
    BtnCancel: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Label3: TLabel;
    Edit1: TEdit;
    Panel3: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Progress: TDmProgress;
    Edit2: TEdit;
    BtnStart: TButton;
    BtnBreak: TButton;
    BtnFinish: TButton;
    Panel2: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    ComboBox1: TComboBox;
    PanelImageSize: TPanel;
    ImagePreview: TImage;
    Label10: TLabel;
    Label12: TLabel;
    ComboBox2: TComboBox;
    Label13: TLabel;
    PopupMenu1: TPopupMenu;
    LoadDifferentImage1: TMenuItem;
    PasswordTimer: TTimer;
    InfoListBox: TListBox;
    TempProgress: TDmProgress;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPrevClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnBreakClick(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure LoadDifferentImage1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PasswordTimerTimer(Sender: TObject);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    { Private declarations }
    FFileName: string;
    Step: Integer;
    SilentClose: Boolean;
    Image: TJpegImage;
    ImageOptions: TImageDBOptions;
    RecordCount: Integer;
    PasswordKeeper: TPasswordKeeper;
    ItemsData: TList;
    Infos: TStrings;
    FInfo: string;
    FProgressEnabled: Boolean;
    Icons: array of TIcon;
    TopRecords: Integer;
    CurrentWideIndex: Integer;
  protected
    function GetFormID : string; override;
  public
   { Public declarations }
    procedure LoadToolBarIcons;
    procedure LoadLanguage;
    procedure Execute(FileName: string);
    procedure DoFormExit(Sender: TObject);
    procedure OnConvertingStructureEnd(Sender: TObject; NewFileName: string);
    procedure WriteLine(Sender: TObject; Line: string; Info: Integer);
    procedure WriteLnLine(Sender: TObject; Line: string; Info: Integer);
    procedure ProgressCallBack(Sender: TObject; var Info: TProgressCallBackInfo);
  end;

procedure ConvertDB(FileName : string);

implementation

uses UnitDBKernel, ConvertDBThreadUnit, uAbout, CMDUnit;

procedure ConvertDB(FileName: string);
var
  FormConvertingDB: TFormConvertingDB;
begin
  Application.CreateForm(TFormConvertingDB, FormConvertingDB);
  try
    FormConvertingDB.Execute(FileName);
  finally
    R(FormConvertingDB);
  end;
end;

{$R *.dfm}

{ TFormConvertingDB }

procedure TFormConvertingDB.Execute(FileName: string);
var
  DBVer: Integer;
begin
  CloseSplashWindow;
  FFileName := FileName;
  RadioButton1.Enabled := False; // TODO: !!! BDEInstalled;
  Edit2.Text := FFileName;
  ImageOptions := CommonDBSupport.GetImageSettingsFromTable(FFileName);
  DBVer := DBKernel.TestDBEx(FFileName);
  RecordCount := CommonDBSupport.GetRecordsCount(FFileName);
  Edit1.Text := DBKernel.StringDBVersion(DBVer);
  ComboBox1Change(Self);
  ShowModal;
end;

procedure TFormConvertingDB.FormCreate(Sender: TObject);
begin
  PasswordKeeper := TPasswordKeeper.Create;
  ImageOptions.Version := 0; // VERSION SETTED AFTER PROCESSING IMAGES
  Image := TJpegImage.Create;
  Image.Assign(ImagePreview.Picture.Graphic);
  Panel2.Visible := False;
  BtnPrev.Enabled := False;
  LoadLanguage;
  Step := 1;
  SilentClose := False;

  CurrentWideIndex := -1;
  FProgressEnabled := true;
  FInfo := '';
  Infos := TStringList.Create;
  InfoListBox.DoubleBuffered := true;
  ItemsData := TList.Create;
  InfoListBox.ItemHeight := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
  InfoListBox.Clear;
  LoadToolBarIcons;
end;

procedure TFormConvertingDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Convert collection');
    Label1.Caption := L('This wizard will help you convert your database from one format to another.');
    Label3.Caption := L('Current collection') + ':';
    RadioButton2.Caption := L('Convert to *.photodb (PhotoDB)');
    BtnCancel.Caption := L('Cancel');
    BtnPrev.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    Label4.Caption := L('Please wait until convertation is in progress. This can take some time to complete...');
    Label6.Caption := L('Current action') + ':';
    BtnStart.Caption := L('Start');
    BtnBreak.Caption := L('Break');
    BtnFinish.Caption := L('Finish');
    Label7.Caption := L('Waiting');
    Label8.Caption := L('You can adjust the size and compression quality of images in the database and other sizes of images');
    Label9.Caption := L('Size') + ':';
    ComboBox1.Items[0] := L('JPEG quality');
    ComboBox1.Items[1] := L('DB Image size');
    ComboBox1.Items[2] := L('Panel preview size');
    ComboBox1.Items[3] := L('Preview');
    ComboBox1.ItemIndex := 1;
    LoadDifferentImage1.Caption := L('Load other image');
  finally
    EndTranslate;
  end;
end;

procedure TFormConvertingDB.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormConvertingDB.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  DialogResult: Integer;
begin
  if not SilentClose then
  begin
    DialogResult := MessageBoxDB(Handle,
      L('Do you really want to close this wizard?'), L('Question'),
      TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);
    CanClose := DialogResult = ID_OK;
  end;
end;

procedure TFormConvertingDB.BtnNextClick(Sender: TObject);
begin
  if Step = 1 then
    if not RadioButton2.Checked then
      Step := 2;

  if Step = 2 then
  begin
    Step := 3;
    Panel2.Visible := False;
    Panel3.Visible := True;
    BtnNext.Visible := False;
    BtnPrev.Enabled := True;
    BtnStart.Visible := True;
  end;

  if Step = 1 then
  begin
    Step := 2;
    Panel1.Visible := False;
    Panel2.Visible := True;
    BtnPrev.Enabled := True;
    BtnStart.Visible := False;
  end;
end;

procedure TFormConvertingDB.BtnPrevClick(Sender: TObject);
begin

  if Step = 2 then
  begin
    Step := 1;
    Panel2.Visible := False;
    Panel1.Visible := true;
    BtnPrev.Enabled := False;
  end;

  if Step = 3 then
  begin
    Step := 2;
    BtnStart.Visible := False;
    BtnNext.Visible := true;
    Panel2.Visible := true;
    Panel3.Visible := False;
  end;

  if Step = 2 then
    if not RadioButton2.Checked then
      BtnPrevClick(Sender);
end;

procedure TFormConvertingDB.BtnStartClick(Sender: TObject);
begin
  if Step = 3 then
  begin
    Step := 4;
    BtnNext.Enabled := False;
    BtnPrev.Enabled := False;
    BtnCancel.Enabled := False;
    BtnStart.Enabled := False;
    BtnBreak.Visible := true;
    TConvertDBThread.Create(Self, FFileName, RadioButton2.Checked,
      ImageOptions);
  end;
end;

procedure TFormConvertingDB.BtnBreakClick(Sender: TObject);
begin
  if ID_YES = MessageBoxDB(Handle, L('Do you really want to cancel current action?'), L('Warning'),
    TD_BUTTON_YESNO, TD_ICON_WARNING) then
  begin
    BreakConverting := true;
    RecreatingThInTableTerminating := true;
    BtnBreak.Enabled := False;
  end;
end;

procedure TFormConvertingDB.DoFormExit(Sender: TObject);
begin
  SilentClose := true;
  BtnBreak.Enabled := False;
  MessageBoxDB(Handle, L('Convertation of the collection is completed!'), L('Information'),
    TD_BUTTON_OK, TD_ICON_INFORMATION);
  BtnFinish.Visible := true;
end;

procedure TFormConvertingDB.OnConvertingStructureEnd(Sender: TObject;
  NewFileName: string);
var
  Options: TRecreatingThInTableOptions;
begin
  Options.WriteLineProc := WriteLine;
  Options.WriteLnLineProc := WriteLnLine;
  Options.OnEndProcedure := DoFormExit;
  Options.FileName := NewFileName;
  Options.GetFilesWithoutPassProc := PasswordKeeper.GetActiveFiles;
  Options.AddCryptFileToListProc := PasswordKeeper.AddCryptFileToListProc;
  Options.GetAvaliableCryptFileList := PasswordKeeper.GetAvaliableCryptFileList;
  Options.OnProgress := ProgressCallBack;
  RecreatingThInTable.Create(Options);
end;

procedure TFormConvertingDB.BtnFinishClick(Sender: TObject);
begin
 Close;
end;

procedure TFormConvertingDB.RadioButton1Click(Sender: TObject);
begin
 //TODO: remove this option
 //MessageBoxDB(Handle,DB_IS_OLD_DB,L('Warning'),TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TFormConvertingDB.ComboBox2Change(Sender: TObject);
var
  Bitmap, Result : TBitmap;
  w, h, Size : integer;
  ImageSize : int64;
  Jpeg : TJpegImage;
begin
{
JPEGCOmpression
ThSize
ThSizePanelPreview
ThHintSize
}
  Jpeg := nil;
  case ComboBox1.ItemIndex of
    0:
      begin
        Size := StrToIntDef(ComboBox2.Text, 150);
        if Size < 1 then
          Size := 1;
        if Size > 100 then
          Size := 100;
        ImageOptions.DBJpegCompressionQuality := Size;
      end;
    1:
      begin
        Size := StrToIntDef(ComboBox2.Text, 150);
        if Size < 50 then
          Size := 50;
        if Size > 1000 then
          Size := 0100;
        ImageOptions.ThSize := Size;
      end;
    2:
      begin
        Size := StrToIntDef(ComboBox2.Text, 150);
        if Size < 50 then
          Size := 50;
        if Size > 1000 then
          Size := 1000;
        ImageOptions.ThSizePanelPreview := Size;
      end;
    3:
      begin
        Size := StrToIntDef(ComboBox2.Text, 150);
        if Size < 50 then
          Size := 50;
        if Size > 1000 then
          Size := 1000;
        ImageOptions.ThHintSize := Size;
      end;
  end;

  ImageSize := CalcJpegResampledSize(Image, ImageOptions.ThSize,
    ImageOptions.DBJpegCompressionQuality, jpeg);

  if (ComboBox1.ItemIndex = 0) or (ComboBox1.ItemIndex = 1) then
  begin
    ImagePreview.Picture.Assign(jpeg);
  end else
  begin
    if ComboBox1.ItemIndex = 2 then
    begin
      CalcJpegResampledSize(Image, ImageOptions.ThSizePanelPreview,
        ImageOptions.DBJpegCompressionQuality, jpeg);
      ImagePreview.Picture.Assign(jpeg);
    end else
    begin
      w := Image.Width;
      h := Image.Height;
      Bitmap := TBitmap.Create;
      Bitmap.Assign(Image);
      ProportionalSize(ImageOptions.ThHintSize, ImageOptions.ThHintSize, w, h);
      Result := TBitmap.Create;
      DoResize(w, h, Bitmap, Result);
      Bitmap.Free;
      ImagePreview.Picture.Assign(Result);
    end;
  end;

  Label10.Caption := Format(L('Image size: %s'), [SizeInText(ImageSize)]);
  Label12.Caption := Format(L('The size of new database (approximately): %s'),
    [SizeInText(RecordCount * ImageSize)]);

  F(Jpeg);
end;

procedure TFormConvertingDB.ComboBox1Change(Sender: TObject);

  procedure FillComboByCompressionRange;
  begin
    ComboBox2.Items.Clear;
    ComboBox2.Items.Add('25');
    ComboBox2.Items.Add('30');
    ComboBox2.Items.Add('40');
    ComboBox2.Items.Add('50');
    ComboBox2.Items.Add('60');
    ComboBox2.Items.Add('75');
    ComboBox2.Items.Add('80');
    ComboBox2.Items.Add('85');
    ComboBox2.Items.Add('90');
    ComboBox2.Items.Add('95');
    ComboBox2.Items.Add('100');
  end;

  procedure FillComboByImageSizeRange;
  begin
    ComboBox2.Items.Clear;
    ComboBox2.Items.Add('50');
    ComboBox2.Items.Add('75');
    ComboBox2.Items.Add('100');
    ComboBox2.Items.Add('150');
    ComboBox2.Items.Add('200');
    ComboBox2.Items.Add('300');
  end;

begin
  Case ComboBox1.ItemIndex of
    0:
      begin
        Label13.Caption := L(
          'Sets the compression quality of images stored in the database. Takes the value 1-100');
        FillComboByCompressionRange;
        ComboBox2.Text := IntToStr(ImageOptions.DBJpegCompressionQuality);
      end;
    1:
      begin
        Label13.Caption := L('Default thumbnail size in database');
        FillComboByImageSizeRange;
        ComboBox2.Text := IntToStr(ImageOptions.ThSize);
      end;
    2:
      begin
        Label13.Caption := L('Size of the images in the panel by default');
        FillComboByImageSizeRange;
        ComboBox2.Text := IntToStr(ImageOptions.ThSizePanelPreview);
      end;
    3:
      begin
        Label13.Caption := L('Image preview size');
        FillComboByImageSizeRange;
        ComboBox2.Text := IntToStr(ImageOptions.ThHintSize);
      end;
  end;
  ComboBox2Change(Sender);
end;

procedure TFormConvertingDB.WriteLine(Sender: TObject; Line: string;
  Info: Integer);
begin
  BeginScreenUpdate(Handle);
  try
    PInteger(ItemsData[0])^ := Info;
    InfoListBox.Items[0] := Line;
  finally
    EndScreenUpdate(Handle, False);
  end;
end;

procedure TFormConvertingDB.WriteLnLine(Sender: TObject; Line: string; Info : integer);
var
  p: PInteger;
begin
  if Info = LINE_INFO_INFO then
  begin
    FInfo := Line;
    exit;
  end;
  LockWindowUpdate(Handle);
  try
    Infos.Insert(0, FInfo);

    GetMem(p, SizeOf(Integer));
    p^ := Info;
    ItemsData.Insert(TopRecords, p);
    InfoListBox.Items.Insert(TopRecords, Line);

    FInfo := '';

  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFormConvertingDB.LoadDifferentImage1Click(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter :=
      L('JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg');
    OpenDialog.FilterIndex := 1;

    if OpenDialog.Execute then
    begin
      Image.LoadFromFile(OpenDialog.FileName);
      ComboBox1Change(Sender);
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TFormConvertingDB.FormDestroy(Sender: TObject);
begin
  F(PasswordKeeper);
  DBKernel.ReadDBOptions;
end;

function TFormConvertingDB.GetFormID: string;
begin
  Result := 'ConvertDB';
end;

procedure TFormConvertingDB.PasswordTimerTimer(Sender: TObject);
var
  PasswordList: TArCardinal;
  i: Integer;
begin
  if PasswordKeeper.Count > 0 then
  begin
    PasswordTimer.Enabled := False;
    PasswordList := PasswordKeeper.GetPasswords;
    for i := 0 to Length(PasswordList) - 1 do
      PasswordKeeper.TryGetPasswordFromUser(PasswordList[i]);

    PasswordTimer.Enabled := true;
  end;
end;

procedure TFormConvertingDB.ProgressCallBack(Sender: TObject;
  var Info: TProgressCallBackInfo);
begin
  if Info.MaxValue <> Progress.MaxValue then
  begin
    Progress.MaxValue := Info.MaxValue;
    TempProgress.MaxValue := Info.MaxValue;
  end;
  Progress.Position := Info.Position;
  TempProgress.Position := Info.Position;
  if Label3.Caption <> Info.Information then
  begin
    Label3.Caption := Info.Information;
    Progress.Text := Info.Information + ' (&%%)';
  end;
end;

procedure TFormConvertingDB.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DoInfoListBoxDrawItem(Control as TListBox, Index, Rect, State, ItemsData,
    Icons, FProgressEnabled, TempProgress, Infos);
end;

procedure TFormConvertingDB.LoadToolBarIcons;
var
  index: Integer;

  procedure AddIcon(name: string);
  begin
    Icons[index] := TIcon.Create;
    Icons[index].Handle := LoadIcon(HInstance, PWideChar(name));
    Inc(index);
  end;

begin
  index := 0;
  SetLength(Icons, 7);
  AddIcon('CMD_OK');
  AddIcon('CMD_ERROR');
  AddIcon('CMD_WARNING');
  AddIcon('CMD_PLUS');
  AddIcon('CMD_PROGRESS');
  AddIcon('CMD_DB');
  AddIcon('ADMINTOOLS');
end;

procedure TFormConvertingDB.ApplicationEvents1Message(var Msg: TagMSG; var Handled: Boolean);
begin
  if Msg.Hwnd = InfoListBox.Handle then
    if Msg.message = 522 then
      Msg.message := 0;
end;

end.
