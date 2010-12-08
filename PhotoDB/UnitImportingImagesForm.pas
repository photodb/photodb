unit UnitImportingImagesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, DmProgress, Dolphin_DB, ComCtrls,
  acDlgSelect, ImgList, Registry, UnitUpdateDBObject, UnitDBkernel,
  UnitTimeCounter, uVistaFuncs, UnitDBFileDialogs, UnitDBDeclare,
  UnitDBCommon, UnitDBCommonGraphics, uFileUtils, uGraphicUtils,
  uConstants, uMemory, uDBForm;

type
  TFormImportingImages = class(TDBForm)
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel2: TPanel;
    Label2: TLabel;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Panel3: TPanel;
    Label6: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit3: TEdit;
    Label7: TLabel;
    Button6: TButton;
    DmProgress1: TDmProgress;
    Label8: TLabel;
    Image2: TImage;
    Edit4: TEdit;
    PlacesListView: TListView;
    PlacesImageList: TImageList;
    PopupMenu1: TPopupMenu;
    DeleteItem1: TMenuItem;
    Button7: TButton;
    Image3: TImage;
    Label9: TLabel;
    ComboBox1: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure Button10Click(Sender: TObject);

  private
   FFileName : string;
   SilentClose : boolean;
   Step : integer;
   DBTestOK : boolean;
   UpdateObject : TUpdaterDB;
   FullSize : int64;
   ImageCounter : integer;
   ProcessingSize : int64;
   ImageProcessedCounter : integer;
   TimeCounter: TTimeCounter;
    { Private declarations }
  public
   procedure LoadLanguage;
   procedure Execute(FileName : string);
   procedure AddFolder(NewPlace : string);
   procedure FileFounded(Owner : TObject; FileName : string; Size : int64);
   procedure DirectoryAdded(Sender : TObject);
   procedure SetMaxValue(Value : integer);
   procedure SetPosition(Value : integer);
   procedure OnDone(Sender : TObject);
    { Public declarations }
  end;

const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';

procedure ImportImages(FileName : string);

implementation

{$R *.dfm}

uses Language, UnitUpdateDBThread, UnitHelp;

procedure ImportImages(FileName : string);
var
  FormImportingImages: TFormImportingImages;
begin
 Application.CreateForm(TFormImportingImages, FormImportingImages);
 FormImportingImages.Execute(FileName);
 if Application.MainForm<>FormImportingImages then
 FormImportingImages.Release;
end;

procedure TFormImportingImages.Execute(FileName: string);
begin
 FFileName:=FileName;
 ShowModal;
end;

procedure TFormImportingImages.FormCreate(Sender: TObject);
var
  Reg: TRegIniFile;
begin
 FullSize:=0;
 TimeCounter:= TTimeCounter.Create;
 TimeCounter.TimerInterval:=15000;  // 15 seconds to refresh
 ImageCounter:=0;
 ImageProcessedCounter:=0;
 ProcessingSize:=0;
 Step:=1;
 DBTestOK:=false;

 if DBKernel=nil then
 begin
  KernelHandle := LoadLibrary(PWideChar(ProgramDir+'Kernel.dll'));
  if KernelHandle=0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_ERROR_KERNEL_DLL,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   Halt;
  end;
  DBKernel:=TDBKernel.Create;
 end;
 DBKernel.RegisterChangesID(Self,ChangedDBDataByID);

 PopupMenu1.Images:=DBKernel.ImageList;
 DeleteItem1.ImageIndex:=DB_IC_DELETE_INFO;
 PlacesImageList.BkColor:=PlacesListView.Color;
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);

 AddFolder(Reg.ReadString('Shell Folders', 'My Pictures', ''));

 Reg.Free;
 LoadLanguage;
 PlacesListView.Columns[0].Caption:=TEXT_MES_FOLDERS_TO_ADD;

end;

procedure TFormImportingImages.LoadLanguage;
begin
 Caption:=TEXT_MES_IMPORT_IMAGES_CAPTION;
 Label1.Caption:=TEXT_MES_IMPORTING_IMAGES_INFO;
 Label4.Caption:=TEXT_MES_IMPORTING_IMAGES_FIRST_STEP;
 Button4.Caption:=TEXT_MES_ADD_FOLDER;
 Button3.Caption:=TEXT_MES_CANCEL;
 Button5.Caption:=TEXT_MES_DELETE;
 Button2.Caption:=L('Previous');
 Button1.Caption:=TEXT_MES_NEXT;
 DeleteItem1.Caption:=TEXT_MES_DELETE;
 CheckBox1.Caption:=TEXT_MES_NO_ADD_SMALL_FILES_WITH_WH;
 Label3.Caption:=TEXT_MES_WIDTH;
 Label5.Caption:=TEXT_MES_HEIGHT;
 RadioButton1.Caption:=TEXT_MES_CURRENT_DB_FILE;
 RadioButton2.Caption:=MAKE_MES_NEW_DB_FILE;
 Label7.Caption:=TEXT_MES_DB_FILE+':';

 Label2.Caption:=TEXT_MES_IMPORTING_IMAGES_SECOND_STEP;

 Label6.Caption:=TEXT_MES_IMPORTING_IMAGES_THIRD_STEP;
 Button7.Caption:=TEXT_MES_START_NOW;
 ComboBox1.Clear;
 ComboBox1.Items.Add(TEXT_MES_AKS_ME);
 ComboBox1.Items.Add(TEXT_MES_ADD_ALL);
 ComboBox1.Items.Add(TEXT_MES_SKIP_ALL);
 ComboBox1.Items.Add(TEXT_MES_REPLACE_ALL);
 ComboBox1.ItemIndex:=0;

{ Label9.Caption:=TEXT_MES_IF_CONFLICT_IMPORTING_DO;
 Label10.Caption:=TEXT_MES_CALCULATION_IMAGES;
 Label11.Caption:=Format(TEXT_MES_CURRENT_SIZE_F,[SizeInTextA(FullSize)]);
 Label12.Caption:=Format(TEXT_MES_IMAGES_COUNT_F,[ImageCounter]);
 Button8.Caption:=TEXT_MES_BREAK_BUTTON;
 Button9.Caption:=TEXT_MES_PAUSE;
 Button10.Caption:=TEXT_MES_FINISH;}
end;

procedure TFormImportingImages.Button3Click(Sender: TObject);
begin
 Close;
end;

procedure TFormImportingImages.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if not SilentClose then
 begin
  if ID_OK=MessageBoxDB(Handle,TEXT_MES_DO_YOU_REALLY_WANT_TO_CLOSE_THIS_DIALOG,TEXT_MES_QUESTION,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION) then
  begin
   CanClose:=true;
   if UpdateObject<>nil then
   begin
    UpdateObject.DoTerminate;
    UpdateObject.Free;
   end;
  end else CanClose:=false;
 end;
end;

procedure TFormImportingImages.AddFolder(NewPlace : string);
var
  P: Pointer;
begin
  if DirectoryExists(NewPlace) then
  begin
    AddIconToListFromPath(PlacesImageList, DefaultIcon);
    with PlacesListView.Items.AddItem(nil) do
    begin
      ImageIndex := PlacesImageList.Count - 1;
      Caption := Mince(NewPlace, 30);
      GetMem(P, Length(NewPlace) + 1);
      Lstrcpyn(P, PWideChar(NewPlace), Length(NewPlace) + 1);
      Data := P;
    end;
  end;
end;

procedure TFormImportingImages.Button4Click(Sender: TObject);
var
  NewPlace : String;
begin
 NewPlace:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_NEW_PLACE,Dolphin_DB.UseSimpleSelectFolderDialog);
 AddFolder(NewPlace);
end;

procedure TFormImportingImages.PlacesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  item : TListItem;
begin
 item:=PlacesListView.GetItemAt(MousePos.X,MousePos.Y);
 if item<>nil then
 begin
  PopupMenu1.Tag:=item.Index;
  PopupMenu1.Popup(PlacesListView.ClientToScreen(MousePos).x,PlacesListView.ClientToScreen(MousePos).y);
 end;
end;

procedure TFormImportingImages.Button5Click(Sender: TObject);
var
  i : integer;
begin
 if PopupMenu1.Tag<>-1 then
 if PlacesListView.Selected<>nil then
 PopupMenu1.Tag:=PlacesListView.Selected.Index;

 if PopupMenu1.Tag<>-1 then
 begin
  PlacesImageList.Delete(PopupMenu1.Tag);
  PlacesListView.Items.Delete(PopupMenu1.tag);
  for i:=PopupMenu1.tag to PlacesListView.Items.Count-1 do
  PlacesListView.Items[i].ImageIndex:=PlacesListView.Items[i].ImageIndex-1;
 end;
end;

procedure TFormImportingImages.Button1Click(Sender: TObject);
begin
 if Step=2 then
 begin
  Button7.Visible:=true;
  Button1.Visible:=false;
  Panel2.Visible:=false;
  Panel3.Visible:=true;
  Step:=3;
 end;
 if Step=1 then
 begin
  if PlacesListView.Items.Count=0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_NO_PLACES_TO_IMPORT,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_WARNING);
   exit;
  end;
  Button2.Enabled:=true;
  Panel1.Visible:=false;
  Panel2.Visible:=true;
  Step:=2;
 end;
end;

procedure TFormImportingImages.Button2Click(Sender: TObject);
begin
 if Step=2 then
 begin
  Button2.Enabled:=false;
  Panel1.Visible:=true;
  Panel2.Visible:=false;
  Step:=1;
 end;
 if Step=3 then
 begin
  Panel2.Visible:=true;
  Panel3.Visible:=false;
  Button7.Visible:=false;
  Button1.Visible:=true;
  Step:=2;
 end;
end;

procedure TFormImportingImages.Button6Click(Sender: TObject);
var
  SaveDialog : DBSaveDialog;
  FileName : string;
begin
  SaveDialog:=DBSaveDialog.Create;
  SaveDialog.Filter:='PhotoDB Files (*.photodb)|*.photodb';
  SaveDialog.FilterIndex:=0;

 if SaveDialog.Execute then
 begin
  FileName:=SaveDialog.FileName;
  if not ValidDBPath(FileName) then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_PATH_INVALID,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
   exit;
  end;

  if SaveDialog.GetFilterIndex=2 then
  if GetExt(FileName)<>'DB' then FileName:=FileName+'.db';
  if SaveDialog.GetFilterIndex=1 then
  if GetExt(FileName)<>'PHOTODB' then FileName:=FileName+'.photodb';

  if FileExists(FileName) and (ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_1,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING)) then exit;
  begin
   DbKernel.CreateDBbyName(FileName);
   DBTestOK:=DBKernel.TestDB(FileName);
   Edit3.Text:=FileName;
  end;
 end;
 SaveDialog.Free;
end;

procedure TFormImportingImages.CheckBox1Click(Sender: TObject);
begin
 Edit1.Enabled:=CheckBox1.Checked;
 Edit2.Enabled:=CheckBox1.Checked;
end;

procedure TFormImportingImages.RadioButton2Click(Sender: TObject);
begin
 Edit3.Enabled:=RadioButton2.Checked;
 Button6.Enabled:=RadioButton2.Checked;
end;

procedure TFormImportingImages.Button7Click(Sender: TObject);
begin
 Button3.Enabled:=false;
 Button2.Visible:=false;
 Button7.Visible:=false;
 Button8.Visible:=true;
 Button9.Visible:=true;
// DBKernel.SetGuestModeAccess;

 DBKernel.WriteBool('Options','NoAddSmallImages',CheckBox1.Checked);
 DBKernel.WriteString('Options','NoAddSmallImagesWidth',Edit1.text);
 DBKernel.WriteString('Options','NoAddSmallImagesHeight',Edit2.text);


 UpdateObject := TUpdaterDB.Create(false);

 UpdateObject.OwnerFormSetMaxValue:=SetMaxValue;
 UpdateObject.OwnerFormSetPosition:=SetPosition;
 UpdateObject.OnDirectoryAdded:=DirectoryAdded;
 UpdateObject.SetDone:=OnDone;

 Case ComboBox1.ItemIndex of
  1 : UpdateObject.AutoAnswer:=Result_add_all;
  2 : UpdateObject.AutoAnswer:=Result_skip_all;
  3 : UpdateObject.AutoAnswer:=Result_replace_all;
 end;
 UpdateObject.Auto:=false;
 UpdateObject.AddDirectory(PWideChar(PlacesListView.Items[0].Data),FileFounded);
 Label10.Visible:=true;
 Label11.Visible:=true;
 Label12.Visible:=true;
 Image3.Visible:=true;

end;

procedure TFormImportingImages.FileFounded(Owner: TObject; FileName: string;
  Size: int64);
begin
 FullSize:=FullSize+Size;
 inc(ImageCounter);
 Label11.Caption:=Format(TEXT_MES_CURRENT_SIZE_F,[SizeInTextA(FullSize)]);
 Label12.Caption:=Format(TEXT_MES_IMAGES_COUNT_F,[ImageCounter]);
 Edit4.Text:=FileName;
end;

procedure TFormImportingImages.DirectoryAdded(Sender: TObject);
begin
 PlacesListView.Items[0].Delete;
 if PlacesListView.Items.Count>0 then
 UpdateObject.AddDirectory(PWideChar(PlacesListView.Items[0].Data),FileFounded)
 else begin
  if UpdateObject.GetCount=0 then
  begin
   OnDone(Sender);
   exit;
  end;
  TimeCounter.MaxActions:=FullSize;
  TimeCounter.DoBegin;
  UpdateObject.Execute;
  Label10.Caption:=TEXT_MES_PROCESSING_IMAGES;
 end;
end;

procedure TFormImportingImages.Button8Click(Sender: TObject);
begin
 if UpdateObject<>nil then UpdateObject.DoTerminate;
end;

procedure TFormImportingImages.Button9Click(Sender: TObject);
begin
 if UpdateObject<>nil then
 begin
  if UpdateObject.Pause then
  begin
   UpdateObject.DoUnPause;
   Button9.Caption:=TEXT_MES_PAUSE;
  end else begin
   UpdateObject.DoPause;
   Button9.Caption:=TEXT_MES_UNPAUSE;
  end;
 end;
end;

procedure TFormImportingImages.FormDestroy(Sender: TObject);
begin
 TimeCounter.Free;
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
end;

procedure TFormImportingImages.ChangedDBDataByID(Sender: TObject;
  ID: integer; params: TEventFields; Value: TEventValues);
var
  Bit: TBitmap;
  P: TPoint;
  FileSize: Integer;

  procedure FillRectToBitmapA(var Bitmap: TBitmap);
  begin
    Bitmap.Canvas.Pen.Color := 0;
    Bitmap.Canvas.Brush.Color := MakeDarken(ClWindow, 0.9);
    Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    Bitmap.Canvas.Pen.Color := ClWindow;
 end;

begin
 //TODO: check it!
 if (SetNewIDFileData in params) or (EventID_FileProcessed in params) then
 if UpdateObject.Active then
 begin
  Image3.Visible:=false;
  bit := TBitmap.Create;
  bit.PixelFormat:=pf24bit;
  bit.Assign(Value.JPEGImage);
  bit.Width:=ThSize;
  bit.Height:=ThSize;
  FillRectToBitmapA(bit);
  bit.Canvas.Draw(ThSize div 2-Value.JPEGImage.Width div 2,ThSize div 2-Value.JPEGImage.height div 2,Value.JPEGImage);
  image2.Picture.Graphic:=bit;
  Edit4.Text:=Value.Name;

  inc(ImageProcessedCounter);
  FileSize:=GetFileSizeByName(Value.Name);
  ProcessingSize:=ProcessingSize+FileSize;
  Label11.Caption:=Format(TEXT_MES_PROCESSING_SIZE_F,[SizeInTextA(ProcessingSize),SizeInTextA(FullSize)]);
  Label12.Caption:=Format(TEXT_MES_IMAGES_PROCESSED_COUNT_F,[ImageProcessedCounter,ImageCounter]);

  TimeCounter.NextAction(FileSize);

  Label8.Visible:=true;
  Label8.Caption:=Format(TEXT_MES_TIME_REM_F,[FormatDateTime('hh:mm:ss',TimeCounter.GetTimeRemaining)]);

  exit;
 end;

 if EventID_Param_Add_Crypt_WithoutPass in params then
 begin
  if not CryptFileWithoutPassChecked then
  begin
   DoHelpHint(TEXT_MES_WARNING,TEXT_MES_CRYPT_FILE_WITHOUT_PASS_MOT_ADDED,p,Self);
  end;
 end;
end;

procedure TFormImportingImages.SetMaxValue(Value: integer);
begin
 DmProgress1.MaxValue:=Value;
end;

procedure TFormImportingImages.SetPosition(Value: integer);
begin
 DmProgress1.Position:=Value;
end;

procedure TFormImportingImages.OnDone(Sender: TObject);
begin
 DmProgress1.Position:=DmProgress1.MaxValue;
 Button3.Visible:=false;
 Button8.Visible:=false;
 Button9.Visible:=false;
 Button10.Visible:=true;
 Label8.Visible:=false;
end;

procedure TFormImportingImages.Button10Click(Sender: TObject);
begin
 SilentClose:=true;
 Close;
end;

end.
