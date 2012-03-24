unit ProgressActionUnit;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  DmProgress,
  Dolphin_DB,
  AppEvnts,
  uGUIDUtils,
  uConstants,
  uVistaFuncs,
  uGOM,
  uMemory,
  uShellIntegration,
  uSysUtils,
  uDBForm,
  pngimage;

type
  TProgressActionForm = class(TDBForm)
    OperationCounter: TDmProgress;
    OperationProgress: TDmProgress;
    LbActiveTask: TLabel;
    LbTasks: TLabel;
    LbInfo: TLabel;
    ImMain: TImage;
    AeMain: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FOneOperation: Boolean;
    FPosition: Int64;
    FMaxPosCurrentOperation: Int64;
    FLoading: Boolean;
    FOperationCount: Int64;
    FOperationPosition: Int64;
    FCanClosedByUser: Boolean;
    FBackground: Boolean;
    procedure SetOneOperation(const Value: Boolean);
    procedure SetPosition(const Value: Int64);
    procedure SetMaxPosCurrentOperation(const Value: Int64);
    procedure SetLoading(const Value: Boolean);
    procedure SetOperationCount(const Value: Int64);
    procedure SetOperationPosition(const Value: Int64);
    procedure SetCanClosedByUser(const Value: Boolean);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    WindowID: TGUID;
    Closed: Boolean;
    WindowCanClose: Boolean;
    procedure DoFormShow;
    procedure SetMaxOneValue(Value: Int64);
    procedure SetMaxTwoValue(Value: Int64);
    procedure ReCount;
    procedure LoadLanguage;
    procedure SetAlternativeText(Text: string);
    constructor Create(AOwner: TComponent; Background: Boolean); reintroduce;
  published
    { Published declarations }
    property OneOperation: Boolean read FOneOperation write SetOneOperation;
    property XPosition: Int64 read FPosition write SetPosition;
    property MaxPosCurrentOperation: Int64 read FMaxPosCurrentOperation write SetMaxPosCurrentOperation;
    property Loading: Boolean read FLoading write SetLoading default True;
    property OperationCount: Int64 read FOperationCount write SetOperationCount;
    property OperationPosition: Int64 read FOperationPosition write SetOperationPosition;
    property CanClosedByUser: Boolean read FCanClosedByUser write SetCanClosedByUser default False;
  end;

  TManagerProgresses = class(TObject)
  private
    FForms: TList;
    function GetItem(Index: Integer): TProgressActionForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewProgress: TProgressActionForm;
    procedure AddProgress(Progress: TForm);
    procedure RemoveProgress(Progress: TForm);
    function IsProgress(Progress: TProgressActionForm): Boolean;
    function ProgressCount: Integer;
    property Items[Index: Integer] : TProgressActionForm read GetItem; default;
  end;

function GetProgressWindow(Background: Boolean = False): TProgressActionForm;

var
  ManagerProgresses: TManagerProgresses = nil;

implementation

{$R *.dfm}

function GetProgressWindow(Background: Boolean = False): TProgressActionForm;
begin
  Result := TProgressActionForm.Create(Application, Background);
end;

procedure TProgressActionForm.DoFormShow;
begin
  if not CanClosedByUser then
    DisableWindowCloseButton(Handle);
  if not Visible then
  begin
    Show;
    SetFocus;
    Invalidate;
    Refresh;
    Repaint;
  end;
end;

procedure TProgressActionForm.FormCreate(Sender: TObject);
begin
  WindowCanClose := False;
  Closed := False;
  WindowID := GetGUID;
  ManagerProgresses.AddProgress(Self);
  LoadLanguage;
  FLoading := False;
  FCanClosedByUser := False;
  DoubleBuffered := True;
end;

procedure TProgressActionForm.LoadLanguage;
begin
  BeginTranslate;
  try
    LbInfo.Caption := L('Please wait while the program performs the current operation and updates the collection.');
    LbTasks.Caption := L('Tasks') + ':';
    LbActiveTask.Caption := L('Current action') + ':';
    Caption := L('Action is performed');
    OperationCounter.Text := L('Processing... (&%%)');
    OperationProgress.Text := L('Processing... (&%%)');
  finally
    EndTranslate;
  end;
end;

procedure TProgressActionForm.ReCount;
begin
  if OneOperation then
  begin
    OperationProgress.MaxValue := FMaxPosCurrentOperation;
    OperationProgress.Position := FPosition;
    OperationCounter.MaxValue := FMaxPosCurrentOperation;
    OperationCounter.Position := FPosition;
  end else
  begin
    OperationProgress.MaxValue := FMaxPosCurrentOperation;
    OperationProgress.Position := FPosition;
    OperationCounter.MaxValue := FOperationCount;
    OperationCounter.Position := FOperationPosition;
  end;
end;

procedure TProgressActionForm.SetAlternativeText(Text: string);
begin
  LbInfo.Caption := Text;
end;

procedure TProgressActionForm.SetLoading(const Value: Boolean);
begin
  FLoading := Value;
end;

procedure TProgressActionForm.SetMaxOneValue(Value: Int64);
begin
  //
end;

procedure TProgressActionForm.SetMaxPosCurrentOperation(
  const Value: int64);
begin
  FMaxPosCurrentOperation := Value;
end;

procedure TProgressActionForm.SetMaxTwoValue(Value: int64);
begin
//
end;

procedure TProgressActionForm.SetOneOperation(const Value: boolean);
begin
  FOneOperation := Value;
  ReCount;
end;

procedure TProgressActionForm.SetOperationCount(const Value: int64);
begin
  FOperationCount := Value;
  ReCount;
end;

procedure TProgressActionForm.SetOperationPosition(const Value: int64);
begin
  FOperationPosition := Value;
  ReCount;
end;

procedure TProgressActionForm.SetPosition(const Value: int64);
begin
  FPosition := Value;
  ReCount;
end;

procedure TProgressActionForm.AeMainMessage(var Msg: TagMSG; var Handled: Boolean);
begin
  if not CanClosedByUser then
    if Active then
      if Msg.message = WM_SYSKEYDOWN then
        Msg.message := 0;
end;

procedure TProgressActionForm.SetCanClosedByUser(const Value: Boolean);
begin
  FCanClosedByUser := Value;
end;

{ TManagerProgresses }

procedure TManagerProgresses.AddProgress(Progress: TForm);
begin
  if FForms.IndexOf(Progress) < 0 then
    FForms.Add(Progress)
end;

constructor TManagerProgresses.Create;
begin
  FForms := TList.Create;
end;

destructor TManagerProgresses.Destroy;
begin
  F(FForms);
  inherited;
end;

function TManagerProgresses.GetItem(Index: Integer): TProgressActionForm;
begin
  Result := FForms[Index];
end;

function TManagerProgresses.IsProgress(Progress: TProgressActionForm): Boolean;
begin
  Result := FForms.IndexOf(Progress) > -1;
end;

function TManagerProgresses.NewProgress: TProgressActionForm;
begin
  Application.CreateForm(TProgressActionForm,Result);
end;

function TManagerProgresses.ProgressCount: Integer;
begin
  Result := FForms.Count;
end;

procedure TManagerProgresses.RemoveProgress(Progress: TForm);
begin
  FForms.Remove(Progress)
end;

procedure TProgressActionForm.FormDestroy(Sender: TObject);
begin
  ManagerProgresses.RemoveProgress(Self);
end;

procedure TProgressActionForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if CanClosedByUser then
  begin
    Closed := ID_YES = MessageBoxDB(Handle, L('Do you really want to abort the operation?'), L('Question'),
      TD_BUTTON_YESNO, TD_ICON_QUESTION);
    CanClose := WindowCanClose;
  end;
end;

constructor TProgressActionForm.Create(AOwner: TComponent; Background : boolean);
begin
  inherited Create(AOwner);
  FBackground := Background;
  if Background then
    Position := PoDefault
  else
    Position := PoScreenCenter;
end;

procedure TProgressActionForm.FormShow(Sender: TObject);
begin
  if FBackground then
  begin
    Top := Screen.WorkAreaHeight - Height;
    Left := Screen.WorkAreaWidth - Width;
    // TODO: in options
    AlphaBlend := True;
    AlphaBlendValue := 220;
  end;
end;

function TProgressActionForm.GetFormID: string;
begin
  Result := 'ActionProgress';
end;

procedure TProgressActionForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if IsWindowsVista then
    Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TProgressActionForm.FormPaint(Sender: TObject);
begin
  if not Active then
  begin
    OperationCounter.DoPaintOnXY(Canvas, OperationCounter.Left, OperationCounter.Top);
    OperationProgress.DoPaintOnXY(Canvas, OperationProgress.Left, OperationProgress.Top);
  end;
end;

initialization

  ManagerProgresses := TManagerProgresses.Create;

finalization

  F(ManagerProgresses);

end.
