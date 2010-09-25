unit ExEffectsUnit;

{$DEFINE PHOTODB}

interface

uses Windows, ExEffects, Effects, Graphics, StdCtrls, ComCtrls, GBlur2,
     Classes, GraphicsBaseTypes, SysUtils, ExtCtrls, Controls, Dialogs,
     EffectsLanguage, Forms, OptimizeImageUnit
{$IFDEF PHOTODB}
     , Dolphin_DB, uGOM
{$ENDIF}
     ;

type
  TGausBlur = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FTrackBar : TTrackBar;
   FTrackBarlabel : TLabel;
   FSID : String;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TGaussBlurThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FRadius : Double;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak: boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; S : TBitmap; Radius : Double; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: boolean);
    procedure ImageProgressSynch;
  end;

type
  TSharpen = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FTrackBar : TTrackBar;
   FTrackBarlabel : TLabel;
   FSID : String;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TSharpenThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FEffectSize : integer;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak : Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; S : TBitmap; EffectSize: integer; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: Boolean);
    procedure ImageProgressSynch;
  end;

type
  TPixelsEffect = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FTrackBarWidth : TTrackBar;
   FTrackBarWidthlabel : TLabel;
   FTrackBarHeight : TTrackBar;
   FTrackBarHeightlabel : TLabel;
   FSID : String;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TPixelsEffectThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FWidth : integer;
    FHeight : integer;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak : boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; CreateSuspended: Boolean; S : TBitmap; Width, Height: integer; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break : boolean);
    procedure ImageProgressSynch;
  end;

type
  TWaveEffect = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FTrackBarFrequency : TTrackBar;
   FTrackBarFrequencyLabel : TLabel;
   FTrackBarLength : TTrackBar;
   FTrackBarLengthLabel : TLabel;
   FHorizontal : TCheckBox;
   ColorChooser : TShape;
   ColorChooserLabel : TLabel;
   ColorDialog : TColorDialog;
   FSID : String;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  procedure ColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TWaveEffectThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FFrequency, FLength: integer;
    FHorizontal : Boolean;
    FBkColor : TColor;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak : boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; CreateSuspended: Boolean; S : TBitmap; Frequency, Length: integer; Horizontal : Boolean; BkColor : TColor; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: boolean);
    procedure ImageProgressSynch;
  end;

//<<...TDisorderEffect...>>
type
  TDisorderEffect = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FDisorderLengthW : TTrackBar;
   FDisorderLengthWLabel : TLabel;
   FDisorderLengthH : TTrackBar;
   FDisorderLengthHLabel : TLabel;
   ColorChooser : TShape;
   ColorChooserLabel : TLabel;
   ColorDialog : TColorDialog;
   FSID : String;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  procedure ColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TDisorderEffectThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FW, FH: integer;
    FBkColor : TColor;
    FSID : string;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak: boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; CreateSuspended: Boolean; S : TBitmap; W,H: integer; BkColor : TColor; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: boolean);
    procedure ImageProgressSynch;
  end;
//>>...TDisorderEffect...<<

//<<...TReplaceColorEffect...>>
type
  TReplaceColorEffect = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FReplaceColorValue : TTrackBar;
   FReplaceColorValueLabel : TLabel;
   FReplaceColorSize : TTrackBar;
   FReplaceColorSizeLabel : TLabel;
   ColorBaseChooser : TShape;
   ColorBaseChooserLabel : TLabel;
   ColorToChooser : TShape;
   ColorToChooserLabel : TLabel;
   ColorDialog : TColorDialog;
   FButtonCustomColor : TButton;
   FSID : String;
   FButtonPressed : Boolean;
   Loading : Boolean;
    { Private declarations }
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  procedure ColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  procedure ButtonMouseMove(Sender: TObject; Shift: TShiftState;
    X, Y: Integer);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TReplaceColorEffectThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FSize : Integer;
    FColorBase, FColorNew : TColor;
    FSID : string;
    FValue : Integer;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; S : TBitmap; ColorBase, ColorNew: TColor; Size, Value : Integer; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: boolean);
    procedure ImageProgressSynch;
  end;
//>>...TReplaceColorEffect...<<


//<<...TCustomMatrixEffect...>>
type
  TCustomMatrixEffect = class(TExEffect)
  private
   FS,FD : Tbitmap;
   FSID : String;
   FButtonPressed : Boolean;
   Lock : Boolean;
   LabelMatrix : TLabel;
   E : array[1..5,1..5] of TEdit;
   DeviderLabel : TLabel;
   DeviderEdit : TEdit;
   FSampleEffectLabel : TLabel;
   FSampleEffect : TComboBox;

   SaveNameEditLabel : TLabel;
   SaveNameEdit : TEdit;
   SaveCurrentButton : TButton;
   PresentComboBox : TComboBox;
   LoadSelectedButton : TButton;
   DeleteSelectedButton : TButton;

    { Private declarations }
   procedure RefreshButtons;
   procedure LoadPresentClick(Sender : TObject);
   procedure SavePresentClick(Sender : TObject);
   procedure DeletePresentClick(Sender : TObject);
   procedure PresentSelect(Sender : TObject);
   procedure ReloadUserPresents;
  public
  class function ID : string; override;
  constructor Create; override;
  destructor Destroy; override;
  function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; override;
  function GetName : String; override;
  Procedure GetPreview(S,D : TBitmap); override;
  Procedure MakeImage(Sender : TObject);
  Procedure Progress(Progress : integer; var Break: boolean);
  Procedure ExitThread(Image : TBitmap; SID : string);
  Procedure ParamsChanged(Sender : TObject);
  Procedure FillMatrix(Sender : TObject);
  function GetProperties : string; override;
  procedure SetProperties(Properties : string); override;
   { Public declarations }
  end;

type
  TCustomMatrixEffectThread = class(TThread)
  private
    { Private declarations }
    FAOwner : TObject;
    FS : TBitmap;
    FSID : string;
    FM : TConvolutionMatrix;
    FOnExit : TBaseEffectProcThreadExit;
    FProgress : integer;
    FBreak : boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; CreateSuspended: Boolean; S : TBitmap; M : TConvolutionMatrix; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break : boolean);
    procedure ImageProgressSynch;
  end;
//>>...TCustomMatrixEffect...<<


implementation

uses ImEditor;

{ TGausBlur }

constructor TGausBlur.Create;
begin
 Inherited;
 GOM.AddObj(Self);
 FTrackBar := nil ;
 FTrackBarlabel := nil ;
end;

destructor TGausBlur.Destroy;
begin
 GOM.RemoveObj(Self);
 if FTrackBar<>nil then FTrackBar.Free;
 if FTrackBarlabel<>nil then FTrackBarlabel.Free;
 inherited;
end;

function TGausBlur.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Extended;
begin
 FS:=S;
 FD:=D;
 x:=0;
 Panel.Caption:=GetName;
 FTrackBarlabel:= TLabel.Create(Panel);
 FTrackBarlabel.Parent:=Panel;
 FTrackBarlabel.Top:=20;
 FTrackBarlabel.Left:=8;
 FTrackBarlabel.Caption:=Format(EFF_TEXT_MES_GAUSS_BLUR_RADIUS,[x]);
 FTrackBar:= TTrackBar.Create(Panel);
 FTrackBar.Parent:=Panel;
 FTrackBar.Top:=FTrackBarlabel.Top+FTrackBarlabel.Height+5;
 FTrackBar.Left:=8;
 FTrackBar.Min:=1;
 FTrackBar.Position:=20;
 FTrackBar.Max:=200;
 FTrackBar.Width:=250;
 FTrackBar.OnChange:=MakeImage;
 if aMakeImage then
 MakeImage(Self);
 Result:=true;
end;

procedure TGausBlur.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TGausBlur.GetName: String;
begin
 Result:=EFF_TEXT_MES_GAUSS_BLUR;
end;

procedure TGausBlur.GetPreview(S, D: TBitmap);
begin
 D.Assign(S);
 GBlur(D,3);
end;

function TGausBlur.GetProperties: string;
begin
 Result:='EffectSize='+IntToStr(FTrackBar.Position)+';';
end;

class function TGausBlur.ID: string;
begin
 Result:='{C7DB416B-BD8E-4F7D-8A44-309C4FA9B451}';
end;

procedure TGausBlur.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FTrackBarlabel.Caption:=Format(EFF_TEXT_MES_GAUSS_BLUR_RADIUS,[FTrackBar.Position/10]);
 FSID:=IntToStr(random(10000));
 TGaussBlurThread.Create(self,D,FTrackBar.Position/10,FSID,ExitThread);
end;

procedure TGausBlur.Progress(Progress: integer; var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
// MakeImage(self);
end;

procedure TGausBlur.SetProperties(Properties: string);
begin
 FTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'EffectSize'),1);
end;

{ TGaussBlurThread }

constructor TGaussBlurThread.Create(AOwner: TObject;
  S: TBitmap; Radius: Double; SID: string;
  OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(False);
 FAOwner := AOwner;
 FS := S;
 FRadius := Radius;
 FSID := SID;
 FOnExit := OnExit;
end;

procedure TGaussBlurThread.Execute;
var
  b : boolean;
begin
 Sleep(300);
 FreeOnTerminate:=true;
 if (FAOwner as TGausBlur).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 ImageProgress(1,b);
 GBlur(FS,FRadius,ImageProgress);
 Synchronize(OnExit);
end;

procedure TGaussBlurThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TGaussBlurThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TGausBlur).FSID=FSID then
 (FAOwner as TGausBlur).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TGaussBlurThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TSharpenThread }

constructor TSharpenThread.Create(AOwner: TObject;
  S: TBitmap; EffectSize: integer; SID: string;
  OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FEffectSize := EffectSize;
  FSID := SID;
  FOnExit := OnExit;
end;

procedure TSharpenThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TSharpen).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 Sharpen(FS,New,FEffectSize/10,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TSharpenThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TSharpenThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TSharpen).FSID=FSID then
 (FAOwner as TSharpen).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TSharpenThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TSharpen }

constructor TSharpen.Create;
begin
 inherited;
 GOM.AddObj(Self);
 FTrackBar := nil ;
 FTrackBarlabel := nil ;
end;

destructor TSharpen.Destroy;
begin
 GOM.RemoveObj(Self);
 if FTrackBar<>nil then FTrackBar.Free;
 if FTrackBarlabel<>nil then FTrackBarlabel.Free;
 inherited;
end;

function TSharpen.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Extended;
begin
 FS:=S;
 FD:=D;
 x:=0;
 Panel.Caption:=GetName;
 FTrackBarlabel:= TLabel.Create(Panel);
 FTrackBarlabel.Parent:=Panel;
 FTrackBarlabel.Top:=20;
 FTrackBarlabel.Left:=8;
 FTrackBarlabel.Caption:=Format(EFF_TEXT_MES_SHARPEN_EFFECT_SIZE,[x]);
 FTrackBar:= TTrackBar.Create(Panel);
 FTrackBar.Parent:=Panel;
 FTrackBar.Top:=FTrackBarlabel.Top+FTrackBarlabel.Height+5;
 FTrackBar.Left:=8;
 FTrackBar.Min:=0;
 FTrackBar.Max:=30;
 FTrackBar.Position:=10;
 FTrackBar.Width:=250;
 FTrackBar.OnChange:=MakeImage;
 if aMakeImage then
 MakeImage(Self);
 Result:=true;
end;

procedure TSharpen.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TSharpen.GetName: String;
begin
 Result:=TEXT_MES_SHARPEN;
end;

procedure TSharpen.GetPreview(S, D: TBitmap);
begin
 Sharpen(S,D,5);
end;

function TSharpen.GetProperties: string;
begin
 Result:='EffectSize='+IntToStr(FTrackBar.Position)+';';
end;

class function TSharpen.ID: string;
begin
 Result:='{27FEBBB0-C8F5-4493-A1EA-928221CEDB49}';
end;

procedure TSharpen.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FTrackBarlabel.Caption:=Format(EFF_TEXT_MES_SHARPEN_EFFECT_SIZE,[FTrackBar.Position/10]);
 FSID:=IntToStr(random(10000));
 TSharpenThread.Create(self,D,FTrackBar.Position+20,FSID,ExitThread);
end;

procedure TSharpen.Progress(Progress: integer; var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TSharpen.SetProperties(Properties: string);
begin
 FTrackBar.Position:=StrToIntDef(GetValueByName(Properties,'EffectSize'),1);
 MakeImage(self);
end;

{ TPixelsEffect }

constructor TPixelsEffect.Create;
begin
 inherited;
 GOM.AddObj(Self);
 FTrackBarWidth := nil;
 FTrackBarWidthlabel := nil;
 FTrackBarHeight := nil;
 FTrackBarHeightlabel := nil;
end;

destructor TPixelsEffect.Destroy;
begin
 GOM.RemoveObj(Self);
  if FTrackBarWidth<>nil then FTrackBarWidth.Free;
  if FTrackBarWidthlabel<>nil then FTrackBarWidthlabel.Free;
  if FTrackBarHeight<>nil then FTrackBarHeight.Free;
  if FTrackBarHeightlabel<>nil then FTrackBarHeightlabel.Free;
 inherited;
end;

function TPixelsEffect.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Integer;
begin
 FS:=S;
 FD:=D;
 x:=1;
 Panel.Caption:=GetName;
 FTrackBarWidthlabel:= TLabel.Create(Panel);
 FTrackBarWidthlabel.Parent:=Panel;
 FTrackBarWidthlabel.Top:=20;
 FTrackBarWidthlabel.Left:=8;
 FTrackBarWidthlabel.Caption:=Format(TEXT_MES_WIDTH_F,[x]);
 FTrackBarWidth:= TTrackBar.Create(Panel);
 FTrackBarWidth.Parent:=Panel;
 FTrackBarWidth.Top:=FTrackBarWidthlabel.Top+FTrackBarWidthlabel.Height+5;
 FTrackBarWidth.Left:=8;
 FTrackBarWidth.Min:=1;
 FTrackBarWidth.Max:=30;
 FTrackBarWidth.Position:=3;
 FTrackBarWidth.Width:=250;
 FTrackBarWidth.OnChange:=MakeImage;

 FTrackBarHeightlabel:= TLabel.Create(Panel);
 FTrackBarHeightlabel.Parent:=Panel;
 FTrackBarHeightlabel.Top:=FTrackBarWidth.Top+FTrackBarWidth.Height+5;
 FTrackBarHeightlabel.Left:=8;
 FTrackBarHeightlabel.Caption:=Format(TEXT_MES_HEIGHT_F,[x]);
 FTrackBarHeight:= TTrackBar.Create(Panel);
 FTrackBarHeight.Parent:=Panel;
 FTrackBarHeight.Top:=FTrackBarHeightlabel.Top+FTrackBarHeightlabel.Height+5;
 FTrackBarHeight.Left:=8;
 FTrackBarHeight.Min:=1;
 FTrackBarHeight.Max:=30;
 FTrackBarHeight.Position:=3;
 FTrackBarHeight.Width:=250;
 FTrackBarHeight.OnChange:=MakeImage;

 Result:=true;
 if aMakeImage then
 MakeImage(Self);
end;

procedure TPixelsEffect.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TPixelsEffect.GetName: String;
begin
 Result:=TEXT_MES_PIXEL_EFFECT;
end;

procedure TPixelsEffect.GetPreview(S, D: TBitmap);
begin
 PixelsEffect(S,D,3,3);
end;

function TPixelsEffect.GetProperties: string;
begin
 Result:='EffectWidthSize='+IntToStr(FTrackBarWidth.Position)+';';
 Result:=Result+'EffectHeightSize='+IntToStr(FTrackBarHeight.Position)+';';
end;

class function TPixelsEffect.ID: string;
begin
 Result:='{4F530D08-B94C-4C5A-8C84-DF61210F414D}';
end;

procedure TPixelsEffect.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FTrackBarWidthlabel.Caption:=Format(TEXT_MES_WIDTH_F,[FTrackBarWidth.Position]);
 FTrackBarHeightlabel.Caption:=Format(TEXT_MES_HEIGHT_F,[FTrackBarHeight.Position]);
 FSID:=IntToStr(random(10000));
 TPixelsEffectThread.Create(self,false,D,FTrackBarWidth.Position,FTrackBarHeight.Position,FSID,ExitThread);
end;

procedure TPixelsEffect.Progress(Progress: integer; var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TPixelsEffect.SetProperties(Properties: string);
begin
 FTrackBarWidth.Position:=StrToIntDef(GetValueByName(Properties,'EffectWidthSize'),1);
 FTrackBarHeight.Position:=StrToIntDef(GetValueByName(Properties,'EffectHeightSize'),1);
 MakeImage(self);
end;

{ TPixelsEffectThread }

constructor TPixelsEffectThread.Create(AOwner: TObject;
  CreateSuspended: Boolean; S: TBitmap; Width, Height: integer;
  SID: string; OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(True);
 FAOwner := AOwner;
 FS := S;
 FWidth := Width;
 FHeight := Height;
 FSID := SID;
 FOnExit := OnExit;
 if not CreateSuspended then Resume;
end;

procedure TPixelsEffectThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TPixelsEffect).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 PixelsEffect(FS,New,FWidth,FHeight,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TPixelsEffectThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TPixelsEffectThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TPixelsEffect).FSID=FSID then
 (FAOwner as TPixelsEffect).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TPixelsEffectThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TWaveEffect }

procedure TWaveEffect.ColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog.Color:=ColorChooser.Brush.Color;
 if ColorDialog.Execute then
 begin
  ColorChooser.Brush.Color:=ColorDialog.Color;
  MakeImage(Sender);
 end;
end;

constructor TWaveEffect.Create;
begin
 inherited;
 GOM.AddObj(Self);
end;

destructor TWaveEffect.Destroy;
begin
 GOM.RemoveObj(Self);
 inherited;
end;

function TWaveEffect.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Integer;
begin
 FS:=S;
 FD:=D;
 x:=1;
 Panel.Caption:=GetName;
 FTrackBarFrequencylabel:= TLabel.Create(Panel);
 FTrackBarFrequencylabel.Parent:=Panel;
 FTrackBarFrequencylabel.Top:=20;
 FTrackBarFrequencylabel.Left:=8;
 FTrackBarFrequencylabel.Caption:=Format(TEXT_MES_WIDTH_F,[x]);
 FTrackBarFrequency:= TTrackBar.Create(Panel);
 FTrackBarFrequency.Parent:=Panel;
 FTrackBarFrequency.Top:=FTrackBarFrequencylabel.Top+FTrackBarFrequencylabel.Height+5;
 FTrackBarFrequency.Left:=8;
 FTrackBarFrequency.Min:=1;
 FTrackBarFrequency.Max:=30;
 FTrackBarFrequency.Position:=3;
 FTrackBarFrequency.Width:=250;
 FTrackBarFrequency.OnChange:=MakeImage;

 FTrackBarLengthlabel:= TLabel.Create(Panel);
 FTrackBarLengthlabel.Parent:=Panel;
 FTrackBarLengthlabel.Top:=FTrackBarFrequency.Top+FTrackBarFrequency.Height+5;
 FTrackBarLengthlabel.Left:=8;
 FTrackBarLengthlabel.Caption:=Format(TEXT_MES_HEIGHT_F,[x]);
 FTrackBarLength:= TTrackBar.Create(Panel);
 FTrackBarLength.Parent:=Panel;
 FTrackBarLength.Top:=FTrackBarLengthlabel.Top+FTrackBarLengthlabel.Height+5;
 FTrackBarLength.Left:=8;
 FTrackBarLength.Min:=1;
 FTrackBarLength.Max:=30;
 FTrackBarLength.Position:=3;
 FTrackBarLength.Width:=250;
 FTrackBarLength.OnChange:=MakeImage;

 FHorizontal := TCheckBox.Create(Panel);
 FHorizontal.Parent:=Panel;
 FHorizontal.Top:=FTrackBarLength.Top+FTrackBarLength.Height+5;
 FHorizontal.Left:=8;
 FHorizontal.Width:=250;
 FHorizontal.Caption:=TEXT_MES_WAVE_HORIZONTAL;
 FHorizontal.OnClick:=MakeImage;

 ColorChooser:=TShape.Create(Panel);
 ColorChooser.Parent:=Panel;
 ColorChooser.Top:=FHorizontal.Top+FHorizontal.Height+5;
 ColorChooser.Left:=8;
 ColorChooser.Width:=17;
 ColorChooser.Height:=17;
 ColorChooser.OnMouseDown:=ColorMouseDown;
 ColorChooser.Brush.Color:=$0;
 ColorDialog := TColorDialog.Create(Panel);

 ColorChooserLabel := TLabel.Create(Panel);
 ColorChooserLabel.Parent:=Panel;
 ColorChooserLabel.Top:=FHorizontal.Top+FHorizontal.Height+8;
 ColorChooserLabel.Left:=ColorChooser.Left+ColorChooser.Width+5;
 ColorChooserLabel.Caption:=TEXT_MES_BK_COLOR;

 Result:=true;
 MakeImage(self);
end;

procedure TWaveEffect.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TWaveEffect.GetName: String;
begin
 Result:=TEXT_MES_WAVE;
end;

procedure TWaveEffect.GetPreview(S, D: TBitmap);
begin
 WaveSin(S,D,10,10,true,$FFFFFF);
end;

function fBoolToStr(b : boolean) : string;
begin
 if b then Result:='TRUE' else Result:='FALSE';
end;

function TWaveEffect.GetProperties: string;
begin
 Result:='Frequency='+IntToStr(FTrackBarFrequency.Position)+';';
 Result:=Result+'Length='+IntToStr(FTrackBarLength.Position)+';';
 Result:=Result+'Horizontal='+fBoolToStr(FHorizontal.Checked)+';';
 Result:=Result+'Color='+IntToStr(ColorChooser.Brush.Color)+';';
end;

class function TWaveEffect.ID: string;
begin
 Result:='{9E1AE930-6903-497B-AA2F-CFABE87A10B8}';
end;

procedure TWaveEffect.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FTrackBarFrequencylabel.Caption:=Format(TEXT_MES_FREQUENCY_F,[FTrackBarFrequency.Position]);
 FTrackBarLengthlabel.Caption:=Format(TEXT_MES_LENGTH_F,[FTrackBarLength.Position]);
 FSID:=IntToStr(random(10000));
 TWaveEffectThread.Create(self,false,D,FTrackBarLength.Position,FTrackBarFrequency.Position,FHorizontal.Checked,ColorChooser.Brush.Color,FSID,ExitThread);
end;

procedure TWaveEffect.Progress(Progress: integer; var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TWaveEffect.SetProperties(Properties: string);
begin
 FTrackBarFrequency.Position:=StrToIntDef(GetValueByName(Properties,'Frequency'),1);
 FTrackBarLength.Position:=StrToIntDef(GetValueByName(Properties,'Length'),1);
 FHorizontal.Checked:=GetBoolValueByName(Properties,'Color',true);
 ColorChooser.Brush.Color:=GetIntValueByName(Properties,'Color',1);
 MakeImage(self);
end;

{ TWaveEffectThread }

constructor TWaveEffectThread.Create(AOwner: TObject;
  CreateSuspended: Boolean; S: TBitmap; Frequency, Length: integer;
  Horizontal: Boolean; BkColor: TColor; SID: string;
  OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(True);
 FAOwner := AOwner;
 FS := S;
 FFrequency:=Frequency;
 FLength:=Length;
 FHorizontal:=Horizontal;
 FBkColor:=BkColor;
 FSID := SID;
 FOnExit := OnExit;
 if not CreateSuspended then Resume;
end;

procedure TWaveEffectThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TWaveEffect).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 WaveSin(FS,New,FFrequency,FLength,FHorizontal,FBkColor,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TWaveEffectThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TWaveEffectThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TWaveEffect).FSID=FSID then
 (FAOwner as TWaveEffect).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TWaveEffectThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TDisorderEffect }

procedure TDisorderEffect.ColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog.Color:=ColorChooser.Brush.Color;
 if ColorDialog.Execute then
 begin
  ColorChooser.Brush.Color:=ColorDialog.Color;
  MakeImage(Sender);
 end;
end;

constructor TDisorderEffect.Create;
begin
 inherited;
 GOM.AddObj(Self);
end;

destructor TDisorderEffect.Destroy;
begin
 GOM.RemoveObj(Self);
 inherited;
end;

function TDisorderEffect.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Integer;
begin
 FS:=S;
 FD:=D;
 x:=1;
 Panel.Caption:=GetName;
 FDisorderLengthWLabel:= TLabel.Create(Panel);
 FDisorderLengthWLabel.Parent:=Panel;
 FDisorderLengthWLabel.Top:=20;
 FDisorderLengthWLabel.Left:=8;
 FDisorderLengthWLabel.Caption:=Format(TEXT_MES_HORIZONTAL_DISORDER,[x]);
 FDisorderLengthW:= TTrackBar.Create(Panel);
 FDisorderLengthW.Parent:=Panel;
 FDisorderLengthW.Top:=FDisorderLengthWLabel.Top+FDisorderLengthWLabel.Height+5;
 FDisorderLengthW.Left:=8;
 FDisorderLengthW.Min:=1;
 FDisorderLengthW.Max:=250;
 FDisorderLengthW.Position:=5;
 FDisorderLengthW.Width:=250;
 FDisorderLengthW.OnChange:=MakeImage;

 FDisorderLengthHLabel:= TLabel.Create(Panel);
 FDisorderLengthHLabel.Parent:=Panel;
 FDisorderLengthHLabel.Top:=FDisorderLengthW.Top+FDisorderLengthW.Height+5;
 FDisorderLengthHLabel.Left:=8;
 FDisorderLengthHLabel.Caption:=Format(TEXT_MES_VERTICAL_DISORDER,[x]);
 FDisorderLengthH:= TTrackBar.Create(Panel);
 FDisorderLengthH.Parent:=Panel;
 FDisorderLengthH.Top:=FDisorderLengthHLabel.Top+FDisorderLengthHLabel.Height+5;
 FDisorderLengthH.Left:=8;
 FDisorderLengthH.Min:=1;
 FDisorderLengthH.Max:=250;
 FDisorderLengthH.Position:=5;
 FDisorderLengthH.Width:=250;
 FDisorderLengthH.OnChange:=MakeImage;

 ColorChooser:=TShape.Create(Panel);
 ColorChooser.Parent:=Panel;
 ColorChooser.Top:=FDisorderLengthH.Top+FDisorderLengthH.Height+5;
 ColorChooser.Left:=8;
 ColorChooser.Width:=17;
 ColorChooser.Height:=17;
 ColorChooser.OnMouseDown:=ColorMouseDown;
 ColorChooser.Brush.Color:=$0;
 ColorDialog := TColorDialog.Create(Panel);

 ColorChooserLabel := TLabel.Create(Panel);
 ColorChooserLabel.Parent:=Panel;
 ColorChooserLabel.Top:=FDisorderLengthH.Top+FDisorderLengthH.Height+8;
 ColorChooserLabel.Left:=ColorChooser.Left+ColorChooser.Width+5;
 ColorChooserLabel.Caption:=TEXT_MES_BK_COLOR;

 Result:=true;
 if aMakeImage then
 MakeImage(Self);
end;

procedure TDisorderEffect.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TDisorderEffect.GetName: String;
begin
 Result:=TEXT_MES_DISORDER;
end;

procedure TDisorderEffect.GetPreview(S, D: TBitmap);
begin
 Disorder(S,D,10,10,$FFFFFF);
end;

function TDisorderEffect.GetProperties: string;
begin
 Result:='LengthW='+IntToStr(FDisorderLengthW.Position)+';';
 Result:=Result+'LengthH='+IntToStr(FDisorderLengthH.Position)+';';
 Result:=Result+'Color='+IntToStr(ColorChooser.Brush.Color)+';';
end;

class function TDisorderEffect.ID: string;
begin
 Result:='{088EC8E3-4F6B-4863-92AF-E47E5A7982A5}';
end;

procedure TDisorderEffect.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 D:=TBitmap.Create;
 D.Assign(FS);
 FDisorderLengthWLabel.Caption:=Format(TEXT_MES_HORIZONTAL_DISORDER,[FDisorderLengthW.Position]);
 FDisorderLengthHLabel.Caption:=Format(TEXT_MES_VERTICAL_DISORDER,[FDisorderLengthH.Position]);
 FSID:=IntToStr(random(10000));
 TDisorderEffectThread.Create(self,false,D,FDisorderLengthW.Position,FDisorderLengthH.Position,ColorChooser.Brush.Color,FSID,ExitThread);
end;

procedure TDisorderEffect.Progress(Progress: integer; var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TDisorderEffect.SetProperties(Properties: string);
begin
 FDisorderLengthW.Position:=GetIntValueByName(Properties,'LengthW',1);
 FDisorderLengthH.Position:=GetIntValueByName(Properties,'LengthH',1);
 ColorChooser.Brush.Color:=GetIntValueByName(Properties,'Color',1);
 MakeImage(self);
end;

{ TDisorderEffectThread }

constructor TDisorderEffectThread.Create(AOwner: TObject;
  CreateSuspended: Boolean; S: TBitmap; W,H: integer; BkColor: TColor;
  SID: string; OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(True);
 FAOwner := AOwner;
 FS := S;
 FW:=W;
 FH:=H;
 FSID := SID;
 FOnExit := OnExit;
 FBkColor:=BkColor;
 if not CreateSuspended then Resume;
end;

procedure TDisorderEffectThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TDisorderEffect).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 Disorder(FS,New,FW,FH,FBkColor,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TDisorderEffectThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TDisorderEffectThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  Exit;
 end;
 if (FAOwner as TDisorderEffect).FSID=FSID then
 (FAOwner as TDisorderEffect).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TDisorderEffectThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TReplaceColorEffect }

procedure TReplaceColorEffect.ButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Screen.Cursor:=CrCross;
 FButtonPressed:=true;
end;

procedure TReplaceColorEffect.ButtonMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  c : TCanvas;
  p : TPoint;
begin
 if FButtonPressed then
 begin
  C := TCanvas.Create;
  GetCursorPos(p);
  C.Handle := GetDC(GetWindow(GetDesktopWindow, GW_OWNER));
  ColorBaseChooser.Brush.Color:=C.Pixels[p.x,p.y];
  C.Free;
 end;
end;

procedure TReplaceColorEffect.ButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Screen.Cursor:=CrDefault;
 FButtonPressed:=false;
 MakeImage(Sender);
end;

procedure TReplaceColorEffect.ColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog.Color:=(Sender as TShape).Brush.Color;
 if ColorDialog.Execute then
 begin
  (Sender as TShape).Brush.Color:=ColorDialog.Color;
  MakeImage(Sender);
 end;
end;

constructor TReplaceColorEffect.Create;
begin
 inherited;
 FButtonPressed:=false;
 GOM.AddObj(Self);
end;

destructor TReplaceColorEffect.Destroy;
begin
 GOM.RemoveObj(Self);
 inherited;
end;

function TReplaceColorEffect.Execute(S, D: TBitmap;
  Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  x : Integer;
begin
 Loading:=true;
 FS:=S;
 FD:=D;
 x:=1;
 Panel.Caption:=GetName;

 FReplaceColorValueLabel:= TLabel.Create(Panel);
 FReplaceColorValueLabel.Parent:=Panel;
 FReplaceColorValueLabel.Top:=20;
 FReplaceColorValueLabel.Left:=8;
 FReplaceColorValueLabel.Caption:=Format(TEXT_MES_DISORDER_F,[x]);
 FReplaceColorValue:= TTrackBar.Create(Panel);
 FReplaceColorValue.Parent:=Panel;
 FReplaceColorValue.Top:=FReplaceColorValueLabel.Top+FReplaceColorValueLabel.Height+5;
 FReplaceColorValue.Left:=8;
 FReplaceColorValue.Min:=1;
 FReplaceColorValue.Max:=255;
 FReplaceColorValue.Position:=100;
 FReplaceColorValue.Width:=250;
 FReplaceColorValue.OnChange:=MakeImage;


 FReplaceColorSizeLabel:= TLabel.Create(Panel);
 FReplaceColorSizeLabel.Parent:=Panel;
 FReplaceColorSizeLabel.Top:=FReplaceColorValue.Top+FReplaceColorValue.Height+5;
 FReplaceColorSizeLabel.Left:=8;
 FReplaceColorSizeLabel.Caption:=Format(TEXT_MES_DISORDER_SIZE_F,[x]);
 FReplaceColorSize:= TTrackBar.Create(Panel);
 FReplaceColorSize.Parent:=Panel;
 FReplaceColorSize.Top:=FReplaceColorSizeLabel.Top+FReplaceColorSizeLabel.Height+5;
 FReplaceColorSize.Left:=8;
 FReplaceColorSize.Min:=1;
 FReplaceColorSize.Max:=10;
 FReplaceColorSize.Position:=2;
 FReplaceColorSize.Width:=250;
 FReplaceColorSize.OnChange:=MakeImage;


 ColorDialog := TColorDialog.Create(Panel);

 ColorBaseChooser:=TShape.Create(Panel);
 ColorBaseChooser.Parent:=Panel;
 ColorBaseChooser.Top:=FReplaceColorSize.Top+FReplaceColorSize.Height+5;
 ColorBaseChooser.Left:=8;
 ColorBaseChooser.Width:=17;
 ColorBaseChooser.Height:=17;
 ColorBaseChooser.OnMouseDown:=ColorMouseDown;
 ColorBaseChooser.Brush.Color:=$0;

 ColorBaseChooserLabel := TLabel.Create(Panel);
 ColorBaseChooserLabel.Parent:=Panel;
 ColorBaseChooserLabel.Top:=FReplaceColorSize.Top+FReplaceColorSize.Height+8;
 ColorBaseChooserLabel.Left:=ColorBaseChooser.Left+ColorBaseChooser.Width+5;
 ColorBaseChooserLabel.Caption:=TEXT_MES_COLOR_BASE;

 ColorToChooser:=TShape.Create(Panel);
 ColorToChooser.Parent:=Panel;
 ColorToChooser.Top:=ColorBaseChooser.Top+ColorBaseChooser.Height+5;
 ColorToChooser.Left:=8;
 ColorToChooser.Width:=17;
 ColorToChooser.Height:=17;
 ColorToChooser.OnMouseDown:=ColorMouseDown;
 ColorToChooser.Brush.Color:=$FFFFFF;

 ColorToChooserLabel := TLabel.Create(Panel);
 ColorToChooserLabel.Parent:=Panel;
 ColorToChooserLabel.Top:=ColorBaseChooser.Top+ColorBaseChooser.Height+8;
 ColorToChooserLabel.Left:=ColorToChooser.Left+ColorToChooser.Width+5;
 ColorToChooserLabel.Caption:=TEXT_MES_COLOR_TO;

 FButtonCustomColor := TButton.Create(Panel);
 FButtonCustomColor.Parent:=Panel;
 FButtonCustomColor.Top:=ColorToChooser.Top+ColorToChooser.Height+5;
 FButtonCustomColor.Width:=80;
 FButtonCustomColor.Height:=21;
 FButtonCustomColor.Left:=8;
 FButtonCustomColor.Caption:=TEXT_MES_SELECT_COLOR;
 FButtonCustomColor.OnMouseDown:=ButtonMouseDown;
 FButtonCustomColor.OnMouseMove:=ButtonMouseMove;
 FButtonCustomColor.OnMouseUp:=ButtonMouseUp;

 Result:=true;
 Loading:=false;
 if aMakeImage then
 MakeImage(Self);
end;

procedure TReplaceColorEffect.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

function TReplaceColorEffect.GetName: String;
begin
 Result:=TEXT_MES_COLOR_REPLACER;
end;

procedure TReplaceColorEffect.GetPreview(S, D: TBitmap);
begin
 ReplaceColorInImage(S,D,ClBlue,ClGreen,100,2);
end;

function TReplaceColorEffect.GetProperties: string;
begin
 Result:='ReplaceColorValue='+IntToStr(FReplaceColorValue.Position)+';';
 Result:=Result+'ReplaceColorSize='+IntToStr(FReplaceColorSize.Position)+';';
 Result:=Result+'ColorBase='+IntToStr(ColorBaseChooser.Brush.Color)+';';
 Result:=Result+'ColorTo='+IntToStr(ColorToChooser.Brush.Color)+';';
end;

class function TReplaceColorEffect.ID: string;
begin
 Result:='{8911A34F-074F-452A-BD58-13102F049DF0}';
end;

procedure TReplaceColorEffect.MakeImage(Sender: TObject);
var
  D : TBitmap;
begin
 if Loading then exit;
 D:=TBitmap.Create;
 D.Assign(FS);
 FReplaceColorSizeLabel.Caption:=Format(TEXT_MES_DISORDER_SIZE_F,[FReplaceColorSize.Position]);
 FReplaceColorValueLabel.Caption:=Format(TEXT_MES_DISORDER_F,[FReplaceColorValue.Position]);
 FSID:=IntToStr(random(10000));
 TReplaceColorEffectThread.Create(self,D,ColorBaseChooser.Brush.Color,ColorToChooser.Brush.Color,FReplaceColorValue.Position,FReplaceColorSize.Position,FSID,ExitThread);
end;

procedure TReplaceColorEffect.Progress(Progress: integer;
  var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TReplaceColorEffect.SetProperties(Properties: string);
begin
 FReplaceColorValue.Position:=GetIntValueByName(Properties,'ReplaceColorValue',1);
 FReplaceColorSize.Position:=GetIntValueByName(Properties,'ReplaceColorSize',1);
 ColorBaseChooser.Brush.Color:=GetIntValueByName(Properties,'ColorBase',1);
 ColorToChooser.Brush.Color:=GetIntValueByName(Properties,'ColorTo',1);
 MakeImage(self);
end;

{ TReplaceColorEffectThread }

constructor TReplaceColorEffectThread.Create(AOwner: TObject;
  S: TBitmap; ColorBase, ColorNew: TColor;
  Size, Value: Integer; SID: string; OnExit: TBaseEffectProcThreadExit);
begin
 inherited Create(False);
 FAOwner := AOwner;
 FS := S;
 FSize:=Size;
 FColorBase:=ColorBase;
 FColorNew:=ColorNew;
 FSID := SID;
 FValue:=Value;
 FOnExit := OnExit;
end;

procedure TReplaceColorEffectThread.Execute;
var
  New : TBitmap;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TReplaceColorEffect).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.PixelFormat:=pf24bit;
 ReplaceColorInImage(FS,New,FColorBase,FColorNew,FSize,FValue,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TReplaceColorEffectThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TReplaceColorEffectThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  exit;
 end;
 if (FAOwner as TReplaceColorEffect).FSID=FSID then
 (FAOwner as TReplaceColorEffect).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TReplaceColorEffectThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

{ TCustomMatrixEffect }

constructor TCustomMatrixEffect.Create;
begin
 inherited;
 Lock :=false;
 FButtonPressed:=false;
 GOM.AddObj(Self);
end;

procedure TCustomMatrixEffect.DeletePresentClick(Sender: TObject);
var
  Name : String;
begin
 Name:=PresentComboBox.Text;
 if Name='' then exit;
 DBKernel.DeleteKey('Editor\CustomEffect\'+Name);
 ReloadUserPresents;
end;

destructor TCustomMatrixEffect.Destroy;
begin
 GOM.RemoveObj(Self);
 inherited;
end;

function TCustomMatrixEffect.Execute(S, D: TBitmap;
  Panel: TGroupBox; aMakeImage : boolean): boolean;
var
  i,j : integer;
begin
 Panel.Caption:=GetName;
 FS:=S;
 FD:=D;
 LabelMatrix := TLabel.Create(Panel);
 LabelMatrix.Parent:=Panel;
 LabelMatrix.Caption:=TEXT_MES_MATRIX_5_5+':';
 LabelMatrix.Top:=18;
 LabelMatrix.Left:=8;
 LabelMatrix.Width:=100;
 LabelMatrix.Height:=15;
 LabelMatrix.Visible:=true;
 Lock:=true;
 for i:=1 to 5 do
 for j:=1 to 5 do
 begin
  E[i,j]:=TEdit.Create(Panel);
  E[i,j].Parent:=Panel;
  E[i,j].Text:='0';
  E[i,j].Top:=LabelMatrix.Top+LabelMatrix.Height+5+(i-1)*25;
  E[i,j].Left:=8+(j-1)*30;
  E[i,j].Width:=25;
  E[i,j].Height:=20;
  E[i,j].Visible:=true;
  E[i,j].OnChange:=ParamsChanged;
 end;
 E[3,3].Text:='1';
 DeviderLabel := TLabel.Create(Panel);
 DeviderLabel.Parent:=Panel;
 DeviderLabel.Caption:=TEXT_MES_DEVIDER+':';
 DeviderLabel.Top:=E[5,5].Top+E[5,5].Height+8;
 DeviderLabel.Left:=8;
 DeviderLabel.Width:=100;
 DeviderLabel.Height:=21;

 DeviderLabel.Visible:=true;
 DeviderEdit := TEdit.Create(Panel);
 DeviderEdit.Parent:=Panel;
 DeviderEdit.Text:='1';
 DeviderEdit.Top:=DeviderLabel.Top+DeviderLabel.Height+2;
 DeviderEdit.Left:=8;
 DeviderEdit.Width:=100;
 DeviderEdit.Height:=21;
 DeviderEdit.Visible:=true;
 DeviderEdit.OnChange:=ParamsChanged;

 FSampleEffectLabel := TLabel.Create(Panel);
 FSampleEffectLabel.Parent:=Panel;
 FSampleEffectLabel.Caption:=TEXT_MES_SAMPLE_M_EFFECT+':';
 FSampleEffectLabel.Top:=E[5,5].Top+E[5,5].Height+8;
 FSampleEffectLabel.Left:=DeviderLabel.Left+DeviderLabel.Width+5;
 FSampleEffectLabel.Width:=150;
 FSampleEffectLabel.Height:=21;

 FSampleEffect := TComboBox.Create(Panel);
 FSampleEffect.Parent:=Panel;
 FSampleEffect.Width:=140;
 FSampleEffect.Height:=21;
 FSampleEffect.Top:=FSampleEffectLabel.Top+FSampleEffectLabel.Height+2;
 FSampleEffect.Left:=DeviderLabel.Left+DeviderLabel.Width+5;
 FSampleEffect.OnChange:=FillMatrix;
 FSampleEffect.Style:=csDropDownList;
 FSampleEffect.DropDownCount:=15;
 FSampleEffect.Items.Add('Neutral');
 FSampleEffect.Items.Add('Anti Alias');
 FSampleEffect.Items.Add('Blur');
 FSampleEffect.Items.Add('Blur more');
 FSampleEffect.Items.Add('Sharpen');
 FSampleEffect.Items.Add('Sharpen more');
 FSampleEffect.Items.Add('Lithography');
 FSampleEffect.Items.Add('Hi pass');
 FSampleEffect.Items.Add('Emboss');
 FSampleEffect.Items.Add('Engrave');
 FSampleEffect.Items.Add('Lines');
 FSampleEffect.Items.Add('Edges');
 FSampleEffect.Items.Add('Sculpture');
 FSampleEffect.ItemIndex:=0;

 SaveNameEditLabel := TLabel.Create(Panel);
 SaveNameEditLabel.Top:=18;
 SaveNameEditLabel.Left:=E[5,5].Left+E[5,5].Width+5;
 SaveNameEditLabel.Width:=100;
 SaveNameEditLabel.Parent:=Panel;
 SaveNameEditLabel.Caption:=TEXT_MES_PRESENT_NAME+':';
 SaveNameEditLabel.Visible:=true;

 SaveNameEdit := TEdit.Create(Panel);
 SaveNameEdit.Top:=SaveNameEditLabel.Top+SaveNameEditLabel.Height+5;
 SaveNameEdit.Left:=E[5,5].Left+E[5,5].Width+5;
 SaveNameEdit.Width:=100;
 SaveNameEdit.Height:=21;
 SaveNameEdit.Parent:=Panel;
 SaveNameEdit.Text:=TEXT_MES_PRESENT_NAME;
 SaveNameEdit.Visible:=true;

 SaveCurrentButton := TButton.Create(Panel);
 SaveCurrentButton.Top:=SaveNameEdit.Top+SaveNameEdit.Height+3;
 SaveCurrentButton.Left:=E[5,5].Left+E[5,5].Width+5;
 SaveCurrentButton.Width:=100;
 SaveCurrentButton.Height:=21;
 SaveCurrentButton.Parent:=Panel;
 SaveCurrentButton.Caption:=TEXT_MES_SAVE_PRESENT;
 SaveCurrentButton.Visible:=true;
 SaveCurrentButton.OnClick:=SavePresentClick;

 PresentComboBox := TComboBox.Create(Panel);
 PresentComboBox.Top:=SaveCurrentButton.Top+SaveCurrentButton.Height+3;
 PresentComboBox.Left:=E[5,5].Left+E[5,5].Width+5;
 PresentComboBox.Width:=100;
 PresentComboBox.Parent:=Panel;
 PresentComboBox.Style:=csDropDownList;
 PresentComboBox.Visible:=true;
 PresentComboBox.OnChange:=PresentSelect;

 LoadSelectedButton := TButton.Create(Panel);
 LoadSelectedButton.Top:=PresentComboBox.Top+PresentComboBox.Height+3;
 LoadSelectedButton.Left:=E[5,5].Left+E[5,5].Width+5;
 LoadSelectedButton.Width:=100;
 LoadSelectedButton.Height:=21;
 LoadSelectedButton.Parent:=Panel;
 LoadSelectedButton.Caption:=TEXT_MES_LOAD_PRESENT;
 LoadSelectedButton.Visible:=true;
 LoadSelectedButton.OnClick:=LoadPresentClick;

 DeleteSelectedButton := TButton.Create(Panel);
 DeleteSelectedButton.Top:=LoadSelectedButton.Top+LoadSelectedButton.Height+3;
 DeleteSelectedButton.Left:=E[5,5].Left+E[5,5].Width+5;
 DeleteSelectedButton.Width:=100;
 DeleteSelectedButton.Height:=21;
 DeleteSelectedButton.Parent:=Panel;
 DeleteSelectedButton.Caption:=TEXT_MES_DELETE_PRESENT;
 DeleteSelectedButton.Visible:=true;
 DeleteSelectedButton.OnClick:=DeletePresentClick;

 Lock:=false;
 Result:=true;
 ReloadUserPresents;
 MakeImage(self);
end;

procedure TCustomMatrixEffect.ExitThread(Image: TBitmap; SID: string);
begin
 if SID=FSID then
 SetImageProc(Image) else Image.Free;
end;

procedure TCustomMatrixEffect.FillMatrix(Sender: TObject);
var
  i, j : integer;
  MX : TConvolutionMatrix;
begin
 Lock:=true;
 for i:=0 to 24 do MX.Matrix[i]:=0;
 MX:=Filterchoice(FSampleEffect.ItemIndex);
 for i:=-2 to 2 do
 for j:=-2 to 2 do
 begin
  E[3+i,3+j].Text:=InttoStr(MX.Matrix[(i+2)*5+j+2]);
 end;
 DeviderEdit.Text:=InttoStr(MX.Devider);
 Lock:=false;
 MakeImage(self);
end;

function TCustomMatrixEffect.GetName: String;
begin
 Result:=TEXT_MES_CUSTOM_USER_EFFECT;
end;

procedure TCustomMatrixEffect.GetPreview(S, D: TBitmap);
begin
 D.Assign(S);
end;

function TCustomMatrixEffect.GetProperties: string;
var
  i,j : integer;
begin
 Result:='Devider='+IntToStr(StrToIntDef(DeviderEdit.Text,1))+';';
 for i:=1 to 5 do
 for j:=1 to 5 do
 begin
  Result:=Result+Format('v%d&%d=',[i,j])+IntToStr(StrToIntDef(E[i,j].Text,1))+';';
 end;
end;

class function TCustomMatrixEffect.ID: string;
begin
 Result:='{84ABBC44-9F9D-4373-9676-6BD986B4464E}';
end;

procedure TCustomMatrixEffect.LoadPresentClick(Sender: TObject);
{$IFDEF PHOTODB}
var
  i, j : integer;
  Name : String;
{$ENDIF}
begin
{$IFDEF PHOTODB}
 Name:=PresentComboBox.Text;
 for i:=-2 to 2 do
 for j:=-2 to 2 do
 begin
  E[3+i,3+j].Text:=DBKernel.ReadString('Editor\CustomEffect\'+Name,InttoStr((i+2)*5+j+2));
 end;
 DeviderEdit.Text:=DBKernel.ReadString('Editor\CustomEffect\'+Name,'Devider');
{$ENDIF}
end;

procedure TCustomMatrixEffect.MakeImage(Sender: TObject);
var
  D : TBitmap;
  MX : TConvolutionMatrix;
  i,j : integer;
begin
 if Lock then exit;
 Lock:=true;
 begin
  MX.Devider:=StrtoIntDef(DeviderEdit.Text,1);
  for i:=0 to 24 do MX.Matrix[i]:=0;
  for i:=-2 to 2 do
  for j:=-2 to 2 do
  begin
   MX.Matrix[(i+2)*5+j+2]:=StrtoIntDef(E[3+i,3+j].Text,0);
  end;
 end;
 Lock:=false;
 D:=TBitmap.Create;
 D.Assign(FS);
 FSID:=IntToStr(random(10000));
 TCustomMatrixEffectThread.Create(self,false,D,MX,FSID,ExitThread);
end;

procedure TCustomMatrixEffect.ParamsChanged(Sender: TObject);
begin
 MakeImage(Sender);
end;

procedure TCustomMatrixEffect.PresentSelect(Sender: TObject);
begin
 RefreshButtons;
end;

procedure TCustomMatrixEffect.Progress(Progress: integer;
  var Break: boolean);
begin
 (Editor as TImageEditor).FStatusProgress.Position:=Progress;
end;

procedure TCustomMatrixEffect.RefreshButtons;
begin
 if (PresentComboBox.ItemIndex<>-1) then
 begin
  DeleteSelectedButton.Enabled:=true;
  LoadSelectedButton.Enabled:=true;
 end else
 begin
  DeleteSelectedButton.Enabled:=false;
  LoadSelectedButton.Enabled:=false;
 end;
end;

procedure TCustomMatrixEffect.ReloadUserPresents;
var
  i : integer;
  List : TStrings;
begin
 PresentComboBox.Clear;
 List:=DBKernel.ReadKeys('Editor\CustomEffect');
 for i:=1 to List.Count do
 begin
  PresentComboBox.Items.Add(List[i-1]);
 end;
 RefreshButtons;
end;

procedure TCustomMatrixEffect.SavePresentClick(Sender: TObject);
{$IFDEF PHOTODB}
var
  Name : String;
  i,j : integer;
{$ENDIF}
begin
{$IFDEF PHOTODB}
 Name:=SaveNameEdit.Text;
 for i:=1 to Length(Name) do
 begin
  if Name[i]='\' then Name[i]:='_';
  if Name[i]='/' then Name[i]:='_';
  if Name[i]=':' then Name[i]:='_';
  if Name[i]=';' then Name[i]:='_';
 end;
 for i:=-2 to 2 do
 for j:=-2 to 2 do
 begin
  DBKernel.WriteString('Editor\CustomEffect\'+Name,InttoStr((i+2)*5+j+2),E[3+i,3+j].Text);
 end;
 DBKernel.WriteString('Editor\CustomEffect\'+Name,'Devider',DeviderEdit.Text);
{$ENDIF}
 ReloadUserPresents;
end;

procedure TCustomMatrixEffect.SetProperties(Properties: string);
var
  i,j : integer;
begin
 DeviderEdit.Text:=GetValueByName(Properties,'Devider');
 for i:=1 to 5 do
 for j:=1 to 5 do
 begin
  E[i,j].Text:=GetValueByName(Properties,Format('v%d&%d',[i,j]));
 end;
 MakeImage(self);
end;

{ TCustomMatrixEffectThread }

constructor TCustomMatrixEffectThread.Create(AOwner: TObject;
  CreateSuspended: Boolean; S: TBitmap; M: TConvolutionMatrix; SID: string;
  OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FM := M;
  FSID := SID;
  FOnExit := OnExit;
end;

procedure TCustomMatrixEffectThread.Execute;
var
  New : TBitmap;
  p1,p2 : TArPRGBArray;
  i : integer;
begin
 FreeOnTerminate:=true;
 sleep(100);
 if (FAOwner as TCustomMatrixEffect).FSID<>FSID then
 begin
  FS.Free;
  Exit;
 end;
 New:=TBitmap.Create;
 New.Width:=FS.Width;
 New.Height:=FS.Height;
 New.PixelFormat:=pf24bit;
 setlength(p1,FS.Height);
 setlength(p2,FS.Height);
 for i:=0 to FS.Height-1 do
 begin
  p1[i]:=FS.Scanline[i];
  p2[i]:=New.Scanline[i];
 end;
 MatrixEffectsW(0,100,p1,p2,FS.Width-1,FS.Height-1,FM,ImageProgress);
 FS.Free;
 Pointer(FS):=Pointer(New);
 Synchronize(OnExit);
end;

procedure TCustomMatrixEffectThread.ImageProgress(Progress: integer;
  var Break: boolean);
begin
 FBreak:=Break;
 FProgress:=Progress;
 Synchronize(ImageProgressSynch);
 Break:=FBreak;
end;

procedure TCustomMatrixEffectThread.ImageProgressSynch;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FBreak:=true;
  Exit;
 end;
 if (FAOwner as TCustomMatrixEffect).FSID=FSID then
 (FAOwner as TCustomMatrixEffect).Progress(FProgress,FBreak) else FBreak:=true;
end;

procedure TCustomMatrixEffectThread.OnExit;
begin
 if not GOM.IsObj(FAOwner) then
 begin
  FS.Free;
  exit;
 end;
 if Assigned(FOnExit) then FOnExit(FS,FSID) else FS.Free;
end;

end.
