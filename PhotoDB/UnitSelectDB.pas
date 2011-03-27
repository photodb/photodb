unit UnitSelectDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, Dolphin_DB, uDBUtils,
  UnitDBDeclare, UnitDBFileDialogs, uConstants, jpeg, CommonDBSupport,
  UnitDBCommonGraphics, ImgList, ComCtrls, ComboBoxExDB, WebLink,
  UnitDBCommon, uShellIntegration, UnitDBKernel, uFIleUtils, uDBForm,
  uMemory;

type
  TFormSelectDB = class(TDBForm)
    Image2: TImage;
    LbStepInfo: TLabel;
    PanelStep10: TPanel;
    NextButton: TButton;
    BackButton: TButton;
    FinishButton: TButton;
    RadioGroup1: TRadioGroup;
    PanelStep20: TPanel;
    GroupBox1: TGroupBox;
    Button5: TButton;
    ImageIconPreview: TImage;
    Label4: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Button4: TButton;
    PanelStep30: TPanel;
    ListBox1: TListBox;
    Label5: TLabel;
    Label6: TLabel;
    CancelButton: TButton;
    PanelImageSize: TPanel;
    ImagePreview: TImage;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    ComboBox2: TComboBox;
    PanelStep40: TPanel;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    PanelStep21: TPanel;
    GroupBox2: TGroupBox;
    ComboBoxExDB1: TComboBoxExDB;
    DBImageList: TImageList;
    Label7: TLabel;
    Label8: TLabel;
    CheckBox2: TCheckBox;
    PanelStep22: TPanel;
    GroupBox3: TGroupBox;
    Label9: TLabel;
    EdFileName: TEdit;
    Label11: TLabel;
    EdDBType: TEdit;
    Label14: TLabel;
    ImageIconPreview2: TImage;
    BtnChooseIcon: TButton;
    BtnChangeDBOptions: TButton;
    BtnSelectFile: TButton;
    SelectDBFileNameEdit: TEdit;
    WebLink1: TWebLink;
    Label15: TLabel;
    Edit5: TEdit;
    CheckBox3: TCheckBox;
    Label16: TLabel;
    InternalNameEdit: TEdit;
    procedure CancelButtonClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
    procedure ComboBoxExDB1Change(Sender: TObject);
    procedure BtnSelectFileClick(Sender: TObject);
    procedure BtnChangeDBOptionsClick(Sender: TObject);
    procedure WebLink1Click(Sender: TObject);
    procedure InternalNameEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ImageOptions: TImageDBOptions;
    FDBFile: TPhotoDBFile;
    Step: Integer;
    Image: TJpegImage;
    FOptions: Integer;
    procedure DoSelectStep(NewStep: Integer);
  protected
    { Protected declarations }
    function GetFormID : string; override;
    function LReadOnly : string;
  public
    { Public declarations }
    procedure LoadLanguage;
    procedure SetDefaultIcon(Path: string = '');
    procedure WriteNewDBOptions;
    procedure RefreshDBList;
    procedure SetOptions(Options: Integer);
    function GetResultDB: TPhotoDBFile;
    procedure SetIconImage(Icon: string);
  end;

const
  SELECT_DB_OPTION_NONE = 0;
  SELECT_DB_OPTION_GET_DB = 1;
  SELECT_DB_OPTION_GET_DB_OR_EXISTS = 2;

function DoChooseDBFile(Options : Integer = SELECT_DB_OPTION_GET_DB) : TPhotoDBFile;

implementation

uses UnitConvertDBForm, UnitDBOptions;

{$R *.dfm}

function DoChooseDBFile(Options: Integer = SELECT_DB_OPTION_GET_DB)
  : TPhotoDBFile;
var
  FormSelectDB: TFormSelectDB;
begin
  Application.CreateForm(TFormSelectDB, FormSelectDB);
  try
    FormSelectDB.SetOptions(Options);
    FormSelectDB.ShowModal;
    Result := FormSelectDB.GetResultDB;
  finally
    R(FormSelectDB);
  end;
end;

procedure TFormSelectDB.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSelectDB.RadioGroup1Click(Sender: TObject);
begin
  if (RadioGroup1.ItemIndex <> -1) and (Step = 0) then
  begin
    NextButton.Enabled := true;
    Step := 1;
  end;
  FinishButton.Enabled := (RadioGroup1.ItemIndex = 3) or
    ((RadioGroup1.ItemIndex = 2) and
      (FOptions = SELECT_DB_OPTION_GET_DB));
  NextButton.Enabled := not FinishButton.Enabled;
end;

procedure TFormSelectDB.FormCreate(Sender: TObject);
begin
  FDBFile := TPhotoDBFile.Create;
  ImageOptions := CommonDBSupport.GetDefaultImageDBOptions;
  ImageOptions.Version := 0; // VERSION SETTED AFTER PROCESSING IMAGES
  Image := TJpegImage.Create;
  Image.Assign(ImagePreview.Picture.Graphic);
  SetDefaultIcon;
  ListBox1.ItemIndex := 0;
  Step := 0;
  LoadLanguage;
  RefreshDBList;
end;

procedure TFormSelectDB.FormDestroy(Sender: TObject);
begin
  F(FDBFile);
  F(Image);
end;

procedure TFormSelectDB.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Choose\create\edit collection wizard');
    LbStepInfo.Caption := L('Choose an action from the list and click "Next" button');
    ListBox1.Items[0] := L('JPEG quality');
    ListBox1.Items[1] := L('DB Image size');
    ListBox1.Items[2] := L('Panel preview size');
    ListBox1.Items[3] := L('Image preview size');
    ListBox1.ItemIndex := 1;
    RadioGroup1.Caption := L('Select an action') + ':';
    CancelButton.Caption := L('Cancel');
    BackButton.Caption := L('Back');
    NextButton.Caption := L('Next');
    FinishButton.Caption := L('Finish');
    GroupBox1.Caption := L('File name and location');
    Label2.Caption := L('Select name for new collection') + ':';
    Label3.Caption := L('Choose file for new collection') + ':';
    Button4.Caption := L('Select file');
    Label4.Caption := L('Icon preview') + ':';
    Button5.Caption := L('Choose icon');
    Edit1.Text := L('New collection');
    Edit2.Text := L('No file');
    Label5.Caption := L('Options') + ':';
    Label6.Caption := L('Value') + ':';
    GroupBox2.Caption := L('Select collection');
    Label7.Caption := L('Select collection from list') + ':';
    CheckBox1.Caption := L('Use as default collection');
    CheckBox2.Caption := L('Use as default collection');
    GroupBox3.Caption := L('Select an file');
    Label8.Caption := L('File name') + ':';
    Label9.Caption := L('File name') + ':';
    Label11.Caption := L('DB Type') + ':';
    Label14.Caption := L('Icon preview') + ':';
    BtnChooseIcon.Caption := L('Choose icon');
    BtnChangeDBOptions.Caption := L('Change Collection Settings');
    BtnSelectFile.Caption := L('Select file');
    Label15.Caption := L('Description');
    CheckBox3.Caption := L('Add standard groups');
    Label16.Caption := L('Display name');
    InternalNameEdit.Text := DBKernel.NewDBName(L('New collection'));
    WebLink1.Text := L('Press this link to change the size and quality of previews using convertation wizard');
  finally
    EndTranslate;
  end;
end;

function TFormSelectDB.LReadOnly: string;
begin
  Result := L('Database file marked as "Read only"! Please, reset this attribute and try again!');
end;

function GetPrevStep(Step : integer) : integer;
begin
  Result := 0;
  if Step = 21 then
    Result := 1;
  if Step = 22 then
    Result := 1;
  if Step = 20 then
    Result := 1;
  if Step = 30 then
    Result := 20;
  if Step = 40 then
    Result := 30;
end;

procedure TFormSelectDB.DoSelectStep(NewStep : integer);
begin
  if (NewStep = 1) then
  begin
    NextButton.Enabled := true;
    PanelStep10.Visible := true;
    PanelStep20.Visible := false;
    PanelStep21.Visible := false;
    PanelStep22.Visible := false;
    Step := 1;
    BackButton.Enabled := false;
    FinishButton.Enabled := false;
  end;
  if (NewStep = 20) then
  begin
    PanelStep10.Visible := false;
    PanelStep20.Visible := true;
    PanelStep30.Visible := false;
    Step := 20;
    BackButton.Enabled := true;
  end;
  if (NewStep = 21) then
  begin
    NextButton.Enabled := false;
    PanelStep10.Visible := false;
    PanelStep21.Visible := true;
    Step := 21;
    BackButton.Enabled := true;
    FinishButton.Enabled := true;
    ComboBoxExDB1Change(Self);
  end;
  if (NewStep = 22) then
  begin
    NextButton.Enabled := false;
    PanelStep10.Visible := false;
    PanelStep22.Visible := true;
    Step := 22;
    BackButton.Enabled := true;
    FinishButton.Enabled := true;
  end;
  if (NewStep = 30) then
  begin
    PanelStep20.Visible := false;
    PanelStep30.Visible := true;
    PanelStep40.Visible := false;
    Step := 30;
    BackButton.Enabled := true;
    FinishButton.Enabled := false;
  end;
  if (NewStep = 40) then
  begin
    PanelStep30.Visible := false;
    PanelStep40.Visible := true;
    Step := 40;
    NextButton.Enabled := false;
    FinishButton.Enabled := true;
  end;
end;

procedure TFormSelectDB.BackButtonClick(Sender: TObject);
begin
  DoSelectStep(GetPrevStep(Step));
end;

procedure TFormSelectDB.NextButtonClick(Sender: TObject);
begin
  if Step = 30 then
  begin
    WriteNewDBOptions;
    DoSelectStep(40);
  end;
  if Step = 20 then
  begin
    if Edit2.Text <> L('No file') then
    begin
      FDBFile.FileName := Edit2.Text;
      FDBFile.Name := Edit1.Text;
      DoSelectStep(30);
    end else
    begin
      MessageBoxDB(Handle, L(
          'File isn''t selected! Please, select an file and try again.'),
        L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
      Button4Click(Sender);
    end;
  end;
  if Step = 1 then
  begin
    Case RadioGroup1.ItemIndex of
      0:
        begin
          DoSelectStep(20);
        end;
      1:
        begin
          DoSelectStep(22);
        end;
      2:
        begin
          if FOptions = SELECT_DB_OPTION_GET_DB_OR_EXISTS then
            DoSelectStep(21);
        end;
    end;
  end;
end;

procedure TFormSelectDB.Button5Click(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: Integer;
begin
  S := FDBFile.Icon;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    Icon := FileName + ',' + IntToStr(IconIndex);
  FDBFile.Icon := Icon;
  SetIconImage(Icon);
end;

procedure TFormSelectDB.Button4Click(Sender: TObject);
var
  FA: Integer;
  FileName: string;
  SaveDialog: DBSaveDialog;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;

      if SaveDialog.GetFilterIndex = 2 then
        if GetExt(FileName) <> 'DB' then
          FileName := FileName + '.db';
      if SaveDialog.GetFilterIndex = 1 then
        if GetExt(FileName) <> 'PHOTODB' then
          FileName := FileName + '.photodb';

      FA := FileGetAttr(FileName);
      if FileExistsSafe(FileName) and ((FA and SysUtils.faReadOnly) <> 0) then
      begin
        MessageBoxDB(Handle, LReadOnly, L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        Exit;
      end;
      Edit2.Text := FileName;
    end;

  finally
    F(SaveDialog);
  end;
end;

procedure TFormSelectDB.SetDefaultIcon(path : string = '');
begin
  //TODO: Check
  if Path = '' then
    Path := Application.ExeName + ',1';
  FDBFile.Icon := Path;
  SetIconImage(Path);
end;

procedure TFormSelectDB.SetIconImage(Icon: string);
var
  Ico: TIcon;
begin
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(Icon);
    ImageIconPreview.Picture.Graphic := Ico;
    ImageIconPreview2.Picture.Graphic := Ico;
    ImageIconPreview.Refresh;
    ImageIconPreview2.Refresh;
  finally
    F(Ico);
  end;
end;

procedure TFormSelectDB.ListBox1Click(Sender: TObject);

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
  Case ListBox1.ItemIndex of
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

procedure TFormSelectDB.ComboBox2Change(Sender: TObject);
var
  Bitmap, Result: TBitmap;
  W, H, Size: Integer;
  ImageSize: Int64;
  jpeg: TJpegImage;
begin
  {
    JPEGCOmpression
    ThSize
    ThSizePanelPreview
    ThHintSize
  }
  jpeg := nil;
  case ListBox1.ItemIndex of
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
  if (ListBox1.ItemIndex = 0) or (ListBox1.ItemIndex = 1) then
  begin
    ImagePreview.Picture.Assign(jpeg);
  end else
  begin
    if ListBox1.ItemIndex = 2 then
    begin
      CalcJpegResampledSize(Image, ImageOptions.ThSizePanelPreview,
        ImageOptions.DBJpegCompressionQuality, jpeg);
      ImagePreview.Picture.Assign(jpeg);
    end else
    begin
      W := Image.Width;
      H := Image.Height;
      Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(Image);
        ProportionalSize(ImageOptions.ThHintSize, ImageOptions.ThHintSize, W, H);
        Result := TBitmap.Create;
        DoResize(W, H, Bitmap, Result);
      finally
        F(Bitmap);
      end;
      ImagePreview.Picture.Assign(Result);
    end;
  end;

  Label10.Caption := Format(L('Image size: %s'), [SizeInText(ImageSize)]);
  Label12.Caption := Format(L('The size of the new database (approximately for 10,000 records): %s'),
    [SizeInText(10000 * ImageSize)]);

  F(jpeg);
end;

procedure TFormSelectDB.WriteNewDBOptions;
begin
  Memo1.Clear;
  Memo1.Lines.Add(L('The new collection will be created with the following settings:')+#13#13);
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format(L('Collection name: "%s"'), [FDBFile.Name]));
  Memo1.Lines.Add(Format(L('Path to collection: "%s"'), [FDBFile.FileName]));
  Memo1.Lines.Add(Format(L('Path to icon: "%s"'), [FDBFile.Icon]));
  Memo1.Lines.Add('');
  Memo1.Lines.Add(Format(L('Size of collection previews: %dpx'),
      [ImageOptions.ThSize]));
  Memo1.Lines.Add(Format(L('Quality of images: %dpx'),
      [ImageOptions.DBJpegCompressionQuality]));
  Memo1.Lines.Add(Format(L('Preview size: %dpx'),
      [ImageOptions.ThHintSize]));
  Memo1.Lines.Add(Format(L('Small preview size: %dpx'),
      [ImageOptions.ThSizePanelPreview]));
end;

procedure TFormSelectDB.FinishButtonClick(Sender: TObject);
var
  FileName : string;
  SaveDialog : DBSaveDialog;
  FA : integer;

  function InvalidDBFileMessage : string;
  begin
    Result := L('Invalid or missing file $nl$"%s"! $nl$Check for a file or try to add it through the database manager - perhaps the file was created in an earlier version of the program and must be converted to the current version');
  end;

begin
  if (RadioGroup1.ItemIndex = 3) or ((RadioGroup1.ItemIndex = 2) and
      (FOptions = SELECT_DB_OPTION_GET_DB)) then
  begin
    // Sample DB
    SaveDialog := DBSaveDialog.Create;
    try
      SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');
      if SaveDialog.Execute then
      begin
        FileName := SaveDialog.FileName;

        if SaveDialog.GetFilterIndex = 2 then
          if GetExt(FileName) <> 'DB' then
            FileName := FileName + '.db';
        if SaveDialog.GetFilterIndex = 1 then
          if GetExt(FileName) <> 'PHOTODB' then
            FileName := FileName + '.photodb';

        FA := FileGetAttr(FileName);
        if FileExistsSafe(FileName) and ((FA and SysUtils.faReadOnly) <> 0) then
        begin
          MessageBoxDB(Handle, LReadOnly, L('Warning'), TD_BUTTON_OK,
            TD_ICON_WARNING);
          Exit;
        end;

        CreateExampleDB(FileName, Application.ExeName + ',0',
          ExtractFileDir(Application.ExeName));

        FDBFile.Name := DBKernel.NewDBName(L('My collection'));
        FDBFile.FileName := FileName;
        FDBFile.Icon := Application.ExeName + ',0';
        DBKernel.AddDB(FDBFile.Name, FDBFile.FileName, FDBFile.Icon);

        MessageBoxDB(Handle, Format(L('Collection "%s" succesfully created!'),
            [FileName]), L('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
        Close;
      end;
    finally
      F(SaveDialog);
    end;
  end;

  if Step = 40 then
  begin
    DBKernel.CreateDBbyName(FDBFile.FileName);
    CommonDBSupport.ADOCreateSettingsTable(FDBFile.FileName);
    ImageOptions.Description := Edit5.Text;
    CommonDBSupport.UpdateImageSettings(FDBFile.FileName, ImageOptions);
    if CheckBox3.Checked then
      CreateExampleGroups(FDBFile.FileName, Application.ExeName + ',0',
        ExtractFileDir(Application.ExeName));
    if CheckBox1.Checked then
      DBKernel.SetDataBase(FDBFile.FileName);
    MessageBoxDB(Handle, Format(L('Collection "%s" succesfully created!'),
        [FDBFile.FileName]), L('Information'), TD_BUTTON_OK,
      TD_ICON_INFORMATION);
    Close;
    Exit;
  end;

  if Step = 21 then
  begin
    if DBKernel.TestDB(DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName) then
    begin
      if CheckBox2.Checked then
        DBKernel.SetDataBase(DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName);
      FDBFile := DBKernel.DBs[ComboBoxExDB1.ItemIndex];
      Close;
      Exit;
    end else
    begin
      MessageBoxDB(Handle, Format(InvalidDBFileMessage,
          [DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName]), L('Error'),
        TD_BUTTON_OK, TD_ICON_ERROR);
    end;
  end;

  if Step = 22 then
  begin
    if DBKernel.TestDB(FDBFile.FileName) then
    begin
      // TODO:
      DBKernel.AddDB(FDBFile.Name, FDBFile.FileName, FDBFile.Icon);
      Close;
      Exit;
    end else
    begin
      MessageBoxDB(Handle, Format(InvalidDBFileMessage,
          [DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName]), L('Error'),
        TD_BUTTON_OK, TD_ICON_ERROR);
    end;
  end;
end;

procedure TFormSelectDB.RefreshDBList;
var
  I: Integer;
  Ico: TIcon;
begin
  ComboBoxExDB1.Clear;
  DBImageList.Clear;
  DBImageList.BkColor := clWindow;

  for I := 0 to DBKernel.DBs.Count - 1 do
  begin
    with ComboBoxExDB1.ItemsEx.Add do
    begin
      Caption := DBKernel.DBs[I].name;
      ImageIndex := I + 1;
    end;
    Ico := TIcon.Create;
    try
      Ico.Handle := ExtractSmallIconByPath(DBKernel.DBs[I].Icon);
      if Ico.Empty then
        Ico.Handle := ExtractSmallIconByPath(Application.ExeName + ',0');

      DBImageList.AddIcon(Ico);
    finally
      Ico.Free;
    end;
  end;

  ComboBoxExDB1.ItemIndex := 0;
  ComboBoxExDB1Change(Self);
end;

procedure TFormSelectDB.ComboBoxExDB1Change(Sender: TObject);
begin
  if ComboBoxExDB1.Items.Count > 0 then
    SelectDBFileNameEdit.Text := DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName;
end;

procedure TFormSelectDB.BtnSelectFileClick(Sender: TObject);
var
  DBVersion : Integer;
  DialogResult : Integer;
  FA : Integer;
  OpenDialog : DBOpenDialog;
  FileName : string;
  DBTestOK : boolean;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');

    if FileExistsSafe(dbname) then
      OpenDialog.SetFileName(dbname);

    if OpenDialog.Execute then
    begin
      FileName := OpenDialog.FileName;

      FA := FileGetAttr(FileName);
      if (FA and SysUtils.faReadOnly) <> 0 then
      begin
        MessageBoxDB(Handle, LReadOnly, L('Warning'), TD_BUTTON_OK,
          TD_ICON_WARNING);
        Exit;
      end;

      DBVersion := DBKernel.TestDBEx(FileName);
      if DBVersion > 0 then
        if not DBKernel.ValidDBVersion(FileName, DBVersion) then
        begin
          DialogResult := MessageBoxDB(Handle,
            'This database may not be used without conversion, ie it is designed to work with older versions of the program. Run the wizard to convert database?', L('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING);
          if ID_YES = DialogResult then
            ConvertDB(FileName);

        end;
      DBTestOK := DBKernel.TestDB(FileName);
      if DBTestOK then
      begin
        FDBFile.FileName := FileName;
        EdFileName.Text := FileName;
        EdDBType.Text := DBKernel.StringDBVersion(DBKernel.TestDBEx(FileName));
      end else
        EdFileName.Text := L('No file');

    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TFormSelectDB.BtnChangeDBOptionsClick(Sender: TObject);
begin
  if DBKernel.ValidDBVersion(FDBFile.FileName,
    DBKernel.TestDBEx(FDBFile.FileName)) then
    ChangeDBOptions('', FDBFile.FileName)
  else
  begin
    MessageBoxDB(Handle, L('Please select any collection at first!'), L('Warning'),
      TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

procedure TFormSelectDB.WebLink1Click(Sender: TObject);
begin
  if DBKernel.TestDBEx(FDBFile.FileName) > 0 then
  begin
    ConvertDB(FDBFile.FileName);
  end else
  begin
    MessageBoxDB(Handle, L('Please select any collection at first!'), L('Warning'),
      TD_BUTTON_OK, TD_ICON_WARNING);
  end;
end;

function TFormSelectDB.GetFormID: string;
begin
  Result := 'SelectDB';
end;

function TFormSelectDB.GetResultDB: TPhotoDBFile;
begin
  Result := TPhotoDBFile.Create;
  Result.Name := FDBFile.Name;
  Result.Icon := FDBFile.Icon;
  Result.FileName := FDBFile.FileName;
  Result.FileType := FDBFile.FileType;
end;

procedure TFormSelectDB.SetOptions(Options: Integer);
begin
  RadioGroup1.Items.Clear;
  RadioGroup1.Items.Add(L('Create new collection'));
  RadioGroup1.Items.Add(L('Select existing collection from hard disk'));
  if SELECT_DB_OPTION_GET_DB_OR_EXISTS = Options then
    RadioGroup1.Items.Add(L('Use other registered collection'));
  RadioGroup1.Items.Add(L('Create standard collection*'));
  FOptions := Options;
end;

procedure TFormSelectDB.InternalNameEditChange(Sender: TObject);
begin
  FDBFile.Name := InternalNameEdit.Text;
end;

end.
