unit ExEffectsUnit;

interface

uses
  Windows, ExEffects, Effects, Graphics, StdCtrls, ComCtrls, GBlur2,
  Classes, GraphicsBaseTypes, SysUtils, ExtCtrls, Controls, Dialogs,
  Forms, OptimizeImageUnit, uEditorTypes, uGOM, uDBThread,
  UnitDBKernel, uMemory, uSettings;

type
  TGausBlur = class(TExEffect)
  private
    { Private declarations }
    FS, FD: Tbitmap;
    FTrackBar: TTrackBar;
    FTrackBarlabel: TLabel;
    FSID: string;
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TGaussBlurThread = class(TDBThread)
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
    { Private declarations }
    FS, FD: Tbitmap;
    FTrackBar: TTrackBar;
    FTrackBarlabel: TLabel;
    FSID: string;
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TSharpenThread = class(TDBThread)
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
    FS, FD: Tbitmap;
    FTrackBarWidth: TTrackBar;
    FTrackBarWidthlabel: TLabel;
    FTrackBarHeight: TTrackBar;
    FTrackBarHeightlabel: TLabel;
    FSID: string;
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TPixelsEffectThread = class(TDBThread)
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
    FS, FD: Tbitmap;
    FTrackBarFrequency: TTrackBar;
    FTrackBarFrequencyLabel: TLabel;
    FTrackBarLength: TTrackBar;
    FTrackBarLengthLabel: TLabel;
    FHorizontal: TCheckBox;
    ColorChooser: TShape;
    ColorChooserLabel: TLabel;
    ColorDialog: TColorDialog;
    FSID: string;
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    procedure ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TWaveEffectThread = class(TDBThread)
  private
    { Private declarations }
    FAOwner: TObject;
    FS: TBitmap;
    FFrequency, FLength: Integer;
    FHorizontal: Boolean;
    FBkColor: TColor;
    FSID: string;
    FOnExit: TBaseEffectProcThreadExit;
    FProgress: Integer;
    FBreak: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TObject; CreateSuspended: Boolean; S: TBitmap; Frequency, Length: Integer;
      Horizontal: Boolean; BkColor: TColor; SID: string; OnExit: TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress: Integer; var Break: Boolean);
    procedure ImageProgressSynch;
  end;

//<<...TDisorderEffect...>>
type
  TDisorderEffect = class(TExEffect)
  private
    { Private declarations }
    FS, FD: TBitmap;
    FDisorderLengthW: TTrackBar;
    FDisorderLengthWLabel: TLabel;
    FDisorderLengthH: TTrackBar;
    FDisorderLengthHLabel: TLabel;
    ColorChooser: TShape;
    ColorChooserLabel: TLabel;
    ColorDialog: TColorDialog;
    FSID: string;
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    procedure ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TDisorderEffectThread = class(TDBThread)
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
    constructor Create(AOwner : TObject; S : TBitmap; W,H: integer; BkColor : TColor; SID : string; OnExit : TBaseEffectProcThreadExit);
    procedure OnExit;
    procedure ImageProgress(Progress : integer; var Break: boolean);
    procedure ImageProgressSynch;
  end;
//>>...TDisorderEffect...<<

//<<...TReplaceColorEffect...>>
type
  TReplaceColorEffect = class(TExEffect)
  private
    { Private declarations }
    FS, FD: Tbitmap;
    FReplaceColorValue: TTrackBar;
    FReplaceColorValueLabel: TLabel;
    FReplaceColorSize: TTrackBar;
    FReplaceColorSizeLabel: TLabel;
    ColorBaseChooser: TShape;
    ColorBaseChooserLabel: TLabel;
    ColorToChooser: TShape;
    ColorToChooserLabel: TLabel;
    ColorDialog: TColorDialog;
    FButtonCustomColor: TButton;
    FSID: string;
    FButtonPressed: Boolean;
    Loading: Boolean;
  public
   { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    procedure ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TReplaceColorEffectThread = class(TDBThread)
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
    { Private declarations }
    FS, FD: TBitmap;
    FSID: string;
    FButtonPressed: Boolean;
    Lock: Boolean;
    LabelMatrix: TLabel;
    E: array [1 .. 5, 1 .. 5] of TEdit;
    DeviderLabel: TLabel;
    DeviderEdit: TEdit;
    FSampleEffectLabel: TLabel;
    FSampleEffect: TComboBox;

    SaveNameEditLabel: TLabel;
    SaveNameEdit: TEdit;
    SaveCurrentButton: TButton;
    PresentComboBox: TComboBox;
    LoadSelectedButton: TButton;
    DeleteSelectedButton: TButton;
    procedure RefreshButtons;
    procedure LoadPresentClick(Sender: TObject);
    procedure SavePresentClick(Sender: TObject);
    procedure DeletePresentClick(Sender: TObject);
    procedure PresentSelect(Sender: TObject);
    procedure ReloadUserPresents;
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean; override;
    function GetName: string; override;
    procedure GetPreview(S, D: TBitmap); override;
    procedure MakeImage(Sender: TObject);
    procedure Progress(Progress: Integer; var Break: Boolean);
    procedure ExitThread(Image: TBitmap; SID: string);
    procedure ParamsChanged(Sender: TObject);
    procedure FillMatrix(Sender: TObject);
    function GetProperties: string; override;
    procedure SetProperties(Properties: string); override;
  end;

type
  TCustomMatrixEffectThread = class(TDBThread)
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
  inherited;
  GOM.AddObj(Self);
  FTrackBar := nil;
  FTrackBarlabel := nil;
end;

destructor TGausBlur.Destroy;
begin
  GOM.RemoveObj(Self);
  F(FTrackBar);
  F(FTrackBarlabel);
  inherited;
end;

function TGausBlur.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  Radius: Extended;
begin
  FS := S;
  FD := D;
  Radius := 0;
  Panel.Caption := GetName;
  FTrackBarlabel := TLabel.Create(Panel);
  FTrackBarlabel.Parent := Panel;
  FTrackBarlabel.Top := 20;
  FTrackBarlabel.Left := 8;
  FTrackBarlabel.Caption := Format(L('Radius: [%2.1f]'), [Radius]);
  FTrackBar := TTrackBar.Create(Panel);
  FTrackBar.Parent := Panel;
  FTrackBar.Top := FTrackBarlabel.Top + FTrackBarlabel.Height + 5;
  FTrackBar.Left := 8;
  FTrackBar.Min := 1;
  FTrackBar.Position := 20;
  FTrackBar.Max := 200;
  FTrackBar.Width := 250;
  FTrackBar.OnChange := MakeImage;
  if AMakeImage then
    MakeImage(Self);
  Result := True;
end;

procedure TGausBlur.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TGausBlur.GetName: string;
begin
  Result := L('Gauss blur');
end;

procedure TGausBlur.GetPreview(S, D: TBitmap);
begin
  D.Assign(S);
  GBlur(D, 3);
end;

function TGausBlur.GetProperties: string;
begin
  Result := 'EffectSize=' + IntToStr(FTrackBar.Position) + ';';
end;

class function TGausBlur.ID: string;
begin
  Result := '{C7DB416B-BD8E-4F7D-8A44-309C4FA9B451}';
end;

procedure TGausBlur.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FTrackBarlabel.Caption := Format(L('Сила эффекта: [%2.1f]'), [FTrackBar.Position / 10]);
  FSID := IntToStr(Random(10000));
  TGaussBlurThread.Create(Self, D, FTrackBar.Position / 10, FSID, ExitThread);
end;

procedure TGausBlur.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TGausBlur.SetProperties(Properties: string);
begin
  FTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'EffectSize'), 1);
end;

{ TGaussBlurThread }

constructor TGaussBlurThread.Create(AOwner: TObject; S: TBitmap; Radius: Double; SID: string;
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
  b : Boolean;
begin
  Sleep(300);
  FreeOnTerminate := True;
  if (FAOwner as TGausBlur).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  ImageProgress(1, B);
  GBlur(FS, FRadius, ImageProgress);
  Synchronize(OnExit);
end;

procedure TGaussBlurThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TGaussBlurThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TGausBlur).FSID = FSID then
    (FAOwner as TGausBlur).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TGaussBlurThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TSharpenThread }

constructor TSharpenThread.Create(AOwner: TObject; S: TBitmap; EffectSize: Integer; SID: string;
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
  New: TBitmap;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TSharpen).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := Pf24bit;
  Sharpen(FS, New, FEffectSize / 10, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TSharpenThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TSharpenThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TSharpen).FSID = FSID then
    (FAOwner as TSharpen).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TSharpenThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TSharpen }

constructor TSharpen.Create;
begin
  inherited;
  GOM.AddObj(Self);
  FTrackBar := nil;
  FTrackBarlabel := nil;
end;

destructor TSharpen.Destroy;
begin
  GOM.RemoveObj(Self);
  F(FTrackBar);
  F(FTrackBarlabel);
  inherited;
end;

function TSharpen.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  X: Extended;
begin
  FS := S;
  FD := D;
  X := 0;
  Panel.Caption := GetName;
  FTrackBarlabel := TLabel.Create(Panel);
  FTrackBarlabel.Parent := Panel;
  FTrackBarlabel.Top := 20;
  FTrackBarlabel.Left := 8;
  FTrackBarlabel.Caption := Format(L('Effect size: [%2.1f]'), [X]);
  FTrackBar := TTrackBar.Create(Panel);
  FTrackBar.Parent := Panel;
  FTrackBar.Top := FTrackBarlabel.Top + FTrackBarlabel.Height + 5;
  FTrackBar.Left := 8;
  FTrackBar.Min := 0;
  FTrackBar.Max := 30;
  FTrackBar.Position := 10;
  FTrackBar.Width := 250;
  FTrackBar.OnChange := MakeImage;
  if AMakeImage then
    MakeImage(Self);
  Result := True;
end;

procedure TSharpen.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TSharpen.GetName: String;
begin
  Result := L('Sharpen');
end;

procedure TSharpen.GetPreview(S, D: TBitmap);
begin
  Sharpen(S, D, 5);
end;

function TSharpen.GetProperties: string;
begin
  Result := 'EffectSize=' + IntToStr(FTrackBar.Position) + ';';
end;

class function TSharpen.ID: string;
begin
  Result := '{27FEBBB0-C8F5-4493-A1EA-928221CEDB49}';
end;

procedure TSharpen.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FTrackBarlabel.Caption := Format(L('Effect size: [%2.1f]'), [FTrackBar.Position / 10]);
  FSID := IntToStr(Random(10000));
  TSharpenThread.Create(Self, D, FTrackBar.Position + 20, FSID, ExitThread);
end;

procedure TSharpen.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TSharpen.SetProperties(Properties: string);
begin
  FTrackBar.Position := StrToIntDef(GetValueByName(Properties, 'EffectSize'), 1);
  MakeImage(Self);
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
  F(FTrackBarWidth);
  F(FTrackBarWidthlabel);
  F(FTrackBarHeight);
  F(FTrackBarHeightlabel);
  inherited;
end;

function TPixelsEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  X: Integer;
begin
  FS := S;
  FD := D;
  X := 1;
  Panel.Caption := GetName;
  FTrackBarWidthlabel := TLabel.Create(Panel);
  FTrackBarWidthlabel.Parent := Panel;
  FTrackBarWidthlabel.Top := 20;
  FTrackBarWidthlabel.Left := 8;
  FTrackBarWidthlabel.Caption := Format(L('Width [%d]'), [X]);
  FTrackBarWidth := TTrackBar.Create(Panel);
  FTrackBarWidth.Parent := Panel;
  FTrackBarWidth.Top := FTrackBarWidthlabel.Top + FTrackBarWidthlabel.Height + 5;
  FTrackBarWidth.Left := 8;
  FTrackBarWidth.Min := 1;
  FTrackBarWidth.Max := 30;
  FTrackBarWidth.Position := 3;
  FTrackBarWidth.Width := 250;
  FTrackBarWidth.OnChange := MakeImage;

  FTrackBarHeightlabel := TLabel.Create(Panel);
  FTrackBarHeightlabel.Parent := Panel;
  FTrackBarHeightlabel.Top := FTrackBarWidth.Top + FTrackBarWidth.Height + 5;
  FTrackBarHeightlabel.Left := 8;
  FTrackBarHeightlabel.Caption := Format(L('Height [%d]'), [X]);
  FTrackBarHeight := TTrackBar.Create(Panel);
  FTrackBarHeight.Parent := Panel;
  FTrackBarHeight.Top := FTrackBarHeightlabel.Top + FTrackBarHeightlabel.Height + 5;
  FTrackBarHeight.Left := 8;
  FTrackBarHeight.Min := 1;
  FTrackBarHeight.Max := 30;
  FTrackBarHeight.Position := 3;
  FTrackBarHeight.Width := 250;
  FTrackBarHeight.OnChange := MakeImage;

  Result := True;
  if AMakeImage then
    MakeImage(Self);
end;

procedure TPixelsEffect.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TPixelsEffect.GetName: string;
begin
  Result := L('Pixels');
end;

procedure TPixelsEffect.GetPreview(S, D: TBitmap);
begin
  PixelsEffect(S, D, 3, 3);
end;

function TPixelsEffect.GetProperties: string;
begin
  Result := 'EffectWidthSize=' + IntToStr(FTrackBarWidth.Position) + ';';
  Result := Result + 'EffectHeightSize=' + IntToStr(FTrackBarHeight.Position) + ';';
end;

class function TPixelsEffect.ID: string;
begin
  Result := '{4F530D08-B94C-4C5A-8C84-DF61210F414D}';
end;

procedure TPixelsEffect.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FTrackBarWidthlabel.Caption := Format(L('Width [%d]'), [FTrackBarWidth.Position]);
  FTrackBarHeightlabel.Caption := Format(L('Height [%d]'), [FTrackBarHeight.Position]);
  FSID := IntToStr(Random(10000));
  TPixelsEffectThread.Create(Self, False, D, FTrackBarWidth.Position, FTrackBarHeight.Position, FSID, ExitThread);
end;

procedure TPixelsEffect.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TPixelsEffect.SetProperties(Properties: string);
begin
  FTrackBarWidth.Position := StrToIntDef(GetValueByName(Properties, 'EffectWidthSize'), 1);
  FTrackBarHeight.Position := StrToIntDef(GetValueByName(Properties, 'EffectHeightSize'), 1);
  MakeImage(Self);
end;

{ TPixelsEffectThread }

constructor TPixelsEffectThread.Create(AOwner: TObject; CreateSuspended: Boolean; S: TBitmap; Width, Height: Integer;
  SID: string; OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FWidth := Width;
  FHeight := Height;
  FSID := SID;
  FOnExit := OnExit;
end;

procedure TPixelsEffectThread.Execute;
var
  New: TBitmap;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TPixelsEffect).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := Pf24bit;
  PixelsEffect(FS, New, FWidth, FHeight, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TPixelsEffectThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TPixelsEffectThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TPixelsEffect).FSID = FSID then
    (FAOwner as TPixelsEffect).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TPixelsEffectThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TWaveEffect }

procedure TWaveEffect.ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := ColorChooser.Brush.Color;
  if ColorDialog.Execute then
  begin
    ColorChooser.Brush.Color := ColorDialog.Color;
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

function TWaveEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  X: Integer;
begin
  FS := S;
  FD := D;
  X := 1;
  Panel.Caption := GetName;
  FTrackBarFrequencylabel := TLabel.Create(Panel);
  FTrackBarFrequencylabel.Parent := Panel;
  FTrackBarFrequencylabel.Top := 20;
  FTrackBarFrequencylabel.Left := 8;
  FTrackBarFrequencylabel.Caption := Format(L('Width [%d]'), [X]);
  FTrackBarFrequency := TTrackBar.Create(Panel);
  FTrackBarFrequency.Parent := Panel;
  FTrackBarFrequency.Top := FTrackBarFrequencylabel.Top + FTrackBarFrequencylabel.Height + 5;
  FTrackBarFrequency.Left := 8;
  FTrackBarFrequency.Min := 1;
  FTrackBarFrequency.Max := 30;
  FTrackBarFrequency.Position := 3;
  FTrackBarFrequency.Width := 250;
  FTrackBarFrequency.OnChange := MakeImage;

  FTrackBarLengthlabel := TLabel.Create(Panel);
  FTrackBarLengthlabel.Parent := Panel;
  FTrackBarLengthlabel.Top := FTrackBarFrequency.Top + FTrackBarFrequency.Height + 5;
  FTrackBarLengthlabel.Left := 8;
  FTrackBarLengthlabel.Caption := Format(L('Height [%d]'), [X]);
  FTrackBarLength := TTrackBar.Create(Panel);
  FTrackBarLength.Parent := Panel;
  FTrackBarLength.Top := FTrackBarLengthlabel.Top + FTrackBarLengthlabel.Height + 5;
  FTrackBarLength.Left := 8;
  FTrackBarLength.Min := 1;
  FTrackBarLength.Max := 30;
  FTrackBarLength.Position := 3;
  FTrackBarLength.Width := 250;
  FTrackBarLength.OnChange := MakeImage;

  FHorizontal := TCheckBox.Create(Panel);
  FHorizontal.Parent := Panel;
  FHorizontal.Top := FTrackBarLength.Top + FTrackBarLength.Height + 5;
  FHorizontal.Left := 8;
  FHorizontal.Width := 250;
  FHorizontal.Caption := L('Horizontal');
  FHorizontal.OnClick := MakeImage;

  ColorChooser := TShape.Create(Panel);
  ColorChooser.Parent := Panel;
  ColorChooser.Top := FHorizontal.Top + FHorizontal.Height + 5;
  ColorChooser.Left := 8;
  ColorChooser.Width := 17;
  ColorChooser.Height := 17;
  ColorChooser.OnMouseDown := ColorMouseDown;
  ColorChooser.Brush.Color := $0;
  ColorDialog := TColorDialog.Create(Panel);

  ColorChooserLabel := TLabel.Create(Panel);
  ColorChooserLabel.Parent := Panel;
  ColorChooserLabel.Top := FHorizontal.Top + FHorizontal.Height + 8;
  ColorChooserLabel.Left := ColorChooser.Left + ColorChooser.Width + 5;
  ColorChooserLabel.Caption := L('Backgroud color');

  Result := True;
  MakeImage(Self);
end;

procedure TWaveEffect.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TWaveEffect.GetName: string;
begin
  Result := L('Wave');
end;

procedure TWaveEffect.GetPreview(S, D: TBitmap);
begin
  WaveSin(S, D, 10, 10, True, $FFFFFF);
end;

function FBoolToStr(B: Boolean): string;
begin
  if B then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

function TWaveEffect.GetProperties: string;
begin
  Result := 'Frequency=' + IntToStr(FTrackBarFrequency.Position) + ';';
  Result := Result + 'Length=' + IntToStr(FTrackBarLength.Position) + ';';
  Result := Result + 'Horizontal=' + FBoolToStr(FHorizontal.Checked) + ';';
  Result := Result + 'Color=' + IntToStr(ColorChooser.Brush.Color) + ';';
end;

class function TWaveEffect.ID: string;
begin
  Result := '{9E1AE930-6903-497B-AA2F-CFABE87A10B8}';
end;

procedure TWaveEffect.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FTrackBarFrequencylabel.Caption := Format(L('Frequency [%d]'), [FTrackBarFrequency.Position]);
  FTrackBarLengthlabel.Caption := Format(L('Length [%d]'), [FTrackBarLength.Position]);
  FSID := IntToStr(Random(10000));
  TWaveEffectThread.Create(Self, False, D, FTrackBarLength.Position, FTrackBarFrequency.Position, FHorizontal.Checked,
    ColorChooser.Brush.Color, FSID, ExitThread);
end;

procedure TWaveEffect.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TWaveEffect.SetProperties(Properties: string);
begin
  FTrackBarFrequency.Position := StrToIntDef(GetValueByName(Properties, 'Frequency'), 1);
  FTrackBarLength.Position := StrToIntDef(GetValueByName(Properties, 'Length'), 1);
  FHorizontal.Checked := GetBoolValueByName(Properties, 'Color', True);
  ColorChooser.Brush.Color := GetIntValueByName(Properties, 'Color', 1);
  MakeImage(Self);
end;

{ TWaveEffectThread }

constructor TWaveEffectThread.Create(AOwner: TObject; CreateSuspended: Boolean; S: TBitmap; Frequency, Length: Integer;
  Horizontal: Boolean; BkColor: TColor; SID: string; OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FFrequency := Frequency;
  FLength := Length;
  FHorizontal := Horizontal;
  FBkColor := BkColor;
  FSID := SID;
  FOnExit := OnExit;
end;

procedure TWaveEffectThread.Execute;
var
  New: TBitmap;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TWaveEffect).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := pf24bit;
  WaveSin(FS, New, FFrequency, FLength, FHorizontal, FBkColor, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TWaveEffectThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TWaveEffectThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TWaveEffect).FSID = FSID then
    (FAOwner as TWaveEffect).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TWaveEffectThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TDisorderEffect }

procedure TDisorderEffect.ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := ColorChooser.Brush.Color;
  if ColorDialog.Execute then
  begin
    ColorChooser.Brush.Color := ColorDialog.Color;
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

function TDisorderEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  X: Integer;
begin
  FS := S;
  FD := D;
  X := 1;
  Panel.Caption := GetName;
  FDisorderLengthWLabel := TLabel.Create(Panel);
  FDisorderLengthWLabel.Parent := Panel;
  FDisorderLengthWLabel.Top := 20;
  FDisorderLengthWLabel.Left := 8;
  FDisorderLengthWLabel.Caption := Format(L('Horizontal Disorder [%d]'), [X]);
  FDisorderLengthW := TTrackBar.Create(Panel);
  FDisorderLengthW.Parent := Panel;
  FDisorderLengthW.Top := FDisorderLengthWLabel.Top + FDisorderLengthWLabel.Height + 5;
  FDisorderLengthW.Left := 8;
  FDisorderLengthW.Min := 1;
  FDisorderLengthW.Max := 250;
  FDisorderLengthW.Position := 5;
  FDisorderLengthW.Width := 250;
  FDisorderLengthW.OnChange := MakeImage;

  FDisorderLengthHLabel := TLabel.Create(Panel);
  FDisorderLengthHLabel.Parent := Panel;
  FDisorderLengthHLabel.Top := FDisorderLengthW.Top + FDisorderLengthW.Height + 5;
  FDisorderLengthHLabel.Left := 8;
  FDisorderLengthHLabel.Caption := Format(L('Vertical Disorder [%d]'), [X]);
  FDisorderLengthH := TTrackBar.Create(Panel);
  FDisorderLengthH.Parent := Panel;
  FDisorderLengthH.Top := FDisorderLengthHLabel.Top + FDisorderLengthHLabel.Height + 5;
  FDisorderLengthH.Left := 8;
  FDisorderLengthH.Min := 1;
  FDisorderLengthH.Max := 250;
  FDisorderLengthH.Position := 5;
  FDisorderLengthH.Width := 250;
  FDisorderLengthH.OnChange := MakeImage;

  ColorChooser := TShape.Create(Panel);
  ColorChooser.Parent := Panel;
  ColorChooser.Top := FDisorderLengthH.Top + FDisorderLengthH.Height + 5;
  ColorChooser.Left := 8;
  ColorChooser.Width := 17;
  ColorChooser.Height := 17;
  ColorChooser.OnMouseDown := ColorMouseDown;
  ColorChooser.Brush.Color := $0;
  ColorDialog := TColorDialog.Create(Panel);

  ColorChooserLabel := TLabel.Create(Panel);
  ColorChooserLabel.Parent := Panel;
  ColorChooserLabel.Top := FDisorderLengthH.Top + FDisorderLengthH.Height + 8;
  ColorChooserLabel.Left := ColorChooser.Left + ColorChooser.Width + 5;
  ColorChooserLabel.Caption := L('Backgroud color');

  Result := True;
  if AMakeImage then
    MakeImage(Self);
end;

procedure TDisorderEffect.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TDisorderEffect.GetName: string;
begin
  Result := L('Disorder');
end;

procedure TDisorderEffect.GetPreview(S, D: TBitmap);
begin
  Disorder(S, D, 10, 10, $FFFFFF);
end;

function TDisorderEffect.GetProperties: string;
begin
  Result := 'LengthW=' + IntToStr(FDisorderLengthW.Position) + ';';
  Result := Result + 'LengthH=' + IntToStr(FDisorderLengthH.Position) + ';';
  Result := Result + 'Color=' + IntToStr(ColorChooser.Brush.Color) + ';';
end;

class function TDisorderEffect.ID: string;
begin
  Result := '{088EC8E3-4F6B-4863-92AF-E47E5A7982A5}';
end;

procedure TDisorderEffect.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FDisorderLengthWLabel.Caption := Format(L('Horizontal Disorder [%d]'), [FDisorderLengthW.Position]);
  FDisorderLengthHLabel.Caption := Format(L('Vertical Disorder [%d]'), [FDisorderLengthH.Position]);
  FSID := IntToStr(Random(10000));
  TDisorderEffectThread.Create(Self, D, FDisorderLengthW.Position, FDisorderLengthH.Position, ColorChooser.Brush.Color,
    FSID, ExitThread);
end;

procedure TDisorderEffect.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TDisorderEffect.SetProperties(Properties: string);
begin
  FDisorderLengthW.Position := GetIntValueByName(Properties, 'LengthW', 1);
  FDisorderLengthH.Position := GetIntValueByName(Properties, 'LengthH', 1);
  ColorChooser.Brush.Color := GetIntValueByName(Properties, 'Color', 1);
  MakeImage(Self);
end;

{ TDisorderEffectThread }

constructor TDisorderEffectThread.Create(AOwner: TObject; S: TBitmap; W, H: Integer; BkColor: TColor; SID: string;
  OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FW := W;
  FH := H;
  FSID := SID;
  FOnExit := OnExit;
  FBkColor := BkColor;
end;

procedure TDisorderEffectThread.Execute;
var
  New: TBitmap;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TDisorderEffect).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := pf24bit;
  Disorder(FS, New, FW, FH, FBkColor, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TDisorderEffectThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TDisorderEffectThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TDisorderEffect).FSID = FSID then
    (FAOwner as TDisorderEffect).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TDisorderEffectThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TReplaceColorEffect }

procedure TReplaceColorEffect.ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := CrCross;
  FButtonPressed := True;
end;

procedure TReplaceColorEffect.ButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  C: TCanvas;
  P: TPoint;
begin
  if FButtonPressed then
  begin
    C := TCanvas.Create;
    try
    GetCursorPos(P);
    C.Handle := GetDC(GetWindow(GetDesktopWindow, GW_OWNER));
    ColorBaseChooser.Brush.Color := C.Pixels[P.X, P.Y];
    finally
      F(C);
    end;
  end;
end;

procedure TReplaceColorEffect.ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Screen.Cursor := CrDefault;
  FButtonPressed := False;
  MakeImage(Sender);
end;

procedure TReplaceColorEffect.ColorMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := (Sender as TShape).Brush.Color;
  if ColorDialog.Execute then
  begin
    (Sender as TShape).Brush.Color := ColorDialog.Color;
    MakeImage(Sender);
  end;
end;

constructor TReplaceColorEffect.Create;
begin
  inherited;
  FButtonPressed := False;
  GOM.AddObj(Self);
end;

destructor TReplaceColorEffect.Destroy;
begin
  GOM.RemoveObj(Self);
  inherited;
end;

function TReplaceColorEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  X: Integer;
begin
  Loading := True;
  FS := S;
  FD := D;
  X := 1;
  Panel.Caption := GetName;

  FReplaceColorValueLabel:= TLabel.Create(Panel);
  FReplaceColorValueLabel.Parent := Panel;
  FReplaceColorValueLabel.Top := 20;
  FReplaceColorValueLabel.Left := 8;
  FReplaceColorValueLabel.Caption := Format(L('Disorder [%d]'), [X]);
  FReplaceColorValue := TTrackBar.Create(Panel);
  FReplaceColorValue.Parent := Panel;
  FReplaceColorValue.Top := FReplaceColorValueLabel.Top + FReplaceColorValueLabel.Height + 5;
  FReplaceColorValue.Left := 8;
  FReplaceColorValue.Min := 1;
  FReplaceColorValue.Max := 255;
  FReplaceColorValue.Position := 100;
  FReplaceColorValue.Width := 250;
  FReplaceColorValue.OnChange := MakeImage;

  FReplaceColorSizeLabel := TLabel.Create(Panel);
  FReplaceColorSizeLabel.Parent := Panel;
  FReplaceColorSizeLabel.Top := FReplaceColorValue.Top + FReplaceColorValue.Height + 5;
  FReplaceColorSizeLabel.Left := 8;
  FReplaceColorSizeLabel.Caption := Format(L('Value [%d]'), [X]);
  FReplaceColorSize := TTrackBar.Create(Panel);
  FReplaceColorSize.Parent := Panel;
  FReplaceColorSize.Top := FReplaceColorSizeLabel.Top + FReplaceColorSizeLabel.Height + 5;
  FReplaceColorSize.Left := 8;
  FReplaceColorSize.Min := 1;
  FReplaceColorSize.Max := 10;
  FReplaceColorSize.Position := 2;
  FReplaceColorSize.Width := 250;
  FReplaceColorSize.OnChange := MakeImage;

  ColorDialog := TColorDialog.Create(Panel);

  ColorBaseChooser := TShape.Create(Panel);
  ColorBaseChooser.Parent := Panel;
  ColorBaseChooser.Top := FReplaceColorSize.Top + FReplaceColorSize.Height + 5;
  ColorBaseChooser.Left := 8;
  ColorBaseChooser.Width := 17;
  ColorBaseChooser.Height := 17;
  ColorBaseChooser.OnMouseDown := ColorMouseDown;
  ColorBaseChooser.Brush.Color := $0;

  ColorBaseChooserLabel := TLabel.Create(Panel);
  ColorBaseChooserLabel.Parent := Panel;
  ColorBaseChooserLabel.Top := FReplaceColorSize.Top + FReplaceColorSize.Height + 8;
  ColorBaseChooserLabel.Left := ColorBaseChooser.Left + ColorBaseChooser.Width + 5;
  ColorBaseChooserLabel.Caption := L('Selected Color');

  ColorToChooser := TShape.Create(Panel);
  ColorToChooser.Parent := Panel;
  ColorToChooser.Top := ColorBaseChooser.Top + ColorBaseChooser.Height + 5;
  ColorToChooser.Left := 8;
  ColorToChooser.Width := 17;
  ColorToChooser.Height := 17;
  ColorToChooser.OnMouseDown := ColorMouseDown;
  ColorToChooser.Brush.Color := $FFFFFF;

  ColorToChooserLabel := TLabel.Create(Panel);
  ColorToChooserLabel.Parent := Panel;
  ColorToChooserLabel.Top := ColorBaseChooser.Top + ColorBaseChooser.Height + 8;
  ColorToChooserLabel.Left := ColorToChooser.Left + ColorToChooser.Width + 5;
  ColorToChooserLabel.Caption := L('New Color');

  FButtonCustomColor := TButton.Create(Panel);
  FButtonCustomColor.Parent := Panel;
  FButtonCustomColor.Top := ColorToChooser.Top + ColorToChooser.Height + 5;
  FButtonCustomColor.Width := 80;
  FButtonCustomColor.Height := 21;
  FButtonCustomColor.Left := 8;
  FButtonCustomColor.Caption := L('Select color');
  FButtonCustomColor.OnMouseDown := ButtonMouseDown;
  FButtonCustomColor.OnMouseMove := ButtonMouseMove;
  FButtonCustomColor.OnMouseUp := ButtonMouseUp;

  Result := True;
  Loading := False;
  if AMakeImage then
    MakeImage(Self);
end;

procedure TReplaceColorEffect.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TReplaceColorEffect.GetName: string;
begin
  Result := L('Replace color');
end;

procedure TReplaceColorEffect.GetPreview(S, D: TBitmap);
begin
  ReplaceColorInImage(S, D, ClBlue, ClGreen, 100, 2);
end;

function TReplaceColorEffect.GetProperties: string;
begin
  Result := 'ReplaceColorValue=' + IntToStr(FReplaceColorValue.Position) + ';';
  Result := Result + 'ReplaceColorSize=' + IntToStr(FReplaceColorSize.Position) + ';';
  Result := Result + 'ColorBase=' + IntToStr(ColorBaseChooser.Brush.Color) + ';';
  Result := Result + 'ColorTo=' + IntToStr(ColorToChooser.Brush.Color) + ';';
end;

class function TReplaceColorEffect.ID: string;
begin
  Result := '{8911A34F-074F-452A-BD58-13102F049DF0}';
end;

procedure TReplaceColorEffect.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  if Loading then
    Exit;
  D := TBitmap.Create;
  D.Assign(FS);
  FReplaceColorSizeLabel.Caption := Format(L('Value [%d]'), [FReplaceColorSize.Position]);
  FReplaceColorValueLabel.Caption := Format(L('Disorder [%d]'), [FReplaceColorValue.Position]);
  FSID := IntToStr(Random(10000));
  TReplaceColorEffectThread.Create(Self, D, ColorBaseChooser.Brush.Color, ColorToChooser.Brush.Color,
    FReplaceColorValue.Position, FReplaceColorSize.Position, FSID, ExitThread);
end;

procedure TReplaceColorEffect.Progress(Progress: Integer;
  var Break: boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TReplaceColorEffect.SetProperties(Properties: string);
begin
  FReplaceColorValue.Position := GetIntValueByName(Properties, 'ReplaceColorValue', 1);
  FReplaceColorSize.Position := GetIntValueByName(Properties, 'ReplaceColorSize', 1);
  ColorBaseChooser.Brush.Color := GetIntValueByName(Properties, 'ColorBase', 1);
  ColorToChooser.Brush.Color := GetIntValueByName(Properties, 'ColorTo', 1);
  MakeImage(Self);
end;

{ TReplaceColorEffectThread }

constructor TReplaceColorEffectThread.Create(AOwner: TObject; S: TBitmap; ColorBase, ColorNew: TColor;
  Size, Value: Integer; SID: string; OnExit: TBaseEffectProcThreadExit);
begin
  inherited Create(False);
  FAOwner := AOwner;
  FS := S;
  FSize := Size;
  FColorBase := ColorBase;
  FColorNew := ColorNew;
  FSID := SID;
  FValue := Value;
  FOnExit := OnExit;
end;

procedure TReplaceColorEffectThread.Execute;
var
  New: TBitmap;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TReplaceColorEffect).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := pf24bit;
  ReplaceColorInImage(FS, New, FColorBase, FColorNew, FSize, FValue, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TReplaceColorEffectThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TReplaceColorEffectThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TReplaceColorEffect).FSID = FSID then
    (FAOwner as TReplaceColorEffect).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TReplaceColorEffectThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

{ TCustomMatrixEffect }

constructor TCustomMatrixEffect.Create;
begin
  inherited;
  Lock := False;
  FButtonPressed := False;
  GOM.AddObj(Self);
end;

procedure TCustomMatrixEffect.DeletePresentClick(Sender: TObject);
var
  Name: string;
begin
  Name := PresentComboBox.Text;
  if Name = '' then
    Exit;
  Settings.DeleteKey('Editor\CustomEffect\' + Name);
  ReloadUserPresents;
end;

destructor TCustomMatrixEffect.Destroy;
begin
  GOM.RemoveObj(Self);
  inherited;
end;

function TCustomMatrixEffect.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
var
  I, J: Integer;
begin
  Panel.Caption:= GetName;
  FS := S;
  FD := D;
  LabelMatrix := TLabel.Create(Panel);
  LabelMatrix.Parent := Panel;
  LabelMatrix.Caption := L('Matrix 5x5') + ':';
  LabelMatrix.Top := 18;
  LabelMatrix.Left := 8;
  LabelMatrix.Width := 100;
  LabelMatrix.Height := 15;
  LabelMatrix.Visible := True;
  Lock := True;
  for I := 1 to 5 do
    for J := 1 to 5 do
    begin
      E[I, J] := TEdit.Create(Panel);
      E[I, J].Parent := Panel;
      E[I, J].Text := '0';
      E[I, J].Top := LabelMatrix.Top + LabelMatrix.Height + 5 + (I - 1) * 25;
      E[I, J].Left := 8 + (J - 1) * 30;
      E[I, J].Width := 25;
      E[I, J].Height := 20;
      E[I, J].Visible := True;
      E[I, J].OnChange := ParamsChanged;
    end;
  E[3, 3].Text := '1';
  DeviderLabel := TLabel.Create(Panel);
  DeviderLabel.Parent := Panel;
  DeviderLabel.Caption := L('Devider') + ':';
  DeviderLabel.Top := E[5, 5].Top + E[5, 5].Height + 8;
  DeviderLabel.Left := 8;
  DeviderLabel.Width := 100;
  DeviderLabel.Height := 21;

  DeviderLabel.Visible := True;
  DeviderEdit := TEdit.Create(Panel);
  DeviderEdit.Parent := Panel;
  DeviderEdit.Text := '1';
  DeviderEdit.Top := DeviderLabel.Top + DeviderLabel.Height + 2;
  DeviderEdit.Left := 8;
  DeviderEdit.Width := 100;
  DeviderEdit.Height := 21;
  DeviderEdit.Visible := True;
  DeviderEdit.OnChange := ParamsChanged;

  FSampleEffectLabel := TLabel.Create(Panel);
  FSampleEffectLabel.Parent := Panel;
  FSampleEffectLabel.Caption := L('Sample effect') + ':';
  FSampleEffectLabel.Top := E[5, 5].Top + E[5, 5].Height + 8;
  FSampleEffectLabel.Left := DeviderLabel.Left + DeviderLabel.Width + 5;
  FSampleEffectLabel.Width := 150;
  FSampleEffectLabel.Height := 21;

  FSampleEffect := TComboBox.Create(Panel);
  FSampleEffect.Parent := Panel;
  FSampleEffect.Width := 140;
  FSampleEffect.Height := 21;
  FSampleEffect.Top := FSampleEffectLabel.Top + FSampleEffectLabel.Height + 2;
  FSampleEffect.Left := DeviderLabel.Left + DeviderLabel.Width + 5;
  FSampleEffect.OnChange := FillMatrix;
  FSampleEffect.Style := CsDropDownList;
  FSampleEffect.DropDownCount := 15;
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
  FSampleEffect.ItemIndex := 0;

  SaveNameEditLabel := TLabel.Create(Panel);
  SaveNameEditLabel.Top := 18;
  SaveNameEditLabel.Left := E[5, 5].Left + E[5, 5].Width + 5;
  SaveNameEditLabel.Width := 100;
  SaveNameEditLabel.Parent := Panel;
  SaveNameEditLabel.Caption := L('Configuration name') + ':';
  SaveNameEditLabel.Visible := True;

  SaveNameEdit := TEdit.Create(Panel);
  SaveNameEdit.Top := SaveNameEditLabel.Top + SaveNameEditLabel.Height + 5;
  SaveNameEdit.Left := E[5, 5].Left + E[5, 5].Width + 5;
  SaveNameEdit.Width := 100;
  SaveNameEdit.Height := 21;
  SaveNameEdit.Parent := Panel;
  SaveNameEdit.Text := L('Configuration name');
  SaveNameEdit.Visible := True;

  SaveCurrentButton := TButton.Create(Panel);
  SaveCurrentButton.Top := SaveNameEdit.Top + SaveNameEdit.Height + 3;
  SaveCurrentButton.Left := E[5, 5].Left + E[5, 5].Width + 5;
  SaveCurrentButton.Width := 100;
  SaveCurrentButton.Height := 21;
  SaveCurrentButton.Parent := Panel;
  SaveCurrentButton.Caption := L('Save configuration');
  SaveCurrentButton.Visible := True;
  SaveCurrentButton.OnClick := SavePresentClick;

  PresentComboBox := TComboBox.Create(Panel);
  PresentComboBox.Top := SaveCurrentButton.Top + SaveCurrentButton.Height + 3;
  PresentComboBox.Left := E[5, 5].Left + E[5, 5].Width + 5;
  PresentComboBox.Width := 100;
  PresentComboBox.Parent := Panel;
  PresentComboBox.Style := CsDropDownList;
  PresentComboBox.Visible := True;
  PresentComboBox.OnChange := PresentSelect;

  LoadSelectedButton := TButton.Create(Panel);
  LoadSelectedButton.Top := PresentComboBox.Top + PresentComboBox.Height + 3;
  LoadSelectedButton.Left := E[5, 5].Left + E[5, 5].Width + 5;
  LoadSelectedButton.Width := 100;
  LoadSelectedButton.Height := 21;
  LoadSelectedButton.Parent := Panel;
  LoadSelectedButton.Caption := L('Load configuration');
  LoadSelectedButton.Visible := True;
  LoadSelectedButton.OnClick := LoadPresentClick;

  DeleteSelectedButton := TButton.Create(Panel);
  DeleteSelectedButton.Top := LoadSelectedButton.Top + LoadSelectedButton.Height + 3;
  DeleteSelectedButton.Left := E[5, 5].Left + E[5, 5].Width + 5;
  DeleteSelectedButton.Width := 100;
  DeleteSelectedButton.Height := 21;
  DeleteSelectedButton.Parent := Panel;
  DeleteSelectedButton.Caption := L('Delete configuration');
  DeleteSelectedButton.Visible := True;
  DeleteSelectedButton.OnClick := DeletePresentClick;

  Lock := False;
  Result := True;
  ReloadUserPresents;
  MakeImage(Self);
end;

procedure TCustomMatrixEffect.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

procedure TCustomMatrixEffect.FillMatrix(Sender: TObject);
var
  I, J: Integer;
  MX: TConvolutionMatrix;
begin
  Lock := True;
  for I := 0 to 24 do
    MX.Matrix[I] := 0;
  MX := Filterchoice(FSampleEffect.ItemIndex);
  for I := -2 to 2 do
    for J := -2 to 2 do
      E[3 + I, 3 + J].Text := IntToStr(MX.Matrix[(I + 2) * 5 + J + 2]);

  DeviderEdit.Text := IntToStr(MX.Devider);
  Lock := False;
  MakeImage(Self);
end;

function TCustomMatrixEffect.GetName: string;
begin
  Result := L('Custom Effect');
end;

procedure TCustomMatrixEffect.GetPreview(S, D: TBitmap);
begin
  D.Assign(S);
end;

function TCustomMatrixEffect.GetProperties: string;
var
  I, J: Integer;
begin
  Result := 'Devider=' + IntToStr(StrToIntDef(DeviderEdit.Text, 1)) + ';';
  for I := 1 to 5 do
    for J := 1 to 5 do
      Result := Result + Format('v%d&%d=', [I, J]) + IntToStr(StrToIntDef(E[I, J].Text, 1)) + ';';
end;

class function TCustomMatrixEffect.ID: string;
begin
 Result:='{84ABBC44-9F9D-4373-9676-6BD986B4464E}';
end;

procedure TCustomMatrixEffect.LoadPresentClick(Sender: TObject);
var
  I, J: Integer;
  name: string;
begin
  name := PresentComboBox.Text;
  for I := -2 to 2 do
    for J := -2 to 2 do
    begin
      E[3 + I, 3 + J].Text := Settings.ReadString('Editor\CustomEffect\' + name, InttoStr((I + 2) * 5 + J + 2));
    end;
  DeviderEdit.Text := Settings.ReadString('Editor\CustomEffect\' + name, 'Devider');
end;

procedure TCustomMatrixEffect.MakeImage(Sender: TObject);
var
  D: TBitmap;
  MX: TConvolutionMatrix;
  I, J: Integer;
begin
  if Lock then
    Exit;
  Lock := True;
  begin
    MX.Devider := StrtoIntDef(DeviderEdit.Text, 1);
    for I := 0 to 24 do
      MX.Matrix[I] := 0;
    for I := -2 to 2 do
      for J := -2 to 2 do
      begin
        MX.Matrix[(I + 2) * 5 + J + 2] := StrToIntDef(E[3 + I, 3 + J].Text, 0);
      end;
  end;
  Lock := False;
  D := TBitmap.Create;
  D.Assign(FS);
  FSID := IntToStr(Random(10000));
  TCustomMatrixEffectThread.Create(Self, False, D, MX, FSID, ExitThread);
end;

procedure TCustomMatrixEffect.ParamsChanged(Sender: TObject);
begin
  MakeImage(Sender);
end;

procedure TCustomMatrixEffect.PresentSelect(Sender: TObject);
begin
  RefreshButtons;
end;

procedure TCustomMatrixEffect.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TCustomMatrixEffect.RefreshButtons;
begin
  if (PresentComboBox.ItemIndex <> -1) then
  begin
    DeleteSelectedButton.Enabled := True;
    LoadSelectedButton.Enabled := True;
  end else
  begin
    DeleteSelectedButton.Enabled := False;
    LoadSelectedButton.Enabled := False;
  end;
end;

procedure TCustomMatrixEffect.ReloadUserPresents;
var
  I: Integer;
  List: TStrings;
begin
  PresentComboBox.Clear;
  List := Settings.ReadKeys('Editor\CustomEffect');
  for I := 1 to List.Count do
    PresentComboBox.Items.Add(List[I - 1]);

  RefreshButtons;
end;

procedure TCustomMatrixEffect.SavePresentClick(Sender: TObject);
var
  Name: string;
  I, J: Integer;
begin
  Name := SaveNameEdit.Text;
  for I := 1 to Length(Name) do
  begin
    if (Name[I] = '\') or (Name[I] = '/') or (Name[I] = ':') or (Name[I] = ';') then
      Name[I] := '_';
  end;
  for I := -2 to 2 do
    for J := -2 to 2 do
      Settings.WriteString('Editor\CustomEffect\' + name, IntToStr((I + 2) * 5 + J + 2), E[3 + I, 3 + J].Text);

  Settings.WriteString('Editor\CustomEffect\' + name, 'Devider', DeviderEdit.Text);

  ReloadUserPresents;
end;

procedure TCustomMatrixEffect.SetProperties(Properties: string);
var
  I, J: Integer;
begin
  DeviderEdit.Text := GetValueByName(Properties, 'Devider');
  for I := 1 to 5 do
    for J := 1 to 5 do
      E[I, J].Text := GetValueByName(Properties, Format('v%d&%d', [I, J]));

  MakeImage(Self);
end;

{ TCustomMatrixEffectThread }

constructor TCustomMatrixEffectThread.Create(AOwner: TObject; CreateSuspended: Boolean; S: TBitmap;
  M: TConvolutionMatrix; SID: string; OnExit: TBaseEffectProcThreadExit);
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
  New: TBitmap;
  P1, P2: TArPRGBArray;
  I: Integer;
begin
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TCustomMatrixEffect).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.Width := FS.Width;
  New.Height := FS.Height;
  New.PixelFormat := Pf24bit;
  Setlength(P1, FS.Height);
  Setlength(P2, FS.Height);
  for I := 0 to FS.Height - 1 do
  begin
    P1[I] := FS.Scanline[I];
    P2[I] := New.Scanline[I];
  end;
  MatrixEffectsW(0, 100, P1, P2, FS.Width - 1, FS.Height - 1, FM, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TCustomMatrixEffectThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TCustomMatrixEffectThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TCustomMatrixEffect).FSID = FSID then
    (FAOwner as TCustomMatrixEffect).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TCustomMatrixEffectThread.OnExit;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    F(FS);
    Exit;
  end;
  if Assigned(FOnExit) then
    FOnExit(FS, FSID)
  else
    F(FS);
end;

end.
