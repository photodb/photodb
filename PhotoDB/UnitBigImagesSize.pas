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
    RgPictureSize: TRadioGroup;
    CloseLink: TWebLink;
    TimerActivate: TTimer;
    procedure CloseLinkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RgPictureSizeClick(Sender: TObject);
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
    procedure SetRadioButtonSize;
    { Public declarations }
  end;

var
  BigImagesSizeForm: TBigImagesSizeForm;

implementation

uses Language;

{$R *.dfm}

procedure TBigImagesSizeForm.LoadLanguage;
begin
  Caption := TEXT_MES_BIG_IMAGE_FORM_SELECT;
  RgPictureSize.Caption := TEXT_MES_BIG_IMAGE_SIZES;
  CloseLink.Text := TEXT_MES_CLOSE;
  RgPictureSize.Items[0] := Format(TEXT_MES_OTHER_BIG_SIZE_F,[BigThSize,BigThSize]);
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
  FCallBack := nil;

  CloseLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);

  RgPictureSize.HandleNeeded;
  RgPictureSize.DoubleBuffered := True;
  RgPictureSize.Buttons[0].DoubleBuffered := True;

  TimerActivated := False;
  Destroying := False;
  LoadLanguage;
  LockChange := False;
  Color := Theme_ListColor;
  Panel1.Color := Theme_ListColor;
  DBkernel.RecreateThemeToForm(Self);
  DBKernel.RegisterForm(Self);
end;

procedure TBigImagesSizeForm.RgPictureSizeClick(Sender: TObject);
begin
  if LockChange or (not Assigned(FCallBack)) then
    Exit;

  case RgPictureSize.ItemIndex of
    0: BigThSize :=TrackBar1.Position * 10 + 40;
    1: BigThSize := 300;
    2: BigThSize := 250;
    3: BigThSize := 200;
    4: BigThSize := 150;
    5: BigThSize := 100;
    6: BigThSize := 50;
  end;

  FCallBack(Self, BigThSize, BigThSize);
  LockChange := True;
  TrackBar1.Position:=50-(BigThSize div 10-4);
  LockChange := False;
end;

procedure TBigImagesSizeForm.SetRadioButtonSize;
begin
  case BigThSize of
    50:  RgPictureSize.ItemIndex := 6;
    100: RgPictureSize.ItemIndex := 5;
    150: RgPictureSize.ItemIndex := 4;
    200: RgPictureSize.ItemIndex := 3;
    250: RgPictureSize.ItemIndex := 2;
    300: RgPictureSize.ItemIndex := 1;
  else
    RgPictureSize.ItemIndex := 0;
  end;
end;

procedure TBigImagesSizeForm.TrackBar1Change(Sender: TObject);
begin
  BeginScreenUpdate(RgPictureSize.Buttons[0].Handle);
  try
    if LockChange then
      Exit;

    LockChange := True;
    RgPictureSize.ItemIndex := 0;
    BigThSize := (50 - TrackBar1.Position) * 10 + 40;
    RgPictureSize.Buttons[0].Caption := Format(TEXT_MES_OTHER_BIG_SIZE_F, [BigThSize, BigThSize]);

    FCallBack(Self, BigThSize, BigThSize);
  finally
    EndScreenUpdate(RgPictureSize.Buttons[0].Handle, False);
    LockChange := False;
  end;
end;

procedure TBigImagesSizeForm.FormDestroy(Sender: TObject);
begin
  DBkernel.UnRegisterForm(Self);
end;

procedure TBigImagesSizeForm.Execute(aOwner: TForm; aPictureSize : integer;
  CallBack: TCallBackBigSizeProc);
var
  p: TPoint;
begin
  GetCursorPos(p);

  p.X := p.X - 12;

  LockChange := True;
  BigThSize := aPictureSize;
  TrackBar1.Position := 50 - (BigThSize div 10 - 4);
  p.y := p.y - 10 - Round((TrackBar1.Height - 20) * TrackBar1.Position / TrackBar1.Max);

  if p.y < 0 then
  begin
    Left := p.X;
    p.X := 10;
    p.y := 10 + Round((TrackBar1.Height - 20) * TrackBar1.Position / TrackBar1.Max);
    Top := 0;
    p := ClientToScreen(p);
    SetCursorPos(p.X, p.y);
  end
  else
  begin
    Left := p.X;
    Top := p.y - GetSystemMetrics(SM_CYFRAME) - GetSystemMetrics(SM_CYCAPTION)
      div 2;
  end;

  SetRadioButtonSize;

  LockChange := False;
  RgPictureSize.Items[0] := Format(TEXT_MES_OTHER_BIG_SIZE_F, [BigThSize, BigThSize]);
  FCallBack := CallBack;
  fOwner := aOwner;
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
 if Key = 27 then
   Deactivate;
end;

procedure TBigImagesSizeForm.FormShow(Sender: TObject);
var
  p : TPoint;
begin
  ActivateApplication(Self.Handle);
  GetCursorPos(p);
  TrackBar1.SetFocus;
  if GetAsyncKeystate(VK_MBUTTON)<>0 then
    Exit;
  if GetAsyncKeystate(VK_LBUTTON) <> 0 then
    mouse_event(MOUSEEVENTF_LEFTDOWN, P.X, P.Y, 0, 0);
end;

end.
