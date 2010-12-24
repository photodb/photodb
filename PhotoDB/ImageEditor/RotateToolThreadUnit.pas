unit RotateToolThreadUnit;

interface

uses
  Windows, Classes, Effects, EffectsToolUnit, Graphics, RotateToolUnit,
  Language, GraphicsBaseTypes, ScanlinesFX, uEditorTypes;

type
  TRotateEffectThread = class(TThread)
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
  inherited Create(False);
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
 if (FEditor as TImageEditor).ToolClass=FOwner then
 FOnExit(D,FSID) else
 begin
  D.Free;
 end;
end;

procedure TRotateEffectThread.Execute;
begin
 inherited;
 FreeOnTerminate:=true;
 sleep(50);
 if (FEditor is TImageEditor) then
 begin
 if (FEditor as TImageEditor).ToolClass=FOwner then
 begin
  if (FOwner as TRotateToolPanelClass).FSID<>FSID then
  begin
   BaseImage.free;
   exit;
  end;
 end else
 begin
  BaseImage.free;
  exit;
 end;
 end else
 begin
  BaseImage.free;
  exit;
 end;
 D:=TBitmap.Create;
 if Assigned(FProc) then
 FProc(BaseImage,D,CallBack) else
 begin
  D.Assign(BaseImage);
  RotateBitmap(D,FAngle,FBackColor,CallBack);
 end;
 Synchronize(DoExit);
 BaseImage.Free;
 intParam:=0;
 Synchronize(SetProgress);
end;

procedure TRotateEffectThread.SetProgress;
begin
 if (FEditor as TImageEditor).ToolClass=FOwner then
 if (FOwner is TRotateToolPanelClass) then
 (FOwner as TRotateToolPanelClass).SetProgress(IntParam,FSID);
end;

end.
