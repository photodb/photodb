unit RotateToolThreadUnit;

interface

uses
  Windows,
  Classes,
  Effects,
  EffectsToolUnit,
  Graphics,
  RotateToolUnit,
  Dmitry.Graphics.Types,
  ScanlinesFX,
  uEditorTypes,
  uMemory,
  uDBThread;

type
  TRotateEffectThread = class(TDBThread)
  private
    { Private declarations }
    FSID: string;
    FProc: TBaseEffectProc;
    BaseImage: TBitmap;
    IntParam: Integer;
    FOnExit: TBaseEffectProcThreadExit;
    D: TBitmap;
    FOwner: TObject;
    FAngle: Double;
    FBackColor: TColor;
    FEditor: TObject;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TObject; CreateSuspended: Boolean; Proc: TBaseEffectProc; S: TBitmap; SID: string;
      OnExit: TBaseEffectProcThreadExit; Angle: Double; BackColor: TColor; Editor: TObject);
    procedure CallBack(Progress: Integer; var Break: Boolean);
    procedure SetProgress;
    procedure DoExit;
  end;

implementation

{ TRotateEffectThread }

uses ImEditor;

procedure TRotateEffectThread.CallBack(Progress: Integer; var Break: Boolean);
begin
  IntParam := Progress;
  Synchronize(SetProgress);
  if (FEditor as TImageEditor).ToolClass = FOwner then
    Break := (FOwner as TRotateToolPanelClass).FSID <> FSID;
end;

constructor TRotateEffectThread.Create(AOwner: TObject;
  CreateSuspended: Boolean; Proc: TBaseEffectProc; S: TBitmap; SID: string;
  OnExit: TBaseEffectProcThreadExit; Angle: Double; BackColor: TColor; Editor : TObject);
begin
  inherited Create(nil, False);
  FOwner := AOwner;
  FSID := SID;
  FAngle := Angle;
  FBackColor := BackColor;
  FOnExit := OnExit;
  FProc := Proc;
  BaseImage := S;
  FEditor := Editor;
end;

procedure TRotateEffectThread.DoExit;
begin
  if (FEditor as TImageEditor).ToolClass = FOwner then
  begin
    FOnExit(D, FSID);
    D := nil;
  end;
end;

procedure TRotateEffectThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  Sleep(50);
  try
    if not (FEditor is TImageEditor) then
      Exit;

    if (FEditor as TImageEditor).ToolClass <> FOwner then
      Exit;

    if (FOwner as TRotateToolPanelClass).FSID <> FSID then
      Exit;

    D := TBitmap.Create;
    try
      if Assigned(FProc) then
        FProc(BaseImage, D, CallBack)
      else
        RotateBitmap(BaseImage, D, FAngle, FBackColor, CallBack);

      Synchronize(DoExit);
    finally
      F(D);
    end;
  finally
    F(BaseImage)
  end;
  IntParam := 0;
  Synchronize(SetProgress);
end;

procedure TRotateEffectThread.SetProgress;
begin
  if (FEditor as TImageEditor).ToolClass = FOwner then
    if (FOwner is TRotateToolPanelClass) then
      (FOwner as TRotateToolPanelClass).SetProgress(IntParam, FSID);
end;

end.
