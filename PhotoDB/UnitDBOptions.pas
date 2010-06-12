unit UnitDBOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, StdCtrls, CommonDBSupport, WebLink, Language,
  UnitDBDeclare, UnitDBFileDialogs, uVistaFuncs, ExtCtrls;

type
  TFormDBOptions = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Edit4: TEdit;
    WebLink1: TWebLink;
    Label7: TLabel;
    Edit5: TEdit;
    Button3: TButton;
    Button4: TButton;
    GroupBoxIcon: TGroupBox;
    Button5: TButton;
    ImageIconPreview: TImage;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WebLink1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private       
   ImageOptions : TImageDBOptions;
   DBFile : TPhotoDBFile;
   fname : String;
    { Private declarations }
  public
   procedure LoadLanguage;
   procedure Execute(Options : TPhotoDBFile);
   procedure ReadSettingsFromDB;
   procedure SetDefaultIcon(path : string = '');
    { Public declarations }
  end;

procedure ChangeDBOptions(Name, FileName : string);  overload;
procedure ChangeDBOptions(Options : TPhotoDBFile);  overload;

implementation

uses UnitConvertDBForm, ExplorerUnit;

{$R *.dfm}

procedure ChangeDBOptions(Name, FileName : string);
var
  FormDBOptions: TFormDBOptions;
  Options : TPhotoDBFile;
begin
  Application.CreateForm(TFormDBOptions, FormDBOptions);
  Options._Name:=Name;
  Options.Icon:='';
  Options.FileName:=FileName;
  Options.aType:=0;
  FormDBOptions.Execute(Options);
  FormDBOptions.Release;
  FormDBOptions.Free;
end;

procedure ChangeDBOptions(Options : TPhotoDBFile);  overload;
var
  FormDBOptions: TFormDBOptions;
begin
  Application.CreateForm(TFormDBOptions, FormDBOptions);
  FormDBOptions.Execute(Options);
  FormDBOptions.Release;
  FormDBOptions.Free;
end;

procedure TFormDBOptions.Execute(Options : TPhotoDBFile);
begin
 fName:=Options._Name;
 DBFile.FileName:=Options.FileName;
 ReadSettingsFromDB;        
 SetDefaultIcon(Options.Icon);    
 GroupBoxIcon.Visible:=true;
 ShowModal;
end;

procedure TFormDBOptions.FormCreate(Sender: TObject);
begin
 DBKernel.RecreateThemeToForm(Self);
 LoadLanguage;          
 DBKernel.RegisterForm(Self);
end;

procedure TFormDBOptions.FormDestroy(Sender: TObject);
begin
 DBKernel.UnRegisterForm(Self);
end;

procedure TFormDBOptions.LoadLanguage;
begin
 Caption:=TEXT_MES_CHANGE_DB_OPTIONS;
 Label1.Caption:=TEXT_MES_DB_NAME;
 Label2.Caption:=TEXT_MES_DB_DESCRIPTION;
 Label7.Caption:=TEXT_MES_DB_PATH;
 Button3.Caption:=TEXT_MES_OPEN_FILE_LOCATION;
 Button4.Caption:=TEXT_MES_CHANGE_FILE_LOCATION;
 Label3.Caption:=TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE_INFO;
 Label4.Caption:=TEXT_MES_CONVERTATION_HINT_SIZE_INFO;
 Label5.Caption:=TEXT_MES_CONVERTATION_TH_SIZE;       
 Label6.Caption:=TEXT_MES_CONVERTATION_JPEG_QUALITY;
 WebLink1.Text:=TEXT_MES_PRESS_THIS_LINK_TO_CONVERT_DB;
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
 GroupBoxIcon.Caption:=TEXT_MES_ICON_OPTIONS;
 Label8.Caption:=TEXT_MES_ICON_PREVIEW;
 Button5.Caption:=TEXT_MES_CHOOSE_ICON;
end;

procedure TFormDBOptions.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TFormDBOptions.WebLink1Click(Sender: TObject);
begin
 ConvertDB(DBFile.FileName);
end;

procedure TFormDBOptions.Button3Click(Sender: TObject);
begin
 With ExplorerManager.NewExplorer do
 begin
  SetOldPath(DBFile.FileName);
  SetPath(GetDirectory(DBFile.FileName));
  Show;
 end; 
end;

procedure TFormDBOptions.Button1Click(Sender: TObject);
var
  Options : TImageDBOptions;
  Value : TEventValues;

  procedure DisableControls;
  begin
   Button1.Enabled:=false;  
   Button2.Enabled:=false; 
   Button3.Enabled:=false;
   Button4.Enabled:=false;
   Button5.Enabled:=false;  
   Edit1.Enabled:=false;
   Edit2.Enabled:=false;
   ComboBox1.Enabled:=false;   
   ComboBox2.Enabled:=false;
   WebLink1.Enabled:=false;
  end;

begin
 DisableControls;
 Options:=CommonDBSupport.GetImageSettingsFromTable(DBFile.FileName);
 Options.Name:=DOlphin_DB.NormalizeDBString(Edit1.Text);
 Options.Description:=DOlphin_DB.NormalizeDBString(Edit2.Text);
 Options.ThSizePanelPreview:=SysUtils.StrToIntDef(ComboBox1.Text,Options.ThSizePanelPreview);
 Options.ThHintSize:=SysUtils.StrToIntDef(ComboBox2.Text,Options.ThHintSize);
 if Options.ThSizePanelPreview<50 then Options.ThSizePanelPreview:=50;
 if Options.ThSizePanelPreview>Options.ThSize then Options.ThSizePanelPreview:=Options.ThSize;

 if Options.ThHintSize<Options.ThSize then Options.ThHintSize:=Options.ThSize;
 if Options.ThHintSize>Screen.Width then Options.ThHintSize:=Screen.Width;

 CommonDBSupport.UpdateImageSettings(DBFile.FileName,Options);
 if FName<>'' then
 begin
  DBkernel.AddDB(FName,DBFile.FileName,DBFile.Icon,true);
 end;
 if AnsiLowerCase(DBName)=AnsiLowerCase(DBFile.FileName) then
 begin
  DBKernel.ReadDBOptions;
  DBKernel.DoIDEvent(Self,0,[EventID_Param_DB_Changed],Value);
 end;
 Close;
end;

procedure TFormDBOptions.Button4Click(Sender: TObject);
var
  DBVersion : integer;
  DialogResult : integer;
  FA : integer;
  OpenDialog : DBOpenDialog;
  FileName : string;
begin         
 OpenDialog := DBOpenDialog.Create;

 if BDEInstalled then
 OpenDialog.Filter:='DataBase Files (*.db;*.mdb;*.photodb)|*.db;*.mdb;*.photodb|Access Files (*.mdb)|*.mdb|BDE Files (*.db)|*.db' else
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
  begin
   if not DBKernel.ValidDBVersion(FileName,DBVersion) then
   begin
    DialogResult:=MessageBoxDB(Handle,TEXT_MES_DB_VERSION_INVALID_CONVERT_AVALIABLE,TEXT_MES_WARNING,TEXT_MES_INVALID_DB_VERSION_INFO,TD_BUTTON_YESNO,TD_ICON_WARNING);
    if ID_YES=DialogResult then
    begin
     ConvertDB(FileName);
    end;
    exit;
   end;
  end;
  Edit5.Text:=FileName;
  Button1.Enabled:=true;
  DBFile.FileName:=FileName;
  if fName<>'' then
  DBKernel.AddDB(fName,DBFile.FileName,DBFile.Icon);
 end;    
 OpenDialog.Free;
end;

procedure TFormDBOptions.ReadSettingsFromDB;
var
  ValidDB : boolean;
begin
 ValidDB:=DBKernel.TestDB(DBFile.FileName);
 if ValidDB then
 begin
  ImageOptions:=CommonDBSupport.GetImageSettingsFromTable(DBFile.FileName);
  Button4.Visible:=false;
  Button3.Visible:=true;
 end else
 begin
  ImageOptions:= CommonDBSupport.GetDefaultImageDBOptions;
  Button4.Visible:=true;
  Button3.Visible:=false;
  Button1.Enabled:=false;
 end;
 Edit3.Text:=IntToStr(ImageOptions.ThSize);
 Edit4.Text:=IntToStr(ImageOptions.DBJpegCompressionQuality);
 ComboBox2.Text:= IntToStr(ImageOptions.ThHintSize);
 ComboBox1.Text:= IntToStr(ImageOptions.ThSizePanelPreview);

 DBFile.Icon:=Application.ExeName+',0';
 if fName='' then
 begin
  DBFile._Name:=TEXT_MES_DB_NAME_PATTERN;
 end else
 begin
  DBFile._Name:=fName;
 end;
 Edit1.Text:=Trim(ImageOptions.Name);
 Edit2.Text:=Trim(ImageOptions.Description);
 Edit5.Text:=DBFile.FileName;

end;

procedure TFormDBOptions.Button5Click(Sender: TObject);
var
  FileName : String;
  IconIndex : integer;
  s,  Icon : String;
  i : Integer;
  ico : TIcon;
begin
 if not Button5.Enabled then exit;
 s:=DBFile.Icon;
 i:=Pos(',',s);
 FileName:=Copy(s,1,i-1);
 Icon:=Copy(s,i+1,Length(s)-i);
 IconIndex:=StrToIntDef(Icon,0);
 ChangeIconDialog(Handle,FileName,IconIndex);
 if FileName<>'' then
 Icon:=FileName+','+IntToStr(IconIndex);
 DBFile.Icon:=Icon;
 ico:=GetSmallIconByPath(Icon);
 ImageIconPreview.Picture.Icon.Assign(ico);
 ImageIconPreview.Refresh;
 ico.free;
end;

procedure TFormDBOptions.SetDefaultIcon(path : string = '');
var
  ico : TIcon;
begin
 if path='' then path:=GetDirectory(GetProgramPath)+'Icons.dll,121';
 DBFile.Icon:=path;
 ico:=GetSmallIconByPath(path);
 ImageIconPreview.Picture.Icon.Assign(ico);
 ImageIconPreview.Refresh;
 ico.free;
end;

end.
