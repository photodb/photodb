unit uAbout;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  ExtCtrls,
  StdCtrls,
  Dialogs,
  jpeg,
  uConstants,
  uResources,
  pngimage,
  ComCtrls,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.ImButton,

  uMemory,
  uTranslate,
  uRuntime,
  uActivationUtils,
  uDBForm,
  UnitInternetUpdate,
  uInternetUtils,
  ShellApi,
  uMobileUtils,
  uFormInterfaces;

type
  TAboutForm = class(TDBForm, IAboutForm)
    ImageLogo: TImage;
    ImbClose: TImButton;
    BtShowActivationForm: TButton;
    MemoInfo: TRichEdit;
    MemoRegistrationInfo: TRichEdit;
    LsUpdates: TLoadingSign;
    LnkGoToWebSite: TWebLink;
    procedure ImbCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtShowActivationFormClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W, H: Integer;
      Bitmap: TBitmap);
    procedure LnkGoToWebSiteClick(Sender: TObject);
  private
    { Private declarations }
    FBackground: TBitmap;
    FUpdateInfo: TUpdateInfo;
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
    procedure LoadLanguage;
    procedure UpdateCkeckComplete(Sender: TObject; Info: TUpdateInfo);
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure Execute;
    procedure LoadRegistrationData;
  end;

implementation

{$R *.dfm}

{ TAboutForm }

function TAboutForm.GetFormID: string;
begin
  Result := 'About';
end;

procedure TAboutForm.WMMouseDown(var S: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, S.LParam);
end;

procedure TAboutForm.ImbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  Logo: TPngImage;
begin
  LoadLanguage;
  LnkGoToWebSite.LoadImage;
  LnkGoToWebSite.Left := LsUpdates.Left - LnkGoToWebSite.Width - 5;
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
    F(Logo);
  end;

  BtShowActivationForm.Caption := L('Open activation form');

  if FolderView then
    MemoInfo.Lines.Text := ReadInternalFSContent(FSLicenseFileName)
  else
    MemoInfo.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Licenses\License' + TTranslateManager.Instance.Language + '.txt');

  LnkGoToWebSite.Font.Color := clBlack;
  LnkGoToWebSite.Visible := not FolderView;
  LsUpdates.Visible := not FolderView;
  FUpdateInfo.InfoAvaliable := False;
  if not FolderView then
    TInternetUpdate.Create(Self, False, UpdateCkeckComplete);
end;

procedure TAboutForm.Execute;
begin
  if FolderView then
  begin
    BtShowActivationForm.Visible := False;
    MemoRegistrationInfo.Clear;
    MemoRegistrationInfo.Lines.Add(Format(L('Standalone database created using "%s". In this program many features are disabled and these features are available in the full version.'), [ProductName]));
    ShowModal;
    Exit;
  end;

  LoadRegistrationData;
  ShowModal;
end;

procedure TAboutForm.BtShowActivationFormClick(Sender: TObject);
begin
  if not FolderView then
  begin
    ActivationForm.Execute;
    LoadRegistrationData;
  end;
end;

procedure TAboutForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormDblClick(Sender: TObject);
begin
  if not FolderView then
    ActivationForm.Execute;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
  F(FBackground);
end;

procedure TAboutForm.LnkGoToWebSiteClick(Sender: TObject);
begin
  if FUpdateInfo.InfoAvaliable and FUpdateInfo.IsNewVersion then
    ShellExecute(Handle, 'open', PChar(FUpdateInfo.UrlToDownload), nil, nil, SW_NORMAL)
  else
    ShellExecute(Handle, 'open', PChar(ResolveLanguageString(HomePageURL)), nil, nil, SW_NORMAL);
  Close;
end;

procedure TAboutForm.LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W,
  H: Integer; Bitmap: TBitmap);
begin
  Bitmap.Width := W;
  Bitmap.Height := H;
  if FBackground <> nil then
    Bitmap.Canvas.CopyRect(Rect(0, 0, W, H), FBackground.Canvas, Rect(X, Y, X + W, Y + H));
end;

procedure TAboutForm.LoadLanguage;
begin
  BeginTranslate;
  try
    LnkGoToWebSite.Text := L('Checking updates...');
  finally
    EndTranslate;
  end;
end;

procedure TAboutForm.LoadRegistrationData;
begin
  BtShowActivationForm.Visible := TActivationManager.Instance.IsDemoMode;
  MemoRegistrationInfo.Clear;
  MemoRegistrationInfo.Lines.Add(L('Program code') + ':');

  MemoRegistrationInfo.Lines.Add(TActivationManager.Instance.ApplicationCode);
  MemoRegistrationInfo.Lines.Add('');
  MemoRegistrationInfo.Lines.Add(L('The program is registered to') + ':');
  MemoRegistrationInfo.Lines.Add('');
  if TActivationManager.Instance.IsDemoMode then
    MemoRegistrationInfo.Lines.Add(L('This program isn''t activated.'))
  else
    MemoRegistrationInfo.Lines.Add(TActivationManager.Instance.ActivationUserName);
end;

procedure TAboutForm.UpdateCkeckComplete(Sender: TObject; Info: TUpdateInfo);
begin
  FUpdateInfo := Info;
  LsUpdates.Visible := False;
  if not Info.InfoAvaliable then
    LnkGoToWebSite.Text := L('Can not check for updates!')
  else if not Info.IsNewVersion then
    LnkGoToWebSite.Text := Format(L('You''re using the latest version of PhotoDB (%s)!'), [ProductVersion])
  else
    LnkGoToWebSite.Text := Format(L('New version (%s) is available!'), [ReleaseToString(Info.Release)]);

  LnkGoToWebSite.Left := LsUpdates.Left + LsUpdates.Width - LnkGoToWebSite.Width;
  LnkGoToWebSite.Refresh;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

initialization
  FormInterfaces.RegisterFormInterface(IAboutForm, TAboutForm);

end.
