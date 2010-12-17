unit EffectsToolUnit;

interface

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
  ComCtrls, Effects, ExEffects, Language, Dialogs, Forms, GraphicsBaseTypes,
  ExEffectsUnitW, EffectsLanguage, OptimizeImageUnit, Dolphin_DB;

type
  TEffectsManager = class(TObject)
  private
    { Private declarations }
    Effects: TBaseEffectProcedures;
    ExEffects: TExEffects;
  public
    { Public declarations }
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
    EffectsChooser: TListView;
    ImageList: TImageList;
    EM: TEffectsManager;
    BaseEffects: TBaseEffectProcedures;
    ExEffects: TExEffects;
    BaseImage: TBitmap;
    FOnDone: TNotifyEvent;
    ApplyOnDone: Boolean;
  public
   { Public declarations }
   FSID : String;
   TempFilterID : String;
   FilterID : string;
   FilterInitialString : string;
   OutFilterInitialString : string;
   class function ID: string; override;
   function GetProperties : string; override;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   Procedure ClosePanel; override;
   procedure MakeTransform; override;
   procedure ClosePanelEvent(Sender : TObject);
   procedure DoMakeImage(Sender : TObject);
   procedure SelectEffect(Sender : TObject);
   procedure SetBaseImage(Image : TBitmap);
   procedure FillEffects(OneEffectID : string = '');
   procedure SetThreadImage(Image : TBitmap; SID : string);
   procedure SetProgress(Progress : Integer; SID : string);
   procedure SetNewImage(Image : TBitmap);
   procedure EffectChooserPress(Sender: TObject; var Key: Char);
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
   Procedure SetProperties(Properties : String); override;
  end;

implementation

{ TEffectsToolPanelClass }

uses EffectsToolThreadUnit, ImEditor, ExEffectsUnit, ExEffectFormUnit;

procedure TEffectsToolPanelClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then
 OnClosePanel(Self);
 if not ApplyOnDone then
 inherited; //free!!!!!!!!!
end;

procedure TEffectsToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
 CancelTempImage(true);
 ClosePanel;
end;

constructor TEffectsToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel : TIcon;
begin
 inherited;
 NewImage:=nil;
 ApplyOnDone:=false;
 Align:=AlClient;
 BaseImage:=TBitmap.Create;
 BaseImage.PixelFormat:=pf24bit;
 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 EffectsChooser := TListView.Create(Self);;
 EffectsChooser.Parent:=AOwner as TWinControl;
 EffectsChooser.Left:=5;
 EffectsChooser.Top:=5;
 EffectsChooser.Width:=180;
 EffectsChooser.Height:=400;
 EffectsChooser.OnDblClick:=SelectEffect;
 EffectsChooser.DoubleBuffered:=True;
 EffectsChooser.ReadOnly:=True;
 EffectsChooser.HideSelection:=false;
 EffectsChooser.OnKeyPress:=EffectChooserPress;

 ImageList := TImageList.Create(Self);
 ImageList.Width:=100;
 ImageList.Height:=100;
 ImageList.BkColor:=ClWhite;
 EffectsChooser.LargeImages:=ImageList;
 EffectsChooser.ViewStyle:=vsIcon;


 MakeItLink := TWebLink.Create(Self);
 MakeItLink.Parent:=AOwner as TWinControl;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=EffectsChooser.Top+EffectsChooser.Height+8;
 MakeItLink.Left:=10;
 MakeItLink.Visible:=true;
 MakeItLink.Color:=ClBtnface;
 MakeItLink.OnClick:=DoMakeImage;
 MakeItLink.Icon:=IcoOK;
 MakeItLink.ImageCanRegenerate:=True;
 IcoOK.Free;

 CloseLink := TWebLink.Create(Self);
 CloseLink.Parent:=AOwner as TWinControl;
 CloseLink.Text:=TEXT_MES_IM_CLOSE_TOOL_PANEL;
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 CloseLink.Left:=10;
 CloseLink.Visible:=true;
 CloseLink.Color:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;
 IcoCancel.Free;

 CloseLink.ImageCanRegenerate:=True;
end;

destructor TEffectsToolPanelClass.Destroy;
begin
 CloseLink.Free;
 EffectsChooser.Free;
 MakeItLink.Free;
 EM.Free;
 ImageList.Free;
 BaseImage.Free;
 inherited;
end;

procedure TEffectsToolPanelClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TEffectsToolPanelClass.EffectChooserPress(Sender: TObject;
  var Key: Char);
begin
 if key = #13 then SelectEffect(Sender);
end;

procedure TEffectsToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
 fOnDone:=OnDone;
 ApplyOnDone:=true;
 SelectEffect(self);
end;

procedure TEffectsToolPanelClass.FillEffects(OneEffectID : string = '');
var
  item : TlistItem;
  i : integer;
  Bitmap : Tbitmap;
  ExEffect : TExEffect;
  Filter_ID : string;
begin
 EM := TEffectsManager.Create;
 EM.InitializeBaseEffects;

 BaseEffects:=EM.GetBaseEffects;
 ExEffects:=EM.GetExEffects;

 Bitmap := Tbitmap.Create;
 Bitmap.Width:=BaseImage.Width;
 Bitmap.Height:=BaseImage.Height;

 //FilterInitialString:='a'; //////////!!!!!!!!!!
 Filter_ID:=Copy(OneEffectID,1,38);
 FilterInitialString:=Copy(OneEffectID,39,Length(OneEffectID)-38);
 OutFilterInitialString:=FilterInitialString;
 for i:=0 to Length(BaseEffects)-1 do
 begin
  if OneEffectID<>'' then
  if BaseEffects[i].ID<>Filter_ID then Continue;

  BaseEffects[i].Proc(BaseImage,Bitmap);
  ImageList.Add(Bitmap,nil);
  item:=EffectsChooser.Items.Add;
  item.ImageIndex:=ImageList.Count-1;
  item.Indent:=i;
  item.Caption:=BaseEffects[i].Name;
 end;

 for i:=0 to Length(ExEffects)-1 do
 begin
  ExEffect:=ExEffects[i].Create;

  if OneEffectID<>'' then
  if ExEffect.ID<>Filter_ID then
  begin
   ExEffect.Free;
   Continue;
  end;

  ExEffect.GetPreview(BaseImage,Bitmap);
  ImageList.Add(Bitmap,nil);
  item:=EffectsChooser.Items.Add;
  item.ImageIndex:=ImageList.Count-1;
  item.Indent:=i+Length(BaseEffects);
  item.Caption:=ExEffect.GetName;
  ExEffect.Free;
 end;

 Bitmap.Free;
end;

function TEffectsToolPanelClass.GetProperties: string;
begin
 Result:=FilterID+'['+OutFilterInitialString+']';
end;

class function TEffectsToolPanelClass.ID: string;
begin
 Result:='{2AA20ABA-9205-4655-9BCE-DF3534C4DD79}';
end;

procedure TEffectsToolPanelClass.MakeTransform;
begin
// inherited;
 if NewImage<>nil then
 begin
  ImageHistory.Add(NewImage,'{'+ID+'}['+GetProperties+']');
  SetImagePointer(NewImage);
 end;
 ClosePanel;
end;

procedure TEffectsToolPanelClass.SelectEffect(Sender: TObject);
var
  item : TListItem;
  ExEffectForm : TExEffectForm;
  ExEffect : TExEffect;

begin
 NewImage := TBitmap.Create;
 NewImage.PixelFormat:=pf24bit;
 if ApplyOnDone=true then
 begin
  if EffectsChooser.Items.Count=1 then
  begin
   EffectsChooser.Items[0].Selected:=true;
   EffectsChooser.Items[0].Focused:=true;
  end else
  begin
   if Assigned(fOnDone) then fOnDone(self);
   Free;
   exit;
  end;
 end;
 item:=EffectsChooser.Selected;
 if item=nil then exit;
 FSID:=IntToStr(Random(100000));
 if item.Indent<=Length(BaseEffects)-1 then
 begin
  NewImage.Assign(Image);
  TempFilterID:=BaseEffects[item.Indent].ID;
  (Editor as TImageEditor).StatusBar1.Panels[0].Text:=Format(TEXT_MES_FILTER_WORK,[BaseEffects[item.Indent].Name]);
  TBaseEffectThread.Create(self,BaseEffects[item.Indent].Proc,NewImage,FSID,SetThreadImage,Editor);
  NewImage:=nil;
 end else
 begin
  Application.CreateForm(TExEffectForm,ExEffectForm);
  ExEffectForm.Editor:=Editor;
  ExEffect:=ExEffects[item.Indent-Length(BaseEffects)].Create;
  TempFilterID:=ExEffect.ID;
  (Editor as TImageEditor).StatusBar1.Panels[0].Text:=Format(TEXT_MES_FILTER_WORK,[ExEffect.GetName]);
  ExEffect.Free;
  OutFilterInitialString:=FilterInitialString;
  if not ExEffectForm.Execute(Self,Image,NewImage,ExEffects[item.Indent-Length(BaseEffects)],OutFilterInitialString) then
  NewImage:=nil;
  ExEffectForm.Release;

  if ApplyOnDone then
  begin
   MakeTransform;
   if Assigned(fOnDone) then fOnDone(self);
   Free;
  end;

 end;
end;

procedure TEffectsToolPanelClass.SetBaseImage(Image: TBitmap);
begin
 BaseImage.Assign(Image);
end;

procedure TEffectsToolPanelClass.SetNewImage(Image: TBitmap);
begin
 FilterID:=TempFilterID;
 Pointer(NewImage):=Pointer(Image);
 SetTempImage(Image);
end;

procedure TEffectsToolPanelClass.SetProgress(Progress: Integer;
  SID: string);
begin
 if SID=FSID then
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TEffectsToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TEffectsToolPanelClass.SetThreadImage(Image: TBitmap;
  SID: string);
begin
 if SID=FSID then
 begin
  FilterID:=TempFilterID;
  Pointer(NewImage):=Pointer(Image);
  SetTempImage(Image);
 end else Image.Free;
 if ApplyOnDone then
 begin
  MakeTransform;
  if Assigned(fOnDone) then fOnDone(self);
  Free;
 end;
end;

{ TEffectsmanager }

function BaseEffectProcW(Proc : TBaseEffectProc; Name : String; ID : string) : TBaseEffectProcW;
begin
 Result.Proc:=Proc;
 Result.Name:=Name;
 Result.ID:=ID;
end;

procedure TEffectsManager.AddBaseEffect(Effect: TBaseEffectProcW);
begin
 SetLength(Effects,length(Effects)+1);
 Effects[length(Effects)-1]:=Effect;
end;

procedure TEffectsManager.AddExEffect(Effect: TExEffectsClass);
begin
 SetLength(ExEffects,length(ExEffects)+1);
 ExEffects[length(ExEffects)-1]:=Effect;
end;

function TEffectsManager.GetBaseEffects: TBaseEffectProcedures;
begin
 Result:=Effects;
end;

function TEffectsManager.GetEffectNameByID(ID: string): string;
var
  i : integer;
  ExEffect : TExEffect;
begin
 Result:=TEXT_MES_UNKNOWN;

 for i:=0 to Length(Effects)-1 do
 begin
  if Effects[i].ID=ID then
  begin
   Result:=Effects[i].Name;
   exit;
  end;
 end;

 for i:=0 to Length(ExEffects)-1 do
 begin
  if ExEffects[i].ID=ID then
  begin
   ExEffect:=ExEffects[i].Create;
   Result:=ExEffect.GetName;
   ExEffect.Free;
   break;
  end;
 end;
end;

function TEffectsManager.GetExEffects: TExEffects;
begin
 Result:=ExEffects;
end;

procedure TEffectsManager.InitializeBaseEffects;
begin
  AddBaseEffect(BaseEffectProcW(Sepia, 'Sepia', '{CA27D483-3F3D-4805-B5CE-56E3D9C3F3ED}'));
  AddBaseEffect(BaseEffectProcW(GrayScaleImage, TEXT_MES_GRAYSCALE, '{92C0D214-A561-4AAA-937E-CD3110905524}'));
  AddBaseEffect(BaseEffectProcW(Dither, 'Dither', '{0A18043D-1696-4B18-A532-8B0EE731B865}'));
  AddBaseEffect(BaseEffectProcW(Inverse, TEXT_MES_INVERSE, '{62BE35C1-3C56-4AAC-B521-46076CB1DE20}'));
  AddBaseEffect(BaseEffectProcW(AutoLevels, TEXT_MES_AUTO_LEVELS, '{F28C1B08-8C3B-4522-BE41-64998F58AC31}'));
  AddBaseEffect(BaseEffectProcW(AutoColors, TEXT_MES_AUTO_COLORS, '{B09B7105-8FB8-4E1B-B1D5-09486B33ED5B}'));
  AddBaseEffect(BaseEffectProcW(Emboss, 'Emboss', '{1262A88E-55C5-4894-873F-ED458D1CDD8C}'));
  AddBaseEffect(BaseEffectProcW(AntiAlias, TEXT_MES_ANTIALIAS, '{C0EF3036-EFB4-459E-A16E-6DE8AA7D6EBD}'));
  AddBaseEffect(BaseEffectProcW(OptimizeImage, TEXT_MES_OPTIMIZE_IMAGE, '{718F3546-E030-4CBF-BE61-49DAD7232B10}'));

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

end.
