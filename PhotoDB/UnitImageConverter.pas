unit UnitImageConverter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ImageConverting, GraphicEx, acDlgSelect, TiffImageUnit,
  ExtCtrls,  JPEG, GIFImage, GraphicCrypt, Language, UnitDBkernel, PngImage,
  RAWImage, uVistaFuncs, UnitDBDeclare, UnitDBFileDialogs;

type
  TFormConvertImages = class(TForm)
    ComboBox2: TComboBox;
    Cancel: TButton;
    Ok: TButton;
    Image1: TImage;
    Label1: TLabel;
    RadioButton1: TRadioButton;
    Label2: TLabel;
    RadioButton2: TRadioButton;
    Button1: TButton;
    CheckBox2: TCheckBox;
    Edit3: TEdit;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure ComboBox2Select(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    { Private declarations }
  public          
  FImageList : TArStrings;
  FIDList : TArInteger;
  procedure GetFileList(ImageList : TArStrings; IDList : TArInteger);
  procedure LoadLanguage;
    { Public declarations }
  end;


Procedure ConvertImages(ImageList : TArStrings; IDList : TArInteger);

implementation

uses UnitJPEGOptions, ProgressActionUnit, UnitConvertImagesThread;

{$R *.dfm}

Procedure ConvertImages(ImageList : TArStrings; IDList : TArInteger);
var
  FormConvertImages: TFormConvertImages;
begin
  Application.CreateForm(TFormConvertImages, FormConvertImages);
  FormConvertImages.GetFileList(ImageList,IDList);
  FormConvertImages.ShowModal;
  FormConvertImages.Release;
  if UseFreeAfterRelease then FormConvertImages.Free;
end;

procedure TFormConvertImages.FormCreate(Sender: TObject);
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
 RadioButton1.Checked:=DBkernel.ReadBool('Resizer','Replace',false);
 RadioButton2.Checked:=DBkernel.ReadBool('Resizer','Make New',true);
 if not DBkernel.UserRights.FileOperationsCritical then
 begin
  RadioButton1.Enabled:=false;
  RadioButton2.Enabled:=false;
  RadioButton2.Checked:=true;
 end;
end;

procedure TFormConvertImages.CancelClick(Sender: TObject);
begin
 Close;
end;

procedure TFormConvertImages.OkClick(Sender: TObject);
var
  Options : TConvertThreadOptions;
begin
 if ComboBox2.ItemIndex<0 then
 begin
  MessageBoxDB(Handle,TEXT_MES_CHOOSE_FORMAT,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
  ComboBox2.SetFocus;
  exit;
 end;

 Options.ImageList:=FImageList;
 Options.IDList:=FIDList;
 Options.ConvertableImageClassIndex:=ComboBox2.ItemIndex;
 Options.EndDirectory:=Edit3.Text;
 Options.UseOtherFolder:=CheckBox2.Checked;
 Options.ReplaceImages:=RadioButton1.Checked;

 TConvertImagesThread.Create(false,self,'',nil,Options);

 Close;
end;

procedure TFormConvertImages.GetFileList(ImageList: TArStrings; IDList : TArInteger);
begin
 FImageList:=ImageList;
 FIDList:=IDList;
end;

procedure TFormConvertImages.ComboBox2Select(Sender: TObject);
begin
 Button1.Enabled:=TJPEGImage=GetGraphicClass(GraphicExtension(GetConvertableImageClasses[ComboBox2.ItemIndex]),true);
end;

procedure TFormConvertImages.Button1Click(Sender: TObject);
begin
 SetJPEGOptions;
end;

procedure TFormConvertImages.LoadLanguage;
begin
 Caption:=TEXT_MES_CONVERT_CAPTION;
 Label1.Caption:=TEXT_MES_CONVERT_IMAGE_INFO;
 Cancel.Caption:=TEXT_MES_CANCEL;
 Ok.Caption:=TEXT_MES_OK;
 label2.Caption:=TEXT_MES_CONVERT_TO;
 Button1.Caption:=TEXT_MES_JPEG_OPTIONS;
 RadioButton1.Caption:=TEXT_MES_REPLACE_IMAGES;
 RadioButton2.Caption:=TEXT_MES_MAKE_NEW_IMAGES;
 CheckBox2.Caption:=TEXT_MES_USE_ANOTHER_FOLDER;
end;

procedure TFormConvertImages.Button5Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_FOR_IMAGES,Dolphin_DB.UseSimpleSelectFolderDialog);
 if DirectoryExists(dir) then
 Edit3.Text:=dir;
end;

procedure TFormConvertImages.CheckBox2Click(Sender: TObject);
begin
 Edit3.Enabled:=CheckBox2.Checked;
 Button5.Enabled:=CheckBox2.Checked;
end;

end.
