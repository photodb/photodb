unit UnitConvertDBForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DmProgress, ComCtrls, Dolphin_DB, 
  uVistaFuncs, jpeg, Spin, UnitRecreatingThInTable, CommonDBSupport, Menus,
  ExtDlgs, Graphics, UnitPasswordKeeper, UnitDBDeclare, AppEvnts,
  UnitDBCommonGraphics, UnitDBFileDialogs, UnitDBCommon;

type
  TFormConvertingDB = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
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
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
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
   FFileName : string;
   Step : integer;
   SilentClose : boolean;
   Image : TJpegImage;
   ImageOptions : TImageDBOptions;
   RecordCount : integer;
   PasswordKeeper : TPasswordKeeper;
   
   ItemsData : TList;
   Infos : TArStrings;
   FInfo : String;
   FProgressEnabled : boolean;
   Icons : array of TIcon;
   TopRecords : integer;
   CurrentWideIndex : integer;
    { Private declarations }
  public           
  procedure LoadToolBarIcons;
  procedure LoadLanguage;
  procedure Execute(FileName : string);
  procedure DoFormExit(Sender: TObject);
  procedure OnConvertingStructureEnd(Sender: TObject; NewFileName : string);
  procedure WriteLine(Sender : TObject; Line : string; Info : integer);
  procedure WriteLnLine(Sender : TObject; Line : string; Info : integer);
  procedure ProgressCallBack(Sender : TObject; var Info : TProgressCallBackInfo); 
    { Public declarations }
  end;

procedure ConvertDB(FileName : string);

implementation

uses UnitDBKernel, Language, ConvertDBThreadUnit, About, CMDUnit;

procedure ConvertDB(FileName : string);
var
  FormConvertingDB: TFormConvertingDB;
begin
 Application.CreateForm(TFormConvertingDB, FormConvertingDB);
 FormConvertingDB.Execute(FileName);
 FormConvertingDB.Release;
 if UseFreeAfterRelease then
 FormConvertingDB.Free;
end;

{$R *.dfm}

{ TFormConvertingDB }

procedure TFormConvertingDB.Execute(FileName: string);
var
  DBVer : integer;
begin
 if AboutForm<>nil then AboutForm.WaitEnabled:=false;
 FFileName:=FileName;
 RadioButton1.Enabled:=False;// TODO: !!! BDEInstalled;
 Edit2.Text:=FFileName;
 ImageOptions:=CommonDBSupport.GetImageSettingsFromTable(FFileName);
 DBVer:=DBKernel.TestDBEx(FFileName);
 RecordCount:=CommonDBSupport.GetRecordsCount(FFileName);
 Edit1.Text:=DBKernel.StringDBVersion(DBVer);
 ComboBox1Change(nil);
 ShowModal;
end;

procedure TFormConvertingDB.FormCreate(Sender: TObject);
begin
 PasswordKeeper:=TPasswordKeeper.Create;
 ImageOptions.Version:=0; //VERSION SETTED AFTER PROCESSING IMAGES
 Image:=TJpegImage.Create;
 Image.Assign(ImagePreview.Picture.Graphic);
 Panel2.Visible:=false;
 Button2.Enabled:=false;
 LoadLanguage;
 Step:=1;
 SilentClose:=false;

 CurrentWideIndex:=-1;
 FProgressEnabled:=true;
 FInfo:='';
 SetLength(Infos,0);
 InfoListBox.DoubleBuffered:=true;
 ItemsData:=TList.Create;
 InfoListBox.ItemHeight:=InfoListBox.Canvas.TextHeight('Iy')*3+5;
 InfoListBox.Clear;
 LoadToolBarIcons;
end;

procedure TFormConvertingDB.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_DIALOG_CONVERTING_DB;
 Label3.Caption:=TEXT_MES_CURRENT_DATABASE+':';
 RadioButton1.Caption:=TEXT_MES_CONVERT_TO_BDE;
 RadioButton2.Caption:=TEXT_MES_CONVERT_TO_MDB;
 Button3.Caption:=TEXT_MES_CANCEL;
 Label2.Caption:=TEXT_MES_CONVERTING_FIRST_STEP;
 Caption:=TEXT_MES_CONVERTING_CAPTION;
 Button2.Caption:=TEXT_MES_SLIDE_PREVIOUS;
 Button1.Caption:=TEXT_MES_NEXT;
 Label4.Caption:=TEXT_MES_CONVERTING_SECOND_STEP;
 Label6.Caption:=TEXT_MES_CURRENT_ACTION+':';
 Button4.Caption:=TEXT_MES_START_NOW;
 Button5.Caption:=TEXT_MES_BREAK_BUTTON;
 Button6.Caption:=TEXT_MES_FINISH;
 Label7.Caption:=TEXT_MES_WAITING;
 Label8.Caption:=TEXT_MES_CONVERTING_IMAGE_SIZES_STEP;
 Label9.Caption:=TEXT_MES_SIZE+':';
 ComboBox1.Items[0]:=TEXT_MES_CONVERTATION_JPEG_QUALITY;
 ComboBox1.Items[1]:=TEXT_MES_CONVERTATION_TH_SIZE;
 ComboBox1.Items[2]:=TEXT_MES_CONVERTATION_PANEL_PREVIEW_SIZE;
 ComboBox1.Items[3]:=TEXT_MES_CONVERTATION_HINT_SIZE;
 ComboBox1.ItemIndex:=1;
 LoadDifferentImage1.Caption:=TEXT_MES_LOAD_DIFFERENT_IMAGE;
end;

procedure TFormConvertingDB.Button3Click(Sender: TObject);
begin
 Close;
end;

procedure TFormConvertingDB.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if not SilentClose then
 CanClose:=ID_OK=Application.MessageBox(TEXT_MES_DO_YOU_REALLY_WANT_TO_CLOSE_THIS_DIALOG,TEXT_MES_QUESTION,MB_OKCANCEL+MB_ICONQUESTION);
end;

procedure TFormConvertingDB.Button1Click(Sender: TObject);
begin     
 if Step=1 then
 if not RadioButton2.Checked then Step:=2;

  if Step=2 then
  begin
   Step:=3;              
   Panel2.Visible:=false;
   Panel3.Visible:=true;  
   Button1.Visible:=false;
   Button2.Enabled:=true;
   Button4.Visible:=true;
  end;

  if Step=1 then
  begin
   Step:=2;               
   Panel1.Visible:=false;
   Panel2.Visible:=true;
   Button2.Enabled:=true;
   Button4.Visible:=false;
  end;
end;

procedure TFormConvertingDB.Button2Click(Sender: TObject);
begin

  if Step=2 then
  begin
   Step:=1;
   Panel2.Visible:=false;
   Panel1.Visible:=true;  
   Button2.Enabled:=false;
  end;
  
  if Step=3 then
  begin
   Step:=2;
   Button4.Visible:=false;  
   Button1.Visible:=true;
   Panel2.Visible:=true;
   Panel3.Visible:=false;
  end;

 if Step=2 then
 if not RadioButton2.Checked then Button2Click(Sender);

end;

procedure TFormConvertingDB.Button4Click(Sender: TObject);
begin
  if Step=3 then
  begin
   Step:=4;
   Button1.Enabled:=false;
   Button2.Enabled:=false;
   Button3.Enabled:=false;   
   Button4.Enabled:=false;
   Button5.Visible:=true;
   TConvertDBThread.Create(false,self,FFileName,RadioButton2.Checked,ImageOptions);
  end;
end;

procedure TFormConvertingDB.Button5Click(Sender: TObject);
begin
 if ID_YES=MessageBoxDB(Handle,TEXT_MES_BREAK_RECREATING_TH,TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_WARNING) then
 begin
  BreakConverting:=true;
  RecreatingThInTableTerminating:=true;
  Button5.Enabled:=false;
 end;
end;

procedure TFormConvertingDB.DoFormExit(Sender: TObject);
begin
 SilentClose:=true;
 Button5.Enabled:=false;
 MessageBoxDB(Handle,TEXT_MES_CONVETRING_ENDED,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
 Button6.Visible:=true;
end;

procedure TFormConvertingDB.OnConvertingStructureEnd(Sender: TObject; NewFileName : string);
var
 Options : TRecreatingThInTableOptions;
begin
 Options.WriteLineProc:=WriteLine;
 Options.WriteLnLineProc:=WriteLnLine;
 Options.OnEndProcedure:=DoFormExit;
 Options.FileName:= NewFileName;
 Options.GetFilesWithoutPassProc:=PasswordKeeper.GetActiveFiles;
 Options.AddCryptFileToListProc:=PasswordKeeper.AddCryptFileToListProc;
 Options.GetAvaliableCryptFileList:=PasswordKeeper.GetAvaliableCryptFileList;
 Options.OnProgress:=ProgressCallBack;
 RecreatingThInTable.Create(False,Options);
end;

procedure TFormConvertingDB.Button6Click(Sender: TObject);
begin
 Close;
end;

procedure TFormConvertingDB.RadioButton1Click(Sender: TObject);
begin
 MessageBoxDB(Handle,TEXT_MES_DB_IS_OLD_DB,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
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
 Case ComboBox1.ItemIndex of
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
 if (ComboBox1.ItemIndex=0) or (ComboBox1.ItemIndex=1) then
 begin
  ImagePreview.Picture.Assign(Jpeg);
 end else
 begin
  if ComboBox1.ItemIndex = 2 then
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
 Label12.Caption:=Format(TEXT_MES_NEW_DB_SIZE_FORMAT,[Dolphin_DB.SizeInTextA(RecordCount*ImageSize)]);

 Jpeg.free;
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

procedure TFormConvertingDB.WriteLine(Sender: TObject; Line: string; Info : integer);
begin
 BeginScreenUpdate(Handle);
 PInteger(ItemsData[0])^:=Info;
 InfoListBox.Items[0]:=Line;
 EndScreenUpdate(Handle,false);
end;

procedure TFormConvertingDB.WriteLnLine(Sender: TObject; Line: string; Info : integer);
var
  p : PInteger;
  i : integer;
begin
 if Info=LINE_INFO_INFO then
 begin
  FInfo:=Line;
  exit;
 end;
 LockWindowUpdate(Handle);
 SetLength(Infos,Length(Infos)+1);
 for i:=length(Infos)-2 downto TopRecords do
 begin
  Infos[i+1]:=Infos[i];
 end;
 Infos[ TopRecords]:=FInfo;

 GetMem(p,SizeOf(integer));
 p^:=Info;
 ItemsData.Insert( TopRecords,p);
 InfoListBox.Items.Insert( TopRecords,Line);

 FInfo:='';

 LockWindowUpdate(0);
end;

procedure TFormConvertingDB.LoadDifferentImage1Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
begin
 OpenDialog:=DBOpenDialog.Create;
 OpenDialog.Filter:='JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg';
 OpenDialog.FilterIndex:=1;

 if OpenDialog.Execute then
 begin
  Image.LoadFromFile(OpenDialog.FileName);
  ComboBox1Change(sender);
 end;
 OpenDialog.Free;
end;

procedure TFormConvertingDB.FormDestroy(Sender: TObject);
begin
 PasswordKeeper.Free;
 DBKernel.ReadDBOptions;
end;

procedure TFormConvertingDB.PasswordTimerTimer(Sender: TObject);
var
  PasswordList : TArCardinal;
  i : integer;
begin
 if PasswordKeeper.Count>0 then
 begin
  PasswordTimer.Enabled:=false;
  PasswordList:=PasswordKeeper.GetPasswords;
  for i:=0 to Length(PasswordList)-1 do
  begin
   PasswordKeeper.TryGetPasswordFromUser(PasswordList[i]);
  end;  
  PasswordTimer.Enabled:=true;
 end;
end;

procedure TFormConvertingDB.ProgressCallBack(Sender: TObject;
  var Info: TProgressCallBackInfo);
begin
 if Info.MaxValue<>Progress.MaxValue then
 begin
  Progress.MaxValue:=Info.MaxValue;
  TempProgress.MaxValue:=Info.MaxValue;
 end;
 Progress.Position:=Info.Position;
 TempProgress.Position:=Info.Position;
 if Label3.Caption<>Info.Information then
 begin
  Label3.Caption:=Info.Information;
  Progress.Text:=Info.Information+' (&%%)';
 end;
end;

procedure TFormConvertingDB.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
 DoInfoListBoxDrawItem(Control as TListBox,Index,Rect,State,
 ItemsData,Icons,FProgressEnabled,TempProgress,Infos);
end;

procedure TFormConvertingDB.LoadToolBarIcons;
var
  index : integer;

  procedure AddIcon(Name : String);
  begin
   Icons[index]:=TIcon.Create;
   Icons[index].Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
   Inc(index);
  end;
begin
 index:=0;
 SetLength(Icons,7);
 AddIcon('CMD_OK');
 AddIcon('CMD_ERROR');
 AddIcon('CMD_WARNING');
 AddIcon('CMD_PLUS');
 AddIcon('CMD_PROGRESS');
 AddIcon('CMD_DB');
 AddIcon('ADMINTOOLS');
end;

procedure TFormConvertingDB.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if Msg.hwnd=InfoListBox.Handle then
 if Msg.message<>15 then
 if Msg.message<>512 then
 if Msg.message<>160 then  
 if Msg.message<>161 then
 if Msg.message=522 then
 begin
  Msg.message:=0;
//  ShowMessage(IntToStr(Msg.message));
 end;
end;

end.
