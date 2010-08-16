unit UnitUpdateDB;

interface

uses
  dolphin_db, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DmProgress, Menus, ExtCtrls, UnitHelp, uVistaFuncs,
  DropSource, DropTarget, UnitDBkernel, DB, AppEvnts, UnitDBDeclare,
  UnitUpdateDBObject, UnitTimeCounter, DragDrop, DragDropFile, WebLink,
  GraphicCrypt, jpeg, TLayered_Bitmap, UnitDBCommon,
  UnitDBCommonGraphics, DmMemo, uW7TaskBar;

type
  TUpdateDBForm = class(TForm)
    PopupMenu1: TPopupMenu;
    Stayontop1: TMenuItem;
    Layered1: TMenuItem;
    Fill1: TMenuItem;
    N101: TMenuItem;
    N201: TMenuItem;
    N301: TMenuItem;
    N401: TMenuItem;
    N501: TMenuItem;
    N601: TMenuItem;
    N701: TMenuItem;
    N801: TMenuItem;
    N901: TMenuItem;
    Hide1: TMenuItem;
    Auto1: TMenuItem;
    AutoAnswer1: TMenuItem;
    None1: TMenuItem;
    ReplaceAll1: TMenuItem;
    AddAll1: TMenuItem;
    SkipAll1: TMenuItem;
    History1: TMenuItem;
    UseScaningByFilename1: TMenuItem;
    DropFileTarget1: TDropFileTarget;
    ApplicationEvents1: TApplicationEvents;
    DmMemo1: TDmMemo;
    FilesLabel: TDmMemo;
    ProgressBar: TDmProgress;
    WebLinkOpenImage: TWebLink;
    WebLinkOpenFolder: TWebLink;
    ButtonClose: TWebLink;
    ButtonBreak: TWebLink;
    ButtonRunStop: TWebLink;
    ShowHistoryLink: TWebLink;
    WebLinkOptions: TWebLink;
    ImageGo: TImage;
    ImageHourGlass: TImage;
    Timer1: TTimer;
    TimerTerminate: TTimer;
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Stayontop1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure N101Click(Sender: TObject);
    procedure Auto1Click(Sender: TObject);
    procedure None1Click(Sender: TObject);
    procedure ReplaceAll1Click(Sender: TObject);
    procedure AddAll1Click(Sender: TObject);
    procedure SkipAll1Click(Sender: TObject); 
    procedure ButtonRunStopClick(Sender: TObject);
    procedure ButtonBreakClick(Sender: TObject);
    procedure SetAddObject(AddObject : TUpdaterDB);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure UseScaningByFilename1Click(Sender: TObject);
    procedure History1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HideImage(OnCreate : boolean);
    procedure ShowImage;
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Image1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure WebLinkOptionsClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WebLinkOpenImageClick(Sender: TObject);
    procedure WebLinkOpenFolderClick(Sender: TObject);
    procedure TimerTerminateTimer(Sender: TObject);
  private
    FImage : TLayeredBitmap;
    FImageInv : TLayeredBitmap;
    FImageHourGlass : TLayeredBitmap;
    FImagePos : integer;
    FImagePosStep : integer;
    FCurrentImage : TBitmap;
    FCurrentFileName : string;
    FAddObject : TUpdaterDB;
    BadHistory : TStrings;
    LastIDImage : integer;
    LastFileName : String;  
    TimeCounter: TTimeCounter;
    FInfoStr : string;
    FProgressMessage : Cardinal; 
    FW7TaskBar : ITaskbarList3;
  procedure WMMouseDown(var s : Tmessage); message WM_LButtonDown;
    { Private declarations }
  public        
   FullSize : Int64;
  Constructor Create(AOwner : TComponent; AddObject : TUpdaterDB); reintroduce;
  Procedure LoadLanguage;
  Procedure SetAutoAnswer(Value : integer);
  Procedure SetText(Text : string);
  Procedure ShowForm(Sender: TObject);
  Procedure SetMaxValue(Value : integer);
  Procedure SetDone(Sender: TObject);       
  Procedure SetBeginUpdation(Sender: TObject);
  Procedure SetTimeText(Text : string);
  Procedure SetPosition(Value : integer);
  Procedure SetFileName(FileName : string);  
  Procedure DoShowImage(Sender: TObject);
  Procedure AddFileSizes(Value : int64);
  Procedure OnBeginUpdation(Sender: TObject);
  procedure LoadToolBarIcons;
  procedure SetIcon(Link : TWebLink; Name : String);
  procedure OnDirectorySearch(Owner : TObject; FileName : string; Size : int64);
    { Public declarations }
  end;

var
  UpdaterDB : TUpdaterDB;
  
implementation

uses Language, FormManegerUnit, UnitHistoryForm,
     ExplorerUnit, SlideShow, UnitScripts, DBScriptFunctions,
     UnitUpdateDBThread;

{$R *.dfm}

{ TUpdateDBForm }

procedure TUpdateDBForm.WMMouseDown(var s: Tmessage);
begin
 Perform(WM_NCLButtonDown,HTcaption,s.lparam);
end;

procedure TUpdateDBForm.ButtonCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TUpdateDBForm.FormCreate(Sender: TObject);
var
  i, j : integer;
  b : byte;
  P : PARGB32;
begin
 FullSize:=0;
 DoubleBuffered := true;
 FInfoStr:='';
 FCurrentImage:=nil;
 FCurrentFileName:='';
 HideImage(true);
 TimeCounter:= TTimeCounter.Create;
 TimeCounter.TimerInterval:=10000;  // 15 seconds to refresh
 LastIDImage:=0;
 LastFileName:=':::';
 BadHistory:=TStringList.Create;
 DBKernel.RegisterForm(self);
 DBKernel.RecreateThemeToForm(self);
 DropFileTarget1.Register(Self);
 DBKernel.RegisterChangesID(Self,ChangedDBDataByID);
 LoadLanguage;
 LoadToolBarIcons();

 FImagePos:=0;
 FImagePosStep:=1;
 FImage := TLayeredBitmap.Create();
 FImage.LoadFromHIcon(ImageGo.Picture.Icon.Handle);

 FImageInv := TLayeredBitmap.Create();
 FImageInv.LoadFromHIcon(ImageGo.Picture.Icon.Handle);

 for i:=0 to FImageInv.Height-1 do
 begin
   P := FImageInv.ScanLine[i];
   for j:=0 to FImageInv.Width-1 do
   begin
    b := P[j].R;
    P[j].R := P[j].B;
    P[j].B := b;
   end;
 end;

  FImageHourGlass:= TLayeredBitmap.Create();
  FImageHourGlass.LoadFromHIcon(ImageHourGlass.Picture.Icon.Handle, 48, 48);

  FProgressMessage := RegisterWindowMessage('SLIDE_SHOW_PROGRESS');
  PostMessage(Handle, FProgressMessage, 0, 0);
end;

procedure TUpdateDBForm.Stayontop1Click(Sender: TObject);
begin
 Stayontop1.Checked:=not Stayontop1.Checked;
 If not Stayontop1.Checked then
 FormStyle:=FsNormal else FormStyle:=fsStayOnTop;
end;

constructor TUpdateDBForm.Create(AOwner: TComponent;
  AddObject: TUpdaterDB);
begin             
 Inherited Create(AOwner);
 FAddObject:=AddObject;
end;

procedure TUpdateDBForm.SetAddObject(AddObject: TUpdaterDB);
begin
 FAddObject:=AddObject;
end;

procedure TUpdateDBForm.LoadLanguage;
begin
 FilesLabel.Text:= TEXT_MES_NO_ANY_FILEA;
 ProgressBar.Text:='';
 ButtonBreak.Text:= TEXT_MES_BREAK_BUTTON;
 ButtonRunStop.Text:= TEXT_MES_PAUSE;
 ButtonClose.Text:= TEXT_MES_CLOSE;
 ProgressBar.Text:= TEXT_MES_PROGRESS_PR;
 Stayontop1.Caption := TEXT_MES_STAY_ON_TOP;
 Layered1.Caption:= TEXT_MES_LAYERED;
 Fill1.Caption:= TEXT_MES_FILL;
 Hide1.Caption:= TEXT_MES_HIDE;
 Auto1.Caption:= TEXT_MES_AUTO;
 AutoAnswer1.Caption:= TEXT_MES_AUTO_ANSWER;
 None1.Caption:= TEXT_MES_NONE;
 ReplaceAll1.Caption:= TEXT_MES_REPLACE_ALL;
 AddAll1.Caption:= TEXT_MES_ADD_ALL;
 SkipAll1.Caption:= TEXT_MES_SKIP_ALL;
 Caption:=TEXT_MES_UPDATER_CAPTION;
 History1.Caption:= TEXT_MES_HISTORY;
 UseScaningByFilename1.Caption:=TEXT_MES_USE_SCANNING_BY_FILENAME;

 ShowHistoryLink.Text:= TEXT_MES_SHOW_HISTORY;
 WebLinkOptions.Text:=TEXT_MES_OPTIONS;
 WebLinkOpenImage.Text:=TEXT_MES_UPDATER_OPEN_IMAGE;
 WebLinkOpenFolder.Text:=TEXT_MES_UPDATER_OPEN_FOLDER;
 DmMemo1.Text:=TEXT_MES_PROCESSING_STATUS;
end;

procedure TUpdateDBForm.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  p : TPoint;
  i, FileSize : integer;
  b : Boolean;
  w,h : integer;
  bit, Bitmap : TBitmap;

procedure FillRectToBitmapA(var Bitmap: TBitmap);
begin
 Bitmap.Canvas.Pen.Color:=0;
 Bitmap.Canvas.Brush.Color:=RGB(Round(GetRValue(Theme_ListColor)*0.9),Round(GetGValue(Theme_ListColor)*0.9),Round(GetBValue(Theme_ListColor)*0.9));
 Bitmap.Canvas.Rectangle(0,0,Bitmap.Width,Bitmap.Height);
 Bitmap.Canvas.Pen.Color:=Theme_ListColor;
end;

begin

 if (SetNewIDFileData in params) or (EventID_FileProcessed in params) then
 //? if FAddObject.Active then
 begin
  LastFileName:=Value.Name;
  LastIDImage:=ID;
  bit := TBitmap.Create;
  bit.PixelFormat:=pf24bit;
  bit.Assign(Value.JPEGImage);
  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat:=pf24bit;
  w:=bit.Width;
  h:=bit.Height;
  ProportionalSize(100,100,w,h);
  DoResize(w,h,bit,Bitmap);
  bit.free;
  FCurrentImage:=TBitmap.Create;
  FCurrentImage.Assign(Bitmap);
  Repaint;
  Bitmap.free;
  FileSize:=Dolphin_DB.GetFileSizeByName(Value.Name);
  TimeCounter.NextAction(FileSize);

  ProgressBar.Text:=Format(TEXT_MES_TIME_REM_F,[FormatDateTime('hh:mm:ss',TimeCounter.GetTimeRemaining)]);
  FCurrentFileName:=Value.Name;
  WebLinkOpenImage.Enabled:=true;
  WebLinkOpenImage.RefreshBuffer;
  WebLinkOpenImage.Repaint;
  WebLinkOpenFolder.Enabled:=true;
  WebLinkOpenFolder.RefreshBuffer;
  WebLinkOpenFolder.Repaint;
  exit;
 end;

 if EventID_Param_Add_Crypt_WithoutPass in params then
 begin
  b:=true;
  Value.Name:=AnsiLowerCase(Value.Name);
  for i:=0 to BadHistory.Count-1 do
  if AnsiLowerCase(BadHistory[i])=Value.Name then
  begin
   b:=false;
   break;
  end;
  if b then BadHistory.Add(Value.Name);
  if not CryptFileWithoutPassChecked then
  begin
   Show;
   Delay(100);
   DoHelpHint(TEXT_MES_WARNING,TEXT_MES_CRYPT_FILE_WITHOUT_PASS_MOT_ADDED,p,Self);
  end;
 end;
end;

procedure TUpdateDBForm.HideImage(OnCreate : boolean);
begin
 if not WebLinkOpenImage.Enabled and not WebLinkOpenFolder.Enabled then exit;
 if not OnCreate then
 begin
  if GetParamStrDBBool('/NoFullRun') then
  begin
   TimerTerminate.Enabled:=true;
   exit;
  end;
 end;
 WebLinkOpenImage.Enabled:=false;
 WebLinkOpenImage.RefreshBuffer;
 WebLinkOpenImage.Repaint;
 WebLinkOpenFolder.Enabled:=false;
 WebLinkOpenFolder.RefreshBuffer;
 WebLinkOpenFolder.Repaint;
 FCurrentImage.free;
 FCurrentFileName:='';
 FCurrentImage:=nil;
 ProgressBar.Position:=0;
 ProgressBar.Text:=TEXT_MES_DONE;
 Repaint;
end;

procedure TUpdateDBForm.ShowImage;
begin
//
end;

procedure TUpdateDBForm.Hide1Click(Sender: TObject);
begin
 Hide;
end;

procedure TUpdateDBForm.N101Click(Sender: TObject);
Var
  S : String;
  n : Integer;
begin
 S:=(Sender as TMenuItem).Caption;
 S:=copy(s,2,2);
 n:=StrToIntDef(s,0);
 AlphaBlendValue:=Round(255-255*n/100);
end;

procedure TUpdateDBForm.Auto1Click(Sender: TObject);
begin
 Auto1.Checked:=Not Auto1.Checked;
 FAddObject.Auto:=Auto1.Checked;
end;

procedure TUpdateDBForm.None1Click(Sender: TObject);
begin
 FAddObject.AutoAnswer:=Result_invalid;
end;

procedure TUpdateDBForm.ReplaceAll1Click(Sender: TObject);
begin
 FAddObject.AutoAnswer:=Result_replace_All;
end;

procedure TUpdateDBForm.AddAll1Click(Sender: TObject);
begin
 FAddObject.AutoAnswer:=Result_add_all;
end;

procedure TUpdateDBForm.SkipAll1Click(Sender: TObject);
begin
 FAddObject.AutoAnswer:=Result_skip_all;
end;

procedure TUpdateDBForm.ButtonRunStopClick(Sender: TObject);
begin
 if FAddObject.Pause then
 begin
  FAddObject.DoUnPause;
  SetIcon(ButtonRunStop,'UPDATER_PAUSE');
  ButtonRunStop.Text:=TEXT_MES_PAUSE;
 end else begin
 //TODO icon
  FAddObject.DoPause;    
  SetIcon(ButtonRunStop,'UPDATER_PLAY');
  ButtonRunStop.Text:=TEXT_MES_UNPAUSE;
 end;
end;

procedure TUpdateDBForm.ButtonBreakClick(Sender: TObject);
begin
 FAddObject.DoTerminate;
end;

procedure TUpdateDBForm.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  i : integer;
begin
 for i:=0 to DropFileTarget1.Files.Count-1 do
 begin
  FInfoStr:='';
  if FileExists((DropFileTarget1.Files[i])) then
  UpdaterDB.AddFile((DropFileTarget1.Files[i]));
  if Directoryexists((DropFileTarget1.Files[i])) then
  begin
   UpdaterDB.AddDirectory((DropFileTarget1.Files[i]),OnDirectorySearch);
  end;
  UpdaterDB.Execute;
 end;
end;

procedure TUpdateDBForm.FormDestroy(Sender: TObject);
begin
 UpdaterDB.SaveWork;
 TimeCounter.Free;
 BadHistory.Free;
 DBKernel.UnRegisterChangesID(Self,ChangedDBDataByID);
 DropFileTarget1.Unregister;
end;

procedure TUpdateDBForm.UseScaningByFilename1Click(Sender: TObject);
begin
 UseScaningByFilename1.Checked:=Not UseScaningByFilename1.Checked;
 FAddObject.UseFileNameScaning:=UseScaningByFilename1.Checked;
end;

procedure TUpdateDBForm.History1Click(Sender: TObject);
begin
// BadHistory.Add('D:\Projects\VBToC#Replacer_1_2\VBToC#Replacer\Projects');
// BadHistory.Add('j:\autoexec.bat');
 if BadHistory.Count=0 then
 begin
  MessageBoxDB(Handle,TEXT_MES_NO_HISTORY,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
  exit;
 end;
 ShowHistory(BadHistory);
end;

procedure TUpdateDBForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 if FormManager.IsMainForms(self) and (FormManager.MainFormsCount=1) then
 begin
  FAddObject.DoTerminate;
 end;
end;

procedure TUpdateDBForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
const
  SC_DragMove = $F012;
begin
  if Msg.Message = FProgressMessage then
    FW7TaskBar := CreateTaskBarInstance;

  if (Msg.Message = WM_LBUTTONDOWN) then
  begin
    if (Msg.hwnd = FilesLabel.Handle)
    or (Msg.hwnd = DmMemo1.Handle)
    or (Msg.hwnd = ProgressBar.Handle) then
    begin
      Perform(WM_NCLBUTTONDOWN, HTcaption, Msg.lparam);
      Handled := True;
    end;
  end;
end;

// LastIDImage
procedure TUpdateDBForm.Image1Click(Sender: TObject);
var
  Info : TRecordsInfo;
begin
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 Info:=Dolphin_DB.RecordsInfoOne(LastFileName,LastIDImage,0,0,0,'','','','','',0,false,false,0,false,false,true,'');
 Viewer.Execute(Sender,Info);
end;

procedure TUpdateDBForm.SetAutoAnswer(Value: integer);
begin
 AddAll1.Checked:=false;
 SkipAll1.Checked:=false;
 None1.Checked:=false;
 ReplaceAll1.Checked:=false;
 Case Value of
  Result_Add_All : AddAll1.Checked:=true;
  Result_Skip_All : SkipAll1.Checked:=true;
  Result_Replace_All : ReplaceAll1.Checked:=true;
  else None1.Checked:=true;
 end;
end;

procedure TUpdateDBForm.SetText(Text: string);
begin
 FilesLabel.Text:=Text;
end;

procedure TUpdateDBForm.ShowForm(Sender: TObject);
begin
 Show;
end;

procedure TUpdateDBForm.SetMaxValue(Value: integer);
begin
 ProgressBar.MaxValue:=Value;
end;

procedure TUpdateDBForm.SetDone(Sender: TObject);
begin
 HideImage(false);
 ProgressBar.Position:=0;
 ProgressBar.Text:=TEXT_MES_DONE;
 FilesLabel.Text:=TEXT_MES_NO_FILE_TO_ADD;
end;

procedure TUpdateDBForm.SetBeginUpdation(Sender: TObject);
begin
 HideImage(false);
 ProgressBar.Position:=0;
 ProgressBar.Text:=TEXT_MES_ADDING_FILE_PR;
 FilesLabel.Text:=TEXT_MES_NOW_FILE;

 if FW7TaskBar <> nil then
   FW7TaskBar.SetProgressState(Handle, TBPF_INDETERMINATE);
end;

procedure TUpdateDBForm.SetTimeText(Text: string);
begin
// TimeLabel.Caption:=Text;
end;

procedure TUpdateDBForm.SetPosition(Value: integer);
begin
  ProgressBar.Position := Value;
  if FW7TaskBar <> nil then
  begin
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
    FW7TaskBar.SetProgressValue(Handle, Value, ProgressBar.MaxValue);
  end;
end;

procedure TUpdateDBForm.SetFileName(FileName: string);
begin
 FilesLabel.Lines.Text:=Mince(FileName,40);
end;

procedure TUpdateDBForm.DoShowImage(Sender: TObject);
begin
 FInfoStr:='';
 ShowImage;
end;

procedure TUpdateDBForm.AddFileSizes(Value: int64);
begin              
 FInfoStr:='';
 TimeCounter.AddActions(Value);
end;

procedure TUpdateDBForm.OnBeginUpdation(Sender: TObject);
begin
 TimeCounter.DoBegin;
end;

procedure TUpdateDBForm.FormPaint(Sender: TObject);
var
  R : TRect;
Const
  DrawTextOpt = DT_NOPREFIX+DT_WORDBREAK;
begin

 Canvas.Pen.Color:=0;
 Canvas.Brush.Color:=0;
 Canvas.MoveTo(0,0);
 Canvas.LineTo(Width-1,0);
 Canvas.LineTo(Width-1,Height-1);
 Canvas.LineTo(0,Height-1);
 Canvas.LineTo(0,0);

 Canvas.Pen.Color:=ClGray;
 Canvas.Brush.Color:=ClGray;

 R.Left:=120;
 R.Top:=24;
 R.Right:=R.Left+273;
 R.Bottom:=R.Top+57;

 Canvas.MoveTo(R.Left-1,R.Top-1);
 Canvas.LineTo(R.Right,R.Top-1);
 Canvas.LineTo(R.Right,R.Bottom);
 Canvas.LineTo(R.Left-1,R.Bottom);
 Canvas.LineTo(R.Left-1,R.Top-1);

 Canvas.Brush.Color:=ClWhite;
 Canvas.Font.Style:=[];

 DrawTextA(Canvas.Handle, PChar(FilesLabel.Text), Length(FilesLabel.Text), R, DrawTextOpt);

 if FCurrentImage<>nil then
 Canvas.Draw(10+50-FCurrentImage.Width div 2,10+50-FCurrentImage.Height div 2,FCurrentImage);

 Canvas.Font.Style:=[fsBold];
 Canvas.TextOut(120,5,TEXT_MES_PROCESSING_STATUS);

 ProgressBar.DoPaintOnXY(Canvas,ProgressBar.Left,ProgressBar.Top);
end;

procedure TUpdateDBForm.SetIcon(Link : TWebLink; Name : String);
var
  Ico : TIcon;
begin
 Ico:=TIcon.Create;
 Ico.Handle:=LoadIcon(DBKernel.IconDllInstance,PChar(Name));
 Link.Icon := Ico;
 Link.Icon := Link.Icon;
 Link.SetDefault;
end;

procedure TUpdateDBForm.LoadToolBarIcons();
begin
 SetIcon(WebLinkOptions,'UPDATER_OPTIONS');
 SetIcon(ButtonRunStop,'UPDATER_PLAY');
 SetIcon(ButtonBreak,'UPDATER_STOP');
 SetIcon(ShowHistoryLink,'UPDATER_HISTORY');
 SetIcon(ButtonClose,'UPDATER_CLOSE');         
 SetIcon(WebLinkOpenImage,'UPDATER_OPEN_IMAGE');
 SetIcon(WebLinkOpenFolder,'UPDATER_OPEN_FOLDER');
end;

procedure TUpdateDBForm.WebLinkOptionsClick(Sender: TObject);
var
  p : TPoint;
begin
 p.X:=WebLinkOptions.Left;
 p.Y:=WebLinkOptions.Top+WebLinkOptions.Height;
 p:=ClientToScreen(p);
 PopupMenu1.Popup(p.X,p.Y);
end;

procedure TUpdateDBForm.Timer1Timer(Sender: TObject);
var
  Bitmap : TBitmap;  
  TextTop, TextLeft, TextWidth, TextHeight : integer;
  Text : string;
begin
 if FCurrentImage=nil then
 begin

  Bitmap:=TBitmap.Create;
  Bitmap.Width:=100;
  Bitmap.Height:=85;
  Bitmap.Canvas.Brush.Color:=clWhite;
  Bitmap.Canvas.Pen.Color:=clWhite;
  Bitmap.Canvas.Rectangle(0,0,100,100);

  if FInfoStr='' then
  begin
   FImage.DolayeredDraw(16*FImagePos,0,255-FImagePosStep,Bitmap);
   if FImagePos>4 then
   FImage.DolayeredDraw(0,0,FImagePosStep,Bitmap) else
   FImage.DolayeredDraw(16*(FImagePos+1),0,FImagePosStep,Bitmap);
  end else
  begin
   Bitmap.Canvas.Font.Name:='Times New Roman';
   Bitmap.Canvas.Font.Size:=8;
   Bitmap.Canvas.Font.Style:=[fsBold];
   Bitmap.Canvas.Brush.Color:=clWhite;
   Text:=FInfoStr;
   TextWidth:=Canvas.TextWidth(Text);
   TextHeight:=Canvas.TextHeight(Text);
   TextLeft:=Bitmap.Width div 2 - TextWidth div 2;
   TextTop:=Bitmap.Height - TextHeight;
   Bitmap.Canvas.TextOut(TextLeft,TextTop,Text);

   FImageInv.DolayeredDraw(16*FImagePos,0,255-FImagePosStep,Bitmap);
   if FImagePos>4 then
   FImageInv.DolayeredDraw(0,0,FImagePosStep,Bitmap) else
   FImageInv.DolayeredDraw(16*(FImagePos+1),0,FImagePosStep,Bitmap);

  end;
  FImageHourGlass.DolayeredDraw(Bitmap.Width div 2 - FImageHourGlass.Width div 2-10,16,150,Bitmap);
  Canvas.Draw(10,FilesLabel.Top,Bitmap);
  Bitmap.free;
 
  inc(FImagePosStep,10);
  if (FImagePosStep>=255) then
  begin
   FImagePosStep:=0;
   inc(FImagePos);
   if FImagePos>5 then FImagePos:=0;
  end;

 end;

end;

procedure TUpdateDBForm.OnDirectorySearch(Owner: TObject; FileName: string;
  Size: int64);
begin
 FullSize:=FullSize+Size;
 FInfoStr:=Format(TEXT_MES_UPDATER_INFO_SIZE_FORMAT,[Dolphin_DB.SizeInTextA(FullSize)]);
end;

procedure TUpdateDBForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

procedure TUpdateDBForm.WebLinkOpenImageClick(Sender: TObject);
begin
 if fCurrentFileName<>'' then
 begin
  if Viewer=nil then Application.CreateForm(TViewer, Viewer);
  Viewer.ExecuteDirectoryWithFileOnThread(fCurrentFileName);
 end;
end;

procedure TUpdateDBForm.WebLinkOpenFolderClick(Sender: TObject);
begin
 if fCurrentFileName<>'' then
 begin
  With ExplorerManager.NewExplorer(False) do
  begin
   SetOldPath(fCurrentFileName);
   SetPath(ExtractFilePath(fCurrentFileName));
   Show;
   SetFocus;
  end;
 end;
end;

procedure TUpdateDBForm.TimerTerminateTimer(Sender: TObject);
begin
 TimerTerminate.Enabled:=false;     
 Close;
 FormManager.UnRegisterMainForm(Self);
end;

initialization

UpdaterDB:=nil;

end.
