unit ResizeToolThreadUnit;

interface

uses
  Windows, Classes, Effects, EffectsToolUnit, Graphics, GraphicsBaseTypes,
  UnitResampleFilters, uEditorTypes, uMemory, uDBThread;

type
  TResizeToolThread = class(TDBThread)
  private
    { Private declarations }
    FSID: string;
    BaseImage: TBitmap;
    IntParam: Integer;
    FOnExit: TBaseEffectProcThreadExit;
    D: TBitmap;
    FOwner: TObject;
    FToWidth, FToHeight: Integer;
    FMethod: TResizeProcedure;
    FEditor: TObject;
    FIntMethod: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TObject; Method: TResizeProcedure; IntMethod: Integer; CreateSuspended: Boolean;
      S: TBitmap; SID: string; OnExit: TBaseEffectProcThreadExit; ToWidth, ToHeight: Integer; Editor: TObject);
    procedure CallBack(Progress: Integer; var Break: Boolean);
    procedure SetProgress;
    procedure DoExit;
  end;

implementation

uses ResizeToolUnit, ImEditor;

{ TResizeToolThread }

procedure TResizeToolThread.CallBack(Progress: Integer; var Break: Boolean);
begin
  IntParam := Progress;
  Synchronize(SetProgress);
  if (FEditor as TImageEditor).ToolClass = FOwner then
  begin
    if not(FOwner is TResizeToolPanelClass) then
    begin
      Break := True;
      Exit;
    end;
    Break := (FOwner as TResizeToolPanelClass).FSID <> FSID;
  end;
end;

constructor TResizeToolThread.Create(AOwner: TObject; Method : TResizeProcedure; IntMethod : Integer;
  CreateSuspended: Boolean; S: TBitmap; SID: string;
  OnExit: TBaseEffectProcThreadExit; ToWidth, ToHeight: Integer; Editor : TObject);
begin
  inherited Create(False);
  FOwner := AOwner;
  FSID := SID;
  FOnExit := OnExit;
  BaseImage := S;
  FToWidth := ToWidth;
  FMethod := Method;
  FIntMethod := IntMethod;
  FToHeight := ToHeight;
  FEditor := Editor;
end;

procedure TResizeToolThread.DoExit;
begin
  if (FEditor as TImageEditor).ToolClass = FOwner then
    FOnExit(D, FSID)
  else
  begin
    D.Free;
  end;
end;

procedure TResizeToolThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  try
    D := TBitmap.Create;
    D.PixelFormat := pf24bit;
    BaseImage.PixelFormat := pf24bit;
    if Assigned(FMethod) then
    begin
      if ((FToWidth / BaseImage.Width) > 1) or ((FToHeight / BaseImage.Height) > 1) then
        Interpolate(0, 0, FToWidth, FToHeight, Rect(0, 0, BaseImage.Width, BaseImage.Height), BaseImage, D, CallBack)
      else
        FMethod(FToWidth, FToHeight, BaseImage, D, CallBack);
    end else
    begin
      D.Width := FToWidth;
      D.Height := FToHeight;
      Strecth(BaseImage, D, ResampleFilters[FIntMethod].Filter, ResampleFilters[FIntMethod].Width, CallBack);
    end;
  finally
    F(BaseImage);
    Synchronize(DoExit);
    IntParam := 0;
    Synchronize(SetProgress);
  end;
end;

procedure TResizeToolThread.SetProgress;
begin
  if (FEditor as TImageEditor).ToolClass = FOwner then
    if (FOwner is TResizeToolPanelClass) then
      (FOwner as TResizeToolPanelClass).SetProgress(IntParam, FSID);
end;

end.
