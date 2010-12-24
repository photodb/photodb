unit uAbout;

interface

uses
  win32crc, UnitDBKernel, Searching, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,
  ImButton, Dialogs, jpeg, DmProgress, psAPI, uConstants, uTime,
  UnitDBCommonGraphics, uResources, pngimage, ComCtrls, WebLink, LoadingSign,
  uMemory, uTranslate, uRuntime, uActivationUtils;

type
  TAboutForm = class(TForm)
    ImageLogo: TImage;
    ImbClose: TImButton;
    BtShowActivationForm: TButton;
    MemoInfo: TRichEdit;
    MemoRegistrationInfo: TRichEdit;
    LoadingSign1: TLoadingSign;
    LnkGoToWebSite: TWebLink;
    procedure ImbCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Grayscale(var Image : TBitmap);
    procedure Execute(Wait : boolean = false);
    procedure BtShowActivationFormClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W, H: Integer;
      Bitmap: TBitmap);
  private
    { Private declarations }
    FBackground : TBitmap;
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
  public
    WaitEnabled : boolean;
    procedure LoadRegistrationData;
    { Public declarations }
  end;

procedure ShowAbout;

implementation

uses uActivation, Language;

{$R *.dfm}

procedure ShowAbout;
var
  AboutForm : TAboutForm;
begin
  Application.CreateForm(TAboutForm, AboutForm);
  try
    AboutForm.Execute;
  finally
    R(AboutForm);
  end;
end;

{ TAboutForm }

procedure TAboutForm.GrayScale(var Image : TBitmap);
begin
  UnitDBCommonGraphics.GrayScale(Image);
end;

procedure TAboutForm.WMMouseDown(var s: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, s.lparam);
end;

procedure TAboutForm.ImbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  Logo : TPngImage;
begin
  DoubleBuffered := True;
  MemoInfo.Brush.Style := BsClear;
  SetWindowLong(MemoInfo.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT);
  MemoRegistrationInfo.Brush.Style := BsClear;
  SetWindowLong(MemoRegistrationInfo.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT);

  FBackground := TBitmap.Create;
  Logo := GetLogoPicture;
  try
    FBackground.Assign(Logo);
    FBackground.PixelFormat := pf24bit;
    ImageLogo.Picture.Graphic := FBackground;
  finally
    Logo.Free;
  end;
  WaitEnabled := True;
  //ImbClose.Filter := GrayScale;
  //ImbClose.Refresh;
  BtShowActivationForm.Caption := TEXT_MES_OPEN_ACTIVATION_FORM;
  if DBKernel <> nil then
    BtShowActivationForm.Visible := DBkernel.ProgramInDemoMode
  else
    BtShowActivationForm.Visible := False;
  TW.I.Start('Memo1');
  MemoInfo.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Licenses\License' + TTranslateManager.Instance.Language + '.txt');
  TW.I.Start('End');
end;

procedure TAboutForm.Execute;
begin
  if FolderView then
  begin
    BtShowActivationForm.Visible := False;
    MemoRegistrationInfo.Clear;
    MemoRegistrationInfo.Lines.Add(Format(TEXT_MES_DB_VIEW_ABOUT_F, [ProductName]));
    ShowModal;
    Exit;
  end;

  LoadRegistrationData;
  ShowModal;
end;

procedure TAboutForm.BtShowActivationFormClick(Sender: TObject);
begin
  ShowActivationDialog;
end;

procedure TAboutForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormDblClick(Sender: TObject);
begin
  if not FolderView then
    ShowActivationDialog;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
  F(FBackground);
end;

procedure TAboutForm.LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W,
  H: Integer; Bitmap: TBitmap);
begin
  Bitmap.Width := W;
  Bitmap.Height := H;
  if FBackground <> nil then
    Bitmap.Canvas.CopyRect(Rect(0, 0, W, H), FBackground.Canvas, Rect(X, Y, X + W, Y + H));
end;

procedure TAboutForm.LoadRegistrationData;
var
  S, Code: string;
  N: Cardinal;
begin
  MemoRegistrationInfo.Clear;
  MemoRegistrationInfo.Lines.Add(TEXT_MES_PROGRAM_CODE);
  S := GetIdeDiskSerialNumber;
  CalcStringCRC32(S, N);
  N := N xor $6357A302; // v2.2
  S := Inttohex(N, 8);
  CalcStringCRC32(S, N);
{$IFDEF ENGL}
  N := N xor $1459EF12;
{$ENDIF}
{$IFDEF RUS}
  N := N xor $762C90CA; // v2.2
{$ENDIF}
  Code := S + Inttohex(N, 8);
  MemoRegistrationInfo.Lines.Add(Code);
  MemoRegistrationInfo.Lines.Add('');
  MemoRegistrationInfo.Lines.Add(TEXT_MES_REG_TO);
  MemoRegistrationInfo.Lines.Add('');
  if DBkernel.ProgramInDemoMode then
    MemoRegistrationInfo.Lines.Add(TEXT_MES_COPY_NOT_ACTIVATED)
  else
    MemoRegistrationInfo.Lines.Add(DBkernel.ReadRegName);
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

end.
