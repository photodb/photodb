unit uAbout;

interface

uses
  win32crc, dolphin_db, Searching, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,
  ImButton, Dialogs, jpeg, DmProgress, psAPI, uConstants, uTime,
  UnitDBCommonGraphics, uResources;

{$DEFINE RUS}

type
  TAboutForm = class(TForm)
    ImageLogo: TImage;
    MemoInfo: TMemo;
    MemoRegistrationInfo: TMemo;
    ImbClose: TImButton;
    BtShowActivationForm: TButton;
    procedure ImbCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Grayscale(var Image : TBitmap);
    procedure Execute(Wait : boolean = false);
    procedure BtShowActivationFormClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    Seconds : integer;
    FStartTime : Cardinal;
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
  if AboutForm = nil then
    Application.CreateForm(TAboutForm, AboutForm);
  AboutForm.Execute;
  AboutForm.Release;
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
  InfoText : TStringList;
  Logo : TJPEGImage;
begin
  Logo := GetLogoPicture;
  try
    ImageLogo.Picture.Graphic := Logo;
  finally
    Logo.Free;
  end;
  WaitEnabled := True;
  ImbClose.Filter := GrayScale;
  ImbClose.Refresh;
  BtShowActivationForm.Caption := TEXT_MES_OPEN_ACTIVATION_FORM;
  if DBKernel <> nil then
    BtShowActivationForm.Visible := DBkernel.ProgramInDemoMode
  else
    BtShowActivationForm.Visible := False;
  TW.I.Start('Memo1');
  InfoText := TStringList.Create;
  try
    MemoInfo.Clear;
    InfoText.Add(ProductName);
    InfoText.Add('About project:');
    InfoText.Add('All copyrights to this program are');
    InfoText.Add('exclusively owned by the author:');
    InfoText.Add('Veresov Dmitry © 2002-2011');
    InfoText.Add('Studio "Illusion Dolphin".');
    InfoText.Add('You can''t emulate, clone, rent, lease,');
    InfoText.Add('sell, modify, decompile, disassemble,');
    InfoText.Add('otherwise, reverse engineer, transfer');
    InfoText.Add('this software.');
    InfoText.Add('');
    InfoText.Add('HomePage:');
    InfoText.Add(HomeURL);
    InfoText.Add('');
    InfoText.Add('E-Mail:');
    InfoText.Add(ProgramMail);
    MemoInfo.Lines.Assign(InfoText);
  finally
    InfoText.Free;
  end;
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

  BtShowActivationForm.Visible := DBkernel.ProgramInDemoMode;

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
