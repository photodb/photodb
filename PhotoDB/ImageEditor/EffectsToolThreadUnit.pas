unit EffectsToolThreadUnit;

interface

uses
  Windows, Classes, Effects, EffectsToolUnit, Graphics, GraphicsBaseTypes, Forms,
  uConstants, uLogger, uEditorTypes, uShellIntegration, uMemory, uDBThread;

type
  TBaseEffectThread = class(TDBThread)
  private
    { Private declarations }
    FSID: string;
    FProc: TBaseEffectProc;
    BaseImage: TBitmap;
    IntParam: Integer;
    FOnExit: TBaseEffectProcThreadExit;
    D: TBitmap;
    FOwner: TObject;
    FEditor: TImageEditorForm;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TObject; Proc: TBaseEffectProc; S: TBitmap; SID: string;
      OnExit: TBaseEffectProcThreadExit; Editor: TImageEditorForm);
    procedure CallBack(Progress: Integer; var Break: Boolean);
    procedure SetProgress;
    procedure DoExit;
    procedure ClearText;
  end;

implementation

uses
  ImEditor;

procedure TBaseEffectThread.CallBack(Progress: Integer; var Break: Boolean);
begin
  IntParam := Progress;
  Synchronize(SetProgress);
  if not EditorsManager.IsEditor(FEditor) then
    Exit;
  if (FEditor as TImageEditor).ToolClass = FOwner then
    if FOwner is TEffectsToolPanelClass then
      Break := (FOwner as TEffectsToolPanelClass).FSID <> FSID;
end;

procedure TBaseEffectThread.ClearText;
begin
  if not EditorsManager.IsEditor(FEditor) then
    Exit;
  if (FEditor as TImageEditor).ToolClass = FOwner then
    (FEditor as TImageEditor).StatusBar1.Panels[0].Text := '';
end;

constructor TBaseEffectThread.Create(AOwner : TObject;
  Proc: TBaseEffectProc; S: TBitmap; SID: string; OnExit : TBaseEffectProcThreadExit; Editor : TImageEditorForm);
begin
  inherited Create(False);
  FOwner := AOwner;
  FSID := SID;
  FOnExit := OnExit;
  FProc := Proc;
  BaseImage := S;
  FEditor := Editor;
end;

procedure TBaseEffectThread.DoExit;
begin
  if not EditorsManager.IsEditor(FEditor) then
  begin
    F(D);
    Exit;
  end;
  if (FEditor as TImageEditor).ToolClass = FOwner then
  begin
    Synchronize(ClearText);
    FOnExit(D, FSID);
  end
  else
    F(D);
end;

procedure TBaseEffectThread.Execute;
begin
  FreeOnTerminate := True;
  D := TBitmap.Create;
  FProc(BaseImage, D, CallBack);
  Synchronize(DoExit);
  F(BaseImage);
  IntParam := 0;
  Synchronize(SetProgress);
end;

procedure TBaseEffectThread.SetProgress;
begin
  try
    if not EditorsManager.IsEditor(FEditor) then
      Exit;
    if (FEditor as TImageEditor).ToolClass = FOwner then
    begin
      if FOwner is TEffectsToolPanelClass then
        (FOwner as TEffectsToolPanelClass).SetProgress(IntParam, FSID);
    end;
  except
    if (FEditor as TImageEditor).ToolClass = FOwner then
      if FOwner is TEffectsToolPanelClass then
      begin
        EventLog('TBaseEffectThread.SetProgress() exception!');
        MessageBoxDB(Handle, 'TBaseEffectThread.SetProgress() exception!',
          'TBaseEffectThread.SetProgress() exception!', TD_BUTTON_OK, TD_ICON_ERROR);
      end;
  end;
end;

end.
