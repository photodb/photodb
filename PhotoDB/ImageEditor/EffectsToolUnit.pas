unit EffectsToolUnit;

interface

uses
  System.Math,
  System.Types,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Themes,

  MPCommonUtilities,

  Dmitry.Controls.WebLink,

  ToolsUnit,
  ImageHistoryUnit,
  Effects,
  ExEffects,
  ExEffectsUnitW,
  OptimizeImageUnit,
  UnitBitmapImageList,
  EasyListView,

  uMemory,
  uBitmapUtils,
  uSettings,
  uListViewUtils,
  uEditorTypes,
  uTranslate,
  uMemoryEx;

type
  TEffectsManager = class(TObject)
  private
    { Private declarations }
    Effects: TBaseEffectProcedures;
    ExEffects: TExEffects;
  public
    { Public declarations }
    function L(StringToTranslate : string) : string;
    procedure AddBaseEffect(Effect: TBaseEffectProcW);
    function GetBaseEffects: TBaseEffectProcedures;
    procedure AddExEffect(Effect: TExEffectsClass);
    function GetExEffects: TExEffects;
    procedure InitializeBaseEffects;
    function GetEffectNameByID(ID: string): string;
  end;

type
  TEffectsToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    NewImage: TBitmap;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    EffectsChooser: TEasyListView;
    FSelectTimer: TTimer;
    FImageList: TBitmapImageList;
    EM: TEffectsManager;
    BaseEffects: TBaseEffectProcedures;
    ExEffects: TExEffects;
    BaseImage: TBitmap;
    FOnDone: TNotifyEvent;
    ApplyOnDone: Boolean;
    procedure FreeNewImage;
    procedure ListViewItemThumbnailDraw(Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
      ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure ListViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SelectTimerOnTimer(Sender: TObject);
  protected
    function LangID: string; override;
  public
    { Public declarations }
    FSID: string;
    TempFilterID: string;
    FilterID: string;
    FilterInitialString: string;
    OutFilterInitialString: string;
    class function ID: string; override;
    function GetProperties: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; override;
    procedure MakeTransform; override;
    procedure ClosePanelEvent(Sender: TObject);
    procedure DoMakeImage(Sender: TObject);
    procedure SelectEffect(Sender: TCustomEasyListview; Item: TEasyItem);
    procedure SetBaseImage(Image: TBitmap);
    procedure FillEffects(OneEffectID: string = '');
    procedure SetThreadImage(Image: TBitmap; SID: string);
    procedure SetProgress(Progress: Integer; SID: string);
    procedure SetNewImage(Image: TBitmap);
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    procedure SetProperties(Properties: string); override;
  end;

implementation

{ TEffectsToolPanelClass }

uses
  EffectsToolThreadUnit,
  ImEditor,
  ExEffectsUnit,
  ExEffectFormUnit;

procedure TEffectsToolPanelClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  if not ApplyOnDone then
    inherited;
end;

procedure TEffectsToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
  CancelTempImage(True);
  NewImage := nil;
  ClosePanel;
end;

constructor TEffectsToolPanelClass.Create(AOwner: TComponent);
begin
  inherited;
  NewImage := nil;
  ApplyOnDone := False;
  Align := AlClient;
  BaseImage := TBitmap.Create;
  BaseImage.PixelFormat := pf24bit;

  FSelectTimer := TTimer.Create(nil);
  FSelectTimer.Interval := 1;
  FSelectTimer.Enabled := False;
  FSelectTimer.OnTimer := SelectTimerOnTimer;

  EffectsChooser := TEasyListview.Create(nil);
  EffectsChooser.Parent := AOwner as TWinControl;
  EffectsChooser.Left := 5;
  EffectsChooser.Top := 5;
  EffectsChooser.Width := 180;
  EffectsChooser.Height := EffectsChooser.Parent.Height - 75;
  EffectsChooser.Anchors := [akLeft, akTop, akRight, akBottom];
  EffectsChooser.OnItemSelectionChanged := SelectEffect;
  EffectsChooser.OnMouseMove := ListViewMouseMove;
  EffectsChooser.DoubleBuffered := True;
  EffectsChooser.EditManager.Enabled := False;
  EffectsChooser.Scrollbars.SmoothScrolling := AppSettings.Readbool('Options', 'SmoothScrolling', True);
  if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
    EffectsChooser.ShowThemedBorder := False;
  EffectsChooser.OnItemThumbnailDraw := ListViewItemThumbnailDraw;
  SetLVThumbnailSize(EffectsChooser, 130);

  SetLVSelection(EffectsChooser, False, [cmbLeft]);
  EffectsChooser.Selection.BlendIcon := False;
  EffectsChooser.Selection.FullRowSelect := True;

  FImageList := TBitmapImageList.Create;
  EffectsChooser.View := elsThumbnail;

  MakeItLink := TWebLink.Create(nil);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := EffectsChooser.Top + EffectsChooser.Height + 8;
  MakeItLink.Left := 10;
  MakeItLink.Visible := True;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.LoadFromResource('DOIT');
  MakeItLink.Anchors := [akLeft, akBottom];
  MakeItLink.RefreshBuffer(True);

  CloseLink := TWebLink.Create(nil);
  CloseLink.Parent := AOwner as TWinControl;
  CloseLink.Text := L('Close tool');
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.LoadFromResource('CANCELACTION');
  CloseLink.Anchors := [akLeft, akBottom];
  CloseLink.RefreshBuffer(True);
end;

destructor TEffectsToolPanelClass.Destroy;
begin
  F(CloseLink);
  F(EffectsChooser);
  F(FSelectTimer);
  F(MakeItLink);
  F(EM);
  F(FImageList);
  F(BaseImage);
  FreeNewImage;
  inherited;
end;

procedure TEffectsToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TEffectsToolPanelClass.ExecuteProperties(Properties: string; OnDone: TNotifyEvent);
begin
  FOnDone := OnDone;
  ApplyOnDone := True;
  SelectEffect(EffectsChooser, nil);
end;

procedure TEffectsToolPanelClass.FillEffects(OneEffectID: string = '');
var
  Item: TEasyItem;
  I: Integer;
  Bitmap, Bitmap32: TBitmap;
  ExEffect: TExEffect;
  Filter_ID: string;
begin
  EM := TEffectsManager.Create;
  EM.InitializeBaseEffects;

  BaseEffects := EM.GetBaseEffects;
  ExEffects := EM.GetExEffects;

  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := BaseImage.Width;
    Bitmap.Height := BaseImage.Height;

    Filter_ID := Copy(OneEffectID, 1, 38);
    FilterInitialString := Copy(OneEffectID, 39, Length(OneEffectID) - 38);
    OutFilterInitialString := FilterInitialString;
    for I := 0 to Length(BaseEffects) - 1 do
    begin
      if OneEffectID <> '' then
        if BaseEffects[I].ID <> Filter_ID then
          Continue;

      BaseEffects[I].Proc(BaseImage, Bitmap);
      Bitmap32 := TBitmap.Create;
      try
        DrawShadowToImage(Bitmap32, Bitmap);
        FImageList.AddBitmap(Bitmap32);
        Bitmap32 := nil;
      finally
        F(Bitmap32);
      end;

      Item := EffectsChooser.Items.Add;
      Item.ImageIndex := FImageList.Count - 1;
      Item.Data := Pointer(I);
      Item.Caption := BaseEffects[I].name;
    end;

    for I := 0 to Length(ExEffects) - 1 do
    begin
      ExEffect := ExEffects[I].Create;
      try
        if OneEffectID <> '' then
          if ExEffect.ID <> Filter_ID then
            Continue;

        ExEffect.GetPreview(BaseImage, Bitmap);

        Bitmap32 := TBitmap.Create;
        try
          DrawShadowToImage(Bitmap32, Bitmap);
          FImageList.AddBitmap(Bitmap32);
          Bitmap32 := nil;
        finally
          F(Bitmap32);
        end;

        Item := EffectsChooser.Items.Add;
        Item.ImageIndex := FImageList.Count - 1;
        Item.Data := Pointer(I + Length(BaseEffects));
        Item.Caption := ExEffect.GetName;
      finally
        F(ExEffect);
      end;
    end;

  finally
    F(Bitmap);
  end;
end;

procedure TEffectsToolPanelClass.FreeNewImage;
begin
  if Assigned(CancelPointerToImage) then
    CancelPointerToImage(NewImage);
  F(NewImage);
end;

function TEffectsToolPanelClass.GetProperties: string;
begin
  Result := FilterID + '[' + OutFilterInitialString + ']';
end;

class function TEffectsToolPanelClass.ID: string;
begin
  Result := '{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}';
end;

function TEffectsToolPanelClass.LangID: string;
begin
  Result := 'EffectsTool';
end;

procedure TEffectsToolPanelClass.ListViewMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Item: TEasyItem;
  R: TRect;
  ViewportPoint: TPoint;
begin
  ViewportPoint := Point(X, Y);
  R := EffectsChooser.Scrollbars.ViewableViewportRect;
  ViewportPoint.X := ViewportPoint.X + R.Left;
  ViewportPoint.Y := ViewportPoint.Y + R.Top;

  Item := EffectsChooser.Groups.Groups[0].ItemByPoint(ViewportPoint);

  if (Item <> nil) and Item.SelectionHitPt(ViewportPoint, eshtClickSelect) then
    EffectsChooser.Cursor := crHandPoint;
end;

procedure TEffectsToolPanelClass.ListViewItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas; ARect: TRect;
  AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  W, H: Integer;
  X, Y: Integer;
  ImageW, ImageH: Integer;
  Graphic: TBitmap;
begin
  Graphic := FImageList[Item.ImageIndex].Bitmap;

  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top + 4;
  ImageW := Graphic.Width;
  ImageH := Graphic.Height;
  ProportionalSize(W, H, ImageW, ImageH);

  X := ARect.Left + W div 2 - ImageW div 2;
  Y := ARect.Bottom - ImageH;

  Graphic.AlphaFormat := afDefined;
  ACanvas.Draw(X, Y, Graphic, 255);
end;

procedure TEffectsToolPanelClass.MakeTransform;
begin
  if NewImage <> nil then
  begin
    ImageHistory.Add(NewImage, '{' + ID + '}[' + GetProperties + ']');
    SetImagePointer(NewImage);
    NewImage := nil;
  end;
  ClosePanel;
end;

procedure TEffectsToolPanelClass.SelectEffect(Sender: TCustomEasyListview; Item: TEasyItem);
begin
  FSelectTimer.Enabled := False;
  FSelectTimer.Enabled := True;
end;

procedure TEffectsToolPanelClass.SelectTimerOnTimer(Sender: TObject);
var
  ExEffectForm: TExEffectForm;
  ExEffect: TExEffect;
  Item : TEasyItem;
begin
  FSelectTimer.Enabled := False;

  FreeNewImage;
  NewImage := TBitmap.Create;
  NewImage.PixelFormat := pf24bit;
  if ApplyOnDone = True then
  begin
    if EffectsChooser.Items.Count = 1 then
    begin
      EffectsChooser.Items[0].Selected := True;
      EffectsChooser.Items[0].Focused := True;
    end else
    begin
      if Assigned(FOnDone) then
        FOnDone(Self);
      Exit;
    end;
  end;
  Item := EffectsChooser.Selection.First;
  if Item = nil then
    Exit;
  FSID := IntToStr(Random(MaxInt));
  if Integer(Item.Data) <= Length(BaseEffects) - 1 then
  begin
    NewImage.Assign(Image);
    TempFilterID := BaseEffects[Integer(Item.Data)].ID;
    (Editor as TImageEditor).StatusBar1.Panels[1].Text := Format(L('Filter "%s" is working'), [BaseEffects[Integer(Item.Data)].name]);
    TBaseEffectThread.Create(Self, BaseEffects[Integer(Item.Data)].Proc, NewImage, FSID, SetThreadImage, Editor);
    NewImage := nil;
  end else
  begin
    Application.CreateForm(TExEffectForm, ExEffectForm);
    try
      ExEffectForm.Editor := Editor;
      ExEffect := ExEffects[Integer(Item.Data) - Length(BaseEffects)].Create;
      try
      TempFilterID := ExEffect.ID;
      (Editor as TImageEditor).StatusBar1.Panels[1].Text := Format(L('Filter "%s" is working'), [ExEffect.GetName]);

      finally
        F(ExEffect);
      end;
      OutFilterInitialString := FilterInitialString;
      if not ExEffectForm.Execute(Self, Image, NewImage, ExEffects[Integer(Item.Data) - Length(BaseEffects)],
        OutFilterInitialString) then
        NewImage := nil;
    finally
      R(ExEffectForm);
    end;
    if ApplyOnDone then
    begin
      MakeTransform;
      if Assigned(FOnDone) then
        FOnDone(Self);
    end;
  end;
end;

procedure TEffectsToolPanelClass.SetBaseImage(Image: TBitmap);
begin
  BaseImage.Assign(Image);
end;

procedure TEffectsToolPanelClass.SetNewImage(Image: TBitmap);
begin
  FilterID := TempFilterID;
  FreeNewImage;
  Pointer(NewImage) := Pointer(Image);
  SetTempImage(Image);
end;

procedure TEffectsToolPanelClass.SetProgress(Progress: Integer; SID: string);
begin
  if SID = FSID then
    (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TEffectsToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TEffectsToolPanelClass.SetThreadImage(Image: TBitmap; SID: string);
begin
  if SID = FSID then
  begin
    FilterID := TempFilterID;
    FreeNewImage;
    Pointer(NewImage) := Pointer(Image);
    SetTempImage(Image);
  end else
    F(Image);
  if ApplyOnDone then
  begin
    MakeTransform;
    if Assigned(FOnDone) then
      FOnDone(Self);
  end;
end;

{ TEffectsmanager }

function BaseEffectProcW(Proc: TBaseEffectProc; name: string; ID: string): TBaseEffectProcW;
begin
  Result.Proc := Proc;
  Result.name := name;
  Result.ID := ID;
end;

procedure TEffectsManager.AddBaseEffect(Effect: TBaseEffectProcW);
begin
  SetLength(Effects, Length(Effects) + 1);
  Effects[Length(Effects) - 1] := Effect;
end;

procedure TEffectsManager.AddExEffect(Effect: TExEffectsClass);
begin
  SetLength(ExEffects, Length(ExEffects) + 1);
  ExEffects[Length(ExEffects) - 1] := Effect;
end;

function TEffectsManager.GetBaseEffects: TBaseEffectProcedures;
begin
  Result := Effects;
end;

function TEffectsManager.GetEffectNameByID(ID: string): string;
var
  I: Integer;
  ExEffect: TExEffect;
begin
  Result := TA('Unknown');

  for I := 0 to Length(Effects) - 1 do
  begin
    if Effects[I].ID = ID then
    begin
      Result := Effects[I].name;
      Exit;
    end;
  end;

  for I := 0 to Length(ExEffects) - 1 do
  begin
    if ExEffects[I].ID = ID then
    begin
      ExEffect := ExEffects[I].Create;
      try
        Result := ExEffect.GetName;
      finally
        F(ExEffect);
      end;
      Break;
    end;
  end;
end;

function TEffectsManager.GetExEffects: TExEffects;
begin
  Result := ExEffects;
end;

procedure TEffectsManager.InitializeBaseEffects;
begin
  AddBaseEffect(BaseEffectProcW(Sepia,          L('Sepia'),              '{CA27D483-3F3D-4805-B5CE-56E3D9C3F3ED}'));
  AddBaseEffect(BaseEffectProcW(GrayScaleImage, L('Grayscale'),          '{92C0D214-A561-4AAA-937E-CD3110905524}'));
  AddBaseEffect(BaseEffectProcW(Dither,         L('Dither'),             '{0A18043D-1696-4B18-A532-8B0EE731B865}'));
  AddBaseEffect(BaseEffectProcW(Inverse,        L('Inverse'),            '{62BE35C1-3C56-4AAC-B521-46076CB1DE20}'));
  AddBaseEffect(BaseEffectProcW(AutoLevels,     L('Auto levels'),        '{F28C1B08-8C3B-4522-BE41-64998F58AC31}'));
  AddBaseEffect(BaseEffectProcW(AutoColors,     L('Auto colors'),        '{B09B7105-8FB8-4E1B-B1D5-09486B33ED5B}'));
  AddBaseEffect(BaseEffectProcW(Emboss,         L('Emboss'),             '{1262A88E-55C5-4894-873F-ED458D1CDD8C}'));
  AddBaseEffect(BaseEffectProcW(AntiAlias,      L('Smoothing'),          '{C0EF3036-EFB4-459E-A16E-6DE8AA7D6EBD}'));
  AddBaseEffect(BaseEffectProcW(OptimizeImage,  L('Optimize image'),     '{718F3546-E030-4CBF-BE61-49DAD7232B10}'));

  AddExEffect(TDisorderEffect);
  AddExEffect(TGausBlur);
  AddExEffect(TSplitBlurEffect);
  AddExEffect(TSharpen);
  AddExEffect(TPixelsEffect);
  AddExEffect(TWaveEffect);
  AddExEffect(TGrayScaleEffect);
  AddExEffect(TSepeaEffect);
  AddExEffect(TReplaceColorEffect);
  AddExEffect(TAddColorNoiseEffect);
  AddExEffect(TAddMonoNoiseEffect);
  AddExEffect(TFishEyeEffect);
  AddExEffect(TTwistEffect);
  AddExEffect(TCustomMatrixEffect);
end;

function TEffectsManager.L(StringToTranslate: string): string;
begin
  Result := TTranslateManager.Instance.SmartTranslate(StringToTranslate, 'Effects');
end;

end.
