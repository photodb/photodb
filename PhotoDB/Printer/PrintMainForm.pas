unit PrintMainForm;

interface

{$DEFINE PHOTODB}
{$DEFINE WORK}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, StdCtrls, ExtCtrls, ComCtrls, jpeg,
  ScrollingImage, printers, ScrollingImageAddons, ImgList, Math, UnitPrinterTypes,
  WebLink, SaveWindowPos, ExtDlgs, Language, UnitDBFileDialogs,
  {$IFDEF PHOTODB}
    Dolphin_DB, GraphicCrypt, uVistaFuncs, UnitCDMappingSupport, uConstants,
  {$ENDIF}
   Menus ;

type
  TPrintForm = class(TForm)
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    PageSetupDialog1: TPageSetupDialog;
    ToolsPanel: TPanel;
    BottomPanel: TPanel;
    OkButtonPanel: TPanel;
    Button3: TButton;
    Button4: TButton;
    ListView1: TListView;
    RightPanel: TPanel;
    BaseImage: TImage;
    ImageList1: TImageList;
    FastScrollingImage1: TFastScrollingImage;
    Panel1: TPanel;
    ScrollingImageNavigator1: TScrollingImageNavigator;
    ZoomInLink: TWebLink;
    ZoomOutLink: TWebLink;
    FullSizeLink: TWebLink;
    FitToSizeLink: TWebLink;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    Edit1: TEdit;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    CheckBox2: TCheckBox;
    RadioGroup1: TRadioGroup;
    TerminateTimes: TTimer;
    SaveWindowPos1: TSaveWindowPos;
    PopupMenu1: TPopupMenu;
    CopyToFile1: TMenuItem;
    Image1: TImage;
    Label5: TLabel;
    WebLink1: TWebLink;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DoGenerateSample;
    procedure AddSampleImage(SampleImageType : TPrintSampleSizeOne);
    procedure ListView1DblClick(Sender: TObject);
    procedure SetPreviewImage(Bitmap : TBitmap; SID : String);
    procedure ListView1Resize(Sender: TObject);
    procedure FullSizeLinkClick(Sender: TObject);
    procedure ZoomOutLinkClick(Sender: TObject);
    procedure ZoomInLinkClick(Sender: TObject);
    procedure FitToSizeLinkClick(Sender: TObject);
    procedure ToolsPanelResize(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TerminateTimesTimer(Sender: TObject);
    function GetSampleType : TPrintSampleSizeOne;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure CopyToFile1Click(Sender: TObject);
    procedure LoadLanguage;
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboBox2KeyPress(Sender: TObject; var Key: Char);
    function SizeToPixels(Pixels: TXSize): TXSize;
    function PixelsToSize(Pixels: TXSize): TXSize;
    procedure Edit1Exit(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FastScrollingImage1Resize(Sender: TObject);
  private
    { Private declarations }
    PreviewSID: string;
    FFiles: TStrings;
    CountPerPage: Integer;
    Pages: Integer;
    FCurrentFormat: TPrintSampleSizeOne;
    VirtualBitmap: TBitmap;
  public
    { Public declarations }
    FStatusProgress: TProgressBar;
    procedure Execute(PrintFiles: TStrings); overload;
    procedure Execute(VirtualFile: TBitmap); overload;
  end;

var PrintFormExists : boolean;
    Printing : boolean;

function GetPrintForm(Files : TStrings) : TPrintForm; overload;
function GetPrintForm(Picture : TBitmap) : TPrintForm; overload;

implementation

uses UnitGeneratorPrinterPreview, PrinterProgress, UnitJPEGOptions;

{$R *.dfm}


function GetPrintForm(Files : TStrings) : TPrintForm;
var
  form : TCustomForm;
  Handle : THandle;
  i : integer;
begin
 form:=nil;
 try
  Application.CreateForm(TPrintForm,Result);
  for i:=0 to Files.Count-1 do
  Files[i]:=ProcessPath(Files[i]);
  Result.Execute(Files);
 except
  on e : Exception do
  begin
   form:=Screen.ActiveForm;
   if form=nil then form:=Application.MainForm;
   Handle:=0;
   if form<>nil then Handle:=form.Handle;
   MessageBoxDB(Handle,Format(TEXT_MES_PRINT_ERROR_F,[e.Message]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
 end;
end;

function GetPrintForm(Picture : TBitmap) : TPrintForm;
begin
 if Picture.Empty then exit;
 Application.CreateForm(TPrintForm,Result);
 Result.Execute(Picture);
end;

procedure TPrintForm.AddSampleImage(SampleImageType: TPrintSampleSizeOne);
var
  NewImage: TBitmap;
  SampleImage: TBitmap;
  Item: TListItem;
  Options: TGenerateImageOptions;
begin
  ImageList1.Width := ListView1.Width - 50;
  ImageList1.Height := Round(ImageList1.Width * Printer.PageHeight / Printer.PageWidth);
  SampleImage := TBitmap.Create;
  SampleImage.PixelFormat := Pf24bit;
  SampleImage.Assign(BaseImage.Picture.Graphic);
  Item := ListView1.Items.Add;
  Item.ImageIndex := -1;

  case SampleImageType of
    TPSS_FullSize:
      Item.Caption := TEXT_MES_TPSS_FULL_SIZE;
    TPSS_C35:
      Item.Caption := TEXT_MES_TPSS_C35;
    TPSS_20X25C1:
      Item.Caption := TEXT_MES_TPSS_20X25C1;
    TPSS_13X18C1:
      Item.Caption := TEXT_MES_TPSS_13X18C1;
    TPSS_13X18C2:
      Item.Caption := TEXT_MES_TPSS_13X18C2;
    TPSS_10X15C1:
      Item.Caption := TEXT_MES_TPSS_10X15C1;
    TPSS_10X15C2:
      Item.Caption := TEXT_MES_TPSS_10X15C2;
    TPSS_10X15C3:
      Item.Caption := TEXT_MES_TPSS_10X15C3;
    TPSS_9X13C1:
      Item.Caption := TEXT_MES_TPSS_9X13C1;
    TPSS_9X13C2:
      Item.Caption := TEXT_MES_TPSS_9X13C2;
    TPSS_9X13C4:
      Item.Caption := TEXT_MES_TPSS_9X13C4;
    TPSS_C9:
      Item.Caption := TEXT_MES_TPSS_C9;
    TPSS_4X6C4:
      Item.Caption := TEXT_MES_TPSS_4X6C4;
    TPSS_3X4C6:
      Item.Caption := TEXT_MES_TPSS_3X4C6;
  end;
  Options.CropImages := False;
  Options.FreeCenterSize := False;
  Options.VirtualImage := False;
  NewImage := GenerateImage(False, ImageList1.Width, ImageList1.Height, SampleImage, nil, SampleImageType, Options);
  ImageList1.Add(NewImage, nil);
  Item.ImageIndex := ImageList1.Count - 1;
  Item.Indent := Integer(SampleImageType);
  SampleImage.Free;
  NewImage.Free;
end;

procedure TPrintForm.Button1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, 'rundll32.exe' ,'shell32.dll,SHHelpShortcuts_RunDLL AddPrinter','', SW_SHOWNORMAL);
end;

procedure TPrintForm.Button2Click(Sender: TObject);
begin
 if PrinterSetupDialog1.Execute then
 begin
  DoGenerateSample;
  Button3.Enabled:=false;
  Image1.Picture.Bitmap.Height:=0;
  Image1.Picture.Bitmap.Width:=0;
 end;
end;

procedure TPrintForm.Button4Click(Sender: TObject);
begin
 Close;
end;

procedure TPrintForm.DoGenerateSample;
var
  PixInInch, PageSizeMm : TXSize;
  SamplePage : TBitmap;

  PaperSize : TPaperSize;
begin
 PixInInch:=GetPixelsPerInch;
 PageSizeMm.Width:=InchToCm(Printer.PageWidth*10/PixInInch.Width);
 PageSizeMm.Height:=InchToCm(Printer.PageHeight*10/PixInInch.Height);
 SamplePage := TBitmap.Create;
 SamplePage.PixelFormat:=pf24bit;
 SamplePage.Width:=Printer.PageWidth;
 SamplePage.Height:=Printer.PageHeight;
 PaperSize := GetPaperSize;
 ListView1.Items.Clear;

 Case PaperSize of
 TPS_A4 :
  begin
   AddSampleImage(TPSS_FullSize);
   if VirtualBitmap=nil then AddSampleImage(TPSS_C35);
   AddSampleImage(TPSS_20X25C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_13X18C2);
   AddSampleImage(TPSS_13X18C1);
   AddSampleImage(TPSS_10X15C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_10X15C2);
   if FFiles.Count>2 then AddSampleImage(TPSS_10X15C3);
   AddSampleImage(TPSS_9X13C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_9X13C2);
   if FFiles.Count>2 then AddSampleImage(TPSS_9X13C4);
   if VirtualBitmap=nil then AddSampleImage(TPSS_C9);
   AddSampleImage(TPSS_4X6C4);
   AddSampleImage(TPSS_3X4C6);
  end;

 TPS_B5 :
  begin
   AddSampleImage(TPSS_FullSize);
   AddSampleImage(TPSS_13X18C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_13X18C2);
   AddSampleImage(TPSS_10X15C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_10X15C2);
   AddSampleImage(TPSS_9X13C1);
   if FFiles.Count>1 then AddSampleImage(TPSS_9X13C2);
   if VirtualBitmap=nil then AddSampleImage(TPSS_C9);
   AddSampleImage(TPSS_4X6C4);
   AddSampleImage(TPSS_3X4C6);
  end;

 TPS_CAN13X18:
  begin
   AddSampleImage(TPSS_FullSize);
   AddSampleImage(TPSS_13X18C1);
   AddSampleImage(TPSS_10X15C1);
   AddSampleImage(TPSS_9X13C1);
   AddSampleImage(TPSS_4X6C4);
   AddSampleImage(TPSS_3X4C6);
  end;

 TPS_CAN10X15:
  begin
   AddSampleImage(TPSS_FullSize);
   AddSampleImage(TPSS_10X15C1);
   AddSampleImage(TPSS_9X13C1);
  end;

 TPS_CAN9X13:
  begin
   AddSampleImage(TPSS_FullSize);
   AddSampleImage(TPSS_9X13C1);
  end;

 TPS_OTHER :
  begin
   AddSampleImage(TPSS_FullSize);
  end;
 end;

 SamplePage.Free;
end;

procedure TPrintForm.FormCreate(Sender: TObject);
var
  Ico : TIcon;
begin
 LoadLanguage;
 PrintFormExists:=true;
 FFiles:=TStringList.Create;
 ListView1.DoubleBuffered:=true;
 VirtualBitmap:=nil;
 ZoomInLink.LoadIconSize(ZoomInLink.Icon,16,16);
 ZoomOutLink.LoadIconSize(ZoomOutLink.Icon,16,16);
 FitToSizeLink.LoadIconSize(FitToSizeLink.Icon,16,16);
 FullSizeLink.LoadIconSize(FullSizeLink.Icon,16,16);
 ToolsPanelResize(Sender);
 FStatusProgress:=CreateProgressBar(StatusBar1,0);
 FStatusProgress.Hide;
 {$IFDEF PHOTODB}
 SaveWindowPos1.Key:=RegRoot+'PrintForm';
 Ico:=TIcon.Create;
 Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 WebLink1.Icon:=Ico;
 Ico.Free;
 {$ENDIF}
 SaveWindowPos1.SetPosition;
 DBKernel.RegisterForm(self);
end;

procedure TPrintForm.ListView1DblClick(Sender: TObject);
var
  item : TListItem;
  SampleType : TPrintSampleSizeOne;
  Files : TStrings;
  i, Incr : integer;
  Bitmap : TBitmap;
  Options : TGenerateImageOptions;
begin

 item:=ListView1.Selected;
 if item=nil then item:=ListView1.Items[0];
 SampleType := TPrintSampleSizeOne(item.indent);
 PreviewSID:=GetCID;
 StaticText1.Hide;
 Files := TStringList.Create;
 Bitmap := TBitmap.Create;

 ImageList1.GetBitmap(item.ImageIndex,Bitmap);
 Image1.Picture.Bitmap:=Bitmap;
 Bitmap.Free;
 FCurrentFormat:=SampleType;

 Case SampleType of
  TPSS_FullSize: Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_FULL_SIZE+']';
  TPSS_C35:      Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_C35+']';
  TPSS_20X25C1:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_20X25C1+']';
  TPSS_13X18C1:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_13X18C1+']';
  TPSS_13X18C2:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_13X18C2+']';
  TPSS_10X15C1:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_10X15C1+']';
  TPSS_10X15C2:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_10X15C2+']';
  TPSS_10X15C3:  Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_10X15C3+']';
  TPSS_9X13C1:   Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_9X13C1+']';
  TPSS_9X13C2:   Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_9X13C2+']';
  TPSS_9X13C4:   Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_9X13C4+']';
  TPSS_C9:       Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_C9+']';
  TPSS_4X6C4:    Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_4X6C4+']';
  TPSS_3X4C6:    Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION+'  ['+TEXT_MES_TPSS_3X4C6+']';
 end;

 Case SampleType of
  TPSS_FullSize: CountPerPage:=1;
  TPSS_C35:      CountPerPage:=35;
  TPSS_20X25C1:  CountPerPage:=1;
  TPSS_13X18C1:  CountPerPage:=1;
  TPSS_13X18C2:  CountPerPage:=2;
  TPSS_10X15C1:  CountPerPage:=1;
  TPSS_10X15C2:  CountPerPage:=2;
  TPSS_10X15C3:  CountPerPage:=3;
  TPSS_9X13C1:   CountPerPage:=1;
  TPSS_9X13C2:   CountPerPage:=2;
  TPSS_9X13C4:   CountPerPage:=4;
  TPSS_C9:       CountPerPage:=9;
  TPSS_4X6C4:    CountPerPage:=1;
  TPSS_3X4C6:    CountPerPage:=1;
 end;
 if CheckBox1.Checked then CountPerPage:=1;
 Pages:=(FFiles.Count div CountPerPage);
 if (FFiles.Count-Pages*CountPerPage)>0 then inc(Pages);
 ComboBox1.Text:='1';
 ComboBox1.Items.Clear;
 for i:=1 to Pages do ComboBox1.Items.Add(IntToStr(i));

 Incr:=StrToIntDef(ComboBox1.Text,1);
 Incr:=Min(Pages,Incr);
 Incr:=max(1,Incr);
 Incr:=(Incr-1)*CountPerPage;
 for i:=1 to CountPerPage do
 if FFiles.Count>=i+Incr then
 Files.Add(FFiles[i+Incr-1]);
 if (Files.Count=0) and (VirtualBitmap=nil) then
 begin
  Files.Free;
  Exit;
 end;

 Options.CropImages:=CheckBox2.Checked;
 Options.FreeCenterSize:=CheckBox1.Checked;
 Options.FreeWidthPx:=Round(SizeToPixels(XSize(StrToFloatDef(Edit1.Text,1),0)).Width);
 Options.FreeHeightPx:=Round(SizeToPixels(XSize(0,StrToFloatDef(Edit2.Text,1))).Height);
 if Options.FreeCenterSize then SampleType:=TPSS_CUSTOM;

 TGeneratorPrinterPreview.Create(false,self,PreviewSID,SampleType,Files,SetPreviewImage,false,Options,0,VirtualBitmap<>nil,VirtualBitmap,false);
 Files.Free;
 Button2.Enabled:=false;
 Button4.Enabled:=false;
 Button3.Enabled:=false;
 ListView1.Enabled:=false;
 ComboBox1.Enabled:=false;
 ZoomInLink.Enabled:=false;
 ZoomOutLink.Enabled:=false;
 WebLink1.Enabled:=false;
 FitToSizeLink.Enabled:=false;
 FullSizeLink.Enabled:=false;
 ZoomInLink.SetDefault;
 ZoomOutLink.SetDefault;
 FitToSizeLink.SetDefault;
 FullSizeLink.SetDefault;
end;

procedure TPrintForm.SetPreviewImage(Bitmap: TBitmap; SID: String);
begin
 if PreviewSID=SID then
 begin
  FastScrollingImage1.Picture:=Bitmap;
  {$IFNDEF WORK}
  FastScrollingImage1.FitImage:=true;
  {$ENDIF}
  {$IFDEF WORK}
  FastScrollingImage1.AutoZoomImage:=true;
  FastScrollingImage1.AutoShrinkImage:=true;
  {$ENDIF}
  FastScrollingImage1.Resize;
  Bitmap.Free;
  Button2.Enabled:=true;
  Button4.Enabled:=true;
  Button3.Enabled:=true;
  if not CheckBox1.Checked then ListView1.Enabled:=true;
  RadioGroup1.Enabled:=true;
  ComboBox1.Enabled:=true;
  Button3.Enabled:=true;
  ZoomInLink.Enabled:=true;
  ZoomOutLink.Enabled:=true;
  FitToSizeLink.Enabled:=true;
  FullSizeLink.Enabled:=true;
  WebLink1.Enabled:=true;
  ZoomInLink.SetDefault;
  ZoomOutLink.SetDefault;
  FitToSizeLink.SetDefault;
  FullSizeLink.SetDefault;
 end;
end;

procedure TPrintForm.ListView1Resize(Sender: TObject);
begin
 ShowScrollBar(ListView1.Handle, SB_HORZ, FALSE);
end;

procedure TPrintForm.FullSizeLinkClick(Sender: TObject);
begin
 {$IFNDEF WORK}
 FastScrollingImage1.FitImage:=false;
 {$ENDIF}
 {$IFDEF WORK}
 FastScrollingImage1.AutoZoomImage:=false;
 FastScrollingImage1.AutoShrinkImage:=false;
 {$ENDIF}
 FastScrollingImage1.Zoom:=100;
 FastScrollingImage1.Resize;
end;

procedure TPrintForm.ZoomOutLinkClick(Sender: TObject);
begin
 {$IFNDEF WORK}
 FastScrollingImage1.FitImage:=false;
 {$ENDIF}
 {$IFDEF WORK}
 FastScrollingImage1.AutoZoomImage:=false;
 FastScrollingImage1.AutoShrinkImage:=false;
 {$ENDIF}
 FastScrollingImage1.Zoom:= FastScrollingImage1.Zoom/1.2;
end;

procedure TPrintForm.ZoomInLinkClick(Sender: TObject);
begin
 {$IFNDEF WORK}
 FastScrollingImage1.FitImage:=false;
 {$ENDIF}
 {$IFDEF WORK}
 FastScrollingImage1.AutoZoomImage:=false;
 FastScrollingImage1.AutoShrinkImage:=false;
 {$ENDIF}
 FastScrollingImage1.Zoom:= FastScrollingImage1.Zoom*1.2;
end;

procedure TPrintForm.FitToSizeLinkClick(Sender: TObject);
begin
 {$IFNDEF WORK}
 FastScrollingImage1.FitImage:=true;
 {$ENDIF}
 {$IFDEF WORK}
 FastScrollingImage1.AutoZoomImage:=true;
 FastScrollingImage1.AutoShrinkImage:=true;
 {$ENDIF}
 FastScrollingImage1.Resize;
end;

procedure TPrintForm.ToolsPanelResize(Sender: TObject);
begin
 ListView1.Height:=ToolsPanel.Height-Panel2.Height-15-Panel3.Height;
end;

procedure TPrintForm.Button3Click(Sender: TObject);
var
  Options : TGenerateImageOptions;
begin
 if RadioGroup1.ItemIndex=0 then
 begin
  Printer.BeginDoc;
  Printer.Canvas.Draw(0,0,FastScrollingImage1.Picture);
  Printer.EndDoc;
  Close;
 end else
 begin
  Options.CropImages:=CheckBox2.Checked;
  Options.FreeCenterSize:=CheckBox1.Checked;
  TGeneratorPrinterPreview.Create(false,self,PreviewSID, GetSampleType,FFiles,SetPreviewImage,true,Options,CountPerPage,VirtualBitmap<>nil,VirtualBitmap,true);
  VirtualBitmap:=nil;
  Close;
 end;
end;

procedure TPrintForm.Execute(PrintFiles: TStrings);
var
  i : integer;
begin
  VirtualBitmap:=nil;
  FFiles.Assign(PrintFiles);
  {$IFDEF PHOTODB}
   for i:=FFiles.Count-1 downto 0 do
   if ValidCryptGraphicFile(FFiles[i]) then
   if DBKernel.FindPasswordForCryptImageFile(FFiles[i])='' then
   FFiles.Delete(i);
  {$ENDIF}
  if FFiles.Count=0 then
  begin
   Close;
   exit;
  end;
  DoGenerateSample;
  ShowModal;
end;

procedure TPrintForm.FormDestroy(Sender: TObject);
begin
 if VirtualBitmap<>nil then VirtualBitmap.Free;
 PrintFormExists:=false;
 FFiles.Free;
 SaveWindowPos1.SavePosition;
 DBKernel.UnRegisterForm(self);
end;

procedure TPrintForm.ComboBox1Click(Sender: TObject);
var
  Files : TStrings;
  i, Incr : integer;
  SampleType : TPrintSampleSizeOne;
  Options : TGenerateImageOptions;
begin
 SampleType := GetSampleType;
 PreviewSID:=GetCID;
 Files := TStringList.Create;
 Incr:=StrToIntDef(ComboBox1.Text,1);
 Incr:=Min(Pages,Incr);
 Incr:=max(1,Incr);
 Incr:=(Incr-1)*CountPerPage;
 for i:=1 to CountPerPage do
 if FFiles.Count>=i+Incr then
 Files.Add(FFiles[i+Incr-1]);
 if Files.Count=0 then
 begin
  Files.Free;
  Exit;
 end;
 Options.CropImages:=CheckBox2.Checked;
 Options.FreeCenterSize:=CheckBox1.Checked;
 Options.FreeWidthPx:=Round(SizeToPixels(XSize(StrToFloatDef(Edit1.Text,1),0)).Width);
 Options.FreeHeightPx:=Round(SizeToPixels(XSize(0,StrToFloatDef(Edit2.Text,1))).Height);
 if Options.FreeCenterSize then SampleType:=TPSS_CUSTOM;
 TGeneratorPrinterPreview.Create(false,self,PreviewSID, SampleType,Files,SetPreviewImage,false,Options,0,VirtualBitmap<>nil,VirtualBitmap,false);
 Files.Free;
 ListView1.Enabled:=false;
 ComboBox1.Enabled:=false;
 ZoomInLink.Enabled:=false;
 ZoomOutLink.Enabled:=false;
 FitToSizeLink.Enabled:=false;
 FullSizeLink.Enabled:=false;
 ZoomInLink.SetDefault;
 ZoomOutLink.SetDefault;
 FitToSizeLink.SetDefault;
 FullSizeLink.SetDefault;
end;

procedure TPrintForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 TerminateTimes.Enabled:=true;
end;

procedure TPrintForm.TerminateTimesTimer(Sender: TObject);
begin
 TerminateTimes.Enabled:=false;
 Release;
end;

function TPrintForm.GetSampleType: TPrintSampleSizeOne;
begin
 Result := FCurrentFormat;
end;

procedure TPrintForm.PopupMenu1Popup(Sender: TObject);
begin
 CopyToFile1.Visible:=Button3.Enabled;

end;

procedure TPrintForm.CopyToFile1Click(Sender: TObject);
var
  Image : TGraphic;
  SavePictureDialog : DBSavePictureDialog;
  FileName : string;
begin
 SavePictureDialog := DBSavePictureDialog.Create;
 SavePictureDialog.Filter:='JPEG Image File (*.jpg;*.jpeg)|*.jpg;*.jpeg|Bitmaps (*.bmp)|*.bmp';
 SavePictureDialog.FilterIndex:=1;
 if SavePictureDialog.Execute then
 begin
  FileName:=SavePictureDialog.FileName;
  Case SavePictureDialog.GetFilterIndex of
   1 :
    begin
     SetJPEGOptions;
     if (GetExt(FileName)<>'JPG') and (GetExt(FileName)<>'JPEG') then
     FileName:=FileName+'.jpg';
     if FileExists(FileName) then
     if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
     Image:=TJPEGImage.Create;
     Image.Assign(FastScrollingImage1.Picture);
     (Image as TJPEGImage).ProgressiveEncoding:=true;
     {$IFNDEF PHOTODB}
     (Image as TJPEGImage).CompressionQuality:=75;
     {$ENDIF}
     {$IFDEF PHOTODB}
     (Image as TJPEGImage).CompressionQuality:=DBKernel.ReadInteger('','JPEGCompression',75);
     (Image as TJPEGImage).ProgressiveEncoding:=DBKernel.ReadBool('','JPEGProgressiveMode',false);
     {$ENDIF}
     Image.SaveToFile(FileName);
     Image.Free;
    end;
   2 :
    begin
    if (GetExt(FileName)<>'BMP') then
     FileName:=FileName+'.bmp';
     if ID_OK<>MessageBoxDB(Handle,Format(TEXT_MES_FILE_EXISTS_REPLACE,[FileName]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
     Image:=TBitmap.Create;
     Image.Assign(FastScrollingImage1.Picture);
     Image.SaveToFile(FileName);
     Image.Free;
    end;

  end;
 end;
end;

procedure TPrintForm.LoadLanguage;
begin
 Button1.Caption:=TEXT_MES_ADD_PRINTER;
 Button2.Caption:=TEXT_MES_PRINTER_SETUP;
 ZoomOutLink.Text:=TEXT_MES_ZOOM_IN;
 ZoomInLink.Text:=TEXT_MES_ZOOM_OUT;
 FullSizeLink.Text:=TEXT_MES_IM_REAL_SIZE;
 FitToSizeLink.Text:=TEXT_MES_IM_FIT_TO_SIZE;
 Button4.Caption:=TEXT_MES_CLOSE;
 Button3.Caption:=TEXT_MES_DO_PRINT;
 Caption:=TEXT_MES_PRINTER_MAIN_FORM_CAPTION;
 Label5.Caption:=TEXT_MES_CURRENT_FORMAT;
 RadioGroup1.Caption:=TEXT_MES_PRINT_RANGE;
 RadioGroup1.Items[0]:=TEXT_MES_PRINT_RANGE_CURRENT;
 RadioGroup1.Items[1]:=TEXT_MES_PRINT_RANGE_ALL;
 CopyToFile1.Caption:=TEXT_MES_COPY_TO_FILE;
 CheckBox2.Caption:=TEXT_MES_CROP_IMAGES;
 CheckBox1.Caption:=TEXT_MES_USE_CUSTOM_SIZE;
 Label3.Caption:=TEXT_MES_CUSTOM_SIZE;
 Label2.Caption:=TEXT_MES_PAGE+':';
 Label1.Caption:=TEXT_MES_PRINT_FORMATS+':';
 WebLink1.Text:=TEXT_MES_MAKE_IMAGE;
 StaticText1.Caption:=TEXT_MES_PRINT_SELECT_FORMAT;
end;

procedure TPrintForm.CheckBox1Click(Sender: TObject);
begin
 Edit1.Enabled := CheckBox1.Checked;
 Edit2.Enabled := CheckBox1.Checked;
 ComboBox2.Enabled := CheckBox1.Checked;
 ListView1.Enabled := not CheckBox1.Checked;
end;

procedure TPrintForm.Execute(VirtualFile: TBitmap);
begin
 FFiles.Clear;
 Pointer(VirtualBitmap):=Pointer(VirtualFile);
 DoGenerateSample;
 ShowModal;
end;

Function TPrintForm.SizeToPixels(Pixels: TXSize): TXSize;
begin
 if AnsiLowerCase(ComboBox2.Text)='px' then Result:=Pixels;
 if AnsiLowerCase(ComboBox2.Text)='mm' then Result:=MmToPix(XSize(Pixels.Width,Pixels.Height));
 if AnsiLowerCase(ComboBox2.Text)='sm' then Result:=MmToPix(XSize(Pixels.Width*10,Pixels.Height*10));
 if AnsiLowerCase(ComboBox2.Text)='in' then Result:=MmToPix(XSize(InchToCm(Pixels.Width)*10,InchToCm(Pixels.Height)*10));
 if Result.Width>Printer.PageWidth then
 begin
  Result.Width:=Printer.PageWidth;
 end;
 if Result.Height>Printer.PageHeight then
 begin
  Result.Height:=Printer.PageHeight;
 end;
end;

procedure TPrintForm.ComboBox2KeyPress(Sender: TObject; var Key: Char);
begin
 Key:=#0;
end;

function TPrintForm.PixelsToSize(Pixels: TXSize): TXSize;
begin
 if AnsiLowerCase(ComboBox2.Text)='px' then Result:=Pixels;
 if AnsiLowerCase(ComboBox2.Text)='mm' then Result:=PixToSm(XSize(Pixels.Width*10,Pixels.Height*10));
 if AnsiLowerCase(ComboBox2.Text)='sm' then Result:=PixToSm(Pixels);
 if AnsiLowerCase(ComboBox2.Text)='in' then Result:=PixToIn(Pixels);
end;

function FloatToStrX(Value: Extended; Numbers : integer): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended,
    ffGeneral, Numbers, 0));
end;

procedure TPrintForm.Edit1Exit(Sender: TObject);
var
  Size : TXSize;
  text : string;
begin
 if Edit1.Tag=1 then Exit;
 Edit1.Tag:=1;
 text:=Edit1.Text;
 if Edit1.Text[Length(Edit1.Text)]=DecimalSeparator then text:=text+'0';
 Size:=SizeToPixels(XSize(StrToFloatDef(Text,1),0));
 Size:=PixelsToSize(Size);
 Edit1.Text:=FloatToStrX(Size.Width,4);
 Edit1.Tag:=0;
end;

procedure TPrintForm.Edit2Exit(Sender: TObject);
var
  Size : TXSize;
  text : string;
begin
 if Edit2.Tag=1 then Exit;
 Edit2.Tag:=1;
 text:=Edit2.Text;
 if Edit2.Text[Length(Edit2.Text)]=DecimalSeparator then text:=text+'0';
 Size:=SizeToPixels(XSize(0,StrToFloatDef(Text,1)));
 Size:=PixelsToSize(Size);
 Edit2.Text:=FloatToStrX(Size.Height,4);
 Edit2.Tag:=0;
end;

procedure TPrintForm.ComboBox2Change(Sender: TObject);
begin
 Edit1Exit(Sender);
 Edit2Exit(Sender);
end;

procedure TPrintForm.FastScrollingImage1Resize(Sender: TObject);
begin
 StaticText1.Left:=ToolsPanel.Width+ FastScrollingImage1.Width div 2- StaticText1.Width div 2;
 StaticText1.Top:=FastScrollingImage1.Height div 2- StaticText1.Height div 2;
end;

initialization

PrintFormExists := false;
Printing := false;

end.
