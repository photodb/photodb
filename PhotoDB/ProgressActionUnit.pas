unit ProgressActionUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DmProgress, Language, Dolphin_DB, AppEvnts,
  uVistaFuncs;

type
  TProgressActionForm = class(TForm)
    OperationCounter: TDmProgress;
    OperationProgress: TDmProgress;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    FOneOperation: boolean;
    FPosition: int64;
    FMaxPosCurrentOperation: int64;
    FLoading: boolean;
    FOperationCount: int64;
    FOperationPosition: int64;
    FCanClosedByUser : boolean;
    fBackground : boolean;
    procedure SetOneOperation(const Value: boolean);
    procedure SetPosition(const Value: int64);
    procedure SetMaxPosCurrentOperation(const Value: int64);
    procedure SetLoading(const Value: boolean);
    procedure SetOperationCount(const Value: int64);
    procedure SetOperationPosition(const Value: int64);
    procedure SetCanClosedByUser(const Value: Boolean);
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    { Private declarations }
  public
  WindowID : string;
  Closed : Boolean;
  WindowCanClose : boolean;
  Procedure DoShow;
  Procedure SetMaxOneValue(Value : int64);
  Procedure SetMaxTwoValue(Value : int64);
  Procedure ReCount;
  Procedure LoadLanguage;
  Procedure SetAlternativeText(Text : String);
   constructor Create(AOwner: TComponent; Background : boolean); reintroduce;
  published
  Property OneOperation : boolean read FOneOperation Write SetOneOperation;
  Property xPosition : int64 read FPosition write SetPosition;
  Property MaxPosCurrentOperation : int64 read FMaxPosCurrentOperation write SetMaxPosCurrentOperation;
  Property Loading : boolean read FLoading write SetLoading default true;
  Property OperationCount : int64 read FOperationCount write SetOperationCount;
  Property OperationPosition : int64 read FOperationPosition write SetOperationPosition;
  Property CanClosedByUser : Boolean read FCanClosedByUser write SetCanClosedByUser default false;
    { Public declarations }
  end;

  TArForms = array of TForm;

  TManagerProgresses = class(TObject)
   Private
    FForms : TArForms;
   Public
    Constructor Create;
    Destructor Destroy; override;
    Function NewProgress : TProgressActionForm;
    Procedure AddProgress(Progress : TForm);
    Procedure RemoveProgress(Progress : TForm);
    Property Progresses : TArForms Read FForms;
    Function IsProgress(Progress : TProgressActionForm) : Boolean;
    Function ProgressCount : Integer;
   published
  end;

function GetProgressWindow(Background : boolean = false) : TProgressActionForm;

var
  ManagerProgresses : TManagerProgresses;

implementation

{$R *.dfm}

function GetProgressWindow(Background : boolean = false) : TProgressActionForm;
begin
 Result:=TProgressActionForm.Create(Application,Background);
// Application.CreateForm(TProgressActionForm,Result);
end;

procedure TProgressActionForm.DoShow;
begin
 if not CanClosedByUser then
 Del_close_btn(Handle);
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
 WindowCanClose:=false;
 Closed:=false;
 WindowID:=GetCID;
 ManagerProgresses.AddProgress(self);
 DBKernel.RecreateThemeToForm(self);
 LoadLanguage;
 FLoading:=false;
 FCanClosedByUser:=false;
 DoubleBuffered:=true;
end;

procedure TProgressActionForm.LoadLanguage;
begin
 Label3.Caption:=TEXT_MES_WAIT_ACTION;
 Label2.Caption:=TEXT_MES_TASKS+':';
 Label1.Caption:=TEXT_MES_CURRENT_ACTION+':';
 Caption:=TEXT_MES_PROGRESS_FORM;
 OperationCounter.Text:=TEXT_MES_DEFAULT_PROGRESS_TEXT;
 OperationProgress.Text:=TEXT_MES_DEFAULT_PROGRESS_TEXT;
end;

procedure TProgressActionForm.ReCount;
begin
 if OneOperation then
 begin
  OperationProgress.MaxValue:=FMaxPosCurrentOperation;
  OperationProgress.Position:=FPosition;
  OperationCounter.MaxValue:=FMaxPosCurrentOperation;
  OperationCounter.Position:=FPosition;
 end else
 begin
  OperationProgress.MaxValue:=FMaxPosCurrentOperation;
  OperationProgress.Position:=FPosition;
  OperationCounter.MaxValue:=FOperationCount;
  OperationCounter.Position:=FOperationPosition;
 end;
end;

procedure TProgressActionForm.SetAlternativeText(Text: String);
begin
 Label3.Caption:=Text;
end;

procedure TProgressActionForm.SetLoading(const Value: boolean);
begin
  FLoading := Value;
end;

procedure TProgressActionForm.SetMaxOneValue(Value: int64);
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

procedure TProgressActionForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if not CanClosedByUser then
 if Active then
 if Msg.message=260 then
 Msg.message:=0;
end;

procedure TProgressActionForm.SetCanClosedByUser(const Value: Boolean);
begin
  FCanClosedByUser := Value;
end;

{ TManagerProgresses }

procedure TManagerProgresses.AddProgress(Progress: TForm);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FForms)-1 do
 if FForms[i]=Progress then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FForms,Length(FForms)+1);
  FForms[Length(FForms)-1]:=Progress;
 end;
end;


constructor TManagerProgresses.Create;
begin
  SetLength(FForms,0);
end;

destructor TManagerProgresses.Destroy;
begin
  SetLength(FForms,0);
  inherited;
end;

function TManagerProgresses.IsProgress(
  Progress: TProgressActionForm): Boolean;
var
  i : Integer;
begin
 Result:=False;
 For i:=0 to Length(FForms)-1 do
 if FForms[i]=Progress then
 Begin
  Result:=True;
  Break;
 End;
end;

function TManagerProgresses.NewProgress: TProgressActionForm;
begin
  Application.CreateForm(TProgressActionForm,Result);
end;

function TManagerProgresses.ProgressCount: Integer;
begin
 Result:=Length(FForms);
end;

procedure TManagerProgresses.RemoveProgress(Progress: TForm);
var
  i, j : integer;
begin
 For i:=0 to Length(FForms)-1 do
 if FForms[i]=Progress then
 begin
  For j:=i to Length(FForms)-2 do
  FForms[j]:=FForms[j+1];
  SetLength(FForms,Length(FForms)-1);
  break;
 end;
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
  Closed:=ID_YES=MessageBoxDB(Handle,TEXT_MES_DO_YOU_REALLY_WANT_CANCEL_OPERATION,TEXT_MES_QUESTION,TD_BUTTON_YESNO,TD_ICON_QUESTION);
  CanClose:=WindowCanClose;
 end;
end;

constructor TProgressActionForm.Create(AOwner: TComponent; Background : boolean);
begin
 inherited Create(AOwner);
 fBackground:=Background;
 if Background then
 begin
  Position :=poDefault;
 end else Position := poScreenCenter;
end;

procedure TProgressActionForm.FormShow(Sender: TObject);
begin
 if fBackground then
 begin
  Top := Screen.WorkAreaHeight-Height;
  Left := Screen.WorkAreaWidth-Width;
   //TODO: in options
  AlphaBlend:=true;
  AlphaBlendValue:=220;
 end;
end;

procedure TProgressActionForm.CreateParams(var Params: TCreateParams);
begin
 inherited CreateParams(Params);
 if IsWindowsVista then
 Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TProgressActionForm.WMActivate(var Message: TWMActivate);
begin
 if (Message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) and IsWindowsVista then
 begin
  SetActiveWindow(Application.Handle);
  Message.Result := 0;
 end else
  inherited;
end;

procedure TProgressActionForm.WMSyscommand(var Message: TWmSysCommand);
begin
  case (Message.CmdType and $FFF0) of
    SC_MINIMIZE:
    begin
      ShowWindow(Handle, SW_MINIMIZE);
      Message.Result := 0;
    end;
    SC_RESTORE:
    begin
      ShowWindow(Handle, SW_RESTORE);
      Message.Result := 0;
    end;
  else
    inherited;
  end;
end;

procedure TProgressActionForm.FormPaint(Sender: TObject);
begin
 if not Active then
 begin
  OperationCounter.DoPaintOnXY(Canvas,OperationCounter.Left,OperationCounter.Top);
  OperationProgress.DoPaintOnXY(Canvas,OperationProgress.Left,OperationProgress.Top);
 end;
end;

initialization

ManagerProgresses := TManagerProgresses.create;

finalization

ManagerProgresses.free;

end.
