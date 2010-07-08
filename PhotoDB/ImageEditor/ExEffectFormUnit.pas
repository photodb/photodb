unit ExEffectFormUnit;

interface

{$DEFINE PHOTODB}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ExEffects, Language,
  EffectsLanguage, ToolsUnit, ScrollingImage, Math,

 {$IFDEF PHOTODB}
  Dolphin_DB, uGOM, AppEvnts
 {$ENDIF}

  ;

type
  TExEffectForm = class(TForm)
    BottomPanel: TPanel;
    ExEffectPanel: TPanel;
    ButtonPanel: TPanel;
    Button2: TButton;
    Button1: TButton;
    EffectPanel: TGroupBox;
    CheckBox1: TCheckBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    OriginalImage: TFastScrollingImage;
    NewImage: TFastScrollingImage;
    Timer1: TTimer;
    CheckBox2: TCheckBox;
    TrackBar1: TTrackBar;
    ApplicationEvents1: TApplicationEvents;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure OriginalImageChangePos(Sender: TObject);
    procedure NewImageChangePos(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
  FEffect : TExEffect;
  FOwner : TToolsPanelClass;
  FInitialString : string;     
   InitiatedByString : boolean;
    FEditor: TForm;
    procedure SetEditor(const Value: TForm);
    { Private declarations }
  public
  function Execute(Owner : TToolsPanelClass; S,D : TBitmap; Effect: TExEffectsClass; var InitialString : string) : boolean;
  procedure SetImage(Image : TBitmap);
    { Public declarations }
  published
  property Editor : TForm read FEditor write SetEditor;
  end;

implementation

{$R *.dfm}

uses EffectsToolUnit, ImEditor;

{ TExEffectForm }

function TExEffectForm.Execute(Owner : TToolsPanelClass; S,D : TBitmap; Effect: TExEffectsClass; var InitialString : string): boolean;
begin
 FInitialString:=InitialString;
 if FInitialString<>'' then
 begin
  SpeedButton1.Enabled:=false;
  SpeedButton2.Enabled:=false;
  EffectPanel.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  Button2.Enabled:=false;
  Button1.Enabled:=false;
  InitiatedByString:=true;
 end else InitiatedByString:=false;
 FOwner:=Owner;
 FEffect:=Effect.Create;
 FEffect.SetImageProc:=SetImage;
 FEffect.Editor:=Editor;
 if InitiatedByString then
 begin
  FEffect.Execute(S,D,EffectPanel,false);
  FEffect.SetProperties(InitialString);
 end else FEffect.Execute(S,D,EffectPanel,true);
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 if not InitiatedByString then
 begin
  OriginalImage.Picture.Assign(S);
  NewImage.Picture.Assign(S);
 end;
 ShowModal;
 InitialString:=FInitialString;
 Result:=true;
end;

procedure TExEffectForm.Button2Click(Sender: TObject);
begin
 (FOwner as TEffectsToolPanelClass).CancelTempImage(true);
 Close;
end;

procedure TExEffectForm.FormCreate(Sender: TObject);
begin
 FEffect:=nil;
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;
 Caption:=TEXT_MES_EX_EFFECTS;
 CheckBox1.Caption:=TEXT_MES_PREVIEW;
 CheckBox2.Caption:=TEXT_MES_LAYERED;
end;

procedure TExEffectForm.FormDestroy(Sender: TObject);
begin
 if GOM.IsObj(FEffect) then
 if FEffect<>nil then FEffect.Free;
 (Editor as TImageEditor).FStatusProgress.Position:=0;
 (Editor as TImageEditor).StatusBar1.Panels[0].Text:='';
end;

procedure TExEffectForm.SetImage(Image: TBitmap);
var
  OldPos : TPoint;
begin
 if InitiatedByString then
 begin
  (FOwner as TEffectsToolPanelClass).SetNewImage(Image);
  FInitialString:=FEffect.GetProperties;
  Close;
 end else
 begin
  OriginalImage.Tag:=1;
  OldPos:=NewImage.ImagePos;
  NewImage.Picture.Assign(Image);
  NewImage.ImagePos:=OldPos;

  NewImage.Transparent:=true;
  NewImage.Transparent:=false;
  OriginalImage.Tag:=0;
  if CheckBox1.Checked then
  begin
   (FOwner as TEffectsToolPanelClass).SetTempImage(Image);
   FInitialString:=FEffect.GetProperties;
  end else
  Image.Free;
 end;
end;

procedure TExEffectForm.Button1Click(Sender: TObject);
var
  Bitmap : TBitmap;
begin
 Bitmap := TBitmap.Create;
 Bitmap.Assign(NewImage.Picture);
 Bitmap.PixelFormat:=pf24bit;
 (FOwner as TEffectsToolPanelClass).CancelTempImage(true);
 (FOwner as TEffectsToolPanelClass).SetNewImage(Bitmap);
 Close;
end;

procedure TExEffectForm.SpeedButton1Click(Sender: TObject);
begin
 OriginalImage.Tag:=1;
 OriginalImage.Zoom:=Min(1600,Max(1,OriginalImage.Zoom*1.2));
 NewImage.Zoom:=OriginalImage.Zoom;
 Label1.Caption:=IntToStr(Round(NewImage.Zoom))+'%';
 OriginalImage.Tag:=0;
end;

procedure TExEffectForm.SpeedButton2Click(Sender: TObject);
begin
 OriginalImage.Tag:=1;
 OriginalImage.Zoom:=Min(1600,Max(1,OriginalImage.Zoom/1.2));
 NewImage.Zoom:=OriginalImage.Zoom;
 Label1.Caption:=IntToStr(Round(NewImage.Zoom))+'%';
 OriginalImage.Tag:=0;
end;

procedure TExEffectForm.OriginalImageChangePos(Sender: TObject);
begin
 if OriginalImage.Tag<>1 then
 NewImage.ImagePos:=OriginalImage.ImagePos;
end;

procedure TExEffectForm.NewImageChangePos(Sender: TObject);
begin
 if OriginalImage.Tag=1 then exit;
 OriginalImage.Tag:=1;
 OriginalImage.ImagePos:=NewImage.ImagePos;
 OriginalImage.Tag:=0;
end;

procedure TExEffectForm.CheckBox1Click(Sender: TObject);
var
  Image :  TBitmap;
begin
 if CheckBox1.Checked then
 begin
  Image := TBitmap.Create;
  Image.PixelFormat:=pf24bit;
  Image.Assign(NewImage.Picture);
  (FOwner as TEffectsToolPanelClass).SetTempImage(Image);
 end else
 begin
  (FOwner as TEffectsToolPanelClass).CancelTempImage(true);
 end;
end;

procedure TExEffectForm.CheckBox2Click(Sender: TObject);
begin
 AlphaBlend:=CheckBox2.Checked;
end;

procedure TExEffectForm.TrackBar1Change(Sender: TObject);
begin
 AlphaBlendvalue:=255-Round(TrackBar1.Position*255/20);
end;

procedure TExEffectForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#27 then
 begin
  Button2Click(Sender);
 end;
end;

procedure TExEffectForm.Timer1Timer(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 if CtrlKeyDown and Active then
 begin
  if Visible then Hide;
 end else
 begin
  if not Visible then Show;
 end
 {$ENDIF}
end;

procedure TExEffectForm.SetEditor(const Value: TForm);
begin
  FEditor := Value;
end;

procedure TExEffectForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if not Active then Exit;
 if Msg.message=522 then
 begin
  if Msg.wParam<0 then SpeedButton1Click(nil) else SpeedButton2Click(nil);
 end;
end;

end.
