unit ColorToolUnit;

interface

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
     GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
     ComCtrls, Effects, Language;

type TColorToolPanelClass = Class(TToolsPanelClass)
  private
  NewImage : TBitmap;
  CloseLink : TWebLink;
  MakeItLink : TWebLink;
  ContrastLabel : TStaticText;
  ContrastTrackBar : TTrackBar;
  BrightnessLabel : TStaticText;
  BrightnessTrackBar : TTrackBar;
  RLabel : TStaticText;
  RTrackBar : TTrackBar;
  GLabel : TStaticText;
  GTrackBar : TTrackBar;
  BLabel : TStaticText;
  BTrackBar : TTrackBar;
  Loading : boolean;
  ApplyOnDone : boolean;  
  fOnDone : TNotifyEvent;
    { Private declarations }
  public
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   Procedure ClosePanel; override;
   procedure MakeTransform; override;
   procedure ClosePanelEvent(Sender : TObject);
   procedure DoMakeImage(Sender : TObject);
   procedure SetLocalProperties(Sender : TObject); 
   procedure RefreshInfo;

   function GetProperties : string; override;
   class function ID : string; override;

   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;       
   Procedure SetProperties(Properties : String); override;
   { Public declarations }
  end;

implementation

uses Dolphin_DB;

{ TColorToolPanelClass }

procedure TColorToolPanelClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(Self);
 if not ApplyOnDone then
 inherited; //free!!!!!!!!!
end;

procedure TColorToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
 CancelTempImage(true);
 ClosePanel;
end;

constructor TColorToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel : TIcon;
begin
 inherited;
 ApplyOnDone:=false;
 NewImage:=nil;
 Loading:=true;
 Align:=AlClient;
 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 ContrastLabel:=TStaticText.Create(Self);

 ContrastLabel.Top:=8;
 ContrastLabel.Left:=8;
 ContrastLabel.Caption:=TEXT_MES_CONTRAST;
 ContrastLabel.Parent:=AOwner as TWinControl;

 ContrastTrackBar := TTrackBar.Create(Self);
 ContrastTrackBar.Top:=ContrastLabel.Top+ContrastLabel.Height+5;
 ContrastTrackBar.Left:=8;
 ContrastTrackBar.Width:=161;
 ContrastTrackBar.Min:=-100;
 ContrastTrackBar.Max:=100;
 ContrastTrackBar.Position:=0;
 ContrastTrackBar.OnChange:=SetLocalProperties;
 ContrastTrackBar.Parent:=AOwner as TWinControl;

 BrightnessLabel:=TStaticText.Create(Self);
 BrightnessLabel.Top:=ContrastTrackBar.Top+ContrastTrackBar.Height+5;
 BrightnessLabel.Left:=8;
 BrightnessLabel.Caption:=TEXT_MES_BRIGHTNESS;
 BrightnessLabel.Parent:=AOwner as TWinControl;

 BrightnessTrackBar := TTrackBar.Create(Self);
 BrightnessTrackBar.Top:=BrightnessLabel.Top+BrightnessLabel.Height+5;
 BrightnessTrackBar.Left:=8;
 BrightnessTrackBar.Width:=161;
 BrightnessTrackBar.Min:=-255;
 BrightnessTrackBar.Max:=255;
 BrightnessTrackBar.Position:=0;
 BrightnessTrackBar.OnChange:=SetLocalProperties;
 BrightnessTrackBar.Parent:=AOwner as TWinControl;

 RLabel := TStaticText.Create(Self);
 RLabel.Top:=BrightnessTrackBar.Top+BrightnessTrackBar.Height+5;
 RLabel.Caption:='R';

 RTrackBar := TTrackBar.Create(Self);
 RTrackBar.Orientation:=trVertical;
 RTrackBar.Top:=RLabel.Top+RLabel.Height+5;
 RTrackBar.Left:=15;
 RTrackBar.Min:=-100;
 RTrackBar.Max:=100;
 RTrackBar.Position:=0;
 RTrackBar.OnChange:=SetLocalProperties;
 RTrackBar.Parent:=AOwner as TWinControl;

 RLabel.Left:=RTrackBar.Left;
 RLabel.Parent:=AOwner as TWinControl;

 GLabel := TStaticText.Create(Self);
 GLabel.Top:=BrightnessTrackBar.Top+BrightnessTrackBar.Height+5;
 GLabel.Caption:='G';

 GTrackBar := TTrackBar.Create(Self);
 GTrackBar.Orientation:=trVertical;
 GTrackBar.Top:=RLabel.Top+RLabel.Height+5;
 GTrackBar.Left:=RTrackBar.Left+RTrackBar.Width+5;
 GTrackBar.Min:=-100;
 GTrackBar.Max:=100;
 GTrackBar.Position:=0;
 GTrackBar.OnChange:=SetLocalProperties;
 GTrackBar.Parent:=AOwner as TWinControl;

 GLabel.Left:=GTrackBar.Left;
 GLabel.Parent:=AOwner as TWinControl;

 BLabel := TStaticText.Create(Self);
 BLabel.Top:=BrightnessTrackBar.Top+BrightnessTrackBar.Height+5;
 BLabel.Caption:='B';

 BTrackBar := TTrackBar.Create(Self);
 BTrackBar.Orientation:=trVertical;
 BTrackBar.Top:=RLabel.Top+RLabel.Height+5;
 BTrackBar.Left:=GTrackBar.Left+GTrackBar.Width+5;
 BTrackBar.Min:=-100;
 BTrackBar.Max:=100;
 BTrackBar.Position:=0;
 BTrackBar.OnChange:=SetLocalProperties;
 BTrackBar.Parent:=AOwner as TWinControl;

 BLabel.Left:=BTrackBar.Left;
 BLabel.Parent:=AOwner as TWinControl;

 MakeItLink := TWebLink.Create(Self);
 MakeItLink.Parent:=AOwner as TWinControl;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=BTrackBar.Top+BTrackBar.Height+5;
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

 Loading:=false;
 RefreshInfo;
end;

destructor TColorToolPanelClass.Destroy;
begin
 ContrastLabel.Free;
 ContrastTrackBar.Free;
 BrightnessLabel.Free;
 BrightnessTrackBar.Free;
 RTrackBar.Free;
 GTrackBar.Free;
 BTrackBar.Free;
 CloseLink.Free;
 MakeItLink.Free;
 RLabel.Free;
 GLabel.Free;
 BLabel.Free;
 inherited;
end;

procedure TColorToolPanelClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TColorToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
 fOnDone:=OnDone;
 ApplyOnDone:=true;
 Loading:=true;
 ContrastTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'Contrast'),0); 
 BrightnessTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'Brightness'),0);
 RTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'RValue'),0);
 GTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'GValue'),0);
 BTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'BValue'),0);
 Loading:=false;
 SetLocalProperties(self);
 MakeTransform;
 if Assigned(fOnDone) then fOnDone(self);
 Free;
end;

function TColorToolPanelClass.GetProperties: string;
begin
 Result:='Contrast='+IntToStr(ContrastTrackBar.Position)+';';
 Result:=Result+'Brightness='+IntToStr(BrightnessTrackBar.Position)+';';
 Result:=Result+'RValue='+IntToStr(RTrackBar.Position)+';';
 Result:=Result+'GValue='+IntToStr(GTrackBar.Position)+';';
 Result:=Result+'BValue='+IntToStr(BTrackBar.Position)+';';
end;

class function TColorToolPanelClass.ID: string;
begin
 Result:='{E20DDD6C-0E5F-4A69-A689-978763DE8A0A}';
end;

procedure TColorToolPanelClass.MakeTransform;
begin
 inherited;
 if NewImage<>nil then
 begin
  ImageHistory.Add(NewImage,'{'+ID+'}['+GetProperties+']');
  SetImagePointer(NewImage);
 end;
 ClosePanel;
end;

procedure TColorToolPanelClass.RefreshInfo;
begin
 ContrastLabel.Caption:=Format(TEXT_MES_CONTRAST,[ContrastTrackBar.Position]);
 BrightnessLabel.Caption:=Format(TEXT_MES_BRIGHTNESS,[BrightnessTrackBar.Position]);
 RLabel.Caption:=Format(TEXT_MES_R_F,[RTrackBar.Position]);
 GLabel.Caption:=Format(TEXT_MES_G_F,[GTrackBar.Position]);
 BLabel.Caption:=Format(TEXT_MES_B_F,[BTrackBar.Position]);
end;

procedure TColorToolPanelClass.SetLocalProperties(Sender: TObject);
var
  PImage : TArPARGB;
  i : integer;
  Width, Height : integer;
  ContrastValue : Extended;
  function Znak(x : extended) : extended;
  begin
   if x>=0 then Result:=1 else Result:=-1;
  end;

begin
 if Loading then exit;
 NewImage := TBitmap.Create;
 NewImage.Assign(Image);
 SetLength(PImage,NewImage.Height);
 for i:=0 to NewImage.Height-1 do
 PImage[i]:=NewImage.ScanLine[i];
 Height:=NewImage.Height;
 Width:=NewImage.Width;
 ContrastValue:=Znak(ContrastTrackBar.Position)*100*Power(Abs(ContrastTrackBar.Position)/100,2);
 Contrast(PImage,Width,Height,ContrastValue,false);
 ChangeBrightness(PImage,Width,Height,BrightnessTrackBar.Position);
 SetRGBChannelValue(PImage,Width,Height,RTrackBar.Position,GTrackBar.Position,BTrackBar.Position);
 SetTempImage(NewImage);
 RefreshInfo;
end;

procedure TColorToolPanelClass.SetProperties(Properties: String);
begin

end;

end.

