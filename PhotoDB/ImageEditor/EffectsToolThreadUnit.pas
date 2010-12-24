unit EffectsToolThreadUnit;

interface

uses Windows,
  Classes, Effects, EffectsToolUnit, Graphics, GraphicsBaseTypes, Forms,
  Dolphin_DB, uVistaFuncs, uLogger, uEditorTypes, uShellIntegration;

type
  TBaseEffectThread = class(TThread)
  private
    { Private declarations }
    FSID: string;
    FProc: TBaseEffectProc;
    BaseImage: TBitmap;
    IntParam: Integer;
    FOnExit: TBaseEffectProcThreadExit;
    D: TBitmap;
    FOwner: TObject;
    FEditor: TForm;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TObject; Proc : TBaseEffectProc; S : TBitmap; SID : string; OnExit : TBaseEffectProcThreadExit; Editor : TForm);
    Procedure CallBack(Progress : integer; var Break: boolean);
    Procedure SetProgress;
    Procedure DoExit;
    Procedure ClearText;
  end;

implementation

uses ImEditor;

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
  Proc: TBaseEffectProc; S: TBitmap; SID: string; OnExit : TBaseEffectProcThreadExit; Editor : TForm);
begin
 inherited Create(False);
 FOwner:=AOwner;
 FSID:=SID;
 FOnExit := OnExit;
 FProc:=Proc;
 BaseImage:=S;
 FEditor:=Editor;
end;

procedure TBaseEffectThread.DoExit;
begin
  if not EditorsManager.IsEditor(FEditor) then
  begin
    D.Free;
    Exit;
  end;
  if (FEditor as TImageEditor).ToolClass = FOwner then
  begin
    Synchronize(ClearText);
    FOnExit(D, FSID);
  end
  else
  begin
    D.Free;
  end;
end;

procedure TBaseEffectThread.Execute;
begin
  FreeOnTerminate := True;
  D := TBitmap.Create;
  FProc(BaseImage, D, CallBack);
  Synchronize(DoExit);
  BaseImage.Free;
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
