unit about;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

uses
  win32crc, dolphin_db, Searching, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,
  ImButton, Dialogs, jpeg, DmProgress, psAPI, uConstants, uTime,
  UnitDBCommonGraphics, uResources;

type
  TAboutForm = class(TForm)
    ImageLogo: TImage;
    Memo1: TMemo;
    Memo2: TMemo;
    CloseButton: TImButton;
    Button1: TButton;
    Timer1: TTimer;
    Button2: TButton;
    LoadingTimer: TTimer;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Grayscale(var Image : TBitmap);
    procedure Execute(Wait : boolean = false);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure LoadingTimerTimer(Sender: TObject);
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

var
  AboutForm: TAboutForm;

implementation

uses Activation, Language;

{$R *.dfm}

{ TAboutForm }

procedure TAboutForm.GrayScale(var Image : TBitmap);
begin
  UnitDBCommonGraphics.GrayScale(Image);
end;

procedure TAboutForm.WMMouseDown(var s: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, s.lparam);
end;

procedure TAboutForm.CloseButtonClick(Sender: TObject);
begin
  if Timer1.Enabled then
    Exit;
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
 WaitEnabled:=True;
 CloseButton.Filter:=GrayScale;
 CloseButton.Refresh;
 Button1.Caption:=TEXT_MES_OPEN_ACTIVATION_FORM;
 if DBKernel<>nil then
 Button1.Visible:=DBkernel.ProgramInDemoMode else Button1.Visible:=false;
 TW.I.Start('Memo1');
 InfoText := TStringList.Create;
 try
   Memo1.Clear;
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
   Memo1.Lines.Assign(InfoText);
 finally
   InfoText.Free;
 end;
 TW.I.Start('End');
end;

procedure TAboutForm.Execute(Wait : boolean = false);
begin
 if FolderView then
 begin
  Button2.Visible:=false;
  Button1.Visible:=false;
  Memo2.Clear;
  Memo2.Lines.Add(Format(TEXT_MES_DB_VIEW_ABOUT_F,[ProductName]));
  if Wait then else
  ShowModal;
  exit;
 end;

 Seconds:=0;
 timer1.Interval:=1000;
 LoadingTimer.Enabled:=false;
 if not Wait then
 if DBkernel.ProgramInDemoMode then
 begin
  If SearchManager.SearchCount=0 then
  begin
   Button2.Visible:=true;
   Button1.Visible:=false;
   timer1.Enabled:=true;
  end else begin
   Button2.Visible:=false;
   Button1.Visible:=true;
   timer1.Enabled:=false;
  end;
 end;
 if Wait then
 begin
  Button1.Visible:=false;
  CloseButton.Visible:=false;
  Button2.Visible:=false;
  LoadingTimer.Enabled:=true;
 end;
 LoadRegistrationData;
 if Wait then else
 ShowModal;
 FStartTime:=GetTickCount;
end;

procedure TAboutForm.Button1Click(Sender: TObject);
begin
 if ActivateForm=nil then
 Application.CreateForm(tActivateForm,ActivateForm);
 ActivateForm.execute;
end;

procedure TAboutForm.Timer1Timer(Sender: TObject);
begin
 inc(Seconds);
 if DemoSecondsToOpen+1-Seconds<0 then
 begin
  Button2.Enabled:=true;
  Button2.caption:=TEXT_MES_CLOSE;
  Timer1.Enabled:=false;
  exit;
 end;
 Button2.Caption:=format(TEXT_MES_CLOSE_FORMAT,[inttostr(DemoSecondsToOpen+1-Seconds)]);
end;

procedure TAboutForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if Timer1.Enabled then CanClose:=false;
end;

procedure TAboutForm.Button2Click(Sender: TObject);
begin
 Close;
end;

procedure TAboutForm.FormDblClick(Sender: TObject);
begin
 if not DBkernel.ProgramInDemoMode then
 if not FolderView then
 begin
  if ActivateForm=nil then
  Application.CreateForm(TActivateForm,ActivateForm);
  ActivateForm.execute;
 end;
end;

procedure TAboutForm.LoadingTimerTimer(Sender: TObject);
var
  DBSize, ProcessSize, Progress : integer;
begin
 LoadingTimer.Enabled:=false;
 if not WaitEnabled then exit;
 DBSize:=GetFileSizeByName(dbname);

 if ((GetTickCount-FStartTime)>2000) and not Visible then Show;
end;

procedure TAboutForm.LoadRegistrationData;
var
  s, Code : string;
  n : Cardinal;
begin
 Memo2.Clear;
 memo2.Lines.Add(TEXT_MES_PROGRAM_CODE);
 s:=GetIdeDiskSerialNumber;
 CalcStringCRC32(s,n);
 n:=n xor $6357A302; //v2.2
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 {$IFDEF ENGL}
  n:=n xor $1459EF12;
 {$ENDIF}
 {$IFDEF RUS}
 n:=n xor $762C90CA; //v2.2
 {$ENDIF}
 Code:=s+inttohex(n,8);
 memo2.Lines.Add(Code);
 memo2.Lines.Add('');
 memo2.Lines.Add(TEXT_MES_REG_TO);
 memo2.Lines.Add('');
 if DBkernel.ProgramInDemoMode then
 memo2.Lines.Add(TEXT_MES_COPY_NOT_ACTIVATED) else
 memo2.Lines.Add(DBkernel.ReadRegName);
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Close();
end;

end.
