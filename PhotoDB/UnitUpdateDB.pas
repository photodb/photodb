unit UnitUpdateDB;

interface

uses
   dolphin_db, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
   Forms, Dialogs, StdCtrls, DmProgress, Menus, ExtCtrls, UnitHelp,
   uVistaFuncs, DB, AppEvnts, DragDrop, DragDropFile, WebLink,
   DropSource, DropTarget, UnitDBkernel, UnitDBDeclare, uShellIntegration,
   UnitUpdateDBObject, UnitTimeCounter, UnitDBCommonGraphics, DmMemo,
   GraphicCrypt, jpeg, TLayered_Bitmap, UnitDBCommon, uMemory, uFileUtils,
   uW7TaskBar, GraphicsBaseTypes, TwButton, uGraphicUtils, uDBForm,
   uConstants, uAppUtils, uDBUtils, uDBPopupMenuInfo;

type
  TUpdateDBForm = class(TDBForm)
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
    TwWindowsPos: TTwButton;
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
    { Private declarations }
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
    LastFileName : string;
    TimeCounter: TTimeCounter;
    FInfoStr : string;
    FProgressMessage : Cardinal;
    FW7TaskBar : ITaskbarList3;
    FFullSize: Int64;
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
  protected
    function GetFormID : string; override;
    procedure LoadLanguage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AddObject: TUpdaterDB); reintroduce;
    procedure SetAutoAnswer(Value: Integer);
    procedure SetText(Text: string);
    procedure ShowForm(Sender: TObject);
    procedure SetMaxValue(Value: Integer);
    procedure SetDone(Sender: TObject);
    procedure SetBeginUpdation(Sender: TObject);
    procedure SetTimeText(Text: string);
    procedure SetPosition(Value: Integer);
    procedure SetFileName(FileName: string);
    procedure DoShowImage(Sender: TObject);
    procedure AddFileSizes(Value: Int64);
    procedure OnBeginUpdation(Sender: TObject);
    procedure LoadToolBarIcons;
    procedure SetIcon(Link: TWebLink; name: string);
    procedure OnDirectorySearch(Owner: TObject; FileName: string; Size: Int64);
    property FullSize : Int64 read FFullSize write FFullSize;
  end;

var
  UpdaterDB : TUpdaterDB;

implementation

uses FormManegerUnit, UnitHistoryForm,
  ExplorerUnit, SlideShow, UnitScripts, DBScriptFunctions,
  UnitUpdateDBThread;

{$R *.dfm}

{ TUpdateDBForm }

 procedure TUpdateDBForm.WMMouseDown(var S: Tmessage);
 begin
   Perform(WM_NCLButtonDown, HTcaption, S.Lparam);
 end;

 procedure TUpdateDBForm.ButtonCloseClick(Sender: TObject);
 begin
   Close;
 end;

procedure TUpdateDBForm.FormCreate(Sender: TObject);
var
  I, J: Integer;
  B: Byte;
  P: PARGB32;
begin
  FFullSize := 0;
  DoubleBuffered := True;
  FInfoStr := '';
  FCurrentImage := nil;
  FCurrentFileName := '';
  HideImage(True);
  TimeCounter := TTimeCounter.Create;
  TimeCounter.TimerInterval := 10000; // 10 seconds to refresh
  LastIDImage := 0;
  LastFileName := ':::';
  BadHistory := TStringList.Create;
  DropFileTarget1.Register(Self);
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  LoadLanguage;
  LoadToolBarIcons;
  ButtonClose.Left := ClientWidth - ButtonClose.Width - 5;

  FImagePos := 0;
  FImagePosStep := 1;
  FImage := TLayeredBitmap.Create;
  FImage.LoadFromHIcon(ImageGo.Picture.Icon.Handle);

  FImageInv := TLayeredBitmap.Create;
  FImageInv.LoadFromHIcon(ImageGo.Picture.Icon.Handle);

  for I := 0 to FImageInv.Height - 1 do
  begin
    P := FImageInv.ScanLine[I];
    for J := 0 to FImageInv.Width - 1 do
    begin
      B := P[J].R;
      P[J].R := P[J].B;
      P[J].B := B;
    end;
  end;

  FImageHourGlass:= TLayeredBitmap.Create;
  FImageHourGlass.LoadFromHIcon(ImageHourGlass.Picture.Icon.Handle, 48, 48);

  FProgressMessage := RegisterWindowMessage('SLIDE_SHOW_PROGRESS');
  PostMessage(Handle, FProgressMessage, 0, 0);
end;

procedure TUpdateDBForm.Stayontop1Click(Sender: TObject);
begin
  Stayontop1.Checked := not Stayontop1.Checked;
  if not Stayontop1.Checked then
    FormStyle := FsNormal
  else
    FormStyle := FsStayOnTop;
end;

constructor TUpdateDBForm.Create(AOwner: TComponent;
  AddObject: TUpdaterDB);
begin
  inherited Create(AOwner);
  FAddObject := AddObject;
end;

procedure TUpdateDBForm.SetAddObject(AddObject: TUpdaterDB);
begin
  FAddObject := AddObject;
end;

procedure TUpdateDBForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Collection Updater');
    FilesLabel.Text := L('No files');
    ProgressBar.Text := '';
    ButtonBreak.Text := L('Stop');
    ButtonRunStop.Text := L('Pause');
    ButtonClose.Text := L('Close');
    ProgressBar.Text := L('Progress... (&%%)');
    Stayontop1.Caption := L('Stay on top');
    Layered1.Caption := L('Transparency');
    Fill1.Caption := L('No');
    Hide1.Caption := L('Hide');
    Auto1.Caption := L('Auto');
    AutoAnswer1.Caption := L('Auto answer');
    None1.Caption := L('None');
    ReplaceAll1.Caption := L('Replace all');
    AddAll1.Caption := L('Add all');
    SkipAll1.Caption := L('Skip all');
    History1.Caption := L('History');
    UseScaningByFilename1.Caption := L('Detailed search if file name already exists');

    ShowHistoryLink.Text := L('Show history');
    WebLinkOptions.Text := L('Options');
    WebLinkOpenImage.Text := L('Open');
    WebLinkOpenFolder.Text := L('Explorer');
    DmMemo1.Text := L('Status') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TUpdateDBForm.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  P: TPoint;
  I, FileSize: Integer;
  B: Boolean;
  W, H: Integer;
  Bit, Bitmap: TBitmap;

  procedure FillRectToBitmapA(Bitmap: TBitmap);
  begin
    Bitmap.Canvas.Pen.Color := 0;
    Bitmap.Canvas.Brush.Color := MakeDarken(clWindow, 0.9);
    Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    Bitmap.Canvas.Pen.Color := clWindow;
  end;

begin

  if (SetNewIDFileData in Params) or (EventID_FileProcessed in Params) then
  begin
    LastFileName := Value.name;
    LastIDImage := ID;
    Bit := TBitmap.Create;
    try
      Bit.PixelFormat := Pf24bit;
      Bit.Assign(Value.JPEGImage);
      Bitmap := TBitmap.Create;
      try
        Bitmap.PixelFormat := Pf24bit;
        W := Bit.Width;
        H := Bit.Height;
        ProportionalSize(100, 100, W, H);
        DoResize(W, H, Bit, Bitmap);

        FCurrentImage := TBitmap.Create;
        FCurrentImage.Assign(Bitmap);
        Repaint;
      finally
        F(Bitmap);
      end;
    finally
      F(Bit);
    end;
    FileSize := GetFileSizeByName(Value.name);
    TimeCounter.NextAction(FileSize);

    ProgressBar.Text := Format(L('Tile left - %s (&%%%%)'), [FormatDateTime('hh:mm:ss', TimeCounter.GetTimeRemaining)]);
    FCurrentFileName := Value.name;
    WebLinkOpenImage.Enabled := True;
    WebLinkOpenImage.RefreshBuffer;
    WebLinkOpenImage.Repaint;
    WebLinkOpenFolder.Enabled := True;
    WebLinkOpenFolder.RefreshBuffer;
    WebLinkOpenFolder.Repaint;
    Exit;
  end;

  if EventID_Param_Add_Crypt_WithoutPass in Params then
  begin
    B := True;
    Value.name := AnsiLowerCase(Value.name);
    for I := 0 to BadHistory.Count - 1 do
      if AnsiLowerCase(BadHistory[I]) = Value.name then
      begin
        B := False;
        Break;
      end;
    if B then
      BadHistory.Add(Value.name);
    if not CryptFileWithoutPassChecked then
    begin
      Show;
      Delay(100);
      DoHelpHint(L('Warning'), L( 'Unable to add to collection one or more files. Choose "History" in context menu for details.'), P, Self);
    end;
  end;
end;

procedure TUpdateDBForm.HideImage(OnCreate : boolean);
begin
  if not WebLinkOpenImage.Enabled and not WebLinkOpenFolder.Enabled then
    Exit;
  if not OnCreate then
  begin
    if GetParamStrDBBool('/NoFullRun') then
    begin
      TimerTerminate.Enabled := True;
      Exit;
    end;
  end;
  WebLinkOpenImage.Enabled := False;
  WebLinkOpenImage.RefreshBuffer;
  WebLinkOpenImage.Repaint;
  WebLinkOpenFolder.Enabled := False;
  WebLinkOpenFolder.RefreshBuffer;
  WebLinkOpenFolder.Repaint;
  FCurrentImage.Free;
  FCurrentFileName := '';
  FCurrentImage := nil;
  ProgressBar.Position := 0;
  ProgressBar.Text := L('Done');
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
var
  S: string;
  N: Integer;
begin
  S := (Sender as TMenuItem).Caption;
  S := Copy(S, 2, 2);
  N := StrToIntDef(S, 0);
  AlphaBlendValue := Round(255 - 255 * N / 100);
end;

procedure TUpdateDBForm.Auto1Click(Sender: TObject);
begin
  Auto1.Checked := not Auto1.Checked;
  FAddObject.Auto := Auto1.Checked;
end;

procedure TUpdateDBForm.None1Click(Sender: TObject);
begin
  FAddObject.AutoAnswer := Result_invalid;
end;

procedure TUpdateDBForm.ReplaceAll1Click(Sender: TObject);
begin
  FAddObject.AutoAnswer := Result_replace_All;
end;

procedure TUpdateDBForm.AddAll1Click(Sender: TObject);
begin
  FAddObject.AutoAnswer := Result_add_all;
end;

procedure TUpdateDBForm.SkipAll1Click(Sender: TObject);
begin
  FAddObject.AutoAnswer := Result_skip_all;
end;

procedure TUpdateDBForm.ButtonRunStopClick(Sender: TObject);
begin
  if FAddObject.Pause then
  begin
    FAddObject.DoUnPause;
    SetIcon(ButtonRunStop, 'UPDATER_PAUSE');
    ButtonRunStop.Text := L('Pause');
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
  end else
  begin
    // TODO icon
    FAddObject.DoPause;
    SetIcon(ButtonRunStop, 'UPDATER_PLAY');
    ButtonRunStop.Text := L('Run');
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_PAUSED);
  end;
end;

procedure TUpdateDBForm.ButtonBreakClick(Sender: TObject);
begin
  FAddObject.DoTerminate;
end;

procedure TUpdateDBForm.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  I: Integer;
begin
  for I := 0 to DropFileTarget1.Files.Count - 1 do
  begin
    FInfoStr := '';
    if FileExistsSafe((DropFileTarget1.Files[I])) then
      UpdaterDB.AddFile((DropFileTarget1.Files[I]));

    if DirectoryExistsSafe((DropFileTarget1.Files[I])) then
      UpdaterDB.AddDirectory((DropFileTarget1.Files[I]), OnDirectorySearch);

    UpdaterDB.Execute;
  end;
end;

procedure TUpdateDBForm.FormDestroy(Sender: TObject);
begin
  F(FImage);
  F(FImageInv);
  F(FImageHourGlass);

  UpdaterDB.SaveWork;
  F(TimeCounter);
  F(BadHistory);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  DropFileTarget1.Unregister;
end;

procedure TUpdateDBForm.UseScaningByFilename1Click(Sender: TObject);
begin
  UseScaningByFilename1.Checked := not UseScaningByFilename1.Checked;
  FAddObject.UseFileNameScaning := UseScaningByFilename1.Checked;
end;

procedure TUpdateDBForm.History1Click(Sender: TObject);
begin
// BadHistory.Add('D:\Projects\VBToC#Replacer_1_2\VBToC#Replacer\Projects');
// BadHistory.Add('j:\autoexec.bat');
  if BadHistory.Count = 0 then
  begin
    MessageBoxDB(Handle, L('History is empty!'), L('Warning'), TD_BUTTON_OK, TD_ICON_INFORMATION);
    Exit;
  end;
  ShowHistory(BadHistory);
end;

procedure TUpdateDBForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FormManager.IsMainForms(Self) and (FormManager.MainFormsCount = 1) then
    FAddObject.DoTerminate;

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
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  Info := TDBPopupMenuInfo.Create;
  try
    InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(LastFileName);
    try
      InfoItem.ID := LastIDImage;
      info.Add(InfoItem);
      Viewer.Execute(Sender, Info);
      Viewer.Show;
    finally
      F(InfoItem);
    end;
  finally
    F(Info);
  end;
end;

procedure TUpdateDBForm.SetAutoAnswer(Value: Integer);
begin
  AddAll1.Checked := False;
  SkipAll1.Checked := False;
  None1.Checked := False;
  ReplaceAll1.Checked := False;
  case Value of
    Result_Add_All:
      AddAll1.Checked := True;
    Result_Skip_All:
      SkipAll1.Checked := True;
    Result_Replace_All:
      ReplaceAll1.Checked := True;
  else
    None1.Checked := True;
  end;
end;

procedure TUpdateDBForm.SetText(Text: string);
begin
  FilesLabel.Text := Text;
end;

procedure TUpdateDBForm.ShowForm(Sender: TObject);
begin
  Show;
end;

procedure TUpdateDBForm.SetMaxValue(Value: integer);
begin
  ProgressBar.MaxValue := Value;
end;

procedure TUpdateDBForm.SetDone(Sender: TObject);
begin
  HideImage(False);
  ProgressBar.Position := 0;
  ProgressBar.Text := L('Done');
  FilesLabel.Text := L('No files to add');
end;

procedure TUpdateDBForm.SetBeginUpdation(Sender: TObject);
begin
  HideImage(False);
  ProgressBar.Position := 0;
  ProgressBar.Text := L('Processing files... (&%%)');
  FilesLabel.Text := L('<current file>');

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
  FilesLabel.Lines.Text := Mince(FileName, 40);
end;

procedure TUpdateDBForm.DoShowImage(Sender: TObject);
begin
  FInfoStr := '';
  ShowImage;
end;

procedure TUpdateDBForm.AddFileSizes(Value: int64);
begin
  FInfoStr := '';
  TimeCounter.AddActions(Value);
end;

procedure TUpdateDBForm.OnBeginUpdation(Sender: TObject);
begin
  TimeCounter.DoBegin;
end;

procedure TUpdateDBForm.FormPaint(Sender: TObject);
var
  R: TRect;

const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK;

begin

  Canvas.Pen.Color := 0;
  Canvas.Brush.Color := 0;
  Canvas.MoveTo(0, 0);
  Canvas.LineTo(Width - 1, 0);
  Canvas.LineTo(Width - 1, Height - 1);
  Canvas.LineTo(0, Height - 1);
  Canvas.LineTo(0, 0);

  Canvas.Pen.Color := ClGray;
  Canvas.Brush.Color := ClGray;

  R.Left := 120;
  R.Top := 24;
  R.Right := R.Left + 273;
  R.Bottom := R.Top + 57;

  Canvas.MoveTo(R.Left - 1, R.Top - 1);
  Canvas.LineTo(R.Right, R.Top - 1);
  Canvas.LineTo(R.Right, R.Bottom);
  Canvas.LineTo(R.Left - 1, R.Bottom);
  Canvas.LineTo(R.Left - 1, R.Top - 1);

  Canvas.Brush.Color := ClWhite;
  Canvas.Font.Style := [];

  DrawText(Canvas.Handle, PChar(FilesLabel.Text), Length(FilesLabel.Text), R, DrawTextOpt);

  if FCurrentImage <> nil then
    Canvas.Draw(10 + 50 - FCurrentImage.Width div 2, 10 + 50 - FCurrentImage.Height div 2, FCurrentImage);

  Canvas.Font.Style := [FsBold];
  Canvas.TextOut(120, 5, L('Progress status') + ':');

  ProgressBar.DoPaintOnXY(Canvas, ProgressBar.Left, ProgressBar.Top);
end;

function TUpdateDBForm.GetFormID: string;
begin
  Result := 'Updater';
end;

procedure TUpdateDBForm.SetIcon(Link : TWebLink; Name : String);
var
  Ico : HIcon;
begin
  Ico := LoadIcon(DBKernel.IconDllInstance, PWideChar(Name));
  try
    Link.LoadFromHIcon(Ico);
  finally
    DestroyIcon(Ico);
  end;
end;

procedure TUpdateDBForm.LoadToolBarIcons;
begin
  SetIcon(WebLinkOptions, 'UPDATER_OPTIONS');
  SetIcon(ButtonRunStop, 'UPDATER_PLAY');
  SetIcon(ButtonBreak, 'UPDATER_STOP');
  SetIcon(ShowHistoryLink, 'UPDATER_HISTORY');
  SetIcon(ButtonClose, 'UPDATER_CLOSE');
  SetIcon(WebLinkOpenImage, 'UPDATER_OPEN_IMAGE');
  SetIcon(WebLinkOpenFolder, 'UPDATER_OPEN_FOLDER');
end;

procedure TUpdateDBForm.WebLinkOptionsClick(Sender: TObject);
var
  P: TPoint;
begin
  P.X := WebLinkOptions.Left;
  P.Y := WebLinkOptions.Top + WebLinkOptions.Height;
  P := ClientToScreen(P);
  PopupMenu1.Popup(P.X, P.Y);
end;

procedure TUpdateDBForm.Timer1Timer(Sender: TObject);
var
  Bitmap: TBitmap;
  TextTop, TextLeft, TextWidth, TextHeight: Integer;
  Text: string;
begin
  if FCurrentImage = nil then
  begin

    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := 100;
      Bitmap.Height := 85;
      Bitmap.Canvas.Brush.Color := ClWhite;
      Bitmap.Canvas.Pen.Color := ClWhite;
      Bitmap.Canvas.Rectangle(0, 0, 100, 100);

      if FInfoStr = '' then
      begin
        FImage.DolayeredDraw(16 * FImagePos, 0, 255 - FImagePosStep, Bitmap);
        if FImagePos > 4 then
          FImage.DolayeredDraw(0, 0, FImagePosStep, Bitmap)
        else
          FImage.DolayeredDraw(16 * (FImagePos + 1), 0, FImagePosStep, Bitmap);
      end else
      begin
        Bitmap.Canvas.Font.name := 'Times New Roman';
        Bitmap.Canvas.Font.Size := 8;
        Bitmap.Canvas.Font.Style := [FsBold];
        Bitmap.Canvas.Brush.Color := ClWhite;
        Text := FInfoStr;
        TextWidth := Canvas.TextWidth(Text);
        TextHeight := Canvas.TextHeight(Text);
        TextLeft := Bitmap.Width div 2 - TextWidth div 2;
        TextTop := Bitmap.Height - TextHeight;
        Bitmap.Canvas.TextOut(TextLeft, TextTop, Text);

        FImageInv.DolayeredDraw(16 * FImagePos, 0, 255 - FImagePosStep, Bitmap);
        if FImagePos > 4 then
          FImageInv.DolayeredDraw(0, 0, FImagePosStep, Bitmap)
        else
          FImageInv.DolayeredDraw(16 * (FImagePos + 1), 0, FImagePosStep, Bitmap);

      end;
      FImageHourGlass.DolayeredDraw(Bitmap.Width div 2 - FImageHourGlass.Width div 2 - 10, 16, 150, Bitmap);
      Canvas.Draw(10, FilesLabel.Top, Bitmap);
    finally
      F(Bitmap);
    end;

    Inc(FImagePosStep, 10);
    if (FImagePosStep >= 255) then
    begin
      FImagePosStep := 0;
      Inc(FImagePos);
      if FImagePos > 5 then
        FImagePos := 0;
    end;
  end;
end;

procedure TUpdateDBForm.OnDirectorySearch(Owner: TObject; FileName: string;
  Size: int64);
begin
  FFullSize := FFullSize + Size;
  FInfoStr := Format(L('Reading [%s]'), [SizeInText(FFullSize)]);
end;

procedure TUpdateDBForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

procedure TUpdateDBForm.WebLinkOpenImageClick(Sender: TObject);
begin
  if FCurrentFileName <> '' then
  begin
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    Viewer.ExecuteDirectoryWithFileOnThread(FCurrentFileName);
    Viewer.Show;
  end;
end;

procedure TUpdateDBForm.WebLinkOpenFolderClick(Sender: TObject);
begin
  if FCurrentFileName <> '' then
  begin
    with ExplorerManager.NewExplorer(False) do
    begin
      SetOldPath(FCurrentFileName);
      SetPath(ExtractFilePath(FCurrentFileName));
      Show;
      SetFocus;
    end;
  end;
end;

procedure TUpdateDBForm.TimerTerminateTimer(Sender: TObject);
begin
  TimerTerminate.Enabled := False;
  FormManager.UnRegisterMainForm(Self);
  Close;
end;

initialization

  UpdaterDB := nil;

finalization

  F(UpdaterDB);

end.
