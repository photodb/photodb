unit UnitPasswordForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UnitDBKernel, FormManegerUnit, GraphicCrypt, DB,
  uConstants, win32crc, Menus, Clipbrd, UnitDBDeclare, WatermarkedEdit,
  uDBForm, uTranslate, uFileUtils, uShellIntegration, uSettings,
  uSysUtils, uMemory;

type
  PasswordType = Integer;

const
  PASS_TYPE_IMAGE_FILE = 0;
  PASS_TYPE_IMAGE_BLOB = 1;
  PASS_TYPE_IMAGE_STENO = 2;
  PASS_TYPE_IMAGES_CRC = 3;

type
  TPassWordForm = class(TDBForm)
    LbTitle: TLabel;
    BtCancel: TButton;
    BtOk: TButton;
    CbSavePassToSession: TCheckBox;
    CbSavePassPermanent: TCheckBox;
    CbDoNotAskAgain: TCheckBox;
    BtCancelForFiles: TButton;
    InfoListBox: TListBox;
    BtHideDetails: TButton;
    PmCopyFileList: TPopupMenu;
    CopyText1: TMenuItem;
    LbInfo: TLabel;
    PmCloseAction: TPopupMenu;
    CloseDialog1: TMenuItem;
    Skipthisfiles1: TMenuItem;
    EdPassword: TWatermarkedEdit;
    procedure FormCreate(Sender: TObject);
    procedure LoadLanguage;
    procedure BtOkClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure CopyText1Click(Sender: TObject);
    procedure BtCancelForFilesClick(Sender: TObject);
    procedure CloseDialog1Click(Sender: TObject);
    procedure Skipthisfiles1Click(Sender: TObject);
    procedure BtHideDetailsClick(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      aRect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFileName: string;
    FPassword: string;
    DB: TField;
    UseAsk: Boolean;
    FCRC: Cardinal;
    FOpenedList: Boolean;
    DialogType: PasswordType;
    Skip: Boolean;
    PassIcon: TIcon;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure ReallignControlsEx;
    procedure LoadFileList(FileList : TStrings);
    property Password : string read FPassword write FPassword;
  end;

function GetImagePasswordFromUser(FileName : String) : String;
function GetImagePasswordFromUserBlob(DF : TField; FileName : String) : String;
function GetImagePasswordFromUserEx(FileName : String; out AskAgain : boolean) : String;
function GetImagePasswordFromUserStenoraphy(FileName : string; CRC : Cardinal) : String;
function GetImagePasswordFromUserForManyFiles(FileList : TStrings; CRC : Cardinal; var Skip : boolean) : String;

implementation

{$R *.dfm}

function GetImagePasswordFromUserForManyFiles(FileList: TStrings; CRC: Cardinal; var Skip: Boolean): string;
var
  PassWordForm: TPassWordForm;
begin
  Application.CreateForm(TPassWordForm, PassWordForm);
  PassWordForm.FFileName := '';
  PassWordForm.DB := nil;
  PassWordForm.LbTitle.Caption := TA('Enter password for group of files (press "Show files" to see list) here:', 'Password');
  PassWordForm.FCRC := CRC;
  PassWordForm.DialogType := PASS_TYPE_IMAGES_CRC;
  PassWordForm.UseAsk := False;
  PassWordForm.ReallignControlsEx;
  PassWordForm.LoadFileList(FileList);
  PassWordForm.Skip := Skip;
  PassWordForm.ShowModal;
  Skip := PassWordForm.Skip;
  Result := PassWordForm.Password;
  PassWordForm.Release;
end;

function GetImagePasswordFromUser(FileName: string): string;
var
  PassWordForm: TPassWordForm;
begin
  Application.CreateForm(TPassWordForm, PassWordForm);
  PassWordForm.FFileName := FileName;
  PassWordForm.DB := nil;
  PassWordForm.LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  PassWordForm.UseAsk := False;
  PassWordForm.DialogType := PASS_TYPE_IMAGE_FILE;
  PassWordForm.ReallignControlsEx;
  PassWordForm.ShowModal;
  Result := PassWordForm.Password;
  PassWordForm.Release;
end;

function GetImagePasswordFromUserEx(FileName: string; out AskAgain: Boolean): string;
var
  PassWordForm: TPassWordForm;
begin
  Application.CreateForm(TPassWordForm, PassWordForm);
  PassWordForm.FFileName := FileName;
  PassWordForm.DB := nil;
  PassWordForm.UseAsk := True;
  PassWordForm.DialogType := PASS_TYPE_IMAGE_FILE;
  PassWordForm.ReallignControlsEx;
  PassWordForm.LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  PassWordForm.ShowModal;
  AskAgain := not PassWordForm.CbDoNotAskAgain.Checked;
  Result := PassWordForm.Password;
  PassWordForm.Release;
end;

function GetImagePasswordFromUserBlob(DF: TField; FileName: string): string;
var
  PassWordForm: TPassWordForm;
begin
  Application.CreateForm(TPassWordForm, PassWordForm);
  PassWordForm.FFileName := '';
  PassWordForm.DB := DF;
  PassWordForm.UseAsk := False;
  PassWordForm.DialogType := PASS_TYPE_IMAGE_BLOB;
  PassWordForm.ReallignControlsEx;
  PassWordForm.LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  PassWordForm.ShowModal;
  Result := PassWordForm.Password;
  PassWordForm.Release;
  PassWordForm.Free;
end;

function GetImagePasswordFromUserStenoraphy(FileName: string; CRC: Cardinal): string;
var
  PassWordForm: TPassWordForm;
begin
  Application.CreateForm(TPassWordForm, PassWordForm);
  PassWordForm.FFileName := FileName;
  PassWordForm.DB := nil;
  PassWordForm.UseAsk := False;
  PassWordForm.FCRC := CRC;
  PassWordForm.DialogType := PASS_TYPE_IMAGE_STENO;
  PassWordForm.ReallignControlsEx;
  PassWordForm.LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  PassWordForm.ShowModal;
  Result := PassWordForm.Password;
  PassWordForm.Release;
  PassWordForm.Free;
end;

procedure TPassWordForm.FormCreate(Sender: TObject);
begin
  FOpenedList := False;
  ClientHeight := BtOk.Top + BtOk.Height + 5;
  CbSavePassToSession.Checked := Settings.Readbool('Options', 'AutoSaveSessionPasswords', True);
  CbSavePassPermanent.Checked := Settings.Readbool('Options', 'AutoSaveINIPasswords', False);
  LoadLanguage;
  Password := '';
  PassIcon := TIcon.Create;
  PassIcon.Handle := LoadIcon(HInstance, PWideChar('PASSWORD'));
end;

procedure TPassWordForm.FormDestroy(Sender: TObject);
begin
  F(PassIcon);
end;

procedure TPassWordForm.LoadLanguage;
begin
  BeginTranslate;
  try
    EdPassword.WatermarkText := L('Enter your password here');
    Caption := L('Password is required');
    LbTitle.Caption := L('Enter password to open file "%s" here:');
    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('OK');
    CbSavePassToSession.Caption := L('Save password for session');
    CbSavePassPermanent.Caption := L('Save password in settings');
    CbDoNotAskAgain.Caption := L('Don''t ask again');
    BtCancelForFiles.Caption := L('Show files');
    LbInfo.Caption := L('These files have the same password (hashes are equals)');
    CloseDialog1.Caption := L('Close');
    Skipthisfiles1.Caption := L('Skip these files');
    BtHideDetails.Caption := L('Hide list');
    CopyText1.Caption := L('Copy text');
  finally
    EndTranslate;
  end;
end;

procedure TPassWordForm.BtOkClick(Sender: TObject);

  function TEST: Boolean;
  var
    Crc, Crc2: Cardinal;
  begin
    Result := False;
    if (DialogType = PASS_TYPE_IMAGE_STENO) or (DialogType = PASS_TYPE_IMAGES_CRC) then
    begin
      //unicode password
      CalcStringCRC32(EdPassword.Text, Crc);
      //old-style pasword
      CalcAnsiStringCRC32(AnsiString(EdPassword.Text), Crc2);
      Result := (Crc = FCRC) or (Crc2 = FCRC);
      Exit;
    end;
    if FFileName <> '' then
      Result := ValidPassInCryptGraphicFile(FFileName, EdPassword.Text);
    if DB <> nil then
      Result := ValidPassInCryptBlobStreamJPG(DB, EdPassword.Text);
  end;

begin
  if TEST then
  begin
    Password := EdPassword.Text;
    if CbSavePassToSession.Checked then
      DBKernel.AddTemporaryPasswordInSession(Password);
    if CbSavePassPermanent.Checked then
      DBKernel.SavePassToINIDirectory(Password);
    Close;
  end else
    MessageBoxDB(Handle, L('Password is invalid!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TPassWordForm.EdPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    if ShiftKeyDown then
    begin
      DBKernel.AddTemporaryPasswordInSession(EdPassword.Text);
      Exit;
    end;
    Key := #0;
    BtOkClick(Sender);
  end;
  if Key = Char(VK_ESCAPE) then
  begin
    Password := '';
    Close;
  end;
end;

procedure TPassWordForm.BtCancelClick(Sender: TObject);
var
  P: TPoint;
begin
  if (DialogType = PASS_TYPE_IMAGES_CRC) then
  begin
    P.X := BtCancel.Left;
    P.Y := BtCancel.Top + BtCancel.Height;
    P := ClientToScreen(P);
    PmCloseAction.Popup(P.X, P.Y);
  end else
  begin
    Password := '';
    Close;
  end;
end;

procedure TPassWordForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    Password := '';
    Close;
  end;
end;

function TPassWordForm.GetFormID: string;
begin
  Result := 'Password';
end;

procedure TPassWordForm.ReallignControlsEx;
begin
  if not UseAsk then
  begin
    CbDoNotAskAgain.Visible := False;
    BtCancel.Top := CbSavePassPermanent.Top + CbSavePassPermanent.Height + 3;
    BtOk.Top := CbSavePassPermanent.Top + CbSavePassPermanent.Height + 3;
    CbSavePassToSession.Enabled := CbSavePassToSession.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO) and not
      (DialogType = PASS_TYPE_IMAGES_CRC);
    CbSavePassPermanent.Enabled := CbSavePassPermanent.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO);
    CbDoNotAskAgain.Enabled := CbDoNotAskAgain.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO);

    if (DialogType = PASS_TYPE_IMAGES_CRC) then
      CbSavePassToSession.Checked := True;
    if (DialogType = PASS_TYPE_IMAGES_CRC) then
    begin
      LbTitle.Height := 50;
      EdPassword.Top := LbTitle.Top + LbTitle.Height + 3;
      CbSavePassToSession.Top := EdPassword.Top + EdPassword.Height + 5;
      CbSavePassPermanent.Top := CbSavePassToSession.Top + CbSavePassToSession.Height + 3;
      CbDoNotAskAgain.Top := CbSavePassPermanent.Top; // +CbSavePassPermanent.Height+3; //invisible
      BtCancel.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      BtOk.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      BtCancelForFiles.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      LbInfo.Top := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
      InfoListBox.Top := LbInfo.Top + LbInfo.Height + 3;
    end;
    ClientHeight := BtOk.Top + BtOk.Height + 3;
  end;
end;

procedure TPassWordForm.CopyText1Click(Sender: TObject);
begin
  TextToClipboard(InfoListBox.Items.Text);
end;

procedure TPassWordForm.LoadFileList(FileList: TStrings);
begin
  InfoListBox.Items.Assign(FileList);

  BtCancelForFiles.Visible := True;
  InfoListBox.Visible := True;
  LbInfo.Visible := True;
  BtHideDetails.Visible := True;
  CbSavePassToSession.Enabled := False;
  CbDoNotAskAgain.Enabled := True;
end;

procedure TPassWordForm.BtCancelForFilesClick(Sender: TObject);
begin
  if FOpenedList then
  begin
    FOpenedList := False;
    ClientHeight := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
    InfoListBox.Visible := False;
    BtHideDetails.Visible := False;
    LbInfo.Visible := False;
  end else
  begin
    FOpenedList := True;
    ClientHeight := BtHideDetails.Top + BtHideDetails.Height + 3;
    InfoListBox.Visible := True;
    BtHideDetails.Visible := True;
    LbInfo.Visible := True;
  end;
end;

procedure TPassWordForm.CloseDialog1Click(Sender: TObject);
begin
  Password := '';
  Close;
end;

procedure TPassWordForm.Skipthisfiles1Click(Sender: TObject);
begin
  Password := '';
  Skip := True;
  Close;
end;

procedure TPassWordForm.BtHideDetailsClick(Sender: TObject);
begin
  FOpenedList := False;
  ClientHeight := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
  InfoListBox.Visible := False;
  BtHideDetails.Visible := False;
  LbInfo.Visible := False;
end;

procedure TPassWordForm.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
end;

procedure TPassWordForm.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; aRect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
begin
  ListBox := Control as TListBox;
  if OdSelected in State then
    ListBox.Canvas.Brush.Color := $A0A0A0
  else
    ListBox.Canvas.Brush.Color := ClWhite;
  // clearing rect
  ListBox.Canvas.Pen.Color := ListBox.Canvas.Brush.Color;
  ListBox.Canvas.Rectangle(ARect);

  ListBox.Canvas.Pen.Color := ClBlack;
  ListBox.Canvas.Font.Color := ClBlack;
  Text := ListBox.Items[index];

  DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, PassIcon.Handle, 16, 16, 0, 0, DI_NORMAL);
  ARect.Left := ARect.Left + 20;
  DrawText(ListBox.Canvas.Handle, PWideChar(Text), Length(Text), ARect, DT_NOPREFIX + DT_LEFT + DT_WORDBREAK);

end;

end.
