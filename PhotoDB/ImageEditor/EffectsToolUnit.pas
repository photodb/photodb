unit EffectsToolUnit;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls, Types,
  ComCtrls, Effects, ExEffects, Dialogs, Forms, GraphicsBaseTypes, uMemoryEx,
  ExEffectsUnitW, OptimizeImageUnit, UnitDBKernel, uListViewUtils, MPCommonUtilities,
  uEditorTypes, uMemory, uTranslate, EasyListView;

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
    ImageList: TImageList;
    EM: TEffectsManager;
    BaseEffects: TBaseEffectProcedures;
    ExEffects: TExEffects;
    BaseImage: TBitmap;
    FOnDone: TNotifyEvent;
    ApplyOnDone: Boolean;
    procedure FreeNewImage;
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
    procedure SelectEffect(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState; var Handled: Boolean);
    procedure SetBaseImage(Image: TBitmap);
    procedure FillEffects(OneEffectID: string = '');
    procedure SetThreadImage(Image: TBitmap; SID: string);
    procedure SetProgress(Progress: Integer; SID: string);
    procedure SetNewImage(Image: TBitmap);
    procedure EffectChooserPress(Sender: TCustomEasyListview; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    procedure SetProperties(Properties: string); override;
  end;

implementation

{ TEffectsToolPanelClass }

uses
  EffectsToolThreadUnit, ImEditor, ExEffectsUnit, ExEffectFormUnit;

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
var
  IcoOK, IcoCancel: TIcon;
begin
  inherited;
  NewImage := nil;
  ApplyOnDone := False;
  Align := AlClient;
  BaseImage := TBitmap.Create;
  BaseImage.PixelFormat := pf24bit;
  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoOK.Handle := LoadIcon(HInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(HInstance, 'CANCELACTION');

  EffectsChooser := TEasyListview.Create(nil);
  EffectsChooser.Parent := AOwner as TWinControl;
  EffectsChooser.Left := 5;
  EffectsChooser.Top := 5;
  EffectsChooser.Width := 180;
  EffectsChooser.Height := EffectsChooser.Parent.Height - 75;
  EffectsChooser.Anchors := [akLeft, akTop, akRight, akBottom];
  EffectsChooser.OnDblClick := SelectEffect;
  EffectsChooser.DoubleBuffered := True;
  EffectsChooser.EditManager.Enabled := False;
  EffectsChooser.OnKeyAction := EffectChooserPress;

  SetLVSelection(EffectsChooser, False, [cmbLeft]);
  EffectsChooser.Selection.BlendIcon := False;
  EffectsChooser.Selection.FullRowSelect := True;

  ImageList := TImageList.Create(nil);
  ImageList.Width := 100;
  ImageList.Height := 100;
  ImageList.BkColor := ClWhite;
  EffectsChooser.ImagesLarge := ImageList;
  EffectsChooser.View := elsThumbnail;

  MakeItLink := TWebLink.Create(nil);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := EffectsChooser.Top + EffectsChooser.Height + 8;
  MakeItLink.Left := 10;
  MakeItLink.Visible := True;
  MakeItLink.Color := clBtnface;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.Icon := IcoOK;
  MakeItLink.ImageCanRegenerate := True;
  MakeItLink.Anchors := [akLeft, akBottom];
  IcoOK.Free;

  CloseLink := TWebLink.Create(nil);
  CloseLink.Parent := AOwner as TWinControl;
  CloseLink.Text := L('Close tool');
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.Color := clBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.Icon := IcoCancel;
  CloseLink.ImageCanRegenerate := True;
  CloseLink.Anchors := [akLeft, akBottom];
  IcoCancel.Free;

  CloseLink.ImageCanRegenerate := True;
end;

destructor TEffectsToolPanelClass.Destroy;
begin
  F(CloseLink);
  F(EffectsChooser);
  F(MakeItLink);
  F(EM);
  F(ImageList);
  F(BaseImage);
  FreeNewImage;
  inherited;
end;

procedure TEffectsToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TEffectsToolPanelClass.EffectChooserPress(Sender: TCustomEasyListview; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
begin
  if CharCode = VK_RETURN then
    SelectEffect(Sender, cmbNone, Point(0, 0), [], DoDefault);
end;

procedure TEffectsToolPanelClass.ExecuteProperties(Properties: string; OnDone: TNotifyEvent);
var
  Handled: Boolean;
begin
  FOnDone := OnDone;
  ApplyOnDone := True;
  SelectEffect(nil, cmbNone, Point(0, 0), [], Handled);
end;

procedure TEffectsToolPanelClass.FillEffects(OneEffectID: string = '');
var
  Item: TEasyItem;
  I: Integer;
  Bitmap: Tbitmap;
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
      ImageList.Add(Bitmap, nil);
      Item := EffectsChooser.Items.Add;
      Item.ImageIndex := ImageList.Count - 1;
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
        ImageList.Add(Bitmap, nil);
        Item := EffectsChooser.Items.Add;
        Item.ImageIndex := ImageList.Count - 1;
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

procedure TEffectsToolPanelClass.SelectEffect(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState; var Handled: Boolean);
var
  Item: TEasyItem;
  ExEffectForm: TExEffectForm;
  ExEffect: TExEffect;

begin
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
  FSID := IntToStr(Random(100000));
  if Integer(Item.Data) <= Length(BaseEffects) - 1 then
  begin
    NewImage.Assign(Image);
    TempFilterID := BaseEffects[Integer(Item.Data)].ID;
    (Editor as TImageEditor).StatusBar1.Panels[0].Text := Format(L('Filter "%s" is working'), [BaseEffects[Integer(Item.Data)].name]);
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
      (Editor as TImageEditor).StatusBar1.Panels[0].Text := Format(L('Filter "%s" is working'), [ExEffect.GetName]);

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
