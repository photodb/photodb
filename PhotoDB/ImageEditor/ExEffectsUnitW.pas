unit ExEffectsUnitW;

interface

uses
  ExEffects,
  Effects,
  Graphics,
  StdCtrls,
  ComCtrls,

  uDBThread,
  Classes,

  SysUtils,
  ExtCtrls,
  Controls,
  uGOM,
  uEditorTypes,
  uMemory;

type
  TExEffectOneParamCustom = class(TExEffect)
  private
    { Private declarations }
    FS, FD: TBitmap;
    FTrackBar: TTrackBar;
    FTrackBarlabel: TLabel;
    FSID: string;
    FEffect: TEffectOneIntParam;
    FText: string;
    FName: string;
    FValue: Integer;
    FMax: Integer;
    procedure SetName(const Value: String);
    procedure SetText(const Value: String);
    procedure SetMax(const Value: Integer);
    procedure SetValue(const Value: Integer);
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
    procedure SetEffect(Effect: TEffectOneIntParam);
    property Text: string read FText write SetText;
    property name: string read FName write SetName;
    property Max: Integer read FMax write SetMax;
    property Value: Integer read FValue write SetValue;
  end;

type
  TExEffectOneParamCustomThread = class(TDBThread)
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
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

type
  TSepeaEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

type
  TAddColorNoiseEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

type
  TAddMonoNoiseEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

type
  TFishEyeEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function GetBestValue: Integer; override;
  end;

type
  TSplitBlurEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function GetBestValue: Integer; override;
  end;

type
  TTwistEffect = class(TExEffectOneParamCustom)
  private
    { Private declarations }
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create; override;
    destructor Destroy; override;
    function GetBestValue: Integer; override;
  end;

implementation

uses ImEditor;

{ TExEffectOneParamCustom }

constructor TExEffectOneParamCustom.Create;
begin
  inherited;
  GOM.AddObj(Self);
  FTrackBar := nil;
  FTrackBarlabel := nil;
end;

destructor TExEffectOneParamCustom.Destroy;
begin
  GOM.RemoveObj(Self);
  F(FTrackBar);
  F(FTrackBarlabel);
  inherited;
end;

function TExEffectOneParamCustom.Execute(S, D: TBitmap; Panel: TGroupBox; AMakeImage: Boolean): Boolean;
begin
  FS := S;
  FD := D;
  Panel.Caption := GetName;
  FTrackBarlabel := TLabel.Create(Panel);
  FTrackBarlabel.Parent := Panel;
  FTrackBarlabel.Top := 20;
  FTrackBarlabel.Left := 8;
  FTrackBar := TTrackBar.Create(nil);
  FTrackBar.Parent := Panel;
  FTrackBar.Top := FTrackBarlabel.Top + FTrackBarlabel.Height + 5;
  FTrackBar.Max := FMax;
  FTrackBar.Position := FValue;
  FTrackBar.Left := 8;
  FTrackBar.Min := 1;
  FTrackBar.Width := 250;
  FTrackBar.OnChange := MakeImage;
  MakeImage(Self);
  Result := True;
end;

procedure TExEffectOneParamCustom.ExitThread(Image: TBitmap; SID: string);
begin
  if SID = FSID then
    SetImageProc(Image)
  else
    F(Image);
end;

function TExEffectOneParamCustom.GetName: string;
begin
  Result := FName;
end;

procedure TExEffectOneParamCustom.GetPreview(S, D: TBitmap);
begin
  if GetBestValue < 0 then
    FEffect(S, D, 50)
  else
    FEffect(S, D, GetBestValue);
end;

class function TExEffectOneParamCustom.ID: string;
begin
  Result:='{99AB2B0A-B2A9-461D-A4E4-F799442E8A58}';
end;

procedure TExEffectOneParamCustom.MakeImage(Sender: TObject);
var
  D: TBitmap;
begin
  D := TBitmap.Create;
  D.Assign(FS);
  FTrackBarlabel.Caption := Format(FText, [FTrackBar.Position]);
  FSID := IntToStr(Random(MaxInt));
  TExEffectOneParamCustomThread.Create(Self, FEffect, False, D, FTrackBar.Position, FSID, ExitThread);
end;

procedure TExEffectOneParamCustom.Progress(Progress: Integer; var Break: Boolean);
begin
  (Editor as TImageEditor).FStatusProgress.Position := Progress;
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
  inherited Create(nil, False);
  FAOwner := AOwner;
  FEffect := Effect;
  FS := S;
  FInt := Int;
  FSID := SID;
  FOnExit := OnExit;
end;

procedure TExEffectOneParamCustomThread.Execute;
var
  New: TBitmap;
begin
  inherited;
  FreeOnTerminate := True;
  Sleep(100);
  if (FAOwner as TExEffectOneParamCustom).FSID <> FSID then
  begin
    F(FS);
    Exit;
  end;
  New := TBitmap.Create;
  New.PixelFormat := pf24bit;
  FEffect(FS, New, FInt, ImageProgress);
  F(FS);
  Pointer(FS) := Pointer(New);
  Synchronize(OnExit);
end;

procedure TExEffectOneParamCustomThread.ImageProgress(Progress: Integer; var Break: Boolean);
begin
  FBreak := Break;
  FProgress := Progress;
  Synchronize(ImageProgressSynch);
  Break := FBreak;
end;

procedure TExEffectOneParamCustomThread.ImageProgressSynch;
begin
  if not GOM.IsObj(FAOwner) then
  begin
    FBreak := True;
    Exit;
  end;
  if (FAOwner as TExEffectOneParamCustom).FSID = FSID then
    (FAOwner as TExEffectOneParamCustom).Progress(FProgress, FBreak)
  else
    FBreak := True;
end;

procedure TExEffectOneParamCustomThread.OnExit;
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

{ TGrayScaleEffect }

constructor TGrayScaleEffect.Create;
begin
  inherited;
  SetEffect(GrayScaleImage);
  Name := L('Custom grayscale');
  Text := L('Ñolor - Grayscale [%d]') + ':';
  FMax := 100;
  FValue := 50;
end;

destructor TGrayScaleEffect.Destroy;
begin
  inherited;
end;

class function TGrayScaleEffect.ID: string;
begin
  Result := '{BE5AE21F-5F27-4ADE-AAAF-FB9A8F591C08}';
end;

{ TSepeaEffect }

constructor TSepeaEffect.Create;
begin
  inherited;
  SetEffect(Sepia);
  name := L('Custom sepia');
  Text := L('Sepia value [%d]');
  FMax := 100;
  FValue := 50;
end;

destructor TSepeaEffect.Destroy;
begin

  inherited;
end;

class function TSepeaEffect.ID: string;
begin
  Result := '{DE6F7AEB-BDE7-4D36-859A-656645A7FBBC}';
end;

{ TAddColorNoiseEffect }

constructor TAddColorNoiseEffect.Create;
begin
  inherited;
  SetEffect(AddColorNoise);
  Name := L('Color noise');
  Text := L('Color noise') + ' [%d]';
  FMax := 100;
  FValue := 50;
end;

destructor TAddColorNoiseEffect.Destroy;
begin

  inherited;
end;

class function TAddColorNoiseEffect.ID: string;
begin
  Result := '{4FFBD84A-DA88-4A50-96CF-929951489DB8}';
end;

{ TAddMonoNoiseEffect }

constructor TAddMonoNoiseEffect.Create;
begin
  inherited;
  SetEffect(AddMonoNoise);
  name := L('Mono noise');
  Text := L('Mono noise') + ' [%d]';
  FMax := 100;
  FValue := 50;
end;

destructor TAddMonoNoiseEffect.Destroy;
begin

  inherited;
end;

class function TAddMonoNoiseEffect.ID: string;
begin
  Result := '{483B513B-2EAD-467C-A738-9A3B7BF446D0}';
end;

{ TFishEyeEffect }

constructor TFishEyeEffect.Create;
begin
  inherited;
  SetEffect(FishEye);
  Name := L('Fish eye');
  Text := L('Fish eye') + ' [%d]';
  FMax := 100;
  FValue := 10;
end;

destructor TFishEyeEffect.Destroy;
begin

  inherited;
end;

function TFishEyeEffect.GetBestValue: Integer;
begin
  Result := 20;
end;

class function TFishEyeEffect.ID: string;
begin
  Result := '{1FED9DDE-0B92-48B8-8C73-1D90901A8DE9}';
end;

{ TSplitBlurEffect }

constructor TSplitBlurEffect.Create;
begin
  inherited;
  SetEffect(SplitBlur);
  name := L('Linear blur');
  Text := L('Linear blur') + ' [%d]';
  FMax := 100;
  FValue := 5;
end;

destructor TSplitBlurEffect.Destroy;
begin

  inherited;
end;

function TSplitBlurEffect.GetBestValue: Integer;
begin
  Result := 10;
end;

class function TSplitBlurEffect.ID: string;
begin
  Result := '{1017603E-3059-4604-9AFD-E942F1C8B38E}';
end;

{ TTwistEffect }

constructor TTwistEffect.Create;
begin
  inherited;
  SetEffect(Twist);
  Name := L('Twist');
  Text := L('Twist') + ' [%d]';
  FMax := 1000;
  FValue := 100;
end;

destructor TTwistEffect.Destroy;
begin

  inherited;
end;

function TTwistEffect.GetBestValue: Integer;
begin
  Result := 10;
end;

class function TTwistEffect.ID: string;
begin
  Result := '{33EC7CD0-5512-490C-AE6E-4D38C564BF3E}';
end;

end.
