unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ExtCtrls, Dialogs, ExtDlgs, ActnList, Menus, ComCtrls,
  ScrollingImage, TexturePanel;

type
  TMainForm = class(TForm)
    SI: TSBScrollingImage;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    View1: TMenuItem;
    ActionList: TActionList;
    FileOpen: TAction;
    ViewScrollBars: TAction;
    StatusBar: TStatusBar;
    OpenPictureDialog: TOpenPictureDialog;
    FileOpen1: TMenuItem;
    ViewNavigator: TAction;
    ViewNavigator1: TMenuItem;
    ViewCanScroll: TAction;
    N1: TMenuItem;
    EnableDisableScroll1: TMenuItem;
    ViewAutoCenter: TAction;
    ShowHideScrollBars1: TMenuItem;
    AutoCenter1: TMenuItem;
    ViewIncrementalDisplay: TAction;
    N2: TMenuItem;
    IncrementalDisplay1: TMenuItem;
    Help1: TMenuItem;
    HelpAbout: TAction;
    HelpAbout1: TMenuItem;
    pnlOptions: TPanel;
    Splitter: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ViewOptions: TAction;
    ViewOptions1: TMenuItem;
    btnNavInOptions: TSpeedButton;
    Label2: TLabel;
    Bevel1: TBevel;
    Edit1: TEdit;
    udScale: TUpDown;
    cbAutoShrink: TCheckBox;
    Label3: TLabel;
    CheckBox6: TCheckBox;
    ViewCanScrollWithMouse: TAction;
    NEWEnableDisableScrollWithMouse1: TMenuItem;
    TexturePanel: TTexturePanel;
    ViewTransparent: TAction;
    NE1: TMenuItem;
    cbAutoZoom: TCheckBox;
    mnuZoom: TMenuItem;
    ScrollBox1: TScrollBox;
    cbStretchMethod: TComboBox;
    Label4: TLabel;
    procedure ViewScrollBarsExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure FileOpenExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ViewCanScrollExecute(Sender: TObject);
    procedure ViewNavigatorExecute(Sender: TObject);
    procedure SIChangeImage(Sender: TObject);
    procedure ViewAutoCenterExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ViewIncrementalDisplayExecute(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure ViewOptionsExecute(Sender: TObject);
    procedure btnNavInOptionsClick(Sender: TObject);
    procedure udScaleClick(Sender: TObject; Button: TUDBtnType);
    procedure SIChangePos(Sender: TObject);
    procedure SIMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAutoShrinkClick(Sender: TObject);
    procedure ViewCanScrollWithMouseExecute(Sender: TObject);
    procedure ViewTransparentExecute(Sender: TObject);
    procedure cbAutoZoomClick(Sender: TObject);
    procedure SIZoomChanged(Sender: TObject);
    procedure cbStretchMethodChange(Sender: TObject);
  private
    procedure OnImageProgress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses JPEG, Navig;

procedure TMainForm.FormCreate(Sender: TObject);
var
  AppPath, S: string;
begin
  AppPath := ExtractFilePath(Application.ExeName);

  S := ExtractFilePath(ExcludeTrailingBackSlash(AppPath));
  OpenPictureDialog.InitialDir := S;

  S := S + 'Default.bmp';
  if FileExists(S) then SI.Picture.LoadFromFile(S);

  SIZoomChanged(Sender);

  cbStretchMethod.ItemIndex := SI.StretchMode - 1;
end;

procedure TMainForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Action = ViewNavigator then
    ViewNavigator.Checked := NavigatorForm.Visible;
  if Action = ViewScrollBars then
    ViewScrollBars.Checked := SI.ScrollBarsVisible;
 if Action = ViewCanScroll then
    ViewCanScroll.Checked := SI.CanScroll;
  if Action = ViewAutoCenter then
    ViewAutoCenter.Checked := SI.AutoCenter;
  if Action = ViewCanScrollWithMouse then
    ViewCanScrollWithMouse.Checked := SI.CanScrollWithMouse;
  if Action = ViewTransparent then
    ViewTransparent.Checked := SI.Transparent;
end;

procedure TMainForm.ViewScrollBarsExecute(Sender: TObject);
begin
  SI.ScrollBarsVisible := not SI.ScrollBarsVisible;
end;

procedure TMainForm.ViewCanScrollExecute(Sender: TObject);
begin
  SI.CanScroll := not SI.CanScroll;
end;

procedure TMainForm.ViewNavigatorExecute(Sender: TObject);
begin
  NavigatorForm.Visible := not NavigatorForm.Visible;
end;

procedure TMainForm.ViewAutoCenterExecute(Sender: TObject);
begin
  SI.AutoCenter := not SI.AutoCenter;
end;

procedure TMainForm.ViewIncrementalDisplayExecute(Sender: TObject);
begin
  with ViewIncrementalDisplay do
  begin
    Checked := not Checked;
    if Checked then
      Application.MessageBox('Some pictures may not support incremental display and program may hang.', 'Warning!!!', MB_ICONWARNING);
  end;
end;

procedure TMainForm.FileOpenExecute(Sender: TObject);
var
  Picture: TPicture;
  BMP: TBitmap;
begin
  with OpenPictureDialog do
    if Execute then
    begin
      if AnsiLowerCase(ExtractFileExt(FileName)) <> '.bmp' then
      begin
        // Экспериментальный код для инкрементальной загрузки изображений.
        //
        // Должен загружать графику любого типа, которая
        // установлена в среде Delphi.
        if ViewIncrementalDisplay.Checked then
        begin
          Picture := TPicture.Create;
          try
            Picture.OnProgress := OnImageProgress;
            Picture.LoadFromFile(FileName);

            // Извращение конечно: производить никому не нужную отрисовку,
            // но другого метода вызвать Picture.OnProgress я не нашел.
            BMP := TBitmap.Create;
            try
              BMP.Canvas.Draw(0, 0, Picture.Graphic);
            finally
              BMP.Free;
            end;
          finally
            Picture.Free;
          end;
        end else begin
          Picture := TPicture.Create;
          try
            Picture.LoadFromFile(FileName);
            SI.LoadGraphic(Picture.Graphic);
          finally
            Picture.Free;
          end;
        end;
      end else
        SI.Picture.LoadFromFile(FileName);
      StatusBar.SimpleText := FileName;
    end;
end;

procedure TMainForm.SIChangeImage(Sender: TObject);
begin
  if Assigned(NavigatorForm) and
     not Assigned(NavigatorForm.Parent) then
    with NavigatorForm do
      if Width = 250 then
        // специально для инкрементального отображения изображений
        Height := CorrectNavigatorHeight(250)
      else
        Width := 250;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if Self.ControlAtPos(ScreenToClient(MousePos), False, True) = TexturePanel then
    if (ssCtrl in Shift) or (ssMiddle in SHift) then
      SI.ScrollImage(WheelDelta, 0)
    else
      SI.ScrollImage(0, WheelDelta);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
       VK_PRIOR : SI.ScrollPageUp;
        VK_NEXT : SI.ScrollPageDown;
         VK_END : SI.ScrollEnd;
        VK_HOME : SI.ScrollHome;
        VK_LEFT : SI.ScrollImage(SI.ScrollBarIncrement, 0);
          VK_UP : SI.ScrollImage(0, SI.ScrollBarIncrement);
       VK_RIGHT : SI.ScrollImage(-SI.ScrollBarIncrement, 0);
        VK_DOWN : SI.ScrollImage(0, -SI.ScrollBarIncrement);
         VK_ADD : if SI.Zoom < 5000 then SI.Zoom := SI.Zoom * 2;
    VK_SUBTRACT : if SI.Zoom > 25 then SI.Zoom := SI.Zoom / 2;
  end;
end;

procedure TMainForm.HelpAboutExecute(Sender: TObject);
const
  AboutText =
    'Image Controls 2.1'#13 +
    'Advanced Demo'#13#13 +
    'Используйте также колесо мыши, Ctrl + прокрутку колеса, прокрутку нажатого' +
    ' колеса мыши, клавиши управления курсором, Home, End, PageUp, PageDown,' +
    ' а также навигатор для скроллинга изображения.';
begin
  Application.MessageBox(PChar(AboutText), 'About', MB_ICONQUESTION);
end;

procedure TMainForm.OnImageProgress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
  const Msg: string);
var
  Graphic: TGraphic;
begin
  Graphic := TGraphic(Sender);
  SI.Picture.Width := Graphic.Width;
  SI.Picture.Height := Graphic.Height;
  SI.Picture.Canvas.Draw(0, 0, Graphic);

  StatusBar.SimpleText := IntToStr(PercentDone);

  // Практически ничего не дает.
  // TODO: Поместить в поток?
  Application.ProcessMessages;
end;

procedure TMainForm.ViewOptionsExecute(Sender: TObject);
begin
  Splitter.Visible := not pnlOptions.Visible;
  pnlOptions.Visible := Splitter.Visible;
end;

procedure TMainForm.btnNavInOptionsClick(Sender: TObject);
begin
  if Assigned(NavigatorForm.Parent) then
  begin
    with NavigatorForm do
    begin
      Visible := False;
      BorderStyle := bsSizeToolWin;      
      Parent := nil;
      SetBounds((Screen.Width - 228) div 2, (Screen.Height - 181) div 2,
        228, NavigatorForm.CorrectNavigatorHeight(228));
      Anchors := [akLeft, akTop];
      Visible := True;
    end;
    ViewNavigator.Enabled := True;
  end else begin
    with NavigatorForm do
    begin
      BorderStyle := bsNone;      
      Parent := pnlOptions;
      SetBounds(3, btnNavInOptions.Top - 153, pnlOptions.Width - 6, 150);
      Anchors := [akLeft, akRight, akBottom];
      Visible := True;
    end;
    ViewNavigator.Enabled := False;
  end;
end;

procedure TMainForm.udScaleClick(Sender: TObject; Button: TUDBtnType);
begin
  SI.Zoom := udScale.Position;
end;

procedure TMainForm.SIChangePos(Sender: TObject);
begin
  Label3.Caption := Format('%dx%d', [SI.ImageLeft, SI.ImageTop]);
end;

procedure TMainForm.SIMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := nil;
end;

procedure TMainForm.cbAutoShrinkClick(Sender: TObject);
begin
  SI.AutoShrinkImage := cbAutoShrink.Checked;
end;

procedure TMainForm.cbAutoZoomClick(Sender: TObject);
begin
  SI.AutoZoomImage := cbAutoZoom.Checked;
end;

procedure TMainForm.ViewCanScrollWithMouseExecute(Sender: TObject);
begin
  SI.CanScrollWithMouse := not ViewCanScrollWithMouse.Checked;
end;

procedure TMainForm.ViewTransparentExecute(Sender: TObject);
begin
  SI.Transparent := not ViewTransparent.Checked;
end;

procedure TMainForm.SIZoomChanged(Sender: TObject);
begin
  ModifyMenu(MainMenu.Handle, 3, mf_ByPosition or mf_Popup or mf_Help, mnuZoom.Handle, PChar(FloatToStrF(SI.Zoom, ffFixed, 18, 2) + '%'));
  SendMessage(Handle, WM_NCPAINT, 0, 0);  
end;

procedure TMainForm.cbStretchMethodChange(Sender: TObject);
begin
  SI.StretchMode := cbStretchMethod.ItemIndex + 1;
end;

end.
