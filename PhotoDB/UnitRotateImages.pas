unit UnitRotateImages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Dolphin_DB, ImageConverting, uVistaFuncs,
  JPEG, GIFImage, GraphicEx, Language, UnitDBkernel, GraphicCrypt,
  acDlgSelect, GDIPlusRotate, ExplorerTypes, TiffImageUnit,
  UnitRotatingImagesThread, UnitDBDeclare, UnitDBFileDialogs;

type
  TFormRotateImages = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    ComboBox2: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    RadioButton01: TRadioButton;
    RadioButton03: TRadioButton;
    RadioButton02: TRadioButton;
    GroupBox2: TGroupBox;
    RadioButton001: TRadioButton;
    RadioButton002: TRadioButton;
    Edit3: TEdit;
    CheckBox2: TCheckBox;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ComboBox2Click(Sender: TObject);
  private
    { Private declarations }
  public
    FImageList : TArStrings;
    FIDList, FRotateList : TArInteger;
    FViewer : Boolean;
    procedure GetFileList(ImageList : TArStrings; IDList, RotateList : TArInteger; Viewer : boolean = false);
    procedure LoadLanguage;
    { Public declarations }
  end;

procedure RotateImages(ImageList : TArStrings; IDList, RotateList : TArInteger; BeginRotate : Integer; Viewer : boolean = false);

implementation

{$R *.dfm}

uses UnitJPEGOptions, ProgressActionUnit;

procedure RotateImages(ImageList : TArStrings; IDList, RotateList : TArInteger; BeginRotate : Integer; Viewer : boolean = false);
var
  FormRotateImages: TFormRotateImages;
  i : integer;
  v, RotateWithoutPromt : boolean;
begin
 Application.CreateForm(TFormRotateImages, FormRotateImages);
 FormRotateImages.GetFileList(ImageList,IDList,RotateList, Viewer);
 Case BeginRotate of
   DB_IMAGE_ROTATE_270  : FormRotateImages.RadioButton01.Checked:=true;
   DB_IMAGE_ROTATE_90 : FormRotateImages.RadioButton02.Checked:=true;
   DB_IMAGE_ROTATE_180 : FormRotateImages.RadioButton03.Checked:=true;
 end;
 v:=false;
 for i:=0 to Length(IDList)-1 do
 if IDList[i]=0 then
 begin
  v:=true;
  break;
 end;

 RotateWithoutPromt:=DBKernel.Readbool('Options','RotateWithoutPromt',true);
 if v and not RotateWithoutPromt then FormRotateImages.ShowModal else FormRotateImages.Button2Click(nil);
 FormRotateImages.Release;
end;

procedure TFormRotateImages.Button1Click(Sender: TObject);
begin
 SetJPEGOptions;
end;

procedure TFormRotateImages.FormCreate(Sender: TObject);
var
  Formats : TArGraphicClass;
  i : integer;
  Description, Mask : String;
begin
 LoadLanguage;
 DBkernel.RecreateThemeToForm(Self);
 ComboBox2.Clear;
 Formats:=GetConvertableImageClasses;
 for i:=0 to Length(Formats)-1 do
 begin
  if Formats[i]<>TGIFImage then
  begin
   if Formats[i]<>TiffImageUnit.TTiffGraphic then
   Description:=GraphicEx.FileFormatList.GetDescription(Formats[i]) else
   Description:='Tiff Image';
  end else
  Description:='GIF Image';
  if Formats[i]<>TBitmap then
  Mask:=GraphicFileMask(Formats[i]) else
  Mask:='*.bmp;*.dib';
  ComboBox2.Items.Add(Description+'  ('+Mask+')')
 end;
 ComboBox2.ItemIndex:=DBKernel.ReadInteger('Rotate options','Format',0);
 RadioButton01.Checked:=DBKernel.ReadBool('Rotate options','CCW',true);
 RadioButton02.Checked:=DBKernel.ReadBool('Rotate options','CW',false);
 RadioButton03.Checked:=DBKernel.ReadBool('Rotate options','180',false);
 RadioButton1.Checked:=DBKernel.ReadBool('Rotate options','Original Format',true);
 RadioButton2.Checked:=DBKernel.ReadBool('Rotate options','Convert',false);
 RadioButton001.Checked:=DBKernel.ReadBool('Rotate options','Replace',false);
 RadioButton002.Checked:=DBKernel.ReadBool('Rotate options','New',true);

end;

procedure TFormRotateImages.Button4Click(Sender: TObject);
begin
 DBKernel.WriteInteger('Rotate options','Format',ComboBox2.ItemIndex);
 DBKernel.WriteBool('Rotate options','CCW',RadioButton01.Checked);
 DBKernel.WriteBool('Rotate options','CW',RadioButton02.Checked);
 DBKernel.WriteBool('Rotate options','180',RadioButton03.Checked);
 DBKernel.WriteBool('Rotate options','Original Format',RadioButton1.Checked);
 DBKernel.WriteBool('Rotate options','Convert',RadioButton2.Checked);
 DBKernel.WriteBool('Rotate options','Replace',RadioButton001.Checked);
 DBKernel.WriteBool('Rotate options','New',RadioButton002.Checked);
end;

procedure TFormRotateImages.GetFileList(ImageList: TArStrings;
  IDList, RotateList: TArInteger; Viewer : boolean = false);
begin
 FImageList:=ImageList;
 FIDList:=IDList;
 FRotateList:=RotateList;
 FViewer:=Viewer;
end;

procedure TFormRotateImages.Button3Click(Sender: TObject);
begin
 Close;
end;

procedure TFormRotateImages.Button2Click(Sender: TObject);
var
  Options : TRotatingImagesThreadOptions;
  RotateWithoutPromt, RotateEvenIfFileInDB : boolean;
begin
 if ComboBox2.ItemIndex<0 then
 begin
  MessageBoxDB(Handle,TEXT_MES_CHOOSE_FORMAT,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  ComboBox2.SetFocus;
  exit;
 end;
 RotateWithoutPromt:=DBKernel.Readbool('Options','RotateWithoutPromt',true);
 RotateEvenIfFileInDB:=DBKernel.Readbool('Options','RotateEvenIfFileInDB',true);

 if RotateWithoutPromt then RadioButton001.Checked:=true;
 if RotateEvenIfFileInDB and FViewer then RadioButton001.Checked:=true;

 Options.Files:=FImageList;
 Options.IDs:=FIDList;
 Options.Rotate:=FRotateList;
 Options.RotateWithoutPromt := RotateWithoutPromt;
 Options.RotateEvenIfFileInDB := RotateEvenIfFileInDB;
 Options.TryKeepOriginalFormat:=RadioButton1.Checked;
 Options.FormatIndex:=ComboBox2.ItemIndex;  
 Options.RotateCCW:=RadioButton01.Checked;
 Options.RotateCW:=RadioButton02.Checked;
 Options.Rotate180:=RadioButton03.Checked;
 Options.UseAnotherFolder:=CheckBox2.Checked;
 Options.EndDir:=Edit3.Text;
 Options.IsViewer:=fViewer;
 Options.ReplaceImages:=RadioButton001.Checked;
 TRotatingImagesThread.Create(false, Options);
end;

procedure TFormRotateImages.LoadLanguage;
begin
 Caption:=TEXT_MES_ROTATE_CAPTION;
 Label2.Caption:=TEXT_MES_ROTATE_IMAGE_INFO;
 GroupBox1.Caption:=TEXT_MES_CHANGE_SIZE;
 RadioButton01.Caption:=TEXT_MES_ROTATE_270;
 RadioButton02.Caption:=TEXT_MES_ROTATE_90;
 RadioButton03.Caption:=TEXT_MES_ROTATE_180;
 RadioButton1.Caption:=TEXT_MES_TRY_KEEP_ORIGINAL_FORMAT;
 RadioButton2.Caption:=TEXT_MES_CONVERT_TO;
 Button1.Caption:=TEXT_MES_JPEG_OPTIONS;
 GroupBox2.Caption:=TEXT_MES_FILE_ACTIONS;
 RadioButton001.Caption:=TEXT_MES_REPLACE_IMAGES;
 RadioButton002.Caption:=TEXT_MES_MAKE_NEW_IMAGES;
 Button4.Caption:=TEXT_MES_SAVE_SETTINGS_BY_DEFAULT;
 Button3.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_OK;
 CheckBox2.Caption:=TEXT_MES_USE_ANOTHER_FOLDER;
end;

procedure TFormRotateImages.CheckBox2Click(Sender: TObject);
begin
 Edit3.Enabled:=CheckBox2.Checked;
 Button5.Enabled:=CheckBox2.Checked;
end;

procedure TFormRotateImages.Button5Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_FOR_IMAGES,Dolphin_DB.UseSimpleSelectFolderDialog);
 if DirectoryExists(dir) then
 Edit3.Text:=dir;
end;

procedure TFormRotateImages.ComboBox2Click(Sender: TObject);
begin
 RadioButton2.Checked:=true;
end;

end.
