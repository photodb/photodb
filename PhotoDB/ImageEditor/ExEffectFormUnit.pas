unit ExEffectFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ExEffects,
  ToolsUnit, ScrollingImage, Math,  Dolphin_DB, uGOM, AppEvnts,
  uMemory, uDBForm, uSysUtils, uEditorTypes;

type
  TExEffectForm = class(TDBForm)
    BottomPanel: TPanel;
    ExEffectPanel: TPanel;
    ButtonPanel: TPanel;
    BtnCancel: TButton;
    BtnOk: TButton;
    EffectPanel: TGroupBox;
    CbPreview: TCheckBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    OriginalImage: TFastScrollingImage;
    NewImage: TFastScrollingImage;
    Timer1: TTimer;
    CbTransparent: TCheckBox;
    TbTransparent: TTrackBar;
    ApplicationEvents1: TApplicationEvents;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure OriginalImageChangePos(Sender: TObject);
    procedure NewImageChangePos(Sender: TObject);
    procedure CbPreviewClick(Sender: TObject);
    procedure CbTransparentClick(Sender: TObject);
    procedure TbTransparentChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    { Private declarations }
    FEffect: TExEffect;
    FOwner: TToolsPanelClass;
    FInitialString: string;
    InitiatedByString: Boolean;
    FEditor: TImageEditorForm;
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    function Execute(Owner: TToolsPanelClass; S, D: TBitmap; Effect: TExEffectsClass;
      var InitialString: string): Boolean;
    procedure SetImage(Image: TBitmap);
    property Editor: TImageEditorForm read FEditor write FEditor;
  end;

implementation

{$R *.dfm}

uses EffectsToolUnit, ImEditor;

{ TExEffectForm }

function TExEffectForm.Execute(Owner : TToolsPanelClass; S,D : TBitmap; Effect: TExEffectsClass; var InitialString : string): boolean;
begin
  FInitialString := InitialString;
  if FInitialString <> '' then
  begin
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := False;
    EffectPanel.Enabled := False;
    CbPreview.Enabled := False;
    CbTransparent.Enabled := False;
    BtnCancel.Enabled := False;
    BtnOk.Enabled := False;
    InitiatedByString := True;
  end else
    InitiatedByString := False;

  FOwner := Owner;
  FEffect := Effect.Create;
  FEffect.SetImageProc := SetImage;
  FEffect.Editor := Editor;
  if InitiatedByString then
  begin
    FEffect.Execute(S, D, EffectPanel, False);
    FEffect.SetProperties(InitialString);
  end else
    FEffect.Execute(S, D, EffectPanel, True);
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if not InitiatedByString then
  begin
    OriginalImage.Picture.Assign(S);
    NewImage.Picture.Assign(S);
  end;
  ShowModal;
  InitialString := FInitialString;
  Result := True;
end;

procedure TExEffectForm.BtnCancelClick(Sender: TObject);
begin
  (FOwner as TEffectsToolPanelClass).CancelTempImage(True);
  Close;
end;

procedure TExEffectForm.FormCreate(Sender: TObject);
begin
  FEffect := nil;
  LoadLanguage;
end;

procedure TExEffectForm.FormDestroy(Sender: TObject);
begin
  if GOM.IsObj(FEffect) then
    F(FEffect);

  (Editor as TImageEditor).FStatusProgress.Position := 0;
  (Editor as TImageEditor).StatusBar1.Panels[0].Text := '';
end;

procedure TExEffectForm.SetImage(Image: TBitmap);
var
  OldPos: TPoint;
begin
  if InitiatedByString then
  begin
    (FOwner as TEffectsToolPanelClass).SetNewImage(Image);
    FInitialString := FEffect.GetProperties;
    Close;
  end else
  begin
    OriginalImage.Tag := 1;
    OldPos := NewImage.ImagePos;
    NewImage.Picture.Assign(Image);
    NewImage.ImagePos := OldPos;

    NewImage.Transparent := True;
    NewImage.Transparent := False;
    OriginalImage.Tag := 0;
    if CbPreview.Checked then
    begin
     (FOwner as TEffectsToolPanelClass).SetTempImage(Image);
      FInitialString := FEffect.GetProperties;
    end else
      F(Image);
  end;
end;

procedure TExEffectForm.BtnOkClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  Bitmap.Assign(NewImage.Picture);
  Bitmap.PixelFormat := pf24bit;
  (FOwner as TEffectsToolPanelClass).CancelTempImage(True);
  (FOwner as TEffectsToolPanelClass).SetNewImage(Bitmap);
  Close;
end;

procedure TExEffectForm.SpeedButton1Click(Sender: TObject);
begin
  OriginalImage.Tag := 1;
  OriginalImage.Zoom := Min(1600, Max(1, OriginalImage.Zoom * 1.2));
  NewImage.Zoom := OriginalImage.Zoom;
  Label1.Caption := IntToStr(Round(NewImage.Zoom)) + '%';
  OriginalImage.Tag := 0;
end;

procedure TExEffectForm.SpeedButton2Click(Sender: TObject);
begin
  OriginalImage.Tag := 1;
  OriginalImage.Zoom := Min(1600, Max(1, OriginalImage.Zoom / 1.2));
  NewImage.Zoom := OriginalImage.Zoom;
  Label1.Caption := IntToStr(Round(NewImage.Zoom)) + '%';
  OriginalImage.Tag := 0;
end;

procedure TExEffectForm.OriginalImageChangePos(Sender: TObject);
begin
  if OriginalImage.Tag <> 1 then
    NewImage.ImagePos := OriginalImage.ImagePos;
end;

procedure TExEffectForm.NewImageChangePos(Sender: TObject);
begin
  if OriginalImage.Tag = 1 then
    Exit;
  OriginalImage.Tag := 1;
  OriginalImage.ImagePos := NewImage.ImagePos;
  OriginalImage.Tag := 0;
end;

procedure TExEffectForm.CbPreviewClick(Sender: TObject);
var
  Image: TBitmap;
begin
  if CbPreview.Checked then
  begin
    Image := TBitmap.Create;
    Image.PixelFormat := pf24bit;
    Image.Assign(NewImage.Picture);
    (FOwner as TEffectsToolPanelClass).SetTempImage(Image);
  end else
  begin
    (FOwner as TEffectsToolPanelClass).CancelTempImage(True);
  end;
end;

procedure TExEffectForm.CbTransparentClick(Sender: TObject);
begin
  AlphaBlend := CbTransparent.Checked;
end;

procedure TExEffectForm.TbTransparentChange(Sender: TObject);
begin
  AlphaBlendvalue := 255 - Round(TbTransparent.Position * 255 / 20);
end;

procedure TExEffectForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
    BtnCancelClick(Sender);
end;

function TExEffectForm.GetFormID: string;
begin
  Result := 'ExEffectForm';
end;

procedure TExEffectForm.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    Caption := L('Effects');
    CbPreview.Caption := L('Preview');
    CbTransparent.Caption := L('Transparency');
  finally
    EndTranslate;
  end;
end;

procedure TExEffectForm.Timer1Timer(Sender: TObject);
begin
  if CtrlKeyDown and Active then
  begin
    if Visible then
      Hide;
  end else
  begin
    if not Visible then
      Show;
  end
end;

procedure TExEffectForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if not Active then
    Exit;
  if Msg.message = WM_MOUSEWHEEL then
  begin
    if Msg.WParam < 0 then
      SpeedButton1Click(Self)
    else
      SpeedButton2Click(Self);
  end;
end;

end.
