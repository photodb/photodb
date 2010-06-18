unit UnitBigImagesSize;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, WebLink, dolphin_db, UnitDBKernel,
  DBCtrls, UnitDBCommon, UnitDBCommonGraphics;

type
  TBigImagesSizeForm = class(TForm)
    TrackBar1: TTrackBar;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    CloseLink: TWebLink;
    TimerActivate: TTimer;
    procedure CloseLinkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TimerActivateTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    LockChange : boolean;
    fCallBack: TCallBackBigSizeProc;
    fOwner : TForm;      
    TimerActivated : boolean;
    procedure LoadLanguage;
    { Private declarations }
  public
    BigThSize : integer;
    Destroying : boolean;
    procedure Execute(aOwner : TForm; aPictureSize : integer; CallBack : TCallBackBigSizeProc);
    { Public declarations }
  end;

var
  BigImagesSizeForm: TBigImagesSizeForm;

implementation

uses Language;

{$R *.dfm}

procedure TBigImagesSizeForm.LoadLanguage;
begin
 Caption:=TEXT_MES_BIG_IMAGE_FORM_SELECT;
 RadioGroup1.Caption:=TEXT_MES_BIG_IMAGE_SIZES;
 CloseLink.Text:=TEXT_MES_CLOSE;
 RadioGroup1.Items[6]:=Format(TEXT_MES_OTHER_BIG_SIZE_F,[BigThSize,BigThSize]);
end;

procedure TBigImagesSizeForm.CloseLinkClick(Sender: TObject);
begin
 if Destroying then exit;
 Destroying:=true;
 Release;
 Free;
end;

procedure TBigImagesSizeForm.FormCreate(Sender: TObject);
begin
 RadioGroup1.DoubleBuffered:=true;
 
 CloseLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_DELETE_INFO+1]);

 RadioGroup1.DoubleBuffered:=true;
 RadioGroup1.Buttons[0].DoubleBuffered:=true;

 TimerActivated:=false;
 Destroying:=false;
 LoadLanguage;
 LockChange:=false;
 Color:=Theme_ListColor;
 Panel1.Color:=Theme_ListColor;
 DBkernel.RecreateThemeToForm(self);
 DBKernel.RegisterForm(self);
end;

procedure TBigImagesSizeForm.RadioGroup1Click(Sender: TObject);
begin
 if LockChange then exit;
 case RadioGroup1.ItemIndex of
   0: BigThSize:=50;
   1: BigThSize:=100;
   2: BigThSize:=150;
   3: BigThSize:=200;
   4: BigThSize:=250;
   5: BigThSize:=300;
   6: BigThSize:=TrackBar1.Position*10+40;
  end;
 fCallBack(self,BigThSize,BigThSize);
 LockChange:=true;
 TrackBar1.Position:=50-(BigThSize div 10-4);
 LockChange:=false;
end;

procedure TBigImagesSizeForm.TrackBar1Change(Sender: TObject);
begin
 BeginScreenUpdate(RadioGroup1.Buttons[0].Handle);
 if LockChange then exit;
 LockChange:=true;
 RadioGroup1.ItemIndex:=6;
 BigThSize:=(50-TrackBar1.Position)*10+40;
 RadioGroup1.Buttons[6].Caption:=Format(TEXT_MES_OTHER_BIG_SIZE_F,[BigThSize,BigThSize]);

 fCallBack(self,BigThSize,BigThSize);
 LockChange:=false;
 EndScreenUpdate(RadioGroup1.Buttons[0].handle,false);
end;

procedure TBigImagesSizeForm.FormDestroy(Sender: TObject);
begin
 DBkernel.UnRegisterForm(self);
end;

procedure TBigImagesSizeForm.Execute(aOwner: TForm; aPictureSize : integer;
  CallBack: TCallBackBigSizeProc);
var
  p : TPoint;
begin
 GetCursorPos(p);

 p.X:=p.X-12;

 LockChange:=true;      
 BigThSize:=aPictureSize;
 TrackBar1.Position:=50-(BigThSize div 10-4);
 p.y:=p.y-10-Round((TrackBar1.Height-20)*TrackBar1.Position/TrackBar1.Max);

 if p.y<0 then
 begin    
  Left:=p.x;   
  p.x:=10;
  p.Y:=10+Round((TrackBar1.Height-20)*TrackBar1.Position/TrackBar1.Max);
  Top:=0;
  p:=ClientToScreen(p);
  SetCursorPos(p.X,p.y);
 end else
 begin   
  Left:=p.x;
  Top:=p.Y-GetSystemMetrics(SM_CYFRAME)-GetSystemMetrics(SM_CYCAPTION) div 2;
 end;

 case BigThSize of
  50:   RadioGroup1.ItemIndex:=0;
  100:  RadioGroup1.ItemIndex:=1;
  150:  RadioGroup1.ItemIndex:=2;
  200:  RadioGroup1.ItemIndex:=3;
  250:  RadioGroup1.ItemIndex:=4;
  300:  RadioGroup1.ItemIndex:=5;
   else RadioGroup1.ItemIndex:=6;
  end;     
 LockChange:=false;
 RadioGroup1.Items[6]:=Format(TEXT_MES_OTHER_BIG_SIZE_F,[BigThSize,BigThSize]);
 FCallBack:=CallBack;
 FOwner := aOwner;
// GetCursorPos(p);
 Show;

end;

procedure TBigImagesSizeForm.FormDeactivate(Sender: TObject);
begin
 if not TimerActivated then exit;
 if Destroying then exit;
 Destroying:=true;
 Release;
 Free;
end;

procedure TBigImagesSizeForm.TimerActivateTimer(Sender: TObject);
begin
 TimerActivate.Enabled:=false;
 TimerActivated:=true;
end;

procedure TBigImagesSizeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 //ESC
 if Key = 27 then Deactivate;
end;

procedure TBigImagesSizeForm.FormShow(Sender: TObject);
var
  p : TPoint;
begin
 ActivateApplication(Self.Handle);
 GetCursorPos(p);
 TrackBar1.SetFocus;
 if GetAsyncKeystate(VK_MBUTTON)<>0 then exit;
 if GetAsyncKeystate(VK_LBUTTON)<>0 then
 mouse_event(MOUSEEVENTF_LEFTDOWN, p.X, p.Y, 0, 0);
end;

end.
