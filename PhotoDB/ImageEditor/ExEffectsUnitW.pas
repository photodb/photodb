unit ExEffectsUnitW;

interface

uses ExEffects, Effects, Graphics, StdCtrls, ComCtrls, GBlur2, EffectsLanguage,
     Classes, GraphicsBaseTypes, SysUtils, ExtCtrls, Controls, Dialogs;

type
  TExEffectOneParamCustom = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FTrackBar : TTrackBar;
   FTrackBarlabel : TLabel;
   FSID : String;
   FEffect: TEffectOneIntParam;
    FText: String;
    FName: String;
    FValue: Integer;
    FMax: Integer;
    procedure SetName(const Value: String);
    procedure SetText(const Value: String);
    procedure SetMax(const Value: Integer);
    procedure SetValue(const Value: Integer);
    { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  Procedure SetEffect(Effect : TEffectOneIntParam);
  Property Text : String read FText Write SetText;
  Property Name : String read FName Write SetName;
  Property Max : Integer read FMax Write SetMax;
  Property Value: Integer read FValue Write SetValue;
   { Public declarations }
  end;

type
  TExEffectOneParamCustomThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FInt : Integer;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FEffect : TEffectOneIntParam;
    FProgress : integer;
    FBreak : boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; Effect : TEffectOneIntParam; CreateSuspended: Boolean; S : TBitmap; Int: Integer; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break : boolean);
    procedure ImageProgressSynch;
  end;

type
  TGrayScaleEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
   { Public declarations }
  end;

type
  TSepeaEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
   { Public declarations }
  end;

type
  TAddColorNoiseEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
   { Public declarations }
  end;

type
  TAddMonoNoiseEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
   { Public declarations }
  end;

type
  TFishEyeEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
  function GetBestValue: integer; override;
   { Public declarations }
  end;

type
  TSplitBlurEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
  function GetBestValue : integer; override;
   { Public declarations }
  end;

type
  TTwistEffect = class(TExEffectOneParamCustom)
  private
   { Private declarations }
  public
  class function ID : ShortString; override;
  constructor Create; override;
  destructor Destroy; override;
  function GetBestValue : integer; override;
   { Public declarations }
  end;

implementation

uses ImEditor;

{ TExEffectOneParamCustom }

constructor TExEffectOneParamCustom.Create;
begin
 Inherited;
 GOM.AddObj(Self);
 FTrackBar := nil ;
 FTrackBarlabel := nil ;
end;

destructor TExEffectOneParamCustom.Destroy;
begin
 GOM.RemoveObj(Self);
 if FTrackBar<>nil then FTrackBar.Free;
 if FTrackBarlabel<>nil then FTrackBarlabel.Free;
 inherited;
end;

function TExEffectOneParamCustom.Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean): boolean;
begin
 FS:=S;
 FD:=D;
 Panel.Caption:=GetName;
 FTrackBarlabel:= TLabel.Create(Panel);
 FTrackBarlabel.Parent:=Panel;
 FTrackBarlabel.Top:=20;
 FTrackBarlabel.Left:=8;
 FTrackBar:= TTrackBar.Create(nil);
 FTrackBar.Parent:=Panel;
 FTrackBar.Top:=FTrackBarlabel.Top+FTrackBarlabel.Height+5;
 FTrackBar.Max:=FMax;
 FTrackBar.Position:=FValue;
 FTrackBar.Left:=8;
 FTrackBar.Min:=1;
 FTrackBar.Width:=250;
 FTrackBar.OnChange:=MakeImage;
 MakeImage(Self);
 Result:=true;
end;

procedure TExEffectOneParamCustom.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TExEffectOneParamCustom.GetName: String;
begin
 Result:=FName;
end;

procedure TExEffectOneParamCustom.GetPreview(S, D: TBitmap);
begin
 if GetBestValue<0 then
 FEffect(S,D,50) else FEffect(S,D,GetBestValue);
end;

class function TExEffectOneParamCustom.ID: ShortString;
begin
  Result:='{99AB2B0A-B2A9-461D-A4E4-F799442E8A58}';
end;

procedure TExEffectOneParamCustom.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FTrackBarlabel.Caption:=Format(FText,[FTrackBar.Position]);
 FSID:=IntToStr(random(100000));
 TExEffectOneParamCustomThread.Create(self,FEffect,false,D,FTrackBar.Position,FSID,ExitThread);
end;

procedure TExEffectOneParamCustom.Progress(Progress: integer;
  var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TExEffectOneParamCustom.SetEffect(Effect: TEffectOneIntParam);
begin
  FEffect := Effect;
end;

procedure TExEffectOneParamCustom.SetMax(const Value: Integer);
begin
  FMax := Value;
end;

procedure TExEffectOneParamCustom.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TExEffectOneParamCustom.SetText(const Value: String);
begin
  FText := Value;
end;

procedure TExEffectOneParamCustom.SetValue(const Value: Integer);
begin
  FValue := Value;
  FTrackBar.Position:=Value;
end;

{ TExEffectOneParamCustomThread }

constructor TExEffectOneParamCustomThread.Create(AOwner: TObject;
  Effect: TEffectOneIntParam; CreateSuspended: Boolean; S: TBitmap;
  Int: Integer; SID: string; OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(True);
 FAOwner := AOwner;
 FEffect:=Effect;
 FS := S;
 FInt := Int;
 FSID := SID;
 FOnExit := OnExit;
 if not CreateSuspended then Resume;
end;

procedure TExEffectOneParamCustomThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TExEffectOneParamCustom).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 FEffect(FS,New,FInt,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TExEffectOneParamCustomThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure  TExEffectOneParamCustomThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TExEffectOneParamCustom).FSID=FSID then
 (FAOwner as TExEffectOneParamCustom).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TExEffectOneParamCustomThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TGrayScaleEffect }

constructor TGrayScaleEffect.Create;
begin
  inherited;
  SetEffect(GrayScaleImage);
  Name:=TEXT_MES_CUSTOM_GRAYSCALE;
  Text:=TEXT_MES_GRAYSCALE_TEXT;
  FMax:=100;
  FValue:=50;
end;

destructor TGrayScaleEffect.Destroy;
begin
  inherited;
end;

class function TGrayScaleEffect.ID: ShortString;
begin
 Result:='{BE5AE21F-5F27-4ADE-AAAF-FB9A8F591C08}';
end;

{ TSepeaEffect }

constructor TSepeaEffect.Create;
begin
  inherited;
  SetEffect(Sepia);
  Name:=TEXT_MES_CUSTOM_SEPIA;
  Text:=TEXT_MES_SEPIA_TEXT;
  FMax:=100;
  FValue:=50;
end;

destructor TSepeaEffect.Destroy;
begin

  inherited;
end;

class function TSepeaEffect.ID: ShortString;
begin
 Result:='{DE6F7AEB-BDE7-4D36-859A-656645A7FBBC}';
end;

{ TAddColorNoiseEffect }

constructor TAddColorNoiseEffect.Create;
begin
  inherited;
  SetEffect(AddColorNoise);
  Name:=TEXT_MES_COLOR_NOISE;
  Text:=TEXT_MES_COLOR_NOISE+' [%d]';
  FMax:=100;
  FValue:=50;
end;

destructor TAddColorNoiseEffect.Destroy;
begin

  inherited;
end;

class function TAddColorNoiseEffect.ID: ShortString;
begin
 Result:='{4FFBD84A-DA88-4A50-96CF-929951489DB8}';
end;

{ TAddMonoNoiseEffect }

constructor TAddMonoNoiseEffect.Create;
begin
  inherited;
  SetEffect(AddMonoNoise);
  Name:=TEXT_MES_MONO_NOISE;
  Text:=TEXT_MES_MONO_NOISE+' [%d]';
  FMax:=100;
  FValue:=50;
end;

destructor TAddMonoNoiseEffect.Destroy;
begin

  inherited;
end;

class function TAddMonoNoiseEffect.ID: ShortString;
begin
Result:='{483B513B-2EAD-467C-A738-9A3B7BF446D0}';
end;

{ TFishEyeEffect }

constructor TFishEyeEffect.Create;
begin
  inherited;
  SetEffect(FishEye);
  Name:=TEXT_MES_FISH_EYE;
  Text:=TEXT_MES_FISH_EYE+' [%d]';
  FMax:=100;
  FValue:=10;
end;

destructor TFishEyeEffect.Destroy;
begin

  inherited;
end;

function TFishEyeEffect.GetBestValue: integer;
begin
 Result:=20;
end;

class function TFishEyeEffect.ID: ShortString;
begin
 Result:='{1FED9DDE-0B92-48B8-8C73-1D90901A8DE9}';
end;

{ TSplitBlurEffect }

constructor TSplitBlurEffect.Create;
begin
  inherited;
  SetEffect(SplitBlur);
  Name:=TEXT_MES_SPLIT_BLUR;
  Text:=TEXT_MES_SPLIT_BLUR+' [%d]';
  FMax:=100;
  FValue:=5;
end;

destructor TSplitBlurEffect.Destroy;
begin

  inherited;
end;

function TSplitBlurEffect.GetBestValue: integer;
begin
 Result:=10;
end;

class function TSplitBlurEffect.ID: ShortString;
begin
 Result:='{1017603E-3059-4604-9AFD-E942F1C8B38E}';
end;

{ TTwistEffect }

constructor TTwistEffect.Create;
begin
  inherited;
  SetEffect(Twist);
  Name:=TEXT_MES_TWIST;
  Text:=TEXT_MES_TWIST+' [%d]';
  FMax:=1000;
  FValue:=100;
end;

destructor TTwistEffect.Destroy;
begin

  inherited;
end;

function TTwistEffect.GetBestValue: integer;
begin
 Result:=10;
end;

class function TTwistEffect.ID: ShortString;
begin
 Result:='{33EC7CD0-5512-490C-AE6E-4D38C564BF3E}';
end;

end.
