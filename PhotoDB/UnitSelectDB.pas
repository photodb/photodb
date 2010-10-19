unit UnitSelectDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, Dolphin_DB, Language,
  UnitDBDeclare, UnitDBFileDialogs, uVistaFuncs, jpeg, CommonDBSupport,
  UnitDBCommonGraphics, ImgList, ComCtrls, ComboBoxExDB, WebLink,
  UnitDBCommon;

type
  TFormSelectDB = class(TForm)
    Image2: TImage;
    Label1: TLabel;
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
    Edit3: TEdit;
    Label11: TLabel;
    Edit4: TEdit;
    Label14: TLabel;
    ImageIconPreview2: TImage;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    procedure FormDestroy(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
    procedure ComboBoxExDB1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WebLink1Click(Sender: TObject);
    procedure InternalNameEditChange(Sender: TObject);
  private
    { Private declarations }
    ImageOptions: TImageDBOptions;
    FDBFile: TPhotoDBFile;
    Step: Integer;
    Image: TJpegImage;
    FOptions: Integer;
    procedure DoSelectStep(NewStep: Integer);
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

uses UnitConvertDBForm, UnitDBOptions, UnitInstallThread;

{$R *.dfm}

function DoChooseDBFile(Options : Integer = SELECT_DB_OPTION_GET_DB) : TPhotoDBFile;
var
  FormSelectDB: TFormSelectDB;
begin
  Application.CreateForm(TFormSelectDB, FormSelectDB);
  try
    FormSelectDB.SetOptions(Options);
    FormSelectDB.ShowModal;
    Result := FormSelectDB.GetResultDB;
  finally
    FormSelectDB.Release;
  end;
end;

procedure TFormSelectDB.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSelectDB.RadioGroup1Click(Sender: TObject);
begin
 if (RadioGroup1.ItemIndex<>-1) and (Step=0) then
 begin
  NextButton.Enabled:=true;
  Step:=1;
 end;
 FinishButton.Enabled:=(RadioGroup1.ItemIndex=3) or ((RadioGroup1.ItemIndex=2) and (fOptions = SELECT_DB_OPTION_GET_DB));
 NextButton.Enabled:=not FinishButton.Enabled;
end;

procedure TFormSelectDB.FormCreate(Sender: TObject);
begin
  FDBFile := TPhotoDBFile.Create;
  ImageOptions:=CommonDBSupport.GetDefaultImageDBOptions;
  ImageOptions.Version:=0; //VERSION SETTED AFTER PROCESSING IMAGES
  Image:=TJpegImage.Create;
  Image.Assign(ImagePreview.Picture.Graphic);
  SetDefaultIcon;
  ListBox1.ItemIndex:=0;
  Step:=0;
  LoadLanguage;
  DBKernel.RegisterForm(Self);
  RefreshDBList;
end;

procedure TFormSelectDB.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_SELECT_DB_OPTION_STEP1;
 ListBox1.Items[0]:=TEXT_MES_CONVERTATION_JPEG_QUALITY;
 ListBox1.Items[1]:=TEXT_MES_CONVERTATION_TH_SIZE;
 ListBox1.Items[2]:=TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE;
 ListBox1.Items[3]:=TEXT_MES_CONVERTATION_HINT_SIZE;
 ListBox1.ItemIndex:=1;

 Caption:=TEXT_MES_SELECT_DB_CAPTION;
 RadioGroup1.Caption:=TEXT_MES_SELECT_DB_OPTIONS;

 CancelButton.Caption:=TEXT_MES_CANCEL;
 BackButton.Caption:=TEXT_MES_BACK;
 NextButton.Caption:=TEXT_MES_NEXT;
 FinishButton.Caption:=TEXT_MES_FINISH;

 GroupBox1.Caption:=TEXT_MES_DB_NAME_AND_LOCATION;
 Label2.Caption:=TEXT_MES_DB_ENTER_NEW_DB_NAME;
 Label3.Caption:=TEXT_MES_CHOOSE_NEW_DB_PATH;
 Button4.Caption:=TEXT_MES_SELECT_DB_FILE;
 Label4.Caption:=TEXT_MES_ICON_PREVIEW+':';
 Button5.Caption:=TEXT_MES_SELECT_ICON;
 Edit1.Text:= TEXT_MES_DB_NAME_PATTERN;
 Edit2.Text:= TEXT_MES_NO_DB_FILE;
 Label5.Caption:=TEXT_MES_OPTIONS+':';
 Label6.Caption:=TEXT_MES_VALUE+':';

 GroupBox2.Caption:=TEXT_MES_SELECT_DB;
 Label7.Caption:=TEXT_MES_SELECT_DB_FROM_LIST+':';

 CheckBox1.Caption:=TEXT_MES_USE_AS_DEFAULT_DB;
 CheckBox2.Caption:=TEXT_MES_USE_AS_DEFAULT_DB;

 GroupBox3.Caption:=TEXT_MES_SELECT_FILE_ON_HARD_DISK;
 Label9.Caption:=TEXT_MES_FILE_NAME;
 Label11.Caption:=TEXT_MES_DB_TYPE;
 Label14.Caption:=TEXT_MES_ICON_PREVIEW+':';
 Button1.Caption:=TEXT_MES_SELECT_ICON;
 Button2.Caption:=TEXT_MES_CHANGE_DB_OPTIONS;
 Button3.Caption:=TEXT_MES_SELECT_DB_FILE;
 Label15.Caption:=TEXT_MES_DB_DESCRIPTION;

 CheckBox3.Caption:=TEXT_MES_ADD_DEFAULT_GROUPS_TO_DB;

 Label16.Caption:=TEXT_MES_INTERNAL_NAME;

 InternalNameEdit.Text:=DBKernel.NewDBName(TEXT_MES_DB_NAME_PATTERN);

 WebLink1.Text:=TEXT_MES_PRESS_THIS_LINK_TO_CONVERT_DB;
end;

function GetPrevStep(Step : integer) : integer;
begin

 Result:=0;

 if Step=21 then
 Result:=1;

 if Step=22 then
 Result:=1;

 if Step=20 then
 Result:=1;
 if Step=30 then
 Result:=20;
 if Step=40 then
 Result:=30;
end;

procedure TFormSelectDB.DoSelectStep(NewStep : integer);
begin
 if (NewStep=1) then
 begin
  NextButton.Enabled:=true;
  PanelStep10.Visible:=true;
  PanelStep20.Visible:=false;
  PanelStep21.Visible:=false;
  PanelStep22.Visible:=false;
  Step:=1;
  BackButton.Enabled:=false;
  FinishButton.Enabled:=false;
 end;
 if (NewStep=20) then
 begin
  PanelStep10.Visible:=false;
  PanelStep20.Visible:=true;
  PanelStep30.Visible:=false;
  Step:=20;
  BackButton.Enabled:=true;
 end;
 if (NewStep=21) then
 begin
  NextButton.Enabled:=false;
  PanelStep10.Visible:=false;
  PanelStep21.Visible:=true;
  Step:=21;
  BackButton.Enabled:=true;
  FinishButton.Enabled:=true;
  ComboBoxExDB1Change(Self);
 end;
 if (NewStep=22) then
 begin
  NextButton.Enabled:=false;
  PanelStep10.Visible:=false;
  PanelStep22.Visible:=true;
  Step:=22;
  BackButton.Enabled:=true;
  FinishButton.Enabled:=true;
 end;
 if (NewStep=30) then
 begin
  PanelStep20.Visible:=false;
  PanelStep30.Visible:=true;
  PanelStep40.Visible:=false;
  Step:=30;
  BackButton.Enabled:=true;
  FinishButton.Enabled:=false;
 end;
 if (NewStep=40) then
 begin
  PanelStep30.Visible:=false;
  PanelStep40.Visible:=true;
  Step:=40;
  NextButton.Enabled:=false;
  FinishButton.Enabled:=true;
 end;
end;

procedure TFormSelectDB.BackButtonClick(Sender: TObject);
begin
 DoSelectStep(GetPrevStep(Step));
end;

procedure TFormSelectDB.NextButtonClick(Sender: TObject);
begin
 if Step=30 then
 begin
  WriteNewDBOptions;
  DoSelectStep(40);
 end;
 if Step=20 then
 begin
  if Edit2.Text<>TEXT_MES_NO_DB_FILE then
  begin
   FDBFile.FileName:=Edit2.Text;
   FDBFile.Name:=Edit1.Text;
   DoSelectStep(30);
  end else
  begin
   MessageBoxDB(Handle,TEXT_MES_NO_DB_FILE_SELECTED,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   Button4Click(Sender);
  end;
 end;
 if Step=1 then
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
    if fOptions=SELECT_DB_OPTION_GET_DB_OR_EXISTS then
    DoSelectStep(21);
   end;
  end;
 end;
end;

procedure TFormSelectDB.FormDestroy(Sender: TObject);
begin
  DBKernel.UnRegisterForm(Self);
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
  FA : integer;
  FileName : string;
  SaveDialog : DBSaveDialog;
begin
 SaveDialog:=DBSaveDialog.Create;

 SaveDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';

 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;

  if SaveDialog.GetFilterIndex=2 then
  if GetExt(FileName)<>'DB' then FileName:=FileName+'.db';
  if SaveDialog.GetFilterIndex=1 then
  if GetExt(FileName)<>'PHOTODB' then FileName:=FileName+'.photodb';

  if not ValidDBPath(FileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   SaveDialog.Free;
   exit;
  end;
  FA:=FileGetAttr(FileName);
  if FIleExists(FileName) and ((fa and SysUtils.faReadOnly)<>0) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   SaveDialog.Free;
   exit;
  end;
  Edit2.Text:=FileName;
 end;
 SaveDialog.Free;
end;

procedure TFormSelectDB.SetDefaultIcon(path : string = '');
begin
  if Path = '' then
    Path := GetDirectory(GetProgramPath) + 'Icons.dll,121';
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
    Ico.Free;
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
    Label13.Caption:=TEXT_MES_CONVERTATION_JPEG_QUALITY_INFO;
    FillComboByCompressionRange;
    ComboBox2.Text:=IntToStr(ImageOptions.DBJpegCompressionQuality);
   end;
  1:
   begin
    Label13.Caption:=TEXT_MES_CONVERTATION_TH_SIZE_INFO;
    FillComboByImageSizeRange;
    ComboBox2.Text:=IntToStr(ImageOptions.ThSize);
   end;
  2:
   begin
    Label13.Caption:=TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE_INFO;
    FillComboByImageSizeRange;
    ComboBox2.Text:=IntToStr(ImageOptions.ThSizePanelPreview);
   end;
  3:
   begin
    Label13.Caption:=TEXT_MES_CONVERTATION_HINT_SIZE_INFO;
    FillComboByImageSizeRange;
    ComboBox2.Text:=IntToStr(ImageOptions.ThHintSize);
   end;
 end;
 ComboBox2Change(Sender);
end;

procedure TFormSelectDB.ComboBox2Change(Sender: TObject);
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
 Case ListBox1.ItemIndex of
 0:
  begin
   Size:=StrToIntDef(ComboBox2.Text,150);
   if Size<1 then Size:=1;
   if Size>100 then Size:=100;
   ImageOptions.DBJpegCompressionQuality:=Size;
  end;
 1:
  begin
   Size:=StrToIntDef(ComboBox2.Text,150);
   if Size<50 then Size:=50;
   if Size>1000 then Size:=0100;
   ImageOptions.ThSize:=Size;
  end;
 2:
  begin
   Size:=StrToIntDef(ComboBox2.Text,150);
   if Size<50 then Size:=50;
   if Size>1000 then Size:=1000;
   ImageOptions.ThSizePanelPreview:=Size;
  end;
 3:
  begin
   Size:=StrToIntDef(ComboBox2.Text,150);
   if Size<50 then Size:=50;
   if Size>1000 then Size:=1000;
   ImageOptions.ThHintSize:=Size;
  end;
 end;

 ImageSize:=CalcJpegResampledSize(Image, ImageOptions.ThSize, ImageOptions.DBJpegCompressionQuality, Jpeg);
 if (ListBox1.ItemIndex=0) or (ListBox1.ItemIndex=1) then
 begin
  ImagePreview.Picture.Assign(Jpeg);
 end else
 begin
  if ListBox1.ItemIndex = 2 then
  begin
   CalcJpegResampledSize(Image, ImageOptions.ThSizePanelPreview, ImageOptions.DBJpegCompressionQuality, Jpeg);
   ImagePreview.Picture.Assign(Jpeg);
  end else
  begin
   w:=Image.Width;
   h:=Image.Height;
   Bitmap:=TBitmap.Create;
   Bitmap.Assign(Image);
   ProportionalSize(ImageOptions.ThHintSize,ImageOptions.ThHintSize,w,h);
   Result:=TBitmap.Create;
   DoResize(w,h,Bitmap,Result);
   Bitmap.Free;
   ImagePreview.Picture.Assign(Result);
  end;
 end;

 Label10.Caption:=Format(TEXT_MES_IMAGE_SIZE_FORMAT,[Dolphin_DB.SizeInTextA(ImageSize)]);
 Label12.Caption:=Format(TEXT_MES_NEW_DB_SIZE_FORMAT_10000,[Dolphin_DB.SizeInTextA(10000*ImageSize)]);

 Jpeg.free;
end;


procedure TFormSelectDB.WriteNewDBOptions;
begin
 Memo1.Clear;
 Memo1.Lines.Add(TEXT_MES_NEW_DB_WILL_CREATE_WITH_THIS_OPTIONS);
 Memo1.Lines.Add('');
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_NAME_FORMAT,[FDBFile.Name]));
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_PATH_FORMAT,[FDBFile.FileName]));
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_ICON_FORMAT,[FDBFile.Icon]));
 Memo1.Lines.Add('');
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_IMAGE_SIZE_FORMAT,[ImageOptions.ThSize]));
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_IMAGE_QUALITY_FORMAT,[ImageOptions.DBJpegCompressionQuality]));
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_IMAGE_HINT_FORMAT,[ImageOptions.ThHintSize]));
 Memo1.Lines.Add(Format(TEXT_MES_NEW_DB_IMAGE_PANEL_PREVIEW,[ImageOptions.ThSizePanelPreview]));
end;

procedure TFormSelectDB.FinishButtonClick(Sender: TObject);
var
  FileName : string;
  SaveDialog : DBSaveDialog;
  FA : integer;
begin
 if (RadioGroup1.ItemIndex=3) or ((RadioGroup1.ItemIndex=2) and (fOptions = SELECT_DB_OPTION_GET_DB)) then
 begin
  //Sample DB
  SaveDialog:=DBSaveDialog.Create;

  SaveDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';

  if SaveDialog.Execute then
  begin
   FileName:=SaveDialog.FileName;

   if SaveDialog.GetFilterIndex=2 then
   if GetExt(FileName)<>'DB' then FileName:=FileName+'.db';
   if SaveDialog.GetFilterIndex=1 then
   if GetExt(FileName)<>'PHOTODB' then FileName:=FileName+'.photodb';

   if not ValidDBPath(FileName) then
   begin
    MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
    SaveDialog.Free;
    exit;
   end;
   FA:=FileGetAttr(FileName);
   if FileExists(FileName) and ((fa and SysUtils.faReadOnly)<>0) then
   begin
    MessageBoxDB(Handle,TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
    SaveDialog.Free;
    exit;
   end;

   CreateExampleDB(FileName,Application.ExeName+',0',GetDirectory(Application.ExeName));

   FDBFile.Name:=DBkernel.NewDBName(TEXT_MES_DEFAULT_DB_NAME);
   FDBFile.FileName:=FileName;
   FDBFile.Icon:=Application.ExeName+',0';
   DBKernel.AddDB(FDBFile.Name,FDBFile.FileName,FDBFile.Icon);

   MessageBoxDB(Handle,Format(TEXT_MES_DB_CREATED_SUCCESS_F,[FileName]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
   Close;
  end;
 end;

 if Step=40 then
 begin
  DBkernel.CreateDBbyName(FDBFile.FileName);
  CommonDBSupport.ADOCreateSettingsTable(FDBFile.FileName);
  ImageOptions.Description:=Edit5.Text;
  CommonDBSupport.UpdateImageSettings(FDBFile.FileName,ImageOptions);
  if CheckBox3.Checked then
  CreateExampleGroups(FDBFile.FileName,Application.ExeName+',0',GetDirectory(Application.ExeName));
  if CheckBox1.Checked then
  DBkernel.SetDataBase(FDBFile.FileName);
  MessageBoxDB(Handle,Format(TEXT_MES_DB_CREATED_SUCCESS_F,[FDBFile.FileName]),TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
  Close;
  exit;
 end;

 if Step=21 then
 begin
  if DBkernel.TestDB(DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName) then
  begin
   if CheckBox2.Checked then
   DBKernel.SetDataBase(DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName);
   FDBFile:=DBKernel.DBs[ComboBoxExDB1.ItemIndex];
   Close;
   exit;
  end else
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_ERROR_DB_FILE_F,[DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName]),TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
  end;
 end;

 if Step=22 then
 begin
  if DBkernel.TestDB(FDBFile.FileName) then
  begin
   //TODO:
   DBKernel.AddDB(FDBFile.Name,FDBFile.FileName,FDBFile.Icon);
   Close;
   exit;
  end else
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_ERROR_DB_FILE_F,[DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName]),TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
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
  ComboBoxExDB1Change(nil);
end;

procedure TFormSelectDB.ComboBoxExDB1Change(Sender: TObject);
begin
  SelectDBFileNameEdit.Text := DBKernel.DBs[ComboBoxExDB1.ItemIndex].FileName;
end;

procedure TFormSelectDB.Button3Click(Sender: TObject);
var
  DBVersion : integer;
  DialogResult : integer;
  FA : integer;
  OpenDialog : DBOpenDialog;
  FileName : string;
  DBTestOK : boolean;
begin
 OpenDialog := DBOpenDialog.Create;

 OpenDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';

 if FileExists(dbname) then
 OpenDialog.SetFileName(dbname);

 if OpenDialog.Execute then
 begin
  FileName:=OpenDialog.FileName;
  if not ValidDBPath(FileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   OpenDialog.Free;
   exit;
  end;
  FA:=FileGetAttr(FileName);
  if (fa and SysUtils.faReadOnly)<>0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_READ_ONLY_CHANGE_ATTR_NEEDED,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   OpenDialog.Free;
   exit;
  end;

  DBVersion:=DBKernel.TestDBEx(FileName);
  if DBVersion>0 then
  if not DBKernel.ValidDBVersion(FileName,DBVersion) then
  begin
   DialogResult:=MessageBoxDB(Handle,TEXT_MES_DB_VERSION_INVALID_CONVERT_AVALIABLE,TEXT_MES_WARNING,TEXT_MES_INVALID_DB_VERSION_INFO,TD_BUTTON_YESNO,TD_ICON_WARNING);
   if ID_YES=DialogResult then
   begin
    ConvertDB(FileName);
   end;
  end;
  DBTestOK:=DBKernel.TestDB(FileName);
  if DBTestOK then
  begin
   FDBFile.FileName:=FileName;
   Edit3.Text:=FileName;
   Edit4.Text:=DBkernel.StringDBVersion(DBkernel.TestDBEx(FileName));
  end else
  Edit3.Text:=TEXT_MES_NO_DB_FILE;

 end;
 OpenDialog.Free;
end;

procedure TFormSelectDB.Button2Click(Sender: TObject);
begin
 //TODO:
 if DBKernel.ValidDBVersion(FDBFile.FileName,DBKernel.TestDBEx(FDBFile.FileName)) then
  ChangeDBOptions('',FDBFile.FileName) else
 begin
  MessageBoxDB(Handle,TEXT_MES_SELECT_DB_AT_FIRST,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
 end;
end;

procedure TFormSelectDB.WebLink1Click(Sender: TObject);
begin
 if DBKernel.TestDBEx(FDBFile.FileName)>0 then
 begin
  ConvertDB(FDBFile.FileName);
 end else
 begin
  MessageBoxDB(Handle,TEXT_MES_SELECT_DB_AT_FIRST,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
 end;
end;

function TFormSelectDB.GetResultDB: TPhotoDBFile;
begin
 Result:=FDBFile;
end;

procedure TFormSelectDB.SetOptions(Options: Integer);
begin
 RadioGroup1.Items.Clear;
 RadioGroup1.Items.Add(TEXT_MES_SELECT_DB_OPTION_1);
 RadioGroup1.Items.Add(TEXT_MES_SELECT_DB_OPTION_2);

 if SELECT_DB_OPTION_GET_DB_OR_EXISTS=Options then
  RadioGroup1.Items.Add(TEXT_MES_SELECT_DB_OPTION_3);

 RadioGroup1.Items.Add(TEXT_MES_CREATE_EXAMPLE_DB);

 fOptions := Options;
end;

procedure TFormSelectDB.InternalNameEditChange(Sender: TObject);
begin
 FDBFile.Name:=InternalNameEdit.Text;
end;

end.
