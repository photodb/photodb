unit UnitUpdateDB;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Menus,
  ExtCtrls,
  DB,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Graphics.Types,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.DmProgress,
  Dmitry.Controls.SaveWindowPos,
  Dmitry.Controls.TwButton,
  Dmitry.Controls.WebLink,

  UnitHelp,
  uVistaFuncs,
  dolphin_db,
  AppEvnts,
  DragDrop,
  DragDropFile,
  DropSource,
  DropTarget,
  UnitDBKernel,
  UnitDBDeclare,
  uShellIntegration,
  UnitUpdateDBObject,
  uCounters,
  uJpegUtils,
  uBitmapUtils,
  GraphicCrypt,
  jpeg,
  UnitDBCommon,
  uMemory,

  uW7TaskBar,
  uGraphicUtils,
  uDBForm,
  uConstants,
  uAppUtils,
  uDBUtils,
  uDBPopupMenuInfo,
  pngimage,
  uUpdateDBTypes,
  uInterfaceManager,
  uRuntime,
  uThemesUtils,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  DmMemo,
  uFormInterfaces;

type
  TUpdateDBForm = class(TDBForm, IDBUpdaterCallBack)
    PmMain: TPopupActionBar;
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
    AeMain: TApplicationEvents;
    MemInfoCaption: TDmMemo;
    ProgressBar: TDmProgress;
    WebLinkOpenImage: TWebLink;
    WebLinkOpenFolder: TWebLink;
    WlClose: TWebLink;
    ButtonBreak: TWebLink;
    ButtonRunStop: TWebLink;
    ShowHistoryLink: TWebLink;
    WebLinkOptions: TWebLink;
    ImageGo: TImage;
    ImageHourGlass: TImage;
    TmrAnimation: TTimer;
    TwWindowsPos: TTwButton;
    SwpWindow: TSaveWindowPos;
    procedure WlCloseClick(Sender: TObject);
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
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure UseScaningByFilename1Click(Sender: TObject);
    procedure History1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HideImage(OnCreate : boolean);
    procedure ShowImage;
    procedure AeMainMessage(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Image1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure WebLinkOptionsClick(Sender: TObject);
    procedure TmrAnimationTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WebLinkOpenImageClick(Sender: TObject);
    procedure WebLinkOpenFolderClick(Sender: TObject);
    procedure WebLinkOptionsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FImage: TLayeredBitmap;
    FImageInv: TLayeredBitmap;
    FImageHourGlass: TLayeredBitmap;
    FImagePos: Integer;
    FImagePosStep: Integer;
    FCurrentImage: TBitmap;
    FCurrentFileName: string;
    BadHistory: TStrings;
    LastIDImage: Integer;
    LastFileName: string;
    FSpeedCounter: TSpeedEstimateCounter;
    FInfoStr: string;
    FProgressMessage: Cardinal;
    FW7TaskBar: ITaskbarList3;
    FFullSize: Int64;
    FInfoText: string;
    procedure WMMouseDown(var S: TMessage); message WM_LBUTTONDOWN;
  protected
    function GetFormID: string; override;
    procedure LoadLanguage;
  public
    { Public declarations }
    procedure UpdaterSetText(Text: string);
    procedure UpdaterSetMaxValue(Value: Integer);
    procedure UpdaterSetAutoAnswer(Value: Integer);
    procedure UpdaterSetTimeText(Text: string);
    procedure UpdaterSetPosition(Value, Max: Integer);
    procedure UpdaterSetFileName(FileName: string);
    procedure UpdaterAddFileSizes(Value: Int64);
    procedure UpdaterDirectoryAdded(Sender: TObject);
    procedure UpdaterOnDone(Sender: TObject);
    procedure UpdaterShowForm(Sender: TObject);
    procedure UpdaterSetBeginUpdation(Sender: TObject);
    procedure UpdaterShowImage(Sender: TObject);
    procedure UpdaterSetFullSize(Value: Int64);
    procedure UpdaterFoundedEvent(Owner: TObject; FileName: string; Size: Int64);
    function UpdaterGetForm: TDBForm;

    procedure OnBeginUpdation(Sender: TObject);
    procedure LoadToolBarIcons;
    procedure SetIcon(Link: TWebLink; name: string);
  end;

procedure CreateUpdaterForm;

implementation

uses
  FormManegerUnit,
  UnitHistoryForm,
  uManagerExplorer,
  UnitScripts,
  DBScriptFunctions,
  UnitUpdateDBThread;

procedure CreateUpdaterForm;
var
  FForm: TUpdateDBForm;
begin
  Application.CreateForm(TUpdateDBForm, FForm);
end;

{$R *.dfm}

{ TUpdateDBForm }

procedure TUpdateDBForm.WMMouseDown(var S: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCAPTION, S.LParam);
end;

procedure TUpdateDBForm.WlCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TUpdateDBForm.FormCreate(Sender: TObject);
var
  I, J: Integer;
  B: Byte;
  P: PARGB32;
begin
  InterfaceManager.RegisterObject(Self);
  FFullSize := 0;
  DoubleBuffered := True;
  FInfoStr := '';
  FCurrentImage := nil;
  FCurrentFileName := '';
  HideImage(True);
  FSpeedCounter := TSpeedEstimateCounter.Create(10000); // 10 seconds to refresh

  LastIDImage := 0;
  LastFileName := ':::';
  BadHistory := TStringList.Create;
  DropFileTarget1.Register(Self);
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
  LoadLanguage;
  LoadToolBarIcons;
  WlClose.LoadImage;
  WlClose.Left := ClientWidth - WlClose.Width - 5;

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

  SwpWindow.Key := RegRoot + 'UpdateDB';
  SwpWindow.SetPosition;

  FImageHourGlass := TLayeredBitmap.Create;
  AssignGraphic(FImageHourGlass, ImageHourGlass.Picture.Graphic);
  FImageHourGlass.IsLayered := True;

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

procedure TUpdateDBForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Collection Updater');
    FInfoText := L('No files');
    ProgressBar.Text := '';
    ButtonBreak.Text := L('Stop');
    ButtonRunStop.Text := L('Pause');
    WlClose.Text := L('Close');
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
    MemInfoCaption.Text := L('Status') + ':';
  finally
    EndTranslate;
  end;
end;

procedure TUpdateDBForm.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  P: TPoint;
  I: Integer;
  FileSize: Int64;
  B: Boolean;
  W, H: Integer;
  Bit, Bitmap: TBitmap;

  procedure FillRectToBitmapA(Bitmap: TBitmap);
  begin
    Bitmap.Canvas.Pen.Color := 0;
    Bitmap.Canvas.Brush.Color := MakeDarken(Theme.WindowColor, 0.9);
    Bitmap.Canvas.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    Bitmap.Canvas.Pen.Color := Theme.WindowColor;
  end;

begin
  if DBTerminating then
    Exit;

  if (EventID_CancelAddingImage in Params) then
  begin
    FileSize := GetFileSizeByName(Value.name);
    FSpeedCounter.AddSpeedInterval(FileSize);

    ProgressBar.Text := Format(L('Tile left - %s (&%%%%)'), [TimeIntervalInString(FSpeedCounter.GetTimeRemaining(UpdaterDB.GetSize))]);
    FCurrentFileName := Value.name;
    Invalidate;
  end;
  if (SetNewIDFileData in Params) or (EventID_FileProcessed in Params) then
  begin
    LastFileName := Value.name;
    LastIDImage := ID;
    Bit := TBitmap.Create;
    try
      Bit.PixelFormat := pf24bit;
      AssignJpeg(Bit, Value.JPEGImage);
      ApplyRotate(Bit, Value.Rotate);
      Bitmap := TBitmap.Create;
      try
        Bitmap.PixelFormat := Pf24bit;
        W := Bit.Width;
        H := Bit.Height;
        ProportionalSize(100, 100, W, H);
        DoResize(W, H, Bit, Bitmap);

        F(FCurrentImage);
        FCurrentImage := Bitmap;
        Bitmap := nil;
        Repaint;
      finally
        F(Bitmap);
      end;
    finally
      F(Bit);
    end;
    FileSize := GetFileSizeByName(Value.name);
    FSpeedCounter.AddSpeedInterval(FileSize);

    ProgressBar.Text := Format(L('Tile left - %s (&%%%%)'), [FormatDateTime('hh:mm:ss', FSpeedCounter.GetTimeRemaining(UpdaterDB.GetSize))]);
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
      Close;
      Exit;
    end;
  end;
  WebLinkOpenImage.Enabled := False;
  WebLinkOpenImage.RefreshBuffer;
  WebLinkOpenImage.Repaint;
  WebLinkOpenFolder.Enabled := False;
  WebLinkOpenFolder.RefreshBuffer;
  WebLinkOpenFolder.Repaint;
  FCurrentFileName := '';
  F(FCurrentImage);
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
  UpdaterDB.Auto := Auto1.Checked;
end;

procedure TUpdateDBForm.None1Click(Sender: TObject);
begin
  UpdaterDB.AutoAnswer := Result_invalid;
end;

procedure TUpdateDBForm.ReplaceAll1Click(Sender: TObject);
begin
  UpdaterDB.AutoAnswer := Result_replace_All;
end;

procedure TUpdateDBForm.AddAll1Click(Sender: TObject);
begin
  UpdaterDB.AutoAnswer := Result_add_all;
end;

procedure TUpdateDBForm.SkipAll1Click(Sender: TObject);
begin
  UpdaterDB.AutoAnswer := Result_skip_all;
end;

procedure TUpdateDBForm.ButtonRunStopClick(Sender: TObject);
begin
  if UpdaterDB.Pause then
  begin
    UpdaterDB.DoUnPause;
    SetIcon(ButtonRunStop, 'UPDATER_PAUSE');
    ButtonRunStop.Text := L('Pause');
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
  end else
  begin
    UpdaterDB.DoPause;
    SetIcon(ButtonRunStop, 'UPDATER_PLAY');
    ButtonRunStop.Text := L('Run');
    if FW7TaskBar <> nil then
      FW7TaskBar.SetProgressState(Handle, TBPF_PAUSED);
  end;
end;

procedure TUpdateDBForm.ButtonBreakClick(Sender: TObject);
begin
  UpdaterDB.DoTerminate;
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
      UpdaterDB.AddDirectory((DropFileTarget1.Files[I]));

    UpdaterDB.Execute;
  end;
end;

procedure TUpdateDBForm.FormDestroy(Sender: TObject);
begin
  SwpWindow.SavePosition;

  InterfaceManager.UnRegisterObject(Self);

  F(FImage);
  F(FImageInv);
  F(FImageHourGlass);
  F(FCurrentImage);

  F(FSpeedCounter);
  F(BadHistory);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
  DropFileTarget1.Unregister;
end;

procedure TUpdateDBForm.UseScaningByFilename1Click(Sender: TObject);
begin
  UseScaningByFilename1.Checked := not UseScaningByFilename1.Checked;
  UpdaterDB.UseFileNameScaning := UseScaningByFilename1.Checked;
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
    UpdaterDB.DoTerminate;
  //do not free this form, it owned by update object
  //TODO: check how application terminating when this form is last
end;

procedure TUpdateDBForm.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
const
  SC_DragMove = $F012;
begin
  if Msg.Message = FProgressMessage then
    FW7TaskBar := CreateTaskBarInstance;

  if (Msg.Message = WM_LBUTTONDOWN) then
  begin
    if (Msg.hwnd = MemInfoCaption.Handle)
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
  Info := TDBPopupMenuInfo.Create;
  try
    InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(LastFileName);
    try
      InfoItem.ID := LastIDImage;
      info.Add(InfoItem);
      Viewer.ShowImages(Sender, Info);
      Viewer.Show;
    finally
      F(InfoItem);
    end;
  finally
    F(Info);
  end;
end;

procedure TUpdateDBForm.UpdaterSetAutoAnswer(Value: Integer);
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

procedure TUpdateDBForm.UpdaterSetText(Text: string);
begin
  FInfoText := Text;
  Invalidate;
end;

procedure TUpdateDBForm.UpdaterShowForm(Sender: TObject);
begin
  Show;
end;

procedure TUpdateDBForm.UpdaterSetMaxValue(Value: integer);
begin
  ButtonBreak.Enabled := True;
  ButtonRunStop.Enabled := True;
  ProgressBar.MaxValue := Value;
  Invalidate;
end;

procedure TUpdateDBForm.UpdaterOnDone(Sender: TObject);
begin
  HideImage(False);
  FSpeedCounter.Reset;
  FFullSize := 0;
  ProgressBar.Position := 0;
  ProgressBar.Text := L('Done');
  FInfoText := L('No files to add');
  SetIcon(ButtonRunStop, 'UPDATER_PAUSE');
  ButtonRunStop.Text := L('Pause');
  ButtonBreak.Enabled := False;
  ButtonRunStop.Enabled := False;
  Invalidate;
end;

procedure TUpdateDBForm.UpdaterSetBeginUpdation(Sender: TObject);
begin
  ButtonBreak.Enabled := True;
  ButtonRunStop.Enabled := True;

  HideImage(False);
  ProgressBar.Position := 0;
  ProgressBar.Text := L('Processing files... (&%%)');
  FInfoText := L('<current file>');

  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressState(Handle, TBPF_INDETERMINATE);
end;

procedure TUpdateDBForm.UpdaterSetTimeText(Text: string);
begin
end;

procedure TUpdateDBForm.UpdaterSetPosition(Value, Max: Integer);
begin
  ProgressBar.Position := Value;
  ProgressBar.MaxValue := Max;
  if FW7TaskBar <> nil then
  begin
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
    FW7TaskBar.SetProgressValue(Handle, Value, Max);
  end;
end;

procedure TUpdateDBForm.UpdaterSetFileName(FileName: string);
begin
  FInfoText := Mince(FileName, 40);
end;

procedure TUpdateDBForm.UpdaterSetFullSize(Value: Int64);
begin
  FFullSize := Value;
end;

procedure TUpdateDBForm.UpdaterShowImage(Sender: TObject);
begin
  FInfoStr := '';
  ShowImage;
end;

procedure TUpdateDBForm.UpdaterAddFileSizes(Value: Int64);
begin
  FInfoStr := '';
end;

procedure TUpdateDBForm.UpdaterDirectoryAdded(Sender: TObject);
begin
  //isn't used
end;

function TUpdateDBForm.UpdaterGetForm: TDBForm;
begin
  Result := Self;
end;

procedure TUpdateDBForm.OnBeginUpdation(Sender: TObject);
begin
  FSpeedCounter.Reset;
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

  Canvas.Font.Color := Theme.WindowTextColor;
  Canvas.Brush.Color := Theme.WindowColor;
  Canvas.Font.Style := [];

  DrawText(Canvas.Handle, PChar(FInfoText), Length(FInfoText), R, DrawTextOpt);

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
  Ico: HIcon;
begin
  Ico := LoadImage(HInstance, PWideChar(Name), IMAGE_ICON, 16, 16, 0);
  try
    Link.LoadFromHIcon(Ico);
  finally
    DestroyIcon(Ico);
  end;
end;

procedure TUpdateDBForm.LoadToolBarIcons;
begin
  SetIcon(WebLinkOptions, 'UPDATER_OPTIONS');
  SetIcon(ButtonRunStop, 'UPDATER_PAUSE');
  SetIcon(ButtonBreak, 'UPDATER_STOP');
  SetIcon(ShowHistoryLink, 'UPDATER_HISTORY');
  SetIcon(WlClose, 'UPDATER_CLOSE');
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
  PmMain.Popup(P.X, P.Y);
end;

procedure TUpdateDBForm.WebLinkOptionsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    WebLinkOptionsClick(Sender);
end;

procedure TUpdateDBForm.TmrAnimationTimer(Sender: TObject);
var
  Bitmap: TBitmap;
  TextTop, TextLeft, TextWidth, TextHeight: Integer;
  Text: string;
begin
  if (FCurrentImage = nil) and Visible then
  begin

    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := 100;
      Bitmap.Height := 85;
      Bitmap.Canvas.Brush.Color := Theme.WindowColor;
      Bitmap.Canvas.Pen.Color := Theme.WindowColor;
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
        Bitmap.Canvas.Font.Name := 'Times New Roman';
        Bitmap.Canvas.Font.Size := 8;
        Bitmap.Canvas.Font.Style := [FsBold];
        Bitmap.Canvas.Font.Color := Theme.WindowTextColor;
        Bitmap.Canvas.Brush.Color := Theme.WindowColor;
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
      Canvas.Draw(10, MemInfoCaption.Top + MemInfoCaption.Height + 3, Bitmap);
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

procedure TUpdateDBForm.UpdaterFoundedEvent(Owner: TObject; FileName: string; Size: int64);
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
    Viewer.ShowImageInDirectoryEx(FCurrentFileName);
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

end.
