unit about;

interface

//{$DEFINE ENGL}
{$DEFINE RUS}

uses
  win32crc, dolphin_db, Searching, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,
  ImButton, Dialogs, jpeg, DmProgress, psAPI;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    Memo2: TMemo;
    CloseButton: TImButton;
    Button1: TButton;
    Timer1: TTimer;
    Button2: TButton;
    DmProgress1: TDmProgress;
    LoadingTimer: TTimer;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Grayscale(var image : tbitmap);
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
  FStartTime : Cardinal;
  procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
    { Private declarations }
  public
   WaitEnabled : boolean;
   procedure LoadRegistrationData;
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;
  Seconds : integer;

implementation

uses Activation, Language;

{$R *.dfm}

{ TAboutForm }

procedure TAboutForm.GrayScale(var image : tbitmap);
var
  i, j, c : integer;
  p : PARGB;
begin
 if image.PixelFormat<>pf24bit then image.PixelFormat:=pf24bit;
 for i:=0 to image.Height-1 do
 begin
  p:=image.ScanLine[i];
  for j:=0 to image.Width-1 do
  begin
   c:=round(0.3*p[j].r+0.59*p[j].g+0.11*p[j].b);
   p[j].r:=c;
   p[j].g:=c;
   p[j].b:=c;
  end;
 end;
end;

procedure TAboutForm.WMMouseDown(var s: Tmessage);
begin
 Perform(WM_NCLBUTTONDOWN,HTCaption,s.lparam);
end;

procedure TAboutForm.CloseButtonClick(Sender: TObject);
begin
 if timer1.Enabled then exit;
 close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
 DmProgress1.Text:=TEXT_MES_LOADING_PHOTODB;
 WaitEnabled:=true;
 CloseButton.Filter:=grayscale;
 CloseButton.Refresh;
 Button1.Caption:=TEXT_MES_OPEN_ACTIVATION_FORM;
 if DBKernel<>nil then
 Button1.Visible:=DBkernel.ProgramInDemoMode else Button1.Visible:=false;
 Memo1.Clear;
 Memo1.Lines.Add(ProductName);
 Memo1.Lines.Add('About project:');
 Memo1.Lines.Add('All copyrights to this program are');
 Memo1.Lines.Add('exclusively owned by the author:');
 Memo1.Lines.Add('Veresov Dmitry © 2002-2008');
 Memo1.Lines.Add('Studio "Illusion Dolphin".');
 Memo1.Lines.Add('You can''t emulate, clone, rent, lease,');
 Memo1.Lines.Add('sell, modify, decompile, disassemble,');
 Memo1.Lines.Add('otherwise, reverse engineer, transfer');
 Memo1.Lines.Add('this software.');
 Memo1.Lines.Add('');
 Memo1.Lines.Add('HomePage:');
 Memo1.Lines.Add(HomeURL);
 Memo1.Lines.Add('');
 Memo1.Lines.Add('E-Mail:');
 Memo1.Lines.Add(ProgramMail);
end;

procedure TAboutForm.Execute(Wait : boolean = false);
begin
 if FolderView then
 begin
  Button2.Visible:=false;
  Button1.Visible:=false;
  DmProgress1.Visible:=false;
  Memo2.Clear;
  Memo2.Lines.Add(Format(TEXT_MES_DB_VIEW_ABOUT_F,[ProductName]));
  if Wait then else
  ShowModal;
  exit;
 end;

 Seconds:=0;
 timer1.Interval:=1000;
 LoadingTimer.Enabled:=false;
 DmProgress1.Visible:=false;
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
  DmProgress1.Visible:=true;
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
 ProcessSize:=GetProcessMemory;

 if ((GetTickCount-FStartTime)>2000) and not Visible then Show;

 Progress:=Round(100*(ProcessSize-ProcessMemorySize)/DBSize);
 if Progress<=100 then
 if Progress>DmProgress1.Position then DmProgress1.Position:=Progress;
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
// n:=n xor $FA45B671;  //v1.75
// n:=n xor $8C54AF5B; //v1.8
// n:=n xor $AC68DF35; //v1.9
// n:=n xor $B1534A4F; //v2.0
// n:=n xor $29E0FA13; //v2.1
 n:=n xor $6357A302; //v2.2
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 {$IFDEF ENGL}
  n:=n xor $1459EF12;
 {$ENDIF}
 {$IFDEF RUS}
//  n:=n xor $4D69F789; //v1.9
//  n:=n xor $E445CF12; //v2.0
//  n:=n xor $56C987F3; //v2.1
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
