unit uOperationProgress;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  uMemory,
  uMemoryEx,
  uShellIntegration,
  uDBForm;

type
  TFormOperationProgress = class(TDBForm)
    PrbProgress: TProgressBar;
    BtnCancel: TButton;
    LbInfo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
    FClosed: Boolean;
    procedure LoadLanguage;
    procedure SetLabel(Text: string);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

type
  TOperationProgress = class(TObject)
  private
    FForm: TFormOperationProgress;
    function GetMax: Integer;
    function GetPosition: Integer;
    function GetText: string;
    procedure SetClosed(const Value: Boolean);
    procedure SetMax(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetText(const Value: string);
    function GetClosed: Boolean;
  public
    constructor Create(Owner: TDBForm);
    destructor Destroy; override;
    procedure Show;
    property Max: Integer read GetMax write SetMax;
    property Position: Integer read GetPosition write SetPosition;
    property Text: string read GetText write SetText;
    property Closed: Boolean read GetClosed write SetClosed;
  end;

implementation

{$R *.dfm}

{ TFormOperationProgress }

procedure TFormOperationProgress.BtnCancelClick(Sender: TObject);
begin
  BtnCancel.Enabled := True;
  FClosed := True;
end;

procedure TFormOperationProgress.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
    Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TFormOperationProgress.FormCreate(Sender: TObject);
begin
  FClosed := False;
  LoadLanguage;
end;

function TFormOperationProgress.GetFormID: string;
begin
  Result := 'OperationProgress';
end;

procedure TFormOperationProgress.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Please wait...');
    BtnCancel.Caption := L('Cancel');
  finally
    EndTranslate;
  end;
end;

procedure TFormOperationProgress.SetLabel(Text: string);
begin
  LbInfo.Caption := Text;
  PrbProgress.Top := LbInfo.Top + LbInfo.Height + 5;
  BtnCancel.Top := PrbProgress.Top + PrbProgress.Height + 5;
  ClientHeight := BtnCancel.Top + BtnCancel.Height + 5;
end;

{ TOperationProgress }

constructor TOperationProgress.Create(Owner: TDBForm);
begin
  FForm := TFormOperationProgress.Create(Owner);
end;

destructor TOperationProgress.Destroy;
begin
  R(FForm);
  inherited;
end;

function TOperationProgress.GetClosed: Boolean;
begin
  Result := FForm.FClosed;
end;

function TOperationProgress.GetMax: Integer;
begin
  Result := FForm.PrbProgress.Max;
end;

function TOperationProgress.GetPosition: Integer;
begin
  Result := FForm.PrbProgress.Position;
end;

function TOperationProgress.GetText: string;
begin
  Result := FForm.LbInfo.Caption;
end;

procedure TOperationProgress.SetClosed(const Value: Boolean);
begin
  FForm.FClosed := Value;
end;

procedure TOperationProgress.SetMax(const Value: Integer);
begin
  FForm.PrbProgress.Max := Value;
end;

procedure TOperationProgress.SetPosition(const Value: Integer);
begin
  FForm.PrbProgress.Position := Value;
  FForm.Repaint;
  Application.ProcessMessages;
end;

procedure TOperationProgress.SetText(const Value: string);
begin
  FForm.SetLabel(Value);
end;

procedure TOperationProgress.Show;
begin
  FForm.Show;
end;

end.
